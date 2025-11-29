# MCP Services Analysis

## Service Comparison

### 1. bucketofacts-mcp-service (Most Mature)

**Architecture:**
- Uses `mcp.server.Server` with stdio transport
- Function-based handlers in `mcp/handlers.py`
- Pydantic request models for validation (`mcp/request_models.py`)
- Separate tool schemas module (`mcp/tool_schemas.py`)
- Comprehensive error handling with exception mapping
- DI via `ServiceFactory` pattern
- Handler registry dictionary (`HANDLERS` dict)
- Serialization helpers (`mcp/helpers.py`)

**Key Strengths:**
- ✅ Pydantic validation for all requests
- ✅ Comprehensive error handling (maps service exceptions to MCP errors)
- ✅ Clean separation of concerns (handlers, schemas, models, helpers)
- ✅ DI integration with ServiceFactory
- ✅ Database session management via context managers
- ✅ Well-structured handler registry

**Pattern:**
```python
# Handler function signature
async def handle_create_fact(
    arguments: dict[str, Any],
    db_manager: Any,
    service_factory: Optional[ServiceFactory] = None
) -> list[TextContent]:
    request = CreateFactRequest(**arguments)  # Pydantic validation
    factory = _get_service_factory(service_factory)
    
    with db_manager.session() as session:
        # Use factory to create services
        fact_repo = factory.create_fact_repository(session)
        # ... handler logic
        return [TextContent(type="text", text=json.dumps(result))]
```

### 2. docomatic-mcp-service

**Architecture:**
- Uses `mcp.server.Server` with stdio transport
- Function-based handlers in `mcp/tool_handlers.py`
- Separate tool schemas module (returns dict, not list)
- Serializers module for model serialization
- Direct service instantiation (no DI)
- Simpler error handling

**Key Strengths:**
- ✅ Clean handler structure
- ✅ Serialization helpers
- ✅ Simple and straightforward

**Weaknesses:**
- ❌ No request validation (raw dict arguments)
- ❌ No DI (direct service instantiation)
- ❌ Less comprehensive error handling

### 3. todorama-mcp-service

**Architecture:**
- FastAPI-based (not stdio MCP)
- Class-based API facade (`MCPTodoAPI`)
- Delegates to specialized handler modules
- More complex structure

**Key Characteristics:**
- Different transport (HTTP vs stdio)
- Class-based approach
- Handler modules organized by domain

## Recommended Patterns for mcp-base

### 1. Request Validation (from bucketofacts)
- Use Pydantic models for all tool arguments
- Automatic validation and type conversion
- Better error messages

### 2. Schema Separation (from both)
- Separate module for tool schemas
- Can be generated from Pydantic models or defined manually

### 3. Serialization Helpers (from both)
- Separate serializers/helpers module
- Consistent model-to-dict conversion
- Handles datetime, nested objects, etc.

### 4. Error Handling (from bucketofacts)
- Map service exceptions to MCP error codes
- Comprehensive exception hierarchy
- Consistent error responses

### 5. Handler Registry (from bucketofacts)
- Dictionary mapping tool names to handlers
- Easy to extend and test
- Can be auto-generated from reflection

### 6. DI Integration (from bucketofacts)
- ServiceFactory pattern for creating services
- Per-request service creation with session
- Clean dependency management

### 7. Database Session Management
- Context managers for sessions
- Automatic cleanup
- Transaction handling

## Recommended Base Framework Structure

```
mcp_base/
├── handler.py          # McpToolHandler interface
├── server.py           # McpServerBase class
├── request_models.py   # Base request model utilities
├── serializers.py      # Base serialization helpers
└── exceptions.py       # MCP exception mapping utilities
```

## Handler Pattern

```python
class CreateFactHandlerImpl(McpToolHandler):
    """Handler for create_fact tool."""
    
    def __init__(self, service_factory: ServiceFactory):
        self.service_factory = service_factory
    
    @property
    def tool_name(self) -> str:
        return "create_fact"
    
    @property
    def tool_schema(self) -> dict[str, Any]:
        return {
            "name": "create_fact",
            "description": "Create a new fact",
            "inputSchema": CreateFactRequest.model_json_schema()
        }
    
    async def handle(
        self,
        arguments: dict[str, Any],
        db_session: Any  # Injected by framework
    ) -> list[TextContent]:
        # Validate request
        request = CreateFactRequest(**arguments)
        
        # Use service factory to create services
        fact_repo = self.service_factory.create_fact_repository(db_session)
        
        # Execute logic
        fact = fact_repo.create(...)
        
        # Serialize and return
        result = serialize_fact(fact)
        return [TextContent(type="text", text=json.dumps(result))]
```

## Key Improvements for mcp-base

1. **Add Pydantic integration**: Support for request models
2. **Add serialization utilities**: Base serializers module
3. **Add exception mapping**: Utilities for converting exceptions to MCP errors
4. **Add database session injection**: Automatic session management
5. **Add schema generation**: Generate schemas from Pydantic models
6. **Support both stdio and HTTP**: Abstract transport layer

