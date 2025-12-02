"""Tests for MCP server base."""

from typing import Any

import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient
from pyiv import Config, SingletonType, get_injector

from mcp_base import McpServerBase, McpToolHandler, TextContent


class EchoHandlerImpl(McpToolHandler):
    """Echo handler for testing."""

    @property
    def tool_name(self) -> str:
        return "echo"

    @property
    def tool_schema(self) -> dict[str, Any]:
        return {
            "name": "echo",
            "description": "Echo a message",
            "inputSchema": {
                "type": "object",
                "properties": {"message": {"type": "string"}},
                "required": ["message"],
            },
        }

    async def handle(self, arguments: dict[str, Any]) -> list[TextContent]:
        message = arguments.get("message", "")
        return [TextContent(type="text", text=f"Echo: {message}")]


class TestConfig(Config):
    """Test configuration."""

    def configure(self):
        self.register(McpToolHandler, EchoHandlerImpl, singleton_type=SingletonType.SINGLETON)


@pytest.fixture
def app():
    """Create FastAPI app with MCP server."""
    app = FastAPI()
    injector = get_injector(TestConfig)

    McpServerBase(
        app=app,
        tool_package="tests.test_server",
        interface=McpToolHandler,
        injector=injector,
        base_path="/v1/mcp/tools",
    )

    return app


@pytest.fixture
def client(app):
    """Create test client."""
    return TestClient(app)


def test_list_tools(client):
    """Test listing all tools."""
    response = client.get("/v1/mcp/tools")

    assert response.status_code == 200
    data = response.json()
    assert "tools" in data
    assert len(data["tools"]) == 1
    assert data["tools"][0]["name"] == "echo"


def test_get_tool_schema(client):
    """Test getting tool schema."""
    response = client.get("/v1/mcp/tools/echo/schema")

    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "echo"
    assert "inputSchema" in data


def test_execute_tool_simple(client):
    """Test executing tool via simple POST."""
    response = client.post("/v1/mcp/tools/echo", json={"arguments": {"message": "hello"}})

    assert response.status_code == 200
    data = response.json()
    assert "result" in data
    assert len(data["result"]) == 1
    assert "hello" in data["result"][0]["text"]


def test_execute_tool_jsonrpc(client):
    """Test executing tool via JSON-RPC."""
    response = client.post(
        "/v1/mcp/tools/echo/jsonrpc",
        json={"jsonrpc": "2.0", "method": "echo", "params": {"message": "hello"}, "id": 1},
    )

    assert response.status_code == 200
    data = response.json()
    assert data["jsonrpc"] == "2.0"
    assert data["id"] == 1
    assert "result" in data


def test_tool_not_found(client):
    """Test error handling for non-existent tool."""
    response = client.get("/v1/mcp/tools/nonexistent/schema")

    assert response.status_code == 404


def test_execute_tool_with_registry():
    """Test server with manual handler registry."""
    app = FastAPI()
    injector = get_injector(TestConfig)

    # Manual registry
    handler_registry = {"echo": EchoHandlerImpl}

    McpServerBase(
        app=app,
        tool_package="tests",
        interface=McpToolHandler,
        injector=injector,
        base_path="/v1/mcp/tools",
        handler_registry=handler_registry,
    )

    client = TestClient(app)
    response = client.get("/v1/mcp/tools")

    assert response.status_code == 200
    data = response.json()
    assert len(data["tools"]) == 1
