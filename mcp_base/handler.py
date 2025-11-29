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


class McpToolHandler(ABC):
    """Interface for MCP tool handlers.
    
    Handlers must implement this interface to be discovered and used by
    the MCP base framework. Handlers are automatically registered as
    per-injector singletons for performance.
    
    Example:
        class CreateFactHandlerImpl(McpToolHandler):
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
            
            async def handle(self, arguments: dict[str, Any], **kwargs) -> list[TextContent]:
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
    
    def validate(self) -> None:
        """Validate that all abstract methods return valid results.
        
        This method checks that:
        - tool_name returns a non-empty string
        - tool_schema returns a valid dict with required fields (name, description, inputSchema)
        - tool_name matches tool_schema['name']
        
        Raises:
            ValueError: If any validation check fails
            
        Example:
            handler = CreateFactHandlerImpl()
            handler.validate()  # Raises ValueError if invalid
        """
        # Validate tool_name
        try:
            name = self.tool_name
            if name is None:
                raise ValueError(f"{self.__class__.__name__}.tool_name returned None")
            if not isinstance(name, str):
                raise ValueError(
                    f"{self.__class__.__name__}.tool_name returned {type(name).__name__}, "
                    f"expected str"
                )
            if not name.strip():
                raise ValueError(f"{self.__class__.__name__}.tool_name returned empty string")
        except Exception as e:
            if isinstance(e, ValueError):
                raise
            raise ValueError(
                f"{self.__class__.__name__}.tool_name raised {type(e).__name__}: {e}"
            ) from e
        
        # Validate tool_schema
        try:
            schema = self.tool_schema
            if schema is None:
                raise ValueError(f"{self.__class__.__name__}.tool_schema returned None")
            if not isinstance(schema, dict):
                raise ValueError(
                    f"{self.__class__.__name__}.tool_schema returned {type(schema).__name__}, "
                    f"expected dict"
                )
            
            # Check required fields
            if "name" not in schema:
                raise ValueError(
                    f"{self.__class__.__name__}.tool_schema missing required field 'name'"
                )
            if not isinstance(schema["name"], str) or not schema["name"].strip():
                raise ValueError(
                    f"{self.__class__.__name__}.tool_schema['name'] must be a non-empty string"
                )
            
            if "description" not in schema:
                raise ValueError(
                    f"{self.__class__.__name__}.tool_schema missing required field 'description'"
                )
            if not isinstance(schema["description"], str):
                raise ValueError(
                    f"{self.__class__.__name__}.tool_schema['description'] must be a string"
                )
            
            if "inputSchema" not in schema:
                raise ValueError(
                    f"{self.__class__.__name__}.tool_schema missing required field 'inputSchema'"
                )
            if not isinstance(schema["inputSchema"], dict):
                raise ValueError(
                    f"{self.__class__.__name__}.tool_schema['inputSchema'] must be a dict"
                )
            
            # Validate that tool_name matches schema name
            if schema["name"] != name:
                raise ValueError(
                    f"{self.__class__.__name__}: tool_name '{name}' does not match "
                    f"tool_schema['name'] '{schema['name']}'"
                )
        except Exception as e:
            if isinstance(e, ValueError):
                raise
            raise ValueError(
                f"{self.__class__.__name__}.tool_schema raised {type(e).__name__}: {e}"
            ) from e
