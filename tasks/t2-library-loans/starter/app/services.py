"""Business logic.

Services raise domain ``AppError``s and never import FastAPI. Routers translate
the returned entities into API schemas. New behavior (e.g. loans) belongs in a
service of its own, following the same shape as the ones below.
"""

from __future__ import annotations

from .exceptions import NotFoundError
from .models import Book, Member
from .repository import BookRepository, MemberRepository
from .schemas import BookCreate, MemberCreate


class BookService:
    def __init__(self, repo: BookRepository) -> None:
        self.repo = repo

    def list_books(self, *, author: str | None = None, genre: str | None = None) -> list[Book]:
        return self.repo.list(author=author, genre=genre)

    def get_book(self, book_id: int) -> Book:
        book = self.repo.get(book_id)
        if book is None:
            raise NotFoundError(f"Book {book_id} not found")
        return book

    def create_book(self, data: BookCreate) -> Book:
        book = Book(
            id=0,
            title=data.title,
            author=data.author,
            genre=data.genre,
            total_copies=data.total_copies,
            available_copies=data.total_copies,
        )
        return self.repo.add(book)


class MemberService:
    def __init__(self, repo: MemberRepository) -> None:
        self.repo = repo

    def list_members(self) -> list[Member]:
        return self.repo.list()

    def get_member(self, member_id: int) -> Member:
        member = self.repo.get(member_id)
        if member is None:
            raise NotFoundError(f"Member {member_id} not found")
        return member

    def create_member(self, data: MemberCreate) -> Member:
        return self.repo.add(Member(id=0, name=data.name, email=data.email))
