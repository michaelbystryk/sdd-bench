# Library API

A small lending-library service built with FastAPI + Pydantic v2.

## Run

```bash
pip install -e ".[dev]"
uvicorn app.main:app --reload
```

## Test

```bash
pytest
```

## Layout

```
app/      application package (FastAPI app, routers, services, storage)
tests/    pytest suite (FastAPI TestClient)
```
