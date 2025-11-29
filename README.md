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
from mcp_base import IMcpToolHandler, validate_request, serialize_model
from mcp.types import TextContent
from typing import Any
import json

class CreateFactHandler(IMcpToolHandler):
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
from mcp_base import IMcpToolHandler

class MyConfig(Config):
    def configure(self):
        # Register handlers manually (or use ReflectionConfig when available)
        self.register(
            IMcpToolHandler,
            CreateFactHandler,
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
    interface=IMcpToolHandler,
    injector=injector,
    base_path="/v1/mcp/tools"
)
```

That's it! Routes are automatically created:
- `GET /v1/mcp/tools` - List all tools
- `GET /v1/mcp/tools/{tool_name}/schema` - Get tool schema
- `POST /v1/mcp/tools/{tool_name}/sse` - Execute tool (SSE)
- `POST /v1/mcp/tools/{tool_name}/jsonrpc` - Execute tool (JSON-RPC)

## Installation

```bash
pip install mcp-base
```

Or with Poetry:

```bash
poetry add mcp-base
```

## License

MIT License

