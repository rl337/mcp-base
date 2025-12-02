"""Widget server integration for MCP services.

This module provides widget discovery, activity timeline tracking, and
web interface endpoints for rendering interactive widgets.
"""

import logging
import time
from collections import deque
from datetime import datetime

from fastapi import APIRouter, FastAPI, HTTPException, Request
from fastapi.responses import HTMLResponse
from pyiv import Injector

from mcp_base.metrics import record_http_request
from mcp_base.user_agent import get_view_context
from mcp_base.widget_renderer import WidgetRenderer
from mcp_base.widget_views import ViewContext, ViewRequest
from mcp_base.widgets import WidgetAction, WidgetCard, WidgetProvider

logger = logging.getLogger(__name__)

# In-memory activity timeline (in production, this could be backed by a database)
_activity_timeline: deque[WidgetCard] = deque(maxlen=1000)


class WidgetServer:
    """Widget server for MCP services.

    Provides widget discovery, activity timeline tracking, and web interface
    endpoints. Widgets are automatically discovered from WidgetProvider implementations.

    Example:
        from fastapi import FastAPI
        from mcp_base import WidgetServer
        from pyiv import get_injector

        app = FastAPI()
        injector = get_injector(MyConfig)

        widget_server = WidgetServer(
            app=app,
            interface=WidgetProvider,
            injector=injector,
            base_path="/v1/widgets"
        )
    """

    def __init__(
        self,
        app: FastAPI,
        interface: type[WidgetProvider],
        injector: Injector,
        base_path: str = "/v1/widgets",
        widget_registry: dict[str, type[WidgetProvider]] | None = None,
        enable_observability: bool = True,
    ):
        """Initialize widget server.

        Args:
            app: FastAPI application
            interface: Interface class for widget providers (e.g., WidgetProvider)
            injector: Configured pyiv injector
            base_path: Base path for widget routes
            widget_registry: Optional manual registry of widget provider classes.
                           If not provided, will attempt to discover from injector config.
            enable_observability: Whether to enable observability (metrics and tracing)
        """
        self.app = app
        self.interface = interface
        self.injector = injector
        self.base_path = base_path
        self.enable_observability = enable_observability

        # Create widget renderer
        self.renderer = WidgetRenderer(injector)

        # Build widget provider registry
        if widget_registry:
            self._providers = widget_registry
        else:
            self._providers = self._discover_providers()

        # Register routes
        self._register_routes()

    def _discover_providers(self) -> dict[str, type[WidgetProvider]]:
        """Discover all widget providers from the injector configuration.

        Returns:
            Dictionary mapping widget provider names to provider classes
        """
        providers = {}
        config = self.injector._config

        # Try reflection-based discovery if available
        if hasattr(config, "discover_implementations"):
            try:
                implementations = config.discover_implementations(self.interface)
                for name, provider_class in implementations.items():
                    try:
                        temp_provider = self.injector.inject(provider_class)
                        widget_name = temp_provider.widget_name
                        providers[widget_name] = provider_class
                    except Exception as e:
                        logger.warning(
                            f"Could not get widget_name from provider {name}: {e}. "
                            f"Using class name as fallback."
                        )
                        widget_name = provider_class.__name__.lower().replace("provider", "")
                        providers[widget_name] = provider_class
            except Exception as e:
                logger.warning(f"Reflection discovery failed: {e}. Falling back to manual scan.")

        # Fallback: scan registered types
        if not providers:
            for abstract_type in config._registrations.keys():
                if abstract_type == self.interface:
                    concrete = config.get_registration(abstract_type)
                    if concrete and issubclass(concrete, self.interface):
                        try:
                            temp_provider = self.injector.inject(concrete)
                            widget_name = temp_provider.widget_name
                            providers[widget_name] = concrete
                        except Exception as e:
                            logger.warning(f"Could not instantiate provider {concrete}: {e}")
                elif issubclass(abstract_type, self.interface) and abstract_type != self.interface:
                    try:
                        temp_provider = self.injector.inject(abstract_type)
                        widget_name = temp_provider.widget_name
                        providers[widget_name] = abstract_type
                    except Exception as e:
                        logger.warning(f"Could not instantiate provider {abstract_type}: {e}")

        if not providers:
            logger.warning(
                f"No widget providers discovered for {self.interface.__name__}. "
                "Consider using ReflectionConfig or providing widget_registry manually."
            )

        return providers

    def _register_routes(self):
        """Register FastAPI routes for widget endpoints."""
        router = APIRouter(prefix=self.base_path, tags=["widgets"])

        # Root endpoint - redirect to widget UI (list view)
        @self.app.get("/", response_class=HTMLResponse)
        async def root_handler(request: Request):
            """Root endpoint - serves the widget list UI.

            This is the default handler for the service, providing the widget
            timeline interface. Does not conflict with MCP protocols which use
            paths like /v1/mcp/tools.
            """
            start_time = time.time()
            status_code = 200
            error_type = None

            try:
                # Get user agent
                user_agent = request.headers.get("user-agent")

                # Determine composite view context (list view)
                context_str = get_view_context("list", user_agent)
                try:
                    composite_context = ViewContext(context_str)
                except ValueError:
                    # Fallback to default
                    composite_context = ViewContext.LIST_DESKTOP

                html = self._render_ui(composite_context)
                return HTMLResponse(content=html)
            except Exception:
                status_code = 500
                error_type = "exception"
                raise
            finally:
                if self.enable_observability:
                    duration = time.time() - start_time
                    record_http_request("GET", "/", status_code, duration, error_type)

        # Web UI endpoint
        @router.get("/ui", response_class=HTMLResponse)
        async def widget_ui(request: Request, view: str = "list"):
            """Render the widget web interface.

            Args:
                view: View type (list or detail)
            """
            start_time = time.time()
            status_code = 200
            error_type = None

            try:
                # Get user agent
                user_agent = request.headers.get("user-agent")

                # Determine composite view context
                view_lower = view.lower()
                view_type_str: str = view_lower if view_lower in ("list", "detail") else "list"
                context_str = get_view_context(view_type_str, user_agent)  # type: ignore[arg-type]
                try:
                    composite_context = ViewContext(context_str)
                except ValueError:
                    composite_context = ViewContext.LIST_DESKTOP

                html = self._render_ui(composite_context)
                return HTMLResponse(content=html)
            except Exception:
                status_code = 500
                error_type = "exception"
                raise
            finally:
                if self.enable_observability:
                    duration = time.time() - start_time
                    record_http_request("GET", "/ui", status_code, duration, error_type)

        # Server-side widget rendering endpoint
        @router.post("/render")
        async def render_widgets(request: Request):
            """Render widgets server-side using the view system.

            Request body:
                {
                    "widgets": [...],  # List of widget dicts
                    "context": "list"  # Optional: list, detail, mobile, desktop, default
                }
            """
            start_time = time.time()
            status_code = 200
            error_type = None

            try:
                body = await request.json()
                widgets_data = body.get("widgets", [])
                context_str = body.get("context", "list")

                # Parse context
                try:
                    context = ViewContext(context_str.lower())
                except ValueError:
                    context = ViewContext.LIST

                # Convert widget dicts to WidgetCard objects
                widgets = []
                for widget_dict in widgets_data:
                    actions = []
                    for action_dict in widget_dict.get("actions", []):
                        actions.append(
                            WidgetAction(
                                label=action_dict.get("label", ""),
                                method=action_dict.get("method", "POST"),
                                url=action_dict.get("url", ""),
                                payload=action_dict.get("payload", {}),
                                confirm=action_dict.get("confirm", False),
                                confirm_message=action_dict.get("confirm_message", "Are you sure?"),
                            )
                        )

                    widget = WidgetCard(
                        id=widget_dict.get("id", ""),
                        title=widget_dict.get("title", ""),
                        content=widget_dict.get("content", ""),
                        timestamp=datetime.fromisoformat(
                            widget_dict.get("timestamp", datetime.now().isoformat())
                        ),
                        service_name=widget_dict.get("service_name", ""),
                        tool_name=widget_dict.get("tool_name", ""),
                        actions=actions,
                        metadata=widget_dict.get("metadata", {}),
                        card_type=widget_dict.get("card_type", "default"),
                        icon=widget_dict.get("icon", ""),
                    )
                    widgets.append(widget)

                # Create view requests
                view_requests = [
                    ViewRequest(
                        context=context,
                        widget=widget,
                        base_path=self.base_path,
                    )
                    for widget in widgets
                ]

                # Get user agent from request
                user_agent = request.headers.get("user-agent")

                # Render using renderer
                html = self.renderer.render_multiple(
                    view_requests, context=context, user_agent=user_agent
                )

                return {"html": html}
            except Exception:
                status_code = 500
                error_type = "exception"
                raise
            finally:
                if self.enable_observability:
                    duration = time.time() - start_time
                    record_http_request("POST", "/render", status_code, duration, error_type)

        # Get activity timeline
        @router.get("/timeline")
        async def get_timeline(
            request: Request,
            limit: int = 50,
            since: str | None = None,
        ):
            """Get activity timeline of widgets.

            Args:
                limit: Maximum number of widgets to return
                since: ISO timestamp - only return widgets after this time
            """
            start_time = time.time()
            status_code = 200
            error_type = None

            try:
                # Get widgets from all providers
                all_widgets: list[WidgetCard] = []

                # Get widgets from providers
                for provider_name, provider_class in self._providers.items():
                    try:
                        provider_instance = self.injector.inject(provider_class)
                        since_dt = None
                        if since:
                            since_dt = datetime.fromisoformat(since.replace("Z", "+00:00"))
                        widgets = await provider_instance.get_widgets(limit=limit, since=since_dt)
                        all_widgets.extend(widgets)
                    except Exception as e:
                        logger.warning(f"Error getting widgets from {provider_name}: {e}")

                # Add widgets from in-memory timeline
                timeline_widgets = list(_activity_timeline)
                all_widgets.extend(timeline_widgets)

                # Sort by timestamp (newest first) and deduplicate by ID
                seen_ids = set()
                unique_widgets = []
                for widget in sorted(all_widgets, key=lambda w: w.timestamp, reverse=True):
                    if widget.id not in seen_ids:
                        seen_ids.add(widget.id)
                        unique_widgets.append(widget)
                        if len(unique_widgets) >= limit:
                            break

                return {"widgets": [w.to_dict() for w in unique_widgets]}
            except Exception:
                status_code = 500
                error_type = "exception"
                raise
            finally:
                if self.enable_observability:
                    duration = time.time() - start_time
                    record_http_request("GET", "/timeline", status_code, duration, error_type)

        # Create widget (for services to add widgets to timeline)
        @router.post("/create")
        async def create_widget(request: Request):
            """Create a new widget and add it to the timeline."""
            start_time = time.time()
            status_code = 200
            error_type = None

            try:
                body = await request.json()
                widget_dict = body.get("widget", {})

                # Deserialize actions
                actions = []
                for action_dict in widget_dict.get("actions", []):
                    if isinstance(action_dict, dict):
                        actions.append(
                            WidgetAction(
                                label=action_dict.get("label", ""),
                                method=action_dict.get("method", "POST"),
                                url=action_dict.get("url", ""),
                                payload=action_dict.get("payload", {}),
                                confirm=action_dict.get("confirm", False),
                                confirm_message=action_dict.get("confirm_message", "Are you sure?"),
                            )
                        )

                # Create widget from dict
                widget = WidgetCard(
                    id=widget_dict.get("id", ""),
                    title=widget_dict.get("title", ""),
                    content=widget_dict.get("content", ""),
                    timestamp=datetime.fromisoformat(
                        widget_dict.get("timestamp", datetime.now().isoformat())
                    ),
                    service_name=widget_dict.get("service_name", ""),
                    tool_name=widget_dict.get("tool_name", ""),
                    actions=actions,
                    metadata=widget_dict.get("metadata", {}),
                    card_type=widget_dict.get("card_type", "default"),
                    icon=widget_dict.get("icon", ""),
                )

                # Add to timeline
                _activity_timeline.append(widget)

                return {"widget": widget.to_dict()}
            except Exception:
                status_code = 500
                error_type = "exception"
                raise
            finally:
                if self.enable_observability:
                    duration = time.time() - start_time
                    record_http_request("POST", "/create", status_code, duration, error_type)

        # Execute widget action (proxy to service endpoints)
        @router.post("/action/{widget_id}")
        async def execute_action(widget_id: str, request: Request):
            """Execute an action from a widget."""
            start_time = time.time()
            status_code = 200
            error_type = None

            try:
                body = await request.json()
                action_index = body.get("action_index", 0)

                # Find widget in timeline
                widget = None
                for w in _activity_timeline:
                    if w.id == widget_id:
                        widget = w
                        break

                if not widget:
                    status_code = 404
                    error_type = "not_found"
                    raise HTTPException(404, f"Widget '{widget_id}' not found")

                if action_index >= len(widget.actions):
                    status_code = 400
                    error_type = "validation_error"
                    raise HTTPException(400, "Invalid action index")

                action = widget.actions[action_index]

                # Return action details - the frontend will make the actual HTTP call
                return {
                    "action": {
                        "method": action.method,
                        "url": action.url,
                        "payload": action.payload,
                    }
                }
            except HTTPException:
                raise
            except Exception:
                status_code = 500
                error_type = "exception"
                raise
            finally:
                if self.enable_observability:
                    duration = time.time() - start_time
                    record_http_request(
                        "POST", f"/action/{widget_id}", status_code, duration, error_type
                    )

        self.app.include_router(router)

    def _render_ui(self, default_context: ViewContext = ViewContext.LIST_DESKTOP) -> str:
        """Render the HTML for the widget web interface."""
        return (
            """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MCP Service Widgets</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
        }
        .header {
            background: white;
            border-radius: 12px;
            padding: 24px;
            margin-bottom: 24px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        .header h1 {
            color: #333;
            margin-bottom: 8px;
        }
        .header p {
            color: #666;
        }
        .timeline {
            display: grid;
            gap: 20px;
        }
        .widget-card {
            background: white;
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            transition: transform 0.2s, box-shadow 0.2s;
            border-left: 4px solid #667eea;
        }
        .widget-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 12px rgba(0, 0, 0, 0.15);
        }
        .widget-card.success { border-left-color: #10b981; }
        .widget-card.warning { border-left-color: #f59e0b; }
        .widget-card.error { border-left-color: #ef4444; }
        .widget-card.info { border-left-color: #3b82f6; }
        .widget-header {
            display: flex;
            justify-content: space-between;
            align-items: start;
            margin-bottom: 12px;
        }
        .widget-title {
            font-size: 18px;
            font-weight: 600;
            color: #333;
            margin-bottom: 4px;
        }
        .widget-meta {
            font-size: 12px;
            color: #999;
        }
        .widget-content {
            color: #555;
            line-height: 1.6;
            margin-bottom: 16px;
        }
        .widget-actions {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }
        .action-btn {
            padding: 8px 16px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 500;
            transition: all 0.2s;
            background: #667eea;
            color: white;
        }
        .action-btn:hover {
            background: #5568d3;
            transform: scale(1.05);
        }
        .action-btn.secondary {
            background: #e5e7eb;
            color: #333;
        }
        .action-btn.secondary:hover {
            background: #d1d5db;
        }
        .loading {
            text-align: center;
            padding: 40px;
            color: white;
            font-size: 18px;
        }
        .empty {
            text-align: center;
            padding: 40px;
            background: white;
            border-radius: 12px;
            color: #666;
        }
        .refresh-btn {
            position: fixed;
            bottom: 24px;
            right: 24px;
            width: 56px;
            height: 56px;
            border-radius: 50%;
            background: white;
            border: none;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            cursor: pointer;
            font-size: 24px;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: transform 0.2s;
        }
        .refresh-btn:hover {
            transform: rotate(180deg) scale(1.1);
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>MCP Service Activity Timeline</h1>
            <p>Interactive widgets from your MCP services</p>
        </div>
        <div id="timeline" class="timeline">
            <div class="loading">Loading widgets...</div>
        </div>
    </div>
    <button class="refresh-btn" onclick="loadWidgets()" title="Refresh">↻</button>
    <script>
        const basePath = '"""
            + self.base_path
            + """';

        async function loadWidgets() {
            const timeline = document.getElementById('timeline');
            timeline.innerHTML = '<div class="loading">Loading widgets...</div>';

            try {
                const response = await fetch(`${basePath}/timeline?limit=50`);
                const data = await response.json();
                const widgets = data.widgets || [];

                if (widgets.length === 0) {
                    timeline.innerHTML = '<div class="empty">No widgets available</div>';
                    return;
                }

                timeline.innerHTML = widgets.map(widget => renderWidget(widget)).join('');

                // Attach action handlers
                widgets.forEach((widget, idx) => {
                    widget.actions.forEach((action, actionIdx) => {
                        const btn = document.getElementById(`action-${widget.id}-${actionIdx}`);
                        if (btn) {
                            btn.onclick = () => handleAction(widget, actionIdx, action);
                        }
                    });
                });
            } catch (error) {
                timeline.innerHTML = `<div class="empty">Error loading widgets: ${error.message}</div>`;
            }
        }

        function renderWidget(widget) {
            const timestamp = new Date(widget.timestamp).toLocaleString();
            const actions = widget.actions.map((action, idx) =>
                `<button id="action-${widget.id}-${idx}" class="action-btn ${idx > 0 ? 'secondary' : ''}">${action.label}</button>`
            ).join('');

            return `
                <div class="widget-card ${widget.card_type}">
                    <div class="widget-header">
                        <div>
                            <div class="widget-title">${escapeHtml(widget.title)}</div>
                            <div class="widget-meta">
                                ${widget.service_name ? escapeHtml(widget.service_name) : ''}
                                ${widget.tool_name ? ' • ' + escapeHtml(widget.tool_name) : ''}
                                • ${timestamp}
                            </div>
                        </div>
                    </div>
                    <div class="widget-content">${widget.content}</div>
                    ${actions ? `<div class="widget-actions">${actions}</div>` : ''}
                </div>
            `;
        }

        async function handleAction(widget, actionIndex, action) {
            if (action.confirm) {
                if (!confirm(action.confirm_message || 'Are you sure?')) {
                    return;
                }
            }

            try {
                let url = action.url;
                if (!url.startsWith('http')) {
                    // Relative URL - construct full path
                    url = basePath.replace('/v1/widgets', '') + url;
                }

                const options = {
                    method: action.method || 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                };

                if (action.method !== 'GET' && Object.keys(action.payload || {}).length > 0) {
                    options.body = JSON.stringify(action.payload);
                }

                const response = await fetch(url, options);
                const result = await response.json();

                // Show result (could be improved with a toast notification)
                alert(`Action completed: ${JSON.stringify(result)}`);

                // Reload widgets to show updated state
                loadWidgets();
            } catch (error) {
                alert(`Error executing action: ${error.message}`);
            }
        }

        function escapeHtml(text) {
            const div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        }

        // Load widgets on page load
        loadWidgets();

        // Auto-refresh every 30 seconds
        setInterval(loadWidgets, 30000);
    </script>
</body>
</html>"""
        )
