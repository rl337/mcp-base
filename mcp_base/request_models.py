"""Base utilities for request model validation."""

from typing import Type, Any
from pydantic import BaseModel, ValidationError


def validate_request(
    model_class: Type[BaseModel],
    arguments: dict[str, Any]
) -> BaseModel:
    """Validate request arguments against a Pydantic model.
    
    This utility function validates request arguments and converts
    them to a typed Pydantic model instance. If validation fails,
    raises a ValidationError that can be caught and converted to
    an MCP error.
    
    Args:
        model_class: Pydantic model class
        arguments: Raw arguments dictionary
        
    Returns:
        Validated model instance
        
    Raises:
        ValidationError: If validation fails
        
    Example:
        from mcp_base.request_models import validate_request
        from my_service.models import CreateFactRequest
        
        try:
            request = validate_request(CreateFactRequest, arguments)
        except ValidationError as e:
            raise McpError(ErrorData(
                code=McpErrorCode.INVALID_PARAMS,
                message=f"Validation error: {e}"
            ))
    """
    return model_class(**arguments)


def get_schema_from_model(model_class: Type[BaseModel]) -> dict[str, Any]:
    """Generate JSON schema from a Pydantic model.
    
    This is a convenience function that generates a JSON schema
    from a Pydantic model, which can be used in tool schemas.
    
    Args:
        model_class: Pydantic model class
        
    Returns:
        JSON schema dictionary
        
    Example:
        from mcp_base.request_models import get_schema_from_model
        from my_service.models import CreateFactRequest
        
        schema = {
            "name": "create_fact",
            "description": "Create a new fact",
            "inputSchema": get_schema_from_model(CreateFactRequest)
        }
    """
    return model_class.model_json_schema()


