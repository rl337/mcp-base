"""Tests for observability (metrics and tracing) with test collectors."""

from typing import Any

import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient
from pyiv import Config, SingletonType, get_injector

from mcp_base import McpServerBase, McpToolHandler, TextContent
from mcp_base.metrics import set_metrics_collector
from mcp_base.test_observability import TestMetricsCollector, TestTracingCollector
from mcp_base.tracing import set_tracing_collector


class EchoHandlerImpl(McpToolHandler):
    """Echo handler for testing."""

    @property
    def tool_name(self) -> str:
        return "echo"

    @property
    def tool_schema(self) -> dict[str, Any]:
        return {
            "name": "echo",
            "description": "Echo a message",
            "inputSchema": {"type": "object", "properties": {"message": {"type": "string"}}},
        }

    async def handle(self, arguments: dict[str, Any], **kwargs) -> list[TextContent]:
        message = arguments.get("message", "")
        return [TextContent(type="text", text=f"Echo: {message}")]


class FailingHandlerImpl(McpToolHandler):
    """Handler that always fails for testing."""

    @property
    def tool_name(self) -> str:
        return "fail"

    @property
    def tool_schema(self) -> dict[str, Any]:
        return {"name": "fail", "description": "Always fails", "inputSchema": {"type": "object"}}

    async def handle(self, arguments: dict[str, Any], **kwargs) -> list[TextContent]:
        raise ValueError("Intentional failure")


class TestConfig(Config):
    """Test configuration."""

    def configure(self):
        self.register(McpToolHandler, EchoHandlerImpl, singleton_type=SingletonType.SINGLETON)


@pytest.fixture
def metrics_collector():
    """Create a test metrics collector."""
    collector = TestMetricsCollector()
    set_metrics_collector(collector)
    yield collector
    # Reset to default
    from mcp_base.metrics import PrometheusMetricsCollector

    set_metrics_collector(PrometheusMetricsCollector())


@pytest.fixture
def tracing_collector():
    """Create a test tracing collector."""
    collector = TestTracingCollector()
    set_tracing_collector(collector)
    yield collector
    # Reset to default
    from mcp_base.tracing import OpenTelemetryTracingCollector

    set_tracing_collector(OpenTelemetryTracingCollector())


@pytest.fixture
def app_with_observability(metrics_collector, tracing_collector):
    """Create FastAPI app with MCP server and test observability."""
    app = FastAPI()
    injector = get_injector(TestConfig)

    McpServerBase(
        app=app,
        tool_package="tests.test_observability",
        interface=McpToolHandler,
        injector=injector,
        base_path="/v1/mcp/tools",
        metrics_collector=metrics_collector,
        tracing_collector=tracing_collector,
    )

    return app, metrics_collector, tracing_collector


@pytest.fixture
def client(app_with_observability):
    """Create test client."""
    app, _, _ = app_with_observability
    return TestClient(app)


class TestMetrics:
    """Tests for metrics collection."""

    def test_tool_execution_metrics_success(self, client, metrics_collector):
        """Test that successful tool execution is tracked in metrics."""
        response = client.post("/v1/mcp/tools/echo", json={"arguments": {"message": "hello"}})

        assert response.status_code == 200

        # Check metrics
        assert metrics_collector.get_tool_execution_count("echo") == 1
        assert metrics_collector.get_success_count("echo") == 1
        assert metrics_collector.get_error_count("echo") == 0

        execution = metrics_collector.tool_executions[0]
        assert execution.tool_name == "echo"
        assert execution.status == "success"
        assert execution.duration is not None
        assert execution.duration > 0

    def test_tool_execution_metrics_error(self, app_with_observability):
        """Test that failed tool execution is tracked in metrics."""
        app, metrics_collector, _ = app_with_observability

        # Register failing handler
        from pyiv import Config, SingletonType, get_injector

        from mcp_base import McpToolHandler

        class FailingConfig(Config):
            def configure(self):
                self.register(
                    McpToolHandler, FailingHandlerImpl, singleton_type=SingletonType.SINGLETON
                )

        injector = get_injector(FailingConfig)
        McpServerBase(
            app=app,
            tool_package="tests",
            interface=McpToolHandler,
            injector=injector,
            base_path="/v1/mcp/tools/fail",
            handler_registry={"fail": FailingHandlerImpl},
            metrics_collector=metrics_collector,
        )

        client = TestClient(app)

        response = client.post("/v1/mcp/tools/fail/fail", json={"arguments": {}})

        assert response.status_code == 500

        # Check metrics
        assert metrics_collector.get_tool_execution_count("fail") == 1
        assert metrics_collector.get_success_count("fail") == 0
        assert metrics_collector.get_error_count("fail") == 1

        execution = metrics_collector.tool_executions[0]
        assert execution.status == "error"
        assert execution.error_type == "ValueError"
        assert "Intentional failure" in execution.error_reason

    def test_http_request_metrics(self, client, metrics_collector):
        """Test that HTTP requests are tracked in metrics."""
        response = client.get("/v1/mcp/tools")

        assert response.status_code == 200
        assert len(metrics_collector.http_requests) > 0

        request = metrics_collector.http_requests[-1]
        assert request.method == "GET"
        assert request.status_code == 200
        assert request.duration > 0

    def test_metrics_endpoint(self, client):
        """Test that metrics endpoint returns metrics."""
        response = client.get("/v1/mcp/tools/metrics")

        assert response.status_code == 200
        assert response.headers["content-type"].startswith("text/plain")


class TestTracing:
    """Tests for distributed tracing."""

    def test_tool_execution_creates_span(self, client, tracing_collector):
        """Test that tool execution creates a trace span."""
        response = client.post("/v1/mcp/tools/echo", json={"arguments": {"message": "hello"}})

        assert response.status_code == 200

        # Check that span was created
        spans = tracing_collector.get_spans_by_name("mcp.tool.echo")
        assert len(spans) == 1

        span = spans[0]
        assert span.name == "mcp.tool.echo"
        assert span.attributes["tool_name"] == "echo"
        assert span.status == "OK"
        assert span.end_time is not None

    def test_tool_execution_span_attributes(self, client, tracing_collector):
        """Test that span has correct attributes."""
        response = client.post("/v1/mcp/tools/echo", json={"arguments": {"message": "test"}})

        assert response.status_code == 200

        spans = tracing_collector.get_spans_by_name("mcp.tool.echo")
        assert len(spans) == 1

        span = spans[0]
        assert "tool_name" in span.attributes
        assert span.attributes["tool_name"] == "echo"

    def test_failed_execution_marks_span_error(self, app_with_observability):
        """Test that failed execution marks span as error."""
        app, _, tracing_collector = app_with_observability

        # Register failing handler
        from pyiv import Config, SingletonType, get_injector

        from mcp_base import McpToolHandler

        class FailingConfig(Config):
            def configure(self):
                self.register(
                    McpToolHandler, FailingHandlerImpl, singleton_type=SingletonType.SINGLETON
                )

        injector = get_injector(FailingConfig)
        McpServerBase(
            app=app,
            tool_package="tests",
            interface=McpToolHandler,
            injector=injector,
            base_path="/v1/mcp/tools/fail",
            handler_registry={"fail": FailingHandlerImpl},
            tracing_collector=tracing_collector,
        )

        client = TestClient(app)

        response = client.post("/v1/mcp/tools/fail/fail", json={"arguments": {}})

        assert response.status_code == 500

        # Check that span was marked as error
        spans = tracing_collector.get_spans_by_name("mcp.tool.fail")
        assert len(spans) == 1

        span = spans[0]
        assert span.status == "ERROR"
        assert span.status_description is not None

    def test_multiple_spans(self, client, tracing_collector):
        """Test that multiple executions create multiple spans."""
        # Execute tool multiple times
        for i in range(3):
            response = client.post(
                "/v1/mcp/tools/echo", json={"arguments": {"message": f"test{i}"}}
            )
            assert response.status_code == 200

        # Check that multiple spans were created
        spans = tracing_collector.get_spans_by_name("mcp.tool.echo")
        assert len(spans) == 3


class TestObservabilityIntegration:
    """Tests for observability integration."""

    def test_metrics_and_tracing_together(self, client, metrics_collector, tracing_collector):
        """Test that metrics and tracing work together."""
        response = client.post("/v1/mcp/tools/echo", json={"arguments": {"message": "hello"}})

        assert response.status_code == 200

        # Check both metrics and tracing
        assert metrics_collector.get_tool_execution_count("echo") == 1
        assert len(tracing_collector.get_spans_by_name("mcp.tool.echo")) == 1

    def test_observability_disabled(self):
        """Test that observability can be disabled."""
        app = FastAPI()
        injector = get_injector(TestConfig)

        McpServerBase(
            app=app,
            tool_package="tests",
            interface=McpToolHandler,
            injector=injector,
            base_path="/v1/mcp/tools",
            enable_observability=False,
        )

        client = TestClient(app)

        # Should still work, just without observability
        response = client.post("/v1/mcp/tools/echo", json={"arguments": {"message": "hello"}})

        assert response.status_code == 200
