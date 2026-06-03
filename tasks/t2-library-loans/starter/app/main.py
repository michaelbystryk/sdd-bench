"""Library API — a small FastAPI service for a lending library.

Run:  ``uvicorn app.main:app --reload``
Test: ``pytest``

Architecture (read before extending):
    routers/    thin HTTP layer; depend on services via deps.py
    services    business logic; raise AppError, never import FastAPI
    repository  storage (in-memory dicts); database.py holds the shared instance
    schemas     Pydantic v2 request/response models (*Create / *Read)
    models      internal dataclass entities
    exceptions  AppError hierarchy
    errors      the JSON error-envelope handler
"""

from __future__ import annotations

from fastapi import FastAPI

from .database import reset_db
from .errors import register_error_handlers
from .routers import books, members


def create_app() -> FastAPI:
    app = FastAPI(title="Library API", version="0.1.0")
    register_error_handlers(app)
    app.include_router(books.router)
    app.include_router(members.router)
    return app


reset_db()
app = create_app()
