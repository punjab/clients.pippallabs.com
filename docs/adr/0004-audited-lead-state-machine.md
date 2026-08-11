# ADR-0004: Audited lead state machine

- Status: Accepted
- Date: 2026-08-10

## Context

Managers need a lightweight workflow whose reported outcomes remain trustworthy.

## Decision

Use the canonical states New, Contacted, Quoted, Won, Lost, and Spam. All state, assignment, follow-up, value, and note mutations go through one lead-workflow service and append a history entry with actor and timestamp. Lost requires a reason. Terminal states require an explicit reopen action before another transition.

## Consequences

- UI and API behavior share one transition policy.
- Support can reconstruct who changed a lead and why.
- Direct model updates to audited fields are prohibited outside ingestion and the workflow service.

