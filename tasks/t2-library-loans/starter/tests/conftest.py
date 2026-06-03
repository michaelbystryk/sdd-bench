from __future__ import annotations

import pytest
from fastapi.testclient import TestClient

from app.database import reset_db
from app.main import app


@pytest.fixture(autouse=True)
def _reset_state():
    """Reseed the datastore before each test so cases are independent."""
    reset_db()
    yield


@pytest.fixture
def client() -> TestClient:
    return TestClient(app)
