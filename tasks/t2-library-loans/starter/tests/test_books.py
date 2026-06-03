from __future__ import annotations


def test_list_books_returns_pagination_envelope(client):
    resp = client.get("/books")
    assert resp.status_code == 200
    body = resp.json()
    assert set(body) == {"items", "total", "limit", "offset"}
    assert body["total"] == 5
    assert body["offset"] == 0
    assert len(body["items"]) == 5


def test_list_books_respects_limit(client):
    resp = client.get("/books", params={"limit": 2})
    body = resp.json()
    assert body["limit"] == 2
    assert len(body["items"]) == 2
    assert body["total"] == 5


def test_list_books_filters_by_genre(client):
    resp = client.get("/books", params={"genre": "scifi"})
    body = resp.json()
    assert body["total"] == 2
    assert {b["title"] for b in body["items"]} == {"Dune", "Neuromancer"}


def test_get_book_returns_book(client):
    resp = client.get("/books/1")
    assert resp.status_code == 200
    assert resp.json()["title"] == "The Pragmatic Programmer"


def test_get_missing_book_returns_error_envelope(client):
    resp = client.get("/books/999")
    assert resp.status_code == 404
    assert resp.json() == {"error": {"code": "not_found", "message": "Book 999 not found"}}


def test_create_book_sets_available_to_total(client):
    resp = client.post(
        "/books",
        json={"title": "New Book", "author": "Someone", "genre": "tech", "total_copies": 4},
    )
    assert resp.status_code == 201
    body = resp.json()
    assert body["available_copies"] == 4
    assert body["id"] > 0


def test_create_book_rejects_zero_copies(client):
    resp = client.post(
        "/books",
        json={"title": "Bad", "author": "X", "genre": "tech", "total_copies": 0},
    )
    assert resp.status_code == 422
