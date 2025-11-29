"""Base MCP server with automatic handler discovery and routing."""

import logging
from typing import Type, Dict, Any, Optional
from fastapi import FastAPI, APIRouter, HTTPException, Request
from fastapi.responses import StreamingResponse
import json

from pyiv import Injector, Config

from mcp_base.handler import IMcpToolHandler, TextContent

logger = logging.getLogger(__name__)


class McpServerBase:
    """Base class for MCP servers with automatic handler discovery.
    
    This class provides automatic route generation and handler discovery
    for MCP services. Handlers are discovered via dependency injection
    configuration and automatically registered as FastAPI routes.
    
    Example:
        from fastapi import FastAPI
        from mcp_base import McpServerBase, IMcpToolHandler
        from pyiv import get_injector
        
        app = FastAPI()
        injector = get_injector(MyConfig)
        
        mcp_server = McpServerBase(
            app=app,
            tool_package="my_service.mcp.handlers",
            interface=IMcpToolHandler,
            injector=injector,
            base_path="/v1/mcp/tools"
        )
    """
    
    def __init__(
        self,
        app: FastAPI,
        tool_package: str,
        interface: Type[IMcpToolHandler],
        injector: Injector,
        base_path: str = "/v1/mcp/tools",
        handler_registry: Optional[Dict[str, Type[IMcpToolHandler]]] = None
    ):
        """Initialize MCP base server.
        
        Args:
            app: FastAPI application
            tool_package: Package path where handlers are defined (for documentation)
            interface: Interface class for handlers (e.g., IMcpToolHandler)
            injector: Configured pyiv injector
            base_path: Base path for MCP routes
            handler_registry: Optional manual registry of handler classes by tool name.
                           If not provided, will attempt to discover from injector config.
        """
        self.app = app
        self.tool_package = tool_package
        self.interface = interface
        self.injector = injector
        self.base_path = base_path
        
        # Build handler registry
        if handler_registry:
            self._handlers = handler_registry
        else:
            self._handlers = self._discover_handlers()
        
        # Register routes
        self._register_routes()
    
    def _discover_handlers(self) -> Dict[str, Type[IMcpToolHandler]]:
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
        if hasattr(config, 'discover_implementations'):
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
                        tool_name = handler_class.__name__.lower().replace('handler', '')
                        handlers[tool_name] = handler_class
            except Exception as e:
                logger.warning(f"Reflection discovery failed: {e}. Falling back to manual scan.")
        
        # Fallback: scan registered types
        if not handlers:
            # Check all registered types
            for abstract_type in config._registrations.keys():
                if issubclass(abstract_type, self.interface) and abstract_type != self.interface:
                    concrete = config.get_registration(abstract_type)
                    if concrete and issubclass(concrete, self.interface):
                        try:
                            temp_handler = self.injector.inject(concrete)
                            tool_name = temp_handler.tool_name
                            handlers[tool_name] = concrete
                        except Exception as e:
                            logger.warning(f"Could not instantiate handler {concrete}: {e}")
        
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
        async def list_tools():
            """List all available MCP tools."""
            tools = []
            for tool_name, handler_class in self._handlers.items():
                schema = self._get_tool_schema(handler_class, tool_name)
                tools.append(schema)
            return {"tools": tools}
        
        # Get tool schema
        @router.get("/{tool_name}/schema")
        async def get_tool_schema(tool_name: str):
            """Get schema for a specific tool."""
            if tool_name not in self._handlers:
                raise HTTPException(404, f"Tool '{tool_name}' not found")
            
            handler_class = self._handlers[tool_name]
            schema = self._get_tool_schema(handler_class, tool_name)
            return schema
        
        # Execute tool (SSE endpoint)
        @router.post("/{tool_name}/sse")
        async def execute_tool_sse(tool_name: str, request: Request):
            """Execute tool and return SSE stream."""
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
        
        # Execute tool (JSON-RPC endpoint)
        @router.post("/{tool_name}/jsonrpc")
        async def execute_tool_jsonrpc(tool_name: str, request: Request):
            """Execute tool via JSON-RPC 2.0."""
            body = await request.json()
            
            # Validate JSON-RPC request
            if "method" in body and body["method"] != tool_name:
                raise HTTPException(400, "Method name mismatch")
            
            arguments = body.get("params", {})
            request_id = body.get("id")
            
            try:
                result = await self._execute_tool(tool_name, arguments)
                return {
                    "jsonrpc": "2.0",
                    "id": request_id,
                    "result": result
                }
            except Exception as e:
                return {
                    "jsonrpc": "2.0",
                    "id": request_id,
                    "error": {
                        "code": -32603,
                        "message": str(e)
                    }
                }
        
        # Simple POST endpoint (non-streaming)
        @router.post("/{tool_name}")
        async def execute_tool_simple(tool_name: str, request: Request):
            """Execute tool and return result directly."""
            body = await request.json()
            arguments = body.get("arguments", {})
            result = await self._execute_tool(tool_name, arguments)
            return {"result": result}
        
        self.app.include_router(router)
    
    async def _execute_tool(
        self,
        tool_name: str,
        arguments: dict[str, Any]
    ) -> list[dict[str, Any]]:
        """Execute a tool handler with dependency injection.
        
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
        
        try:
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
                    results.append({
                        "type": getattr(content, "type", "text"),
                        "text": getattr(content, "text", str(content))
                    })
            
            return results
        except HTTPException:
            raise
        except Exception as e:
            logger.exception(f"Error executing tool {tool_name}")
            raise HTTPException(500, f"Tool execution failed: {str(e)}")
    
    def _get_tool_schema(
        self,
        handler_class: Type[IMcpToolHandler],
        tool_name: str
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
            "inputSchema": {
                "type": "object",
                "properties": {},
                "required": []
            }
        }

