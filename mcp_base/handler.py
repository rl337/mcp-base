"""MCP tool handler interface."""

from abc import ABC, abstractmethod
from typing import Any, Optional

try:
    from mcp.types import TextContent
except ImportError:
    # Fallback if mcp library not available
    from typing import TypedDict
    
    class TextContent(TypedDict):
        """Text content for MCP responses."""
        type: str
        text: str

# Type hint for tracing - agents should use trace_span from mcp_base.tracing
try:
    from mcp_base.tracing import trace_span
    _TRACING_AVAILABLE = True
except ImportError:
    _TRACING_AVAILABLE = False
    trace_span = None


class IMcpToolHandler(ABC):
    """Interface for MCP tool handlers.
    
    Handlers must implement this interface to be discovered and used by
    the MCP base framework. Handlers are automatically registered as
    per-injector singletons for performance.
    
    Example:
        class CreateFactHandler(IMcpToolHandler):
            @property
            def tool_name(self) -> str:
                return "create_fact"
            
            @property
            def tool_schema(self) -> dict[str, Any]:
                return {
                    "name": "create_fact",
                    "description": "Create a new fact",
                    "inputSchema": {"type": "object"}
                }
            
            async def handle(
                self,
                arguments: dict[str, Any]
            ) -> list[TextContent]:
                # Implementation
                return [TextContent(type="text", text="Success")]
    """
    
    @property
    @abstractmethod
    def tool_name(self) -> str:
        """Return the tool name (for routing).
        
        Returns:
            The tool name that will be used in the URL path
        """
        pass
    
    @property
    @abstractmethod
    def tool_schema(self) -> dict[str, Any]:
        """Return the JSON schema for this tool.
        
        Returns:
            Dictionary containing:
            - name: Tool name
            - description: Tool description
            - inputSchema: JSON schema for tool arguments
        """
        pass
    
    @abstractmethod
    async def handle(
        self,
        arguments: dict[str, Any],
        **kwargs
    ) -> list[TextContent]:
        """Handle tool execution.
        
        Handlers should use trace_span from mcp_base.tracing for distributed tracing:
        
        Example:
            from mcp_base.tracing import trace_span
            
            async def handle(self, arguments: dict[str, Any], **kwargs) -> list[TextContent]:
                with trace_span(f"mcp.tool.{self.tool_name}", {"tool_name": self.tool_name}):
                    # Handler implementation
                    ...
        
        Args:
            arguments: Tool arguments from MCP request
            **kwargs: Additional context (e.g., db_session, service_factory)
                     These are injected by the framework based on handler dependencies
            
        Returns:
            List of TextContent responses
            
        Raises:
            Exception: Any exception will be converted to an MCP error
        """
        pass

