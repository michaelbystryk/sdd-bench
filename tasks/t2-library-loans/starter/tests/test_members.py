from __future__ import annotations


def test_list_members_returns_envelope(client):
    resp = client.get("/members")
    assert resp.status_code == 200
    body = resp.json()
    assert body["total"] == 2
    assert len(body["items"]) == 2


def test_get_member(client):
    resp = client.get("/members/1")
    assert resp.status_code == 200
    assert resp.json()["name"] == "Ada Lovelace"


def test_get_missing_member_returns_error_envelope(client):
    resp = client.get("/members/999")
    assert resp.status_code == 404
    assert resp.json() == {"error": {"code": "not_found", "message": "Member 999 not found"}}


def test_create_member(client):
    resp = client.post("/members", json={"name": "Grace Hopper", "email": "grace@example.com"})
    assert resp.status_code == 201
    assert resp.json()["id"] > 0
