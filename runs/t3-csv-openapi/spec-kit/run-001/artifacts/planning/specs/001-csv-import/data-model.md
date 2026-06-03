# Phase 1 Data Model: CSV User Import Service

Single Pydantic v2 module (`app/schemas.py`). No database — see `research.md` §R5. All entities are in-memory request/response shapes.

---

## `UserRow`

A single validated user record. Mirrors `UserRow` in `reference/openapi.yaml`.

| Field         | Type                                         | Constraint                                       | Source of constraint              |
|---------------|----------------------------------------------|--------------------------------------------------|------------------------------------|
| `email`       | `EmailStr` (Pydantic)                        | Syntactically valid email                        | OpenAPI `format: email`            |
| `name`        | `str`                                        | `min_length=1`, `max_length=200`                 | OpenAPI                            |
| `age`         | `int`                                        | `ge=0`, `le=150`                                 | OpenAPI                            |
| `signup_date` | `datetime.date`                              | Parses from `YYYY-MM-DD` (ISO 8601)              | OpenAPI `format: date`             |
| `country`     | `Literal["US","CA","UK","AU","DE","FR","JP"]` | Exactly one of these                            | OpenAPI enum                       |

**Serialization**: `signup_date` is serialized back to `YYYY-MM-DD` (Pydantic's default for `date`). `email` and `country` round-trip as plain strings. The pinned test `test_get_import_returns_same_body_as_post` asserts byte-equal POST/GET payloads, so the persisted shape **is** the serialized shape — no normalization that would re-write fields after the fact.

---

## `FieldError`

One field-level validation failure on a single row.

| Field     | Type                                                                  | Notes                                                |
|-----------|-----------------------------------------------------------------------|------------------------------------------------------|
| `field`   | `str`                                                                 | The CSV column name, e.g., `"age"`. Lowercase, snake. |
| `code`    | `Literal["missing","invalid_type","out_of_range","invalid_format"]`   | Stable machine-readable code. See mapping below.     |
| `message` | `str`                                                                 | Human-readable summary. Not asserted by tests; pick a clear phrasing. |

**Pydantic → `code` mapping** (single source of truth for the validator):

| Pydantic v2 error `type`                                  | `code`             | Notes |
|------------------------------------------------------------|---------------------|-------|
| `missing`                                                  | `missing`           | required field absent |
| `string_too_short` on a required field with empty value    | `missing`           | empty `""` for `email`/`name`/`signup_date`/`country` → `missing` (see preprocessing rule below) |
| `int_parsing`, `int_type`                                  | `invalid_type`      | `age` non-numeric |
| `greater_than_equal`, `less_than_equal`                    | `out_of_range`      | `age` outside `[0, 150]` |
| `value_error` from `EmailStr` (Pydantic email-validator)   | `invalid_format`    | malformed email |
| `date_parsing`, `date_from_datetime_parsing`               | `invalid_format`    | bad `signup_date` shape |
| `literal_error`                                            | `invalid_format`    | unknown `country` |
| `string_too_long`                                          | `out_of_range`      | `name` > 200 chars |

**Preprocessing rule**: Before calling `UserRow.model_validate(...)`, the validator inspects each required field in the raw dict and, if the value is the empty string `""` or missing entirely, records a `FieldError(field, code="missing", ...)` and removes that key from the dict. This avoids `email=""` being reported as `invalid_format` ("not a valid email") instead of the contract-correct `missing`. Any remaining Pydantic errors are appended after the preprocessing-derived missing errors. (See `validator.py` task in `tasks.md`.)

**Special case for `age`**: empty `""` → `missing`. Non-numeric → `invalid_type` (let Pydantic's `int_parsing` surface this). Out-of-range integer → `out_of_range`.

---

## `RowResult`

The outcome for one input row.

| Field        | Type                                       | When `status == "success"` | When `status == "error"` |
|--------------|--------------------------------------------|-----------------------------|---------------------------|
| `row_number` | `int` (`ge=1`)                              | required                    | required                  |
| `status`     | `Literal["success","error"]`                | `"success"`                 | `"error"`                 |
| `data`       | `UserRow | None`                            | populated                   | `None` (key must be present and explicitly null) |
| `errors`     | `list[FieldError] | None`                   | `None` (key must be present and explicitly null) | non-empty list |

**Why both keys are always emitted**: see `research.md` §R10.

---

## `ImportResult`

The full POST response and the cached payload returned by GET.

| Field        | Type                            | Notes                                                                 |
|--------------|---------------------------------|-----------------------------------------------------------------------|
| `import_id`  | `uuid.UUID`                     | Generated once per successful upload. Serialized as canonical UUID string. |
| `total`      | `int` (`ge=0`)                  | Count of data rows processed (excludes header).                       |
| `succeeded`  | `int` (`ge=0`)                  | Count of `results` with `status == "success"`. Invariant: `succeeded + failed == total`. |
| `failed`     | `int` (`ge=0`)                  | Count of `results` with `status == "error"`.                          |
| `results`    | `list[RowResult]`               | In input order. Length equals `total`.                                |

**Caching invariant**: `repository.put(import_id, model)` stores the model; `repository.get(import_id)` returns the same model; serialization is deterministic so POST and GET produce equal JSON bodies (validated by `test_get_import_returns_same_body_as_post`).

---

## `ErrorEnvelope` / `Error`

The single non-2xx response shape used by every error path.

```text
ErrorResponse = { "error": Error }
Error         = { "code": str, "message": str, "details": dict | None }
```

| Code                          | HTTP status | `details`                                            | Trigger                                                                 |
|-------------------------------|-------------|------------------------------------------------------|--------------------------------------------------------------------------|
| `malformed_csv`               | 400         | `null`                                               | `csv.Error` during parsing (e.g., unmatched quote).                      |
| `missing_required_columns`    | 400         | `{ "missing_columns": [str, ...] }`                  | Header row lacks one or more of `email`, `name`, `age`, `signup_date`, `country`. |
| `empty_file`                  | 400         | `null`                                               | Zero data rows (fully empty or header-only).                             |
| `too_many_rows`               | 400         | `{ "max_rows": 100000 }`                             | More than 100,000 data rows (see research §R6).                          |
| `file_too_large`              | 413         | `{ "max_bytes": 10485760 }`                          | Upload exceeds 10 MB; detected mid-stream (see research §R1).            |
| `import_not_found`            | 404         | `null`                                               | `GET /imports/{id}` with an id not in the store.                         |

`details` is omitted from the JSON output (or set to `null`) when there is no structured payload; the spec says `details` is `nullable: true`.

---

## Persistence Layer (in-memory)

```text
repository._store: dict[uuid.UUID, ImportResult]
repository.put(import_id, model) -> None
repository.get(import_id) -> ImportResult | None
```

- Module-level singleton dict (see `research.md` §R5, §R11).
- No eviction, no TTL, no locking.
- Lifetime = process lifetime.

---

## State Transitions

There are no multi-step lifecycles. A single POST request takes the file through:

1. **Receive** → 2. **Size-guard** → 3. **Decode + BOM strip** → 4. **Parse header** → 5. **Parse rows** → 6. **Validate each row** → 7. **Assemble `ImportResult`** → 8. **Persist** → 9. **Respond**.

Whole-file failures short-circuit at steps 2, 3, 4, or 5 with an `ErrorEnvelope`. Row failures collect at step 6 and continue to step 7. No row failure ever short-circuits the request.

GET is a single dict lookup → 200 with the cached `ImportResult` or 404 with `import_not_found`.
