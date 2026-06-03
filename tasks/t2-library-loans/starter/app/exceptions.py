"""Domain exceptions.

Every error that should surface to the client as a structured JSON error is an
``AppError`` (or subclass). The handler in ``errors.py`` maps these to the
``{"error": {"code", "message"}}`` envelope. Do not raise FastAPI's
``HTTPException`` directly in services or routers — raise an ``AppError`` so the
error envelope stays consistent across the API.
"""

from __future__ import annotations


class AppError(Exception):
    """Base class for all client-facing errors."""

    status_code: int = 500
    code: str = "internal_error"

    def __init__(self, message: str, *, code: str | None = None) -> None:
        self.message = message
        if code is not None:
            self.code = code
        super().__init__(message)


class NotFoundError(AppError):
    status_code = 404
    code = "not_found"


class ConflictError(AppError):
    status_code = 409
    code = "conflict"
