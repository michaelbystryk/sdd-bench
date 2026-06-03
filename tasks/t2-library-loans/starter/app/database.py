"""Process-local datastore wiring + seed reset.

``db`` is the single shared instance the dependency providers in ``deps.py``
read from. Tests call ``reset_db()`` between cases for isolation.
"""

from __future__ import annotations

from .repository import BookRepository, MemberRepository


class Database:
    def __init__(self) -> None:
        self.books = BookRepository()
        self.members = MemberRepository()


db = Database()


def reset_db() -> None:
    """Reset every repository to a freshly-seeded state."""
    from .seed import seed

    db.books = BookRepository()
    db.members = MemberRepository()
    seed(db)
