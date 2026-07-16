# JavaScript SDK (Frontend-Direct) — Benefits & Disadvantages

## Benefits

1. **Query latency** — One hop, browser to Algolia's distributed DSN. Engine time is 2–3 ms; network dominates (~91 ms round trip), and the SDK path removes the extra proxy leg per query. Biggest win for search-as-you-type.

2. **Built-in resilience** — Automatic retry and host failover across Algolia's fallback hosts, plus client-side caching of repeated identical queries, all out of the box.

3. **Clean dependency management via npm** — `npm install algoliasearch@5`, versioned, tree-shakable modular packages (`@algolia/client-search` alone if only search is needed), TypeScript types included. CDN lite build with SRI integrity hash as a no-build alternative.

4. **Analytics for free** — v5 bundles Search, Insights, Analytics, and A/B testing clients; click/conversion events flow naturally from the browser with real user context.

5. **Per-user rate limits work automatically** — Algolia sees real user IPs, so maxQueriesPerIPPerHour on a secured key throttles per user with zero code.

6. **No infrastructure** — Nothing to host, scale, or monitor server-side.

## Disadvantages

1. **Page-load latency (cost of adding new JS)** — Extra download + parse + execute on EVERY page view, on top of the existing 1.3 MB bundle — including pages where the user never searches. Lite build is small (single-digit kB gzipped), full client is several times larger. Trades one network hop per query for extra bytes on every page load; pays off only for instant-search-heavy UIs, not a results-page-only search.

2. **npm inclusion = build-pipeline surgery** — Dependency must be integrated into the legacy webpack config; Jh()/Zh() rewritten around SDK calls; SDK major version bumps (v4 → v5 changed the API shape) become coupled to frontend site releases.

3. **Credentials exposed** — App ID + search key visible in DevTools. Secured API keys mitigate but cannot hide the App ID, index names, or query traffic.

4. **Cannot implement our server-side contracts** — externalResults merge impossible (needs server-side external source); Solr-shaped response impossible (SDK path is a frontend rewrite); multi-app registry with hidden per-app credentials impossible.

5. **No shared caching** — Each browser caches only its own queries; every user re-pays Algolia for common queries. Cross-user proxy caching is off the table.

6. **CSP + privacy surface** — Must open connect-src to *.algolia.net / *.algolianet.com; every user's IP and search terms go directly to a third party (consent/OneTrust conversation required).

7. **Rate-limit inversion in hybrid setups** — Any traffic later routed via a proxy collapses Algolia's per-IP limits into one shared bucket for that path; proxy-side rate limiting must be built.

## Decision

Proxy architecture selected: three requirements (externalResults merge, Solr-shaped response with unchanged client JS, multi-app hidden credentials) are impossible frontend-direct. The SDK is still used INSIDE the proxy (Node/Java client) for retry + host failover. Future hybrid option: if autocomplete is added later, autocomplete goes SDK-direct with a secured key while the results page stays proxied.