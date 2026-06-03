import io
import uuid
from pathlib import Path

import pytest
from fastapi.testclient import TestClient

from app.main import app

SAMPLES = Path(__file__).resolve().parent.parent / "reference" / "sample_csvs"


@pytest.fixture
def client():
    return TestClient(app)


def upload(client, csv_path=None, *, content=None, filename="users.csv", content_type="text/csv"):
    if csv_path is not None:
        content = csv_path.read_bytes()
    files = {"file": (filename, io.BytesIO(content), content_type)}
    return client.post("/imports/users", files=files)


def test_happy_path_returns_200_with_full_envelope(client):
    r = upload(client, SAMPLES / "happy.csv")
    assert r.status_code == 200
    body = r.json()
    assert set(body.keys()) >= {"import_id", "total", "succeeded", "failed", "results"}
    uuid.UUID(body["import_id"])
    assert body["total"] == 5
    assert body["succeeded"] == 5
    assert body["failed"] == 0
    assert len(body["results"]) == 5
    for row in body["results"]:
        assert row["status"] == "success"
        assert row["data"] is not None


def test_partial_success_returns_200_with_per_row_results_in_order(client):
    r = upload(client, SAMPLES / "partial_success.csv")
    assert r.status_code == 200
    body = r.json()
    assert body["total"] == 5
    assert body["succeeded"] == 3
    assert body["failed"] == 2
    assert [row["status"] for row in body["results"]] == [
        "success", "error", "success", "error", "success",
    ]
    bob = body["results"][1]
    assert bob["row_number"] == 2
    assert any(e["field"] == "age" and e["code"] == "invalid_type" for e in bob["errors"])
    david = body["results"][3]
    assert david["row_number"] == 4
    assert any(e["field"] == "age" and e["code"] == "out_of_range" for e in david["errors"])


def test_single_row_type_mismatch_is_row_level_not_whole_file(client):
    r = upload(client, SAMPLES / "type_mismatch_age.csv")
    assert r.status_code == 200
    body = r.json()
    assert body["total"] == 1
    assert body["succeeded"] == 0
    assert body["failed"] == 1
    row = body["results"][0]
    assert row["status"] == "error"
    assert row["data"] is None
    assert any(e["field"] == "age" and e["code"] == "invalid_type" for e in row["errors"])


def test_malformed_csv_returns_400(client):
    r = upload(client, SAMPLES / "malformed_quotes.csv")
    assert r.status_code == 400
    body = r.json()
    assert body["error"]["code"] == "malformed_csv"


def test_missing_required_column_returns_400_with_details(client):
    r = upload(client, SAMPLES / "missing_email_column.csv")
    assert r.status_code == 400
    body = r.json()
    assert body["error"]["code"] == "missing_required_columns"
    assert "email" in body["error"]["details"]["missing_columns"]


def test_empty_file_returns_400(client):
    r = upload(client, SAMPLES / "empty.csv")
    assert r.status_code == 400
    body = r.json()
    assert body["error"]["code"] == "empty_file"


def test_file_too_large_returns_413(client, tmp_path):
    # Build a CSV just over 10 MB.
    big = tmp_path / "huge.csv"
    with big.open("wb") as f:
        f.write(b"email,name,age,signup_date,country\n")
        row = b"alice@example.com,Alice Smith,30,2024-01-15,US\n"
        target = 11 * 1024 * 1024
        written = 0
        while written < target:
            f.write(row)
            written += len(row)
    r = upload(client, big)
    assert r.status_code == 413
    body = r.json()
    assert body["error"]["code"] == "file_too_large"


def test_embedded_newlines_in_quoted_field_preserved(client):
    r = upload(client, SAMPLES / "embedded_newlines.csv")
    assert r.status_code == 200
    body = r.json()
    assert body["total"] == 2
    assert body["succeeded"] == 2
    alice = body["results"][0]
    assert "\n" in alice["data"]["name"]


def test_utf8_bom_stripped_from_header(client):
    r = upload(client, SAMPLES / "utf8_bom.csv")
    assert r.status_code == 200
    body = r.json()
    assert body["total"] == 1
    assert body["succeeded"] == 1
    assert body["results"][0]["data"]["email"] == "alice@example.com"


def test_crlf_line_endings_supported(client):
    r = upload(client, SAMPLES / "crlf.csv")
    assert r.status_code == 200
    body = r.json()
    assert body["total"] == 3
    assert body["succeeded"] == 3


def test_mixed_line_endings_supported(client):
    r = upload(client, SAMPLES / "mixed_endings.csv")
    assert r.status_code == 200
    body = r.json()
    assert body["total"] == 3
    assert body["succeeded"] == 3


def test_unicode_in_name_field_preserved(client):
    r = upload(client, SAMPLES / "unicode_names.csv")
    assert r.status_code == 200
    body = r.json()
    assert body["total"] == 3
    assert body["succeeded"] == 3
    names = [row["data"]["name"] for row in body["results"]]
    assert "Álvaro García" in names
    assert "日本太郎" in names
    assert "Müller Karl" in names


def test_get_import_returns_same_body_as_post(client):
    post_r = upload(client, SAMPLES / "happy.csv")
    assert post_r.status_code == 200
    import_id = post_r.json()["import_id"]

    get_r = client.get(f"/imports/{import_id}")
    assert get_r.status_code == 200
    assert get_r.json() == post_r.json()


def test_get_import_unknown_id_returns_404(client):
    unknown = str(uuid.uuid4())
    r = client.get(f"/imports/{unknown}")
    assert r.status_code == 404
    body = r.json()
    assert body["error"]["code"] == "import_not_found"
