"""Pagination helper shared by every list endpoint."""

from __future__ import annotations

from typing import Sequence, TypeVar

T = TypeVar("T")


def paginate(items: Sequence[T], *, limit: int, offset: int) -> tuple[list[T], int]:
    """Return ``(page_items, total)`` for the requested window."""
    total = len(items)
    return list(items[offset : offset + limit]), total
