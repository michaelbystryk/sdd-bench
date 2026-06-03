"""Pydantic v2 API schemas.

Request bodies use ``*Create`` models; responses use ``*Read`` models. Keep the
request and response schemas separate even when they currently look similar —
they diverge as the API grows, and the split keeps write-only and read-only
fields from leaking across the boundary.
"""

from __future__ import annotations

from typing import Generic, TypeVar

from pydantic import BaseModel, ConfigDict, Field

ItemT = TypeVar("ItemT")


class Page(BaseModel, Generic[ItemT]):
    """Standard pagination envelope returned by every list endpoint."""

    items: list[ItemT]
    total: int
    limit: int
    offset: int


class BookCreate(BaseModel):
    title: str = Field(min_length=1)
    author: str = Field(min_length=1)
    genre: str = Field(min_length=1)
    total_copies: int = Field(ge=1)


class BookRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    title: str
    author: str
    genre: str
    total_copies: int
    available_copies: int


class MemberCreate(BaseModel):
    name: str = Field(min_length=1)
    email: str = Field(min_length=1)


class MemberRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    email: str
