"""Target tests for the three loan endpoints to be implemented.

These currently fail — the ``/loans`` endpoints don't exist yet. Making them
pass (without breaking the existing book/member tests, and while matching the
conventions in ``app/``) is the task.

Each test creates its own books/members via the API so cases are independent
of seed data and of one another.
"""

from __future__ import annotations


def _make_book(client, *, copies=1, title="Book", author="Author", genre="tech"):
    resp = client.post(
        "/books",
        json={"title": title, "author": author, "genre": genre, "total_copies": copies},
    )
    assert resp.status_code == 201
    return resp.json()["id"]


def _make_member(client, *, name="Member", email="member@example.com"):
    resp = client.post("/members", json={"name": name, "email": email})
    assert resp.status_code == 201
    return resp.json()["id"]


# --- POST /loans (checkout) ------------------------------------------------


def test_checkout_creates_active_loan(client):
    book_id = _make_book(client, copies=2)
    member_id = _make_member(client)

    resp = client.post("/loans", json={"book_id": book_id, "member_id": member_id})
    assert resp.status_code == 201
    body = resp.json()
    assert body["book_id"] == book_id
    assert body["member_id"] == member_id
    assert body["status"] == "active"
    assert body["id"] > 0


def test_checkout_decrements_available_copies(client):
    book_id = _make_book(client, copies=2)
    member_id = _make_member(client)

    client.post("/loans", json={"book_id": book_id, "member_id": member_id})

    book = client.get(f"/books/{book_id}").json()
    assert book["available_copies"] == 1
    assert book["total_copies"] == 2


def test_checkout_unknown_book_returns_not_found(client):
    member_id = _make_member(client)
    resp = client.post("/loans", json={"book_id": 999999, "member_id": member_id})
    assert resp.status_code == 404
    assert resp.json()["error"]["code"] == "not_found"


def test_checkout_unknown_member_returns_not_found(client):
    book_id = _make_book(client, copies=1)
    resp = client.post("/loans", json={"book_id": book_id, "member_id": 999999})
    assert resp.status_code == 404
    assert resp.json()["error"]["code"] == "not_found"


def test_checkout_with_no_copies_available_conflicts(client):
    book_id = _make_book(client, copies=1)
    m1 = _make_member(client, email="m1@example.com")
    m2 = _make_member(client, email="m2@example.com")

    first = client.post("/loans", json={"book_id": book_id, "member_id": m1})
    assert first.status_code == 201

    second = client.post("/loans", json={"book_id": book_id, "member_id": m2})
    assert second.status_code == 409
    assert second.json()["error"]["code"] == "no_copies_available"


def test_checkout_respects_member_loan_limit(client):
    # MAX_ACTIVE_LOANS is 3; the fourth concurrent checkout must be rejected.
    member_id = _make_member(client)
    book_ids = [_make_book(client, copies=1, title=f"B{i}") for i in range(4)]

    for book_id in book_ids[:3]:
        resp = client.post("/loans", json={"book_id": book_id, "member_id": member_id})
        assert resp.status_code == 201

    over = client.post("/loans", json={"book_id": book_ids[3], "member_id": member_id})
    assert over.status_code == 409
    assert over.json()["error"]["code"] == "loan_limit_exceeded"


# --- POST /loans/{id}/return -----------------------------------------------


def test_return_marks_loan_returned_and_restocks(client):
    book_id = _make_book(client, copies=1)
    member_id = _make_member(client)
    loan = client.post("/loans", json={"book_id": book_id, "member_id": member_id}).json()

    resp = client.post(f"/loans/{loan['id']}/return")
    assert resp.status_code == 200
    body = resp.json()
    assert body["status"] == "returned"
    assert body["returned_at"] is not None

    book = client.get(f"/books/{book_id}").json()
    assert book["available_copies"] == 1


def test_return_unknown_loan_returns_not_found(client):
    resp = client.post("/loans/999999/return")
    assert resp.status_code == 404
    assert resp.json()["error"]["code"] == "not_found"


def test_double_return_conflicts(client):
    book_id = _make_book(client, copies=1)
    member_id = _make_member(client)
    loan = client.post("/loans", json={"book_id": book_id, "member_id": member_id}).json()

    client.post(f"/loans/{loan['id']}/return")
    second = client.post(f"/loans/{loan['id']}/return")
    assert second.status_code == 409
    assert second.json()["error"]["code"] == "already_returned"


# --- GET /members/{id}/loans -----------------------------------------------


def test_member_loans_lists_with_envelope_and_status_filter(client):
    member_id = _make_member(client)
    b1 = _make_book(client, copies=1, title="One")
    b2 = _make_book(client, copies=1, title="Two")

    loan1 = client.post("/loans", json={"book_id": b1, "member_id": member_id}).json()
    client.post("/loans", json={"book_id": b2, "member_id": member_id})
    client.post(f"/loans/{loan1['id']}/return")

    all_loans = client.get(f"/members/{member_id}/loans")
    assert all_loans.status_code == 200
    body = all_loans.json()
    assert set(body) == {"items", "total", "limit", "offset"}
    assert body["total"] == 2

    active = client.get(f"/members/{member_id}/loans", params={"status": "active"})
    assert active.json()["total"] == 1

    returned = client.get(f"/members/{member_id}/loans", params={"status": "returned"})
    assert returned.json()["total"] == 1
