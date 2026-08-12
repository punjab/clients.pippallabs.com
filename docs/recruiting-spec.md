# Optional recruiting capability

## Outcome

Allow any client workspace to receive and manage structured job applications without mixing applicants with sales contacts or leads. Recruiting is disabled by default and activated per tenant by an agency administrator.

## Roles

| Role | Recruiting access |
| --- | --- |
| Agency admin | Activate/deactivate the capability; manage positions and all applications. |
| Client owner | Manage positions and all applications after activation. |
| Location manager | View and advance applications assigned to their location; cannot manage positions. |
| Viewer | No recruiting navigation or applicant access. |

Disabling recruiting removes private navigation and stops public intake. Existing records remain stored for authorized retention/deletion handling if the capability is later re-enabled.

## Public intake

`POST /v1/job_applications` accepts structured applications from a client website backend. It requires:

- a valid website tracking key;
- recruiting enabled for that website's tenant;
- an open tenant-owned `position_key`;
- a tenant-scoped idempotency key;
- applicant name and email;
- submission time and configured-domain HTTP(S) page URL;
- the privacy-notice version shown to the applicant.

Optional fields include phone, location key, availability, experience, motivation, source, and explicit consent for future opportunities. Requests are limited to 64 KB and 30 requests per IP per minute. Repeating an idempotency key returns the original application.

## Hiring workflow

```text
New → Reviewing → Interview → Offered → Hired
  └──────────────→ Rejected
  └──────────────→ Withdrawn
```

Rejected, withdrawn, and hired are terminal. Every stage transition records the previous stage, next stage, actor, and time in append-only application history.

## Data and privacy boundary

- `JobApplicant` represents applicant identity within one tenant.
- `JobApplication` represents one submission for one position.
- `JobPosting` represents an open or closed position, optionally tied to one location.
- `JobApplicationHistory` records intake and stage changes.
- Applicant fields are filtered from application logs.
- Applicant records never create contacts or leads and never enter sales metrics or reports.
- Authentication cookies expire after 14 days and are HTTP-only, same-site, and secure in production.

## Deferred until policy and storage controls exist

- Résumé and cover-letter uploads.
- Malware scanning and quarantine.
- Signed private file downloads.
- Automated retention/deletion schedules.
- Applicant self-service access, correction, and withdrawal.
- Email notifications and interview scheduling.

These are deliberate boundaries rather than implied support.

## Acceptance evidence

The integration suite verifies tenant activation, disabled-workspace rejection, idempotent public intake, configured-domain URL safety, position closure, audited stage progression, viewer denial, and location-manager isolation.
