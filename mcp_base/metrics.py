"""Prometheus metrics for MCP base framework."""

import time
import logging
from typing import Optional
from contextlib import contextmanager

from mcp_base.observability import MetricsCollector

try:
    from prometheus_client import Counter, Histogram, Gauge, generate_latest, CONTENT_TYPE_LATEST
    PROMETHEUS_AVAILABLE = True
except ImportError:
    PROMETHEUS_AVAILABLE = False
    # Dummy classes for when Prometheus is not available
    class Counter:
        def labels(self, **kwargs): return self
        def inc(self): pass
    class Histogram:
        def labels(self, **kwargs): return self
        def observe(self, value): pass
    class Gauge:
        def labels(self, **kwargs): return self
        def set(self, value): pass
    def generate_latest(): return b"# Prometheus not available\n"
    CONTENT_TYPE_LATEST = "text/plain"

logger = logging.getLogger(__name__)

# MCP tool execution metrics
mcp_tool_requests_total = Counter(
    'mcp_tool_requests_total',
    'Total number of MCP tool execution requests',
    ['tool_name', 'status']  # status: success, error
) if PROMETHEUS_AVAILABLE else Counter()

mcp_tool_request_duration_seconds = Histogram(
    'mcp_tool_request_duration_seconds',
    'Duration of MCP tool execution requests in seconds',
    ['tool_name', 'status'],
    buckets=(0.001, 0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1.0, 2.5, 5.0, 10.0, 30.0, 60.0)
) if PROMETHEUS_AVAILABLE else Histogram()

mcp_tool_errors_total = Counter(
    'mcp_tool_errors_total',
    'Total number of MCP tool execution errors',
    ['tool_name', 'error_type', 'error_reason']  # error_type: validation, not_found, internal, etc.
) if PROMETHEUS_AVAILABLE else Counter()

mcp_tool_active_requests = Gauge(
    'mcp_tool_active_requests',
    'Number of currently active MCP tool execution requests',
    ['tool_name']
) if PROMETHEUS_AVAILABLE else Gauge()

# HTTP endpoint metrics (for FastAPI routes)
mcp_http_requests_total = Counter(
    'mcp_http_requests_total',
    'Total number of HTTP requests to MCP endpoints',
    ['method', 'endpoint', 'status_code']
) if PROMETHEUS_AVAILABLE else Counter()

mcp_http_request_duration_seconds = Histogram(
    'mcp_http_request_duration_seconds',
    'HTTP request duration for MCP endpoints in seconds',
    ['method', 'endpoint', 'status_code'],
    buckets=(0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1.0, 2.5, 5.0, 10.0)
) if PROMETHEUS_AVAILABLE else Histogram()

mcp_http_errors_total = Counter(
    'mcp_http_errors_total',
    'Total number of HTTP errors for MCP endpoints',
    ['method', 'endpoint', 'status_code', 'error_type']
) if PROMETHEUS_AVAILABLE else Counter()


class PrometheusMetricsCollector(MetricsCollector):
    """Prometheus-based implementation of MetricsCollector."""
    
    def __init__(self):
        """Initialize Prometheus metrics collector."""
        if not PROMETHEUS_AVAILABLE:
            logger.warning("Prometheus not available, metrics will be no-ops")
    
    @contextmanager
    def track_tool_execution(self, tool_name: str):
        """Track MCP tool execution metrics."""
        start_time = time.time()
        status = "success"
        error_type = None
        error_reason = None
        
        # Increment active requests
        if PROMETHEUS_AVAILABLE:
            mcp_tool_active_requests.labels(tool_name=tool_name).inc()
        
        try:
            yield
        except Exception as e:
            status = "error"
            error_type = type(e).__name__
            error_reason = str(e)[:100]  # Truncate long error messages
            
            # Record error metrics
            if PROMETHEUS_AVAILABLE:
                mcp_tool_errors_total.labels(
                    tool_name=tool_name,
                    error_type=error_type,
                    error_reason=error_reason
                ).inc()
            
            raise
        finally:
            duration = time.time() - start_time
            
            # Decrement active requests
            if PROMETHEUS_AVAILABLE:
                mcp_tool_active_requests.labels(tool_name=tool_name).dec()
            
            # Record request metrics
            if PROMETHEUS_AVAILABLE:
                mcp_tool_requests_total.labels(
                    tool_name=tool_name,
                    status=status
                ).inc()
                
                mcp_tool_request_duration_seconds.labels(
                    tool_name=tool_name,
                    status=status
                ).observe(duration)
    
    def record_http_request(
        self,
        method: str,
        endpoint: str,
        status_code: int,
        duration: float,
        error_type: Optional[str] = None
    ):
        """Record HTTP request metrics."""
        if not PROMETHEUS_AVAILABLE:
            return
        
        mcp_http_requests_total.labels(
            method=method,
            endpoint=endpoint,
            status_code=status_code
        ).inc()
        
        mcp_http_request_duration_seconds.labels(
            method=method,
            endpoint=endpoint,
            status_code=status_code
        ).observe(duration)
        
        if status_code >= 400:
            mcp_http_errors_total.labels(
                method=method,
                endpoint=endpoint,
                status_code=status_code,
                error_type=error_type or "unknown"
            ).inc()
    
    def get_metrics(self) -> bytes:
        """Get Prometheus metrics in text format."""
        if not PROMETHEUS_AVAILABLE:
            return b"# Prometheus metrics not available\n"
        return generate_latest()
    
    def get_metrics_content_type(self) -> str:
        """Get the content type for metrics response."""
        return CONTENT_TYPE_LATEST


# Default instance (can be replaced with test instance)
_default_metrics_collector: Optional[MetricsCollector] = None


def get_metrics_collector() -> MetricsCollector:
    """Get the current metrics collector instance.
    
    Returns:
        MetricsCollector instance (defaults to PrometheusMetricsCollector)
    """
    global _default_metrics_collector
    if _default_metrics_collector is None:
        _default_metrics_collector = PrometheusMetricsCollector()
    return _default_metrics_collector


def set_metrics_collector(collector: MetricsCollector) -> None:
    """Set the metrics collector instance (for testing).
    
    Args:
        collector: MetricsCollector instance to use
    """
    global _default_metrics_collector
    _default_metrics_collector = collector


# Backward compatibility functions
@contextmanager
def track_tool_execution(tool_name: str):
    """Context manager to track MCP tool execution metrics (uses default collector)."""
    with get_metrics_collector().track_tool_execution(tool_name):
        yield


def record_http_request(
    method: str,
    endpoint: str,
    status_code: int,
    duration: float,
    error_type: Optional[str] = None
):
    """Record HTTP request metrics (uses default collector)."""
    get_metrics_collector().record_http_request(method, endpoint, status_code, duration, error_type)


def get_metrics() -> bytes:
    """Get Prometheus metrics in text format (uses default collector)."""
    return get_metrics_collector().get_metrics()


def get_metrics_content_type() -> str:
    """Get the content type for metrics response (uses default collector)."""
    return get_metrics_collector().get_metrics_content_type()

