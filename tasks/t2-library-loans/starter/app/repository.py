"""In-memory repositories.

Storage is a process-local dict keyed by id. This keeps the sample service
dependency-free and deterministic for tests. To back it with a real database,
reimplement these classes behind the same method names — nothing above the
repository layer knows how rows are stored.
"""

from __future__ import annotations

from .models import Book, Member


class BookRepository:
    def __init__(self) -> None:
        self._items: dict[int, Book] = {}
        self._next_id = 1

    def add(self, book: Book) -> Book:
        book.id = self._next_id
        self._items[book.id] = book
        self._next_id += 1
        return book

    def get(self, book_id: int) -> Book | None:
        return self._items.get(book_id)

    def list(self, *, author: str | None = None, genre: str | None = None) -> list[Book]:
        items = list(self._items.values())
        if author is not None:
            items = [b for b in items if b.author == author]
        if genre is not None:
            items = [b for b in items if b.genre == genre]
        return items


class MemberRepository:
    def __init__(self) -> None:
        self._items: dict[int, Member] = {}
        self._next_id = 1

    def add(self, member: Member) -> Member:
        member.id = self._next_id
        self._items[member.id] = member
        self._next_id += 1
        return member

    def get(self, member_id: int) -> Member | None:
        return self._items.get(member_id)

    def list(self) -> list[Member]:
        return list(self._items.values())
