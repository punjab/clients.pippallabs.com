# 4. System and Data Contract

## MVP topology

```text
Client website
  ├─ tracker.js ───────→ public event endpoint
  └─ server-side form ─→ public lead endpoint
                              │
                              v
                    central application + jobs
                              │
                              v
                           Postgres
                              │
                              v
                    dashboard + email report
```

One deployable full-stack application may serve the dashboard and APIs during MVP. Logical boundaries should remain explicit so ingestion or jobs can be separated later without changing client contracts.

## Tenant boundary

- Every tenant-owned record includes `tenant_id`.
- Location-owned records also include `location_id` where applicable.
- Private requests derive allowed tenant/location scope from authenticated membership, never client-provided IDs alone.
- Public requests use a revocable website tracking key mapped server-side to one tenant and website.
- Database queries and indexes include tenant scope.
- Authorization is tested at the API boundary and on background jobs.

## Minimum entities

| Entity | Required purpose |
|---|---|
| Tenant | Client workspace and plan/configuration boundary |
| User / Membership | Identity, tenant role, and optional location scope |
| Location | Physical or operational unit for assignment/reporting |
| Website | Allowed domain, public key, and tracking configuration |
| Contact | Identified person and communication consent |
| Lead | Revenue opportunity, attribution, owner, status, and value |
| Lead history | Append-only status, assignment, follow-up, and note audit trail |
| Event | Immutable raw website activity and attribution |
| Notification | Delivery target, attempt, provider result, and related lead |
| Report | Period, version, generated metrics, and generation time |

## Public contracts

### `POST /v1/events`

Required:

```text
tracking_key, event_id, event_type, occurred_at,
session_id, page_url
```

Optional:

```text
anonymous_id, referrer, landing_page, location_key,
UTM fields, device class, event-specific metadata
```

The endpoint must not accept arbitrary personal information in event metadata.

### `POST /v1/leads`

Required:

```text
tracking_key, idempotency_key, lead_type, occurred_at,
at least one of email or phone
```

Supported:

```text
name, email, phone, message, location_key, source,
page_url, UTM fields, estimated_value,
email_consent, sms_consent, consent_source, consent_timestamp
```

## Private capabilities

```text
GET  /v1/dashboard/summary
GET  /v1/leads
GET  /v1/leads/:id
PATCH /v1/leads/:id
POST /v1/leads/:id/notes
GET  /v1/locations
GET  /v1/pages
GET  /v1/reports
GET  /v1/reports/:id
```

Exact routes may change; the resource and authorization boundaries may not.

## Privacy and security baseline

- No contact is created from anonymous browsing alone.
- Consent source and timestamp are stored separately for email and SMS.
- Tracking does not collect form-field contents, full IP addresses, or sensitive URL parameters.
- Logs redact contact fields and public keys.
- Public endpoints are rate-limited and payload-limited.
- Tracking keys can be rotated without changing the tenant.
- Data retention, deletion, cookie behavior, and applicable consent rules must be approved before pilot launch.
