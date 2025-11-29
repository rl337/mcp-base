"""Tests for MCP handler interface."""

import pytest
from typing import Any

from mcp_base.handler import McpToolHandler, TextContent


class TestHandlerImpl(McpToolHandler):
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
    handler = TestHandlerImpl()
    
    assert handler.tool_name == "test_tool"
    assert "name" in handler.tool_schema
    assert handler.tool_schema["name"] == "test_tool"


def test_handler_validation():
    """Test handler validation method."""
    handler = TestHandlerImpl()
    
    # Should not raise
    handler.validate()
    
    # Verify validation checks work
    assert handler.tool_name == "test_tool"
    assert handler.tool_schema["name"] == "test_tool"
    assert handler.tool_schema["name"] == handler.tool_name


def test_handler_validation_fails_on_invalid_name():
    """Test that validation fails when tool_name is invalid."""
    from mcp_base.handler import McpToolHandler
    
    class InvalidNameHandlerImpl(McpToolHandler):
        @property
        def tool_name(self) -> str:
            return ""  # Empty string
        
        @property
        def tool_schema(self) -> dict[str, Any]:
            return {
                "name": "test",
                "description": "Test",
                "inputSchema": {"type": "object"}
            }
        
        async def handle(self, arguments: dict[str, Any], **kwargs) -> list[TextContent]:
            return []
    
    handler = InvalidNameHandlerImpl()
    
    with pytest.raises(ValueError, match="empty string"):
        handler.validate()


def test_handler_validation_fails_on_missing_schema_field():
    """Test that validation fails when tool_schema is missing required fields."""
    from mcp_base.handler import McpToolHandler
    
    class InvalidSchemaHandlerImpl(McpToolHandler):
        @property
        def tool_name(self) -> str:
            return "test"
        
        @property
        def tool_schema(self) -> dict[str, Any]:
            return {
                "name": "test",
                # Missing description and inputSchema
            }
        
        async def handle(self, arguments: dict[str, Any], **kwargs) -> list[TextContent]:
            return []
    
    handler = InvalidSchemaHandlerImpl()
    
    with pytest.raises(ValueError, match="missing required field 'description'"):
        handler.validate()


def test_handler_validation_fails_on_name_mismatch():
    """Test that validation fails when tool_name doesn't match schema name."""
    from mcp_base.handler import McpToolHandler
    
    class MismatchHandlerImpl(McpToolHandler):
        @property
        def tool_name(self) -> str:
            return "tool1"
        
        @property
        def tool_schema(self) -> dict[str, Any]:
            return {
                "name": "tool2",  # Different from tool_name
                "description": "Test",
                "inputSchema": {"type": "object"}
            }
        
        async def handle(self, arguments: dict[str, Any], **kwargs) -> list[TextContent]:
            return []
    
    handler = MismatchHandlerImpl()
    
    with pytest.raises(ValueError, match="does not match"):
        handler.validate()


@pytest.mark.asyncio
async def test_handler_execution():
    """Test handler execution."""
    handler = TestHandlerImpl()
    
    result = await handler.handle({"message": "hello"})
    
    assert len(result) == 1
    assert result[0]["type"] == "text"
    assert "hello" in result[0]["text"]

