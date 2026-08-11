# Pippal Labs Light CRM — MVP Definition Pack

Status: PRD input  
Working name: Pippal Labs Light CRM  
Design partner: a multi-location pizza chain

## Product in one sentence

A central, multi-tenant lead and activity dashboard that helps Pippal Labs clients see which website activity creates revenue opportunities and follow those opportunities to an outcome.

## Document sequence

1. [Product definition](./01-product-definition.md) — problem, users, promise, and boundaries.
2. [MVP scope and requirements](./02-mvp-scope-and-requirements.md) — release scope with acceptance criteria.
3. [Measurement plan](./03-measurement-plan.md) — product success metrics and event definitions.
4. [System and data contract](./04-system-and-data-contract.md) — architecture, tenancy, entities, and APIs.
5. [Delivery and decisions](./05-delivery-and-decisions.md) — implementation sequence, pilot gates, and unresolved choices.

## Decisions already made

- One central multi-tenant SaaS application and database.
- Lightweight tracking and form integrations on client websites.
- Dashboard-first and API-capable; not an API product.
- Public tracking keys map to internal tenants; internal IDs are not exposed as credentials.
- PostgreSQL stores application and event data for MVP.
- Anonymous behavior remains separate from contacts until the person identifies themselves.
- The MVP is CRM-lite: leads, contacts, ownership, notes, follow-up, and outcome.

## PRD exit criteria

This pack is ready to become a PRD when the open decisions in document 5 have owners and due dates, and the proposed success targets have been accepted or replaced.
