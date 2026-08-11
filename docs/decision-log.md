# Decision log

This chronological log complements the durable decisions in `docs/adr/`.

## 2026-08-10

- Treated the numbered definition pack as the product contract and selected its proposed defaults where stakeholders had not supplied pilot specifics.
- Selected a Pippal Labs-branded, dashboard-first product with explicit location mapping and tenant fallback.
- Selected Ruby 3.4, Rails 8.1, PostgreSQL, Hotwire, Solid Queue, and Minitest for a low-dependency modular monolith.
- Selected local Markdown for issue tracking and a single root domain context because the repository had no VCS remote or existing code organization.
- Prioritized HTTP integration tests for tenant isolation, idempotency, lead workflow, aggregation reconciliation, and report agreement.
- Kept report delivery in-app for P0; email/PDF remains P1. Email is used only for new-lead alerts.
- Chose Render plus managed PostgreSQL as the initial deployment recommendation; no remote resources will be created during local implementation.
- Marked privacy retention duration and jurisdiction as launch blockers rather than inventing a legal policy. The software will expose configurable retention metadata and avoid full IP/form-field tracking.
- Consolidated application data, jobs, and cache tables into one PostgreSQL database for the pilot so local and hosted operation need only one stateful dependency.
- Kept image variants disabled because the CRM does not accept image uploads; this removes an unnecessary native image-processing dependency from production.
- Added a checked-in Render Blueprint using separate web and job processes, a migration pre-deploy step, health checks, deploy-after-checks, and the smallest paid managed PostgreSQL tier suitable for a persistent pilot.
- Completed responsive browser QA at desktop and mobile widths, then optimized dashboard location aggregation after observing its live query profile.
- Required production SMTP, an explicit application host, and the Rails master key at runtime; build-time placeholders are intentionally non-secret and exist only so assets can compile in the container image.
