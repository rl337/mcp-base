"""MCP Base Framework - Automatic handler discovery and routing for MCP services."""

from mcp_base.handler import IMcpToolHandler
from mcp_base.server import McpServerBase

__version__ = "0.1.0"
__all__ = [
    "IMcpToolHandler",
    "McpServerBase",
]

