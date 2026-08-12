# ADR-0006: Tenant-activated recruitment with a separate privacy boundary

- Status: Accepted
- Date: 2026-08-11

## Context

Client websites may collect both commercial enquiries and job applications. Applicants provide employment history and other personal information that has different purposes, access expectations, retention rules, and workflows from customer leads. Not every client needs recruitment features.

## Decision

Implement recruiting as a workspace feature available to every tenant and disabled until an agency administrator activates it. Model job postings, applicants, applications, and append-only application history separately from contacts, leads, and lead history.

Accept structured applications through an idempotent public endpoint authenticated by the website tracking key. Require the feature to be active, an open tenant-owned position, a configured website domain, and a recorded privacy-notice version. Do not accept résumé uploads in the first release.

Allow agency administrators and client owners to manage recruiting across the tenant. Allow location managers to access only applications assigned to their location. Deny recruitment access to viewers.

Because recruiting increases the sensitivity of authenticated pages, expire signed sessions after 14 days and require the secure cookie flag in production.

## Consequences

- Recruitment can be rolled out client by client without forks or Curry Pizza Company-specific code.
- Applicant information cannot leak into sales dashboards, contact deduplication, or lead notifications.
- Résumé storage, malware scanning, signed downloads, retention automation, and applicant access/deletion procedures remain explicit follow-up work before file uploads are enabled.
- The activation registry provides a reusable mechanism for future optional workspace capabilities.
