# 3. Measurement Plan

## MVP outcome

The MVP succeeds when it reliably captures revenue opportunities, helps managers act on them, and gives Pippal Labs a credible account-level ROI narrative.

## Proposed pilot targets

Targets are proposals to approve before the PRD is finalized.

| Measure | Definition | Pilot target | Review cadence |
|---|---|---:|---|
| Time to first value | Tracking installed to first valid event visible | ≤ 30 minutes | Per setup |
| Lead capture reliability | Accepted valid submissions visible in inbox | ≥ 99% | Weekly |
| Median first-response time | Lead created to first move from `New` | ≤ 1 business day | Weekly |
| Lead hygiene | Non-spam leads with owner and status updated within 2 business days | ≥ 80% | Weekly |
| Outcome completeness | Mature leads marked `Won` or `Lost` within agreed sales window | ≥ 70% | Monthly |
| Active client usage | Client workspaces with a meaningful dashboard or lead action in 7 days | ≥ 70% | Weekly |
| Reporting trust | Sampled report metrics matching source records | 100% | Monthly |
| Pilot retention signal | Pilot stakeholder says report materially improves ROI review | 3 of 4 monthly reviews | Monthly |

No revenue claim should be made from order clicks alone. They are labeled **order intent** until transaction data is integrated.

## Product telemetry

| Event | Trigger | Required properties |
|---|---|---|
| `page_view` | Tracked page loads | event_id, tracking_key, session_id, occurred_at, page_url, landing_page, referrer |
| `order_click` | User selects configured order CTA | event_id, session_id, occurred_at, page_url, target_url, location_id if known |
| `call_click` | User selects a `tel:` CTA | event_id, session_id, occurred_at, page_url, location_id if known |
| `coupon_click` | User selects configured coupon CTA | event_id, session_id, occurred_at, page_url, coupon identifier |
| `location_click` | User selects a location | event_id, session_id, occurred_at, page_url, location identifier |
| `cta_click` | User selects another configured CTA | event_id, session_id, occurred_at, page_url, CTA name |
| `lead_created` | Lead API accepts a unique submission | lead_id, lead_type, source, page_url, location_id if known, occurred_at |
| `lead_status_changed` | User changes status | lead_id, from_status, to_status, actor_id, occurred_at |
| `lead_assigned` | User changes owner | lead_id, owner_id, actor_id, occurred_at |
| `follow_up_set` | User sets follow-up | lead_id, follow_up_at, actor_id, occurred_at |
| `report_viewed` | User opens monthly summary | report_id, period, user_id, occurred_at |

## Data-quality checks

- Reject unknown or inactive tracking keys.
- Validate event type, timestamp, URL, payload size, and required fields.
- Deduplicate by tenant and event/idempotency key.
- Label bot/internal traffic when detected; never silently delete it.
- Quarantine invalid payloads with a reason and request identifier.
- Reconcile lead API acceptance, inbox records, and notification attempts daily.
- Display `unknown` for missing attribution and location.

## Pilot dashboard views

1. Account overview: trend and totals for visits, intent, leads, outcomes, and value.
2. Leads: operational inbox and follow-up state.
3. Locations: the same core metrics compared by location.
4. Pages and sources: which pages and acquisition sources create intent and leads.
5. Monthly summary: changes, top contributors, lead outcomes, and missing follow-up.
