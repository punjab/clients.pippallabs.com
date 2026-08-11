# ADR-0003: Immutable ingestion with tenant-scoped idempotency

- Status: Accepted
- Date: 2026-08-10

## Context

Website clients retry requests, public traffic is untrusted, and every dashboard result must be traceable to source records.

## Decision

Map each public tracking key to one active website and tenant. Validate and size-limit JSON at the HTTP edge. Store accepted events immutably and enforce `(tenant_id, event_id)` uniqueness. Enforce `(tenant_id, idempotency_key)` uniqueness for lead submissions and return the original resource for a retry.

Create a contact, lead, initial history, and notification intent in one database transaction. Preserve raw supported attribution fields and use `unknown` rather than inferred values. Reject personal information in event metadata.

## Consequences

- Retries are safe and notification fan-out occurs once.
- Dashboard figures can reconcile to raw accepted records.
- Corrections are expressed as configuration or derived-query changes, not edits to event history.

