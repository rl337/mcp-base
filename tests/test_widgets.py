"""Tests for widget system."""

from datetime import datetime

import pytest

from mcp_base.widgets import WidgetAction, WidgetCard, WidgetProvider


class TestWidgetAction:
    """Tests for WidgetAction."""

    def test_widget_action_creation(self):
        """Test creating a widget action."""
        action = WidgetAction(
            label="Click Me",
            method="POST",
            url="/api/action",
            payload={"key": "value"},
            confirm=True,
            confirm_message="Are you sure?",
        )
        assert action.label == "Click Me"
        assert action.method == "POST"
        assert action.url == "/api/action"
        assert action.payload == {"key": "value"}
        assert action.confirm is True
        assert action.confirm_message == "Are you sure?"

    def test_widget_action_defaults(self):
        """Test widget action with default values."""
        action = WidgetAction(label="Test")
        assert action.label == "Test"
        assert action.method == "POST"
        assert action.url == ""
        assert action.payload == {}
        assert action.confirm is False
        assert action.confirm_message == "Are you sure?"


class TestWidgetCard:
    """Tests for WidgetCard."""

    def test_widget_card_creation(self):
        """Test creating a widget card."""
        widget = WidgetCard(
            id="test-id",
            title="Test Widget",
            content="Test content",
            service_name="test_service",
            tool_name="test_tool",
        )
        assert widget.id == "test-id"
        assert widget.title == "Test Widget"
        assert widget.content == "Test content"
        assert widget.service_name == "test_service"
        assert widget.tool_name == "test_tool"
        assert isinstance(widget.timestamp, datetime)
        assert widget.actions == []
        assert widget.metadata == {}
        assert widget.card_type == "default"
        assert widget.icon == ""

    def test_widget_card_to_dict(self):
        """Test converting widget card to dictionary."""
        action = WidgetAction(label="Action", method="GET", url="/test")
        widget = WidgetCard(
            id="test-id",
            title="Test",
            content="Content",
            actions=[action],
            metadata={"key": "value"},
            card_type="success",
            icon="icon.png",
        )
        widget_dict = widget.to_dict()
        assert widget_dict["id"] == "test-id"
        assert widget_dict["title"] == "Test"
        assert widget_dict["content"] == "Content"
        assert widget_dict["card_type"] == "success"
        assert widget_dict["icon"] == "icon.png"
        assert len(widget_dict["actions"]) == 1
        assert widget_dict["actions"][0]["label"] == "Action"
        assert widget_dict["metadata"] == {"key": "value"}
        assert "timestamp" in widget_dict

    def test_widget_card_default_timestamp(self):
        """Test that widget card gets default timestamp."""
        before = datetime.now()
        widget = WidgetCard(id="test", title="Test")
        after = datetime.now()
        assert before <= widget.timestamp <= after


class TestWidgetProvider:
    """Tests for WidgetProvider interface."""

    @pytest.mark.asyncio
    async def test_widget_provider_interface(self):
        """Test that WidgetProvider is an abstract class."""
        with pytest.raises(TypeError):
            WidgetProvider()  # type: ignore

    @pytest.mark.asyncio
    async def test_widget_provider_create_widget(self):
        """Test the create_widget convenience method."""

        class TestProvider(WidgetProvider):
            @property
            def widget_name(self) -> str:
                return "test"

            async def get_widgets(self, limit: int = 50, since: datetime | None = None):
                return []

        provider = TestProvider()
        widget = await provider.create_widget(
            title="Test Widget",
            content="Content",
            tool_name="test_tool",
            card_type="success",
        )
        assert widget.title == "Test Widget"
        assert widget.content == "Content"
        assert widget.service_name == "test"
        assert widget.tool_name == "test_tool"
        assert widget.card_type == "success"
        assert widget.id  # Should have a UUID

    @pytest.mark.asyncio
    async def test_widget_provider_get_widgets(self):
        """Test getting widgets from a provider."""

        class TestProvider(WidgetProvider):
            def __init__(self):
                self.widgets = [
                    WidgetCard(
                        id="1",
                        title="Widget 1",
                        timestamp=datetime(2024, 1, 1, 12, 0, 0),
                    ),
                    WidgetCard(
                        id="2",
                        title="Widget 2",
                        timestamp=datetime(2024, 1, 1, 13, 0, 0),
                    ),
                ]

            @property
            def widget_name(self) -> str:
                return "test"

            async def get_widgets(self, limit: int = 50, since: datetime | None = None):
                widgets = self.widgets
                if since:
                    widgets = [w for w in widgets if w.timestamp > since]
                return sorted(widgets, key=lambda w: w.timestamp, reverse=True)[:limit]

        provider = TestProvider()
        widgets = await provider.get_widgets()
        assert len(widgets) == 2
        assert widgets[0].id == "2"  # Newest first

        # Test filtering by since
        since = datetime(2024, 1, 1, 12, 30, 0)
        widgets = await provider.get_widgets(since=since)
        assert len(widgets) == 1
        assert widgets[0].id == "2"

        # Test limit
        widgets = await provider.get_widgets(limit=1)
        assert len(widgets) == 1
