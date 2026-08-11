# Pippal Labs Light CRM — Domain Context

## Purpose

The product connects website demand signals to human follow-up and sales outcomes for multi-location Pippal Labs clients.

## Canonical language

| Term | Meaning |
| --- | --- |
| Tenant | A client workspace and the primary data-isolation boundary. |
| Location | A tenant-owned physical or operational unit used for access, routing, and reporting. |
| Website | An allowed web property with a revocable public tracking key. |
| Visit | One distinct accepted session containing at least one page view. |
| Intent | A high-value anonymous action such as an order, call, coupon, location, or configured CTA click. It is not revenue. |
| Contact | An identified person, deduplicated within a tenant by normalized email and/or phone. |
| Lead | One revenue opportunity. Repeated submissions may belong to one contact but remain separate leads. |
| Lead history | An append-only record of a workflow change, actor, and time. |
| Outcome | A terminal sales result: Won or Lost. Spam is terminal but not a sales outcome. |
| Follow-up | The next scheduled action for a lead. It is overdue when its time is past and the lead is active. |
| Event | An immutable accepted website activity record. |
| Attribution | Raw landing page, page URL, referrer, UTM, session, device, and location facts retained with an event or lead. Missing facts are `unknown`. |
| Monthly summary | A versioned, reproducible tenant/location report for a calendar month. |

## Invariants

- Every tenant-owned record carries `tenant_id`; location-owned records carry `location_id` where applicable.
- Private scope comes from the authenticated membership, never a requested tenant identifier alone.
- Public keys identify websites; they are credentials and are never internal tenant IDs.
- Anonymous events never create contacts.
- Event IDs and lead idempotency keys are unique within a tenant.
- Raw events and lead histories are append-only.
- Lost leads require a reason. Won, Lost, and Spam are terminal until explicitly reopened.
- Order clicks are reported as order intent, never revenue.

