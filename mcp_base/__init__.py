"""MCP Base Framework - Automatic handler discovery and routing for MCP services."""

from mcp_base.exceptions import ExceptionMapper, McpErrorCode, create_default_mapper
from mcp_base.handler import McpToolHandler, TextContent
from mcp_base.metrics import (
    get_metrics,
    get_metrics_collector,
    get_metrics_content_type,
    record_http_request,
    set_metrics_collector,
    track_tool_execution,
)
from mcp_base.observability import MetricsCollector, TracingCollector
from mcp_base.request_models import get_schema_from_model, validate_request
from mcp_base.serializers import serialize_datetime, serialize_model, serialize_uuid
from mcp_base.server import McpServerBase
from mcp_base.tracing import (
    add_span_attribute,
    add_span_event,
    get_tracing_collector,
    instrument_fastapi,
    set_span_status,
    set_tracing_collector,
    setup_tracing,
    trace_span,
)
from mcp_base.user_agent import (
    detect_device_type,
    get_view_context,
    is_desktop_device,
    is_mobile_device,
)
from mcp_base.widget_renderer import WidgetRenderer
from mcp_base.widget_server import WidgetServer
from mcp_base.widget_views import (
    DefaultWidgetView,
    DesktopWidgetView,
    DetailDesktopView,
    DetailMobileView,
    DetailWidgetView,
    ListDesktopView,
    ListMobileView,
    ListWidgetView,
    MobileWidgetView,
    ViewContext,
    ViewRequest,
    WidgetView,
)
from mcp_base.widgets import WidgetAction, WidgetCard, WidgetProvider

# Test utilities (for testing)
try:
    from mcp_base.test_observability import (  # noqa: F401
        HttpRequest,
        TestMetricsCollector,
        TestTracingCollector,
        ToolExecution,
        TraceSpan,
    )

    _TEST_AVAILABLE = True
except ImportError:
    _TEST_AVAILABLE = False

__version__ = "0.1.5"  # Keep in sync with pyproject.toml
__all__ = [
    "McpToolHandler",
    "TextContent",
    "McpServerBase",
    "serialize_model",
    "serialize_datetime",
    "serialize_uuid",
    "ExceptionMapper",
    "McpErrorCode",
    "create_default_mapper",
    "validate_request",
    "get_schema_from_model",
    # Observability
    "MetricsCollector",
    "TracingCollector",
    "get_metrics_collector",
    "set_metrics_collector",
    "track_tool_execution",
    "record_http_request",
    "get_metrics",
    "get_metrics_content_type",
    "get_tracing_collector",
    "set_tracing_collector",
    "trace_span",
    "add_span_attribute",
    "add_span_event",
    "set_span_status",
    "setup_tracing",
    "instrument_fastapi",
    # Widgets
    "WidgetCard",
    "WidgetAction",
    "WidgetProvider",
    "WidgetServer",
    "WidgetRenderer",
    # Widget Views
    "WidgetView",
    "ViewContext",
    "ViewRequest",
    "DefaultWidgetView",
    "ListWidgetView",
    "ListMobileView",
    "ListDesktopView",
    "DetailWidgetView",
    "DetailMobileView",
    "DetailDesktopView",
    "MobileWidgetView",
    "DesktopWidgetView",
    # User Agent Detection
    "is_mobile_device",
    "is_desktop_device",
    "detect_device_type",
    "get_view_context",
]

# Add test utilities if available
if _TEST_AVAILABLE:
    __all__.extend(
        [
            "TestMetricsCollector",
            "TestTracingCollector",
            "ToolExecution",
            "HttpRequest",
            "TraceSpan",
        ]
    )
