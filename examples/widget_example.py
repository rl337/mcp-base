"""Example of using the widget system in an MCP service.

This example shows how to:
1. Create a WidgetProvider to provide widgets
2. Integrate widgets with McpServerBase
3. Create widgets from tool handlers
"""

import uuid
from datetime import datetime

from fastapi import FastAPI
from pyiv import Config, SingletonType, get_injector

from mcp_base import (
    McpServerBase,
    McpToolHandler,
    TextContent,
    WidgetAction,
    WidgetCard,
    WidgetProvider,
    WidgetServer,
)


# Example: Widget Provider
class MyServiceWidgetProvider(WidgetProvider):
    """Example widget provider that creates widgets for tool executions."""

    def __init__(self):
        self._widgets: list[WidgetCard] = []

    @property
    def widget_name(self) -> str:
        return "my_service"

    async def get_widgets(
        self, limit: int = 50, since: datetime | None = None
    ) -> list[WidgetCard]:
        """Get widgets, optionally filtered by timestamp."""
        widgets = self._widgets
        if since:
            widgets = [w for w in widgets if w.timestamp > since]
        return sorted(widgets, key=lambda w: w.timestamp, reverse=True)[:limit]

    async def add_tool_execution_widget(
        self, tool_name: str, result: str, success: bool = True
    ):
        """Add a widget for a tool execution."""
        widget = WidgetCard(
            id=str(uuid.uuid4()),
            title=f"Tool Execution: {tool_name}",
            content=f"Result: {result}",
            timestamp=datetime.now(),
            service_name=self.widget_name,
            tool_name=tool_name,
            card_type="success" if success else "error",
            actions=[
                WidgetAction(
                    label="Rerun",
                    method="POST",
                    url=f"/v1/mcp/tools/{tool_name}",
                    payload={"arguments": {}},
                ),
                WidgetAction(
                    label="View Details",
                    method="GET",
                    url=f"/v1/mcp/tools/{tool_name}/schema",
                ),
            ],
        )
        self._widgets.append(widget)
        # Keep only last 100 widgets
        if len(self._widgets) > 100:
            self._widgets = self._widgets[-100:]


# Example: Tool Handler that creates widgets
class EchoHandler(McpToolHandler):
    """Example handler that creates widgets when executed."""

    def __init__(self, widget_provider: MyServiceWidgetProvider):
        self.widget_provider = widget_provider

    @property
    def tool_name(self) -> str:
        return "echo"

    @property
    def tool_schema(self) -> dict:
        return {
            "name": "echo",
            "description": "Echo back the input",
            "inputSchema": {
                "type": "object",
                "properties": {
                    "message": {"type": "string", "description": "Message to echo"}
                },
                "required": ["message"],
            },
        }

    async def handle(self, arguments: dict, **kwargs) -> list[TextContent]:
        message = arguments.get("message", "")
        result = f"Echo: {message}"

        # Create a widget for this execution
        await self.widget_provider.add_tool_execution_widget(
            tool_name=self.tool_name, result=result, success=True
        )

        return [TextContent(type="text", text=result)]


# Example: Dependency Injection Config
class ExampleConfig(Config):
    """Example configuration with widget provider and handler."""

    def configure(self):
        # Register widget provider as singleton
        self.register(WidgetProvider, MyServiceWidgetProvider, singleton_type=SingletonType.SINGLETON)

        # Register handler - it will get the widget provider injected
        self.register(McpToolHandler, EchoHandler, singleton_type=SingletonType.SINGLETON)


# Example: Setting up the server
def create_app() -> FastAPI:
    """Create a FastAPI app with MCP server and widget server."""
    app = FastAPI(title="MCP Service with Widgets")

    # Get injector
    injector = get_injector(ExampleConfig)

    # Set up MCP server
    mcp_server = McpServerBase(
        app=app,
        tool_package="examples",
        interface=McpToolHandler,
        injector=injector,
        base_path="/v1/mcp/tools",
    )

    # Set up widget server
    widget_server = WidgetServer(
        app=app,
        interface=WidgetProvider,
        injector=injector,
        base_path="/v1/widgets",
    )

    return app


if __name__ == "__main__":
    import uvicorn

    app = create_app()
    uvicorn.run(app, host="0.0.0.0", port=8000)

