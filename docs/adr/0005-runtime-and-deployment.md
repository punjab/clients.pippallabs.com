# ADR-0005: PostgreSQL-backed jobs and managed pilot deployment

- Status: Accepted
- Date: 2026-08-10

## Context

The MVP needs lead alerts and report generation but not the operational burden of Redis or Kubernetes.

## Decision

Use Active Job with Solid Queue and an outbox-like Notification record. A job performs delivery and records every attempt/result. Use letter-opener in local development and SMTP in production.

For the pilot, target Render: one Rails web service, one Solid Queue worker, and managed PostgreSQL in the same region, defined by infrastructure configuration in the repository. Revisit Kamal on a dedicated host when cost or control outweighs managed operational simplicity.

## Consequences

- PostgreSQL is the only stateful service during the pilot.
- Notification failures stay visible and retryable.
- The deployment can later move because the application ships as a standard container.

