-- Storage contract: SQLite schema for the Strength Training Workout App
-- Applied by migrateDbIfNeeded() in src/db/schema.ts via PRAGMA user_version.
-- Engine: expo-sqlite (SDK 54). All weights are integers in pounds (lb).

-- ── DATABASE_VERSION = 1 ────────────────────────────────────────────────────
PRAGMA journal_mode = 'wal';
PRAGMA foreign_keys = ON;

-- Single-row app settings (id is always 1).
CREATE TABLE IF NOT EXISTS settings (
  id                INTEGER PRIMARY KEY NOT NULL CHECK (id = 1),
  active_program_id TEXT    NOT NULL,
  days_per_week     INTEGER NOT NULL CHECK (days_per_week IN (3, 4)),
  unit              TEXT    NOT NULL DEFAULT 'lb',
  onboarded         INTEGER NOT NULL DEFAULT 0 CHECK (onboarded IN (0, 1)),
  created_at        TEXT    NOT NULL,
  updated_at        TEXT    NOT NULL
);

-- One row per lift (squat, bench, ohp, deadlift). Working state is shared
-- across programs so program switches never lose progress.
CREATE TABLE IF NOT EXISTS lift_state (
  lift_id              TEXT    PRIMARY KEY NOT NULL,
  starting_weight      INTEGER NOT NULL,
  current_weight       INTEGER NOT NULL,
  consecutive_failures INTEGER NOT NULL DEFAULT 0,
  updated_at           TEXT    NOT NULL
);

-- Training sessions in the A/B rotation.
CREATE TABLE IF NOT EXISTS sessions (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  program_id   TEXT    NOT NULL,
  day_key      TEXT    NOT NULL CHECK (day_key IN ('A', 'B')),
  status       TEXT    NOT NULL CHECK (status IN ('in_progress', 'completed')),
  started_at   TEXT    NOT NULL,
  completed_at TEXT
);
CREATE INDEX IF NOT EXISTS idx_sessions_status       ON sessions (status);
CREATE INDEX IF NOT EXISTS idx_sessions_completed_at ON sessions (completed_at);

-- One row per prescribed set; logging/editing upserts actual_* + completed.
CREATE TABLE IF NOT EXISTS logged_sets (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  session_id    INTEGER NOT NULL REFERENCES sessions (id) ON DELETE CASCADE,
  lift_id       TEXT    NOT NULL,
  set_index     INTEGER NOT NULL,
  target_weight INTEGER NOT NULL,
  target_reps   INTEGER NOT NULL,
  actual_weight INTEGER,
  actual_reps   INTEGER,
  completed     INTEGER NOT NULL DEFAULT 0 CHECK (completed IN (0, 1)),
  logged_at     TEXT,
  UNIQUE (session_id, lift_id, set_index)
);
CREATE INDEX IF NOT EXISTS idx_logged_sets_session ON logged_sets (session_id);
CREATE INDEX IF NOT EXISTS idx_logged_sets_lift    ON logged_sets (lift_id, logged_at);

-- At most one in-progress session is enforced in application code (sessionRepo)
-- before INSERTing a new session.
