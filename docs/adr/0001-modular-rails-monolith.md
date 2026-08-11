# ADR-0001: Modular Rails monolith with PostgreSQL

- Status: Accepted
- Date: 2026-08-10

## Context

The MVP needs transactional lead capture, tenant-scoped workflows, background notifications, analytics, and a polished dashboard. The team must operate one pilot reliably without a service fleet.

## Decision

Build one Ruby on Rails 8.1 application on Ruby 3.4 with PostgreSQL, Hotwire, server-rendered HTML, and a small amount of Stimulus. Organize code by explicit domain services and query objects so ingestion or reporting can later move behind the same public contracts.

Use PostgreSQL for application records, raw events, queue records, and cached aggregates at MVP scale. Avoid Node and a separate SPA build unless a demonstrated interaction needs it.

## Consequences

- Transactions can atomically create a contact, lead, history entry, and notification intent.
- One language, deployment, and observability surface lowers pilot risk.
- Server-rendered UI is fast to build and accessible by default.
- Analytics load must be measured; a warehouse remains a future extraction, not an MVP dependency.

