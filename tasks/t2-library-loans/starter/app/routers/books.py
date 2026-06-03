from __future__ import annotations

from fastapi import APIRouter, Depends, Query

from ..config import DEFAULT_PAGE_LIMIT, MAX_PAGE_LIMIT
from ..deps import get_book_service
from ..pagination import paginate
from ..schemas import BookCreate, BookRead, Page
from ..services import BookService

router = APIRouter(prefix="/books", tags=["books"])


@router.get("", response_model=Page[BookRead])
def list_books(
    author: str | None = None,
    genre: str | None = None,
    limit: int = Query(DEFAULT_PAGE_LIMIT, ge=1, le=MAX_PAGE_LIMIT),
    offset: int = Query(0, ge=0),
    service: BookService = Depends(get_book_service),
) -> Page[BookRead]:
    books = service.list_books(author=author, genre=genre)
    page_items, total = paginate(books, limit=limit, offset=offset)
    return Page[BookRead](
        items=[BookRead.model_validate(b) for b in page_items],
        total=total,
        limit=limit,
        offset=offset,
    )


@router.get("/{book_id}", response_model=BookRead)
def get_book(book_id: int, service: BookService = Depends(get_book_service)) -> BookRead:
    return BookRead.model_validate(service.get_book(book_id))


@router.post("", response_model=BookRead, status_code=201)
def create_book(data: BookCreate, service: BookService = Depends(get_book_service)) -> BookRead:
    return BookRead.model_validate(service.create_book(data))
