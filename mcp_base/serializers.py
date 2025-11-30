"""Base serialization utilities for MCP responses."""

from typing import Any
from datetime import datetime


def serialize_model(obj: Any) -> dict[str, Any]:
    """Serialize a model object to dictionary.
    
    Handles common patterns:
    - SQLAlchemy models (converts to dict)
    - Datetime objects (converts to ISO format)
    - Nested objects (recursive serialization)
    - Metadata fields (handles 'meta' -> 'metadata' mapping)
    
    Args:
        obj: Model instance or object to serialize
        
    Returns:
        Dictionary representation of the object
    """
    if hasattr(obj, "__dict__"):
        result = {}
        for key, value in obj.__dict__.items():
            if key.startswith("_"):
                continue
            
            # Map 'meta' attribute back to 'metadata' for API compatibility
            # (SQLAlchemy reserves 'metadata' as a name, so some models use 'meta' internally)
            output_key = "metadata" if key == "meta" else key
            
            if hasattr(value, "isoformat"):  # datetime
                result[output_key] = value.isoformat()
            elif isinstance(value, dict):
                result[output_key] = value
            elif isinstance(value, list):
                result[output_key] = [
                    serialize_model(item) if hasattr(item, "__dict__") else item
                    for item in value
                ]
            elif hasattr(value, "__dict__"):  # Nested object
                result[output_key] = serialize_model(value)
            else:
                result[output_key] = value
        return result
    return obj


def serialize_datetime(dt: datetime) -> str:
    """Serialize datetime to ISO format string.
    
    Args:
        dt: Datetime object
        
    Returns:
        ISO format string
    """
    return dt.isoformat()


def serialize_uuid(uuid_obj: Any) -> str:
    """Serialize UUID to string.
    
    Args:
        uuid_obj: UUID object
        
    Returns:
        String representation
    """
    return str(uuid_obj)


