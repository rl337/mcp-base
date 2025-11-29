"""Exception mapping utilities for MCP error handling."""

from typing import Type, Optional, Callable
from mcp import McpError
from mcp.types import ErrorData


# Standard MCP error codes
class McpErrorCode:
    """Standard MCP error codes."""
    PARSE_ERROR = -32700
    INVALID_REQUEST = -32600
    METHOD_NOT_FOUND = -32601
    INVALID_PARAMS = -32602
    INTERNAL_ERROR = -32603
    
    # Custom error codes (reserved range: -32000 to -32099)
    NOT_FOUND = -32001
    DUPLICATE = -32002
    VALIDATION_ERROR = -32003
    DATABASE_ERROR = -32004


class ExceptionMapper:
    """Maps service exceptions to MCP errors.
    
    This class provides utilities for converting service-specific exceptions
    to standardized MCP errors with appropriate error codes.
    
    Example:
        mapper = ExceptionMapper()
        mapper.register(NotFoundError, McpErrorCode.NOT_FOUND)
        mapper.register(ValidationError, McpErrorCode.INVALID_PARAMS)
        
        try:
            # Service call
        except Exception as e:
            raise mapper.to_mcp_error(e)
    """
    
    def __init__(self):
        """Initialize exception mapper."""
        self._mappings: dict[Type[Exception], int] = {}
        self._custom_handlers: dict[Type[Exception], Callable[[Exception], McpError]] = {}
    
    def register(
        self,
        exception_type: Type[Exception],
        error_code: int,
        message_formatter: Optional[Callable[[Exception], str]] = None
    ):
        """Register an exception type to error code mapping.
        
        Args:
            exception_type: Exception class to map
            error_code: MCP error code
            message_formatter: Optional function to format error message
        """
        if message_formatter:
            def handler(exc: Exception) -> McpError:
                return McpError(ErrorData(
                    code=error_code,
                    message=message_formatter(exc)
                ))
            self._custom_handlers[exception_type] = handler
        else:
            self._mappings[exception_type] = error_code
    
    def to_mcp_error(self, exception: Exception) -> McpError:
        """Convert an exception to an MCP error.
        
        Args:
            exception: Exception to convert
            
        Returns:
            McpError with appropriate code and message
        """
        # Check custom handlers first
        exc_type = type(exception)
        if exc_type in self._custom_handlers:
            return self._custom_handlers[exc_type](exception)
        
        # Check mappings
        if exc_type in self._mappings:
            return McpError(ErrorData(
                code=self._mappings[exc_type],
                message=str(exception)
            ))
        
        # Default: internal error
        return McpError(ErrorData(
            code=McpErrorCode.INTERNAL_ERROR,
            message=f"Internal error: {str(exception)}"
        ))


def create_default_mapper() -> ExceptionMapper:
    """Create a default exception mapper with common mappings.
    
    Returns:
        ExceptionMapper with common exception mappings
    """
    mapper = ExceptionMapper()
    
    # Common exception patterns (these will be overridden by services)
    # Services should register their specific exception types
    
    return mapper

