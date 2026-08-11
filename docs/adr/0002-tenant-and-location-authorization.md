# ADR-0002: Explicit tenant and location authorization

- Status: Accepted
- Date: 2026-08-10

## Context

Tenant isolation is non-negotiable, while agency administrators need cross-tenant operations and location managers need restricted views.

## Decision

Authenticate dashboard users with secure server sessions. Authorize every private controller through a current membership. Tenant queries begin from that membership's tenant; location managers receive an additional allowed-location scope. Agency administrators choose a tenant through an explicit operator context rather than sending trusted tenant IDs from the browser.

Back the application checks with foreign keys, composite uniqueness constraints, and tenant-leading indexes. Defer PostgreSQL row-level security until operating requirements justify the extra migration and connection-context complexity.

## Consequences

- Authorization remains visible and testable at HTTP boundaries.
- Background jobs must receive and re-check tenant-scoped identifiers.
- Application mistakes are not independently contained by RLS, so cross-tenant request tests are release gates.

