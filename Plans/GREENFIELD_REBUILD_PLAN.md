# Synergia Greenfield Rebuild Plan

## Status

| Field | Value |
| --- | --- |
| Status | AWAITING CONFIRMATION |
| Last updated | 2026-05-07 |
| Competitive additions | StoreFEEDER, Linnworks, Veeqo, Rithum, Sellercloud, Brightpearl, Cin7 analysis |
| Internal MCP | Phase 13 |
| Public MCP read-only beta | Phase 13 |
| Public MCP write | Phase 17 |
| B2B Wholesale Portal | Deferred (see `2027-plans/wholesale-portal.md`) |

> **Documentation rule:** `docs/PROJECT_STATUS.md` must be updated at the end of every phase before the phase is marked complete. Any engineer or agent must be able to orient from that file alone. See Step 4 (Documentation System) for the full `docs/` structure.

## Changelog

### 2026-05-07 — Plan Review Additions (line-by-line audit)

- **Critical schema gaps now in Phase 1 lock:** multi-currency / FX, VAT / tax engine, customers/buyers as first-class entity, channel buffer stock rules
- **New domains added:** Customers/CRM, Tax & Currency, Repricing, Stock Take, Returns to Vendor, Pricing Rules, GDPR/Compliance
- **Market-leading additions:** AI woven through workflows from Phase 5 (not just chat at Phase 13), public MCP read-only beta brought forward to Phase 13, free tier for sub-£100K turnover sellers, channel onboarding "60-second connect" wizard, public uptime/metrics page, open-source adapter SDK, 3PL shadow-tenant model, public marketing site at `synergia.co.uk` (Astro), bilingual UI (English + Urdu with full RTL support) from launch, **AI-authored saved reports + 18-report finance starter pack + user-built drag-and-drop dashboards**, **three-tier product research stack — Tier A (Phase 13) → Tier B Marketplace Research (Phase 14) → Tier C Full Research Platform with AI image-match supplier finding & cross-marketplace arbitrage detection (Phase 15)**
- **Phases now 0–17** (was 0–15): Tier B + Tier C product research inserted as Phases 14 + 15; Storefronts moved to 16; Enterprise + Public API + MCP GA moved to 17.
- **Implementation Sequence rewritten** to match new phase order

### 2026-05-07 — Gap-Analysis Additions

- **New domains added:** Smart Category Management (Catalogue & Inventory), Expense Management, Portfolio Management, Monthly Financial Closing (Finance & Operations)
- **Expense model:** company-level and channel-level expenses; flexible allocation rules (equal across all channels, or selected channels at custom percentages); feeds channel P&L and monthly close
- **Monthly close:** per-company AND per-channel; locks the period; produces an immutable financial snapshot; unlocks are audit-logged
- **Portfolio Management:** operator-defined groupings of channels for cross-channel reporting and P&L view; no investor or profit-sharing logic

### 2026-05-07 — Vinted API Verification (D5 updated)

- **Vinted Pro Integrations API verified against official docs.** Invite-only allowlist; HMAC-SHA256 auth (not OAuth); 500-active-item slot per API user (negotiable); UK supported. **Capabilities exposed:** listings CRUD, orders read + cancel, shipping labels (Vinted-managed only), webhooks for item + order lifecycle. **Capabilities NOT exposed:** returns, disputes / seller-protection cases, messaging, account health, feedback, payouts — all those workflows remain in the Vinted UI for the operator.
- **Vinted stays in Phase 5 launch trio** (pilot client uses it) but with **reduced capability scope** in adapter capability flags. Phase 7 returns / Phase 11 messaging hub / account health dashboard explicitly exclude Vinted.
- **Etsy promoted to must-ship in Phase 12** to fill the workflow gaps Vinted leaves (Etsy has full returns / messaging / cases / feedback).
- **Marketing site Phase 5 must be honest** about Vinted scope — "listings + orders only" — to maintain credibility.
- **v1 Launch Milestone updated** to reflect Vinted reduced depth.

---

## Step 1 — Target Product Spec

Synergia is a **multichannel marketplace management + 3PL platform** targeting UK-based SME and mid-market sellers (£500K–£20M revenue) who manage their own warehouse or operate as a 3PL. It competes directly with StoreFEEDER and Linnworks and is positioned as the modern, neutral, full-stack alternative.

### Positioning

| Dimension | Synergia |
| --- | --- |
| Primary market | UK (launch), EU (Phase 9+) |
| Target segment | Warehouse-owning multichannel sellers + 3PL operators |
| Pricing model | Turnover-based flat tiers (no per-order, per-user, per-listing fees) |
| Contract | Rolling 30-day |
| Competitive angle | StoreFEEDER-depth WMS + Linnworks-breadth channels + Brightpearl-quality analytics, at mid-market price |
| Neutrality | Independently owned; no marketplace conflict of interest (vs. Veeqo/Amazon) |

### Product Domains (35 active + 2 deferred)

**Foundation**
1. **Multi-tenancy** — `company_id NOT NULL` from schema birth; zero-trust data isolation; 3PL shadow-tenant model (each managed brand is a real `company`, not a row in another table)
2. **Billing** — Stripe subscriptions, turnover-based tiers including a **free tier for sub-£100K-turnover sellers** (acquisition wedge), usage metering, Customer Portal
3. **Identity & RBAC** — custom roles per company; action-level permissions (`view/create/edit/delete/export/approve/cancel/assign`); user override chain; platform admin overrides
4. **Audit log** — immutable append-only record of every user action; resource-level timeline; global audit trail for platform admins; AI actions attributed separately
5. **Notifications** — in-app notification centre + email + webhook; per-user per-event-type delivery preferences; real-time push via SignalR
6. **Background processing** — Hangfire (recurring/delayed) + Azure Functions (queue consumers); outbox relay; webhook inbox idempotency

**Catalogue & Inventory**
7. **Product catalogue** — products, variants, BOM/kits/combos, structured `product_attributes` (not just channel-specific JSON), images, supplier linkage
8. **Inventory management** — real-time cross-channel sync; multi-warehouse; FIFO/FEFO; **channel buffer stock rules** (reserve qty per channel, max % allocation per channel)
9. **Stock take & cycle count** — physical inventory audit workflow; bin-level scan reconciliation; immutable variance ledger
10. **Tax & Currency engine** — UK VAT, EU OSS/IOSS, marketplace facilitator rules (eBay/Amazon collect VAT for some categories); per-SKU tax codes; multi-currency pricing; FX rates table; base-currency P&L conversion
11. **Smart category management** — hierarchical category tree per company; auto-categorisation rules engine (condition DSL: match by title keywords, SKU pattern, price range, channel, supplier, or product attributes); priority-ordered rules; manual override; bulk re-categorise; category stats (SKU count, average margin)

**Channels**
12. **Marketplace adapter framework** — `MarketplaceAdapter` ABC; capability flags; `StubMarketplaceAdapter` base; **adapter SDKs open-sourced (D11)** alongside Phase 11 — `MarketplaceAdapter` SDK + `CarrierAdapter` SDK + public MCP client released MIT. Internal business logic + Tier-C research stay closed.
13. **Listing management** — central catalogue → channel push/sync; **per-channel listing templates**; **AI-assisted title/keyword optimisation**; bulk ops; cross-marketplace variation syndication mapping
14. **Channel onboarding** — "60-second connect" wizard: connect channel → pull existing listings → match to catalogue by SKU → flag unmatched → operator reviews import preview → apply
15. **Pricing rules** — per-channel mark-up (cover marketplace fees), sale prices, promo windows, RRP enforcement
16. **Repricing engine** — rule-based competitive repricing (match buy box, beat lowest by X, never below floor); AI-assisted repricing suggestions via MCP layer

**Orders & Fulfilment**
17. **Customers / Buyers** — first-class `customers` entity; address book; repeat-buyer detection; LTV calculation; CRM integration foundation
18. **Order management** — unified order queue; rule-based routing; **address validation at ingest**; no-code automation engine; operator collaboration (notes/`@mentions`/task assignment per order)
19. **Returns & disputes** — returns synced from marketplace APIs; operator-initiated returns and cancellations; **AI-assisted return triage** (categorise reasons, flag fraud patterns); RMA queue, stock fate decisions, refund trigger; marketplace case management
20. **Returns to Vendor (RTV)** — faulty/defective stock back to supplier; distinct workflow from customer returns; supplier credit tracking
21. **Fulfilment / WMS** — React Native app (iOS + Android); barcode pick/pack/ship; location management; staff performance; cycle count
22. **Shipping** — carrier adapters; rate shopping; label generation; tracking relay; insurance & claims (where carrier supports)

**Finance & Operations**
23. **Expense management** — company-level expenses (rent, salaries, software, overheads) and channel-level expenses (marketplace advertising, subscriptions, promotions); recurring and one-off; flexible allocation rules: distribute a company-level expense equally across all active channels, or assign custom percentages to selected channels (percentages must sum to 100); allocated expenses flow into channel P&L and monthly close
24. **Portfolio management** — operator-defined named groupings of channels for cross-channel P&L reporting and comparative analytics (e.g. "UK Channels" = eBay UK + TikTok Shop UK; "EU Channels" = Amazon DE + Etsy); one channel can belong to multiple portfolios; portfolio-level revenue/margin/expense views; no investor or profit-sharing logic
25. **Monthly financial closing** — per-company AND per-channel close workflow; operator opens a period, reviews the financial summary, then locks it; locked periods produce an immutable snapshot (`month_closing_snapshots`) that never changes even if underlying order data is corrected; per-channel breakdown within each company close; status flow: OPEN → IN_PROGRESS → PENDING_REVIEW → LOCKED; unlock requires admin permission and writes an audit entry; closing report auto-generated at lock time

**Intelligence**
26. **Demand forecasting** — velocity trending; reorder alerts; stockout prediction; supplier MOQ + lead time + container constraints
27. **Analytics & reporting** — SKU profitability (fees + COGS + shipping + allocated expenses + return cost); LTV/CAC; channel-level P&L; portfolio P&L; multi-currency normalisation
28. **Report builder + dashboards** — structured `ReportSpec` engine; **AI authoring** (natural language → spec) via in-app assistant; saved reports re-run without AI tokens; scheduled delivery (email PDF / Slack / webhook); user-built dashboards; 18+ pre-built finance reports in the starter pack
29. **Product research / market intelligence** — three-tier research stack delivered across phases:
    - **Tier A — Insights (Phase 13):** analysis of your own catalogue performance + AI-driven recommendations ("what's underperforming?", "which channel suits this SKU best?"); zero new external data
    - **Tier B — Marketplace Research (Phase 14):** Terapeak data, Amazon SP-API reports (BSR, search query performance), Etsy shop stats, TikTok Shop trending, keyword research from marketplace search APIs — all from tenant-already-authorised marketplace OAuth; Niche Explorer; Listing Tracker; AI niche/product recommendations
    - **Tier C — Full Research Platform (Phase 15):** Keepa-grade Amazon price history, Alibaba/AliExpress supplier matching with AI image search, DataForSEO keyword volume, Google Trends, cross-marketplace arbitrage detection (universal product matching by EAN/ASIN/image), saturation analysis with population-level data, white-space/niche hunting
    - **Closed-loop pipeline:** research → catalogue → list → measure → refine. Competitors do ops OR research; Synergia does both in one platform.
30. **Messaging** — marketplace message hub; conversation threading; AI draft assist

**Surfaces**
31. **Public marketing website** — `synergia.co.uk` — the front door of the business. Static-first (Astro) for SEO + performance; pages: home, features (per domain), pricing (free tier prominent), for-sellers, for-3PLs, comparisons (vs Linnworks/StoreFEEDER/Veeqo), integrations directory, blog (content marketing), case studies, about, contact / demo request, legal (privacy, terms, DPA, sub-processors, cookies). Sign-up CTAs route to `app.synergia.co.uk`. Lead capture stored in `marketing_leads` table.
32. **3PL client portal** — scoped portal for 3PL clients (under shadow-tenant model — each managed brand is its own `company` with cross-tenant view permissions for the 3PL operator)
33. **Public API + webhooks** — REST API; outbound webhook subscriptions; developer docs; first-party TypeScript + Python SDKs
34. **AI / MCP layer** — internal MCP server (in-app assistant) + **public MCP server (read-only beta from Phase 13, write from Phase 17)** — only platform with native MCP; AI woven through listing optimisation, return triage, repricing, forecasting, report authoring, **product research** (not just a chat panel)
35. **Public uptime / metrics page** — `status.synergia.co.uk` — transparency: real-time platform status, marketplace sync latency, API rate-limit headroom (trust signal)

**Cross-cutting (not standalone domains)**
- **GDPR / Compliance** — data subject access requests, right to be forgotten, data retention policies, data residency (UK)
- **Feature flags** (Flagsmith) — kill switches, gradual rollout, A/B per company
- **Globalisation & Localisation (i18n / l10n)** — codebase architected for any locale from Phase 2; **launch locales: English (`en-GB`) + Urdu (`ur-PK`)**; every UI string extracted to translation keys; locale-aware formatters for dates/numbers/currency; full RTL (right-to-left) support for Urdu — CSS logical properties throughout; Nastaliq font for Urdu rendering; per-user + per-company locale preference; marketing site, app, and mobile app all localised. **Translation method: AI-translated (Claude) + native-speaker human review** — CI gate blocks production deploys if any key is still AI-only.
- **Locale roadmap post-launch** — additional locales planned in this order: **Hindi (`hi-IN`), Polish (`pl-PL`), Arabic (`ar-SA`, RTL), Romanian (`ro-RO`)**. Reflects UK SME demographics. Each new locale = AI batch translation + native-speaker review + RTL/LTR visual regression on existing screens. New locales ship behind a feature flag for early-access tenants before going GA.

**Deferred to 2027**
- **B2B / wholesale portal** — see `2027-plans/wholesale-portal.md`
- **Self-serve customer returns portal** — see `2027/DEFERRED_FEATURES.md`

---

## Step 2 — Tech Stack + Architectural Decisions

### Tech Stack

| Layer | Choice | Rationale |
| --- | --- | --- |
| Backend | ASP.NET Core 8 (C#) | Performance, strong typing, first-class SignalR + Azure integration |
| Frontend (app) | Vite + React 18 + Shadcn/ui + Tailwind CSS | SPA; fast HMR; no SSR complexity; deploys to Azure Static Web Apps; served at `app.synergia.co.uk` |
| Marketing site | Astro 4 + Tailwind CSS + MDX (blog) + light React islands | Static-first for SEO + Core Web Vitals; MDX for blog/changelog; React islands only for interactive widgets (pricing calculator, demo form); served at `synergia.co.uk` (apex + `www`) |
| Database | Azure SQL (SQL Server) — General Purpose, Azure Database | Fully managed; strong tooling (SSMS, Azure Data Studio); EF Core native support; enterprise SLA |
| ORM | Entity Framework Core + Dapper (complex queries) | EF Core for CRUD + migrations; Dapper for hand-tuned reporting queries |
| Migrations | EF Core migrations (`dotnet ef migrations add`) | Single head enforced in CI; `dotnet ef database update` in deploy pipeline |
| Background jobs | Hangfire (recurring/delayed) + Azure Functions (queue consumers) | Hangfire for scheduled work; Functions scale independently for event-driven processing |
| Queue | Azure Storage Queues (simple high-volume) + Azure Service Bus Standard (DLQ/fan-out) | Storage Queues free tier for most cases; Service Bus only where ordering/DLQ/topics needed |
| Cache + rate limits | Azure Cache for Redis | Token buckets, distributed locks, session cache, carrier rate quote cache |
| Real-time | ASP.NET Core SignalR + Azure SignalR Service (managed backplane) | First-class .NET integration; backplane handles multi-instance scale-out automatically |
| Object storage | Azure Blob Storage | Labels, images, exports; served via Azure Front Door CDN |
| Secrets | Azure Key Vault (referenced via managed identity — no env var secrets ever) | Zero secrets in config files or environment variables |
| Observability | Application Insights + Azure Monitor | Distributed tracing, exception tracking, alerts, dashboards; replaces Sentry + Prometheus |
| Email | Azure Communication Services | Transactional email; no separate vendor account |
| AI assistant | Anthropic API (Claude) direct | Best structured reasoning over operational data; large context window |
| MCP server | `packages/Synergia.Mcp` (C# — ModelContextProtocol NuGet) | Separate project in same solution; connects via internal API; company-scoped |
| Frontend hosting (app) | Azure Static Web Apps (Standard tier) | Global CDN built-in; ~£7/month; native GitHub Actions deploy; free SSL + custom domains; serves `app.synergia.co.uk` |
| Marketing site hosting | Azure Static Web Apps (Free tier) | Separate SWA instance; serves `synergia.co.uk` + `www.synergia.co.uk`; free tier sufficient for marketing traffic |
| Cloud | Azure — UK South primary, UK West secondary | Natural .NET fit; UK data centres; strong compliance certifications |
| CI/CD — backend | GitHub Actions → GHCR → Azure Container Apps | `dotnet build` → push image to GitHub Container Registry → deploy new Container Apps revision; triggers on `src/**` changes only |
| CI/CD — frontend (app) | GitHub Actions → Azure Static Web Apps | `vite build` → SWA deploy action; preview environments per PR automatically; triggers on `frontend/**` changes only |
| CI/CD — marketing | GitHub Actions → Azure Static Web Apps | `astro build` → SWA deploy action; preview environments per PR; triggers on `marketing/**` changes only; Lighthouse CI gate (perf 95+, SEO 100, a11y 100) on every PR |
| Mobile | React Native (Expo) + TypeScript | Cross-platform iOS + Android; shares `packages/api-types` with web frontend; deferred to Phase 5 |
| CI/CD — mobile | GitHub Actions → Expo EAS Build | `eas build` → EAS Submit for App Store / Play Store; OTA updates via Expo Updates; triggers on `mobile/**` changes only |
| CI/CD — infra | GitHub Actions → Azure Bicep | `az deployment group create`; triggers on `infra/**` changes only; requires manual approval gate for prod |
| Shared types | `packages/api-types` (TypeScript) | Auto-generated from .NET OpenAPI spec; consumed by both `frontend/` and `mobile/`; changes retrigger both app workflows |
| i18n — backend | `IStringLocalizer<T>` (.NET built-in) + resource files (`.resx`) per locale | Standard .NET pattern; server-rendered emails, validation messages, API error strings localised per request |
| i18n — frontend (app) | `react-i18next` + ICU MessageFormat | Industry standard; supports pluralisation rules per locale; lazy-loads locale bundles; React hooks API |
| i18n — frontend (marketing) | Astro built-in i18n routing (`/`, `/ur/`) + `astro-i18next` | URL-based locale switching; static generation per locale; per-page hreflang tags for SEO |
| i18n — mobile | `expo-localization` + `i18n-js` | Detects device locale; same translation keys as web app via `packages/locales/` |
| Translation storage | `packages/locales/` JSON files (en-GB baseline, ur-PK first localised) | Single source of truth; consumed by all three frontends; reviewed in PRs like code |
| RTL support | CSS logical properties (`margin-inline-start`, `padding-block`) + `dir="rtl"` attribute on `<html>` for Urdu | No `left`/`right` in CSS; Tailwind `rtl:` modifier where needed; verified via Playwright visual tests in both directions |
| Urdu font | Noto Nastaliq Urdu (Google Fonts) | Preferred Urdu rendering; fallback to system Arabic font; subset to Urdu glyphs only for performance |

### Architectural Decisions

| Decision | Chosen | Runner-up | Rationale |
| --- | --- | --- | --- |
| Service topology | Modular monolith | Microservices | Operational simplicity; decompose when justified by load |
| Marketplace sync | Webhook-first + nightly reconciliation | Polling-only | Low latency on real events; reconciliation catches gaps |
| Marketplace abstraction | MarketplaceAdapter interface (C# port of existing adapter pattern) | Rewrite from scratch | Same pattern, same capability flags, translated to C# interfaces |
| Carrier abstraction | CarrierAdapter interface mirroring marketplace pattern | Per-carrier modules | Same mental model; same registry; same capability flags |
| Tenancy enforcement | App-layer guard + DB NOT NULL | Row-level security | Avoids RLS complexity; guard is explicit and testable |
| Webhook reliability | Transactional outbox (webhook_inbox / webhook_outbox) | Direct queue | DB-atomic event write; no event lost on process crash |
| Search | Azure SQL FTS v1 → Azure AI Search decision at scale | Elasticsearch | Avoid operational overhead until justified |
| Reporting store | Azure SQL indexed views v1 → ClickHouse at 10M events/month | Azure Synapse | Right tool at right scale; not over-engineered early |
| Frontend state | TanStack Query (server state) + Jotai (client state) | Redux | Modern, minimal boilerplate; query deduplication built in; no SSR hydration concerns |
| Label printing | ZPL (Zebra thermal) + react-pdf (desktop PDF) | Browser print | ZPL is the warehouse standard; react-pdf for offices |
| Repo structure | Monorepo (single GitHub repo) | Polyrepo | Shared `packages/api-types` keeps TS types in sync across frontend + mobile automatically; independent CI workflows per path |

### Monorepo Layout

```
synergia/
├── src/
│   ├── Synergia.Api/          # ASP.NET Core 8 API
│   ├── Synergia.Workers/      # Hangfire + Azure Functions
│   └── Synergia.Mcp/          # MCP server
├── frontend/                  # Vite + React (web app — app.synergia.co.uk)
├── marketing/                 # Astro + MDX (marketing site — synergia.co.uk)
├── mobile/                    # Expo + React Native (iOS + Android) — Phase 9
├── packages/
│   ├── api-types/             # TypeScript types auto-generated from .NET OpenAPI spec
│   ├── design-tokens/         # Shared design tokens (colours, typography) — consumed by frontend + marketing
│   └── locales/               # Translation JSON files — en-GB (baseline) + ur-PK; consumed by frontend, marketing, mobile
├── infra/                     # Bicep IaC
│   ├── main.bicep
│   ├── modules/
│   └── parameters/
├── docs/
└── .github/
    └── workflows/
        ├── api.yml            # triggers: src/**, packages/api-types/**, packages/locales/**
        ├── frontend.yml       # triggers: frontend/**, packages/api-types/**, packages/design-tokens/**, packages/locales/**
        ├── marketing.yml      # triggers: marketing/**, packages/design-tokens/**, packages/locales/** — Lighthouse CI gate
        ├── mobile.yml         # triggers: mobile/**, packages/api-types/**, packages/locales/**
        └── infra.yml          # triggers: infra/** — prod requires manual approval
```

Each workflow deploys independently to its own target — a change to `frontend/` never triggers a marketing build, and vice versa. `packages/design-tokens/` is shared so the marketing site and app stay visually consistent.

### Domain layout

| Domain | Hosts | Purpose |
| --- | --- | --- |
| `synergia.co.uk` (apex) + `www.synergia.co.uk` | Marketing site (Astro) | Public site, lead gen, content marketing, SEO |
| `app.synergia.co.uk` | Frontend SPA (Vite + React) | Authenticated tenant app |
| `api.synergia.co.uk` | API (Container Apps) | REST + webhooks; behind Azure Front Door |
| `status.synergia.co.uk` | Public status page | Uptime, sync latency, rate-limit headroom |
| `<brand>.synergia.co.uk` | App (multi-tenant routing) | Branded portal per 3PL-managed brand (Phase 11) |
| `developers.synergia.co.uk` | Developer portal (Phase 17) | API docs, SDK references, sandbox |

---

## Step 3 — Canonical Schema (abridged, key tables)

All tenant-scoped tables carry `company_id UUID NOT NULL REFERENCES companies(id)` from the first migration. No backfill cycles. No nullable company_id ever.

> **Schema lock principle:** Every column is captured in Phase 0 research before being added. Phase 1 locks the schema. Phase 2 implements one EF Core baseline migration. Subsequent schema changes go through a new migration **and** a retroactive update to `SCHEMA.md`.

### Global tables (no company_id)
`users` (with `preferred_locale` column), `companies`, `company_memberships`, `plans`, `plan_features`, `stripe_events`, `carriers`, `carrier_services`, `marketplace_definitions`, `platform_settings`, `audit_log_global`, `currencies`, `fx_rates`, `tax_jurisdictions`, `tax_rates_global`, `notification_event_types` (lookup), `feature_flags_global`, `marketing_leads`, `marketing_form_submissions`, `marketing_newsletter_subscribers`, `supported_locales` (lookup: `en-GB`, `ur-PK`)

### Core tenant tables

```
companies               — subscription root; base_currency CHAR(3); country_code; vat_number; default_locale (e.g. 'en-GB')
company_memberships     — user ↔ company with role
company_roles           — custom role definitions per company
company_role_permissions — (role_id, resource, action, allowed BOOL) — action-level, NOT screen toggles
company_user_permission_overrides — per-user grants/denies that supersede role defaults
company_settings        — per-tenant settings (default warehouse, default currency, fulfilment SLA defaults, etc.)

-- Billing
company_subscriptions   — Stripe subscription per company
usage_records           — metered events (orders processed, labels, API calls)
plan_tiers              — includes free tier (sub-£100K turnover), starter, growth, scale, enterprise

-- Customers / Buyers (NEW)
customers               — buyer record per company; channel_buyer_id mapping; first_seen_at; last_seen_at; total_orders; total_spend
customer_addresses      — shipping + billing addresses; validated_at; validation_provider
customer_channels       — many-to-many: a customer may exist on multiple channels with different IDs
customer_tags           — operator-applied tags (VIP, fraud_risk, returns_frequent, etc.)
customer_notes          — free-text notes with author + timestamp

-- Tax & Currency (NEW)
currencies (global)     — ISO 4217 codes
fx_rates (global)       — daily FX rates from Open Exchange Rates / ECB; base + target + rate + date
tax_jurisdictions (global) — UK, EU member states, US states (where relevant)
tax_codes               — per-company tax code definitions (Standard, Reduced, Zero, Exempt) — mapped to jurisdictions
product_tax_codes       — per-variant tax code per jurisdiction

-- Product catalogue
products                — master SKU catalogue
product_variants        — size/colour/material variants; default_currency; weight; dimensions
product_attributes      — structured category-specific attributes (key/value pairs); searchable & filterable
product_images          — Blob keys per variant; primary_flag; sort_order
product_suppliers       — SKU → supplier mappings with cost_price + currency + MOQ + lead_time_days
product_bom             — Bill of Materials (kits/bundles/combos)
product_bom_items       — component lines with `quantity`
listing_templates       — per-channel reusable listing templates (eBay item-specifics templates, etc.)
variation_groups        — cross-marketplace variation syndication (eBay variations ↔ Amazon parent-child ASIN ↔ Shopify variants)

-- Channels / marketplaces
channels                — connected marketplace/storefront per company; default_currency
channel_listings        — channel-specific listing data per product variant; external_id; external_data JSONB
channel_listing_images  — per-channel image ordering
channel_listing_stock_rules — buffer qty + max% allocation per channel per variant (cross-channel stock split)
listing_sync_jobs       — async push/pull jobs
pricing_rules           — per-channel pricing rules (mark-up %, sale price window, RRP floor); ordered by priority
repricing_rules         — competitive repricing rules per listing (match buy box, beat by X, floor price); active/paused
repricing_history       — every price change with trigger reason (manual / rule / AI suggestion)
ai_listing_suggestions  — AI-generated title/keyword/image-quality suggestions; pending/accepted/rejected
channel_onboarding_jobs — wizard state: connect → pull listings → match catalogue → review → apply

-- Inventory
warehouses              — physical warehouse sites; address; default_currency
warehouse_locations     — bin/aisle/rack per warehouse
stock_levels            — current qty per variant per warehouse location
stock_movements         — ledger of all stock changes (immutable; reason code; reference_type/id)
stock_adjustments       — manual write-offs, corrections
stock_takes             — cycle count / full inventory audit sessions
stock_take_lines        — per-location scan results vs. expected; variance qty
purchase_orders         — inbound POs to suppliers; currency; expected_at; lifecycle status
purchase_order_lines    — SKU qty per PO
goods_received_notes    — GRN per PO
grn_lines               — qty received per SKU
returns_to_vendor       — RTV: faulty stock back to supplier
rtv_lines               — SKU qty per RTV; supplier credit reference

-- Orders
orders                  — canonical order record (channel-agnostic); customer_id; currency; total_in_currency; total_in_base_currency; fx_rate_used
order_lines             — line items; unit_price + currency; tax_amount + tax_code; discount_amount
order_events            — immutable status change log; actor_type (user/marketplace/system/ai)
order_allocations       — stock reservation per order line
order_routing_rules     — rule-based courier/fulfilment assignment (ordered by priority)
automation_rules        — no-code trigger/condition/action rules (JSON body)
order_notes             — internal operator notes per order; author; @mentions
order_tasks             — assignable tasks per order (assignee, due, status)

-- Fulfilment / WMS
pick_waves              — batch picking groupings
pick_tasks              — individual picker assignment
pick_task_lines         — each scan event per task
pack_sessions           — packing bench sessions
pack_session_lines      — scan events during packing
despatch_records        — confirmed despatches

-- Shipping
shipments               — one per despatch (carrier + tracking)
shipment_labels         — Blob key + carrier ref + ZPL/PDF
carrier_rate_quotes     — stored rate-shop results per shipment
shipment_insurance      — optional insurance line per shipment (where carrier supports)

-- Returns
return_requests         — synced from marketplace API or manually logged by operator
return_lines            — SKU qty per return request
return_receipts         — warehouse confirmation of receipt
return_stock_decisions  — restock / write-off / quarantine / refurb decision
return_costs            — per-return shipping + handling + restocking cost (feeds profitability)
marketplace_cases       — eBay/Amazon/TikTok/Vinted dispute cases
case_messages           — message thread per case

-- Forecasting / replenishment
demand_forecasts        — daily/weekly velocity estimates per variant per channel
reorder_alerts          — generated alerts with suggested qty and supplier (respects supplier MOQ + lead time + container size)
supplier_scorecard_snapshots — on-time%, lead-time variance, invoice accuracy per supplier

-- Analytics
order_line_costs        — denormalised COGS + fees + shipping + allocated expense amortisation + return cost per line (append-only)
sku_profitability_mv    — materialised view: net margin per SKU per channel per period (in base currency, after expense allocation)
channel_performance_mv  — materialised view: revenue/orders/returns/expenses/net per channel per period (in base currency)

-- Smart Categories (NEW)
product_categories      — hierarchical category tree per company; name; parent_id (nullable — null = root); color_tag; icon_slug; sort_order; is_system BOOL (system categories cannot be deleted)
product_category_assignments — many-to-many: product variant → category; is_primary BOOL (one primary category per variant); assigned_via (manual/rule/import)
category_rules          — auto-categorisation rules per company; name; conditions_json (DSL — see below); priority INT; is_active BOOL; run_on_import BOOL; run_on_save BOOL
category_rule_actions   — actions when rule matches: assign_category (category_id), set_primary_category, add_tag; multiple actions per rule
category_rule_runs      — audit log of rule execution: rule_id, triggered_by (import/save/manual_run/schedule), matched_count, changed_count, run_at

-- Portfolios (NEW)
portfolios              — operator-defined channel groupings per company; name; description; color_tag; is_default BOOL; sort_order
portfolio_channels      — many-to-many: portfolio ↔ channel; one channel can belong to multiple portfolios

-- Expenses (NEW)
expense_categories      — user-defined expense categories per company (e.g. Rent, Advertising, Staff, Software, Shipping Overhead, Platform Fees); name; color_tag; is_default BOOL
expenses                — individual expense records; company_id; amount; currency; fx_rate_used; amount_in_base_currency; expense_date; category_id; scope (company_level / channel_level); channel_id (nullable — populated only if scope=channel_level); description; recurrence (one_off / monthly / quarterly / annual); recurrence_end_date; reference (invoice number, etc.); created_by
expense_channel_allocations — distribution rules for company-level expenses; (expense_id, channel_id, percentage DECIMAL(5,4)); percentages across all rows for an expense must sum to 1.0 (100%); if no allocation rows exist and scope=company_level the expense is treated as unallocated overhead; NULL allocation_type means unallocated; allocation_type (equal / custom)

-- Monthly Financial Closing (NEW)
month_closings          — one record per (company_id, year SMALLINT, month TINYINT); status (OPEN / IN_PROGRESS / PENDING_REVIEW / LOCKED); opened_at; opened_by; locked_at; locked_by; unlock_reason (populated if ever unlocked); notes; UNIQUE constraint on (company_id, year, month)
month_closing_snapshots — immutable financial snapshot written at lock time; (closing_id, channel_id nullable — NULL = company-wide aggregate); revenue_base; marketplace_fees_base; shipping_costs_base; cogs_base; expenses_direct_base; expenses_allocated_base; return_costs_base; gross_profit_base; net_profit_base; order_count; return_count; snapshot_json JSONB (full breakdown for display); created_at — rows are NEVER updated after insert
month_closing_events    — audit trail: closing_id, event_type (opened/status_changed/locked/unlocked), actor_id, old_status, new_status, note, created_at

-- Report builder + dashboards (NEW)
report_definitions      — saved report: name, description, spec_json (structured ReportSpec), visualisation_type (table/bar/line/waterfall/kpi/pie), filters_json, schedule_cron, delivery_channels, created_by, created_via (ai/manual/template), source_template_id, is_starter_pack BOOL, last_run_at
report_runs             — execution log: report_definition_id, run_at, parameters_used JSONB, result_blob_key, runtime_ms, row_count, triggered_by (user/schedule/api)
report_schedules        — separate from definitions for schedule complexity (multiple schedules per definition; pause/resume; per-recipient delivery channel)
report_deliveries       — delivery log: schedule_id, channel (email/slack/webhook), recipient, status, sent_at, error
report_share_links      — read-only shareable link tokens for a report (with optional expiry)
report_templates (global) — starter-pack report templates shipped with the platform; cloned into `report_definitions` on first run

-- Dashboards (user-built; no default)
widget_types (global)   — catalogue of widget types: kpi, sparkline_kpi, chart, table, live_counter, activity_feed, goal, note, heading, image, embed, shortcut, filter
dashboards              — user-built dashboards; name; description; visibility (private/team/company/public); locked BOOL (only admins can edit when company-wide); default_period; theme; refresh_interval_seconds
dashboard_widgets       — `(dashboard_id, widget_type, position_x, position_y, width, height, config_json, refresh_interval_override)` — config_json holds widget-specific settings (e.g. report_definition_id for chart/table widgets, metric+period for KPI widgets, markdown for note widgets)
dashboard_filters       — dashboard-level cascading filters (period, channel, warehouse) that drive all compatible widgets on the dashboard
dashboard_permissions   — `(dashboard_id, principal_type [user/role], principal_id, permission [view/edit])` for non-public/non-private visibility
dashboard_share_links   — read-only shareable dashboard link with token + optional expiry
dashboard_templates (global) — clone-once starter dashboards: "Daily Operations", "Finance Snapshot", "Warehouse Manager", "Channel Performance"; layout JSON shipped with platform; user clones to own private dashboard

ai_report_authoring_jobs — log of AI authoring sessions: prompt, generated_spec, accepted (bool), tokens_used; for cost tracking + improvement

-- Product research / market intelligence (NEW — Phases 13/14/15)
research_workspaces        — named research projects per company ("Q4 product hunt", "competitor watch — pet supplies"); status: active/archived
research_items             — products/listings/SKUs being researched; source (manual/marketplace/external); external_url, external_id, channel
research_metrics           — denormalised time-series: per research_item per metric (price, BSR, sales_velocity, sell_through_rate, review_count); captured_at; data_source
research_notes             — operator notes on research items
research_keywords          — keyword tracking per workspace; source (terapeak/amazon_search/etsy/dataforseo/google_trends)
research_keyword_metrics   — search volume, competition score, trend direction per keyword per period
research_competitors       — tracked competitor accounts/sellers per channel; their tracked listings
research_categories        — marketplace category tracking with aggregate metrics (avg price, total sellers, growth %)
research_arbitrage_signals — detected cross-marketplace price gaps; needs operator review
research_supplier_matches  — Alibaba/AliExpress supplier match candidates per research_item (with AI image-match confidence)
research_ai_recommendations — AI-generated product/niche recommendations; viewed/accepted/dismissed; tokens_used
research_action_pipeline   — research_item → catalogue product / listing / draft PO conversion log

-- External market data feeds (Phase 15 — Tier C)
market_data_feeds (global) — registry of external data sources (Keepa, DataForSEO, Google Trends API, etc.); active flag; last_sync_at; cost_per_request
market_data_subscriptions  — per-company subscription/usage tracking (which feeds, monthly quota, billing per usage)
market_universal_products  — cross-marketplace product identity (EAN/ASIN/UPC/GTIN + AI image hash); links the same physical product across eBay/TikTok/Amazon/Etsy listings
market_price_history       — daily price snapshot per market_universal_product per channel (Keepa-equivalent)
market_bsr_history         — Amazon Best Sellers Rank time series
market_search_trends       — Google Trends + DataForSEO keyword time series
market_image_match_jobs    — AI image-match jobs (research_item → supplier products via vector similarity)

-- 3PL (shadow-tenant model)
3pl_relationships       — operator_company_id → managed_brand_company_id; permission scope
3pl_client_tokens       — portal access tokens for brands the 3PL manages

-- Messaging
marketplace_conversations — threaded conversation per channel order
marketplace_messages    — individual messages (inbound + outbound); ai_draft_id (link to draft if AI-assisted)
ai_message_drafts       — AI-generated reply drafts; pending operator approval

-- Notifications
notification_event_types (global) — registry of every event_type slug
notification_events     — per-user delivered events; `read_at`, `created_at`
notification_preferences — `(user_id, event_type, channel)` — user opts in/out per channel per event type
notification_templates  — per company per event type per locale customisation (so notifications render in user's locale)
webhook_subscriptions   — outbound webhook endpoints per company
webhook_deliveries      — outbound delivery log: status, response_code, retry_count

-- Localisation overrides (NEW)
custom_translations     — per-company string overrides (e.g. operator wants "Pick task" → "Picking job"); falls back to default translation

-- Outbox / inbox
webhook_inbox           — idempotent inbound webhook store (idempotency_key UNIQUE)
webhook_outbox          — transactional outbox for outbound events
idempotency_keys        — request-level idempotency for mutating API endpoints (24h TTL)

-- Feature flags
feature_flags           — tenant-scoped flag overrides (read by Flagsmith SDK)

-- GDPR
gdpr_dsar_requests      — data subject access requests (export, deletion); status; due_date
gdpr_retention_policies — per-resource retention rules; auto-purge schedule

-- Imports & Migrations (NEW — Phase 5)
import_batches          — id, company_id, resource_type (products/inventory/orders/customers/suppliers/listings/channel_mappings), source_format (csv/xlsx/linnworks/storefeeder), file_blob_key, total_rows, valid_rows, error_rows, status (pending/validating/previewing/committed/rolled_back), started_at, completed_at, started_by
import_batch_errors     — per-row errors: batch_id, row_number, error_code, error_message, raw_row JSONB
import_batch_log        — every state transition + row-counts; immutable audit
import_column_mappings  — saved column mapping templates per company per resource (so re-imports don't require re-mapping)

-- Audit
audit_log               — tenant-scoped immutable audit entries; old_value JSONB; new_value JSONB
```

### Marketing site tables (global — no company_id; handled separately from tenant data)

```
marketing_leads                   — demo requests, contact form, "talk to sales"; name, email, company, turnover_band, segment (seller/3pl), source (utm_source/utm_campaign), status (new/contacted/qualified/converted), assigned_to
marketing_form_submissions        — raw form payload archive; deduplicated by email + form_slug
marketing_newsletter_subscribers  — email, subscribed_at, unsubscribed_at, source, confirmation_status (double-opt-in)
```

Lead workflow: marketing site form → API endpoint `/api/public/marketing/lead` → write to `marketing_leads` → forward to email + (later) sync to CRM (HubSpot/Pipedrive — Phase 17+ decision).

### Schema additions vs. previous draft (post-2026-05-07 review)

The following tables/columns were added during the 2026-05-07 line-by-line audit and **must be in the Phase 1 lock**:

| Domain | New tables | Why |
| --- | --- | --- |
| **Customers** | `customers`, `customer_addresses`, `customer_channels`, `customer_tags`, `customer_notes` | LTV/CAC analytics impossible without this; was hidden inside `orders` |
| **Currency** | `currencies`, `fx_rates` (global); `currency` columns on `companies`, `orders`, `order_lines`, `product_variants`, `purchase_orders`, `warehouses`, `channels` | Multi-channel sellers operate across GBP/EUR/USD; P&L needs FX |
| **Tax** | `tax_jurisdictions`, `tax_codes`, `product_tax_codes`; `tax_rate`, `tax_amount`, `tax_collected_by`, `tax_jurisdiction` on `order_lines` | UK VAT, EU OSS/IOSS, marketplace facilitator rules |
| **Channel buffer** | `channel_listing_stock_rules` | Reserve qty per channel; max % allocation per channel per variant |
| **Pricing/Repricing** | `pricing_rules`, `repricing_rules`, `repricing_history` | Per-channel mark-up; competitive repricing |
| **AI assistance** | `ai_listing_suggestions`, `ai_message_drafts` | AI-woven through workflows from Phase 5+, not just chat at Phase 13 |
| **Listing templates** | `listing_templates`, `variation_groups` | Reusable templates; cross-marketplace variation mapping |
| **Channel onboarding** | `channel_onboarding_jobs` | "60-second connect" wizard state |
| **Stock take / RTV** | `stock_takes`, `stock_take_lines`, `returns_to_vendor`, `rtv_lines` | Cycle count workflow; faulty-to-supplier flow distinct from customer returns |
| **Order operations** | `order_notes`, `order_tasks` | Operator collaboration |
| **Return cost** | `return_costs` | Reverse logistics cost feeds profitability |
| **Product attributes** | `product_attributes` | Structured category-specific data (vs. only channel-specific JSON) |
| **Reliability gaps** | `idempotency_keys`, `feature_flags`, `notification_event_types`, `notification_preferences`, `webhook_deliveries` | Referenced in Phase 2-3 deliverables but missing from schema |
| **Permission gaps** | `company_user_permission_overrides`, `company_settings` | Referenced in Phase 3 RBAC but missing from schema |
| **Compliance** | `gdpr_dsar_requests`, `gdpr_retention_policies` | UK/EU legal requirement |
| **Shipping** | `shipment_insurance` | Carrier insurance API support |
| **3PL** | `3pl_relationships` (replaces `threepl_clients`) | Shadow-tenant model — each managed brand is a real `company` |
| **i18n / l10n** | `supported_locales` (lookup); `users.preferred_locale`; `companies.default_locale`; `custom_translations` | Launch locales: `en-GB` + `ur-PK`; per-user + per-company locale; tenant-level string overrides |
| **Reporting** | `report_definitions`, `report_runs`, `report_schedules`, `report_deliveries`, `report_share_links`, `report_templates` (global), `ai_report_authoring_jobs` | AI authors `ReportSpec` once; saved reports run forever without AI tokens; scheduled delivery |
| **Dashboards** | `widget_types` (global), `dashboards`, `dashboard_widgets`, `dashboard_filters`, `dashboard_permissions`, `dashboard_share_links`, `dashboard_templates` (global) | User-built drag-and-drop dashboards with 13 widget types; visibility (private/team/company/public); cascading filters; optional starter templates |
| **Product research (Tier A/B)** | `research_workspaces`, `research_items`, `research_metrics`, `research_notes`, `research_keywords`, `research_keyword_metrics`, `research_competitors`, `research_categories`, `research_ai_recommendations`, `research_action_pipeline` | Closed-loop research → catalogue pipeline; tenant-authorised marketplace API data |
| **Product research (Tier C)** | `market_data_feeds` (global), `market_data_subscriptions`, `market_universal_products`, `market_price_history`, `market_bsr_history`, `market_search_trends`, `market_image_match_jobs`, `research_arbitrage_signals`, `research_supplier_matches` | External feeds (Keepa, DataForSEO); AI image matching; cross-marketplace product identity; arbitrage detection |
| **Smart Categories** | `product_categories`, `product_category_assignments`, `category_rules`, `category_rule_actions`, `category_rule_runs` | Hierarchical categories + rules engine (keyword, SKU pattern, price, channel, supplier, attribute conditions); auto-categorise on import/save; audit trail per rule run |
| **Portfolios** | `portfolios`, `portfolio_channels` | Named channel groupings for cross-channel P&L reporting; one channel may belong to multiple portfolios |
| **Expenses** | `expense_categories`, `expenses`, `expense_channel_allocations` | Company-level and channel-level expenses; flexible allocation: equal across all channels or custom percentages to selected channels; feeds channel P&L and monthly close |
| **Monthly Closing** | `month_closings`, `month_closing_snapshots`, `month_closing_events` | Lock a financial period per company; per-channel snapshots within each close; immutable once locked; full audit trail; unlocking requires admin + writes a reason |
| **Imports & Migrations** | `import_batches`, `import_batch_errors`, `import_batch_log`, `import_column_mappings` | Per-resource CSV/XLSX importers + competitor-format direct importers (Linnworks, StoreFEEDER, Shopify, eBay); validation, dry-run, atomic commit, rollback by batch |

---

## Step 4 — Documentation System

Documentation is a first-class deliverable. Every engineer or agent must be able to open `docs/PROJECT_STATUS.md` and immediately understand current phase, what is done, what is in progress, and what is next — without asking anyone.

### docs/ Directory Structure

```
docs/
├── PROJECT_STATUS.md              # ENTRY POINT — updated at the end of every phase
├── ARCHITECTURE.md                # High-level system overview with component diagram
├── GETTING_STARTED.md             # Clone → docker compose up → seed → running locally
├── api-research/                  # Phase 0 outputs — one file per external integration
│   ├── ebay.md
│   ├── tiktok-shop.md
│   ├── amazon.md
│   ├── etsy.md
│   ├── vinted.md
│   ├── shopify.md
│   ├── woocommerce.md
│   ├── royal-mail.md
│   ├── evri.md
│   ├── dpd.md
│   ├── stripe.md
│   └── SCHEMA_IMPACT.md
├── schema-design/
│   ├── SCHEMA.md                  # STATUS: LOCKED before any migration runs
│   ├── PERMISSION_MATRIX.md       # Full resource × action matrix
│   ├── NOTIFICATION_EVENT_TYPES.md
│   └── decisions/                 # Per-decision notes where rationale needs detail
├── adr/                           # Architecture Decision Records
│   ├── 001-monorepo.md
│   ├── 002-modular-monolith.md
│   ├── 003-schema-first.md
│   ├── 004-dark-luxury-design.md
│   └── NNN-<slug>.md              # one ADR per significant architectural decision
├── testing/
│   └── TESTING_STRATEGY.md
├── infra/
│   └── INFRA_OVERVIEW.md          # Azure resource map, cost progression, secrets strategy
├── runbooks/                      # Incident response runbooks
│   ├── database-failover.md
│   ├── queue-backlog.md
│   └── high-error-rate.md
└── permissions/
    └── ROLE_TEMPLATES.md          # Default role templates shipped with the platform
```

### PROJECT_STATUS.md Format (maintained every phase)

```markdown
# Synergia — Project Status

**Current phase:** Phase N — <name>
**Status:** NOT STARTED | IN PROGRESS | COMPLETE
**Last updated:** YYYY-MM-DD

## Done
- [ ] ...

## In Progress
- [ ] ...

## Next
Phase N+1 — <name>: <one-line summary>

## Quick Links
- Plan: Plans/GREENFIELD_REBUILD_PLAN.md
- Schema: docs/schema-design/SCHEMA.md
- Architecture: docs/ARCHITECTURE.md
- Getting started: docs/GETTING_STARTED.md
```

### ADR Format

```markdown
# ADR-NNN: <title>

**Status:** PROPOSED | ACCEPTED | SUPERSEDED
**Date:** YYYY-MM-DD

## Context
<why this decision was needed>

## Decision
<what was decided>

## Consequences
<trade-offs accepted>
```

### Rule
Every phase has a documentation deliverable. A phase is not complete until `docs/PROJECT_STATUS.md` is updated to reflect the new state.

---

## Step 5 — Design System

### Design Tooling

**Google Stitch** is used for all UI/component design work before implementation. Every new surface is designed in Stitch first — reviewed and approved — before a line of frontend code is written. Stitch outputs inform the component structure, spacing, and token values used in the React implementation.

### Visual Direction: Dark Luxury

Synergia targets professional operators managing serious commercial operations. The UI must feel premium, considered, and trustworthy — not a generic SaaS dashboard. The chosen direction is **dark luxury**: deep dark surfaces, warm gold accents, high contrast data typography, and motion that clarifies rather than decorates.

**Reference points:** Linear, Vercel dashboard, Raycast, Stripe Dashboard (dark mode) — data-dense but visually refined.

**Anti-patterns to avoid explicitly:** default Shadcn slate theme, generic sidebar + cards layout with no hierarchy, blue primary buttons on dark backgrounds, uniform radius and spacing across every component.

### Colour Palette (CSS custom properties — OKLCH)

```css
:root {
  /* Surfaces */
  --color-bg:          oklch(8% 0 0);        /* near-black base */
  --color-surface:     oklch(12% 0 0);       /* card / panel background */
  --color-surface-raised: oklch(15% 0 0);   /* elevated surfaces, modals */
  --color-border:      oklch(22% 0 0);       /* subtle borders */
  --color-border-active: oklch(35% 0 0);    /* hover/focus borders */

  /* Text */
  --color-text:        oklch(95% 0 0);       /* primary text */
  --color-text-muted:  oklch(60% 0 0);       /* secondary / metadata */
  --color-text-subtle: oklch(40% 0 0);       /* disabled / placeholder */

  /* Accent — warm gold */
  --color-accent:      oklch(75% 0.14 85);   /* gold primary action */
  --color-accent-dim:  oklch(55% 0.10 85);   /* muted gold for badges/tags */
  --color-accent-glow: oklch(75% 0.14 85 / 15%); /* subtle glow on focus */

  /* Semantic */
  --color-success:     oklch(65% 0.14 145);  /* green */
  --color-warning:     oklch(72% 0.16 65);   /* amber */
  --color-danger:      oklch(58% 0.20 25);   /* deep red */
  --color-info:        oklch(65% 0.12 240);  /* muted blue */
}
```

### Typography

- **Headings:** Geist (Vercel) — geometric, modern, high legibility at all sizes
- **Body / UI:** Inter — proven data-dense readability
- **Monospace / data values:** Geist Mono — order IDs, SKUs, tracking numbers, quantities
- **Urdu (`ur-PK`):** Noto Nastaliq Urdu — preferred Urdu typeface; subset to Urdu glyphs; loaded conditionally based on locale
- **Scale:** fluid via `clamp()` — never fixed px for type
- **Line-height for Urdu:** Nastaliq script needs more vertical rhythm — locale-aware line-height tokens (`--line-height-base-ltr` vs `--line-height-base-rtl`)

```css
--text-xs:   clamp(0.7rem,  0.65rem + 0.2vw, 0.75rem);
--text-sm:   clamp(0.8rem,  0.75rem + 0.2vw, 0.875rem);
--text-base: clamp(0.875rem, 0.82rem + 0.25vw, 1rem);
--text-lg:   clamp(1rem,    0.95rem + 0.3vw, 1.125rem);
--text-xl:   clamp(1.1rem,  1rem + 0.5vw, 1.5rem);
--text-2xl:  clamp(1.4rem,  1.2rem + 1vw, 2rem);
```

### Three Surfaces

- **Marketing site** (`synergia.co.uk`) — same dark luxury palette + gold accent; editorial typography; full-bleed hero sections; large product visuals; designed in Stitch first; feels premium, not corporate-template
- **Tenant App** (`app.synergia.co.uk`) — gold accent on deep dark surfaces; data-dense; every number legible at a glance; warm not cold
- **Platform Admin** — violet accent (`oklch(65% 0.18 290)`) replacing gold; visually distinct so staff never confuse admin context with tenant context

All three share `packages/design-tokens/` so colour, typography, spacing, and motion stay consistent. Visiting `synergia.co.uk` → signing up → landing in the app should feel like one continuous product, not a marketing site bolted onto an unrelated dashboard.

### RTL (right-to-left) support

Urdu is RTL — the entire UI mirrors when the locale is Urdu:
- All CSS uses **logical properties** (`margin-inline-start`, `padding-block-end`) — never `margin-left`/`padding-bottom`
- Tailwind `rtl:` modifier used for any case where logical properties don't apply
- Icons that imply direction (arrows, chevrons) flip via `[dir="rtl"]` selectors
- Charts and data tables stay LTR for numerical readability (international convention) — only the surrounding chrome flips
- Phase 2 ESLint rule + Stylelint rule blocks any `left`/`right`/`margin-left`/etc. in new CSS

### Project Structure

```
frontend/
├── src/
│   ├── components/
│   │   ├── ui/          # Shadcn primitives (generated, do not edit)
│   │   └── syn/         # Synergia custom components — dark luxury layer
│   ├── pages/           # Route components (React Router v6)
│   ├── features/        # Feature-scoped modules (orders/, inventory/, wms/, etc.)
│   ├── hooks/           # Shared custom hooks
│   ├── lib/             # API client, utilities, constants
│   ├── stores/          # Jotai atoms
│   └── styles/          # Tailwind config, CSS tokens, Geist font import
├── vite.config.ts
└── staticwebapp.config.json
```

### Custom Components

| Component | Purpose |
| --- | --- |
| `DataGrid` | Virtualised table with column pinning, bulk select, inline edit; gold row highlight on hover |
| `CommandPalette` | Cmd+K global search across orders/SKUs/channels; dark glass surface |
| `ScanInput` | Barcode-optimised input with audible feedback states |
| `LabelPreview` | ZPL/PDF label preview with print queue management |
| `ManifestPanel` | End-of-day carrier manifest builder |
| `OrderTimeline` | Immutable event log visualiser per order; vertical timeline with status nodes |
| `AuditTimeline` | Immutable audit log per resource; actor, action, diff view |
| `NotificationCentre` | Bell icon + slide-out drawer; per-notification read/dismiss; grouped by type |
| `NotificationPreferences` | Per-event-type delivery toggle (in-app / email / webhook / off) per user |
| `ConversationView` | Threaded marketplace message UI |
| `OpsKanban` | Pick wave / task board for warehouse floor |
| `SLAGauge` | Order SLA countdown rings per marketplace |
| `ForecastSparkline` | 30-day velocity trend + reorder threshold line |
| `ProfitabilityBar` | Per-SKU margin waterfall (revenue → fees → COGS → shipping → net) |
| `AutomationRuleBuilder` | No-code trigger/condition/action canvas |
| `PermissionMatrix` | Role editor showing resource × action grid; toggle individual permissions |
| `B2BOrderPortal` | Wholesale buyer-facing ordering surface *(deferred — 2027-plans)* |
| `ThreePLClientPortal` | 3PL client read-only inventory + order dashboard |
| `SupplierScorecard` | On-time %, lead time variance, invoice accuracy per supplier |
| `ReportBuilder` | Visual editor for `ReportSpec` (manual authoring path); same shape as AI-generated specs |
| `ReportRenderer` | Renders a `ReportSpec` result as table / bar / line / waterfall / KPI / pie |
| `DashboardGrid` | 12-col responsive drag-and-drop dashboard layout; resize/move widgets; mobile collapses to single column |
| `WidgetPicker` | Modal for selecting widget type from the 13-type catalogue; previews before adding |
| `WidgetConfigPanel` | Per-widget-type configuration form (metric/period/report/markdown/etc.) |
| `DashboardFilters` | Top-of-dashboard cascading filters (period / channel / warehouse) |
| `DashboardSharingDialog` | Visibility selector + permissioned users/roles + share link generation |
| `DashboardTemplateGallery` | Optional starting-point template picker — clone or skip |
| `KioskMode` | Full-screen widget rotation for warehouse-floor TV displays |
| `NicheExplorer` | Marketplace category browser with demand/competition/price stats |
| `ListingTracker` | Tracked competitor listings; price/stock/sales history charts |
| `KeywordLab` | Search-volume + competition table; reverse-listing keyword extractor |
| `OpportunityFeed` | AI-generated product/niche recommendation cards |
| `ResearchWorkspace` | Pinboard of researched items with notes + comparison + status flow |
| `ArbitrageSignals` | Cross-marketplace price-gap alerts with one-click cross-list action |
| `SupplierMatcher` | Image-match supplier candidates with landed-cost calculator |
| `WhiteSpaceFinder` | Niche hunter with population-level filters |
| `ReportScheduleEditor` | Cron schedule + delivery channel picker for a saved report |
| `CategoryRuleBuilder` | Condition DSL editor for auto-categorisation rules; AND/OR logic; drag-reorder by priority; dry-run preview showing how many products would match |
| `CategoryTree` | Hierarchical category browser with drag-to-nest; color tags; SKU count + avg margin badges per category |
| `PortfolioSelector` | Channel picker to define/edit portfolio membership; appears in portfolio settings and report filters |
| `ExpenseForm` | Expense entry form with scope toggle (company/channel), recurrence picker, and split allocation builder (equal/custom with percentage inputs that enforce sum = 100) |
| `ExpenseAllocationEditor` | Channel list with percentage sliders; live total indicator; blocks save if total ≠ 100% |
| `MonthlyClosePanel` | Period selector, pre-close checklist (open orders / unreconciled payouts / missing expenses), P&L summary table with company + per-channel + portfolio columns, lock/unlock controls, PDF download, historical close list |
| `ImportWizard` | Stepper UI for imports — choose resource → upload file → smart column auto-map → dry-run preview → validation report → commit; supports CSV/XLSX + competitor-format direct paths (Linnworks, StoreFEEDER, Shopify, eBay) |
| `ImportTemplates` | Downloadable CSV/XLSX templates per resource with example rows + per-column docs |

### Motion & Interaction

- Compositor-only properties: `transform`, `opacity`, `clip-path` — never `width`/`height`/`top`/`left`
- Entry animations: fade + 4px upward translate, 180ms `cubic-bezier(0.16, 1, 0.3, 1)` — fast, purposeful
- Data updates: number count-up on metric cards; subtle pulse on real-time value change
- `prefers-reduced-motion` respected — all animations disabled when set
- No decorative loaders; skeleton screens only, dark surface with shimmer in gold tint

---

## Step 6 — Phased Implementation Plan

### Phase 0 — External API Research & Schema Mapping

> 🛑 **NON-NEGOTIABLE.** Phase 0 is the most important phase in the entire rebuild. **Phase 1 cannot start until Phase 0 acceptance is signed off.** No exceptions.

**Goal:** Deeply understand every external data source before writing a single line of schema. No application code produced — outputs are structured research documents in `docs/api-research/`.

#### 🎯 Schema-First Principle (V1 lesson)

**V1 was rebuilt as V2 because we built schema before fully exploring external APIs.** We added eBay first, made schema decisions based on eBay's data model, then discovered TikTok Shop / Vinted / Amazon don't fit those decisions. The fix-on-the-fly response was nullable bolt-ons, JSONB dumping grounds, and inconsistent idempotency strategies. By the time the third marketplace was wired, the schema was a mess.

**The rebuild rule, enforced absolutely:**

1. **Every external API is researched before any schema column is decided.** Not "the ones we plan to ship at launch" — *every* API the platform will integrate with through Phase 17. Discovering Amazon's quirks in Phase 12 is too late.
2. **Every research finding maps to a schema implication in `SCHEMA_IMPACT.md`.** No finding is captured without its schema consequence documented.
3. **Phase 0 is over when `SCHEMA_IMPACT.md` has zero TBD entries** — not when the calendar says it's over.
4. **Phase 1 cannot start without Phase 0 sign-off** by the architect + founder. The sign-off is recorded in `docs/PROJECT_STATUS.md` with an explicit "Phase 0 — APPROVED" entry.
5. **No nullable bolt-ons.** If a research finding implies a new column, that column is added to the locked schema in Phase 1 with `NOT NULL` and a default — not nullable for "we'll figure it out later." Nullable columns added post-lock require a written justification ADR.
6. **No JSONB dumping grounds.** Specific marketplace fields go into typed columns. `external_data JSONB` is reserved only for genuinely platform-specific extra fields that don't appear elsewhere — and even then, every key inside the JSONB is documented in the research.
7. **The schema must answer a hostile review:** "What happens when we add Amazon (multi-currency)? What happens when an EU buyer orders from a UK seller (IOSS)? What happens when a 3PL onboards a 4th brand? What if Vinted releases a returns API in 2027?" If the schema requires structural changes for any of these, Phase 0 is not done.

**If Phase 0 takes longer than estimated, the timeline slips. We do not start Phase 1 with unfinished research. The cost of getting this wrong is another V2 rewrite.**

**Rationale:** Schema decisions made without knowing the full data models of eBay, Amazon, TikTok Shop, Royal Mail, etc. result in perpetual patching — nullable columns bolted on later, missing idempotency keys, fee fields that don't match reality. Two weeks of research here saves months of migrations later. **One year of V1 history confirms this.**

**No infrastructure spend this phase.**

**Marketplaces to investigate:** eBay, TikTok Shop, Amazon SP-API, Etsy, Vinted, Shopify, WooCommerce

For each marketplace, document:
- **OAuth flow:** token lifecycle, scopes, refresh strategy, webhook registration endpoint
- **Listing model:** every required + optional field, category-specific attributes (eBay item specifics, TikTok category fields), variation/variant model, image requirements, pricing fields, inventory quantity fields
- **Order model:** full payload structure, line item fields, buyer info fields, shipping address fields, status enum (every possible value), marketplace-assigned IDs and how they relate to each other
- **Webhook events:** full event type list, complete payload structure per event type, where the idempotency key lives in each payload
- **Returns / disputes:** claim types (INR, SNAD, INAD, etc.), lifecycle states, required response fields, response deadline windows, escalation path
- **Messaging:** thread model, message fields, SLA windows per marketplace
- **Account health:** metric names, threshold values, defect rate definitions, how Synergia must respond
- **Fees / payouts:** fee structure (percentage of sale? fixed? both?), when fees are known (at listing? at sale? at payout?), payout report format and fields
- **Rate limits:** per-endpoint documented limits, quota window type (daily/rolling/per-second), Retry-After header behaviour, sandbox vs. production limits
- **External IDs:** how the marketplace identifies listings, orders, and line items — document every ID type (e.g. eBay: `ItemID` + `TransactionID`; Amazon: `ASIN` + `FNSKU` + merchant SKU; TikTok: `product_id` + `sku_id` + `order_id`) and which ones we need to store and index

**Carriers to investigate:** Royal Mail (Click & Drop / OBA API), Evri, DPD

For each carrier, document:
- **Label request model:** every required + optional field, service codes enum, parcel dimension/weight fields, sender/recipient address fields
- **Rate quote request/response:** required inputs, full response structure (price, ETA, service name, service code)
- **Tracking event model:** event codes enum, status enum, estimated delivery field, location fields
- **Manifest / collection booking model:** end-of-day manifest structure, collection booking fields

**Payment:** Stripe — document subscription object fields, all webhook event types and payload structures, Customer Portal session fields, invoice fields, usage record fields (for metered billing).

**Documentation deliverable:** `docs/PROJECT_STATUS.md` created (Phase 0 — IN PROGRESS); `docs/adr/003-schema-first.md` written; `Plans/AI_COST_MODEL.md` validated against 100 real prompt examples (replaces token estimates with measured averages); Anthropic pricing confirmed in writing; final plan-tier prices locked in collaboration with finance.

**Vinted Pro Integrations prep (decided 2026-05-07 — Vinted stays in Phase 5 launch trio):**
- ☐ Confirm whether pilot client already has Vinted Pro Integrations API access (vs only Vinted Pro selling account); if not, apply for allowlist via https://www.vinted.fr/pro/integrations
- ☐ Capture pilot client's current active Vinted listing count; if > 500, open negotiation with Vinted for slot allocation increase as part of allowlist conversation
- ☐ Document HMAC-SHA256 auth flow in `docs/api-research/vinted.md` (it's not OAuth — `MarketplaceAdapter` ABC must support both auth shapes)
- ☐ Document the operational caveats explicitly in research doc: returns / disputes / messaging / account health / feedback / payouts are NOT exposed by Vinted API and remain operator workflows in the Vinted UI
- ☐ Validate sandbox at `pro-public-sandbox.svc.vinted.com` works end-to-end: register webhook, push test item, trigger sold event, receive order via webhook
- ☐ Probe rate limits in sandbox (Vinted does not document them) and set conservative token-bucket budget for production

**Deliverables:**
- `docs/api-research/ebay.md`
- `docs/api-research/tiktok-shop.md`
- `docs/api-research/amazon.md`
- `docs/api-research/etsy.md`
- `docs/api-research/vinted.md`
- `docs/api-research/shopify.md`
- `docs/api-research/woocommerce.md`
- `docs/api-research/royal-mail.md`
- `docs/api-research/evri.md`
- `docs/api-research/dpd.md`
- `docs/api-research/stripe.md`
- `docs/api-research/SCHEMA_IMPACT.md` — cross-cutting document: for each research finding, notes the schema implication (e.g. "eBay TransactionID must be stored separately from ItemID → `channel_listings.external_order_line_id`")

**Acceptance criteria (all must pass — Phase 0 cannot be marked complete with any unchecked):**

_Per-API research completeness:_
- ☐ Every marketplace has a documented field-by-field order model and webhook payload (eBay, TikTok Shop, Vinted, Amazon SP-API, Etsy, Shopify, WooCommerce — yes, including those that ship in Phase 12+ and Phase 16; researching them now means schema accommodates them)
- ☐ Every carrier has a documented label request model + rate quote response model + tracking event model + manifest model (ShipStation, Royal Mail, Evri, DPD)
- ☐ Stripe research covers every webhook event type and subscription field used through Phase 17 (including future enterprise scenarios)
- ☐ Tier-C external feeds (Keepa, DataForSEO, Google Trends, AliExpress) researched at least at field-shape level — even though they ship Phase 15, schema for `market_universal_products` must accommodate them now

_Schema-impact completeness:_
- ☐ `SCHEMA_IMPACT.md` exists and has been reviewed — **zero "TBD" entries**, **zero "we'll decide later"**, **zero "to be confirmed"**
- ☐ Every external ID type captured in research has a corresponding `external_id` strategy decision (which IDs we store, which we index, which we treat as canonical for cross-marketplace identity)
- ☐ Every webhook payload has a documented idempotency key strategy (where the key lives in the payload, format, uniqueness guarantee)
- ☐ Every fee field across marketplaces has a capture strategy: at-listing / at-sale / at-payout, and what we do when fee data isn't available at order ingest

_Sandbox proof of life:_
- ☐ Working sandbox account secured for every marketplace + carrier + Stripe (registered, accessed, OAuth/HMAC tested for at least one round-trip per API)
- ☐ One real webhook delivery received per marketplace (eBay listing-changed, TikTok order-created, Vinted item-sold, etc.) — proves the integration shape works
- ☐ One real label generated per carrier (ShipStation + Royal Mail at minimum; Evri + DPD nice-to-have)

_Cost model validation:_
- ☐ `Plans/AI_COST_MODEL.md` token estimates validated against ≥ 100 real prompt examples; estimates within ±20% of measured
- ☐ Anthropic pricing confirmed in writing
- ☐ Plan-tier prices locked with finance

_External preconditions resolved:_
- ☐ Vinted Pro Integrations allowlist applied / confirmed (D5)
- ☐ Pilot client's active Vinted listing count captured + slot-allocation negotiated if > 500
- ☐ Amazon SP-API app registration submitted (long lead time)
- ☐ All other adapter sandbox accounts active

_Hostile-review walkthrough:_
- ☐ Architect + founder sit down with `SCHEMA_IMPACT.md` and walk through the four scenarios:
  - "What happens when we add Amazon's SP-API in Phase 12?"
  - "What happens when an EU buyer orders from a UK seller (IOSS / facilitator VAT)?"
  - "What happens when a 3PL onboards a 4th brand?"
  - "What happens if Vinted releases a returns API in 2027?"
- ☐ For each scenario, the answer is "no schema structural change needed." If any answer is "we'd need to migrate," go back and fix the research / schema impact before continuing.

_Sign-off:_
- ☐ `docs/PROJECT_STATUS.md` records explicit "Phase 0 — APPROVED" entry with date + signatories (architect + founder). Phase 1 work is forbidden until this is logged.

**Risks:** Vinted API access may require seller volume threshold — **confirm access in this phase before Phase 1 schema lock (D5). If Vinted access is uncertain at our target customer volume, drop from Phase 5 trio and replace with Etsy.** Amazon SP-API requires app registration; apply early as approval can take days. AI Cost Model token estimates may diverge from reality by > 20% — validate against actual prompts in this phase before plan-tier prices are locked.

---

### Phase 1 — Schema Design & Lock
**Goal:** Translate Phase 0 research into a final, peer-reviewed schema. No migration runs until this is signed off. This is the single most important phase in the project.

**Rationale:** The schema is the contract everything else is built on. A column added wrong now costs a migration + data backfill + potential downtime later. Phase 0 research gives us the full picture; Phase 1 turns it into a schema that won't need patching.

**No infrastructure spend this phase.**

**Deliverables:**
- `docs/schema-design/SCHEMA.md` — every table documented with: purpose, every column (name, type, nullable, rationale), indexes, foreign keys, and which Phase 0 research finding drove each decision
- **External ID strategy:** how each marketplace's identifiers map to `channel_listings` — document the `external_id` + `external_data JSONB` pattern decision per platform
- **Webhook inbox design:** idempotency key strategy per platform (where in each payload the idempotency key lives, format, uniqueness guarantee)
- **Fee capture strategy:** for each marketplace, document exactly what fee data is available via API at what point in the order lifecycle — determines what can go in `order_line_costs` vs. what must be estimated
- **Currency strategy:** confirm base currency on `companies`, currency tracking on every monetary table, FX rate source (Open Exchange Rates / ECB) and refresh schedule, base-currency normalisation for analytics — all locked here, not bolted on later
- **Tax strategy:** UK VAT, EU OSS/IOSS, marketplace facilitator rules (eBay/Amazon collect VAT for sub-£135 imports / sub-€150 EU); per-SKU tax codes; jurisdiction-aware tax calculation; document where tax data is captured per marketplace from Phase 0 research
- **Customer entity strategy:** `customers` as first-class entity (not hidden inside orders); buyer-to-customer matching rules per marketplace (some marketplaces give consistent buyer IDs, some don't); de-duplication strategy
- **Channel buffer stock model:** decision locked on whether to use `channel_listing_stock_rules` (reserve qty + max %) or simpler global "available_to_channels = stock - buffer"
- **3PL shadow-tenant model:** decision locked on `3pl_relationships` (each managed brand is a real `company`) vs. token-scoped sub-tenant — affects auth, permissions, billing
- **Enum definitions:** every status enum for orders, listings, returns, shipments, cases, RTV, stock takes — sourced directly from Phase 0 research, not guessed
- **Permission resource × action matrix:** enumerate every `resource` slug and every `action` value that will exist — this is the contract `PermissionMatrix` and every API attribute is built against; adding a new action later is a schema + API + UI change
- **Audit log schema:** confirm `old_value`/`new_value` JSONB approach vs. column-level diff table — decision locked here
- **Notification event type registry:** enumerate every `event_type` value that will exist across all phases — registered in a `notification_event_types` lookup table, not hardcoded strings
- **GDPR retention policy schema:** per-resource retention rules; auto-purge schedule; DSAR (data subject access request) workflow tables locked here
- **Locale strategy:** launch locales locked (`en-GB` baseline + `ur-PK`); `users.preferred_locale` and `companies.default_locale` columns confirmed; locale resolution chain decided (URL > user preference > company default > browser `Accept-Language` > `en-GB`); RTL handling strategy documented (CSS logical properties throughout, `dir` attribute on `<html>`, no `left`/`right` in any styles); ICU MessageFormat chosen for pluralisation
- **ReportSpec schema:** the structured JSON contract that AI authors and saved reports execute. Locked here. Defines: allowed `metric` values (e.g. `revenue`, `net_margin`, `units_sold`, `return_rate`), allowed `dimension` values (`sku`, `channel`, `warehouse`, `customer`, `period`), allowed `filter` operators (`eq`, `gt`, `lt`, `between`, `in`), allowed `aggregate` functions (`sum`, `avg`, `count`, `min`, `max`), allowed `compare_to` periods (previous_period, same_period_last_year, custom), allowed `visualisation_type` (table/bar/line/waterfall/kpi/pie). Adding a new metric/dimension later requires a schema doc update — AI cannot generate fields not in this contract (security + correctness boundary).
- **Report engine architecture:** decision locked on whether reports run as Dapper queries (preferred — direct hand-tuned SQL per metric, fast) vs EF Core LINQ (slower, harder to optimise). Documented per-metric query strategy.
- **Dashboard widget catalogue:** all 13 widget types defined upfront (kpi, sparkline_kpi, chart, table, live_counter, activity_feed, goal, note, heading, image, embed, shortcut, filter); each widget's `config_json` schema locked; new widget types require schema doc update + AI prompt update — adding a widget type is a deliberate, versioned change, not an ad-hoc addition.
- **Universal product identity (research-tier C):** decision on the canonical identifier for "the same physical product across marketplaces" — composite of (EAN/UPC/GTIN if present) + (ASIN if Amazon) + (AI image vector hash) + (title fuzzy match). Locked in Phase 1 because Tier-C features (arbitrage detection, supplier matching) depend on this identity model from day one. Even though Tier C ships in Phase 15, the columns exist on `products` / `product_variants` from Phase 2 baseline.
- **External market data feed strategy:** decide which Tier-C feeds we integrate (Keepa, DataForSEO, Google Trends, AliExpress/Alibaba search), the cost model (per-tenant subscription vs. shared platform-paid pool), and which features go behind a Pro plan tier. Documented before Phase 15 implementation; informs `market_data_feeds` and `market_data_subscriptions` schema.
- **EF Core entity class stubs** — C# `partial class` files for every entity, no `DbContext` yet, no migration — just the shape reviewed and approved
- **Review checklist** — every table in the schema cross-referenced against Phase 0 research; signed off that no known external field is unaccounted for; explicit walkthrough of: "what happens when we add Amazon (multi-currency)?", "what happens when an EU buyer orders from a UK seller (IOSS)?", "what happens when a 3PL onboards a 4th brand?"

**Documentation deliverable:** `docs/schema-design/SCHEMA.md` (STATUS: LOCKED); `docs/schema-design/PERMISSION_MATRIX.md`; `docs/schema-design/NOTIFICATION_EVENT_TYPES.md`; `docs/PROJECT_STATUS.md` updated to Phase 1 COMPLETE.

**Lock criteria:** No EF Core baseline migration is created until `docs/schema-design/SCHEMA.md` is marked `STATUS: LOCKED`. Future schema changes require a new EF Core migration AND a retroactive update to `SCHEMA.md` explaining why.

**Acceptance criteria:**
- Every table in the schema has a rationale comment
- Every external ID type from Phase 0 research appears somewhere in the schema
- Every webhook payload idempotency key strategy is documented
- No table has a nullable `company_id`
- EF Core entity stubs compile cleanly (no logic, just properties)
- Schema reviewed against: "what happens when we add Amazon?" and "what happens when we add a 4th carrier?" — no structural changes required

**Risks:** Schema review may surface gaps that require going back to Phase 0 research for specific APIs. Budget one iteration loop between Phase 0 and Phase 1 before locking.

---

### Phase 2 — Infrastructure & Repo Foundation
**Goal:** New repo, CI/CD, schema v1 with all tenant-scoped tables, zero nullable company_ids.

**Azure infrastructure tier:** Consumption / serverless only. Estimated cost: **~£80–100/month** (deferred free-tier resources where possible — see earlier discussion).

| Service | Tier | Purpose |
| --- | --- | --- |
| Azure SQL | Serverless — General Purpose, 1–4 vCores (auto-pause after 1h inactivity) | Primary DB; ~£30–50/month when active; £0 when paused |
| Azure Container Apps | Consumption plan (scale to zero) | API only; no charge when idle |
| Azure Static Web Apps | Free tier | Frontend SPA hosting; global CDN; free SSL; preview envs per PR |
| Azure Cache for Redis | Basic C0 (£15/month) — defer to Phase 3 | Rate limits, locks; use in-memory until first paying customers |
| Azure Blob Storage | LRS Hot | Labels, images, seeds |
| GitHub Container Registry | Free (replaces ACR Basic) | API Docker image storage; free for private repos |
| Application Insights | Free tier (5 GB/month) | Traces, exceptions |
| Azure Key Vault | Standard | Secrets via managed identity |
| GitHub Actions | Free tier | CI/CD for all four workflows |

**Deliverables:**
- Monorepo: `src/Synergia.Api/`, `src/Synergia.Workers/`, `src/Synergia.Mcp/`, `frontend/`, `marketing/`, `mobile/` (scaffolded, empty), `packages/api-types/`, `packages/design-tokens/`, `infra/`, `docs/`
- `docs/ARCHITECTURE.md` — component diagram, data flow, infrastructure map
- `docs/GETTING_STARTED.md` — clone → docker compose up → seed → verify
- `docs/infra/INFRA_OVERVIEW.md` — Azure resource list, tiers, cost, secrets strategy
- `docs/adr/001-monorepo.md`, `docs/adr/002-modular-monolith.md`, `docs/adr/004-dark-luxury-design.md`
- `docs/testing/TESTING_STRATEGY.md` — full pyramid, tools, CI config, schedule, coverage thresholds
- `docs/infra/INFRA_OVERVIEW.md` — Azure resource map, cost progression, secrets strategy
- `docs/runbooks/database-restore.md`, `docs/runbooks/secrets-rotation.md`, `docs/runbooks/high-error-rate.md`
- Health check endpoints (`/health/live`, `/health/ready`, `/health/startup`) wired and tested
- Correlation ID middleware wired; all log lines include `{CorrelationId}` and `{CompanyId}`
- Azure Monitor alert rules defined in `infra/modules/monitoring.bicep`
- Idempotency middleware wired; `idempotency_keys` table in baseline migration
- `docs/PROJECT_STATUS.md` updated to Phase 2 COMPLETE
- ASP.NET Core 8 Web API skeleton with `RequireCompanyScope` middleware/filter wired on every controller
- EF Core baseline migration implementing the Phase 1 locked schema (`docs/schema-design/SCHEMA.md`) — `dotnet ef migrations add InitialSchema`; every table and column must match the approved schema exactly
- `StubMarketplaceAdapter` + `StubCarrierAdapter` implementing C# interfaces; registered in DI
- Hangfire wired for background jobs; Azure Storage Queue connection configured
- Vite + React app scaffolded (`npm create vite@latest frontend -- --template react-ts`); Shadcn/ui initialised; Tailwind configured; React Router v6 wired
- `staticwebapp.config.json` configured: all routes → `index.html` (SPA fallback), CORS headers for API calls
- **Marketing site scaffolded** (`npm create astro@latest marketing -- --template minimal --typescript strict`): Tailwind + MDX integrations, `packages/design-tokens/` consumed for shared colour/typography
- **Marketing MVP page set:** home (hero + value prop + waitlist form), pricing (free tier + plan teaser), about, contact — all pages dark-luxury themed, Lighthouse perf ≥ 95
- **Waitlist form** wired to `/api/public/marketing/lead` (writes to `marketing_leads`); double-opt-in email via Azure Communication Services
- **Analytics: Plausible Cloud** (~£8/month) — privacy-first, no cookie banner needed (D17)
- **No third-party CMP** (D18) — minimal first-party consent UI built in-house; no marketing cookies until Phase 11+ when revisit if needed
- DNS: `synergia.co.uk` apex + `www.synergia.co.uk` → marketing SWA; `app.synergia.co.uk` → frontend SWA; `api.synergia.co.uk` → Container Apps via Front Door (added Phase 10)

_Internationalisation foundation (i18n / l10n) — NEW_
- `packages/locales/` initialised with `en-GB` baseline (full string set extracted from MVP screens)
- **Frontend (app):** `react-i18next` wired; `useTranslation()` hook used in every component; zero hardcoded strings; ESLint rule blocks raw text in JSX
- **Marketing site:** Astro built-in i18n routing — default locale at `/`, Urdu at `/ur/`; per-page `hreflang` tags + canonical URLs
- **Backend:** `IStringLocalizer<T>` for API error messages, validation messages, transactional emails; resource files (`.resx`) per locale
- **Locale detection middleware:** resolves locale per request from URL → user preference → company default → `Accept-Language` → fallback `en-GB`
- **CSS logical properties throughout:** `margin-inline-start` not `margin-left`; Tailwind `rtl:` utilities ready
- **Locale switcher** in app top nav and marketing site footer
- **Date/number/currency formatters:** all UI rendering goes through `Intl.DateTimeFormat`, `Intl.NumberFormat` — never hardcoded format strings
- **Urdu (`ur-PK`) — translation kit ready:** translation keys defined in `en-GB`; Urdu locale file exists with English fallback; full Urdu translation rolled out in Phase 5 alongside marketing site feature pages
- **Noto Nastaliq Urdu** font loaded conditionally when locale is Urdu; subset to Urdu glyphs only
- Docker Compose local dev: SQL Server (or `mcr.microsoft.com/mssql/server`), Redis, ASP.NET Core API; Vite runs separately via `npm run dev`
- GitHub Actions — five path-filtered workflows (each deploys independently):
  - `api.yml` (triggers: `src/**`, `packages/api-types/**`): `dotnet build` → `dotnet test` → EF migration check → push image to GHCR → deploy Container Apps revision
  - `frontend.yml` (triggers: `frontend/**`, `packages/api-types/**`, `packages/design-tokens/**`): `npm ci` → `npm run build` → deploy to Azure Static Web Apps via `azure/static-web-apps-deploy@v1`
  - `marketing.yml` (triggers: `marketing/**`, `packages/design-tokens/**`): `npm ci` → `astro build` → Lighthouse CI gate (perf 95+, SEO 100, a11y 100) → deploy to Azure Static Web Apps
  - `mobile.yml` (triggers: `mobile/**`, `packages/api-types/**`): `eas build` → EAS Submit (App Store + Play Store); OTA update via Expo Updates for patch releases — scaffolded in Phase 0, activated in Phase 9
  - `infra.yml` (triggers: `infra/**`): `az deployment group create` for dev on push; prod requires manual approval gate
- Application Insights SDK wired; structured JSON logging via Serilog → App Insights sink
- Azure Key Vault referenced via `DefaultAzureCredential` (managed identity in Azure, local dev credential locally)
- Seed script: 2 companies, 5 users with varied roles, stub channel per company; idempotent
- Azure Cost Management budget alert at £150/month

**Acceptance criteria:**
- `dotnet ef migrations list` shows exactly one migration applied, no pending
- All 50+ tables exist with `company_id NOT NULL` — verified by integration test scanning `information_schema`
- `RequireCompanyScope` returns 403 when no company context — unit tested
- Frontend deploys to SWA on push to `main`; PR branch gets a preview URL automatically
- Marketing site deploys to `synergia.co.uk` on push to `main`; Lighthouse CI gate enforces perf 95+ / SEO 100 / a11y 100
- Waitlist form on marketing site successfully writes to `marketing_leads` and triggers double-opt-in email
- ESLint rule blocks any raw text in JSX (must use `t('key')`); zero hardcoded strings in `frontend/`
- `dir="rtl"` correctly applied when locale is `ur-PK`; layout flips correctly verified via Playwright visual test
- Switching locale in the app updates the UI without a page reload; user's `preferred_locale` persisted
- CI green from first commit; API pipeline fails if EF Core migrations are pending
- Application Insights receives traces from local dev (smoke test)

**Risks:** Schema is locked from Phase 1 — if a gap is discovered during implementation, go back to Phase 1 review and update `SCHEMA.md` before adding columns. Do not bolt on nullable columns to make things work quickly.

---

### Phase 3 — Auth, RBAC, Billing
**Goal:** Users can sign up, create a company, choose a plan, and have roles enforced on every screen.

**Azure infrastructure tier:** No changes from Phase 2. Still consumption/serverless. ~£80–100/month.

**Deliverables:**

_Auth_
- JWT + refresh token rotation; magic link + password flows
- Company creation wizard (onboarding flow) — includes locale picker (defaults to user's browser locale; saved to `users.preferred_locale` and `companies.default_locale`)
- Transactional emails (verify, reset password, magic link, invite) sent in user's `preferred_locale`

_RBAC — action-level permissions_
- `company_roles` — named roles per company (e.g. Warehouse Operator, Account Manager, Finance)
- `company_role_permissions` — `(role_id, resource, action, allowed BOOL)` where `resource` is a page/section slug and `action` is one of: `view`, `create`, `edit`, `delete`, `export`, `approve`, `cancel`, `assign` — not just page on/off
- `company_user_permission_overrides` — per-user overrides that supersede role defaults (grant or deny individual actions)
- Permission resolution chain: user override → company role → global role template → deny
- `PermissionMatrix` component: role editor showing resource × action grid; toggle individual cells; bulk copy from template
- Every API endpoint enforces action-level check via `[RequirePermission("orders", "cancel")]` attribute — not just auth
- Permission change events written to audit log

_Audit Log_
- `audit_log` table: `id`, `company_id`, `user_id`, `actor_type` (user/ai_assistant/system), `action`, `resource_type`, `resource_id`, `old_value JSONB`, `new_value JSONB`, `ip_address`, `user_agent`, `session_id`, `timestamp` — append-only, no updates or deletes ever
- Every API write operation (POST/PUT/PATCH/DELETE) automatically writes an audit entry via middleware — zero per-endpoint boilerplate
- `AuditTimeline` component: per-resource immutable event log with actor, action, and diff view (old → new values)
- Global audit trail page for platform admins: filterable by company, user, resource type, action, date range
- Audit log is excluded from tenant data exports (compliance: operators cannot delete their own audit trail)

_Notifications_
- `notification_events` table: `id`, `company_id`, `user_id`, `event_type`, `title`, `body`, `resource_type`, `resource_id`, `read_at`, `created_at`
- `notification_preferences` table: `(user_id, event_type, channel)` where `channel` ∈ `{in_app, email, webhook}` — defaults to in_app for all, user can opt out per channel per event type
- `NotificationCentre` component: bell icon in navbar with unread count badge; slide-out drawer grouped by type; mark read/dismiss; "mark all read"
- `NotificationPreferences` page: per-event-type delivery toggles (in-app / email / webhook / off)
- Real-time delivery to in-app centre via SignalR (same backplane as WMS — no new service needed until Phase 7)
- Email delivery via Azure Communication Services for email-enabled notifications
- All notification templates customisable per company (subject + body with variable substitution)
- Initial event types wired in Phase 3: login from new device, role changed, permission changed, subscription status changed

_Billing_
- Stripe integration: subscription creation, plan tiers, Customer Portal, webhook handler
- Billing UI: plan selector, usage dashboard, upgrade/downgrade flow
- Platform admin: company list, plan overrides, manual subscription management
- **Plan tiers locked (D1, D13, D24):**
  - **Free** — 1 channel, 1 user, 1 warehouse, 100 orders/month, 50 SKUs; ops only; **no AI features**; basic dashboards
  - **Starter** — paid baseline; full ops; Tier-A research insights; AI features with low caps
  - **Growth** — multi-user, multi-warehouse, multi-channel; Tier-B Marketplace Research; AI features at standard caps
  - **Scale** — full Tier-C research with monthly Keepa/DataForSEO quota included; higher AI caps; advanced RBAC
  - **Enterprise** — unlimited managed brands (3PL), zone-redundant HA, dedicated support
- **3PL all-inclusive (D1):** Starter (1 brand), Growth (5), Scale (20), Enterprise (unlimited). No per-brand line items.
- **AI cost enforcement:** per-feature daily token caps + monthly aggregate ceiling per company; soft warn at 80%, hard cap at 100%

_Marketing site (Phase 3 update)_
- Pricing page connected to live plan data (free/starter/growth/scale/enterprise)
- "Sign up" CTA on marketing site → routes to `app.synergia.co.uk/signup` (real onboarding flow)
- Conversion tracking: which marketing page → sign-up → paid conversion (UTM persisted through sign-up flow)
- Legal pages live: Privacy, Terms, DPA, Sub-processors, Cookie policy

**Acceptance criteria:**
- User can sign up → create company → subscribe to plan → access gated by role
- A role with `orders.cancel = deny` cannot call `DELETE /api/orders/:id/cancel` — returns 403
- A user-level override granting `orders.export` overrides a role that denies it
- Every API write operation appears in `audit_log` within the same DB transaction — no writes without audit entries
- Changing a user's role writes an audit entry with `old_value` and `new_value`
- Notification delivered to in-app centre within 2 seconds of triggering event
- User disabling email for `low_stock` notifications stops email delivery for that event type; in-app still delivered
- Downgrade removes access to premium-plan screens immediately
- Stripe webhook handler is idempotent (duplicate events safe)

**Risks:** Action-level permission matrix has combinatorial complexity — define the full resource × action matrix in Phase 1 schema design before implementation. Notification fanout at scale needs rate limiting to avoid email storms on bulk operations.

---

### Phase 4 — Product Catalogue, Inventory & Foundation Models
**Goal:** Sellers can build a rich product catalogue, manage tax + currency setup, and see real inventory levels across locations. Customer entity foundation in place.

**Azure infrastructure tier:** No changes from Phase 2. ~£80–100/month. Add Azure Communication Services (pay-per-email, ~£5/month) for invite emails.

**Deliverables:**

_Product catalogue_
- Product + variant CRUD (with images to Azure Blob)
- **Structured `product_attributes`** — category-specific key/value attributes (size, colour, material, etc.) — searchable & filterable, not just channel JSON
- **Bill of Materials (kits/bundles/combos) builder** — `product_bom` + `product_bom_items` with `quantity` per component; supports multi-product combos (1× A + 2× B + 1× C) and multipacks (6× A); availability derived from component stock; pre-kitting decision documented
- **Variation groups** — `variation_groups` mapping cross-marketplace variations (eBay variations ↔ Amazon parent-child ASIN ↔ Shopify variants) — schema in place even though channel-specific behaviour ships in Phase 5+

_Tax & Currency setup (NEW)_
- Per-company `base_currency`, `country_code`, `vat_number`
- Tax code library (Standard/Reduced/Zero/Exempt) per jurisdiction (UK VAT default; EU jurisdictions added later)
- Per-variant tax code assignment (`product_tax_codes`)
- Currency selector on monetary fields; FX rate auto-fetch (Open Exchange Rates / ECB) as nightly Hangfire job; rate stored in `fx_rates`

_Customers / Buyers (NEW)_
- `customers` CRUD + address book (`customer_addresses`)
- Customer notes + tags (VIP, fraud_risk, etc.)
- Customer-to-channel buyer mapping (`customer_channels`) — populated automatically from Phase 6 onwards

_Inventory_
- Warehouse + location management (multi-site, bin/aisle/rack)
- Stock level initialisation (manual import + CSV)
- Stock movement ledger (immutable append-only)
- Goods received notes (PO → GRN workflow)

_Suppliers & POs_
- Supplier management CRUD
- **Supplier management depth:**
  - PO lifecycle: draft → submitted → confirmed → in-transit → received
  - Lead time tracking: expected vs. actual delivery date per PO
  - Supplier contact management
  - Email PO to supplier directly from platform; supplier reply tracked
  - PO currency support (orders to overseas suppliers in supplier currency)
- **Returns to Vendor (RTV) workflow** — faulty stock returned to supplier; distinct from customer returns; tracks supplier credit
- **Advanced replenishment:** multi-supplier comparison for a SKU (price, lead time, last scorecard score) — one-click PO creation from comparison view; respects supplier MOQ and lead time

_Inventory dashboard_
- Stock by location, low-stock view, value of stock on hand (in base currency)

_Smart Category Management (NEW)_
- Hierarchical category tree CRUD: root categories + unlimited child levels; color tags + icon slugs for visual scanning
- **Category rules engine:** condition DSL supporting — title contains keyword(s), SKU matches regex, price range (≥/≤/between), channel is/is not, supplier is, product attribute value matches; conditions combinable with AND/OR
- Priority-ordered rules: rule with lowest priority number is evaluated first; first match wins (or "match all" mode per rule)
- Rule run modes: `run_on_import` (auto-categorise when a product is imported via channel onboarding), `run_on_save` (re-evaluate when product is edited)
- Manual override: operator can manually assign a category; manual assignments are not overwritten by future rule runs unless operator explicitly chooses "re-run rules" on that product
- Bulk operations: "Run all active rules against selected products" — shows preview (X products would change) before committing
- Category stats: SKU count, average net margin (from Phase 10 onwards), total stock on hand value per category

_Portfolio Management (NEW)_
- Portfolio CRUD: create named groupings of channels (e.g. "UK Marketplaces", "EU Expansion", "Social Commerce")
- One channel can belong to multiple portfolios; portfolio view filters by its member channels
- Portfolio-level summary panel: aggregate revenue, order count, return rate, gross margin across member channels for a selected period (placeholder data until order pipeline is live in Phase 6)
- Portfolio selector widget (wired to Phase 10 channel P&L reports)

_Expense Management setup (NEW)_
- Expense category CRUD (user-defined; pre-seeded with: Rent & Premises, Staff & Payroll, Software & Subscriptions, Advertising & Promotions, Shipping Overhead, Platform Fees, Professional Services, Other)
- Expense entry: amount, currency, date, category, scope (company-level / channel-level), description, recurrence (one-off, monthly, quarterly, annual), optional reference (invoice number)
- **Channel-level expenses** (`scope = channel_level`): directly attributed to a single channel; no allocation needed; appear in that channel's P&L immediately
- **Company-level expenses** (`scope = company_level`): overhead expenses with three allocation options:
  - **Unallocated** — records as company overhead only; not divided across channels
  - **Equal split** — system creates equal-percentage `expense_channel_allocations` rows across all currently active channels at time of entry
  - **Custom split** — operator selects channels and assigns a percentage to each (UI enforces sum = 100% before save)
- Expense list view: filterable by date range, category, scope, channel; export to CSV/XLSX
- Recurring expenses generate `expenses` rows automatically via Hangfire on their recurrence schedule

**Acceptance criteria:**
- Creating a kit/combo product correctly decrements component stock on sale at the BOM-defined quantities
- A 6-pack multipack (one product × 6 quantity) correctly decrements 6 from the underlying SKU per sale
- Stock movements are immutable; corrections create new movement rows
- Multi-warehouse stock totals aggregate correctly across locations
- PO emailed to supplier from platform; status advances through lifecycle on GRN receipt
- A SKU with `tax_code = Reduced` calculates correctly per UK VAT rates
- An EUR-denominated PO converts to base GBP correctly using the FX rate at PO date
- RTV created → stock decremented → supplier credit recorded; distinct from customer return flow
- Category rule matching "title contains 'charger'" correctly categorises matching products on rule run; manual category override is not overwritten by subsequent rule run
- Custom-split expense with 60%/40% across two channels writes correct `expense_channel_allocations` rows; allocation percentages enforced to sum to 100 before save
- Equal-split expense across 3 active channels writes three rows at 33.33% each
- Recurring monthly expense fires on the correct calendar date; generates a new `expenses` row; linked to original via `recurrence_parent_id`

**Risks:** FIFO/FEFO lot tracking adds schema complexity; scope to post-MVP if needed. Tax engine complexity grows with EU expansion — keep UK VAT primary in this phase, EU VAT/IOSS in Phase 12 alongside EU expansion. Category rules DSL must be well-documented in `docs/schema-design/` for future condition types to be addable without breaking existing rules.

---

### Phase 5 — Channel Connections + Listing Management + Onboarding Wizard
**Goal:** Connect the three initial marketplaces, push listings from the central catalogue, and offer a "60-second connect" onboarding wizard. AI-assisted listing optimisation woven in from day one.

**Initial marketplace adapters: eBay, TikTok Shop, Vinted.** Etsy and Amazon are added in Phase 12. Shopify and WooCommerce (storefronts) are added in Phase 16.

**Carrier framework note:** The `CarrierAdapter` ABC + `StubCarrierAdapter` are scaffolded in this phase (no real carriers connected yet) so that Phase 7 returns workflow can stub return-label generation cleanly. Real carriers (ShipStation + Royal Mail) connect in Phase 8.

**Azure infrastructure tier:** First paying customers expected. Upgrade DB; add Service Bus. Estimated cost: **~£200–280/month**.

| Change | From | To | Reason |
| --- | --- | --- | --- |
| Azure SQL | Serverless (auto-pause) | General Purpose, 2 vCores provisioned (always-on) | Consistent latency for customers; no cold-start pause |
| Azure Static Web Apps | Free tier | Standard tier (~£7/month) | Custom auth providers + private endpoints |
| Azure Service Bus | — | Standard tier | DLQ for failed listing sync jobs; scheduled retry messages |
| Azure Storage Queues | — | Add | High-volume order ingest queues |
| Redis | Basic C0 | Standard C1 | HA replica; rate-limit buckets at customer volume |

**Deliverables:**

_Marketplace adapters_
- **eBay adapter:** OAuth, listing push/pull, inventory sync
- **TikTok Shop adapter:** OAuth, listing push/pull, inventory sync
- **Vinted adapter:** HMAC-SHA256 auth (not OAuth), listings (secondhand item specifics — capped at 500 active items per API user unless slot increase negotiated), inventory sync, order ingestion + cancellation, shipping label retrieval (Vinted-managed labels only), webhook subscription for item + order lifecycle events. **Reduced capability scope** vs eBay/TikTok — Vinted Pro Integrations API does NOT expose returns / disputes / messaging / account health / feedback / payouts; those workflows remain in the Vinted UI for the operator. Adapter capability flags reflect this honestly so dependent features (Phase 7 returns, Phase 11 messaging hub, account health dashboard) gracefully degrade for Vinted listings.
- `MarketplaceAdapter` ABC confirmed; `StubMarketplaceAdapter` pattern tested against all three
- `CarrierAdapter` ABC + `StubCarrierAdapter` scaffolded for Phase 7 return-label stub

_Listing management_
- Listing management UI: central catalogue → channel-specific listing editor → bulk push
- Channel-specific field mapping (eBay item specifics, TikTok Shop categories, Vinted condition/size fields)
- **Listing templates** — reusable per-channel templates so operators don't re-type fields for every new SKU
- **Cross-marketplace variation syndication** — `variation_groups` table populated when same product variant exists on multiple channels
- Listing sync job queue with retry + error surfacing

_Channel onboarding wizard ("60-second connect") — NEW_
- Connect channel via OAuth → Synergia pulls existing listings → matches against catalogue by SKU → flags unmatched listings → operator reviews import preview → applies
- Side-by-side reconciliation UI for SKU mismatches (channel SKU vs catalogue SKU)
- Bulk-create catalogue products from unmatched listings option
- Time-to-first-sync target: under 60 seconds for sub-1,000 listings; under 5 minutes for sub-10,000

_Channel buffer stock — NEW_
- `channel_listing_stock_rules`: per (channel, variant) reserve qty + max % allocation
- Sync engine respects rules: a SKU with 100 units, 10 buffer, 50% max-eBay → eBay sees 45, TikTok sees 45 minus eBay reservation, etc.
- Operator UI to set rules globally or per channel

_Pricing rules — NEW_
- `pricing_rules`: per-channel auto-mark-up to cover marketplace fees; sale price windows (start/end); RRP floor enforcement
- Priority-ordered rules with dry-run preview
- Currency-aware (GBP-priced product on eBay-DE in EUR converts via FX)

_AI listing optimisation — NEW_
- AI suggestions panel on every listing: title rewrites, missing keyword detection, image quality scoring (low resolution, missing white background)
- Suggestions stored in `ai_listing_suggestions`; pending → operator accepts/rejects; accepted suggestions auto-pushed to channel
- Powered by Claude API (no MCP server required at this phase — direct API call)

_Imports & Migrations (NEW — major churn-reducer)_

The single biggest barrier to switching from Linnworks/StoreFEEDER is data migration. This deliverable is the answer.

- **Importer framework:** generic CSV/XLSX import engine with per-resource adapters
- **Per-resource importers (CSV/XLSX upload):**
  - Products (master SKUs + variants + BOM/combo lines)
  - Inventory snapshot (stock levels per warehouse + location)
  - Orders (historical orders for analytics seeding)
  - Customers (buyers + addresses + tags)
  - Suppliers + open POs
  - Listing → channel mappings (which catalogue SKU corresponds to which channel listing)
  - Channel listings (when not already pulled by onboarding wizard)
- **Validation pipeline per import:**
  - Schema check (required columns present, types valid)
  - Business-rule check (no duplicate SKUs, addresses parse, currency codes valid, etc.)
  - Foreign-key check (every channel listing references an existing product)
  - Dry-run preview: "Imports 1,247 products. 23 rows will fail (see issues below). Continue?"
- **Commit step:** atomic — all-or-nothing per file, with progress UI for large files
- **Direct importers from competitor exports:**
  - **Linnworks** export → Synergia mapping (products, channel listings, suppliers, POs)
  - **StoreFEEDER** export → Synergia mapping
  - **Shopify CSV** → catalogue + listings
  - **eBay seller CSV** → catalogue
- **Audit trail:** every import logged with file, operator, row counts, success/failure, post-import row counts in target tables
- **Rollback safety:** imports tagged with `import_batch_id`; emergency rollback procedure documented in runbook (delete all rows from a single batch)
- **`ImportWizard` component:** stepper UI — choose resource → upload file → map columns (with smart auto-mapping) → preview → validation report → commit
- **Templates page:** downloadable CSV/XLSX templates per resource with example rows + column docs

**Why Phase 5:** Channel onboarding wizard pulls existing listings, but tenants migrating from competitors have catalogue, inventory, customer, supplier, and PO data the wizard cannot reach. Without this, switching costs are too high — operators won't move from Linnworks even with a better product.

**Acceptance criteria additions:**
- A 5,000-row Linnworks product export imports successfully in under 2 minutes; dry-run preview matches actual commit row counts exactly
- Validation surfaces fixable errors per row with line numbers; operator can re-upload corrected file
- Importing the same file twice with the same `import_batch_id` is idempotent (does not duplicate)

**Acceptance criteria:**
- A product pushed from catalogue appears on eBay, TikTok Shop, and Vinted within 60 seconds
- Failed sync jobs surface in the UI with error reason and retry option
- All three adapters pass capability flag checks
- Channel onboarding wizard imports 100 existing eBay listings → matched against catalogue → operator review screen shown — under 60 seconds end-to-end
- A SKU with 100 stock and `eBay buffer = 10, max = 50%` correctly publishes 45 to eBay
- Pricing rule "eBay GBP price = catalogue price × 1.15 (cover fees)" correctly applied on push
- AI listing suggestion accepted by operator → suggestion published to channel within 30 seconds

**Risks:** eBay item specifics vary by category — allocate extra time. Vinted API access may require seller volume threshold — confirm before scheduling. AI listing suggestions need a tight cost budget per tenant (Claude tokens × suggestion volume) — see plan rate-limit budget.

_Localisation rollout (Phase 5)_
- **Urdu (`ur-PK`) translation complete** for the entire app + marketing site shipped to date — every key in `packages/locales/en-GB.json` has a corresponding `ur-PK.json` entry
- **Translation method: AI-generated (Claude) + native-speaker human review.** Process: AI batch-translates the full key set with operational/SME context provided ("this is e-commerce/warehouse software for UK SME sellers; 'pick task' means a warehouse picking instruction, not a verb"); native Urdu speaker reviews and corrects every translation in a structured PR; ESLint-style `i18n-review` CI check tracks which keys are AI-only vs human-reviewed (CI blocks production deploy if any key is still AI-only)
- RTL layout verified across every screen via Playwright visual diff (LTR vs RTL snapshots both stored)
- Date/number formatting in Urdu locale verified (Urdu uses Western digits in commercial contexts in Pakistan; date order DD/MM/YYYY)
- Custom translation override UI in tenant settings — operators can rename platform terms (e.g. "Pick task" → "Picking job") for both languages
- Marketing site at `synergia.co.uk/ur/` fully translated; `hreflang` tags signal Urdu version to search engines

**Marketplace listings stay in marketplace-supported languages.** Synergia operators can run the platform in Urdu (UI, reports, alerts, emails), but listings pushed to eBay/TikTok Shop/Vinted/Amazon remain in the language each marketplace supports for that storefront (typically English for `co.uk` storefronts, with marketplace-supported locales for international storefronts in later phases). The app/operations layer is Urdu-friendly; the public-facing buyer experience on each marketplace stays as the marketplace dictates.

_Marketing site (Phase 5 update)_
- **Feature pages live** for every shipped capability: Marketplace Management, Listing Management, Channel Onboarding, AI Listing Optimisation, Pricing Rules, Multi-currency, Channel Buffer Stock
- **Integrations directory** at `synergia.co.uk/integrations`: pages per marketplace (eBay, TikTok Shop, Vinted) + carriers (ShipStation, Royal Mail) — SEO landing pages targeting "[marketplace] inventory management software" terms. **Vinted page must be scoped honestly** — "listings + orders + shipping labels via Vinted Pro Integrations API; returns / messaging / disputes handled in Vinted UI." Don't overclaim; under-promise + over-deliver builds trust.
- **For-sellers** + **For-3PLs** segment landing pages
- **Comparison pages**: "Synergia vs Linnworks", "Synergia vs StoreFEEDER", "Synergia vs Veeqo" — side-by-side feature/pricing tables
- **Blog** scaffolded with first 5 launch posts (MDX)
- **SEO foundation**: structured data (JSON-LD Organization + Product), sitemap.xml, robots.txt, Open Graph + Twitter Card metadata on every page
- **Demo request form** wired (writes to `marketing_leads` with segment + turnover band)

---

### Phase 6 — Order Management + Customer Records + Operator Collaboration
**Goal:** All orders from all connected channels land in one unified queue; rules route them automatically; every order has a buyer record; operators collaborate on orders via notes and tasks.

**Azure infrastructure tier:** No changes from Phase 5. ~£200–280/month.

**Deliverables:**

_Order ingest_
- Unified order ingest from eBay, TikTok Shop, and Vinted (webhook-first + nightly reconciliation fallback)
- `webhook_inbox` idempotency table (idempotency_key UNIQUE constraint)
- Order queue UI: filter by channel/status/courier/date; bulk actions; column configurator
- Order status state machine: PAID → AWAITING_DISPATCH → SHIPPED → DELIVERED → COMPLETED
- Order routing rules engine: priority-ordered rules, test/dry-run mode
- Order timeline component: immutable event log per order
- Stock allocation on order confirmation; deallocation on cancel
- **Multi-currency order capture:** order's native currency stored on `orders`; FX rate at order time recorded; `total_in_base_currency` computed for analytics
- **Tax capture per order line:** `tax_rate`, `tax_amount`, `tax_collected_by` (synergia/marketplace), `tax_jurisdiction` populated from marketplace data

_Customer record creation (NEW)_
- On every inbound order, lookup or create `customers` record by marketplace buyer_id
- `customer_channels` link populated automatically
- **Cross-channel customer detection (D14):** auto-merge by **exact email match** only. Fuzzy matches (similar email/phone/address) flagged but never auto-merged — manual merge tool ships in Phase 13
- `customer.first_seen_at`, `total_orders`, `total_spend` updated on every order
- Customer detail page: full order history, addresses, notes, tags

_Address validation (NEW)_
- At ingest, shipping address validated against postcode lookup service (`getAddress.io` or Royal Mail PAF)
- Failed validation → order flagged "address review required" with reason; operator can override or contact buyer
- Validation result + provider stored on `customer_addresses`

_Operator collaboration (NEW)_
- `order_notes`: operators add internal notes to any order; `@mention` teammates → triggers in-app notification
- `order_tasks`: assignable tasks per order (e.g. "follow up with buyer about wrong address"); assignee, due date, status

**Acceptance criteria:**
- Orders from eBay, TikTok Shop, and Vinted land in queue within 30 seconds of placement
- Duplicate webhook events do not create duplicate orders (idempotency_key enforced)
- Stock allocation prevents oversell across channels (pessimistic lock during allocation)
- Routing rule assigns correct courier/warehouse without operator intervention on 95%+ of orders
- Every order has a `customer_id` populated; same buyer across channels resolves to one customer record where possible
- Invalid postcode at ingest → order flagged within 5 seconds, operator alerted
- `@mention` in order note triggers notification to mentioned user within 2 seconds

**Risks:** Webhook deduplication edge cases on high-volume channels — test with replayed payloads. Customer matching across channels is heuristic (different marketplaces give different buyer IDs) — accept some duplicate customer records initially; merge tooling can come later.

---

### Phase 7 — Returns, Cancellations & Dispute Cases Management
**Goal:** Operators manage the full post-sale exception lifecycle — returns, cancellations, and marketplace dispute cases — in one place. AI assists with return triage from day one.

**Context:** Synergia is a B2B platform — consumers never access it. Buyers initiate returns, cancellations, and cases on the marketplace; Synergia receives them via webhook/API and surfaces them for operator action. Operators can also manually initiate a return or cancellation inside Synergia (phone-in request, warehouse error, pre-despatch cancel).

**Carrier dependency note:** This phase issues return shipping labels via the `CarrierAdapter` framework scaffolded in Phase 5. Real labels generate from Phase 8 onwards (when ShipStation + Royal Mail are connected). Until Phase 8, return labels in this phase use `StubCarrierAdapter` for E2E test coverage.

**Azure infrastructure tier:** No changes from Phase 5. ~£200–280/month.

**Deliverables:**

_Returns_
- Returns synced automatically from marketplace APIs (webhook-first; buyer initiates on marketplace) — **eBay + TikTok Shop only at this phase; Vinted has no returns API so Vinted returns remain in Vinted UI** (operator can still manually log a Vinted return in Synergia for analytics consistency)
- Operator can manually log a return inside Synergia
- Returns queue: all return requests in one view; filter by channel/status/date/AI risk score; bulk actions
- Operator approves / rejects / partially approves each return
- Warehouse receipt confirmation: operator marks stock physically received
- Stock fate decision per return line: restock / quarantine / write-off / **refurb** (refurb path links to optional relisting at lower grade in later phase)
- **Return cost tracking** (`return_costs` table): per-return shipping + handling + restocking cost; feeds Phase 10 SKU profitability
- Refund trigger: operator confirms refund; Synergia calls marketplace API to issue refund
- Return reason tracking and reporting (top return reasons per SKU/channel)

_AI return triage (NEW)_
- On return receipt, Claude API analyses: return reason + buyer history + product return history
- Output: suggested decision (approve/reject/investigate), risk score (0–100 — fraud risk indicator), suggested stock fate
- Stored in `ai_listing_suggestions` analogue table for returns; never auto-actioned, always requires operator confirmation
- Patterns surfaced: "this buyer has 5 returns in 30 days across all channels — flag for review"

_Cancellations_
- Cancellation requests synced from marketplace APIs
- Operator can manually cancel an order in Synergia (pre-despatch); cancellation pushed back to marketplace via API
- Stock deallocation on cancellation; inventory restored immediately
- Cancellation window deadline surfaced in UI (some marketplaces reject after despatch)

_Dispute Cases_
- Dispute cases synced from marketplace APIs: **eBay (INR, SNAD, INAD) + TikTok Shop only**. Vinted seller-protection cases are NOT exposed by the Vinted Pro Integrations API — operator handles Vinted cases in the Vinted UI. Etsy + Amazon dispute cases come online in Phase 12.
- Cases queue: all open cases (eBay + TikTok at Phase 7) in one view; filter by marketplace/type/deadline; SLA countdown
- Operator responds to cases directly from Synergia via marketplace API
- Case timeline: full message thread + status history per case
- Account health impact: flag cases that affect seller metrics
- Case outcome tracking: resolved/escalated/lost — feeds into analytics

**Acceptance criteria:**
- A marketplace return request appears in Synergia within 60 seconds of the buyer raising it
- Operator can manually initiate a return or cancellation; change propagates back to marketplace via API
- Stock restored immediately on cancellation or return write-off decision
- Dispute case response sent from Synergia is confirmed received by the marketplace API
- SLA countdown on each case updates in real-time
- AI return triage produces suggested decision + risk score within 5 seconds of return receipt; never auto-acts
- Buyer with > 3 returns in 30 days across channels flagged automatically with "high return rate" badge

**Risks:** Each marketplace has different case types, deadlines, and response requirements — document all in Phase 0 research before implementation. AI return triage cost per tenant must stay bounded — daily budget per tenant enforced.

---

### Phase 8 — Fulfilment + Carrier Rate Shopping & Label Generation
**Goal:** Connect carriers, rate-shop across all of them, generate labels, and relay tracking back to marketplaces.

**Initial carrier integrations: ShipStation + Royal Mail.** Evri and DPD added in Phase 11.

**Azure infrastructure tier:** No changes from Phase 5. ~£200–280/month.

**Deliverables:**
- `CarrierAdapter` ABC + registry (already scaffolded in Phase 5; this phase activates real implementations)
- **ShipStation adapter:** rate quotes, label generation (multi-carrier via ShipStation API), tracking relay, void label
- **Royal Mail adapter:** Click & Drop / OBA API — label generation, rate quotes, tracking, manifest/collection booking
- Carrier rate shopping: for a given shipment (weight, dimensions, destination), query all connected carriers and surface cheapest/fastest options before committing
- Shipping rules engine: auto-allocate carrier/service by weight/value/destination/product type; priority-ordered rules
- Label generation: ZPL (Zebra thermal) + PDF (desktop); stored in Azure Blob Storage
- Label reprint and void flows
- **Shipment insurance:** optional insurance line per shipment where carrier API supports (`shipment_insurance` table)
- Tracking relay: tracking number written back to marketplace order via adapter
- End-of-day carrier manifest builder (`ManifestPanel` component)
- Phase 7 return-label `StubCarrierAdapter` calls now resolved against real ShipStation/Royal Mail labels
- `shipments`, `shipment_labels`, `carrier_rate_quotes` tables populated from this phase

**Acceptance criteria:**
- Rate shopping returns ranked carrier options with price + ETA within 2 seconds
- Shipping rule assigns carrier without human intervention on 95%+ of orders
- ZPL label generated, stored in Blob, and tracking number written back to eBay/TikTok/Vinted order
- Manifest generated and submitted to carrier at end of day
- Void label correctly cancels the shipment with the carrier
- Return labels generated in Phase 7 now use real carrier; existing return RMAs migrate cleanly

**Risks:** ShipStation API has its own rate limits — token bucket required. Royal Mail OBA requires account registration; apply early.

---

### Phase 9 — WMS + Demand Forecasting + Staff Performance (Mobile App)
**Goal:** Warehouse floor operations fully digitised; operators know what to reorder before they run out.

**Azure infrastructure tier:** Add SignalR Service for WMS real-time updates. Estimated cost: **~£250–330/month**.

| Change | From | To | Reason |
| --- | --- | --- | --- |
| Azure SignalR Service | — | Standard, 1 unit | WMS barcode scan → live pick task updates; low-stock alerts pushed to warehouse manager |

**Deliverables:**
- **WMS mobile app (React Native + Expo, iOS + Android)** — `mobile/` in monorepo, Expo EAS Build for distribution, OTA patch updates via Expo Updates:
  - **Warehouse Operator mode** (primary — floor use, offline-first):
    - Pick wave assignment + route-optimised task list
    - Barcode scan to validate pick / pack / despatch (wrong scan = audible block, must rescan)
    - Inbound GRN — scan items against a PO on arrival
    - Stock transfer between locations
    - Offline queue: scans buffered locally and synced on reconnect
  - **Manager / Owner mode** (secondary — dashboard use):
    - Live order feed with status
    - Inventory levels + low-stock alerts
    - Reorder alerts with one-tap PO creation
    - Staff performance (picks/hour, accuracy %, leaderboard)
    - Sales snapshot (today vs. yesterday, by channel)
    - Push notifications for SLA breaches, stockouts, failed syncs
  - **3PL Client mode** (read-only, activated in Phase 11):
    - View their stock levels
    - View their order statuses
    - Download despatch notes
- Pick wave generator: group orders by courier cutoff, by zone, by product location
- Pick task assignment: route-optimised path through warehouse locations
- Scan & pack: barcode validation on pack bench (wrong item = audible error + block)
- Despatch confirmation: weight check + label scan before releasing to carrier
- **Staff performance dashboard:** picks/hour, accuracy %, sessions per picker; team leaderboard; daily/weekly trend
- Bin/aisle/rack location management UI
- Stock transfer between locations (inter-warehouse + intra-warehouse)
- **Stock take / cycle count workflow (NEW):**
  - Operator schedules a cycle count: full warehouse, by zone, by ABC class, or by SKU group
  - Mobile app: scan all bins in scope; system records actual qty
  - Variance report: expected vs. actual per location; immutable variance ledger
  - Approval flow: operator reviews variances → approves → `stock_movements` written for adjustments
  - Audit trail: every cycle count session logged with operator, time, scope, variances
- **Demand forecasting engine:**
  - Daily velocity calculation per variant per channel (rolling 7/30/90 day)
  - Reorder alert generation: `if days_of_stock < lead_time_days + buffer_days → create alert`
  - Suggested reorder qty (based on velocity × reorder period; respects supplier MOQ + container/pallet sizing)
  - Stockout prediction: "SKU-X will run out in 12 days at current sell-through"
  - Seasonal adjustment flags (manual tag: "this SKU has Q4 demand spike")
- Reorder alert UI: pending alerts with one-click → create PO from suggestion
- **ForecastSparkline component:** 30-day velocity chart + reorder threshold line on every SKU card

**Acceptance criteria:**
- A picker scans wrong item → system blocks, sounds error, requires rescan — cannot proceed
- Staff performance stats update in real-time (within 5 minutes of task completion)
- Reorder alert fires at correct threshold; suggested qty within 10% of manually calculated value
- Demand forecast runs as nightly Hangfire recurring job; p95 completion under 10 minutes for 10K SKUs
- Cycle count session: scan 100 bins → variance report generated → operator approves → adjustments hit `stock_movements` ledger within same session

**Risks:** Seasonal demand forecasting is hard to get right without sufficient historical data; v1 should be simple (velocity-based) with AI upgrade path in Phase 13.

---

### Phase 10 — No-Code Automation + Repricing + Report Engine + Finance Reports Starter Pack
**Goal:** Operators automate repetitive operational decisions without code; competitive repricing across marketplaces; every SKU's true profitability is visible (in base currency); a structured report engine ships with 15+ pre-built finance reports — runnable on demand or scheduled, all without AI tokens.

**Azure infrastructure tier:** Upgrade DB to handle analytics queries; add Front Door for WAF + CDN. Estimated cost: **~£380–480/month**.

| Change | From | To | Reason |
| --- | --- | --- | --- |
| Azure SQL | General Purpose 2 vCores (~£280/month) | General Purpose 4 vCores (~£450/month) | Indexed view refresh + profitability queries under load |
| Azure Front Door | — | Standard | WAF (OWASP rules), CDN for images/labels, SSL termination, health-based routing |

**Deliverables:**
- **No-code automation rule builder (AutomationRuleBuilder component):**
  - Trigger types: order created, order status changed, return request created, stock level dropped below threshold, new marketplace message, SLA breach imminent
  - Condition types: order total, destination country, product category, channel, weight, carrier, SKU, customer tag, time of day
  - Action types: assign carrier, apply shipping service, tag order, send notification, create task, hold order for review, open case draft, forward to supplier (dropship)
  - Chained actions (if action A → then condition B → then action C)
  - Test/dry-run mode: run rule against last 100 orders, show what would have triggered
  - Rule conflict detection: warn if two rules could both match
- `automation_rules` table stores rules as JSON (trigger + conditions array + actions array)
- Rule executor runs as PostToolUse hook on order create/update events

- **Repricing engine (NEW):**
  - Rule-based per-listing: match buy box, beat lowest competitor by X%, hold to floor price, never below COGS + Y% margin
  - Competitor data sourced from eBay/Amazon API (where available — full implementation depends on Phase 11 marketplace depth)
  - `repricing_rules` table: rule definition; active/paused; floor price; ceiling price
  - `repricing_history`: every price change with trigger reason (manual / rule / AI suggestion)
  - **AI repricing suggestions** via Claude API: "your margin on SKU-X is 8% but BuyBox is at +12%; suggested price = £XX (margin 14%)"
  - Throttle: max N price changes per SKU per day (avoid marketplace velocity penalties)
  - Dry-run mode: see what changes would happen without committing
  - Audit log: every repricing action attributed to (rule_id / user_id / ai_assistant)

- **SKU profitability analytics:**
  - Per order line, capture: sale price, marketplace fee %, shipping cost, COGS at time of sale, return cost amortisation
  - `order_line_costs` append-only table written at order completion
  - All values normalised to company `base_currency` using FX rate at order date
  - `sku_profitability_mv` materialised view: net margin per SKU per channel per period
  - Profitability dashboard: SKU table sorted by net margin; channel comparison; "worst 20 SKUs by margin" view
  - **ProfitabilityBar component:** waterfall chart — revenue → marketplace fees → COGS → shipping cost → return cost → net margin — per SKU
  - Export to CSV / XLSX
  - Margin alert: notify if a SKU's rolling 30-day margin drops below configured threshold
  - Note: fee accuracy is approximate until Phase 11 (full marketplace adapter captures all fee detail). Phase 10 uses estimated fee % per channel; Phase 11 reconciles against payout reports.
- Channel-level P&L: revenue, fees, returns, COGS, shipping costs, net per channel per period (base currency)
- **Supplier scorecard:**
  - Track per supplier: on-time delivery rate, average lead time, lead time variance, invoice accuracy, return-fault rate
  - Score computed from GRN dates vs. PO expected dates
  - **SupplierScorecard component:** per-supplier tile with trend sparklines
  - Alert if supplier on-time rate drops below 80%

_Report engine — NEW_
- **`ReportSpec` executor:** structured JSON spec → SQL via Dapper query templates → result; spec validated against allowed metric/dimension/filter contract from Phase 1
- `report_definitions` CRUD: create, edit, save, share, schedule
- **Visualisation types:** table (sortable, exportable), bar, line, waterfall (P&L flows), KPI tile, pie/donut, comparison cards (current vs previous period)
- **Filters & parameters:** date range, channel, warehouse, SKU/category, customer tag, currency (auto-converts to base for analytics)
- **Saved reports run without AI tokens** — once authored, the spec is just SQL execution
- **Scheduled delivery:** cron-based (`report_schedules`); deliver as PDF email (Azure Communication Services), Slack message (webhook), or generic webhook payload
- **Read-only share links:** `report_share_links` with optional expiry — share a report with someone who doesn't have a Synergia login
- **Manual report builder UI:** for power users who want to skip AI; visual editor showing the same `ReportSpec` AI generates
- **Export:** every report exports to CSV / XLSX / PDF
- All values normalised to company `base_currency`

_Monthly Financial Closing workflow (NEW)_
- **Close wizard:** operator navigates to Finance → Monthly Close → selects year/month → system shows pre-close checklist (any open orders in period? unreconciled payouts? expenses missing?) → operator reviews → confirms → status moves OPEN → IN_PROGRESS
- **Pre-close summary panel:** for the selected period shows: total revenue, marketplace fees, COGS, direct expenses, allocated expenses, net profit — company-wide AND per channel side-by-side; operator can drill into any figure before locking
- **Per-channel breakdown:** each channel shows its own P&L for the period (revenue − fees − shipping − COGS − direct channel expenses − allocated share of company expenses = channel net profit)
- **Portfolio view in close:** if portfolios are defined, the summary also shows portfolio-level aggregates alongside individual channel lines
- **Expense allocation at close time:** company-level expenses dated within the close period are included; their `expense_channel_allocations` percentages determine how they split into each channel's P&L; unallocated expenses appear in a separate "Company Overhead" line
- **Lock action:** status moves to PENDING_REVIEW → operator confirms → LOCKED; system writes immutable `month_closing_snapshots` rows (one company-wide row + one row per channel) — these rows are never updated; a closing PDF report is generated and stored in Blob Storage
- **Unlock (admin only):** requires `approve` permission on `month_closings` resource; status reverts to IN_PROGRESS; `month_closing_events` row written with `unlock_reason`; existing snapshot rows are NOT deleted (they remain as historical record); new snapshots written at next lock
- **`MonthlyClosePanel` component:** period selector, pre-close checklist, summary table with company/channel columns, lock/unlock button, download PDF, history (past closes with status badges)
- **Notifications:** notify company admins when a period approaches close-readiness (no open orders in period for > 5 days); notify on lock and unlock

_Finance reports starter pack — 18 pre-built reports shipped with every tenant_

| # | Report | Group |
| --- | --- | --- |
| 1 | Channel P&L | Profitability |
| 2 | Portfolio P&L comparison | Profitability |
| 3 | SKU profitability (top/bottom N) | Profitability |
| 4 | Net margin waterfall (whole business) | Profitability |
| 5 | Gross margin trend (rolling 30/60/90) | Profitability |
| 6 | Period-over-period margin comparison | Profitability |
| 7 | Cash flow (in vs out) | Cash flow |
| 8 | Marketplace payout schedule | Cash flow |
| 9 | Open POs (committed spend) | Cash flow |
| 10 | Expense breakdown by category | Expenses |
| 11 | Expense allocation by channel | Expenses |
| 12 | Monthly close summary (locked periods history) | Close |
| 13 | Stock on hand value | Inventory |
| 14 | Aged stock (0-30 / 31-60 / 61-90 / 90+) | Inventory |
| 15 | Slow-moving / dead stock | Inventory |
| 16 | UK VAT return (VAT100 figures) | Tax |
| 17 | Marketplace payout reconciliation | Reconciliation |
| 18 | Refund / return rate + return cost impact | Cross-cutting |

Reports stored as global `report_templates` rows; on first tenant load, cloned into `report_definitions` so operators can customise their copy without affecting the template.

**Acceptance criteria:**
- An automation rule set up in the UI correctly routes orders without code within 200ms of order creation
- Test/dry-run mode shows accurate preview against historical orders
- SKU profitability figures for a SKU match a manually calculated spreadsheet within ±2% (rounding)
- Materialised view refresh completes in under 60 seconds for 100K order lines
- Repricing rule "match buy box, floor at £15" correctly adjusts price within 60 seconds of competitor change
- AI repricing suggestion shown to operator with rationale; never auto-applied without rule or operator confirmation
- All 18 starter-pack reports load and render correct data within 5 seconds for tenants with 100K orders
- A scheduled report delivers a PDF to operator email at the cron time; failures logged in `report_deliveries`
- Saved report re-runs do not invoke any AI API call (verified by Application Insights metric: `ai.tokens_per_report_run` = 0)
- UK VAT return report figures match a manually calculated control set within £0.01
- Monthly close: pre-close summary figures (revenue, fees, COGS, expenses) match a manually constructed control set within £0.01; locking writes correct `month_closing_snapshots` rows; figures do not change after further order edits
- Custom-split company expense (60% channel A / 40% channel B) correctly appears at those proportions in each channel's close P&L
- Unlocking a period writes an audit entry with reason; existing snapshot rows remain intact; new snapshots written on re-lock reflect updated data
- Portfolio P&L report aggregates member channels correctly; same channel in two portfolios does not double-count in either portfolio's report

**Risks:** No-code rule builder UI is complex to build well; invest in UX design before implementation. Profitability accuracy depends on COGS being kept current — add a "COGS not set" warning prominently. Repricing velocity must respect marketplace rules (eBay penalises rapid price changes) — throttle is non-negotiable. Monthly close PDF generation must be deterministic — same inputs always produce the same output; store the PDF in Blob at lock time rather than re-generating on demand.

---

### Phase 11 — Marketplace Depth + Messaging Hub + 3PL Client Portal
**Goal:** eBay and TikTok Shop fully implemented (all adapter capabilities); Vinted at maximum capability the Vinted Pro Integrations API exposes (orders + listings + cancellations + shipping labels + webhooks — full returns / messaging / disputes / health remain in Vinted UI); messaging hub live for eBay + TikTok; 3PL operators can give clients self-serve visibility.

**Azure infrastructure tier:** No changes from Phase 10. ~£380–480/month.

**Deliverables:**
- **eBay full adapter:** orders, fulfilment, cancellations, returns/cases (INR, SNAD, INAD), account health, seller level, feedback (receive + respond), Trading API legacy support, payout sync, reports, competitor pricing, messaging, notifications, subscription management
- **TikTok Shop full adapter:** orders, fulfilment, returns, cases, creator/affiliate order routing, shop health, messaging
- **Vinted full adapter (within Vinted Pro Integrations API limits):** order management depth (full ingest, cancel, shipping label, webhooks). Returns / disputes / messaging / account health / feedback / payouts remain operator workflows in Vinted UI — Vinted does not expose these in their API. If Vinted releases additional endpoints post-launch, adapter capability flags toggle on without code changes elsewhere.
- **Evri + DPD carrier adapters** added to carrier registry alongside ShipStation + Royal Mail
- Marketplace message hub UI (`ConversationView`): **eBay + TikTok Shop only** at Phase 11; Etsy added Phase 12. Vinted has no messaging API — Vinted buyer messages remain in Vinted UI. Threaded per order; SLA countdown; reply UI ready (AI-assisted reply drafts wired in Phase 13 alongside MCP server)
- Account health dashboard: **eBay seller level gauges + TikTok Shop health metrics + (Phase 12) Amazon health**; defect rate trends, SLA breach alerts. Vinted shop health is NOT in the Vinted API — operator monitors Vinted health in Vinted UI; Synergia surfaces a placeholder card with a "View in Vinted" link.
- Marketplace fee reconciliation: payout reports parsed; `order_line_costs` updated with actual fees (replaces estimates from Phase 10)
- **3PL client portal (shadow-tenant model):**
  - Each 3PL-managed brand is a real `company` (not a row in `threepl_clients`)
  - `3pl_relationships` table: `(operator_company_id, managed_brand_company_id, scope, status)` — defines what the 3PL operator can see in the brand's tenant
  - Brand staff log into their own tenant directly (full feature access scoped to plan tier)
  - 3PL operator switches between managed brands via a "shop selector" in the top nav (similar to GitHub org switcher)
  - Branded portal URL per brand: `<brand>.synergia.co.uk` or `app.synergia.co.uk/b/<brand>`
  - **3pl_client_tokens** for read-only API access from external systems
  - **ThreePLClientPortal component:** brand-side dashboard

_Public uptime / metrics page (NEW)_
- Public-facing page at `status.synergia.co.uk` showing: platform uptime, p95 API latency, marketplace sync latency per channel, current rate-limit headroom
- Powered by Application Insights metrics + `webhook_deliveries` aggregation
- Trust signal for prospects evaluating Synergia

_Marketing CRM sync (D15) — NEW_
- Phase 11 wires `marketing_leads` → **HubSpot Free** sync via HubSpot API
- Background job mirrors lead status; fields mapped: name, email, company, turnover_band, segment, source, status, assigned_to
- Salesforce / Pipedrive deferred until volume justifies migration

_Customer merge tool (D14) — moved here from Phase 13_
- Manual merge UI for fuzzy-matched duplicate `customers` records flagged in Phase 6
- Operator reviews candidate pairs side-by-side; approves merge → orders / addresses / notes consolidate into the kept record; audit trail preserved
- Bulk merge for tenants with many duplicates from migration
- **Why moved to Phase 11:** LTV/CAC analytics in Phase 13 depend on clean customer data; merge tool is a precondition, not a co-deliverable. Shipping in Phase 11 gives operators 2 phases of data cleanup before analytics depend on it.

_AI Insights Digest (NEW — moved forward from Phase 13)_
- Daily / weekly AI-generated summary email per operator
- Content: yesterday's metrics with anomaly callouts, urgent items needing action (SLA breaches, stockouts, buy-box losses, low margin alerts), AI's recommended priorities for today
- Operator opt-in per cadence and topic; subject + body templates customisable per company
- Powered by Claude with structured prompt + the data the operator's role can see
- Cheap to deliver (one Claude call per operator per day); high retention impact (the email replaces "what should I check?" anxiety)


**Acceptance criteria:**
- eBay case opened in portal → response sent via API → eBay confirms message received
- Account health metrics refresh on eBay API schedule (daily); alert fires if defect rate exceeds threshold
- 3PL operator can switch between managed brand tenants in under 1 second; permission scope correctly applied
- Brand-side staff cannot see other brands managed by the same 3PL operator
- Status page reflects real-time data within 60 seconds of metric collection

**Risks:** eBay Trading API is being sunset; validate which endpoints require it vs. REST; plan migration path. Shadow-tenant model adds auth complexity — every controller must check `3pl_relationships` when operator scope crosses tenants.

_Marketing site (Phase 11 update)_
- **Customer case studies** — first 3–5 paying customers featured (with consent); MDX format with structured-data Review/AggregateRating
- **Status page link** prominent in site footer (`status.synergia.co.uk`)
- **Pricing page enhanced** with usage-based estimator (turnover slider → recommended plan)
- **Trust badges**: ISO 27001 progress, GDPR compliant, UK data residency, SOC 2 roadmap
- **Reviews / social proof** on home page — pulled from G2, Capterra, Trustpilot once tenants leave reviews

---

## 🚀 MILESTONE — v1 Public Launch (End of Phase 11)

**This is the public launch goal.** Everything Phases 0–11 builds out a complete, paid, production-ready SaaS platform that beats Linnworks/StoreFEEDER feature-for-feature on the launch trio of marketplaces. Phases 12–17 are post-launch growth phases.

### What v1 Launch includes (Phases 0–11)

| Capability area | Status at launch |
| --- | --- |
| **Marketplaces** | **eBay + TikTok Shop — full adapter depth** (orders, fulfilment, returns, cases, account health, messaging, payouts, feedback). **Vinted — reduced depth** (listings, orders, cancellations, shipping labels, webhooks only — Vinted Pro Integrations API does not expose returns / cases / messaging / account health / feedback / payouts; those workflows remain in Vinted UI for operator). Etsy added Phase 12 fills the gap. |
| **Carriers** | ShipStation + Royal Mail + Evri + DPD — rate shopping, label generation, manifest, tracking writeback |
| **Catalogue** | Products, variants, BOM/combos, structured attributes, listing templates, variation syndication, AI listing optimisation |
| **Inventory** | Multi-warehouse, immutable ledger, channel buffer rules, stock takes, RTV |
| **Orders** | Unified queue from 3 marketplaces, multi-currency, tax capture, address validation, customer records, operator collaboration |
| **Returns / Cases** | Marketplace-synced + operator-initiated; AI return triage; full dispute case management |
| **WMS (mobile)** | iOS + Android, barcode pick/pack/ship, cycle count, staff performance, demand forecasting |
| **Automation & Repricing** | No-code rule engine; rule-based + AI-assisted competitive repricing |
| **Analytics & Reports** | 18 starter-pack finance reports; user-configurable dashboards (no defaults, 13 widget types); scheduled PDF/Slack/webhook delivery; monthly close with locked snapshots |
| **Finance Operations** | Expense management with allocation rules, portfolio P&L, monthly close workflow, UK VAT100 |
| **AI** | Listing optimisation, return triage, repricing suggestions, demand forecast (basic), insights digest email |
| **Multi-tenant** | 3PL shadow-tenant model with brand switcher; full action-level RBAC; audit log |
| **i18n** | English (`en-GB`) + Urdu (`ur-PK`) with full RTL; AI-translated + native-reviewed |
| **Marketing** | `synergia.co.uk` with feature pages, comparison pages, blog, case studies, integrations directory, pricing estimator, demo form |
| **Trust** | Public status page, GDPR-clean (no cookie banner), UK data residency, SLA tiers per plan |
| **Pricing** | Free tier (acquisition), Starter, Growth, Scale, Enterprise — turnover-based, rolling 30-day, transparent |
| **Customer success** | Marketing → app sign-up flow with UTM persistence, HubSpot CRM sync, customer merge tool for clean LTV/CAC |
| **Reliability** | Health checks, correlation IDs, idempotency, secrets rotation, PITR backups, GDPR DSAR workflow, feature flags |

### v1 Launch Acceptance Criteria

- [ ] First 5 paying tenants successfully migrated from competitor platforms (Linnworks/StoreFEEDER) using Imports & Migrations tooling
- [ ] First 30 days post-launch: zero critical incidents; uptime ≥ 99.9%; p95 API latency < 2s
- [ ] Marketing site: 1,000+ unique monthly visitors; 50+ demo requests; 20+ free-tier sign-ups
- [ ] Public status page live at `status.synergia.co.uk` with real metrics
- [ ] G2 / Capterra / Trustpilot listings live, ≥ 5 verified reviews each
- [ ] All 17 acceptance criteria from Phases 2–11 met
- [ ] AI cost model validated against actual tenant usage (see `Plans/AI_COST_MODEL.md`)

### Post-Launch Phases (12–17)

Phases 12–17 ship as **continuous monthly releases** post-launch, gated on customer demand:

| Phase | Theme | Trigger to start |
| --- | --- | --- |
| 12 | Etsy + Amazon expansion adapters | First 5 paying customers requesting Amazon |
| 13 | AI/MCP layer (in-app + public read-only beta) | Deeper AI features needed; Tier-A research demand |
| 14 | Tier-B Marketplace Research | Customer requests for Terapeak/SP-API research |
| 15 | Tier-C Full Research Platform | Tier-B converts to Pro tier upgrades |
| 16 | Storefront channels + dropship | Customer requests for Shopify/WooCommerce |
| 17 | Public API + MCP write GA + enterprise | First Enterprise contract negotiation |

**Decision principle:** post-launch phases are demand-driven, not date-driven. Ship what existing customers ask for first.

---

### Phase 12 — Etsy + Amazon Adapters (must-ship to fill Vinted scope gap)
**Goal:** Two expansion marketplace adapters fully live. **Etsy is must-ship in this phase** — it fills the workflow gaps Vinted's reduced API leaves (full returns / messaging / cases / feedback support that Vinted lacks). Amazon expands to the largest UK marketplace.

**Azure infrastructure tier:** No changes from Phase 10. ~£380–480/month. Monitor Service Bus queue depth as adapter volume increases.

> **Note:** Vinted was integrated at Phase 5 with reduced scope (listings + orders only — Vinted's API limits). Etsy added here gives Synergia a full-depth third marketplace adapter with returns / messaging / cases coverage.

**Deliverables:**
- **Etsy adapter (full depth):** OAuth, listings (materials, tags, production methods, Etsy-specific attributes), orders, fulfilment, **returns**, **messaging**, **shop statistics**, **feedback** — fills the workflow gaps Vinted leaves
- **Amazon adapter (UK/EU):** SP-API OAuth, listings (ASIN + offer management), FBA + FBM orders, FBA inventory, returns, A-to-Z cases, account health, advertising reports, payout

**Acceptance criteria:**
- Both adapters implement full capability flag set for their supported capabilities
- Stub capabilities return `(0, ["not_implemented"])` not exceptions
- Orders from both land in unified queue within 60 seconds

**Risks:** Amazon SP-API has strict per-endpoint rate limits — token bucket must be conservative. Amazon SP-API app registration can take days — apply early in Phase 0 research.

---

### Phase 13 — Advanced Analytics + AI Layer + MCP Server (Internal)
**Goal:** Surface intelligence on top of the operational data; ship the internal MCP server powering the in-app AI assistant.

**Azure infrastructure tier:** Buy 1-year reserved capacity on stable resources. Estimated cost: **~£300–380/month** (reserved discount applied).

| Change | From | To | Reason |
| --- | --- | --- | --- |
| Azure SQL 4 vCores | Pay-as-you-go (~£450/month) | 1-year reserved (~£290/month) | ~35% saving; ~£160/month saved |
| Container Apps | Consumption | Dedicated workload profile (D4) | Predictable capacity for API + analytics workers under load |
| Application Insights | Free 5 GB/month | Pay-per-GB with adaptive sampling | Analytics queries generate significant telemetry; sampling keeps cost under £30/month |

**Deliverables:**

_Analytics_
- LTV / CAC tracking per channel (requires Stripe revenue data linked to acquisition channel)
- Industry benchmarking (anonymised aggregate metrics across Synergia tenants, opt-in)
- AI demand forecasting upgrade: seasonal decomposition, external signal integration (weather, calendar events)
- Search upgrade: Meilisearch deployment if search volumes justify it (decision point at 500K products)
- Export centre: scheduled exports (CSV/XLSX) for orders, inventory, profitability per range

_Internal MCP Server (`packages/synergia-mcp/`)_

Architecture: separate C# project (`src/Synergia.Mcp/`) using the `ModelContextProtocol` NuGet package; talks to Synergia's internal ASP.NET Core API routes (not the DB directly); stateless and separately deployable as a Container App.

**Resources** (read-only context for AI agents):
- `inventory://skus` — stock levels per variant per warehouse
- `orders://queue` — open orders with status and SLA countdown
- `channels://performance` — revenue/returns/fees/expenses per channel per period
- `portfolios://performance` — aggregate P&L per portfolio per period
- `forecasts://reorder-alerts` — pending reorder alerts with suggested qty
- `analytics://sku-profitability` — net margin per SKU per channel (after expense allocation)
- `cases://open` — open marketplace dispute cases
- `suppliers://scorecard` — supplier on-time %, lead time, invoice accuracy
- `expenses://summary` — expense breakdown by category and channel for a given period
- `finance://month-closings` — status of past and current monthly closes; locked period snapshots

**Tools** (actions the AI can take on behalf of the operator):
- `create_purchase_order(supplier_id, lines[])` — raise a PO from a reorder alert
- `update_stock_level(variant_id, warehouse_id, qty, reason)` — manual correction
- `approve_return(return_request_id, decision)` — process an RMA
- `push_listing(product_id, channels[])` — push listing to channels
- `create_automation_rule(trigger, conditions, actions)` — wire a no-code rule
- `get_order_timeline(order_id)` — fetch immutable event log
- `run_report(type, date_range, filters)` — generate an analytics report
- `send_message(conversation_id, body)` — send marketplace message

**Prompts** (pre-built analysis prompts surfaced in MCP clients):
- "Analyse my slowest-moving inventory and suggest what to discount or liquidate"
- "Which channels are most profitable net of fees and shipping this quarter?"
- "Draft a supplier performance review email for my worst-performing supplier"
- "What orders are at risk of SLA breach in the next 24 hours?"
- "Summarise my account health across all marketplaces"

_In-app AI chat assistant_
- Chat panel in Synergia UI (slide-out drawer, `Cmd+/` shortcut)
- Backend: `/api/ai/chat` endpoint runs Claude with MCP server tools injected; all tool calls automatically scoped to the authenticated company (no cross-tenant data leakage possible)
- Operator can ask natural language questions and take actions without leaving the platform
- AI responses include structured data cards (e.g. a reorder alert table, not just prose)
- All AI actions logged to `audit_log` with `actor = ai_assistant`

_Marketplace messaging AI assist (deferred from Phase 11)_
- AI draft reply suggestions in `ConversationView` now powered by MCP server with full order/buyer/return context
- Drafts stored in `ai_message_drafts`; operator approves before send

_Public MCP read-only beta (NEW — brought forward from Phase 17)_
- Publish `synergia-mcp` (read-only) to PyPI alongside internal MCP launch
- Read scope only: resources accessible (inventory, orders, analytics, etc.), no write tools
- API key generated from operator settings; pasted into Claude Desktop config
- Marketing wedge: *"Your inventory is one Claude Desktop install away."*
- Phase 17 promotes write scope to GA

_Product research — Tier A: Insights (NEW)_
- **Goal:** an AI-driven research surface that uses ONLY tenant's own catalogue, sales, and profitability data — no new external data feeds. Sets up the research workflow that Phases 14 and 15 will deepen.
- `research_workspaces` + `research_items` + `research_notes` + `research_ai_recommendations` tables active
- **Catalogue performance insights:** "your worst-performing 20 SKUs by net margin", "SKUs sold on eBay but not on TikTok (cross-listing opportunities)", "categories where you're over-indexed in slow-movers"
- **AI recommendations** in the in-app chat: "what should I cut from my catalogue?", "which of my SKUs would suit Vinted?", "where am I leaving margin on the table?"
- **Workspaces** — operators create named workspaces ("Q4 review", "Underperformers cleanup") and add SKUs from their own catalogue for focused analysis
- **Closed-loop primitive:** any research item can convert to a catalogue action (mark for discontinuation, push to additional channel, schedule a price test) — wires the action pipeline that Phase 14/15 extend
- All research data filtered to the tenant's own data; no marketplace-wide or competitor data yet (that's Phase 14)

_AI report builder + dashboards (NEW)_
- **AI report authoring:** operator types in chat ("show me 5 worst-margin SKUs in last 30 days vs previous 30 days") → AI generates a `ReportSpec` constrained to the locked schema → operator previews → saves to `report_definitions`
- **AI does NOT execute the query** — only generates the spec; execution path is the deterministic SQL engine from Phase 10
- **Edit-with-AI:** existing saved report + new instruction ("also break this down by channel") → AI updates the spec → operator approves
- **AI cost tracking:** `ai_report_authoring_jobs` table logs tokens per session; per-tenant daily budget enforced
- **MCP tool exposed:** `create_report(spec)` and `update_report(id, partial_spec)` — works in-app and via public MCP for Claude Desktop users
- All AI-authored reports tagged `created_via = 'ai'` in audit log; never auto-saved without operator confirmation

- **User-configurable dashboards (no default; user builds their own):**
  - **Empty state on first visit:** new tenants land on an empty Dashboards page with one CTA — "Create your first dashboard". No auto-generated default. Users build what they need.
  - **Optional template gallery:** if the user wants a starting point, they can clone a `dashboard_template` — "Daily Operations", "Finance Snapshot", "Warehouse Manager", "Channel Performance". Cloned dashboards are fully owned and editable; never linked back to the template.
  - **`DashboardGrid` component:** 12-column responsive grid (`react-grid-layout`); widgets resize by dragging corners (snap to grid); reorder by dragging headers; mobile collapses to single column with preserved order.
  - **13 widget types** (catalogued in `widget_types` global table): KPI tile, sparkline KPI, chart (bar/line/pie/waterfall), table, live counter (SignalR-driven), activity feed, goal/progress, note (markdown), heading, image, embed (whitelisted iframe), shortcut button, filter widget.
  - **Add widget flow:** "+ Add widget" → pick type from picker → configure (which report / metric / period / size) → preview → place on grid.
  - **Dashboard-level cascading filters:** period / channel / warehouse selectors at the top of every dashboard drive all compatible widgets — change "last 30 days" once and every widget updates.
  - **Refresh interval** at dashboard level (5s / 30s / 1m / 5m / 1h / manual); per-widget override.
  - **Visibility & permissions** (`dashboard_permissions`):
    - Private (just me) — default
    - Team (specific roles or users)
    - Company-wide (all tenant users)
    - Public read-only link (`dashboard_share_links` with token + optional expiry)
  - **Locked vs editable:** company-wide dashboards can be marked locked — only admins edit; viewers see filters but no layout edit UI.
  - **Cloning:** anyone with view access can clone a dashboard to their own private copy in one click.
  - **Multiple dashboards per user:** sidebar or tab switcher; pin favourites; quick-switcher (Cmd+K).
  - **TV / kiosk mode** (`?kiosk=1`): full-screen, no nav chrome — for warehouse-floor TV displays; auto-rotate between dashboards if multiple set as kiosk.
  - **Dashboard theme override:** dashboards can choose dark / high-contrast / light independently of the user's app theme — important for warehouse TVs in bright light.
  - All widget data refreshes consume zero AI tokens (widgets render saved reports + live SignalR counters).

**Acceptance criteria:**
- AI reply draft in messaging hub generated within 3 seconds; editable before send; never auto-sent
- In-app chat can answer "what are my 5 worst-margin SKUs this month?" with correct figures matching analytics dashboard
- MCP tool `create_purchase_order` creates a real PO in the DB; appears in operator UI immediately
- All AI-triggered actions appear in audit log attributed to `ai_assistant` with the operator's user_id as `on_behalf_of`
- No tool call can access data outside the authenticated company's scope (enforced by internal API `require_company_scope`)
- Seasonal forecasting accuracy within 20% vs. actual at 30-day horizon
- AI generates a valid `ReportSpec` from "5 least profitable SKUs in last 30 days vs previous 30 days" within 5 seconds; spec passes schema validation; preview shows matching data
- Saved AI-authored report re-run 1000 times → zero AI tokens consumed (verified by App Insights metric)
- Edit-with-AI on an existing report ("also break down by channel") correctly augments the spec without rebuilding from scratch
- New tenant lands on empty Dashboards page with template-gallery CTA — no dashboard auto-created
- User can drag a KPI widget onto a dashboard, configure it (metric + period), resize it, save the layout — entire flow under 60 seconds
- Dashboard with 8 widgets renders within 3 seconds for 100K-order tenant; widgets refresh independently per their override interval
- Cascading filter "last 7 days" at dashboard level updates all 8 widgets simultaneously
- Cloning a `dashboard_template` produces a fully editable owned copy with no link back to the template
- Public share link works in incognito browser; respects expiry; revocable from owner UI
- Kiosk mode renders full-screen with no nav chrome; rotates between selected dashboards every 30 seconds

**Risks:** AI tool calls that modify data (create PO, approve return) must require explicit confirmation in the chat UI — never auto-execute on first mention. Benchmarking requires critical mass of tenants opting in; don't block phase on it.

---

### Phase 14 — Market Intelligence (Tier B): Marketplace Research
**Goal:** Turn Synergia into a serious product-research platform using only data the tenant has already authorised via marketplace OAuth. ZikAnalytics-grade eBay research, Helium-10-grade Amazon research, Etsy SEO research — all integrated with the operations side. No new third-party data feeds yet.

**Azure infrastructure tier:** No changes from Phase 13. ~£300–380/month (reserved). Add Azure Cognitive Search if not already present (search across research data).

**Deliverables:**

_Marketplace data ingestion_
- **eBay Terapeak ingestion** — sold listings, sell-through rate, price trends, category insights via the eBay seller-already-authorised API; daily refresh per tenant
- **Amazon SP-API research feeds** — BSR (Best Sellers Rank) tracking for tenant's listings + watchlist; search query performance reports; brand analytics where available
- **TikTok Shop trending products** API (where exposed)
- **Etsy shop stats + search analytics** API
- **Vinted limited stats** (whatever the API exposes)

_Research surfaces_
- **Niche Explorer** — browse marketplace categories with demand/competition/price-band stats; filter by margin opportunity, growth rate, saturation; sort by metric
- **Listing Tracker** — paste/import competitor listing URLs; track price + stock + reviews + sales-velocity proxy over time; alert on changes
- **Keyword Lab** — search-term volume + competition score sourced from marketplace search APIs; suggested title structure for new listings; reverse-listing keyword extraction
- **Competitor Watch** — track named competitor accounts per channel; their active listings; price changes; new launches in your niche
- **Opportunity Feed** — AI-generated suggestions: "5 products you should consider adding based on your catalogue performance + marketplace demand"
- **Side-by-side compare** — pin 2–8 research items for side-by-side comparison

_Closed-loop pipeline_
- Convert any research item to: a catalogue product (auto-fill attributes from research data) → a channel listing (with AI-optimised title from Keyword Lab) → a draft PO to a supplier (placeholder until Phase 15 supplier matching)
- `research_action_pipeline` records every research → action conversion for retrospective ROI ("of the 50 products I researched in Q3, 12 became listings, 4 are now top-margin SKUs")

_Research-aware AI assistant_
- MCP tools: `search_research(query)`, `track_listing(url)`, `find_keywords(category)`, `recommend_products(criteria)`
- Operator can ask: "what's selling on eBay UK in pet supplies under £20 with > 30% sell-through?" → AI uses Tier-B data to answer

**Plan tier:** Market Intelligence Tier B is part of the **Growth tier and above** (free/Starter tier gets Tier-A insights only).

**Acceptance criteria:**
- Terapeak data refresh produces accurate sold-listing counts within ±5% of eBay's own seller-hub Terapeak page
- Niche Explorer returns ranked categories within 3 seconds for a tenant with 5K+ SKUs
- Listing tracker captures a competitor price change within 1 hour of it happening on the marketplace
- Opportunity Feed generates ≥ 5 actionable AI recommendations per week with > 30% operator-acceptance rate (measured)
- Research → catalogue conversion creates a valid product/listing draft in under 10 seconds

**Risks:** Terapeak API access tier varies by eBay seller level — confirm what tier of data we can ingest for sub-tier eBay sellers. Amazon SP-API rate limits constrain how many tenants we can refresh per hour at scale — may need queued background refresh per tenant.

---

### Phase 15 — Market Intelligence (Tier C): Full Research Platform
**Goal:** Synergia becomes the platform that goes from "what should I sell?" to "here's a draft PO for the supplier" without leaving the app. Cross-marketplace arbitrage detection, supplier matching with AI image search, third-party data feeds. The category-defining capability.

**Azure infrastructure tier:** Add Azure OpenAI (or Anthropic vision endpoints) for AI image matching; storage for product image vectors; potential ClickHouse/dedicated analytics tier for time-series market data at scale. Estimated cost: **~£450–600/month** before per-tenant Tier-C usage charges.

| Change | From | To | Reason |
| --- | --- | --- | --- |
| Vector storage | — | Azure AI Search (with vector index) OR Azure CosmosDB vCore (Mongo-style with vector) | AI image-match across millions of supplier products |
| ClickHouse evaluation | — | Decide here whether market time-series data crosses the 10M-events threshold from earlier ADR (`reporting-store`) — provision if so | Tier-C generates large volumes of price/BSR/trend time-series |

**Deliverables:**

_Third-party data feeds_
- **Keepa integration** — Amazon price history, sales rank history, buy-box history; per-product subscription model
- **DataForSEO integration** — keyword volume, competition, related keywords; covers Google search demand (vs marketplace search demand from Tier B)
- **Google Trends API** — trend direction for niches/keywords
- **TikTok Creative Center API** (where available) — trending products, creator/affiliate signals
- **Alibaba/AliExpress search API** (where available, otherwise via approved data partners) — supplier-side product catalogue
- `market_data_feeds` registry; per-feed quota per tenant; usage billing (passthrough or markup)

_Universal product identity_
- `market_universal_products` — cross-marketplace product matching by EAN/UPC/GTIN + ASIN + AI image vector hash + fuzzy title match
- AI image embedding service: every research item + every supplier search result gets a vector hash; matched within configurable similarity threshold
- Manual override UI for operator-confirmed matches (improves AI training data over time)

_Cross-marketplace arbitrage detection_
- `research_arbitrage_signals` — automated detection: "this product sells on TikTok at £15 but on eBay at £25; potential arbitrage gap"
- Filters: minimum margin %, minimum daily volume, marketplace pair, country
- One-click action: "list this on eBay too" → draft listing in Synergia

_Supplier matching (Alibaba/AliExpress)_
- Operator clicks "find supplier" on any research item → AI image-match against Alibaba/AliExpress catalogue → ranked candidates with confidence score
- Per-candidate: estimated landed cost (FOB + shipping + duty + VAT) → margin estimate at current marketplace selling price
- One-click "create draft PO" → fills supplier quote details → operator reviews + sends
- `research_supplier_matches` records every match attempt + outcome

_White-space / niche hunting_
- "Find categories with > 30% margin, > 50 monthly UK sales, < 20 active sellers, growing > 10% MoM" — population-level analytics across marketplaces
- Saturation index per category
- Geography arbitrage hints (e.g. "this product sells well in US but is underserved in UK")

_AI research orchestration_
- MCP tools (extend Phase 13/14 set): `find_supplier_matches(item_id)`, `detect_arbitrage(filters)`, `analyse_niche(category)`, `forecast_product_potential(supplier_url)`
- The in-app AI assistant + Claude Desktop both can drive the full research pipeline end-to-end

**Plan tier:** Market Intelligence Tier C is a **paid add-on** OR included in **Scale / Enterprise tier**. Per-tenant data-feed costs passed through (transparent: "this Keepa lookup cost £0.02") OR bundled into tier subscription with monthly quota.

**Acceptance criteria:**
- Image-match between operator's research item photo and an AliExpress product returns ≥ 85% accuracy on a curated 100-product test set
- Cross-marketplace arbitrage signal correctly identifies a known £10 price gap within 24 hours of price change
- Supplier match → landed cost estimate within ±10% of operator-verified actual landed cost
- White-space query "categories > 30% margin, < 20 sellers, growing > 10% MoM" returns < 60 seconds against full UK marketplace dataset
- Per-tenant Tier-C feed usage tracked and billed correctly (or counted against subscription quota)

**Risks:** Third-party data feed costs at scale (£0.001–£0.10 per request × millions of requests/month) need careful budgeting — risk is unprofitable Pro tier if pricing is wrong. AI image matching false positives could send operators to wrong suppliers; mitigated by operator confirmation step before any PO is drafted. Some marketplaces' TOS prohibit certain types of competitor data ingestion — legal review required before each feed goes live.

---

### Phase 16 — Storefront Channels + Dropship
**Goal:** Connect customer-owned storefronts; enable dropship supplier routing.

**Azure infrastructure tier:** No changes from Phase 11. ~£300–380/month (reserved).

**Deliverables:**
- Shopify adapter (full depth): products, orders, fulfilment, refunds, webhooks
- WooCommerce adapter (full depth): REST API + webhook sync
- BigCommerce adapter
- Magento adapter (native — no bridge layer)
- OpenCart + PrestaShop adapters (lower priority; ship as demand confirmed)
- Dropship order routing: order line → supplier → auto-forward PO → supplier ships → tracking relayed
- Dropship supplier portal: lightweight supplier-facing view to see assigned orders and enter tracking

**Decision (2026-05-07): No api2cart.** All storefront adapters are built natively. The normalisation layer's quality trade-off and per-tenant cost is not worth the engineering saving — and we already own the `MarketplaceAdapter` / storefront adapter framework. Native adapters give better fidelity, no third-party dependency, and full TOS compliance per platform.

**Acceptance criteria:**
- Shopify order placed → lands in Synergia within 15 seconds → fulfilment confirmed → tracking written back to Shopify
- Dropship order forwarded to supplier → supplier enters tracking → tracking written back to channel — without operator touch

**Risks:** Dropship supplier portal is a new user persona; keep it simple (tracking-entry only) for v1.

---

### Phase 17 — Enterprise Hardening + Public API + Public MCP Server
**Goal:** Platform ready for enterprise customers, third-party integrations, and external AI agent connectivity.

**Azure infrastructure tier:** Add geo-redundancy and zone-redundant HA for enterprise SLA commitments. Estimated cost: **~£500–700/month**.

| Change | From | To | Reason |
| --- | --- | --- | --- |
| Azure SQL | General Purpose, single zone | Business Critical or zone-redundant replica | 99.99% SLA required for enterprise contracts |
| Azure Container Apps (API) | UK South only | UK South primary + UK West secondary (Front Door routing) | Regional failover for enterprise customers |
| Azure Static Web Apps | Standard, single region | Standard — already globally distributed via built-in CDN | No change needed; SWA CDN is global by default |
| Azure Service Bus | Standard | Premium (if message volume warrants) | Dedicated capacity, VNet integration, larger message size |
| Azure SignalR Service | Standard 1 unit | Standard 2+ units | Scale with connection count at 100+ concurrent customer sessions |

**Deliverables:**

_Public API & developer platform_
- Public REST API: documented, versioned (`/api/v1/`), scoped OAuth tokens, rate limits per tier
- Developer portal: API docs, webhook event catalogue, sandbox environment with realistic test data
- API key management UI: create/revoke scoped keys, per-key rate limit visibility

_Public MCP Server (write GA — read-only beta launched in Phase 13)_
- Promote read-only beta to write-enabled GA — full tool surface available
- Publish `synergia-mcp` v1.0 (PyPI + npm wrapper for Claude Desktop config)
- Public MCP server connects to Synergia via API key (same as REST API auth — no new auth system)
- Full resource + tool + prompt surface identical to internal MCP server (Phase 13), now accessible from Claude Desktop, Cursor, Windsurf, and any other MCP-compatible client
- MCP server config snippet published in developer portal for one-click Claude Desktop setup:
  ```json
  {
    "mcpServers": {
      "synergia": {
        "command": "uvx",
        "args": ["synergia-mcp"],
        "env": { "SYNERGIA_API_KEY": "sk_live_..." }
      }
    }
  }
  ```
- Rate limits: MCP tool calls count against the company's API quota (same token bucket as REST API)
- MCP server is read-scoped by default; write tools require an API key with `write` scope explicitly granted

_Enterprise hardening_
- Multi-warehouse advanced operations: cross-site stock transfers, site-level performance reports
- Advanced RBAC: custom role templates, permission audit log, bulk role assignment
- Accounting integrations: Xero + QuickBooks native sync (invoices, COGS, payments)
- EDI: basic EDIFACT/X12 support for large retail partners
- SLA management: configurable SLA targets per channel; breach alerting; ops dashboard SLA gauges
- Platform admin: tenant health dashboard, usage analytics, churn signals, support tooling

**Acceptance criteria:**
- Public API documented with OpenAPI spec; sandbox returns realistic test data
- Xero sync: invoice created in Synergia appears in Xero within 5 minutes
- Custom role can be created with screen-level deny on Profitability Analytics; user with that role cannot see the screen
- `uvx synergia-mcp` installs and connects to Synergia in Claude Desktop; `inventory://skus` resource returns correct live data
- MCP write tool called from Claude Desktop requires `write`-scoped API key; read-only key returns 403 on write tool calls

---

## Step 7 — Cross-Cutting Deliverables

### Adapter Capability Matrix

**Phase introduced:** P5 = Phase 5, P8 = Phase 8, P11 = Phase 11, P12 = Phase 12, P16 = Phase 16

**Vinted note (verified 2026-05-07 against Vinted Pro Integrations docs):** Vinted Pro Integrations API is **invite-only**, supports listings/orders/webhooks/shipping labels but **does NOT offer returns, disputes, messaging, account health, payouts, or feedback APIs**. The reduced capability set is reflected below; what isn't checked here means the operator uses the Vinted UI directly for that workflow. Initial slot allocation is 500 active items per API user — slot increase negotiated per partner.

| Capability | eBay (P5) | TikTok Shop (P5) | Vinted (P5) | Etsy (P12) | Amazon (P12) | Shopify (P16) | WooCommerce (P16) | ShipStation (P8) | Royal Mail (P8) | Evri (P11) | DPD (P11) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Auth | OAuth | OAuth | HMAC | OAuth | OAuth | OAuth | OAuth | API key | API key | API key | API key |
| Listings | ✓ | ✓ | ✓ (≤500 items) | ✓ | ✓ | ✓ | ✓ | — | — | — | — |
| Orders | ✓ | ✓ | ✓ (read + cancel) | ✓ | ✓ | ✓ | ✓ | — | — | — | — |
| Fulfilment | ✓ | ✓ | ✓ (label via Vinted) | ✓ | ✓ | ✓ | ✓ | — | — | — | — |
| Cancellations | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | — | — | — | — |
| Returns | ✓ | ✓ | ❌ Vinted UI | ✓ | ✓ | ✓ | ✓ | — | — | — | — |
| Cases/disputes | ✓ | ✓ | ❌ Vinted UI | stub | ✓ | — | — | — | — | — | — |
| Messaging | ✓ | ✓ | ❌ Vinted UI | ✓ | stub | — | — | — | — | — | — |
| Account health | ✓ | ✓ | ❌ Vinted UI | — | ✓ | — | — | — | — | — | — |
| Feedback | ✓ | — | ❌ Vinted UI | ✓ | — | — | — | — | — | — | — |
| Finance/payouts | ✓ | ✓ | ❌ estimated only | — | ✓ | — | — | — | — | — | — |
| Reports | ✓ | ✓ | — | — | ✓ | — | — | — | — | — | — |
| Webhooks | ✓ | ✓ | ✓ (item + order events) | ✓ | ✓ | ✓ | ✓ | — | — | — | — |
| Label generation | — | — | — | — | — | — | — | ✓ | ✓ | ✓ | ✓ |
| Rate quote | — | — | — | — | — | — | — | ✓ | ✓ | ✓ | ✓ |
| Tracking | — | — | — | — | — | — | — | ✓ | ✓ | ✓ | ✓ |
| Manifest/booking | — | — | — | — | — | — | — | ✓ | ✓ | ✓ | ✓ |

### Rate-Limit Budget (70% of documented API maximum)

| Adapter | Documented limit | Synergia budget | Strategy |
| --- | --- | --- | --- |
| eBay REST | 5,000 calls/day per app | 3,500/day | Token bucket per (company_id, adapter); backoff + re-queue |
| TikTok Shop | 10,000 calls/day | 7,000/day | Token bucket; webhook-first to reduce polling |
| Amazon SP-API | Varies by endpoint (1–100 req/s) | 70% per endpoint | Per-endpoint token bucket; respect Retry-After header |
| Etsy | 10 req/s | 7 req/s | Leaky bucket |
| Vinted | Undocumented | Conservative: 2 req/s | Exponential backoff on 429 |
| Royal Mail | 1,000 calls/day | 700/day | Cache rate quotes; don't requote identical shipments |

### Migration Strategy from Current Schema

1. Run current Synergia until Phase 2–4 of rebuild are complete (parallel track)
2. Phase 5: stand up new platform with eBay + TikTok Shop + Vinted adapters connected to new schema; channel onboarding wizard pulls existing listings
3. Migrate company data: companies → company_memberships → channels → products (CSV import tooling); customer data migrated to new `customers` entity from Phase 6
4. Run parallel order processing for 2 weeks (both platforms receive from same channels)
5. Cutover: flip channel webhooks to new platform; sunset old order ingest
6. Historical data migration (orders, inventory history): async backfill job post-cutover; FX rates back-populated from `fx_rates` for historical multi-currency P&L

### Test Strategy

Full detail in `docs/testing/TESTING_STRATEGY.md`. Summary below.

#### Test Pyramid

| Layer | Tool | Scope | Coverage target |
| --- | --- | --- | --- |
| Unit | xUnit (.NET) + Vitest (frontend) | Individual functions, services, components, permission resolution, fee calculations | 80% line coverage — CI fails below threshold |
| Integration | xUnit + Testcontainers (real SQL Server + Redis in Docker) | API endpoints, DB queries, EF Core migrations, webhook handlers, queue consumers | All API endpoints covered |
| E2E | Playwright (web) | Critical user flows: sign-up, order lifecycle, stock movement, label generation, returns | Every flow defined in phase acceptance criteria |
| UI regression | Playwright visual snapshots | Key screens at 1280×800 and 375×812 (mobile viewport); marketing site key pages; **both `en-GB` (LTR) and `ur-PK` (RTL) variants captured** | All primary screens × both locales; diff on every PR |
| i18n coverage | Custom CI script | Every key in `en-GB.json` has matching key in `ur-PK.json`; no orphan keys; ICU plural forms valid | 100% key parity — CI fails if any key missing |
| Marketing perf/SEO | Lighthouse CI | Every marketing page on every PR | Perf 95+, SEO 100, a11y 100 — CI gate, no merge below |
| Mobile E2E | Detox (Phase 9+) | WMS scan flows, offline sync, barcode validation | All WMS operator flows |
| Load | k6 | Order ingest, label generation, rate shopping, listing push | p95 < 2s, error rate < 0.1% at 10× expected peak |
| Contract | OpenAPI → `packages/api-types` diff check | API contract matches generated TypeScript types | Zero drift enforced in CI |

#### CI/CD Integration (GitHub Actions)

```
PR opened / updated:
  api.yml      → unit + integration + migration check (target: < 4 min)
  frontend.yml → unit (Vitest) + E2E headless (Playwright) + visual diff

Merge to main:
  All of the above + full E2E suite against dev environment

Nightly (02:00 UTC) — test-scheduled.yml:
  Full suite against staging + load tests (k6) + visual regression full run

Pre-release gate:
  Load tests must pass p95 < 2s threshold before any production deploy
```

#### Per-Phase Test Focus

| Phase | Test focus |
| --- | --- |
| 0 | No code — research docs peer-reviewed |
| 1 | No code — schema entity stubs compile; permission matrix reviewed; currency/tax/customer/buffer schema decisions locked |
| 2 | Migration integrity; all tables have `company_id NOT NULL`; tenancy guard 403; idempotency middleware; marketing site Lighthouse 95+/100/100; waitlist form E2E; ESLint blocks raw JSX strings; RTL Playwright snapshot for app shell |
| 3 | Auth flows; action-level permission resolution chain; audit log middleware; notification delivery; Stripe idempotency; free tier gating; marketing → app sign-up flow E2E with UTM persistence |
| 4 | Stock movement ledger immutability; BOM/combo decrement at correct quantity; multipack handling; multi-warehouse aggregation; FX rate fetch; UK VAT calculation; customer + RTV workflows; category rule matching (keyword/SKU/price conditions); expense allocation sum enforcement (must equal 100%); recurring expense scheduling; portfolio channel membership |
| 5 | Listing push/pull round-trip across eBay/TikTok/Vinted; channel buffer rule enforcement; pricing rule application; AI listing suggestion E2E; channel onboarding wizard 60s target; marketing site feature pages indexed correctly (Google Search Console verification); demo request form lead capture; full Urdu translation parity (CI gate); RTL visual diff on all primary screens; Urdu hreflang on marketing pages; Linnworks 5K-product import dry-run + commit + idempotent re-import |
| 6 | Order ingest deduplication; stock allocation pessimistic lock; address validation; customer record creation/match; multi-currency capture; tax capture per order line; @mention notification |
| 7 | Returns workflow E2E (marketplace-synced and operator-initiated); cancellations propagation; dispute case round-trip; AI return triage suggestion; RTV separate from customer return |
| 8 | Carrier rate shopping accuracy; ZPL label round-trip; tracking writeback; manifest submission; void label; insurance line capture |
| 9 | WMS barcode scan validation; wrong-scan block; offline sync; demand forecast accuracy; cycle count variance & approval flow |
| 10 | Automation rule engine; profitability calculation vs. manual spreadsheet (with expense allocation); repricing engine velocity throttle; AI repricing suggestions; all 18 starter-pack reports return correct data; UK VAT100 figures match control set; scheduled report PDF email delivery; saved report runs invoke zero AI tokens; monthly close lock produces correct immutable snapshots (company + per-channel); close figures unaffected by post-lock order edits; expense custom split appears correctly in channel P&L; portfolio P&L aggregates without double-counting |
| 11 | Full marketplace adapter capability tests (eBay + TikTok); Vinted reduced-scope adapter coverage tests (verify capability flags correctly degrade for absent capabilities); messaging hub SLA (eBay + TikTok); 3PL shadow-tenant scoping; account health alert (eBay + TikTok); status page metrics accuracy |
| 12 | Etsy + Amazon SP-API integration tests against sandbox |
| 13 | Internal MCP tool calls scoped to company; in-app chat E2E; public MCP read-only beta install + auth; AI report authoring spec validity; saved-report re-run consumes 0 AI tokens (App Insights metric); dashboard create-widget-resize flow under 60s; template clone produces fully detached copy; cascading dashboard filter updates all compatible widgets; share link respects expiry + revocation; kiosk mode renders correctly |
| 14 | Terapeak ingestion accuracy (±5% of seller-hub UI); Niche Explorer ranking under 3s; Listing Tracker change detection within 1 hour; Opportunity Feed > 30% acceptance rate; Research → Action conversion under 10s |
| 15 | AI image match ≥ 85% accuracy on test set; arbitrage signal precision; supplier landed-cost estimate ±10%; white-space query under 60s; per-tenant feed billing reconciles |
| 16 | Native storefront adapter round-trip (Shopify / WooCommerce / BigCommerce / Magento); dropship flow |
| 17 | Public REST API contract; SDK package install; public MCP write tools E2E; Xero/QuickBooks sync |
| All | 80% unit coverage; E2E on every acceptance criterion from every phase |

### Azure Infrastructure Cost Progression

Cost optimisation principles applied throughout:
- Serverless/consumption tiers until paying customers exist (Phases 0–4)
- Services phased in only when the feature they support is built
- 1-year reserved capacity purchased at Phase 13 once workloads are stable
- Dev/Test subscription for all non-production environments (~40% off)
- Application Insights adaptive sampling from day one
- Blob Storage lifecycle policy: hot → cool (30 days) → archive (90 days)
- Azure Cost Management budget alert set at each phase ceiling
- AI tokens (Claude API) budgeted per tenant per day; free tier excludes AI features (D2 / D13)
- **AI Cost Model:** see [`Plans/AI_COST_MODEL.md`](AI_COST_MODEL.md) — per-feature cost estimates, per-tier roll-ups, daily caps, validation milestones. Reviewed at Phase 0, 5, 11, 13, then monthly.

| Phase | Key infrastructure changes | Est. monthly (production) |
| --- | --- | --- |
| 0–1 | No infrastructure spend — research and schema design only | **£0** |
| 2–4 | Azure SQL Serverless, Container Apps consumption, SWA Free, GHCR (free), Blob, App Insights free; Redis deferred | **£80–110** |
| 5–8 | Azure SQL provisioned 2 vCores, SWA Standard (~£7/month), Redis Standard C1, Service Bus Standard, Storage Queues | **£200–270** |
| 9 | Add Azure SignalR Service Standard 1 unit (WMS real-time) | **£250–330** |
| 10–12 | Azure SQL 4 vCores, Azure Front Door Standard | **£380–480** |
| 13 | 1-year reserved on SQL + Container Apps (35% off), App Insights pay-per-GB with sampling | **£300–380** |
| 14 | + Tier-B marketplace research workers (background ingestion), additional Service Bus throughput | **£330–410** |
| 15 | + Vector storage (Azure AI Search vector index), AI image-match compute, third-party feed costs (passthrough or platform-bundled) | **£450–600 base + per-tenant feed costs** |
| 16 | Storefront workload (similar profile to existing channels) | **£450–600** |
| 17 | Azure SQL Business Critical (zone-redundant), secondary region failover, SignalR 2+ units | **£600–800** |

**Dev/Test environment** (separate subscription, non-production): ~£60–80/month at all phases.

### Performance Engineering

Performance is a first-class engineering discipline, not an afterthought. **Every phase has performance acceptance criteria measured against documented targets.** A separate performance regression check runs nightly against staging from Phase 5 onward; CI fails the merge if p95 latency increases > 10% versus baseline.

#### Latency budgets (production targets)

| Endpoint class | p50 | p95 | p99 | Hard cap |
| --- | --- | --- | --- | --- |
| Health check | 10ms | 50ms | 100ms | 200ms |
| Read API (single resource) | 50ms | 200ms | 500ms | 1s |
| Read API (list/search) | 100ms | 400ms | 800ms | 2s |
| Write API (create/update) | 100ms | 500ms | 1s | 3s |
| Carrier rate shopping (multi-carrier) | 500ms | 2s | 4s | 6s |
| Order ingest (webhook) | 100ms | 300ms | 600ms | 2s |
| Listing push to channel | 1s (acknowledged) | 60s (channel confirms) | 120s | 300s |
| Report run (saved spec, < 100K rows) | 500ms | 3s | 8s | 15s |
| Dashboard widget load | 200ms | 1s | 2s | 4s |
| AI chat first token | 500ms | 1.5s | 3s | 5s |
| AI report authoring | 2s | 5s | 8s | 15s |

#### Frontend performance budgets

| Metric | Target | Hard cap |
| --- | --- | --- |
| LCP (Largest Contentful Paint) | < 1.5s | < 2.5s |
| INP (Interaction to Next Paint) | < 100ms | < 200ms |
| CLS (Cumulative Layout Shift) | < 0.05 | < 0.1 |
| TTI (Time to Interactive) | < 2s | < 3.5s |
| Initial JS bundle (gzipped) | < 200KB | < 350KB |
| Lighthouse perf score (marketing) | ≥ 95 | CI fails below |
| Lighthouse perf score (app) | ≥ 80 | CI warns below |

#### Mobile WMS performance budgets (Phase 9)

| Metric | Target | Hard cap |
| --- | --- | --- |
| Scan-to-confirmation visual feedback | < 100ms | < 250ms |
| Wrong-scan error block | < 50ms | < 150ms |
| Pick-task list load (50 items) | < 500ms | < 1.5s |
| Offline-queue sync on reconnect | < 5s for 100 events | < 30s |
| Cold app launch | < 2s | < 4s |
| Battery: full 8h shift, 2K scans | ≥ 30% remaining | ≥ 15% remaining |

#### Scalability targets (per tenant at upper bound)

| Workload | Phase 11 (post-launch) target | Phase 17 (enterprise) target |
| --- | --- | --- |
| Orders/day ingested | 10,000 / day / tenant | 100,000 / day / tenant |
| SKUs in catalogue | 100,000 / tenant | 1,000,000 / tenant |
| Concurrent WMS pickers | 20 / tenant | 200 / tenant |
| Listings synced / hour | 5,000 / hour / tenant | 50,000 / hour / tenant |
| Carrier rate quotes / minute | 60 / minute / tenant | 600 / minute / tenant |
| SignalR concurrent connections (whole platform) | 1,000 | 10,000+ |
| Webhook deliveries / sec (whole platform) | 100 | 1,000 |

#### Database performance discipline

- **Every new endpoint** runs through an **N+1 query audit** before merge — Application Insights query telemetry must show ≤ N+2 queries per request (one parent + one or two batched children, never per-row queries)
- **Every list query** has a covering index documented in `docs/schema-design/INDEXES.md` — adding a query without its index in the same PR is a CI fail
- **Materialised views** (sku_profitability_mv, channel_performance_mv) refresh on a documented cadence per phase: nightly Phase 10; near-real-time (5-min incremental refresh) from Phase 13
- **Read replica** for analytics queries from Phase 5 onward; reporting + dashboard queries route to replica via separate connection string; writes always go to primary
- **Connection pool monitoring** — alert if pool exhausted; per-endpoint connection holding time tracked
- **Slow query log** — anything > 500ms recorded with its plan; weekly review; persistent slow queries get index work

#### Caching strategy (Redis)

| Cache | TTL | Invalidation | Phase introduced |
| --- | --- | --- | --- |
| Carrier rate quotes (same shipment) | 5 min | TTL only | 8 |
| FX rates (latest) | 1h | TTL + manual refresh on rate-source webhook | 4 |
| Tax rates (per jurisdiction) | 24h | Manual on tax-table edit | 4 |
| Permission matrix (per role) | 5 min | Invalidate on role/permission change | 3 |
| Marketplace API rate-limit token buckets | per-bucket lifetime | Decrement on use | 5 |
| AI prompt → response (deterministic prompts) | 1h | TTL only | 13 |
| Saved-report results (cacheable specs) | per-report (default 5 min) | Invalidate on data change in source tables | 10 |
| Dashboard widget data | per-widget refresh interval | TTL only | 13 |
| Public marketing API responses | 5 min | CDN purge on deploy | 2 |

#### Load testing schedule (k6 against staging)

| Phase | Test scenario | Pass criteria |
| --- | --- | --- |
| 5 | Channel listing push at 100 RPS sustained for 5 min | p95 < 2s, error rate < 0.1% |
| 6 | Order webhook ingest at 500 RPS sustained for 10 min | p95 < 600ms, zero duplicates, zero lost events |
| 8 | Carrier rate shopping at 50 RPS (multi-carrier fan-out) | p95 < 2s; carrier rate-limit headroom remains > 30% |
| 9 | WMS scan validation at 10K scans/min across 50 tenants | p95 < 100ms; SignalR delivery p95 < 500ms |
| 10 | Saved-report execution at 100 concurrent runs | p95 < 5s for 100K-order tenant |
| 11 | Mixed-workload soak test 8h at 2× expected peak | Zero memory leaks; zero unbounded queries; pool exhaustion alert never fires |
| 13 | AI chat at 20 concurrent sessions per tenant | First-token p95 < 1.5s; cost per session within budget |
| 17 | Pre-enterprise full-platform soak at 10× peak for 24h | Zero regressions; failover from UK South to UK West < 5 min RTO |

Load tests run **nightly against staging** from Phase 5 onward. **Pre-release gate** (every prod deploy): the relevant phase's load test must pass.

#### Performance review checkpoints

Performance is reviewed at three formal checkpoints, each producing a `docs/perf/REVIEW_PHASE_N.md`:

- **Checkpoint 1 — End of Phase 5** (first paying customers): full N+1 query audit; all critical paths instrumented; baseline p95 recorded for every endpoint class
- **Checkpoint 2 — End of Phase 9** (WMS + mobile live): mobile app perf budget verified on real devices (iPhone SE 2020 + low-tier Android); SignalR scale-out tested
- **Checkpoint 3 — End of Phase 11** (v1 public launch milestone): comprehensive perf audit across all surfaces; signed off as ready for unlimited public sign-ups

#### Performance regression CI gate

From Phase 5 onward:
- Nightly k6 run against staging produces a `perf-results.json` artefact
- CI compares to last week's baseline; **fails the build if p95 latency on any endpoint class regresses > 10%**
- A regression report is auto-posted to the PR that introduced it (using git bisect against the 7-day window)
- Performance team has 48h to fix or explicitly accept the regression with reason logged in `docs/perf/EXCEPTIONS.md`

#### Application Insights custom metrics

Every endpoint emits:
- `request.duration_ms` (with endpoint class tag)
- `db.queries_per_request` (counter)
- `db.duration_ms` (histogram)
- `cache.hit_rate` (per cache name)
- `external.api_calls_per_request` (counter, with adapter tag)
- `ai.tokens_per_request` (per feature tag)

Pre-built Azure Monitor dashboards in `infra/dashboards/`:
- Latency (p50/p95/p99 per endpoint class, last 24h + 7d trend)
- N+1 hot-spots (top 20 endpoints by db.queries_per_request)
- Cache hit rates (per cache, last 7d)
- AI cost burn (per feature, per tenant, real-time)
- External API rate-limit headroom (per adapter, real-time)

---

### Reliability & Scalability Standards

These apply across all phases from Phase 2 onward. They are not phase-specific features — they are baseline requirements for a production-grade platform. Full detail in referenced `docs/` files.

---

#### 1. Feature Flags

**Tool:** Flagsmith (open-source, self-hostable on Azure Container Apps) — no third-party SaaS dependency, no per-seat cost.

- Every new feature behind a flag from day one — ship dark, enable per-company or globally
- Kill switch for any adapter, integration, or AI feature without a deploy
- Flag resolution: `IFeatureFlagService.IsEnabled("feature-slug", companyId)` — not raw config booleans
- Flags stored in `feature_flags` table (tenant-scoped + global); Flagsmith SDK reads from it
- Platform admin UI: enable/disable flags per company, per plan tier, or globally
- Use cases: beta access per company, gradual rollouts, A/B tests, emergency kill switches
- Flag definitions documented in `docs/feature-flags/FLAGS.md` — every flag has: name, description, default state, owner, planned removal date

---

#### 2. GDPR / Compliance

UK + EU operation requires explicit data protection compliance from day one. **Phase 1 schema decision; ongoing operational discipline.**

- **Data Subject Access Requests (DSAR):** `gdpr_dsar_requests` table tracks each request — type (export/delete), requester, status, due date (30 days)
- **Data export:** any data subject (a customer, an operator) can request a JSON export of their personal data via authenticated request — fulfilled within SLA
- **Right to be forgotten:** delete request anonymises personal fields on `customers`, `customer_addresses`, `audit_log` (replace `user_id` with system marker), retains operational/financial records (legitimate-interest basis)
- **Retention policies:** `gdpr_retention_policies` table defines per-resource retention (e.g. inactive customer data → anonymise after 7 years; audit logs → retain 7 years)
- **Auto-purge job:** nightly Hangfire job applies retention policies; logs every action
- **Data residency:** all data in Azure UK South (UK South + UK West for HA) — never crosses out of UK
- **Sub-processor list:** maintained at `synergia.co.uk/legal/sub-processors` — every third-party service Synergia routes data through (Stripe, Anthropic, Open Exchange Rates, etc.)
- **DPA template:** Data Processing Agreement template available for enterprise customers

---

#### 3. Health Checks & Readiness Probes

Three endpoints on `Synergia.Api` from Phase 2 onward:

| Endpoint | Type | Checks | Used by |
| --- | --- | --- | --- |
| `GET /health/live` | Liveness | Process is alive (always 200 if running) | Container Apps liveness probe |
| `GET /health/ready` | Readiness | DB connection, Redis connection, Key Vault reachable | Container Apps readiness probe — traffic held on old revision if failing |
| `GET /health/startup` | Startup | EF Core migrations applied; seed data present | Container Apps startup probe |

- Zero-downtime deploys depend on readiness probe — never remove it
- Health check responses include dependency status detail (for ops debugging, not exposed publicly)
- Azure Monitor alert fires if readiness probe fails for > 2 minutes

---

#### 4. Distributed Tracing & Correlation IDs

- Every inbound HTTP request generates a `CorrelationId` (UUID) at the API gateway level if not already present in `X-Correlation-ID` header
- `CorrelationId` propagated through: all downstream HTTP calls, queue messages (as message property), Hangfire jobs (as job parameter), worker logs
- All Serilog log lines include `{CorrelationId}` and `{CompanyId}` as structured properties → flows into Application Insights as custom dimensions
- Application Insights `operation_id` links all traces, logs, and exceptions from a single request end-to-end
- Outbound HTTP clients (marketplace adapters, carrier adapters) forward `X-Correlation-ID` header to external APIs where supported
- Queue messages carry `CorrelationId` so background job traces link back to the originating HTTP request

---

#### 5. SLA Alerting (Azure Monitor)

Alert rules active from Phase 2 onward, tightened at each phase:

| Alert | Threshold | Action |
| --- | --- | --- |
| API p95 latency | > 2 000ms over 5 min | Email + webhook to on-call |
| API error rate | > 1% of requests over 5 min | Email + webhook |
| Container Apps memory | > 80% for 10 min | Email |
| SQL DTU / vCore utilisation | > 85% for 15 min | Email — trigger scale-up review |
| Service Bus queue depth | > 5 000 messages for 10 min | Email — consumer may be stuck |
| Webhook delivery failures | > 50 failures in 5 min | Email — external service may be down |
| Hangfire failed jobs | > 10 in 1 hour | Email |

- Action groups: email `admin@digitalperception.co.uk` + Slack webhook (when configured)
- All alert rules defined as Bicep resources in `infra/modules/monitoring.bicep` — not clicked in portal
- Custom Application Insights dashboards per domain: Orders, Inventory, Adapters, Background Jobs
- Dashboard definitions stored as JSON in `infra/dashboards/`

---

#### 6. Database Connection Pooling

- Connection string: `Min Pool Size=5; Max Pool Size=100; Connection Timeout=30; Command Timeout=60`
- EF Core retry policy: 3 retries with exponential backoff (1s, 2s, 4s) for transient SQL errors (`SqlException` with retryable error codes)
- Connection pool metrics exported to Application Insights via custom `IDbConnectionInterceptor`
- Alert if pool exhausted (all connections in use) — signals need to scale Container Apps replicas or increase pool size
- Dapper queries (reporting) use a separate read-only connection string pointing to a read replica (Phase 5+ when provisioned DB is in use)

---

#### 7. Idempotency on All Mutating Endpoints

Every `POST`, `PUT`, `PATCH`, `DELETE` endpoint supports an `Idempotency-Key` header:

- Client sends `Idempotency-Key: <uuid>` with any mutating request
- API stores `(idempotency_key, method, path, status_code, response_body, created_at)` in `idempotency_keys` table
- If same key seen again within 24h: return cached response, skip re-execution
- If same key with different method/path: return 422
- Idempotency key TTL: 24 hours (cron job purges expired rows nightly)
- Documented in OpenAPI spec for every mutating endpoint
- Stripe webhooks, marketplace webhooks, and carrier callbacks all use idempotency via `webhook_inbox.idempotency_key` (existing design) — same pattern, different table

---

#### 8. Secrets Rotation

- All secrets in Azure Key Vault — zero secrets in environment variables, config files, or container images
- App references secrets by **name only**, not version — Azure resolves to current version at runtime
- Rotation procedure (zero-restart):
  1. Add new secret version in Key Vault
  2. Verify new version resolves (health check confirms connectivity)
  3. Revoke old version
  4. No application restart required — next Key Vault read picks up new version
- Secret types and rotation schedule documented in `docs/runbooks/secrets-rotation.md`
- Key Vault access via managed identity only — no service principal credentials stored anywhere
- Key Vault diagnostic logs forwarded to Log Analytics — alert on any unauthorized access attempt

---

#### 9. Data Backup & Point-in-Time Recovery

| Tier | Backup type | Retention | RTO | RPO |
| --- | --- | --- | --- | --- |
| Azure SQL built-in PITR | Continuous transaction log backup | 7 days (dev), 35 days (prod) | < 4 hours | < 5 minutes |
| Weekly export | Full `.bacpac` export to Blob Storage (GRS) | 12 weeks | < 8 hours | 1 week |
| Pre-migration snapshot | Manual `.bacpac` before every EF Core migration | Indefinite | < 2 hours | Point of snapshot |

- Weekly export automated as Hangfire recurring job: `SqlExportJob` → uploads to `backups/` container in GRS Blob Storage
- Recovery procedure documented and tested quarterly: `docs/runbooks/database-restore.md`
- Restore test: restore to a throwaway Azure SQL instance; verify row counts match; document result
- Blob Storage backup container: soft delete enabled (30-day recovery), immutability policy (no delete for 90 days)
- Pre-migration snapshot is mandatory before any `dotnet ef database update` in production — enforced in `infra.yml` pipeline

---

### Market-Leading Differentiators

These are the features that move Synergia from "competitive with Linnworks/StoreFEEDER" to "category leader." Each is a deliberate design choice woven through the phases.

| Differentiator | Phase | Why it wins |
| --- | --- | --- |
| **Native MCP server (internal + public)** | 13 (read) → 15 (write) | First-and-only operations platform with full MCP support — operators run analyses and actions from Claude Desktop directly against their live data |
| **AI woven through every workflow** | From Phase 5 onwards | Listing optimisation (P5), return triage (P7), repricing suggestions (P10), forecasting (P9 → P13), messaging drafts (P11) — not a single chat panel bolted on at the end |
| **Free tier for sub-£100K turnover sellers** | Phase 3 | Acquires sellers young; locks them in before they hit Linnworks/StoreFEEDER price brackets. Near-zero Azure cost on consumption tier |
| **"60-second connect" channel onboarding** | Phase 5 | First-impression UX: connect a marketplace and see your existing listings matched in under a minute. Major retention driver |
| **Public uptime / metrics page** | Phase 11 | Trust signal — Linear/Statuspage style transparency. Marketplace sync latency per channel visible to prospects |
| **Open-source `MarketplaceAdapter` SDK** | Phase 11–13 (decision) | Community-built marketplace adapters; one-way moat against closed competitors |
| **3PL shadow-tenant model** | Phase 1 (schema) → Phase 11 | Brands managed by 3PLs are real `companies`, not portal tokens. Scales properly; lets brand-side staff work natively while 3PL operator has cross-tenant view |
| **Transparent turnover-based pricing** | Phase 3 | Rolling 30-day contract; no per-order, per-user, per-listing fees. Direct attack on Linnworks/Brightpearl pricing complexity |
| **Multi-currency + base-currency P&L** | Phase 1 (schema) → Phase 10 | UK + EU operation handled cleanly from day one; competitors patch this in retroactively |
| **First-party developer SDKs** | Phase 17 | TypeScript + Python SDKs published with the public REST API. Lower friction than competitors' raw API docs |
| **Three-tier product research** | Phase 13 (Tier A) → Phase 14 (Tier B) → Phase 15 (Tier C) | **No competitor offers ops + research in one platform.** ZikAnalytics / Helium 10 / Jungle Scout / Keepa are external tools you pay for separately. Synergia closes the loop: research → list → measure → refine, all integrated. Tier C (cross-marketplace arbitrage detection + AI image-match supplier finding) is genuinely category-defining. |
| **Editorial-quality marketing site** | Phase 2 → ongoing | Astro static site at `synergia.co.uk` matching the dark luxury app aesthetic; Lighthouse 95+/100/100 enforced in CI; SEO landing pages per marketplace + per segment; comparison pages directly attacking competitor positioning. The marketing site looks like the product, not a separate brand. |
| **Bilingual (English + Urdu) UI from launch** | Phase 2 (foundation) → Phase 5 (Urdu rollout) | UK has a large Pakistani-British SME seller base — operating Synergia natively in Urdu is a real wedge no UK competitor offers. Full RTL support, Nastaliq typography, native-speaker-reviewed terminology. Per-tenant custom translation overrides for terminology preferences. |
| **AI-authored, AI-free reports** | Phase 10 (engine) → Phase 13 (AI authoring) | Operator describes report in natural language; AI converts to a structured `ReportSpec`; spec saved; report runs forever without AI tokens. Pay AI cost once at design, deterministic SQL forever after. Competitor reporting is rigid pre-built dashboards or expensive BI add-ons; Synergia gives the flexibility of BI with the cost of a static query. |
| **User-built dashboards (no defaults)** | Phase 13 | 13 widget types, 12-col drag-and-drop, cascading filters, kiosk mode for warehouse TVs, visibility tiers, public share links. Competitors ship rigid pre-built dashboards you can't reshape; Synergia ships an empty canvas + a template gallery. Operators build the view their team actually needs. |
| **18 finance reports out of the box** | Phase 10 | Channel P&L, portfolio P&L comparison, SKU profitability, cash flow, expense breakdown, monthly close summary, aged stock, UK VAT100, payout reconciliation, return cost — pre-built from day one. Most competitors charge for "advanced reporting" addons; Synergia ships them in the base tier. |
| **Monthly financial closing (per company + per channel)** | Phase 10 | Lock a period, see channel-level P&L with allocated expenses, produce an immutable PDF snapshot. Competitors either skip this entirely or lock it behind accountancy add-ons. |
| **Flexible expense allocation** | Phase 4 | Company-level overhead split equally or at custom percentages across any subset of channels. Channel P&L and monthly close automatically include allocated expenses — no spreadsheet needed. |

---

### Deferred Features

See [Plans/2027/DEFERRED_FEATURES.md](2027/DEFERRED_FEATURES.md) for features confirmed out of scope for this build.

---

### Locked Decisions (resolved 2026-05-07)

The following questions were resolved on 2026-05-07 and are now decisions, not open questions.

#### 💰 Pricing & Plan Tiers

**D1. 3PL billing model — All-inclusive operator plan with brand-count tiers.**
Starter (1 managed brand), Growth (5), Scale (20), Enterprise (unlimited). One bill per 3PL operator, predictable, no per-brand line items.

**D13. Free tier feature gating — Core features with caps; AI excluded.**
Limits: 1 channel connection, 1 user, 1 warehouse, 100 orders/month, 50 SKUs. All operational features (channels/orders/inventory/WMS/returns) work fully. No AI features. Basic dashboards only — no reporting starter pack. Free tier = acquisition tool, not a forever home.

**D24. Tier B/C research plan gating.**
- Free / Starter → no research
- Growth+ → Tier A insights + Tier B Marketplace Research
- Scale+ → Tier A + B + C standard
- Tier C optionally available as paid add-on for Growth tenants

**D22. Tier C feed cost model — Hybrid.**
Modest quota included in Scale tier (e.g. 500 Keepa lookups/month, X DataForSEO calls/month). Overage billed transparently with operator approval before each costly call ("this Keepa lookup costs £0.02 — confirm?"). Operator stays in control.

#### 🤖 AI & MCP

**D2. AI cost model — Per-tenant per-feature daily caps + monthly aggregate ceiling. Free tier excluded entirely.**
Each AI feature has its own daily token budget per tenant. Monthly company aggregate ceiling. Soft warning at 80%, hard cap at 100%. Free tier zero AI tokens.

**D10. MCP write-tool confirmation UX — Confirmation required for write tools regardless of client.**
Same UX in app chat AND Claude Desktop. AI never executes irreversible actions (create PO, approve return, post message) without explicit operator "yes." Read tools and reversible writes (drafts) skip confirmation.

**D11. Open-source: MarketplaceAdapter SDK, CarrierAdapter SDK, public MCP client. Internal business logic + Tier C research stay closed.**

**D23. AI image-match auto-confirm threshold.**
- ≥ 95% similarity → auto-confirm with audit trail
- 80–95% → operator review with AI confidence shown
- < 80% → drop
Per-tenant tunable; defaults are conservative.

#### 📊 Forecasting & Analytics

**D3. Forecasting cold-start — Velocity-based forecasting from day one with "limited history" warning until 90+ days; opt-in benchmarks layered in once threshold met.**

**D4. Benchmarking opt-in threshold — 100 tenants minimum within a category before benchmarks publish; minimum 5 tenants per slice; ranges shown, not point values; always anonymous.**

**D12. Repricing competitor data source — Phase 10 launches with marketplace APIs only; Phase 15 Tier C adds Keepa as paid add-on.**

#### 🌍 Marketplace & Carrier Adapters

**D5. Vinted access — Vinted stays in Phase 5 launch trio with reduced capability scope (verified 2026-05-07).**
Pilot client already operates eBay + TikTok + Vinted, so Vinted ships at launch. The Vinted Pro Integrations API is invite-only and exposes only listings / orders / cancellations / shipping labels / webhooks — **NOT** returns / disputes / messaging / account health / feedback / payouts. Initial slot cap 500 active items per API user; negotiate increase per partner. Etsy promoted to **must-ship** in Phase 12 to fill the workflow gaps Vinted leaves. Marketing site at Phase 5 must honestly scope Vinted as "listings + orders" — full marketplace ops claim applies to eBay + TikTok only.

**D7. No api2cart — All storefront adapters native.**
Native for Shopify, WooCommerce, BigCommerce, Magento (Phase 16). OpenCart + PrestaShop deferred until customer demand confirmed.

#### 📱 Mobile & Native

**D8. Stay Expo through ~1,000 active warehouse users; revisit native build only when feature requests demand it.**

#### 🏷️ White-label & Reseller

**D9. White-label deferred to 2027.**
Architect for it (per-tenant theme tokens, custom domain support) but no productised white-label tier until 2027. Bespoke deals for strategic partners until then.

#### 👤 Customer Data

**D14. Customer matching — Auto-merge by exact email match in Phase 6; flag fuzzy matches without auto-merging; manual merge tool ships in Phase 13 alongside reporting.**

#### 🌐 Marketing Site

**D15. Marketing CRM — `marketing_leads` table only at Phase 2; sync to HubSpot Free at Phase 11; revisit Salesforce/Pipedrive only if volume demands.**

**D16. Blog content — AI-drafted (Claude) → founder-edited for first 6 months. Contract specialist SEO writer at Phase 11 only if content production proves to drive sign-ups.**

**D17. Marketing site analytics — Plausible Cloud (~£8/month).**
Privacy-first, GDPR-clean, no cookie banner needed for analytics, low cost.

**D18. Cookie banner — Minimal first-party consent UI built in-house. No third-party CMP.**
With Plausible + no marketing cookies, no banner needed under UK ICO guidance. Documented in privacy policy. Revisit if Phase 11+ adds marketing cookies.

#### 🌍 Localisation (resolved earlier)

**D19–D21.** AI-translated + native-speaker human-reviewed; future locale roadmap = Hindi → Polish → Arabic → Romanian; marketplace listings stay in marketplace-supported languages while operator UI is fully localised.

---

### Deferred (revisit later — explicit non-decisions)

**Q6. EDI partner priority (Phase 17).**
**Status: Deferred.** Don't speculate which retail partners need EDI before customers ask. Survey paying tenants in Phase 11+ to identify actual EDI requirements; build only what's requested.

**Q25. Marketplace TOS review for Tier C.**
**Status: Deferred to Phase 14 prep.** Engage UK e-commerce-specialist solicitor before Tier C development for written opinion per planned data feed. Some feeds may be dropped from Tier C as a result. Budget ~£3–5K legal review.

---

### Open Product Questions

_(All other questions resolved — see Locked Decisions above.)_

The remaining unresolved questions all relate to AI-Core architecture and only become live if/when AI-Core is added to the plan:

- **Q26. AI vision provider** — Claude (general) + Azure Document Intelligence (receipts/invoices)? *(Recommended)*
- **Q27. Voice provider for mobile WMS** — Whisper API (transcription) + Azure Speech (wake-words)? *(Recommended)*
- **Q28. AI agent approval UX** — Dedicated "Approvals" inbox + push notifications + chat-message context? *(Recommended)*
- **Q29. Tenant memory storage** — Postgres JSONB on `tenant_ai_memory` table? *(Recommended)*
- **Q30. AI feedback training loop** — Prompt iteration only for v1; revisit fine-tuning at 1,000+ paying tenants? *(Recommended)*
- **Q31. Role-based AI personas** — 4 fixed personas (Warehouse Manager / Finance / Operator / Founder) with role-locked tool access; tone customisation per tenant? *(Recommended)*

These are pending the **AI-Core decision** — do we want to add the AI-Core architecture (universal AI affordance, tenant memory, multi-step agents, proactive watchers, vision/voice) to the plan?

---

## Competitive Positioning Summary

| Competitor | Synergia advantage |
| --- | --- |
| StoreFEEDER | Modern UI + AI woven through workflows + repricing engine + free tier + multi-currency + same WMS depth, same UK channels |
| Linnworks | Transparent rolling-30-day pricing + free tier + native MCP + AI repricing + 60-second channel onboarding + comparable channel breadth |
| Veeqo | Independent ownership (no Amazon conflict of interest) + far deeper analytics + AI layer everywhere + repricing |
| Rithum/ChannelAdvisor | Accessible mid-market pricing (vs. enterprise GMV% fees) + WMS + full-stack operations + AI-native + free tier |
| Sellercloud | Modern UX + UK-native channels + superior analytics + MCP/AI, comparable WMS depth |
| Brightpearl | Comparable automation depth + WMS that Brightpearl lacks + transparent pricing + AI repricing + native MCP |
| Cin7 | Better marketplace breadth + UK-native + no per-user/per-integration caps + native MCP + AI repricing |
| **All competitors** | **Only platform with native MCP server (read-only beta from Phase 13, full from 15) — operators run analyses and actions from Claude Desktop directly against their live data** |
| **All competitors** | **Only platform with AI assistance woven through every workflow** — listing optimisation, return triage, repricing, forecasting, messaging — not a single chat bot bolted on at the end |
| **All competitors** | **Free tier for sub-£100K-turnover sellers** — acquires SMEs before they enter the £500K+ bracket where competitors charge £150–500/month minimum |

---

## Ordered Implementation Sequence

The sequencing principle: **research before schema → schema locked before any migration → infra before app code → auth before business logic → core models (catalogue/inventory/customers/tax/currency) before channels → channels before orders → returns before fulfilment (with carrier framework stubbed early) → fulfilment before WMS → WMS before automation/analytics → AI internal before AI public → expansion adapters last → enterprise/public surfaces last**.

### Foundation (Phases 0–2)

1. **External API research** (Phase 0) — `docs/api-research/` for all marketplaces (eBay, TikTok Shop, Vinted, Etsy, Amazon, Shopify, WooCommerce), carriers (ShipStation, Royal Mail, Evri, DPD), and Stripe; `SCHEMA_IMPACT.md` reviewed
2. **Schema design & lock** (Phase 1) — `docs/schema-design/SCHEMA.md` marked `STATUS: LOCKED`; **multi-currency, VAT, customers, channel buffer, 3PL shadow-tenant decisions all locked here**; EF Core entity stubs approved
3. **Monorepo + CI/CD** (Phase 2) — `src/Synergia.Api/`, `src/Synergia.Workers/`, `src/Synergia.Mcp/`, `frontend/`, `marketing/`, `mobile/`, `packages/api-types/`, `packages/design-tokens/`, `infra/`, `docs/`; five path-filtered workflows
4. **Infrastructure** (Phase 2) — Bicep IaC for dev; Docker Compose local stack; App Insights + Key Vault; idempotency middleware; correlation IDs; health checks; budget alert
5. **Database baseline** (Phase 2) — EF Core baseline migration from locked schema; `dotnet ef migrations list` shows exactly one migration
6. **Seed script** (Phase 2) — companies, users, roles, test data; idempotent
7. **Marketing site MVP** (Phase 2) — Astro scaffold; home + pricing + about + contact + waitlist; deployed to `synergia.co.uk`; Lighthouse 95+/100/100
8. **i18n / l10n foundation** (Phase 2) — `react-i18next` + Astro i18n + `IStringLocalizer` wired; `packages/locales/en-GB.json` baseline; ESLint blocks raw JSX strings; CSS logical properties throughout; RTL handling verified on app shell

### Identity, Audit, Notifications, Billing (Phase 3)

9. **Auth + tenancy guard** — JWT, refresh tokens, `RequireCompanyScope` on every controller; 403 tests green
10. **Action-level RBAC** — `(resource, action)` permission matrix; user override chain; `[RequirePermission]` attribute
11. **Audit log middleware** — every write operation auto-logs; `AuditTimeline` component
12. **Notifications** — in-app centre, email, webhook; per-user preferences; SignalR for real-time
13. **Billing + free tier** — Stripe plans (free/starter/growth/scale/enterprise); webhook idempotency; Customer Portal; plan-gated access
14. **Marketing site → app sign-up flow** — pricing page wired to live plans; UTM persistence through onboarding; legal pages live

### Catalogue & Foundation Models (Phase 4)

15. **Tax & Currency setup** — `currencies`, `fx_rates`, `tax_codes`, base currency on companies; nightly FX fetch
16. **Customer entity** — `customers`, `customer_addresses`, `customer_channels`, tags/notes (populated automatically from Phase 6)
17. **Product catalogue** — products, variants, structured `product_attributes`, BOM/combos with quantity, images, supplier linkage, listing templates, variation groups
18. **Smart category management** — hierarchical category tree; condition DSL rules engine; run_on_import + run_on_save modes; manual override; bulk re-categorise; category stats
19. **Inventory foundation** — warehouses, locations, stock levels, immutable stock movement ledger
20. **Suppliers, POs, GRN, RTV** — supplier CRUD, PO lifecycle, GRN, multi-currency POs, Returns to Vendor flow
21. **Portfolio management** — portfolio CRUD; `portfolio_channels` many-to-many; portfolio summary panel wired to Phase 10 P&L
22. **Expense management** — expense category CRUD; expense entry (company-level + channel-level); allocation rules (unallocated / equal / custom %); recurring expense scheduler

### Channels — Phase 5 (eBay, TikTok Shop, Vinted-reduced)

23. **Marketplace adapter framework** — `MarketplaceAdapter` ABC + `StubMarketplaceAdapter` + registry + capability flags + `webhook_inbox`; auth abstraction supports OAuth + HMAC + API-key
24. **Carrier adapter framework** — `CarrierAdapter` ABC + `StubCarrierAdapter` scaffolded (no real carriers yet — used by Phase 7 returns stub)
25. **eBay adapter (Phase-5 scope)** — OAuth, listing push/pull, inventory sync
26. **TikTok Shop adapter (Phase-5 scope)** — OAuth, listing push/pull, inventory sync
27. **Vinted adapter (Phase-5 scope, reduced API)** — HMAC-SHA256 auth, listings (≤500 active items unless slot increase negotiated), inventory sync, order ingest + cancel, shipping label retrieval, webhooks. **Returns / disputes / messaging / health / feedback / payouts NOT exposed by Vinted API** — adapter capability flags reflect this; downstream features degrade gracefully
28. **Listing management UI** + per-channel listing templates + cross-marketplace variation syndication
29. **Channel onboarding "60-second connect" wizard** — pull existing listings → match catalogue → review → apply
30. **Channel buffer stock rules** — per (channel, variant) reserve qty + max %
31. **Pricing rules engine** — per-channel mark-up, sale prices, RRP floor; currency-aware
32. **AI listing optimisation** — Claude-powered title/keyword/image suggestions; operator-approved before publish
33. **Imports & Migrations** — CSV/XLSX importers per resource (products, inventory, orders, customers, suppliers, listings, channel mappings); validation + dry-run + atomic commit; competitor-format direct paths (Linnworks, StoreFEEDER, Shopify, eBay); column auto-mapping; rollback by `import_batch_id`
34. **Marketing site feature pages** — Marketplace Management, AI Listing Optimisation, Pricing Rules, Channel Buffer Stock; Integrations directory (Vinted page scoped honestly to listings + orders only); segment landing pages (For Sellers / For 3PLs); comparison pages; blog launch + first 5 SEO posts; demo request form
35. **Urdu (`ur-PK`) localisation rollout** — full app + marketing site translated; native-speaker review of operational/SME terminology; RTL visual diff CI gate; Urdu hreflang on marketing site; locale switcher in app + marketing footer; transactional emails in user's locale

### Orders + Customer Operations (Phase 6)

36. **Unified order ingest** — eBay + TikTok Shop + Vinted webhooks → idempotent ingest
37. **Multi-currency + tax capture** — order currency, FX rate, per-line tax data
38. **Address validation at ingest** — postcode lookup + flag failures
39. **Customer record creation/match** — automatic on every order; auto-merge by exact email match (D14); fuzzy matches flagged for Phase 11 merge tool
40. **Order queue UI + state machine + routing rules + timeline**
41. **Operator collaboration** — order notes with @mentions; assignable order tasks

### Returns, Cancellations, Disputes (Phase 7)

42. **Returns workflow** — marketplace-synced (eBay + TikTok only — Vinted has no returns API) + operator-initiated; RMA queue; stock fate decisions; refund via marketplace API; return cost tracking
43. **AI return triage** — Claude analyses return reason + buyer history; suggested decision + risk score; never auto-acts
44. **Cancellations** — marketplace-synced + operator-initiated; propagation back to channel; cancellation window deadline UI
45. **Dispute cases** — eBay + TikTok cases queue (Vinted disputes handled in Vinted UI; Etsy + Amazon disputes arrive Phase 12); SLA countdown; respond via API

### Fulfilment & Carriers (Phase 8)

46. **ShipStation adapter** — rate quotes, multi-carrier label generation, tracking, void
47. **Royal Mail adapter** — Click & Drop / OBA — labels, rates, tracking, manifest
48. **Carrier rate shopping** + shipping rules engine + auto-allocation
49. **Label generation** — ZPL (thermal) + PDF; reprint and void flows
50. **Shipment insurance** + tracking relay back to marketplace
51. **End-of-day manifest builder**
52. **Phase 7 return labels** — migrate from `StubCarrierAdapter` to real carrier

### WMS, Forecasting, Cycle Count (Phase 9)

53. **WMS mobile app** (React Native + Expo) — Operator mode, Manager mode
54. **Pick waves + barcode validation + scan & pack + despatch confirmation**
55. **Stock take / cycle count workflow** — schedule, scan, variance, approve, ledger writes
56. **Demand forecasting engine** — velocity calc, reorder alerts respecting MOQ/lead time, stockout prediction
57. **Staff performance dashboard** — picks/hour, accuracy, leaderboard

### Automation, Repricing, Analytics, Reporting (Phase 10)

58. **No-code automation rule engine** — triggers/conditions/actions, dry-run mode
59. **Repricing engine** — rule-based + AI suggestions; velocity throttle; floor price + audit log
60. **SKU profitability** — `order_line_costs` ledger, materialised view, dashboard, margin alerts (base currency)
61. **Supplier scorecard** — on-time %, lead time variance
62. **Channel P&L** — revenue/fees/COGS/shipping/returns/expenses per channel per period
63. **Monthly Financial Closing** — close wizard, pre-close checklist, P&L summary (company + per-channel + portfolio), lock action with immutable `month_closing_snapshots`, unlock with audit reason, deterministic close PDF
64. **Report engine** — `ReportSpec` executor (Dapper-backed), `report_definitions` CRUD, visualisation types, filters/parameters, CSV/XLSX/PDF export, scheduled delivery (email/Slack/webhook), share links
65. **Finance reports starter pack** — 18 pre-built reports cloned to every tenant on first load
66. **Manual `ReportBuilder` UI** — visual editor for `ReportSpec` (no AI required)

### Marketplace Depth, Messaging, 3PL, Status (Phase 11)

67. **eBay full adapter** — orders, fulfilment, cancellations, returns/cases, account health, feedback, payouts, messaging
68. **TikTok Shop full adapter** — full capability set
69. **Vinted reduced-scope full adapter** — order management depth at the limit of what Vinted Pro Integrations API exposes (full ingest, cancel, label, webhooks). Returns / disputes / messaging / health / feedback / payouts intentionally NOT included — Vinted API does not expose them. Capability flags reflect honestly.
70. **Evri + DPD carrier adapters** added to registry
71. **Marketplace messaging hub** (`ConversationView`) — eBay + TikTok only at Phase 11; Vinted excluded (no API); UI live; AI drafts wired in Phase 13
72. **Account health dashboard** — eBay seller level + TikTok Shop health metrics; defect rate trends, SLA breach alerts; Vinted shows "View in Vinted" placeholder
73. **Marketplace fee reconciliation** — payout reports → `order_line_costs` actuals (replaces estimates) for eBay + TikTok; Vinted fees remain estimated
74. **3PL shadow-tenant model** — `3pl_relationships`; brand switcher; per-brand portal URL
75. **Public uptime / metrics page** — `status.synergia.co.uk`
76. **Marketing CRM sync (HubSpot Free)** — `marketing_leads` mirrored to HubSpot via API
77. **Customer merge tool** — manual merge UI for fuzzy-matched duplicate `customers` records flagged in Phase 6; bulk merge for migration cleanup; precondition for clean LTV/CAC analytics
78. **AI Insights Digest** — daily/weekly AI-generated summary email per opted-in operator
79. **Marketing site case studies + trust** — first paying customers featured; pricing estimator; trust badges; reviews integration

### 🚀 v1 PUBLIC LAUNCH MILESTONE — end of Phase 11

### Expansion Adapters (Phase 12) — Etsy is must-ship to fill Vinted scope gaps

80. **Etsy adapter (full depth)** — full returns / messaging / cases / feedback / shop statistics — fills the workflow gaps Vinted's reduced API leaves
81. **Amazon adapter (SP-API)** — FBA + FBM, full capability set
82. **EU VAT/IOSS support** — for EU expansion alongside Amazon adapter

### AI Layer + Public MCP Beta (Phase 13)

83. **Internal MCP server** — resources + tools + prompts; company-scoped
84. **In-app AI chat assistant** — `/api/ai/chat`, structured data cards, audit attribution
85. **Marketplace messaging AI assist** — drafts in `ConversationView` powered by MCP
86. **AI demand forecasting upgrade** — seasonal decomposition, external signals
87. **Tier-A research insights** — own-data analysis + AI recommendations; closed-loop catalogue actions
88. **AI report builder** — natural language → `ReportSpec`; edit-with-AI; saved reports run without AI tokens; per-tenant token budget; MCP tools `create_report` / `update_report` exposed
89. **User-configurable dashboards** — empty by default; 13 widget types; 12-col drag-and-drop; cascading filters; visibility/permissions; template gallery; kiosk/TV mode
90. **Public MCP read-only beta** — `synergia-mcp` v0.x on PyPI; Claude Desktop config

### Market Intelligence — Tier B (Phase 14)

91. **Marketplace data ingestion** — Terapeak (eBay), SP-API research feeds (Amazon BSR + search query performance), TikTok Shop trending, Etsy stats
92. **Niche Explorer** — browse marketplace categories with demand/competition/price-band stats; filter and sort by margin opportunity, growth, saturation
93. **Listing Tracker** — paste competitor URLs; track price + stock + reviews + sales-velocity proxy over time
94. **Keyword Lab** — search-term volume + competition from marketplace search APIs; reverse-listing keyword extraction
95. **Competitor Watch** — track named seller accounts; new launches alerts; price change alerts
96. **Opportunity Feed** — AI-generated "5 products you should consider" recommendations
97. **Research → Action pipeline** — convert any research item to catalogue product + listing + draft PO
98. **MCP tools** — `search_research`, `track_listing`, `find_keywords`, `recommend_products`

### Market Intelligence — Tier C (Phase 15)

99. **Third-party data feeds** — Keepa (Amazon price history), DataForSEO (keyword volume), Google Trends, AliExpress/Alibaba search; per-tenant subscription/quota tracking
100. **Universal product identity** — cross-marketplace product matching by EAN/UPC/GTIN + ASIN + AI image vector hash + fuzzy title match
101. **Cross-marketplace arbitrage detection** — automated price-gap signals; one-click "list on the cheaper marketplace too"
102. **AI supplier matching** — image-based search across Alibaba/AliExpress; ranked candidates with landed-cost estimate; one-click draft PO
103. **White-space niche hunting** — population-level filters: "categories > 30% margin, < 20 sellers, growing > 10% MoM"
104. **MCP tools (extended)** — `find_supplier_matches`, `detect_arbitrage`, `analyse_niche`, `forecast_product_potential`

### Storefronts, Dropship (Phase 16)

105. **Shopify adapter (full)** — products, orders, fulfilment, refunds, webhooks
106. **WooCommerce + storefront batch** — WooCommerce, BigCommerce, Magento (all native adapters; OpenCart + PrestaShop deferred to demand)
107. **Dropship supplier routing + portal** — order line → supplier → tracking relay

### Enterprise, Public API, Public MCP GA (Phase 17)

108. **Public REST API** — versioned `/api/v1/`, scoped OAuth tokens, rate limits per tier, sandbox
109. **First-party SDKs** — TypeScript + Python published alongside REST API
110. **Developer portal** — API docs, webhook event catalogue, sandbox
111. **Public MCP write GA** — `synergia-mcp` v1.0; full tool surface for Claude Desktop
112. **Accounting integrations** — Xero + QuickBooks native sync
113. **EDI** — basic EDIFACT/X12 support for priority retail partners
114. **Advanced RBAC** — custom role templates, bulk role assignment
115. **SLA management** — configurable targets per channel, breach alerting
116. **Platform admin hardening** — tenant health dashboard, churn signals, support tooling
117. **Geo-redundant HA** — UK South + UK West; Business Critical SQL; SignalR scale-out

---

**WAITING FOR CONFIRMATION**

Reply `proceed` to begin Phase 0 API research.  
Reply `modify: [section]` to adjust any part of the plan.  
Reply `questions first` to resolve any open questions before starting.
