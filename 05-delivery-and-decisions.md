# 5. Delivery and Decisions

## Delivery sequence

Each slice must work end to end before the next begins.

| Slice | Deliverable | Exit gate |
|---|---|---|
| 0. Definitions | Approved metrics, statuses, event names, pilot users, and privacy decisions | Product and pilot owner sign off |
| 1. Secure workspace | Tenant, website, location, membership, role, and public-key administration | Tenant-isolation tests pass |
| 2. First signal | Tracker sends page views and configured CTA clicks to storage | Live pilot event appears within 60 seconds |
| 3. First opportunity | Form sends one deduplicated lead, creates/links contact, and sends one email alert | Real test lead completes the flow |
| 4. First follow-up | Inbox supports assignment, status, note, and follow-up | Location manager completes a test workflow unaided |
| 5. First proof | Overview, locations, pages, and sources reconcile to raw records | Seeded and pilot reconciliation passes |
| 6. First report | Monthly summary shows activity, intent, leads, outcomes, and missing follow-up | Client reviews and understands report without explanation |
| 7. Pilot hardening | Monitoring, failure recovery, rate limits, deletion process, and support runbook | Two weeks with no severity-1 data or isolation incident |

## Pilot shape

- One design-partner tenant.
- Two to five locations.
- One website.
- Two client roles plus Pippal Labs admin.
- One high-value form, preferably catering.
- Order, call, location, coupon, and one configurable CTA.
- Four-week operational pilot followed by one monthly review.

## Go/no-go gates

Launch the pilot only when:

- Tenant isolation and role tests pass.
- A lead can be traced from submission to alert, follow-up, and outcome.
- Event and report totals reconcile.
- Invalid keys, duplicate submissions, and notification failures are handled visibly.
- Privacy notice, consent behavior, data retention, and deletion ownership are approved.

Move P1 work into the PRD only after:

- Lead capture reliability meets target for two consecutive weeks.
- At least 80% of valid leads are being actioned.
- Client stakeholders use the dashboard or report without Pippal Labs operating it for them.
- The pilot identifies a specific missing integration that changes a real decision.

## Open decisions for PRD

| Decision | Why it matters | Proposed default | Owner |
|---|---|---|---|
| First design partner and locations | Fixes real workflows and data volume | Pizza-chain pilot, 2–5 locations | Product |
| Dashboard identity | Affects copy, visual design, and domain | Pippal Labs-branded app | Product |
| Location resolution | Prevents misleading comparisons | Explicit form/page mapping, then tenant fallback | Product + Engineering |
| Meaningful client action | Defines activation and adoption | Lead update or report/dashboard review | Product |
| Sales outcome window | Required for outcome completeness | 30 days, adjusted after pilot | Client owner |
| Lead routing | Determines alert and ownership rules | Form/location mapping to one primary recipient | Client owner |
| Report delivery | Changes scope and email infrastructure | In-app for P0; email/PDF in P1 | Product |
| Privacy jurisdiction and retention | Determines consent and deletion behavior | Decide before implementation | Legal/Product |
| Hosting/auth/email vendors | Affects implementation, not product promise | Choose boring managed services | Engineering |

## PRD inputs still needed

- Named pilot stakeholders and their location access.
- Current lead volume and existing response process.
- Website/CMS and form technology.
- Exact CTA selectors or data attributes to track.
- Allowed domains and internal/bot traffic rules.
- Current monthly report, if one exists.
- Retention period and data deletion policy.
