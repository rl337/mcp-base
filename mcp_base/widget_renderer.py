"""Widget renderer with dependency injection support.

This module provides a renderer that uses dependency injection to select
the appropriate view implementation based on context.
"""

import logging

from pyiv import Injector

from mcp_base.user_agent import detect_device_type
from mcp_base.widget_views import ViewContext, ViewRequest, WidgetView

logger = logging.getLogger(__name__)


class WidgetRenderer:
    """Widget renderer that uses dependency injection to select views.

    The renderer looks up view implementations from the injector based on
    ViewContext. If no specific view is registered for a context, it falls
    back to the default view.

    Example:
        from pyiv import get_injector
        from mcp_base.widget_views import ViewContext, ViewRequest
        from mcp_base.widget_renderer import WidgetRenderer

        injector = get_injector(MyConfig)
        renderer = WidgetRenderer(injector)

        request = ViewRequest(
            context=ViewContext.LIST,
            widget=my_widget,
            base_path="/v1/widgets"
        )
        html = renderer.render(request)
    """

    def __init__(self, injector: Injector):
        """Initialize widget renderer.

        Args:
            injector: Configured pyiv injector with view registrations
        """
        self.injector = injector
        self._view_cache: dict[ViewContext, WidgetView | None] = {}

    def resolve_context(self, context: ViewContext, user_agent: str | None = None) -> ViewContext:
        """Resolve a simple context to a composite context based on user agent.

        If context is already composite (LIST_MOBILE, etc.), returns it as-is.
        If context is simple (LIST, DETAIL), resolves to composite based on user agent.

        Args:
            context: View context (simple or composite)
            user_agent: Optional user agent string for device detection

        Returns:
            Resolved ViewContext (composite if possible, otherwise original)
        """
        # If already composite, return as-is
        if context in (
            ViewContext.LIST_MOBILE,
            ViewContext.LIST_DESKTOP,
            ViewContext.DETAIL_MOBILE,
            ViewContext.DETAIL_DESKTOP,
        ):
            return context

        # Resolve simple contexts to composite
        device_type = detect_device_type(user_agent)
        if context == ViewContext.LIST:
            return ViewContext.LIST_MOBILE if device_type == "mobile" else ViewContext.LIST_DESKTOP
        elif context == ViewContext.DETAIL:
            return (
                ViewContext.DETAIL_MOBILE if device_type == "mobile" else ViewContext.DETAIL_DESKTOP
            )

        # For other contexts, return as-is
        return context

    def get_view(self, context: ViewContext, user_agent: str | None = None) -> WidgetView:
        """Get view implementation for a context.

        Uses dependency injection to look up the view. If no specific view
        is registered, returns the default view.

        The injector should register views like:
            config.bind(WidgetView, ListWidgetView, singleton=True)
            config.bind(WidgetView, DetailWidgetView, singleton=True)

        The renderer will try to inject WidgetView and check if its view_context
        matches. If multiple views are registered, it will use the first one
        that matches the context.

        Args:
            context: The view context
            user_agent: Optional user agent for resolving composite contexts

        Returns:
            WidgetView implementation for the context
        """
        # Resolve to composite context if needed
        resolved_context = self.resolve_context(context, user_agent)

        # Check cache first
        if resolved_context in self._view_cache:
            cached = self._view_cache[resolved_context]
            if cached is not None:
                return cached

        # Try to get view from injector
        # Since pyiv doesn't support context-based injection directly,
        # we need to get all registered WidgetView implementations and
        # find one that matches the context
        config = self.injector._config

        # Check if there are any WidgetView registrations
        if hasattr(config, "_registrations"):
            # Look for WidgetView registrations
            for abstract_type in config._registrations.keys():
                if abstract_type == WidgetView:
                    # This is a registration for WidgetView interface
                    concrete = config.get_registration(abstract_type)
                    if concrete and issubclass(concrete, WidgetView):
                        try:
                            view = self.injector.inject(concrete)
                            if (
                                isinstance(view, WidgetView)
                                and view.view_context == resolved_context
                            ):
                                self._view_cache[resolved_context] = view
                                logger.debug(
                                    f"Found registered view for context: {resolved_context}"
                                )
                                return view
                        except Exception as e:
                            logger.debug(f"Could not inject view {concrete}: {e}")
                elif (
                    isinstance(abstract_type, type)
                    and issubclass(abstract_type, WidgetView)
                    and abstract_type != WidgetView
                ):
                    # This is a concrete WidgetView class registered directly
                    try:
                        view = self.injector.inject(abstract_type)
                        if isinstance(view, WidgetView) and view.view_context == resolved_context:
                            self._view_cache[resolved_context] = view
                            logger.debug(f"Found registered view for context: {resolved_context}")
                            return view
                    except Exception as e:
                        logger.debug(f"Could not inject view {abstract_type}: {e}")

        # Also try reflection-based discovery if available
        if hasattr(config, "discover_implementations"):
            try:
                implementations = config.discover_implementations(WidgetView)
                for _name, view_class in implementations.items():
                    try:
                        view = self.injector.inject(view_class)
                        if isinstance(view, WidgetView) and view.view_context == resolved_context:
                            self._view_cache[resolved_context] = view
                            logger.debug(
                                f"Found view via reflection for context: {resolved_context}"
                            )
                            return view
                    except Exception as e:
                        logger.debug(f"Could not inject view {view_class}: {e}")
            except Exception as e:
                logger.debug(f"Reflection discovery failed: {e}")

        # Fallback to default view
        from mcp_base.widget_views import DefaultWidgetView

        default_view = DefaultWidgetView(resolved_context)
        self._view_cache[resolved_context] = default_view
        logger.debug(f"Using default view for context: {resolved_context}")
        return default_view

    def render(self, request: ViewRequest, user_agent: str | None = None) -> str:
        """Render a widget using the appropriate view.

        Args:
            request: View request with widget and context
            user_agent: Optional user agent for resolving composite contexts

        Returns:
            HTML string for the rendered widget
        """
        view = self.get_view(request.context, user_agent)
        return view.render(request)

    def render_multiple(
        self,
        requests: list[ViewRequest],
        context: ViewContext | None = None,
        user_agent: str | None = None,
    ) -> str:
        """Render multiple widgets.

        If context is provided, all widgets are rendered with that context.
        Otherwise, each request's context is used.

        Args:
            requests: List of view requests
            context: Optional context to use for all widgets

        Returns:
            HTML string containing all rendered widgets
        """
        if not requests:
            return ""

        if context:
            # Use same context for all
            view = self.get_view(context, user_agent)
            # Update all requests to use the same context
            updated_requests = [
                ViewRequest(
                    context=context,
                    widget=req.widget,
                    base_path=req.base_path,
                    metadata=req.metadata,
                )
                for req in requests
            ]
            return view.render_multiple(updated_requests)
        else:
            # Use each request's context
            # Group by context for efficiency
            by_context: dict[ViewContext, list[ViewRequest]] = {}
            for req in requests:
                if req.context not in by_context:
                    by_context[req.context] = []
                by_context[req.context].append(req)

            # Render each group
            results = []
            for ctx, reqs in by_context.items():
                view = self.get_view(ctx, user_agent)
                results.append(view.render_multiple(reqs))

            return "\n".join(results)
