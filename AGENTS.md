# Agent Guidelines for mcp-base

This document provides guidelines for AI agents working on the mcp-base project.

## Project Overview

mcp-base is a dependency-injected, reflection-based framework for building MCP (Model Context Protocol) services. It dramatically reduces boilerplate code by automatically discovering and routing tool handlers.

## Versioning

**IMPORTANT**: This project uses **automatic semantic versioning** via GitHub Actions.

### How It Works

- **Regular commits to main**: Automatically bumps patch version (0.1.0 → 0.1.1)
- **Merge commits to main**: Automatically bumps minor version (0.1.0 → 0.2.0)
- **Major versions**: Must be bumped manually using `poetry version major`

### What This Means for Agents

1. **Do NOT manually update versions** in `pyproject.toml` or `mcp_base/__init__.py` unless:
   - You're bumping a major version (breaking changes)
   - You're fixing a version that got out of sync

2. **Version bumps are automatic**: When you commit to main (or merge a PR), the version will be automatically bumped by the GitHub Actions workflow.

3. **Version sync**: The workflow updates both:
   - `pyproject.toml` (the `version = "X.Y.Z"` field)
   - `mcp_base/__init__.py` (the `__version__ = "X.Y.Z"` field)

4. **Skip CI**: Version bump commits include `[skip ci]` to prevent infinite loops.

### Manual Version Bumping

If you need to manually bump a major version:

```bash
poetry version major
# Then manually update mcp_base/__init__.py to match
```

## Development Workflow

1. Create feature branches from `main`
2. Make changes and commit
3. Open PR to `main`
4. When merged, version is automatically bumped:
   - PR merge → minor version bump
   - Direct commit → patch version bump

## Testing

- Run tests: `poetry run pytest`
- Run with coverage: `poetry run pytest --cov=mcp_base`
- All tests must pass before merging

## Code Style

- Use `black` for formatting (line length 100)
- Use `ruff` for linting
- Use `mypy` for type checking
- All checks run automatically in CI

## Key Files

- `pyproject.toml`: Project configuration and dependencies
- `mcp_base/__init__.py`: Package exports and version
- `.github/workflows/version-bump.yml`: Automatic version bumping workflow
- `.github/workflows/ci.yml`: CI/CD pipeline

## Dependencies

- `pyiv`: Dependency injection framework (uses reflection-based-discovery branch)
- `fastapi`: Web framework
- `pydantic`: Data validation
- `prometheus-client`: Metrics
- `opentelemetry-*`: Distributed tracing

