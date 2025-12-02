"""Widget view system with dependency injection support.

This module provides a view system that allows different widget renderers
to be registered for different contexts (list view, detail view, mobile, desktop, etc.).
"""

from abc import ABC, abstractmethod
from dataclasses import dataclass
from enum import Enum
from typing import Any

from mcp_base.widgets import WidgetCard


class ViewContext(Enum):
    """Context types for widget views.

    Supports both simple contexts (LIST, DETAIL, MOBILE, DESKTOP) and
    composite contexts (LIST_MOBILE, LIST_DESKTOP, DETAIL_MOBILE, DETAIL_DESKTOP).
    Composite contexts combine view type (list/detail) with device type (mobile/desktop).
    """

    # Simple contexts (for backward compatibility)
    LIST = "list"
    """List/timeline view - widgets displayed in a list."""
    DETAIL = "detail"
    """Detail view - single widget displayed in detail."""
    MOBILE = "mobile"
    """Mobile view - optimized for mobile devices."""
    DESKTOP = "desktop"
    """Desktop view - optimized for desktop devices."""
    DEFAULT = "default"
    """Default view - fallback when no specific view is registered."""

    # Composite contexts (preferred)
    LIST_MOBILE = "list_mobile"
    """List view optimized for mobile devices."""
    LIST_DESKTOP = "list_desktop"
    """List view optimized for desktop devices."""
    DETAIL_MOBILE = "detail_mobile"
    """Detail view optimized for mobile devices."""
    DETAIL_DESKTOP = "detail_desktop"
    """Detail view optimized for desktop devices."""


@dataclass
class ViewRequest:
    """Request context for widget rendering."""

    context: ViewContext
    """The view context (list, detail, mobile, desktop, etc.)."""
    widget: WidgetCard
    """The widget to render."""
    base_path: str = "/v1/widgets"
    """Base path for widget API endpoints."""
    metadata: dict[str, Any] | None = None
    """Additional metadata for rendering."""

    def __post_init__(self):
        """Initialize default metadata if not provided."""
        if self.metadata is None:
            self.metadata = {}


class WidgetView(ABC):
    """Interface for widget view renderers.

    Different implementations can be registered for different ViewContext types.
    If no specific view is registered for a context, the default view will be used.
    """

    @property
    @abstractmethod
    def view_context(self) -> ViewContext:
        """Return the view context this renderer handles.

        Returns:
            The ViewContext this renderer is registered for
        """
        pass

    @abstractmethod
    def render(self, request: ViewRequest) -> str:
        """Render a widget as HTML.

        Args:
            request: View request containing widget and context

        Returns:
            HTML string for the rendered widget
        """
        pass

    def render_multiple(self, requests: list[ViewRequest]) -> str:
        """Render multiple widgets (e.g., for list view).

        Default implementation renders each widget separately and combines them.
        Subclasses can override for optimized batch rendering.

        Args:
            requests: List of view requests to render

        Returns:
            HTML string containing all rendered widgets
        """
        return "\n".join(self.render(req) for req in requests)


class DefaultWidgetView(WidgetView):
    """Default widget view implementation.

    This is used as a fallback when no specific view is registered for a context.
    """

    def __init__(self, context: ViewContext = ViewContext.DEFAULT):
        """Initialize default view.

        Args:
            context: The view context this instance handles
        """
        self._context = context

    @property
    def view_context(self) -> ViewContext:
        return self._context

    def render(self, request: ViewRequest) -> str:
        """Render widget as a card."""
        widget = request.widget
        timestamp = widget.timestamp.strftime("%Y-%m-%d %H:%M:%S")
        card_class = f"widget-card {widget.card_type}"

        # Render actions
        actions_html = ""
        if widget.actions:
            actions = []
            for idx, action in enumerate(widget.actions):
                btn_class = "action-btn" if idx == 0 else "action-btn secondary"
                actions.append(
                    f'<button class="{btn_class}" '
                    f"onclick=\"handleWidgetAction('{widget.id}', {idx}, {self._action_to_json(action)})\">"
                    f"{self._escape_html(action.label)}</button>"
                )
            actions_html = f'<div class="widget-actions">{"".join(actions)}</div>'

        # Render metadata
        meta_parts = []
        if widget.service_name:
            meta_parts.append(self._escape_html(widget.service_name))
        if widget.tool_name:
            meta_parts.append(self._escape_html(widget.tool_name))
        meta_parts.append(timestamp)
        meta_html = " • ".join(meta_parts)

        return f"""
        <div class="{card_class}" data-widget-id="{widget.id}">
            <div class="widget-header">
                <div>
                    <div class="widget-title">{self._escape_html(widget.title)}</div>
                    <div class="widget-meta">{meta_html}</div>
                </div>
            </div>
            <div class="widget-content">{widget.content}</div>
            {actions_html}
        </div>
        """

    def _escape_html(self, text: str) -> str:
        """Escape HTML special characters."""
        return (
            text.replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace('"', "&quot;")
            .replace("'", "&#x27;")
        )

    def _action_to_json(self, action: Any) -> str:
        """Convert action to JSON string for JavaScript."""
        import json

        return json.dumps(
            {
                "method": action.method,
                "url": action.url,
                "payload": action.payload,
                "confirm": action.confirm,
                "confirm_message": action.confirm_message,
            }
        )


class ListWidgetView(DefaultWidgetView):
    """List view implementation for widgets."""

    def __init__(self):
        super().__init__(ViewContext.LIST)

    def render_multiple(self, requests: list[ViewRequest]) -> str:
        """Render multiple widgets in a list layout."""
        widgets_html = "\n".join(self.render(req) for req in requests)
        return f'<div class="widget-list">{widgets_html}</div>'


class DetailWidgetView(DefaultWidgetView):
    """Detail view implementation for widgets."""

    def __init__(self):
        super().__init__(ViewContext.DETAIL)

    def render(self, request: ViewRequest) -> str:
        """Render widget in detail view with expanded information."""
        widget = request.widget
        base_html = super().render(request)

        # Add expanded metadata section
        metadata_html = ""
        if widget.metadata:
            metadata_items = []
            for key, value in widget.metadata.items():
                metadata_items.append(
                    f'<div class="metadata-item">'
                    f"<strong>{self._escape_html(str(key))}:</strong> "
                    f"<span>{self._escape_html(str(value))}</span></div>"
                )
            if metadata_items:
                metadata_html = f'<div class="widget-metadata">{"".join(metadata_items)}</div>'

        return f"""
        <div class="widget-detail">
            {base_html}
            {metadata_html}
        </div>
        """


class MobileWidgetView(DefaultWidgetView):
    """Mobile-optimized view implementation."""

    def __init__(self):
        super().__init__(ViewContext.MOBILE)

    def render(self, request: ViewRequest) -> str:
        """Render widget optimized for mobile devices."""
        widget = request.widget
        # Use compact layout for mobile
        card_class = f"widget-card mobile {widget.card_type}"
        timestamp = widget.timestamp.strftime("%m/%d %H:%M")

        actions_html = ""
        if widget.actions:
            # Mobile: show only primary action, others in menu
            primary_action = widget.actions[0]
            actions_html = f"""
            <div class="widget-actions mobile">
                <button class="action-btn primary"
                        onclick="handleWidgetAction('{widget.id}', 0, {self._action_to_json(primary_action)})">
                    {self._escape_html(primary_action.label)}
                </button>
                {('<button class="action-btn menu" onclick="showActionMenu(\'' + widget.id + '\')">⋯</button>' if len(widget.actions) > 1 else '')}
            </div>
            """

        return f"""
        <div class="{card_class}" data-widget-id="{widget.id}">
            <div class="widget-header mobile">
                <div class="widget-title">{self._escape_html(widget.title)}</div>
                <div class="widget-meta">{timestamp}</div>
            </div>
            <div class="widget-content mobile">{widget.content}</div>
            {actions_html}
        </div>
        """


class DesktopWidgetView(DefaultWidgetView):
    """Desktop-optimized view implementation."""

    def __init__(self):
        super().__init__(ViewContext.DESKTOP)

    def render(self, request: ViewRequest) -> str:
        """Render widget optimized for desktop devices."""
        # Desktop can show more information and use wider layout
        return super().render(request)


class ListMobileView(DefaultWidgetView):
    """List view optimized for mobile devices."""

    def __init__(self):
        super().__init__(ViewContext.LIST_MOBILE)

    def render_multiple(self, requests: list[ViewRequest]) -> str:
        """Render multiple widgets in a mobile-optimized list layout."""
        widgets_html = "\n".join(self.render(req) for req in requests)
        return f'<div class="widget-list mobile">{widgets_html}</div>'

    def render(self, request: ViewRequest) -> str:
        """Render widget optimized for mobile list view."""
        widget = request.widget
        card_class = f"widget-card mobile list {widget.card_type}"
        timestamp = widget.timestamp.strftime("%m/%d %H:%M")

        actions_html = ""
        if widget.actions:
            primary_action = widget.actions[0]
            actions_html = f"""
            <div class="widget-actions mobile">
                <button class="action-btn primary"
                        onclick="handleWidgetAction('{widget.id}', 0, {self._action_to_json(primary_action)})">
                    {self._escape_html(primary_action.label)}
                </button>
                {('<button class="action-btn menu" onclick="showActionMenu(\'' + widget.id + '\')">⋯</button>' if len(widget.actions) > 1 else '')}
            </div>
            """

        meta_parts = []
        if widget.service_name:
            meta_parts.append(self._escape_html(widget.service_name))
        meta_parts.append(timestamp)
        meta_html = " • ".join(meta_parts)

        return f"""
        <div class="{card_class}" data-widget-id="{widget.id}">
            <div class="widget-header mobile">
                <div class="widget-title">{self._escape_html(widget.title)}</div>
                <div class="widget-meta">{meta_html}</div>
            </div>
            <div class="widget-content mobile">{widget.content}</div>
            {actions_html}
        </div>
        """


class ListDesktopView(ListWidgetView):
    """List view optimized for desktop devices."""

    def __init__(self):
        super().__init__()
        self._context = ViewContext.LIST_DESKTOP

    @property
    def view_context(self) -> ViewContext:
        return self._context

    def render(self, request: ViewRequest) -> str:
        """Render widget optimized for desktop list view."""
        # Desktop list can show more information
        return super().render(request)


class DetailMobileView(DetailWidgetView):
    """Detail view optimized for mobile devices."""

    def __init__(self):
        super().__init__()
        self._context = ViewContext.DETAIL_MOBILE

    @property
    def view_context(self) -> ViewContext:
        return self._context

    def render(self, request: ViewRequest) -> str:
        """Render widget in mobile-optimized detail view."""
        widget = request.widget
        card_class = f"widget-card mobile detail {widget.card_type}"
        timestamp = widget.timestamp.strftime("%m/%d %H:%M")

        # Mobile detail view with compact metadata
        metadata_html = ""
        if widget.metadata:
            metadata_items = []
            for key, value in widget.metadata.items():
                metadata_items.append(
                    f'<div class="metadata-item mobile">'
                    f"<strong>{self._escape_html(str(key))}:</strong> "
                    f"<span>{self._escape_html(str(value))}</span></div>"
                )
            if metadata_items:
                metadata_html = (
                    f'<div class="widget-metadata mobile">{"".join(metadata_items)}</div>'
                )

        actions_html = ""
        if widget.actions:
            actions = []
            for idx, action in enumerate(widget.actions):
                btn_class = "action-btn primary" if idx == 0 else "action-btn secondary"
                actions.append(
                    f'<button class="{btn_class}" '
                    f"onclick=\"handleWidgetAction('{widget.id}', {idx}, {self._action_to_json(action)})\">"
                    f"{self._escape_html(action.label)}</button>"
                )
            actions_html = f'<div class="widget-actions mobile">{"".join(actions)}</div>'

        meta_parts = []
        if widget.service_name:
            meta_parts.append(self._escape_html(widget.service_name))
        if widget.tool_name:
            meta_parts.append(self._escape_html(widget.tool_name))
        meta_parts.append(timestamp)
        meta_html = " • ".join(meta_parts)

        return f"""
        <div class="widget-detail mobile">
            <div class="{card_class}" data-widget-id="{widget.id}">
                <div class="widget-header mobile">
                    <div class="widget-title">{self._escape_html(widget.title)}</div>
                    <div class="widget-meta">{meta_html}</div>
                </div>
                <div class="widget-content mobile">{widget.content}</div>
                {actions_html}
            </div>
            {metadata_html}
        </div>
        """


class DetailDesktopView(DetailWidgetView):
    """Detail view optimized for desktop devices."""

    def __init__(self):
        super().__init__()
        self._context = ViewContext.DETAIL_DESKTOP

    @property
    def view_context(self) -> ViewContext:
        return self._context

    def render(self, request: ViewRequest) -> str:
        """Render widget in desktop-optimized detail view."""
        # Desktop detail can show more information
        return super().render(request)
