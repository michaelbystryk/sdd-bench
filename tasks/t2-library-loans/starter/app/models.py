"""Internal domain entities (storage layer).

These are distinct from the Pydantic API schemas in ``schemas.py``: entities
never cross the HTTP boundary directly. Routers translate between entities and
schemas so the wire format can evolve independently of storage.
"""

from __future__ import annotations

from dataclasses import dataclass


@dataclass
class Book:
    id: int
    title: str
    author: str
    genre: str
    total_copies: int
    available_copies: int


@dataclass
class Member:
    id: int
    name: str
    email: str
