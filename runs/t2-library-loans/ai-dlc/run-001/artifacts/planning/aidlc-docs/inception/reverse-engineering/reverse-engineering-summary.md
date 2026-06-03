# Reverse Engineering Summary (Minimal Depth)

> Minimal depth chosen: the codebase is small (~15 source files) and was read in full.
> This captures the conventions a new feature must match.

## Business Overview
A lending-library service exposing two resources today:
- **Books** — catalog entries with `total_copies` / `available_copies`.
- **Members** — library patrons.

Business transactions implemented: create/list/get books (with author & genre
filters and pagination), create/list/get members. No lending transactions exist
yet — `app/config.py` already reserves `MAX_ACTIVE_LOANS = 3`, anticipating them.

## Architecture (layered)

```
HTTP request
  -> routers/        thin HTTP layer; translate entities <-> schemas; depend on services via deps.py
  -> services        business logic; raise AppError; never import FastAPI
  -> repository      storage (in-memory dicts keyed by id); database.py holds the shared instance
  -> models          internal dataclass entities (Book, Member)
schemas               Pydantic v2 request (*Create) / response (*Read) models
exceptions            AppError hierarchy (NotFoundError=404, ConflictError=409)
errors                registers the JSON error-envelope handler
```

## Conventions (must be matched by new features)
- **Routers** are thin: `APIRouter(prefix=..., tags=[...])`, depend on a service via
  `Depends(get_*_service)`, and convert entities with `SchemaRead.model_validate(...)`.
- **Error envelope**: all client-facing errors are `AppError` subclasses; the handler
  in `errors.py` renders `{"error": {"code", "message"}}`. Never raise `HTTPException`.
- **Pagination**: every list endpoint returns the generic `Page[ItemT]`
  (`items`, `total`, `limit`, `offset`) using `pagination.paginate(...)`, with
  `limit`/`offset` `Query` params bounded by `DEFAULT_PAGE_LIMIT` / `MAX_PAGE_LIMIT`.
- **Schemas**: separate `*Create` (request) and `*Read` (response, `from_attributes=True`).
- **Entities**: plain `@dataclass` in `models.py`; created with `id=0` then assigned by the repo.
- **Storage**: per-repository `dict[int, Entity]` + integer `_next_id`; `database.Database`
  owns one instance per repo; `reset_db()` reseeds for test isolation.
- **Dependencies**: routers → services → repositories. Routers never touch repositories directly.

## Technology Stack
- Python ≥ 3.11, FastAPI ≥ 0.110, Pydantic v2 ≥ 2.6, Uvicorn, httpx (TestClient), pytest (dev).
- Build: setuptools via `pyproject.toml`. Packages: `app`, `app.routers`.

## Test Conventions
- `tests/conftest.py` provides an autouse `reset_db()` fixture and a `TestClient` `client` fixture.
- Tests drive the API end-to-end via `TestClient`; each test creates its own data.
- Error assertions check `resp.json()["error"]["code"]`.
