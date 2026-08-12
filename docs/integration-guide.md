# Website integration guide

## Browser activity

Load the tracker once near the end of the client website's `<body>`:

```html
<script
  async
  src="https://crm.example.com/tracker.js"
  data-tracking-key="pk_replace_me"
  data-endpoint="https://crm.example.com/v1/events">
</script>
```

The script sends one page view and captures `tel:` links automatically. Mark other calls to action explicitly:

```html
<a href="/order" data-pippal-event="order_click" data-location-key="downtown">Order now</a>
<button data-pippal-event="coupon_click" data-coupon-id="SUMMER20">Reveal offer</button>
<a href="/catering" data-pippal-event="cta_click" data-cta-name="catering_hero">Plan catering</a>
```

It uses session storage, not cookies; queues up to 50 temporary failures; keeps the same event ID on retry; excludes non-UTM query parameters; and never reads form fields.

## Server-side lead capture

Submit leads from the client's form backend, not browser JavaScript. Generate and persist one idempotency key per form submission:

```sh
curl https://crm.example.com/v1/leads \
  -H 'Content-Type: application/json' \
  -d '{
    "tracking_key": "pk_replace_me",
    "idempotency_key": "form-record-12345",
    "lead_type": "catering",
    "occurred_at": "2026-08-10T19:00:00Z",
    "name": "Alex Rivera",
    "email": "alex@example.com",
    "location_key": "downtown",
    "source": "website_form",
    "page_url": "https://example.com/catering"
  }'
```

A retry returns the original lead with `duplicate: true`; it does not create another contact, lead, history entry, or alert.

## Job application capture

Recruiting is available to every client workspace but its API accepts submissions only after an agency administrator activates the feature and a hiring manager publishes an open position. Submit applications from the client's form backend:

```sh
curl https://crm.example.com/v1/job_applications \
  -H 'Content-Type: application/json' \
  -d '{
    "tracking_key": "pk_replace_me",
    "idempotency_key": "job-form-record-7832",
    "position_key": "kitchen-team-member",
    "occurred_at": "2026-08-11T19:00:00Z",
    "name": "Sam Lee",
    "email": "sam@example.com",
    "phone": "+16045550142",
    "availability": "Evenings and weekends",
    "experience": "Two years in a busy restaurant kitchen.",
    "motivation": "I enjoy serving the local community.",
    "location_key": "downtown",
    "source": "careers_form",
    "page_url": "https://example.com/careers",
    "privacy_notice_version": "2026-08",
    "future_opportunities_consent": false
  }'
```

The application is stored separately from CRM contacts and leads. The privacy-notice version is required, future-opportunity consent is explicit, and retries with the same idempotency key return the original application. Closing the position immediately stops further intake for its key.

Résumé uploads are intentionally not accepted. Before adding attachments, configure private object storage, file allowlists and size limits, malware scanning, signed downloads, and an approved retention/deletion policy.
