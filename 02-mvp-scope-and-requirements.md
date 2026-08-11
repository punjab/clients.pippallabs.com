# 2. MVP Scope and Requirements

Priority key: P0 is required for pilot launch. P1 follows only after the pilot gates pass.

## P0 capabilities

| ID | Capability | Requirement | Measurable acceptance criterion |
|---|---|---|---|
| F1 | Tenant foundation | Pippal Labs can create a tenant, locations, websites, tracking keys, users, and roles. | An operator configures a pilot tenant without engineering or database access. |
| F2 | Access control | Agency admin, client owner, location manager, and viewer access is tenant- and location-scoped. | Automated authorization tests cover every private endpoint; no user can retrieve another tenant's fixture data. |
| F3 | Tracking | A website script captures page views, order clicks, call clicks, coupon clicks, location clicks, and configured CTA clicks. | At least 95% of valid test events appear in the dashboard within 60 seconds; retries do not double-count an event ID. |
| F4 | Attribution | Events retain landing page, page URL, referrer, UTM values, session, device class, and location when available. | All supported fields survive an end-to-end fixture test; unknown values remain `unknown`, not invented. |
| F5 | Lead capture | Public API accepts configured form submissions using a public tracking key and idempotency key. | A valid lead appears in the inbox and triggers one alert; repeating the same key creates no duplicate lead or alert. |
| F6 | Contacts | A lead creates or links to a contact using normalized email and/or phone within the tenant. | Repeated submissions by the same identity link to one contact while remaining separate leads. |
| F7 | Lead workflow | Authorized users can set owner, location, status, follow-up date, estimated value, and notes. | Each change is persisted with actor and timestamp; overdue follow-ups can be filtered. |
| F8 | Notifications | New leads notify the configured recipient by email. | 95% of accepted pilot leads produce one delivery attempt within 2 minutes, excluding provider outages. |
| F9 | Overview | Dashboard shows visits, order clicks, call clicks, leads, lead conversion rate, top pages, sources, and locations for a date range. | Aggregates reconcile with seeded raw data within 1%; date and tenant filters apply to every metric. |
| F10 | Lead inbox | Users can filter leads by status, type, location, owner, and follow-up state. | A manager can find and update a seeded lead in under 60 seconds during usability testing. |
| F11 | Monthly summary | System produces a tenant and location summary of activity, leads, outcomes, and top sources/pages. | Report totals match the dashboard for the same period and can be viewed from the app. |
| F12 | Auditability | Raw events, lead source data, and lead workflow history are retained. | Support can trace any displayed pilot metric or lead change to stored source records. |

## Standard lead workflow

```text
New → Contacted → Quoted → Won
                         ↘ Lost
Any active state → Spam
```

Rules:

- `Won`, `Lost`, and `Spam` are terminal unless explicitly reopened.
- A lost lead requires a reason.
- Estimated value is optional; actual value is optional at `Won`.
- Status history is append-only.

## Default dashboard definitions

| Metric | Definition |
|---|---|
| Visits | Distinct sessions with at least one accepted page view |
| Order intent | Accepted `order_click` events |
| Call intent | Accepted `call_click` events |
| Leads | Non-spam leads created in the selected period |
| Lead conversion rate | Leads ÷ visits |
| Win rate | Won leads ÷ leads with a terminal sales outcome (`Won` or `Lost`) |
| Attributed value | Sum of actual value for won leads; estimated value is shown separately |

## P1 candidates after pilot

- Google Search Console and Google Analytics imports.
- Call tracking and review monitoring.
- PDF/email report delivery.
- CSV export.
- White-label hostname support.
- SMS alerts and reminders.
- Custom event configuration UI.
