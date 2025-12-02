"""Tests for widget view system."""


import pytest

from mcp_base.widget_views import (
    DefaultWidgetView,
    DesktopWidgetView,
    DetailWidgetView,
    ListWidgetView,
    MobileWidgetView,
    ViewContext,
    ViewRequest,
    WidgetView,
)
from mcp_base.widgets import WidgetAction, WidgetCard


class TestViewContext:
    """Tests for ViewContext enum."""

    def test_view_context_values(self):
        """Test ViewContext enum values."""
        assert ViewContext.LIST.value == "list"
        assert ViewContext.DETAIL.value == "detail"
        assert ViewContext.MOBILE.value == "mobile"
        assert ViewContext.DESKTOP.value == "desktop"
        assert ViewContext.DEFAULT.value == "default"


class TestViewRequest:
    """Tests for ViewRequest."""

    def test_view_request_creation(self):
        """Test creating a view request."""
        widget = WidgetCard(id="test", title="Test")
        request = ViewRequest(
            context=ViewContext.LIST,
            widget=widget,
            base_path="/v1/widgets",
            metadata={"key": "value"},
        )
        assert request.context == ViewContext.LIST
        assert request.widget == widget
        assert request.base_path == "/v1/widgets"
        assert request.metadata == {"key": "value"}

    def test_view_request_default_metadata(self):
        """Test that ViewRequest initializes default metadata."""
        widget = WidgetCard(id="test", title="Test")
        request = ViewRequest(context=ViewContext.LIST, widget=widget)
        assert request.metadata == {}


class TestWidgetView:
    """Tests for WidgetView interface."""

    def test_widget_view_is_abstract(self):
        """Test that WidgetView is abstract."""
        with pytest.raises(TypeError):
            WidgetView()  # type: ignore


class TestDefaultWidgetView:
    """Tests for DefaultWidgetView."""

    def test_default_view_context(self):
        """Test default view context."""
        view = DefaultWidgetView()
        assert view.view_context == ViewContext.DEFAULT

        view = DefaultWidgetView(ViewContext.LIST)
        assert view.view_context == ViewContext.LIST

    def test_default_view_render(self):
        """Test default view rendering."""
        widget = WidgetCard(
            id="test-id",
            title="Test Widget",
            content="Test content",
            service_name="test_service",
            tool_name="test_tool",
            card_type="success",
        )
        request = ViewRequest(context=ViewContext.DEFAULT, widget=widget)
        view = DefaultWidgetView()
        html = view.render(request)

        assert "test-id" in html
        assert "Test Widget" in html
        assert "Test content" in html
        assert "test_service" in html
        assert "test_tool" in html
        assert "widget-card" in html
        assert "success" in html

    def test_default_view_render_with_actions(self):
        """Test default view rendering with actions."""
        action = WidgetAction(label="Click Me", method="POST", url="/api/test")
        widget = WidgetCard(
            id="test-id",
            title="Test",
            actions=[action],
        )
        request = ViewRequest(context=ViewContext.DEFAULT, widget=widget)
        view = DefaultWidgetView()
        html = view.render(request)

        assert "Click Me" in html
        assert "action-btn" in html
        assert "handleWidgetAction" in html

    def test_default_view_render_multiple(self):
        """Test rendering multiple widgets."""
        widgets = [WidgetCard(id=f"widget-{i}", title=f"Widget {i}") for i in range(3)]
        requests = [ViewRequest(context=ViewContext.DEFAULT, widget=widget) for widget in widgets]
        view = DefaultWidgetView()
        html = view.render_multiple(requests)

        assert "widget-0" in html
        assert "widget-1" in html
        assert "widget-2" in html

    def test_default_view_escape_html(self):
        """Test HTML escaping in default view."""
        widget = WidgetCard(
            id="test",
            title='Test & "Special" <Characters>',
            content="<script>alert('xss')</script>",
        )
        request = ViewRequest(context=ViewContext.DEFAULT, widget=widget)
        view = DefaultWidgetView()
        html = view.render(request)

        assert "&amp;" in html
        assert "&quot;" in html
        assert "&lt;" in html
        assert "&gt;" in html
        assert "<script>" not in html


class TestListWidgetView:
    """Tests for ListWidgetView."""

    def test_list_view_context(self):
        """Test list view context."""
        view = ListWidgetView()
        assert view.view_context == ViewContext.LIST

    def test_list_view_render_multiple(self):
        """Test list view rendering multiple widgets."""
        widgets = [WidgetCard(id=f"widget-{i}", title=f"Widget {i}") for i in range(3)]
        requests = [ViewRequest(context=ViewContext.LIST, widget=widget) for widget in widgets]
        view = ListWidgetView()
        html = view.render_multiple(requests)

        assert "widget-list" in html
        assert "widget-0" in html
        assert "widget-1" in html
        assert "widget-2" in html


class TestDetailWidgetView:
    """Tests for DetailWidgetView."""

    def test_detail_view_context(self):
        """Test detail view context."""
        view = DetailWidgetView()
        assert view.view_context == ViewContext.DETAIL

    def test_detail_view_render_with_metadata(self):
        """Test detail view rendering with metadata."""
        widget = WidgetCard(
            id="test",
            title="Test",
            metadata={"key1": "value1", "key2": "value2"},
        )
        request = ViewRequest(context=ViewContext.DETAIL, widget=widget)
        view = DetailWidgetView()
        html = view.render(request)

        assert "widget-detail" in html
        assert "widget-metadata" in html
        assert "key1" in html
        assert "value1" in html
        assert "key2" in html
        assert "value2" in html


class TestMobileWidgetView:
    """Tests for MobileWidgetView."""

    def test_mobile_view_context(self):
        """Test mobile view context."""
        view = MobileWidgetView()
        assert view.view_context == ViewContext.MOBILE

    def test_mobile_view_render(self):
        """Test mobile view rendering."""
        widget = WidgetCard(
            id="test",
            title="Test",
            content="Content",
        )
        request = ViewRequest(context=ViewContext.MOBILE, widget=widget)
        view = MobileWidgetView()
        html = view.render(request)

        assert "mobile" in html
        assert "widget-card mobile" in html

    def test_mobile_view_render_with_multiple_actions(self):
        """Test mobile view with multiple actions shows menu."""
        actions = [
            WidgetAction(label="Primary", method="POST", url="/primary"),
            WidgetAction(label="Secondary", method="POST", url="/secondary"),
        ]
        widget = WidgetCard(id="test", title="Test", actions=actions)
        request = ViewRequest(context=ViewContext.MOBILE, widget=widget)
        view = MobileWidgetView()
        html = view.render(request)

        assert "Primary" in html
        assert "showActionMenu" in html


class TestDesktopWidgetView:
    """Tests for DesktopWidgetView."""

    def test_desktop_view_context(self):
        """Test desktop view context."""
        view = DesktopWidgetView()
        assert view.view_context == ViewContext.DESKTOP

    def test_desktop_view_render(self):
        """Test desktop view rendering."""
        widget = WidgetCard(id="test", title="Test")
        request = ViewRequest(context=ViewContext.DESKTOP, widget=widget)
        view = DesktopWidgetView()
        html = view.render(request)

        assert "widget-card" in html
        assert "test" in html
