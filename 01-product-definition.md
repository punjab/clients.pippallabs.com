# 1. Product Definition

## Problem

Pippal Labs clients receive website activity and leads across forms, pages, calls, and ordering links, but cannot see the activity in one place or consistently follow revenue opportunities to an outcome. Pippal Labs also lacks a repeatable way to demonstrate website and SEO value.

## MVP promise

Within one dashboard, a client can:

1. See website visits and high-intent actions by location and source.
2. Receive and manage website leads.
3. Record whether each lead was won or lost.
4. Review a monthly summary of activity and outcomes.

## Primary users

| User | Job to be done | MVP value |
|---|---|---|
| Client owner / marketing manager | Understand whether the website creates demand | Overview, sources, pages, locations, report |
| Location manager | Respond to local opportunities | Assigned lead inbox and follow-up |
| Pippal Labs operator | Onboard clients and prove service value | Tenant setup, cross-location visibility, reporting |

The website visitor is a data subject, not a dashboard user.

## Core loop

```text
Visitor action → lead or intent captured → manager notified
→ manager follows up → outcome recorded → value reported
```

## Product principles

- Revenue signals over vanity analytics.
- A usable default dashboard over a dashboard builder.
- Reliable lead capture over exhaustive visitor tracking.
- Location-aware by default.
- One codebase; tenant isolation is non-negotiable.
- Raw inputs remain available so derived metrics can be corrected.

## MVP boundaries

### In

- Multi-tenant accounts, locations, websites, users, and roles.
- Website event tracking for page views and defined CTA clicks.
- Server-side form/lead ingestion.
- Lead and contact management.
- Overview, page, source, and location performance.
- Email lead alerts and monthly summary.

### Out

- Full sales pipelines, deals, quotes, invoices, or email sequencing.
- POS, loyalty, ordering revenue, or closed-loop ad attribution.
- Google, review, call-tracking, SMS, and Slack integrations.
- White-label custom domains and per-client UI customization.
- Custom dashboard/report builders.
- AI recommendations or lead scoring.
- Dedicated analytics warehouse or separate service fleet.

## Assumptions to validate in the pilot

- Order clicks are a useful proxy for order intent when transaction data is unavailable.
- Client managers will update lead status if the workflow is faster than their current process.
- Location is known from the page, selected location, form, or configured fallback.
- A monthly summary supports client retention better than raw traffic reporting alone.
