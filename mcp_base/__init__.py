"""MCP Base Framework - Automatic handler discovery and routing for MCP services."""

from mcp_base.handler import IMcpToolHandler
from mcp_base.server import McpServerBase
from mcp_base.serializers import serialize_model, serialize_datetime, serialize_uuid
from mcp_base.exceptions import (
    ExceptionMapper,
    McpErrorCode,
    create_default_mapper
)
from mcp_base.request_models import validate_request, get_schema_from_model

__version__ = "0.1.0"
__all__ = [
    "IMcpToolHandler",
    "McpServerBase",
    "serialize_model",
    "serialize_datetime",
    "serialize_uuid",
    "ExceptionMapper",
    "McpErrorCode",
    "create_default_mapper",
    "validate_request",
    "get_schema_from_model",
]

