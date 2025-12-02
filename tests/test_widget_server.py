"""Tests for widget server integration."""

from datetime import datetime

import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient
from pyiv import Config, get_injector

from mcp_base.widget_server import WidgetServer
from mcp_base.widget_views import ListWidgetView, WidgetView
from mcp_base.widgets import WidgetCard, WidgetProvider


class TestWidgetProvider(WidgetProvider):
    """Test widget provider."""

    def __init__(self):
        self.widgets = [
            WidgetCard(
                id="widget-1",
                title="Test Widget 1",
                content="Content 1",
                timestamp=datetime(2024, 1, 1, 12, 0, 0),
                service_name="test_service",
            ),
            WidgetCard(
                id="widget-2",
                title="Test Widget 2",
                content="Content 2",
                timestamp=datetime(2024, 1, 1, 13, 0, 0),
                service_name="test_service",
            ),
        ]

    @property
    def widget_name(self) -> str:
        return "test_service"

    async def get_widgets(self, limit: int = 50, since: datetime | None = None):
        widgets = self.widgets
        if since:
            widgets = [w for w in widgets if w.timestamp > since]
        return sorted(widgets, key=lambda w: w.timestamp, reverse=True)[:limit]


class TestConfig(Config):
    """Test configuration."""

    def configure(self):
        self.bind(WidgetProvider, TestWidgetProvider, singleton=True)
        self.bind(WidgetView, ListWidgetView, singleton=True)


@pytest.fixture
def app():
    """Create FastAPI app with widget server."""
    app = FastAPI()
    injector = get_injector(TestConfig)
    WidgetServer(
        app=app,
        interface=WidgetProvider,
        injector=injector,
        base_path="/v1/widgets",
    )
    return app


@pytest.fixture
def client(app):
    """Create test client."""
    return TestClient(app)


class TestWidgetServer:
    """Tests for WidgetServer."""

    def test_widget_server_ui_endpoint(self, client):
        """Test widget UI endpoint."""
        response = client.get("/v1/widgets/ui")
        assert response.status_code == 200
        assert "text/html" in response.headers["content-type"]
        assert "MCP Service Activity Timeline" in response.text

    def test_widget_server_timeline_endpoint(self, client):
        """Test timeline endpoint."""
        response = client.get("/v1/widgets/timeline")
        assert response.status_code == 200
        data = response.json()
        assert "widgets" in data
        assert len(data["widgets"]) == 2
        assert data["widgets"][0]["id"] == "widget-2"  # Newest first

    def test_widget_server_timeline_with_limit(self, client):
        """Test timeline endpoint with limit."""
        response = client.get("/v1/widgets/timeline?limit=1")
        assert response.status_code == 200
        data = response.json()
        assert len(data["widgets"]) == 1

    def test_widget_server_timeline_with_since(self, client):
        """Test timeline endpoint with since parameter."""
        since = datetime(2024, 1, 1, 12, 30, 0).isoformat()
        response = client.get(f"/v1/widgets/timeline?since={since}")
        assert response.status_code == 200
        data = response.json()
        assert len(data["widgets"]) == 1
        assert data["widgets"][0]["id"] == "widget-2"

    def test_widget_server_create_widget(self, client):
        """Test creating a widget."""
        widget_data = {
            "widget": {
                "id": "new-widget",
                "title": "New Widget",
                "content": "New content",
                "timestamp": datetime.now().isoformat(),
                "service_name": "test",
                "tool_name": "test_tool",
                "actions": [
                    {
                        "label": "Action",
                        "method": "POST",
                        "url": "/api/test",
                        "payload": {},
                        "confirm": False,
                        "confirm_message": "Are you sure?",
                    }
                ],
                "metadata": {},
                "card_type": "success",
                "icon": "",
            }
        }
        response = client.post("/v1/widgets/create", json=widget_data)
        assert response.status_code == 200
        data = response.json()
        assert "widget" in data
        assert data["widget"]["id"] == "new-widget"

        # Verify widget is in timeline
        timeline_response = client.get("/v1/widgets/timeline")
        timeline_data = timeline_response.json()
        widget_ids = [w["id"] for w in timeline_data["widgets"]]
        assert "new-widget" in widget_ids

    def test_widget_server_render_endpoint(self, client):
        """Test server-side rendering endpoint."""
        widgets_data = {
            "widgets": [
                {
                    "id": "render-1",
                    "title": "Render Test 1",
                    "content": "Content 1",
                    "timestamp": datetime.now().isoformat(),
                    "service_name": "test",
                    "tool_name": "",
                    "actions": [],
                    "metadata": {},
                    "card_type": "default",
                    "icon": "",
                },
                {
                    "id": "render-2",
                    "title": "Render Test 2",
                    "content": "Content 2",
                    "timestamp": datetime.now().isoformat(),
                    "service_name": "test",
                    "tool_name": "",
                    "actions": [],
                    "metadata": {},
                    "card_type": "default",
                    "icon": "",
                },
            ],
            "context": "list",
        }
        response = client.post("/v1/widgets/render", json=widgets_data)
        assert response.status_code == 200
        data = response.json()
        assert "html" in data
        assert "render-1" in data["html"]
        assert "render-2" in data["html"]
        assert "Render Test 1" in data["html"]
        assert "Render Test 2" in data["html"]

    def test_widget_server_action_endpoint(self, client):
        """Test widget action endpoint."""
        # First create a widget with an action
        widget_data = {
            "widget": {
                "id": "action-widget",
                "title": "Action Widget",
                "content": "Content",
                "timestamp": datetime.now().isoformat(),
                "service_name": "test",
                "tool_name": "",
                "actions": [
                    {
                        "label": "Test Action",
                        "method": "POST",
                        "url": "/api/test",
                        "payload": {"key": "value"},
                        "confirm": False,
                        "confirm_message": "Are you sure?",
                    }
                ],
                "metadata": {},
                "card_type": "default",
                "icon": "",
            }
        }
        client.post("/v1/widgets/create", json=widget_data)

        # Now test the action endpoint
        response = client.post(
            "/v1/widgets/action/action-widget",
            json={"action_index": 0},
        )
        assert response.status_code == 200
        data = response.json()
        assert "action" in data
        assert data["action"]["method"] == "POST"
        assert data["action"]["url"] == "/api/test"
        assert data["action"]["payload"] == {"key": "value"}

    def test_widget_server_action_not_found(self, client):
        """Test widget action endpoint with non-existent widget."""
        response = client.post(
            "/v1/widgets/action/non-existent",
            json={"action_index": 0},
        )
        assert response.status_code == 404

    def test_widget_server_action_invalid_index(self, client):
        """Test widget action endpoint with invalid action index."""
        # Create widget with one action
        widget_data = {
            "widget": {
                "id": "test-widget",
                "title": "Test",
                "content": "Content",
                "timestamp": datetime.now().isoformat(),
                "service_name": "test",
                "tool_name": "",
                "actions": [
                    {
                        "label": "Action",
                        "method": "POST",
                        "url": "/api/test",
                        "payload": {},
                        "confirm": False,
                        "confirm_message": "Are you sure?",
                    }
                ],
                "metadata": {},
                "card_type": "default",
                "icon": "",
            }
        }
        client.post("/v1/widgets/create", json=widget_data)

        # Try invalid index
        response = client.post(
            "/v1/widgets/action/test-widget",
            json={"action_index": 999},
        )
        assert response.status_code == 400
