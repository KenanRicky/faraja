-- Faraja database initialisation.
-- Runs once, on the first startup of an empty data volume.
-- Mirrors the SQLModel definitions in backend/app/models so the API's
-- create_all() finds the schema already in place.

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'projectstatus') THEN
        CREATE TYPE projectstatus AS ENUM (
            'planned', 'in_progress', 'delayed', 'completed', 'cancelled'
        );
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'milestonestatus') THEN
        CREATE TYPE milestonestatus AS ENUM (
            'not_started', 'in_progress', 'done', 'blocked'
        );
    END IF;
END
$$;

CREATE TABLE IF NOT EXISTS project (
    id                  SERIAL PRIMARY KEY,
    name                VARCHAR NOT NULL,
    description         VARCHAR NOT NULL,
    county              VARCHAR NOT NULL,
    constituency        VARCHAR,
    budget_allocated    DOUBLE PRECISION NOT NULL CHECK (budget_allocated >= 0),
    budget_spent        DOUBLE PRECISION NOT NULL DEFAULT 0 CHECK (budget_spent >= 0),
    start_date          DATE NOT NULL,
    target_end_date     DATE NOT NULL,
    status              projectstatus NOT NULL DEFAULT 'planned',
    implementing_agency VARCHAR NOT NULL,
    lead_politician     VARCHAR NOT NULL,
    created_at          TIMESTAMP NOT NULL DEFAULT (NOW() AT TIME ZONE 'utc'),
    updated_at          TIMESTAMP NOT NULL DEFAULT (NOW() AT TIME ZONE 'utc')
);

CREATE INDEX IF NOT EXISTS ix_project_name ON project (name);

CREATE TABLE IF NOT EXISTS milestone (
    id             SERIAL PRIMARY KEY,
    project_id     INTEGER NOT NULL REFERENCES project (id),
    title          VARCHAR NOT NULL,
    detail         VARCHAR,
    due_date       DATE NOT NULL,
    completed_date DATE,
    status         milestonestatus NOT NULL DEFAULT 'not_started',
    created_at     TIMESTAMP NOT NULL DEFAULT (NOW() AT TIME ZONE 'utc')
);

CREATE INDEX IF NOT EXISTS ix_milestone_project_id ON milestone (project_id);
