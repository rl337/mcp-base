# MCP Base Framework

A dependency-injected, reflection-based framework for building MCP (Model Context Protocol) services that dramatically reduces boilerplate code by automatically discovering and routing tool handlers.

## Features

- **Automatic Handler Discovery**: Uses pyiv reflection to discover handler classes in packages
- **FastAPI Integration**: Automatic route generation for MCP tools
- **Dependency Injection**: Full pyiv DI support for handlers
- **Singleton Handlers**: Per-injector singleton handlers for performance
- **Type-Safe**: Full type hints and Pydantic validation
- **Request Validation**: Utilities for Pydantic model validation
- **Exception Mapping**: Convert service exceptions to MCP errors
- **Serialization Helpers**: Base utilities for model serialization
- **Schema Generation**: Generate JSON schemas from Pydantic models

## Quick Start

### 1. Define Request Model (Optional but Recommended)

```python
from pydantic import BaseModel, Field
from mcp_base import get_schema_from_model

class CreateFactRequest(BaseModel):
    """Request model for creating a fact."""
    subject: str = Field(..., description="Entity identifier")
    predicate: str = Field(..., description="Relationship type")
    object: str = Field(..., description="Target entity or value")
```

### 2. Define Handler

```python
from mcp_base import McpToolHandler, validate_request, serialize_model
from mcp.types import TextContent
from typing import Any
import json

class CreateFactHandlerImpl(McpToolHandler):
    """Handler for create_fact tool."""
    
    def __init__(self, fact_service: FactService):
        self.fact_service = fact_service
    
    @property
    def tool_name(self) -> str:
        return "create_fact"
    
    @property
    def tool_schema(self) -> dict[str, Any]:
        return {
            "name": "create_fact",
            "description": "Create a new fact",
            "inputSchema": get_schema_from_model(CreateFactRequest)
        }
    
    async def handle(
        self,
        arguments: dict[str, Any],
        db_session: Any  # Injected by framework
    ) -> list[TextContent]:
        # Validate request
        request = validate_request(CreateFactRequest, arguments)
        
        # Execute logic
        fact = self.fact_service.create_fact(
            subject=request.subject,
            predicate=request.predicate,
            object=request.object,
            session=db_session
        )
        
        # Serialize and return
        result = serialize_model(fact)
        return [TextContent(type="text", text=json.dumps(result, indent=2))]
```

### 2. Configure DI

```python
from pyiv import Config, get_injector, SingletonType
from mcp_base import McpToolHandler

class MyConfig(Config):
    def configure(self):
        # Register handlers manually (or use ReflectionConfig when available)
        self.register(
            McpToolHandler,
            CreateFactHandlerImpl,
            singleton_type=SingletonType.SINGLETON
        )
```

### 3. Initialize MCP Server

```python
from fastapi import FastAPI
from mcp_base import McpServerBase
from pyiv import get_injector

app = FastAPI()
injector = get_injector(MyConfig)

# Initialize MCP base server
mcp_server = McpServerBase(
    app=app,
    tool_package="my_service.mcp.handlers",
    interface=McpToolHandler,
    injector=injector,
    base_path="/v1/mcp/tools"
)
```

That's it! Routes are automatically created:
- `GET /v1/mcp/tools` - List all tools
- `GET /v1/mcp/tools/{tool_name}/schema` - Get tool schema
- `POST /v1/mcp/tools/{tool_name}/sse` - Execute tool (SSE)
- `POST /v1/mcp/tools/{tool_name}/jsonrpc` - Execute tool (JSON-RPC)

## Advanced Usage

### Exception Mapping

```python
from mcp_base import ExceptionMapper, McpErrorCode
from my_service.exceptions import NotFoundError, ValidationError

mapper = ExceptionMapper()
mapper.register(NotFoundError, McpErrorCode.NOT_FOUND)
mapper.register(ValidationError, McpErrorCode.INVALID_PARAMS)

try:
    # Service call
except Exception as e:
    raise mapper.to_mcp_error(e)
```

### Serialization

```python
from mcp_base import serialize_model

# Serialize SQLAlchemy model
fact_dict = serialize_model(fact)

# Handles:
# - Datetime objects (ISO format)
# - UUID objects (string)
# - Nested objects (recursive)
# - Metadata fields (meta -> metadata)
```

## Installation

```bash
pip install mcp-base
```

Or with Poetry:

```bash
poetry add mcp-base
```

## Observability

The framework includes comprehensive observability with Prometheus metrics and OpenTelemetry tracing.

### Metrics

Automatic metrics collection for:
- Tool execution count, duration, success/error rates
- Error types and reasons
- HTTP request metrics
- Active request counts

Metrics are exposed at `/v1/mcp/tools/metrics` for Prometheus scraping.

### Tracing

Automatic distributed tracing with:
- Span creation for each tool execution
- Span attributes (tool_name, arguments)
- Error status tracking
- Deep propagation support

### Testing Observability

Use test collectors to assert metrics and spans in tests:

```python
from mcp_base import TestMetricsCollector, TestTracingCollector
from mcp_base import McpServerBase

# Create test collectors
metrics = TestMetricsCollector()
tracing = TestTracingCollector()

# Initialize server with test collectors
mcp_server = McpServerBase(
    app=app,
    tool_package="my_service.handlers",
    interface=McpToolHandler,
    injector=injector,
    metrics_collector=metrics,
    tracing_collector=tracing
)

# Execute tool
response = client.post("/v1/mcp/tools/echo", json={"arguments": {"message": "hello"}})

# Assert metrics
assert metrics.get_tool_execution_count("echo") == 1
assert metrics.get_success_count("echo") == 1
assert metrics.get_average_duration("echo") > 0

# Assert tracing
spans = tracing.get_spans_by_name("mcp.tool.echo")
assert len(spans) == 1
assert spans[0].attributes["tool_name"] == "echo"
assert spans[0].status == "OK"
```

### Type Hints for Tracing

Handlers should use `trace_span` from `mcp_base.tracing`:

```python
from mcp_base.tracing import trace_span

async def handle(self, arguments: dict[str, Any], **kwargs) -> list[TextContent]:
    with trace_span(f"mcp.tool.{self.tool_name}", {"tool_name": self.tool_name}):
        # Handler implementation
        ...
```

The type hints in `McpToolHandler.handle()` guide agents to implement tracing spans.

### Handler Validation

Handlers can be validated to ensure they implement the interface correctly:

```python
handler = CreateFactHandlerImpl()
handler.validate()  # Raises ValueError if invalid
```

The validation checks:
- `tool_name` returns a non-empty string
- `tool_schema` returns a valid dict with required fields (name, description, inputSchema)
- `tool_name` matches `tool_schema['name']`

## License

MIT License

