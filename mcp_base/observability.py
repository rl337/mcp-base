"""Observability abstractions for testability."""

from abc import ABC, abstractmethod
from typing import Optional, Dict, Any
from contextlib import contextmanager


class MetricsCollector(ABC):
    """Abstract interface for metrics collection.
    
    This allows injection of test implementations for asserting metrics in tests.
    """
    
    @abstractmethod
    @contextmanager
    def track_tool_execution(self, tool_name: str):
        """Track MCP tool execution metrics.
        
        Args:
            tool_name: Name of the tool being executed
            
        Yields:
            Context manager that tracks execution
        """
        pass
    
    @abstractmethod
    def record_http_request(
        self,
        method: str,
        endpoint: str,
        status_code: int,
        duration: float,
        error_type: Optional[str] = None
    ):
        """Record HTTP request metrics.
        
        Args:
            method: HTTP method
            endpoint: Endpoint path
            status_code: HTTP status code
            duration: Request duration in seconds
            error_type: Optional error type
        """
        pass
    
    @abstractmethod
    def get_metrics(self) -> bytes:
        """Get metrics in text format.
        
        Returns:
            Metrics as bytes
        """
        pass
    
    @abstractmethod
    def get_metrics_content_type(self) -> str:
        """Get content type for metrics response.
        
        Returns:
            Content type string
        """
        pass


class TracingCollector(ABC):
    """Abstract interface for distributed tracing.
    
    This allows injection of test implementations for asserting spans in tests.
    """
    
    @abstractmethod
    @contextmanager
    def trace_span(
        self,
        name: str,
        attributes: Optional[Dict[str, Any]] = None,
        kind: Optional[str] = None
    ):
        """Create a trace span.
        
        Args:
            name: Span name
            attributes: Optional span attributes
            kind: Optional span kind
            
        Yields:
            Span object
        """
        pass
    
    @abstractmethod
    def add_span_attribute(self, key: str, value: Any) -> None:
        """Add attribute to current span.
        
        Args:
            key: Attribute key
            value: Attribute value
        """
        pass
    
    @abstractmethod
    def add_span_event(self, name: str, attributes: Optional[Dict[str, Any]] = None) -> None:
        """Add event to current span.
        
        Args:
            name: Event name
            attributes: Optional event attributes
        """
        pass
    
    @abstractmethod
    def set_span_status(self, status_code: str, description: Optional[str] = None) -> None:
        """Set status of current span.
        
        Args:
            status_code: Status code (OK, ERROR)
            description: Optional status description
        """
        pass

