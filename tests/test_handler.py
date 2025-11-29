"""Tests for MCP handler interface."""

import pytest
from typing import Any

from mcp_base.handler import IMcpToolHandler, TextContent


class TestHandler(IMcpToolHandler):
    """Test handler implementation."""
    
    @property
    def tool_name(self) -> str:
        return "test_tool"
    
    @property
    def tool_schema(self) -> dict[str, Any]:
        return {
            "name": "test_tool",
            "description": "A test tool",
            "inputSchema": {
                "type": "object",
                "properties": {
                    "message": {"type": "string"}
                }
            }
        }
    
    async def handle(self, arguments: dict[str, Any]) -> list[TextContent]:
        message = arguments.get("message", "default")
        return [TextContent(type="text", text=f"Echo: {message}")]


def test_handler_interface():
    """Test that handler implements interface correctly."""
    handler = TestHandler()
    
    assert handler.tool_name == "test_tool"
    assert "name" in handler.tool_schema
    assert handler.tool_schema["name"] == "test_tool"


@pytest.mark.asyncio
async def test_handler_execution():
    """Test handler execution."""
    handler = TestHandler()
    
    result = await handler.handle({"message": "hello"})
    
    assert len(result) == 1
    assert result[0]["type"] == "text"
    assert "hello" in result[0]["text"]

