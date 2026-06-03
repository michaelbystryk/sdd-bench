"""FastAPI dependency providers.

Routers depend on services; services own the business logic and talk to
repositories. Routers never touch repositories directly — they go through a
service obtained here via ``Depends(...)``.
"""

from __future__ import annotations

from .database import db
from .services import BookService, MemberService


def get_book_service() -> BookService:
    return BookService(db.books)


def get_member_service() -> MemberService:
    return MemberService(db.members)
