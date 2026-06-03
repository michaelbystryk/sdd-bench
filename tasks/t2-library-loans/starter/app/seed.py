"""Seed data for local runs and tests."""

from __future__ import annotations

from typing import TYPE_CHECKING

from .models import Book, Member

if TYPE_CHECKING:
    from .database import Database


def seed(db: "Database") -> None:
    books = [
        Book(0, "The Pragmatic Programmer", "Hunt & Thomas", "tech", 3, 3),
        Book(0, "Clean Code", "Robert Martin", "tech", 2, 2),
        Book(0, "Dune", "Frank Herbert", "scifi", 4, 4),
        Book(0, "Neuromancer", "William Gibson", "scifi", 1, 1),
        Book(0, "The Hobbit", "J.R.R. Tolkien", "fantasy", 2, 2),
    ]
    for book in books:
        db.books.add(book)

    members = [
        Member(0, "Ada Lovelace", "ada@example.com"),
        Member(0, "Alan Turing", "alan@example.com"),
    ]
    for member in members:
        db.members.add(member)
