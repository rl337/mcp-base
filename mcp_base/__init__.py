"""MCP Base Framework - Automatic handler discovery and routing for MCP services."""

from mcp_base.handler import McpToolHandler
from mcp_base.server import McpServerBase
from mcp_base.serializers import serialize_model, serialize_datetime, serialize_uuid
from mcp_base.exceptions import (
    ExceptionMapper,
    McpErrorCode,
    create_default_mapper
)
from mcp_base.request_models import validate_request, get_schema_from_model
from mcp_base.observability import MetricsCollector, TracingCollector
from mcp_base.metrics import (
    get_metrics_collector,
    set_metrics_collector,
    track_tool_execution,
    record_http_request,
    get_metrics,
    get_metrics_content_type
)
from mcp_base.tracing import (
    get_tracing_collector,
    set_tracing_collector,
    trace_span,
    add_span_attribute,
    add_span_event,
    set_span_status,
    setup_tracing,
    instrument_fastapi
)

# Test utilities (for testing)
try:
    from mcp_base.test_observability import (
        TestMetricsCollector,
        TestTracingCollector,
        ToolExecution,
        HttpRequest,
        TraceSpan
    )
    _TEST_AVAILABLE = True
except ImportError:
    _TEST_AVAILABLE = False

__version__ = "0.1.2"  # Keep in sync with pyproject.toml
__all__ = [
    "McpToolHandler",
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
]

# Add test utilities if available
if _TEST_AVAILABLE:
    __all__.extend([
        "TestMetricsCollector",
        "TestTracingCollector",
        "ToolExecution",
        "HttpRequest",
        "TraceSpan",
    ])

