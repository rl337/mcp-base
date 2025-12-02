"""Widget system for interactive web interface components.

Widgets are simple data classes (like Java beans) that represent interactive
components that can be rendered as cards in a web interface. They support
actions that can call back to web services.
"""

from abc import ABC, abstractmethod
from dataclasses import dataclass, field
from datetime import datetime
from typing import Any


@dataclass
class WidgetAction:
    """An action that can be triggered from a widget.

    Actions can call back to web services via HTTP requests.
    """

    label: str
    """Display label for the action button."""
    method: str = "POST"
    """HTTP method (GET, POST, PUT, DELETE, etc.)."""
    url: str = ""
    """URL to call when action is triggered. Can be relative to base_path."""
    payload: dict[str, Any] = field(default_factory=dict)
    """Optional payload to send with the request."""
    confirm: bool = False
    """Whether to show a confirmation dialog before executing."""
    confirm_message: str = "Are you sure?"
    """Confirmation message if confirm is True."""


@dataclass
class WidgetCard:
    """A card widget that can be rendered in the web interface.

    This is the main widget type - a simple data class (like a Java bean)
    that represents a card component with title, content, and optional actions.
    """

    id: str
    """Unique identifier for this widget instance."""
    title: str
    """Card title."""
    content: str = ""
    """Card content (can be HTML or plain text)."""
    timestamp: datetime = field(default_factory=datetime.now)
    """When this widget was created/updated."""
    service_name: str = ""
    """Name of the MCP service that created this widget."""
    tool_name: str = ""
    """Name of the tool that created this widget (if applicable)."""
    actions: list[WidgetAction] = field(default_factory=list)
    """List of interactive actions available on this widget."""
    metadata: dict[str, Any] = field(default_factory=dict)
    """Additional metadata for the widget."""
    card_type: str = "default"
    """Card type for styling (default, success, warning, error, info)."""
    icon: str = ""
    """Optional icon name or URL."""

    def to_dict(self) -> dict[str, Any]:
        """Convert widget to dictionary for JSON serialization."""
        return {
            "id": self.id,
            "title": self.title,
            "content": self.content,
            "timestamp": self.timestamp.isoformat(),
            "service_name": self.service_name,
            "tool_name": self.tool_name,
            "actions": [
                {
                    "label": action.label,
                    "method": action.method,
                    "url": action.url,
                    "payload": action.payload,
                    "confirm": action.confirm,
                    "confirm_message": action.confirm_message,
                }
                for action in self.actions
            ],
            "metadata": self.metadata,
            "card_type": self.card_type,
            "icon": self.icon,
        }


class WidgetProvider(ABC):
    """Interface for MCP services to provide widgets.

    Similar to McpToolHandler, this interface allows services to provide
    widgets that will be automatically discovered and rendered in the web UI.
    """

    @property
    @abstractmethod
    def widget_name(self) -> str:
        """Return the widget provider name.

        Returns:
            Unique name for this widget provider
        """
        pass

    @abstractmethod
    async def get_widgets(self, limit: int = 50, since: datetime | None = None) -> list[WidgetCard]:
        """Get widgets for display in the timeline.

        Args:
            limit: Maximum number of widgets to return
            since: Only return widgets created after this timestamp

        Returns:
            List of widget cards, ordered by timestamp (newest first)
        """
        pass

    async def create_widget(
        self,
        title: str,
        content: str = "",
        tool_name: str = "",
        actions: list[WidgetAction] | None = None,
        metadata: dict[str, Any] | None = None,
        card_type: str = "default",
        icon: str = "",
    ) -> WidgetCard:
        """Create a new widget card.

        This is a convenience method for creating widgets. Services can also
        create WidgetCard instances directly.

        Args:
            title: Widget title
            content: Widget content
            tool_name: Associated tool name (if any)
            actions: List of actions for the widget
            metadata: Additional metadata
            card_type: Card type for styling
            icon: Optional icon

        Returns:
            Created widget card
        """
        import uuid

        widget = WidgetCard(
            id=str(uuid.uuid4()),
            title=title,
            content=content,
            timestamp=datetime.now(),
            service_name=self.widget_name,
            tool_name=tool_name,
            actions=actions or [],
            metadata=metadata or {},
            card_type=card_type,
            icon=icon,
        )
        return widget
