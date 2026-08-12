# ADR-0007: Three-tier access model

- Status: Accepted
- Date: 2026-08-12

## Context

Pippal Labs operates a single agency serving multiple client tenants. Agency operators previously needed an `agency_admin` membership row in every tenant they touched, which does not scale as clients are onboarded and offers no place for future agency staff with scoped access. Client-side roles also read as internal jargon in the UI.

## Decision

Adopt three tiers of access. A `super_admin` boolean flag on users grants automatic, agency-admin-equivalent access to every tenant with no membership rows; sessions carry an explicit `tenant_id` so a super admin's current tenant is tracked without a membership. The per-tenant `agency_admin` membership role is retained for scoped agency staff. Client roles remain the existing enum keys (`client_owner`, `location_manager`, `viewer`) and are displayed as Owner, Manager, and Viewer.

Authorization checks flow through a small controller concern (`agency_access?`, `accessible_locations`, `location_scoped?`, and related helpers) so super-admin semantics live in one place rather than scattered nil checks on the current membership.

## Consequences

- Onboarding a client no longer creates a membership for super admins; the tenant list on the agency page is the source of truth for them.
- Any code that assumes a non-nil current membership must go through the authorization helpers instead.
- Enum keys and columns are unchanged, so no data migration is needed for role display renames.
- Scoped agency staff can be added later as `agency_admin` memberships without touching the super-admin path.
