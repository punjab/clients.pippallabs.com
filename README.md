# Pippal Labs Light CRM

A multi-tenant, location-aware lead and activity dashboard that connects website demand signals to follow-up and sales outcomes.

The application is a Rails 8.1 modular monolith using PostgreSQL, Hotwire, Tailwind CSS, Solid Queue, and Solid Cache. Product definitions remain in the numbered Markdown files at the repository root; architecture decisions are recorded in [`docs/adr/`](docs/adr/).

## Run locally

Requirements:

- Ruby 3.4.9
- Docker Desktop

Install, start PostgreSQL, migrate, and load the demo workspace:

```sh
bin/setup --skip-server
bin/dev
```

Open <http://localhost:3000> and sign in with:

```text
agency@pippallabs.test
pippal-demo-2026
```

Other demo roles use the same password:

- `owner@northstar.test` — client owner
- `manager@northstar.test` — Downtown-only location manager
- `viewer@northstar.test` — read-only viewer

The local PostgreSQL container listens on port `5433`. Stop it with `docker compose stop`; data remains in the named Docker volume.

## What is implemented

- Agency-managed tenants, locations, websites, tracking-key rotation, users, roles, workspace switching, and location scope.
- Signed server sessions with tenant-scoped private queries and cross-tenant integration tests.
- Idempotent `POST /v1/events` and `POST /v1/leads` ingestion with validation, payload/rate limits, safe metadata, key hashing, and retry semantics.
- Contact resolution by normalized email/phone while preserving separate lead opportunities.
- Lead assignment, status state machine, follow-up, value, notes, explicit reopen, and append-only actor history.
- Durable notification intent plus asynchronous email delivery attempts and visible failures.
- Reconciled overview, location, page/source, and versioned monthly report views.
- Cookie-free browser tracker with session-scoped retry queue at [`public/tracker.js`](public/tracker.js).
- Single-PostgreSQL Solid Queue and Solid Cache runtime, Docker image, and Render blueprint.

## Public API examples

Use the demo key `pk_demo_northstar_local` only for local development.

```sh
curl http://localhost:3000/v1/events \
  -H 'Content-Type: application/json' \
  -d '{
    "tracking_key":"pk_demo_northstar_local",
    "event_id":"evt-local-1",
    "event_type":"page_view",
    "occurred_at":"2026-08-10T19:00:00Z",
    "session_id":"visit-local-1",
    "page_url":"https://northstar-pizza.test/menu"
  }'
```

See [`docs/integration-guide.md`](docs/integration-guide.md) for tracker markup and server-side lead capture.

## Verification

```sh
bin/rails test
bin/rubocop
bundle exec brakeman --quiet --no-pager --exit-on-warn --exit-on-error
bin/importmap audit
bundle exec bundler-audit check --update
bin/rails zeitwerk:check
```

The implementation suite covers tenant/location isolation, public idempotency, contact and alert deduplication, audited workflow transitions, report reconciliation, UI rendering, security validation, and scheduled report generation.

## Deployment recommendation

`render.yaml` defines the recommended pilot topology:

- one Rails web service;
- one Solid Queue worker;
- one managed PostgreSQL database;
- TLS, health checks, Docker builds, and environment-managed SMTP credentials.

No cloud resources have been created. Before pilot deployment, approve the privacy jurisdiction, retention/deletion policy, cookie/consent posture, client domain, and email provider credentials. These are launch gates, not software defaults.

## Documentation

- [`docs/implementation-report.html`](docs/implementation-report.html) — standalone delivery report
- [`CONTEXT.md`](CONTEXT.md) — canonical domain language and invariants
- [`docs/decision-log.md`](docs/decision-log.md) — chronological decisions
- [`docs/adr/`](docs/adr/) — durable architecture decisions
- [`docs/integration-guide.md`](docs/integration-guide.md) — website and form integration
- [`00-read-me.md`](00-read-me.md) through [`05-delivery-and-decisions.md`](05-delivery-and-decisions.md) — product definition pack
