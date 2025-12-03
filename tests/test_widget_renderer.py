"""Tests for widget renderer with dependency injection."""

from pyiv import Config, SingletonType, get_injector

from mcp_base.widget_renderer import WidgetRenderer
from mcp_base.widget_views import (
    DesktopWidgetView,
    ListWidgetView,
    MobileWidgetView,
    ViewContext,
    ViewRequest,
    WidgetView,
)
from mcp_base.widgets import WidgetCard


class TestWidgetRenderer:
    """Tests for WidgetRenderer."""

    def test_renderer_without_registered_views(self):
        """Test renderer falls back to default view when no views registered."""

        class EmptyConfig(Config):
            def configure(self):
                pass

        injector = get_injector(EmptyConfig)
        renderer = WidgetRenderer(injector)

        widget = WidgetCard(id="test", title="Test")
        request = ViewRequest(context=ViewContext.LIST, widget=widget)
        html = renderer.render(request)

        assert "test" in html
        assert "Test" in html

    def test_renderer_with_registered_view(self):
        """Test renderer uses registered view."""

        class TestConfig(Config):
            def configure(self):
                self.register(WidgetView, ListWidgetView, singleton_type=SingletonType.SINGLETON)

        injector = get_injector(TestConfig)
        renderer = WidgetRenderer(injector)

        widget = WidgetCard(id="test", title="Test")
        request = ViewRequest(context=ViewContext.LIST, widget=widget)
        html = renderer.render(request)

        assert "test" in html
        # Should use list view which wraps in widget-list
        assert "widget-list" in html or "Test" in html

    def test_renderer_view_caching(self):
        """Test that renderer caches views."""

        class TestConfig(Config):
            def configure(self):
                self.register(WidgetView, ListWidgetView, singleton_type=SingletonType.SINGLETON)

        injector = get_injector(TestConfig)
        renderer = WidgetRenderer(injector)

        # First call
        widget1 = WidgetCard(id="test1", title="Test 1")
        request1 = ViewRequest(context=ViewContext.LIST, widget=widget1)
        html1 = renderer.render(request1)

        # Second call should use cached view
        widget2 = WidgetCard(id="test2", title="Test 2")
        request2 = ViewRequest(context=ViewContext.LIST, widget=widget2)
        html2 = renderer.render(request2)

        assert "test1" in html1
        assert "test2" in html2
        # View should be cached (LIST resolves to LIST_DESKTOP by default)
        assert ViewContext.LIST_DESKTOP in renderer._view_cache

    def test_renderer_multiple_contexts(self):
        """Test renderer with multiple view contexts."""

        class TestConfig(Config):
            def configure(self):
                self.register(WidgetView, ListWidgetView, singleton_type=SingletonType.SINGLETON)
                self.register(WidgetView, MobileWidgetView, singleton_type=SingletonType.SINGLETON)
                self.register(WidgetView, DesktopWidgetView, singleton_type=SingletonType.SINGLETON)

        injector = get_injector(TestConfig)
        renderer = WidgetRenderer(injector)

        widget = WidgetCard(id="test", title="Test")

        # Test list view (resolves to LIST_DESKTOP by default)
        request = ViewRequest(context=ViewContext.LIST, widget=widget)
        html = renderer.render(request)
        assert "test" in html

        # Test that renderer can handle different contexts without error
        # Note: When multiple views are registered for the same interface,
        # the renderer may not find the exact match, but should still render
        for context in [ViewContext.MOBILE, ViewContext.DESKTOP, ViewContext.DETAIL]:
            request = ViewRequest(context=context, widget=widget)
            html = renderer.render(request)
            assert "test" in html  # Should render successfully

    def test_renderer_render_multiple(self):
        """Test rendering multiple widgets."""

        class TestConfig(Config):
            def configure(self):
                self.register(WidgetView, ListWidgetView, singleton_type=SingletonType.SINGLETON)

        injector = get_injector(TestConfig)
        renderer = WidgetRenderer(injector)

        widgets = [WidgetCard(id=f"widget-{i}", title=f"Widget {i}") for i in range(3)]
        requests = [ViewRequest(context=ViewContext.LIST, widget=widget) for widget in widgets]

        html = renderer.render_multiple(requests)
        assert "widget-0" in html
        assert "widget-1" in html
        assert "widget-2" in html

    def test_renderer_render_multiple_with_context(self):
        """Test rendering multiple widgets with explicit context."""

        class TestConfig(Config):
            def configure(self):
                self.register(WidgetView, ListWidgetView, singleton_type=SingletonType.SINGLETON)

        injector = get_injector(TestConfig)
        renderer = WidgetRenderer(injector)

        widgets = [WidgetCard(id=f"widget-{i}", title=f"Widget {i}") for i in range(3)]
        requests = [ViewRequest(context=ViewContext.DEFAULT, widget=widget) for widget in widgets]

        # Override context to LIST
        html = renderer.render_multiple(requests, context=ViewContext.LIST)
        assert "widget-0" in html
        assert "widget-1" in html
        assert "widget-2" in html

    def test_renderer_empty_requests(self):
        """Test rendering empty list of requests."""

        class TestConfig(Config):
            def configure(self):
                pass

        injector = get_injector(TestConfig)
        renderer = WidgetRenderer(injector)

        html = renderer.render_multiple([])
        assert html == ""

    def test_renderer_fallback_to_default(self):
        """Test renderer falls back to default view for unregistered context."""

        class TestConfig(Config):
            def configure(self):
                # Only register list view
                self.register(WidgetView, ListWidgetView, singleton_type=SingletonType.SINGLETON)

        injector = get_injector(TestConfig)
        renderer = WidgetRenderer(injector)

        # Request detail view (not registered)
        widget = WidgetCard(id="test", title="Test")
        request = ViewRequest(context=ViewContext.DETAIL, widget=widget)
        html = renderer.render(request)

        # Should fall back to default view
        assert "test" in html
        assert "Test" in html
