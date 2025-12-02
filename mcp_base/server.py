"""Base MCP server with automatic handler discovery and routing."""

import json
import logging
import time
from contextlib import nullcontext
from typing import Any

from fastapi import APIRouter, FastAPI, HTTPException, Request
from fastapi.responses import StreamingResponse
from pyiv import Injector

from mcp_base.handler import McpToolHandler
from mcp_base.metrics import (
    get_metrics,
    get_metrics_content_type,
    record_http_request,
)

logger = logging.getLogger(__name__)


class McpServerBase:
    """Base class for MCP servers with automatic handler discovery.

    This class provides automatic route generation and handler discovery
    for MCP services. Handlers are discovered via dependency injection
    configuration and automatically registered as FastAPI routes.

    Example:
        from fastapi import FastAPI
        from mcp_base import McpServerBase, McpToolHandler
        from pyiv import get_injector

        app = FastAPI()
        injector = get_injector(MyConfig)

        mcp_server = McpServerBase(
            app=app,
            tool_package="my_service.mcp.handlers",
            interface=McpToolHandler,
            injector=injector,
            base_path="/v1/mcp/tools"
        )
    """

    def __init__(
        self,
        app: FastAPI,
        tool_package: str,
        interface: type[McpToolHandler],
        injector: Injector,
        base_path: str = "/v1/mcp/tools",
        handler_registry: dict[str, type[McpToolHandler]] | None = None,
        metrics_collector: Any | None = None,  # MetricsCollector
        tracing_collector: Any | None = None,  # TracingCollector
        enable_observability: bool = True,
    ):
        """Initialize MCP base server.

        Args:
            app: FastAPI application
            tool_package: Package path where handlers are defined (for documentation)
            interface: Interface class for handlers (e.g., McpToolHandler)
            injector: Configured pyiv injector
            base_path: Base path for MCP routes
            handler_registry: Optional manual registry of handler classes by tool name.
                           If not provided, will attempt to discover from injector config.
            metrics_collector: Optional metrics collector (for testing). If None, uses default.
            tracing_collector: Optional tracing collector (for testing). If None, uses default.
            enable_observability: Whether to enable observability (metrics and tracing)
        """
        self.app = app
        self.tool_package = tool_package
        self.interface = interface
        self.injector = injector
        self.base_path = base_path
        self.enable_observability = enable_observability

        # Set up observability collectors
        if metrics_collector:
            from mcp_base.metrics import set_metrics_collector

            set_metrics_collector(metrics_collector)
        if tracing_collector:
            from mcp_base.tracing import set_tracing_collector

            set_tracing_collector(tracing_collector)

        # Build handler registry
        if handler_registry:
            self._handlers = handler_registry
        else:
            self._handlers = self._discover_handlers()

        # Register routes
        self._register_routes()

    def _discover_handlers(self) -> dict[str, type[McpToolHandler]]:
        """Discover all handlers from the injector configuration.

        This method attempts to discover handlers in two ways:
        1. If config has discover_implementations (ReflectionConfig), use it
        2. Otherwise, scan registered types in config for interface implementations

        Returns:
            Dictionary mapping tool names to handler classes
        """
        handlers = {}
        config = self.injector._config

        # Try reflection-based discovery if available
        if hasattr(config, "discover_implementations"):
            try:
                implementations = config.discover_implementations(self.interface)
                for name, handler_class in implementations.items():
                    # Extract tool name from handler instance
                    try:
                        # Create temporary instance to get tool_name
                        # Since handlers are singletons, this should be cheap
                        temp_handler = self.injector.inject(handler_class)
                        tool_name = temp_handler.tool_name
                        handlers[tool_name] = handler_class
                    except Exception as e:
                        logger.warning(
                            f"Could not get tool_name from handler {name}: {e}. "
                            f"Using class name as fallback."
                        )
                        # Fallback: use class name (lowercase, remove 'Handler' suffix)
                        tool_name = handler_class.__name__.lower().replace("handler", "")
                        handlers[tool_name] = handler_class
            except Exception as e:
                logger.warning(f"Reflection discovery failed: {e}. Falling back to manual scan.")

        # Fallback: scan registered types
        if not handlers:
            # Check all registered types
            for abstract_type in config._registrations.keys():
                # Check if this registration is for our interface
                if abstract_type == self.interface:
                    concrete = config.get_registration(abstract_type)
                    if concrete and issubclass(concrete, self.interface):
                        try:
                            temp_handler = self.injector.inject(concrete)
                            tool_name = temp_handler.tool_name
                            handlers[tool_name] = concrete
                        except Exception as e:
                            logger.warning(f"Could not instantiate handler {concrete}: {e}")
                # Also check if the registered type itself implements the interface
                elif issubclass(abstract_type, self.interface) and abstract_type != self.interface:
                    # This handles cases where concrete types are registered directly
                    try:
                        temp_handler = self.injector.inject(abstract_type)
                        tool_name = temp_handler.tool_name
                        handlers[tool_name] = abstract_type
                    except Exception as e:
                        logger.warning(f"Could not instantiate handler {abstract_type}: {e}")

        if not handlers:
            logger.warning(
                f"No handlers discovered for {self.interface.__name__} in package {self.tool_package}. "
                "Consider using ReflectionConfig or providing handler_registry manually."
            )

        return handlers

    def _register_routes(self):
        """Register FastAPI routes for each discovered handler."""
        router = APIRouter(prefix=self.base_path, tags=["mcp"])

        # List all tools
        @router.get("")
        async def list_tools(request: Request):
            """List all available MCP tools."""
            start_time = time.time()
            status_code = 200
            error_type = None

            try:
                tools = []
                for tool_name, handler_class in self._handlers.items():
                    schema = self._get_tool_schema(handler_class, tool_name)
                    tools.append(schema)
                return {"tools": tools}
            except Exception:
                status_code = 500
                error_type = "exception"
                raise
            finally:
                if self.enable_observability:
                    duration = time.time() - start_time
                    record_http_request("GET", "/", status_code, duration, error_type)

        # Get tool schema
        @router.get("/{tool_name}/schema")
        async def get_tool_schema(tool_name: str, request: Request):
            """Get schema for a specific tool."""
            start_time = time.time()
            status_code = 200
            error_type = None

            try:
                if tool_name not in self._handlers:
                    status_code = 404
                    error_type = "not_found"
                    raise HTTPException(404, f"Tool '{tool_name}' not found")

                handler_class = self._handlers[tool_name]
                schema = self._get_tool_schema(handler_class, tool_name)
                return schema
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
                        "GET", f"/{tool_name}/schema", status_code, duration, error_type
                    )

        # Execute tool (SSE endpoint)
        @router.post("/{tool_name}/sse")
        async def execute_tool_sse(tool_name: str, request: Request):
            """Execute tool and return SSE stream."""
            start_time = time.time()
            status_code = 200
            error_type = None

            try:
                body = await request.json()
                arguments = body.get("arguments", {})

                async def generate():
                    try:
                        results = await self._execute_tool(tool_name, arguments)
                        for result in results:
                            yield f"data: {json.dumps(result)}\n\n"
                        yield "data: [DONE]\n\n"
                    except Exception as e:
                        error_msg = {"error": str(e)}
                        yield f"data: {json.dumps(error_msg)}\n\n"

                return StreamingResponse(generate(), media_type="text/event-stream")
            except HTTPException as e:
                status_code = e.status_code
                error_type = "http_error"
                raise
            except Exception:
                status_code = 500
                error_type = "exception"
                raise
            finally:
                if self.enable_observability:
                    duration = time.time() - start_time
                    record_http_request(
                        "POST", f"/{tool_name}/sse", status_code, duration, error_type
                    )

        # Execute tool (JSON-RPC endpoint)
        @router.post("/{tool_name}/jsonrpc")
        async def execute_tool_jsonrpc(tool_name: str, request: Request):
            """Execute tool via JSON-RPC 2.0."""
            start_time = time.time()
            status_code = 200
            error_type = None

            try:
                body = await request.json()

                # Validate JSON-RPC request
                if "method" in body and body["method"] != tool_name:
                    status_code = 400
                    error_type = "validation_error"
                    raise HTTPException(400, "Method name mismatch")

                arguments = body.get("params", {})
                request_id = body.get("id")

                try:
                    result = await self._execute_tool(tool_name, arguments)
                    return {"jsonrpc": "2.0", "id": request_id, "result": result}
                except Exception as e:
                    status_code = 500
                    error_type = "tool_error"
                    return {
                        "jsonrpc": "2.0",
                        "id": request_id,
                        "error": {"code": -32603, "message": str(e)},
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
                        "POST", f"/{tool_name}/jsonrpc", status_code, duration, error_type
                    )

        # Simple POST endpoint (non-streaming)
        @router.post("/{tool_name}")
        async def execute_tool_simple(tool_name: str, request: Request):
            """Execute tool and return result directly."""
            start_time = time.time()
            status_code = 200
            error_type = None

            try:
                body = await request.json()
                arguments = body.get("arguments", {})
                result = await self._execute_tool(tool_name, arguments)
                return {"result": result}
            except HTTPException as e:
                status_code = e.status_code
                error_type = "http_error"
                raise
            except Exception:
                status_code = 500
                error_type = "exception"
                raise
            finally:
                if self.enable_observability:
                    duration = time.time() - start_time
                    record_http_request("POST", f"/{tool_name}", status_code, duration, error_type)

        # Metrics endpoint
        @router.get("/metrics")
        async def metrics_endpoint():
            """Prometheus metrics endpoint."""
            from fastapi.responses import Response

            if self.enable_observability:
                metrics_data = get_metrics()
                content_type = get_metrics_content_type()
                return Response(content=metrics_data, media_type=content_type)
            return Response(content=b"# Metrics disabled\n", media_type="text/plain")

        self.app.include_router(router)

    async def _execute_tool(
        self, tool_name: str, arguments: dict[str, Any]
    ) -> list[dict[str, Any]]:
        """Execute a tool handler with dependency injection and observability.

        Args:
            tool_name: Name of the tool to execute
            arguments: Tool arguments

        Returns:
            List of result dictionaries (converted from TextContent)

        Raises:
            HTTPException: If tool not found or execution fails
        """
        if tool_name not in self._handlers:
            raise HTTPException(404, f"Tool '{tool_name}' not found")

        handler_class = self._handlers[tool_name]

        # Track metrics and tracing
        from mcp_base.metrics import get_metrics_collector
        from mcp_base.tracing import get_tracing_collector

        metrics: Any = None
        tracing: Any = None
        if self.enable_observability:
            metrics = get_metrics_collector()
            tracing = get_tracing_collector()

            # Create trace span for tool execution
            span_context: Any = tracing.trace_span(
                f"mcp.tool.{tool_name}", {"tool_name": tool_name, "arguments": str(arguments)[:200]}
            )

            # Track metrics
            metrics_context: Any = metrics.track_tool_execution(tool_name)
        else:
            span_context = nullcontext()
            metrics_context = nullcontext()

        try:
            with span_context, metrics_context:

                # Add span attributes
                if self.enable_observability and tracing:
                    tracing.add_span_attribute("mcp.tool.name", tool_name)
                    tracing.add_span_attribute("mcp.tool.arguments_count", len(arguments))

                # Inject handler instance
                # If registered as SINGLETON, this will reuse the cached instance
                handler_instance = self.injector.inject(handler_class)

                # Call handle method
                text_contents = await handler_instance.handle(arguments)

                # Convert TextContent to dict for JSON serialization
                results = []
                for content in text_contents:
                    if isinstance(content, dict):
                        results.append(content)
                    else:
                        # Handle TextContent objects
                        results.append(
                            {
                                "type": getattr(content, "type", "text"),
                                "text": getattr(content, "text", str(content)),
                            }
                        )

                # Mark span as successful
                if self.enable_observability and tracing:
                    tracing.set_span_status("OK")

                return results
        except HTTPException:
            if self.enable_observability and tracing:
                tracing.set_span_status("ERROR", "HTTP error")
            raise
        except Exception as e:
            logger.exception(f"Error executing tool {tool_name}")
            if self.enable_observability and tracing:
                tracing.set_span_status("ERROR", str(e))
                tracing.add_span_event(
                    "exception", {"exception_type": type(e).__name__, "exception_message": str(e)}
                )
            raise HTTPException(500, f"Tool execution failed: {str(e)}") from e

    def _get_tool_schema(
        self, handler_class: type[McpToolHandler], tool_name: str
    ) -> dict[str, Any]:
        """Extract tool schema from handler class.

        Args:
            handler_class: Handler class
            tool_name: Tool name (fallback if schema doesn't have name)

        Returns:
            Tool schema dictionary
        """
        try:
            # Try to get schema from a temporary instance
            # Since handlers are singletons, this should be cheap
            temp_handler = self.injector.inject(handler_class)
            schema = temp_handler.tool_schema

            if isinstance(schema, dict):
                # Ensure name is set
                if "name" not in schema:
                    schema["name"] = tool_name
                return schema
        except Exception as e:
            logger.warning(f"Could not get schema from handler {handler_class}: {e}")

        # Fallback: create basic schema
        return {
            "name": tool_name,
            "description": handler_class.__doc__ or f"Tool: {tool_name}",
            "inputSchema": {"type": "object", "properties": {}, "required": []},
        }
