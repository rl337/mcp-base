"""Distributed tracing for MCP base framework using OpenTelemetry."""

import logging
import os
from contextlib import contextmanager, nullcontext
from typing import Any

from mcp_base.observability import TracingCollector

try:
    from opentelemetry import trace
    from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
    from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
    from opentelemetry.sdk.resources import Resource
    from opentelemetry.sdk.trace import TracerProvider
    from opentelemetry.sdk.trace.export import BatchSpanProcessor, ConsoleSpanExporter

    OPENTELEMETRY_AVAILABLE = True
except ImportError:
    OPENTELEMETRY_AVAILABLE = False

    # Dummy classes for when OpenTelemetry is not available
    class _DummyTrace:  # type: ignore[no-redef]
        class SpanKind:
            INTERNAL = "INTERNAL"
            SERVER = "SERVER"
            CLIENT = "CLIENT"

        class StatusCode:
            OK = "OK"
            ERROR = "ERROR"

        class Status:
            def __init__(self, code: str, description: str | None = None) -> None:
                pass

        class Tracer:
            def start_as_current_span(self, name: str, kind: Any = None) -> Any:
                return nullcontext()

        @staticmethod
        def get_tracer(name: str) -> "Tracer":
            return _DummyTrace.Tracer()

        @staticmethod
        def get_current_span() -> None:
            return None

    trace = _DummyTrace()  # type: ignore[assignment, misc]
    FastAPIInstrumentor = None  # type: ignore[assignment, misc]
    # Dummy imports for type checking
    OTLPSpanExporter = None  # type: ignore[assignment, misc]
    Resource = None  # type: ignore[assignment, misc]
    TracerProvider = None  # type: ignore[assignment, misc]
    BatchSpanProcessor = None  # type: ignore[assignment, misc]
    ConsoleSpanExporter = None  # type: ignore[assignment, misc]

logger = logging.getLogger(__name__)

# Global tracer
_tracer: trace.Tracer | None = None
_service_name = os.getenv("OTEL_SERVICE_NAME", "mcp-service")
_otlp_endpoint = os.getenv("OTEL_EXPORTER_OTLP_ENDPOINT", "http://localhost:4317")
_use_otlp = os.getenv("OTEL_EXPORTER_OTLP_ENABLED", "true").lower() == "true"
_enable_console = os.getenv("OTEL_CONSOLE_EXPORTER_ENABLED", "false").lower() == "true"


def setup_tracing(service_name: str | None = None) -> None:
    """Initialize OpenTelemetry tracing for the service.

    Args:
        service_name: Optional service name (defaults to OTEL_SERVICE_NAME env var)
    """
    global _tracer, _service_name

    if not OPENTELEMETRY_AVAILABLE:
        logger.warning("OpenTelemetry not available, tracing disabled")
        return

    if _tracer is not None:
        logger.warning("Tracing already initialized")
        return

    if service_name:
        _service_name = service_name

    logger.info(
        "Initializing OpenTelemetry tracing",
        extra={
            "service_name": _service_name,
            "otlp_endpoint": _otlp_endpoint,
            "use_otlp": _use_otlp,
            "enable_console": _enable_console,
        },
    )

    # Create resource with service information
    resource = Resource.create(
        {
            "service.name": _service_name,
            "service.version": os.getenv("SERVICE_VERSION", "0.1.0"),
            "deployment.environment": os.getenv("ENVIRONMENT", "development"),
        }
    )

    # Create tracer provider
    provider = TracerProvider(resource=resource)
    trace.set_tracer_provider(provider)

    # Add span processors (exporters)
    span_processors = []

    # OTLP exporter (for Jaeger, Tempo, etc. via OTLP)
    if _use_otlp:
        try:
            otlp_exporter = OTLPSpanExporter(
                endpoint=_otlp_endpoint,
                insecure=True,  # Use TLS in production
            )
            span_processors.append(BatchSpanProcessor(otlp_exporter))
            logger.info("OTLP exporter configured", extra={"endpoint": _otlp_endpoint})
        except Exception:
            logger.warning("Failed to configure OTLP exporter", exc_info=True)

    # Console exporter (for debugging)
    if _enable_console:
        console_exporter = ConsoleSpanExporter()
        span_processors.append(BatchSpanProcessor(console_exporter))
        logger.info("Console exporter enabled")

    # Register span processors
    for processor in span_processors:
        provider.add_span_processor(processor)

    # Get tracer
    _tracer = trace.get_tracer(__name__)

    logger.info("OpenTelemetry tracing initialized successfully")


def instrument_fastapi(app) -> None:
    """Instrument FastAPI application with OpenTelemetry.

    Args:
        app: FastAPI application instance
    """
    if not OPENTELEMETRY_AVAILABLE or FastAPIInstrumentor is None:
        logger.warning("OpenTelemetry not available, FastAPI instrumentation skipped")
        return

    try:
        FastAPIInstrumentor.instrument_app(app)
        logger.info("FastAPI instrumentation enabled")
    except Exception:
        logger.error("Failed to instrument FastAPI", exc_info=True)


def get_tracer() -> Any:  # type: ignore[return-type]
    """Get the global tracer instance.

    Returns:
        Tracer instance (or dummy tracer if OpenTelemetry not available)
    """
    global _tracer
    if not OPENTELEMETRY_AVAILABLE:
        return trace.get_tracer(__name__)  # Returns dummy tracer

    if _tracer is None:
        # Initialize if not already done
        setup_tracing()
    return _tracer or trace.get_tracer(__name__)


class OpenTelemetryTracingCollector(TracingCollector):
    """OpenTelemetry-based implementation of TracingCollector."""

    def __init__(self):
        """Initialize OpenTelemetry tracing collector."""
        if not OPENTELEMETRY_AVAILABLE:
            logger.warning("OpenTelemetry not available, tracing will be no-ops")

    @contextmanager
    def trace_span(
        self, name: str, attributes: dict[str, Any] | None = None, kind: str | None = None
    ):
        """Create a trace span."""
        if not OPENTELEMETRY_AVAILABLE:
            yield None
            return

        # Convert kind string to SpanKind if provided
        span_kind = trace.SpanKind.INTERNAL
        if kind:
            kind_upper = kind.upper()
            if kind_upper == "SERVER":
                span_kind = trace.SpanKind.SERVER
            elif kind_upper == "CLIENT":
                span_kind = trace.SpanKind.CLIENT

        tracer = get_tracer()
        with tracer.start_as_current_span(name, kind=span_kind) as span:
            if attributes:
                for key, value in attributes.items():
                    if value is not None:
                        # Convert value to appropriate type
                        if isinstance(value, (str, int, float, bool)):
                            span.set_attribute(key, value)
                        else:
                            span.set_attribute(key, str(value))

            try:
                yield span
            except Exception as e:
                # Record exception in span
                span.record_exception(e)
                span.set_status(trace.Status(trace.StatusCode.ERROR, str(e)))
                raise

    def add_span_attribute(self, key: str, value: Any) -> None:
        """Add attribute to current span."""
        if not OPENTELEMETRY_AVAILABLE:
            return

        span = trace.get_current_span()
        if span:
            if isinstance(value, (str, int, float, bool)):
                span.set_attribute(key, value)
            else:
                span.set_attribute(key, str(value))

    def add_span_event(self, name: str, attributes: dict[str, Any] | None = None) -> None:
        """Add event to current span."""
        if not OPENTELEMETRY_AVAILABLE:
            return

        span = trace.get_current_span()
        if span:
            span.add_event(name, attributes or {})

    def set_span_status(self, status_code: str, description: str | None = None) -> None:
        """Set status of current span."""
        if not OPENTELEMETRY_AVAILABLE:
            return

        span = trace.get_current_span()
        if span:
            code = trace.StatusCode.ERROR if status_code.upper() == "ERROR" else trace.StatusCode.OK
            span.set_status(trace.Status(code, description))


# Default instance (can be replaced with test instance)
_default_tracing_collector: TracingCollector | None = None


def get_tracing_collector() -> TracingCollector:
    """Get the current tracing collector instance.

    Returns:
        TracingCollector instance (defaults to OpenTelemetryTracingCollector)
    """
    global _default_tracing_collector
    if _default_tracing_collector is None:
        _default_tracing_collector = OpenTelemetryTracingCollector()
    return _default_tracing_collector


def set_tracing_collector(collector: TracingCollector) -> None:
    """Set the tracing collector instance (for testing).

    Args:
        collector: TracingCollector instance to use
    """
    global _default_tracing_collector
    _default_tracing_collector = collector


# Backward compatibility functions
@contextmanager
def trace_span(
    name: str,
    attributes: dict[str, Any] | None = None,
    kind: trace.SpanKind = trace.SpanKind.INTERNAL,
):
    """Context manager for creating a trace span (uses default collector)."""
    kind_str = "INTERNAL"
    if kind == trace.SpanKind.SERVER:
        kind_str = "SERVER"
    elif kind == trace.SpanKind.CLIENT:
        kind_str = "CLIENT"

    with get_tracing_collector().trace_span(name, attributes, kind_str):
        yield


def add_span_attribute(key: str, value: Any) -> None:
    """Add an attribute to the current active span (uses default collector)."""
    get_tracing_collector().add_span_attribute(key, value)


def add_span_event(name: str, attributes: dict[str, Any] | None = None) -> None:
    """Add an event to the current active span (uses default collector)."""
    get_tracing_collector().add_span_event(name, attributes)


def set_span_status(status_code: trace.StatusCode, description: str | None = None) -> None:
    """Set the status of the current active span (uses default collector)."""
    status_str = "ERROR" if status_code == trace.StatusCode.ERROR else "OK"
    get_tracing_collector().set_span_status(status_str, description)
