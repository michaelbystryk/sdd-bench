## ADDED Requirements

### Requirement: CSV Upload Endpoint

The system SHALL expose `POST /imports/users` that accepts a `multipart/form-data` request with a single `file` part containing a CSV. On any outcome where the file is structurally valid (whether or not individual rows pass validation), the endpoint SHALL respond with HTTP 200 and a JSON body containing `import_id` (UUID), `total`, `succeeded`, `failed`, and `results` (per-row entries in input order).

#### Scenario: Happy path returns full envelope

- **WHEN** a client uploads a CSV whose header and every data row are valid
- **THEN** the response status is 200
- **AND** the body contains `import_id`, `total`, `succeeded`, `failed`, and `results`
- **AND** `import_id` is a valid UUID
- **AND** `total` equals the number of data rows
- **AND** `succeeded` equals `total` and `failed` is `0`
- **AND** every entry in `results` has `status: "success"` and a non-null `data` field

#### Scenario: Partial success returns 200 with per-row results in input order

- **WHEN** a client uploads a CSV where some rows fail row-level validation and others succeed
- **THEN** the response status is 200
- **AND** `results` entries appear in the same order as the input rows
- **AND** each successful entry has `status: "success"`, non-null `data`, and `row_number` matching its input position (1-based, header excluded)
- **AND** each failing entry has `status: "error"`, null `data`, and a non-empty `errors` array

#### Scenario: Row-level type mismatch does not fail the whole file

- **WHEN** a client uploads a CSV whose only data row has an unparseable value (e.g. `age` is not an integer)
- **THEN** the response status is 200
- **AND** `total` is `1`, `succeeded` is `0`, `failed` is `1`
- **AND** the single result has `status: "error"`, null `data`, and includes a `FieldError` with the offending `field` and a `code` from the closed set

### Requirement: Row-Level Validation Rules

The system SHALL validate each data row independently against the `UserRow` schema and SHALL report failures as `FieldError` objects whose `code` is drawn from the closed set `{missing, invalid_type, out_of_range, invalid_format}`.

#### Scenario: Missing required value

- **WHEN** a required column has an empty string in a data row
- **THEN** the row's status is `"error"`
- **AND** `errors` contains an entry with `field` set to that column name and `code: "missing"`

#### Scenario: Unparseable integer

- **WHEN** the `age` cell contains a value that cannot be parsed as an integer
- **THEN** the row's status is `"error"`
- **AND** `errors` contains an entry with `field: "age"` and `code: "invalid_type"`

#### Scenario: Numeric value out of range

- **WHEN** the `age` cell parses as an integer but is less than `0` or greater than `150`
- **THEN** the row's status is `"error"`
- **AND** `errors` contains an entry with `field: "age"` and `code: "out_of_range"`

#### Scenario: Value fails declared format

- **WHEN** a cell does not match its declared format (e.g. `email` is not a valid email address, `signup_date` is not an ISO 8601 date, `country` is not one of `US, CA, UK, AU, DE, FR, JP`)
- **THEN** the row's status is `"error"`
- **AND** `errors` contains an entry with the offending `field` and `code: "invalid_format"`

#### Scenario: Successful row carries typed data

- **WHEN** every cell in a data row passes validation
- **THEN** the row's status is `"success"`
- **AND** `data` is a non-null object with `email`, `name`, `age` (integer), `signup_date` (string in `YYYY-MM-DD` form), and `country` populated from the input
- **AND** `errors` is null or absent

### Requirement: Whole-File Failure Modes

The system SHALL return HTTP 400 with a stable `error.code` when the upload is not processable as a whole, using the standard error envelope `{ "error": { "code": ..., "message": ..., "details": ... } }`. Whole-file failures are distinct from row-level errors and SHALL NOT be mixed into a 200 response.

#### Scenario: Malformed CSV

- **WHEN** the uploaded file is not parseable as CSV (e.g. an unterminated quoted field)
- **THEN** the response status is 400
- **AND** `error.code` is `"malformed_csv"`

#### Scenario: Missing required columns in header

- **WHEN** the header row does not include one or more of `email, name, age, signup_date, country`
- **THEN** the response status is 400
- **AND** `error.code` is `"missing_required_columns"`
- **AND** `error.details.missing_columns` is an array containing each missing column name

#### Scenario: Empty file or header-only file

- **WHEN** the uploaded file contains zero data rows (it is fully empty, or contains only a header)
- **THEN** the response status is 400
- **AND** `error.code` is `"empty_file"`

### Requirement: Upload Size Limit

The system SHALL reject uploads larger than 10,485,760 bytes (10 MB) with HTTP 413 and SHALL do so without fully buffering or parsing the oversized payload as a CSV.

#### Scenario: File exceeds 10 MB

- **WHEN** the multipart `file` part is larger than 10,485,760 bytes
- **THEN** the response status is 413
- **AND** `error.code` is `"file_too_large"`

### Requirement: Encoding And Line-Ending Handling

The system SHALL parse uploads as UTF-8, SHALL strip a leading UTF-8 BOM (`U+FEFF`) before reading the header, SHALL preserve embedded newlines inside quoted fields, and SHALL accept LF, CRLF, and mixed line endings.

#### Scenario: UTF-8 BOM in header

- **WHEN** the file begins with a UTF-8 BOM followed by the header row
- **THEN** the BOM is stripped before parsing
- **AND** the first header column is recognized by its plain name (e.g. `email`, not `﻿email`)

#### Scenario: Embedded newline in quoted field

- **WHEN** a quoted field contains a literal newline character
- **THEN** the newline is preserved verbatim in the row's `data` value for that field
- **AND** the row is counted as a single data row

#### Scenario: CRLF line endings

- **WHEN** the file uses CRLF (`\r\n`) line endings throughout
- **THEN** every row is parsed correctly with no `\r` artifacts in any cell

#### Scenario: Mixed line endings

- **WHEN** the file contains a mix of LF and CRLF line endings between rows
- **THEN** every row is parsed correctly

#### Scenario: Unicode in a text field

- **WHEN** a row contains non-ASCII characters in a text field such as `name`
- **THEN** the characters are preserved verbatim in the response `data` payload

### Requirement: Import Retrieval Endpoint

The system SHALL expose `GET /imports/{import_id}` that, when given the `import_id` returned by a prior successful POST, responds with HTTP 200 and the exact same JSON body that POST returned. Unknown ids SHALL produce HTTP 404 with `error.code = "import_not_found"`.

#### Scenario: Retrieve previously created import

- **WHEN** a client GETs `/imports/{import_id}` using an `import_id` from a previous POST response
- **THEN** the response status is 200
- **AND** the body equals the body returned by the original POST

#### Scenario: Unknown import id

- **WHEN** a client GETs `/imports/{import_id}` with an id that was not produced by any prior POST in this process
- **THEN** the response status is 404
- **AND** `error.code` is `"import_not_found"`
