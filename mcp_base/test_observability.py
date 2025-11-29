"""Test implementations of observability interfaces for testing."""

from typing import Optional, Dict, Any, List
from contextlib import contextmanager
from dataclasses import dataclass, field
from datetime import datetime

from mcp_base.observability import MetricsCollector, TracingCollector


@dataclass
class ToolExecution:
    """Record of a tool execution for testing."""
    tool_name: str
    start_time: datetime
    end_time: Optional[datetime] = None
    duration: Optional[float] = None
    status: str = "success"
    error_type: Optional[str] = None
    error_reason: Optional[str] = None


@dataclass
class HttpRequest:
    """Record of an HTTP request for testing."""
    method: str
    endpoint: str
    status_code: int
    duration: float
    error_type: Optional[str] = None


@dataclass
class TraceSpan:
    """Record of a trace span for testing."""
    name: str
    attributes: Dict[str, Any] = field(default_factory=dict)
    kind: Optional[str] = None
    start_time: datetime = field(default_factory=datetime.now)
    end_time: Optional[datetime] = None
    status: Optional[str] = None
    status_description: Optional[str] = None
    events: List[Dict[str, Any]] = field(default_factory=list)
    exception: Optional[Exception] = None


class TestMetricsCollector(MetricsCollector):
    """Test implementation of MetricsCollector that records all metrics for assertions.
    
    Example:
        collector = TestMetricsCollector()
        with collector.track_tool_execution("create_fact"):
            # Execute tool
            pass
        
        assert len(collector.tool_executions) == 1
        assert collector.tool_executions[0].tool_name == "create_fact"
        assert collector.tool_executions[0].status == "success"
    """
    
    def __init__(self):
        """Initialize test metrics collector."""
        self.tool_executions: List[ToolExecution] = []
        self.http_requests: List[HttpRequest] = []
        self._active_tool_executions: Dict[str, ToolExecution] = {}
    
    @contextmanager
    def track_tool_execution(self, tool_name: str):
        """Track tool execution and record it for testing."""
        from datetime import datetime
        
        execution = ToolExecution(
            tool_name=tool_name,
            start_time=datetime.now()
        )
        self._active_tool_executions[tool_name] = execution
        
        try:
            yield
            execution.status = "success"
        except Exception as e:
            execution.status = "error"
            execution.error_type = type(e).__name__
            execution.error_reason = str(e)[:100]
            raise
        finally:
            execution.end_time = datetime.now()
            if execution.start_time and execution.end_time:
                execution.duration = (execution.end_time - execution.start_time).total_seconds()
            self.tool_executions.append(execution)
            self._active_tool_executions.pop(tool_name, None)
    
    def record_http_request(
        self,
        method: str,
        endpoint: str,
        status_code: int,
        duration: float,
        error_type: Optional[str] = None
    ):
        """Record HTTP request for testing."""
        request = HttpRequest(
            method=method,
            endpoint=endpoint,
            status_code=status_code,
            duration=duration,
            error_type=error_type
        )
        self.http_requests.append(request)
    
    def get_metrics(self) -> bytes:
        """Get metrics (returns empty for test collector)."""
        return b"# Test metrics collector\n"
    
    def get_metrics_content_type(self) -> str:
        """Get content type."""
        return "text/plain"
    
    def get_tool_execution_count(self, tool_name: Optional[str] = None) -> int:
        """Get count of tool executions.
        
        Args:
            tool_name: Optional tool name to filter by
            
        Returns:
            Count of executions
        """
        if tool_name:
            return sum(1 for e in self.tool_executions if e.tool_name == tool_name)
        return len(self.tool_executions)
    
    def get_success_count(self, tool_name: Optional[str] = None) -> int:
        """Get count of successful tool executions.
        
        Args:
            tool_name: Optional tool name to filter by
            
        Returns:
            Count of successful executions
        """
        executions = self.tool_executions
        if tool_name:
            executions = [e for e in executions if e.tool_name == tool_name]
        return sum(1 for e in executions if e.status == "success")
    
    def get_error_count(self, tool_name: Optional[str] = None) -> int:
        """Get count of failed tool executions.
        
        Args:
            tool_name: Optional tool name to filter by
            
        Returns:
            Count of failed executions
        """
        executions = self.tool_executions
        if tool_name:
            executions = [e for e in executions if e.tool_name == tool_name]
        return sum(1 for e in executions if e.status == "error")
    
    def get_average_duration(self, tool_name: Optional[str] = None) -> Optional[float]:
        """Get average execution duration.
        
        Args:
            tool_name: Optional tool name to filter by
            
        Returns:
            Average duration in seconds, or None if no executions
        """
        executions = self.tool_executions
        if tool_name:
            executions = [e for e in executions if e.tool_name == tool_name]
        
        durations = [e.duration for e in executions if e.duration is not None]
        if not durations:
            return None
        return sum(durations) / len(durations)


class TestTracingCollector(TracingCollector):
    """Test implementation of TracingCollector that records all spans for assertions.
    
    Example:
        collector = TestTracingCollector()
        with collector.trace_span("mcp.tool.create_fact", {"tool_name": "create_fact"}):
            # Execute tool
            pass
        
        assert len(collector.spans) == 1
        assert collector.spans[0].name == "mcp.tool.create_fact"
        assert collector.spans[0].attributes["tool_name"] == "create_fact"
    """
    
    def __init__(self):
        """Initialize test tracing collector."""
        self.spans: List[TraceSpan] = []
        self._active_spans: List[TraceSpan] = []
    
    @contextmanager
    def trace_span(
        self,
        name: str,
        attributes: Optional[Dict[str, Any]] = None,
        kind: Optional[str] = None
    ):
        """Create a trace span and record it for testing."""
        span = TraceSpan(
            name=name,
            attributes=attributes or {},
            kind=kind
        )
        self._active_spans.append(span)
        
        try:
            yield span
            span.status = "OK"
        except Exception as e:
            span.status = "ERROR"
            span.status_description = str(e)
            span.exception = e
            raise
        finally:
            span.end_time = datetime.now()
            self.spans.append(span)
            self._active_spans.pop()
    
    def add_span_attribute(self, key: str, value: Any) -> None:
        """Add attribute to current active span."""
        if self._active_spans:
            self._active_spans[-1].attributes[key] = value
    
    def add_span_event(self, name: str, attributes: Optional[Dict[str, Any]] = None) -> None:
        """Add event to current active span."""
        if self._active_spans:
            self._active_spans[-1].events.append({
                "name": name,
                "attributes": attributes or {}
            })
    
    def set_span_status(self, status_code: str, description: Optional[str] = None) -> None:
        """Set status of current active span."""
        if self._active_spans:
            self._active_spans[-1].status = status_code
            self._active_spans[-1].status_description = description
    
    def get_span_count(self, name: Optional[str] = None) -> int:
        """Get count of spans.
        
        Args:
            name: Optional span name to filter by
            
        Returns:
            Count of spans
        """
        if name:
            return sum(1 for s in self.spans if s.name == name)
        return len(self.spans)
    
    def get_spans_by_name(self, name: str) -> List[TraceSpan]:
        """Get all spans with a given name.
        
        Args:
            name: Span name to filter by
            
        Returns:
            List of matching spans
        """
        return [s for s in self.spans if s.name == name]
    
    def get_failed_spans(self) -> List[TraceSpan]:
        """Get all failed spans.
        
        Returns:
            List of spans with ERROR status
        """
        return [s for s in self.spans if s.status == "ERROR"]

