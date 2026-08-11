(() => {
  "use strict";

  const script = document.currentScript;
  const trackingKey = script && script.dataset.trackingKey;
  if (!trackingKey) return;

  const endpoint = new URL(script.dataset.endpoint || "/v1/events", script.src).toString();
  const queueKey = `pippal:event-queue:${trackingKey.slice(-6)}`;
  const sessionKey = `pippal:session:${trackingKey.slice(-6)}`;
  const blockedParameters = /email|phone|name|address|password|token|secret|message|search|query/i;

  const identifier = () =>
    (globalThis.crypto && crypto.randomUUID && crypto.randomUUID()) ||
    `${Date.now()}-${Math.random().toString(16).slice(2)}`;

  const sessionId = (() => {
    try {
      const existing = sessionStorage.getItem(sessionKey);
      if (existing) return existing;
      const created = identifier();
      sessionStorage.setItem(sessionKey, created);
      return created;
    } catch (_) {
      return identifier();
    }
  })();

  const safeUrl = (value) => {
    if (!value) return undefined;
    try {
      const url = new URL(value, location.href);
      [...url.searchParams.keys()].forEach((key) => {
        if (blockedParameters.test(key) || !key.toLowerCase().startsWith("utm_")) url.searchParams.delete(key);
      });
      url.hash = "";
      return url.toString();
    } catch (_) {
      return undefined;
    }
  };

  const attribution = () => {
    const url = new URL(location.href);
    return {
      page_url: safeUrl(location.href),
      landing_page: safeUrl(sessionStorage.getItem("pippal:landing") || location.href),
      referrer: safeUrl(document.referrer),
      utm_source: url.searchParams.get("utm_source") || undefined,
      utm_medium: url.searchParams.get("utm_medium") || undefined,
      utm_campaign: url.searchParams.get("utm_campaign") || undefined,
      utm_term: url.searchParams.get("utm_term") || undefined,
      utm_content: url.searchParams.get("utm_content") || undefined,
      device_class: matchMedia("(max-width: 767px)").matches ? "mobile" : matchMedia("(max-width: 1100px)").matches ? "tablet" : "desktop"
    };
  };

  try {
    if (!sessionStorage.getItem("pippal:landing")) sessionStorage.setItem("pippal:landing", safeUrl(location.href));
  } catch (_) {}

  const readQueue = () => {
    try { return JSON.parse(sessionStorage.getItem(queueKey) || "[]"); } catch (_) { return []; }
  };

  const writeQueue = (events) => {
    try { sessionStorage.setItem(queueKey, JSON.stringify(events.slice(-50))); } catch (_) {}
  };

  const deliver = async (payload, retry = true) => {
    try {
      const response = await fetch(endpoint, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
        keepalive: true,
        credentials: "omit"
      });
      if (!response.ok && response.status >= 500) throw new Error("temporary ingestion error");
      return response.ok;
    } catch (_) {
      if (retry) writeQueue([...readQueue(), payload]);
      return false;
    }
  };

  const track = (eventType, metadata = {}, locationKey) => {
    const payload = {
      tracking_key: trackingKey,
      event_id: identifier(),
      event_type: eventType,
      occurred_at: new Date().toISOString(),
      session_id: sessionId,
      location_key: locationKey || script.dataset.locationKey || undefined,
      ...attribution(),
      metadata
    };
    deliver(payload);
  };

  const queued = readQueue();
  writeQueue([]);
  queued.forEach((payload) => deliver(payload));

  track("page_view");

  document.addEventListener("click", (event) => {
    const target = event.target.closest("[data-pippal-event], a[href^='tel:']");
    if (!target) return;

    const eventType = target.dataset.pippalEvent || "call_click";
    const allowedTypes = ["order_click", "call_click", "coupon_click", "location_click", "cta_click"];
    if (!allowedTypes.includes(eventType)) return;

    const metadata = {};
    if (["order_click", "call_click"].includes(eventType)) metadata.target_url = safeUrl(target.href);
    if (eventType === "coupon_click") metadata.coupon_id = target.dataset.couponId;
    if (eventType === "location_click") metadata.location_identifier = target.dataset.locationKey;
    if (eventType === "cta_click") metadata.cta_name = target.dataset.ctaName || target.textContent.trim().slice(0, 80);
    track(eventType, metadata, target.dataset.locationKey);
  }, { capture: true });

  globalThis.Pippal = Object.freeze({ track });
})();

