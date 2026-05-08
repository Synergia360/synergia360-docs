# Shipping & Rules Engine — Competitive Gap Analysis

> Addendum to `GREENFIELD_REBUILD_PLAN.md`
> Scope: Phase 8 (Fulfilment + Carrier Rate Shopping & Label Generation) and Phase 10 (No-Code Automation)
> Benchmarks: ShipStation, ShipTheory, ShipEngine, Veeqo, Linnworks, Mintsoft, EasyPost, Shippo, ShipHawk, Starshipit, Shipium
> Author: synergia360-v2 planning workstream
> Date: 2026-05-07

---

## 1. Executive summary

The current Phase 8 deliverables in `GREENFIELD_REBUILD_PLAN.md` cover the **structural skeleton** of a competitive shipping platform — `CarrierAdapter` ABC, ShipStation + Royal Mail at launch, rate shopping, ZPL/PDF label generation, manifest builder, void/reprint, shipment insurance, tracking writeback, and a "shipping rules engine" that auto-allocates carrier/service by weight/value/destination/product type.

When measured against ShipStation's automation rules and ShipTheory's shipping rules engine, the plan is **conceptually aligned but materially under-specified**. ShipStation alone exposes 25+ criteria types, 15+ action types, sub-rules, tag-as-intermediary chaining, dry-run, rule activity history, and presets. ShipTheory adds delivery-instructions matching, sender-postcode conditions, channel-name conditions, day-of-week / time-of-day windows, boxes count, "all products" vs "any product" weight semantics, package-size selection rules, and auto-print routing per matched rule.

The plan's "shipping rules engine" line item (one bullet under Phase 8) and its "no-code automation rule builder" (Phase 10) need to be **expanded into a single, first-class Rules Engine subsystem** with explicit condition DSL, action DSL, simulation harness, and audit trail. Without this, Synergia ships with a feature gap on every demo against StoreFEEDER / Linnworks / ShipTheory.

This document inventories what's already covered, identifies 30+ gaps, and ranks them as **Must-add (P0)**, **Should-add (P1)**, **Could-add (P2)**, and **Defer to post-launch (P3)**.

---

## 2. What ShipStation, ShipTheory and adjacent tools actually do

### 2.1 ShipStation — Automation Rules (the de-facto market reference)

**Architecture:** IF/THEN rules with multiple criteria stacked per rule (AND / ANY-OF), priority-ordered, hierarchical (later rules can overwrite earlier), with an Activity tab per order showing which rules fired. Tags act as the chaining mechanism — Rule A applies a tag, Rule B keys off that tag.

**Criteria (conditions) ShipStation exposes:**
- Order: total value, weight, total quantity, item count, store of origin, channel, order tag (include / exclude), order source, requested service at checkout, ship-by date, paid date, custom field 1/2/3
- Customer: customer name, email contains, customer notes, internal notes
- Address: ship-to country, ship-to state, ship-to city, ship-to postcode/ZIP (range / wildcard), residential vs commercial, address verified status, PO Box flag, military APO/FPO flag
- Product: SKU (exact / contains / list), product tag, product weight, dimensions, customs HS code, vendor/brand, category, fulfilment provider
- Date/time: time of import (window), day of week
- Composition: "order contains only X SKU", "order contains any of X", "order contains all of X"

**Actions ShipStation exposes:**
- Carrier/service: set carrier, set service, set package type, set confirmation type
- Routing: set Ship From location (multi-warehouse), set Fulfilment Provider (3PL/dropship), apply Preset (bundle of carrier+service+package+weight+confirmation)
- Order state: hold until date, set ship-by date, place on hold for review, do not import order
- Tagging & assignment: add/remove tag, assign user, send notification to user
- Customer comms: send email (templated), set internal note, create alert (banner)
- Combine/split: combine shipments to same destination, automatically split orders by criteria
- Hazmat: mark as containing dry ice, set dry ice weight (extensible to other dangerous-goods flags)

**Rule infrastructure:**
- Priority ordering, drag to reorder
- Rule status: active / paused
- Activity log per order showing rule trail
- Sub-rules (one rule's actions act as a precondition for the next)
- Bulk re-apply rules to an existing order set
- Presets: reusable bundles (carrier+service+package+weight+confirmation+insurance) applied as one action

### 2.2 ShipTheory — Shipping Rules (UK-specific depth)

**Conditions:**
- Country (in / not in)
- Postcode + postcode ranges, wildcards (e.g. `BT*`, `IV1-IV63`), comma-separated lists
- Order value (=, <, >, between)
- Weight: shipment total, "all product weights" (every product must satisfy), "any product weight" (at least one must satisfy)
- Product SKU (in / not in / starts-with using `15*` style wildcards), with "all SKUs" vs "any SKU" semantics
- Product count
- Number of boxes
- Day of the week
- Time of day
- Sender's postcode (origin warehouse)
- Channel name (in / not in)
- Recipient email address
- Delivery instructions text (channel-supplied "leave with neighbour", "porch", "safe place", etc.)
- Shipping method string from the channel (this is the canonical "checkout shipping option → carrier service" mapping mechanism)

**Actions:**
- Set carrier + service
- Set package size (single or mixed pallet sizes)
- Set boxes count / dimensions
- Set custom enrichment on the shipment (e.g. format/format the recipient details)
- Trigger automatic label print to a specified printer for that rule
- Set return label generation
- Set customs document generation per rule

**International / customs:**
- Auto-generate CN22 (≤£270) or CN23 (>£270)
- Commercial invoice generation
- Tax identifiers per shipment: VAT, EORI, IOSS
- IOSS threshold rule ("if value ≤ €150 → IOSS-prepay VAT")
- HS codes per product line
- Per-carrier toggle to disable customs doc production
- DDP / DAP incoterms support

**Rate shopping & rating API:** REST endpoints for available services per courier on the account, package sizes endpoint, rate quote per shipment.

**Tracking:** branded tracking page (own logo + colours), tracking number push back to channels.

### 2.3 Veeqo, Linnworks, Mintsoft (incumbents we are attacking)

- Veeqo — automation rules to set carrier/service per channel/tag/address; apply tags; set despatch date and due date; apply branded templates; "rules engine lacks flexibility" (per multiple G2 reviews — opportunity for Synergia)
- Linnworks — two parallel mechanisms: (a) Rules Engine for automatic shipping service allocation, (b) Shipping Mapping (channel checkout option → postal service); Royal Mail OBA validation rules (size class, format, value caps); marketplace vendor-name-matching for tracking writeback
- Mintsoft — Required Despatch Date as first-class field, channel → courier mapping, courier price overrides per service

### 2.4 EasyPost, Shippo, ShipEngine, Shipium, ShipHawk (developer-/enterprise-tier reference)

- EasyPost / Shippo — multi-carrier label, rate shop, address verification, tracking, insurance; DDP / DAP / DDU incoterm flagging on customs declarations
- ShipEngine — service group rules: prioritized list of allowable services with statements that EXCLUDE a service from a shipment when conditions match (negative-rule pattern)
- Shipium — Universal Rules Engine with simulation against historical orders (replay last N orders to see what would change)
- ShipHawk — Smart Packing 3D bin-packing / cartonization (selects optimal carton or pallet from on-hand inventory; calculates packed weight and DIM weight in real time)

### 2.5 Patterns we should adopt regardless of vendor

- **Rule simulation / dry-run against a historical order window** (not just "next 100 orders")
- **Rule conflict warning** at save time, not at runtime
- **Rule-fire audit log** per order, queryable both per-order ("which rules ran?") and per-rule ("which orders did this fire on?")
- **Service group / negative rules** ("never use Royal Mail Tracked 24 if value > £750 and country = NI")
- **Tag-as-intermediary chaining** (the practical workaround for nested rules — explicitly support it in UX)
- **Presets** as first-class reusable action bundles
- **Cartonization** as a first-class action ("auto-pick best box from inventory")

---

## 3. What the current `GREENFIELD_REBUILD_PLAN.md` already covers

Mapped from the plan as it exists today:

| Capability | Plan reference | Status |
|---|---|---|
| `CarrierAdapter` ABC + registry + capability flags | Phase 5 (scaffolded), Phase 8 (live) | Planned |
| `StubCarrierAdapter` for E2E tests | Phase 5 | Planned |
| ShipStation adapter (rate, label, tracking, void) | Phase 8 | Planned |
| Royal Mail Click & Drop / OBA adapter | Phase 8 | Planned |
| Evri + DPD adapters | Phase 11 | Planned |
| Carrier rate shopping (cheapest / fastest) | Phase 8 | Planned |
| ZPL + PDF label generation, Blob storage | Phase 8 | Planned |
| Label reprint, void | Phase 8 | Planned |
| Shipment insurance line | Phase 8 (`shipment_insurance` table) | Planned |
| Tracking number writeback to marketplace | Phase 8 | Planned |
| End-of-day manifest builder | Phase 8 (`ManifestPanel`) | Planned |
| Address validation at order ingest | Phase 6 (getAddress.io / Royal Mail PAF) | Planned |
| Return labels via `CarrierAdapter` | Phase 7 stub → Phase 8 real | Planned |
| Shipping rules engine (1-line bullet) | Phase 8 | **Under-specified** |
| No-code automation rule builder | Phase 10 (`AutomationRuleBuilder`) | Planned but generic |
| Rule dry-run mode | Phase 10 | Planned |
| Rule conflict detection | Phase 10 | Planned |
| Pick wave with courier-cutoff awareness | Phase 9 | Planned |
| Despatch confirmation: weight check + label scan | Phase 9 | Planned |
| Schema research dump for Royal Mail / Evri / DPD | Phase 0 | Planned |
| `shipments`, `shipment_labels`, `carrier_rate_quotes` tables | Phase 8 | Planned |

That is a **strong base**. The plan correctly anticipates the architecture, the launch carriers, the Phase 7→8 stub-then-real progression, and the integration with the no-code automation builder. The gaps are in **breadth and depth of conditions/actions, customs/international support, packing intelligence, and rules-engine UX**.

---

## 4. Gaps — what's missing or under-specified

### 4.1 Rules engine — condition DSL gaps (vs ShipStation + ShipTheory union)

| Gap | In plan? | Notes |
|---|---|---|
| Postcode wildcard + range matching (`BT*`, `IV1-IV63`, comma lists) | No | Required for Highlands & Islands surcharge rules, NI handling |
| Sender's postcode / origin warehouse as a condition | No | Multi-warehouse routing |
| Channel name (in / not in) | Partial (rules can ref channel) | Make explicit |
| Channel-supplied shipping method string match | No | This is the primary "honour what the customer chose at checkout" mechanism — can't ship without it |
| Delivery instructions text contains | No | Drives signature / leave-safe / neighbour rules |
| Recipient email contains | No | B2B / VIP detection |
| Day of week + time of day windows | No | Peak surcharges, "ship Monday only" SKUs |
| "All products" vs "Any product" weight / SKU semantics | No | Materially different from "order weight" |
| Number of boxes condition | No | Required for pallet vs parcel routing |
| Customs HS code / product origin country | No | International routing |
| Order tag / customer tag presence (include / exclude) | No | Tag-chaining is *the* sub-rule mechanism |
| Address verified status | No | Hold-on-fail rule |
| Residential vs commercial flag | No | Rate variance |
| PO Box / APO / BFPO flag | No | Royal Mail BFPO has special rules |
| Order containing only X / any of X / all of X SKU groups | No | Bundle / kit / fragile-only routing |
| Negative / exclusion service-group rules | No | "Never use service Y if X" pattern |
| Customer LTV / repeat-buyer flag | No | VIP routing |

**Recommendation:** Define a **canonical Conditions DSL** in Phase 1 schema lock (alongside the `category_rules` DSL that's already planned). One DSL serves both shipping rules and the broader automation rule engine. Document the condition keys exhaustively in `docs/schema-design/rules-dsl.md`.

### 4.2 Rules engine — action DSL gaps

| Gap | In plan? | Notes |
|---|---|---|
| Apply Preset (bundle of carrier + service + package + weight + confirmation + insurance) | No | ShipStation's most-used action |
| Set Ship From Location | No | Multi-warehouse |
| Set Fulfilment Provider (3PL / dropship supplier) | Partial (3PL mentioned) | Dropship-supplier action not explicit |
| Set package size / select box from box library | No | Required for Royal Mail format classification |
| Auto-cartonize (pick best box from inventory) | No | Major cost-savings feature, P1 differentiator |
| Hold until date | No | Pre-order / scheduled-ship workflow |
| Set ship-by date | No | SLA tracking |
| Combine shipments to same destination | No | Cost saver |
| Auto-split orders (by SKU group / weight / fulfilment location) | No | Drop-ship core feature |
| Mark as containing dangerous goods / dry ice / lithium battery | No | Compliance — ADR/IATA |
| Set customs incoterm (DDP / DAP / DDU) | No | Cross-border |
| Set IOSS / EORI / VAT identifier on shipment | No | Required to avoid customer charges on EU orders |
| Auto-print to a specified printer/queue | No | ShipTheory's "print to printer X for this rule" |
| Send email (templated) on rule fire | No | Customer comms |
| Create alert / banner on the order in UI | No | Operator nudge |
| Assign user / team | No | Cross-warehouse work distribution |
| Generate / suppress customs documents per rule | No | Some carriers handle internally |

### 4.3 International / customs gaps

The plan mentions VAT / IOSS / multi-currency as Phase 1 schema concerns, but Phase 8 carrier deliverables do not explicitly cover:

| Gap | Action |
|---|---|
| Per-product HS code, country of origin, customs description, customs value | Add columns to `products` / `product_variants` tables in Phase 1 lock |
| CN22 (≤£270) / CN23 (>£270) auto-generation | Phase 8 deliverable |
| Commercial invoice generation (PDF) with company VAT/EORI/IOSS | Phase 8 deliverable |
| IOSS threshold rule: "if order value ≤ €150 to EU consumer → flag IOSS prepay" | Phase 8 deliverable |
| Tax-identifier set per shipment: VAT, EORI, IOSS | `shipments` table column |
| Incoterms per shipment (DDP / DAP / DDU) | `shipments` table column |
| Per-carrier toggle to suppress customs doc printing (carrier handles digitally) | `carriers` config |
| EU OSS one-stop-shop registration handling | Roadmap (Phase 12 EU expansion) |
| BFPO / Channel Islands / NI special handling | Royal Mail OBA rule set |

### 4.4 Carrier adapter capability gaps

| Gap | Where it goes |
|---|---|
| Multi-piece / multi-box shipment per consignment (parent + children) | `shipments` + `shipment_packages` tables; `CarrierAdapter` capability flag |
| Pallet shipments (LTL) — pallet sizes, freight class, lift-gate, residential delivery | Capability flag; only certain carriers |
| Saturday delivery, AM/PM service tier, time-window service tier | Capability per `carrier_service` |
| Signature required, age-verification (18/21/25) | Capability per `carrier_service` |
| Cash-on-delivery / collect-on-delivery service | Capability flag |
| Delivery date / SLA estimate returned with rate quote | `carrier_rate_quotes.estimated_delivery_at` |
| Carrier collection booking (vs end-of-day manifest) | New `carrier_collections` table; depends per carrier |
| Pickup scheduling (one-off + recurring) | Same |
| Failed-delivery retry / reschedule webhook from carrier | `tracking_events` already implied; add explicitly |
| Proof of delivery (PoD) signature image retrieval | Capability flag; for disputes/INR cases |
| Service downgrade chain (preferred → fallback if API down) | Carrier health-check + fallback rule |

### 4.5 Operational / day-2 gaps

| Gap | Notes |
|---|---|
| Carrier invoice reconciliation / shipping cost audit | Reconcile carrier-billed cost vs. expected per shipment; recover overcharges. Surfaces 2–5% recovery industry-wide. **High ROI feature.** |
| Carrier scorecard analytics | OTD %, OTIF %, damage %, claim resolution time per carrier. Drives carrier negotiations. |
| Shipping cost as a true cost line on `order_line_costs` | Plan already has `order_line_costs` — confirm shipping cost is broken out by actual carrier-billed amount, not estimated |
| Insurance claims workflow | Plan mentions "insurance & claims" but no claim ticket entity; needs `shipment_insurance_claims` table with state machine |
| Lost / damaged shipment workflow | Distinct from returns; triggered by tracking event `delivered=false` after SLA + customer report |
| Branded tracking page hosted by Synergia | Plan does NOT explicitly include this; both ShipStation and ShipTheory have it; **must-add** for parity |
| Branded customer email notifications on shipment (`shipped` / `out for delivery` / `delivered`) | Implied by Phase 5 notifications, but not explicit per-event-per-customer |
| End-customer self-serve returns portal | Distinct from operator returns workflow; `returns_portal_token` on order; **plan-gap** |
| Pickup / drop-off network for customer returns (PUDO) | Royal Mail / Evri ParcelShop / DPD Pickup support |
| Multi-piece label print (one consignment, N labels) | Often missed in v1 |
| Label format options per printer (4×6 ZPL, 6×4 ZPL, A4 PDF, A6 PDF) | UX detail, ship from day 1 |
| Manifest end-of-day with signature capture | Some carriers require it |
| Auto-batch by despatch wave with print-all-labels button | High operator value |

### 4.6 Rules engine — UX & lifecycle gaps

| Gap | Notes |
|---|---|
| Rule simulation against last 30 / 90 / 365 days of historical orders | Plan says "last 100 orders"; expand to a rolling window |
| Rule activity log surfaced *on the order detail page* (which rules fired, in order, with before/after diff) | Plan mentions audit log but not order-detail surfacing |
| Rule conflict warnings at *save time* (static analysis), not just at runtime | Plan mentions conflict detection — confirm it's at save time |
| Rule version history (diff between versions; revert) | Standard for compliance |
| Rule import / export (JSON) for backup, share between tenants, ship as templates | Easy win |
| Rule templates / starter pack ("Royal Mail OBA size class router", "EU IOSS auto-flag", "DPD heavy-parcel router", "Highlands & Islands surcharge dodger", "Pre-order hold-until rule") | Strong onboarding accelerant |
| Bulk re-apply rules to selected historic orders | Operator escape hatch |
| Rule pause / disable (vs delete) | Standard |
| Rule scoping: company-wide vs warehouse-specific vs channel-specific | Multi-warehouse / 3PL need |
| Rule ownership and approval (who can create/edit) | RBAC integration |
| Rule SLA: 95% of orders auto-routed without operator intervention | Plan already has this metric — keep it |

### 4.7 Packing intelligence gap (highest cost-savings opportunity)

The plan does not include **cartonization / 3D bin packing**. ShipHawk and Paccurate report 15–25% reduction in dimensional-weight charges. For a UK SME shipping 5K+ orders/month this is £20K–£60K/year saved. Synergia could be the **first UK-focused multichannel platform with built-in cartonization**.

| Item | Notes |
|---|---|
| `packaging_boxes` table — operator's box library (id, name, internal LWH, external LWH, weight, max payload, cost, SKU) | Phase 1 lock candidate |
| 3D bin-pack algorithm — heuristic-first (3D-FFD), upgradeable to MILP later | Phase 8 or Phase 9 |
| Cartonization as a Rule Action ("auto-select best box from `packaging_boxes`") | Phase 10 |
| DIM weight calculator per carrier (each carrier has its own divisor — Royal Mail 5000, DPD 5000, Evri 5000, FedEx 5000) | Built-in to rate quote logic |
| Multi-package recommendation when items don't fit one box | Triggers split-shipment |
| Pack-bench scan workflow honouring cartonization recommendation | Phase 9 (mobile app) |

### 4.8 Compliance / safety gaps

| Item | Notes |
|---|---|
| Dangerous goods / hazmat flag per product (ADR / IATA / IMDG class) | Some carriers/services refuse these — must be a routing constraint |
| Lithium battery (UN3480 / UN3481) flagging | Royal Mail / Air carriers refuse |
| Aerosols, perfumes (UN1950 / UN1266) | Surface-only services |
| Age-verification required (alcohol, knives, vape) | Service constraint |
| Restricted-destination rules (e.g. embargoed countries) | Compliance |
| GDPR — branded tracking pages & customer comms must be on operator's data-processor agreement | Legal review |

---

## 5. Prioritised recommendations to add to the plan

### 5.1 P0 — Must add before launch (blockers for parity demos)

These should land in the Phase 1 schema lock + Phase 8 scope. Without them Synergia loses every head-to-head against ShipTheory or Linnworks.

1. **Unified Rules Engine subsystem.** Promote the "shipping rules" bullet (Phase 8) and "no-code automation rules" (Phase 10) to a **first-class subsystem** with one shared Conditions DSL, one Actions DSL, one runtime, one audit log, one simulator. Document in `docs/schema-design/rules-dsl.md` at Phase 1 lock.
2. **Conditions DSL — full ShipTheory + ShipStation union** of: postcode (wildcard + range + list), sender postcode, channel name (in/not in), channel shipping method string, delivery instructions contains, recipient email contains, day of week, time of day, all-products vs any-product weight, all-SKUs vs any-SKU SKU set, number of boxes, order tag include/exclude, residential/commercial, address verified status, customer tag, customs HS code, country, postcode-as-PO-Box flag, BFPO flag.
3. **Actions DSL — full ShipStation union** of: set carrier, set service, set package, set Ship From, set Fulfilment Provider (incl. dropship supplier), Apply Preset, set ship-by date, hold until date, hold for review, do not import, add tag, remove tag, assign user, send email, internal note, create alert, combine shipments, split shipment, auto-cartonize, set customs incoterm, set tax IDs, suppress customs docs, mark hazmat / dry ice / lithium, auto-print to printer.
4. **Presets entity.** `shipping_presets` table — reusable bundles applied as a single Action. Avoids 50-rule sprawl.
5. **Channel shipping method mapping table.** `channel_shipping_method_mappings` — channel string → carrier+service. This is the single most-used Shiptheory feature; without it, "honour customer's chosen service at checkout" is impossible.
6. **Customs subsystem.** Per-product HS code, country of origin, customs description, customs value; auto-CN22/CN23 generation; commercial invoice PDF; per-shipment incoterm + tax-IDs (VAT/EORI/IOSS); IOSS threshold rule; per-carrier customs-doc suppression toggle.
7. **Branded tracking page.** Hosted by Synergia at `track.synergia360.app/<token>` (or per-tenant subdomain); operator can set logo + colours + email-domain + custom message; injects tracking events from `tracking_events`. Both ShipStation and ShipTheory have this — non-negotiable for parity.
8. **Branded customer email notifications.** "Shipped", "Out for delivery", "Delivered", "Delivery exception" — per-tenant template, operator-brandable.
9. **Customer self-serve returns portal.** Token-based public page where customer requests RMA, prints label, books PUDO. Distinct from operator-side returns workflow already in Phase 7.
10. **Multi-piece / multi-box shipment model.** `shipments` (parent) → `shipment_packages` (children, each with own label). Phase 1 lock.
11. **Rule simulation harness.** Run a saved rule (or a draft) against a window of historical orders (last 30/90 days), report counts and diffs. Phase 10.
12. **Rule activity log on the order detail page.** Operator can see "Rule X fired → set service to Y" inline on every order. Phase 10.
13. **Rule conflict detection at save time.** Static analysis flagging overlap between rules. Phase 10.
14. **Carrier rate-quote cache + DIM-weight calculator.** Per-carrier DIM divisor; cache rate quotes per (origin-postcode, dest-postcode, weight, dims, service) for N minutes to avoid carrier rate-limit pain. Phase 8.

### 5.2 P1 — Should add for category leadership (Phase 8–11)

15. **Cartonization / 3D bin-pack.** `packaging_boxes` table + heuristic 3D-FFD packer; available as a Rule Action ("auto-select box"). Phase 8 schema, Phase 9 algorithm.
16. **Service group / negative rules.** "Never use Royal Mail Tracked 24 if value > £750 and country = NI." Phase 8/10.
17. **Tag-as-intermediary chaining (explicit UX).** Document and surface this pattern in the rule builder so operators can build sub-rules without nested conditionals. Phase 10.
18. **Carrier invoice reconciliation.** Import weekly carrier invoices (CSV / PDF parse); diff against `shipments.expected_cost`; flag discrepancies; recover refunds. Industry recovery rate 2–5% of freight spend. Phase 11.
19. **Carrier scorecard analytics.** OTD %, OTIF %, damage rate, claim resolution time per carrier per service. Feeds carrier negotiations. Phase 10/11.
20. **Insurance claims workflow.** `shipment_insurance_claims` table with state machine (draft → submitted → approved → paid → denied). Phase 11.
21. **Lost / damaged shipment workflow.** Triggered by tracking SLA breach + customer report; opens claim ticket + replacement order. Phase 11.
22. **Pickup / collection booking (one-off + recurring).** `carrier_collections` table; per-carrier capability. Phase 11.
23. **Service capability flags.** Saturday delivery, AM/PM, signature required, age 18/21, COD, dangerous goods supported, lithium-battery supported. Phase 8.
24. **Hazmat / restricted-goods flag per product.** ADR class, lithium-battery flag, age-verification flag; enforced as a routing constraint by the rules engine. Phase 1 lock + Phase 8.
25. **Rule templates starter pack.** Ship 12–15 pre-built rules as one-click installs: "Royal Mail OBA format classifier", "EU IOSS auto-flag", "Highlands & Islands surcharge avoider", "Pre-order hold-until", "Heavy parcel → DPD", "Lightweight letter → Royal Mail Letter", etc. Phase 10.
26. **Rule version history.** Diff + revert. Phase 10.
27. **Rule import/export (JSON).** Phase 10.
28. **Multi-warehouse routing.** `Set Ship From Location` action + warehouse-cutoff awareness in rate shop. Phase 9.

### 5.3 P2 — Could add (post-launch growth, Phase 12+)

29. **Carrier collection-route optimisation** (multi-warehouse pickup routing).
30. **Predictive ETA refinement** using historical tracking data per carrier per lane (ML, Tier-A insights).
31. **Fraud / address-suspicion flags** as condition (e.g. "BIN flagged + high-value → hold").
32. **Repeat-buyer / VIP customer routing.**
33. **Carrier API mock harness** for offline dev.
34. **A/B test rules** — two parallel rule sets, split traffic, compare cost & SLA outcome.
35. **Rule ownership / approval workflow** — propose / review / approve cycle for finance-impacting rules (carrier change > £X).

### 5.4 P3 — Defer to post-launch / 2027 plan

36. PUDO network selector inside checkout (this is a checkout-side feature; lives in Shopify/WooCommerce app side once those land).
37. Final-mile crowdsourced delivery (Stuart, Gophr) — niche.
38. Predictive cartonization that learns from pack-bench overrides.
39. Carrier API failover / circuit breaker per carrier (could be P1 if carrier outages bite — flag for re-prioritisation if observed).

---

## 6. Concrete edits to `GREENFIELD_REBUILD_PLAN.md`

### 6.1 Phase 0 (Schema research)

Add to the carrier schema-research checklist:
- ☐ Customs/international payload model per carrier (CN22/CN23/Commercial Invoice fields)
- ☐ DIM-weight divisor per carrier
- ☐ Pickup/collection booking model per carrier
- ☐ Multi-piece / multi-package consignment model per carrier
- ☐ Service capability matrix per carrier (Saturday, AM, signature, COD, hazmat, lithium)
- ☐ Per-carrier rate-quote response includes estimated delivery date

### 6.2 Phase 1 (Schema lock)

Add to deliverables:
- `rules` (id, company_id, name, scope [company/warehouse/channel], priority, active, version, created_by, audit fields)
- `rule_versions` (id, rule_id, conditions JSON, actions JSON, created_at, created_by)
- `rule_runs` (id, rule_id, order_id, fired_at, before_state JSON, after_state JSON)
- `shipping_presets` (id, company_id, name, carrier_id, service_id, package_size_id, weight, dimensions, confirmation, insurance_amount)
- `channel_shipping_method_mappings` (channel_id, channel_method_string, carrier_id, service_id, package_size_id, priority)
- `packaging_boxes` (id, company_id, name, internal_l/w/h, external_l/w/h, weight, max_payload, cost, sku, active)
- `shipment_packages` (shipment_id, package_index, box_id, weight, dims, label_blob_key, tracking_number)
- `shipment_customs` (shipment_id, incoterm, vat_id, eori_id, ioss_id, declared_value_currency, declared_value_amount, signed_by, ucr)
- `shipment_customs_lines` (shipment_id, line_index, hs_code, description, country_of_origin, qty, unit_value)
- `shipment_insurance_claims` (id, shipment_id, claim_type, status, amount_claimed, amount_paid, opened_at, closed_at)
- `tracking_events` (shipment_id, carrier_event_code, status, location, occurred_at, raw_payload)
- `carrier_collections` (id, carrier_id, warehouse_id, scheduled_at, recurrence_rule, manifest_id)
- `branded_tracking_settings` (company_id, logo_blob_key, primary_colour, sender_email_address, footer_html, custom_domain)
- Add to `products` / `product_variants`: `hs_code`, `country_of_origin`, `customs_description`, `customs_value`, `hazmat_class`, `lithium_battery_flag`, `age_verification`, `dim_l`, `dim_w`, `dim_h`

### 6.3 Phase 8 (Fulfilment + Carrier Rate Shopping)

Expand deliverables to include:
- Conditions DSL + Actions DSL (versioned; documented; backward-compat plan)
- Channel shipping method mapping engine
- Customs documents (CN22/CN23 + commercial invoice PDF) — per shipment, per-rule generation toggle
- DIM-weight calculator per carrier
- Multi-piece consignment support
- Rate-quote cache with token-bucket per carrier
- Branded tracking page + branded shipment emails
- Customer self-serve returns portal (token URL)
- Hazmat / lithium routing constraint

Update acceptance criteria:
- 95% of orders auto-routed without operator intervention (already in plan)
- Rule simulation runs against ≥90 days of historical orders and returns within 5s for a tenant with 100K orders
- Customs documents generate within 3s of label generation; commercial invoice PDF includes VAT + EORI + IOSS
- Branded tracking page returns within 1s for an order in any state
- Multi-piece consignment: one rate quote, N labels, single tracking parent + N children

### 6.4 Phase 10 (No-code automation)

Replace the generic AutomationRuleBuilder spec with the **unified Rules Engine UX**:
- Single rule builder serves shipping rules, order routing rules, returns rules, repricing rules, automation rules
- Templates library (12+ starter packs)
- Simulation against historical orders (30/90/365-day windows)
- Conflict detection at save time
- Activity log on order detail page
- Version history + revert
- JSON import/export
- Per-rule scope (company / warehouse / channel)

### 6.5 Phase 11 (Post-launch growth)

Add:
- Carrier invoice reconciliation
- Carrier scorecard analytics
- Insurance claims workflow + lost/damaged workflow
- Carrier collection booking (one-off + recurring)
- Cartonization production rollout (algorithm shipped Phase 9, defaulting to ON in Phase 11 once tuned)

---

## 7. Estimated incremental scope

Compared to the existing Phase 8 + Phase 10 scope, these additions roughly translate to:

| Bucket | Engineer-weeks (rough) | Where it lands |
|---|---|---|
| Unified Rules Engine subsystem (DSL + runtime + audit + simulator + UX) | 8–10 | Phase 1 schema, Phase 10 build |
| Customs subsystem (HS codes, CN22/23, commercial invoice, IOSS rules) | 4–6 | Phase 8 |
| Multi-piece consignment + DIM weight | 3 | Phase 8 |
| Branded tracking page + branded emails | 3 | Phase 8 |
| Customer self-serve returns portal | 3 | Phase 7 / Phase 8 |
| Cartonization algorithm + box library | 4–6 | Phase 9 |
| Carrier invoice reconciliation | 4 | Phase 11 |
| Carrier scorecard + insurance claims | 3 | Phase 11 |
| Hazmat / restricted-goods compliance layer | 2 | Phase 8 |
| Channel shipping-method mapping | 1 | Phase 8 |
| Presets entity + UI | 1 | Phase 8 |
| Rule templates starter pack | 1 | Phase 10 |
| **Total** | **37–47 EW** | Spread across Phases 1, 8, 9, 10, 11 |

Most P0 items are **already implied** by the architectural commitments in the plan (CarrierAdapter framework, no-code rule builder, schema-first lock). Making them explicit is the work; the foundations are already there.

---

## 8. What to do next

1. **Review & approve** the P0 list above.
2. **Edit `GREENFIELD_REBUILD_PLAN.md`** to incorporate the schema additions in Phase 1 lock (Section 6.2 above) — this is the most time-critical change because Phase 1 sets the schema floor for everything else.
3. **Write `docs/schema-design/rules-dsl.md`** before starting Phase 8 build — define the conditions and actions vocabulary as a versioned spec.
4. **Open API research stubs** (per Phase 0 checklist) for ShipStation customs, Royal Mail OBA size classes, Evri/DPD customs, before writing adapter code.
5. **Source a 3D-FFD bin-pack reference implementation** (open-source `py3dbp` or `binpacking` in TypeScript) — pick early, as the box-library data model needs to fit it.
6. **Decide branded-tracking domain strategy** — `track.synergia360.app/<token>` vs per-tenant subdomain — feeds into Phase 1 Front Door / DNS planning.

---

## Sources

- [ShipStation — Automation Rules Criteria and Actions](https://help.shipstation.com/hc/en-us/articles/1260807687290-Automation-Rules-Criteria-and-Actions)
- [ShipStation — Advanced Automation Rules](https://help.shipstation.com/hc/en-us/articles/360047475631-Advanced-Automation-Rules)
- [ShipStation — Create More Complex Automation Rules](https://help.shipstation.com/hc/en-us/articles/360047475611-Create-More-Complex-Automation-Rules)
- [ShipStation — Automation Rule Examples](https://help.shipstation.com/hc/en-us/articles/360029962911-Automation-Rule-Examples)
- [ShipStation — Use Shipping Presets](https://help.shipstation.com/hc/en-us/articles/360036323651-Use-Shipping-Presets)
- [ShipStation — Automatically Split Orders](https://help.shipstation.com/hc/en-us/articles/17465241673627-Automatically-Split-Orders)
- [ShipStation — Combine Shipments](https://help.shipstation.com/hc/en-us/articles/360033432631-Combine-Shipments)
- [ShipStation — Customs Declarations](https://help.shipstation.com/hc/en-us/articles/360025869952-Customs-Declarations)
- [ShipStation — International Shipping](https://help.shipstation.com/hc/en-us/articles/360026157991-International-Shipping-with-ShipStation)
- [ShipStation — Verify & Print Shipments with Barcode Scan](https://help.shipstation.com/hc/en-us/articles/360031021831-Verify-Print-Shipments-with-Barcode-Scan)
- [ShipStation — Now Supports Dimensioners](https://www.shipstation.com/blog/how-to-use-dimensioner-with-shipstation/)
- [ShipStation — Branded Shipping Experience](https://www.shipstation.com/features/branding-shipping/)
- [ShipStation Automation Rules Explained — Cahoot](https://www.cahoot.ai/shipstation-automation-rules-explained-where-shipping-automation-breaks-down/)
- [ShipTheory — Shipping Rules Explained](https://support.shiptheory.com/support/solutions/articles/10125-shipping-rules-explained)
- [ShipTheory — Setting up your Shipping Rules](https://support.shiptheory.com/support/solutions/articles/24000038386-setting-up-your-shipping-rules)
- [ShipTheory — New Shipping Rule Options](https://shiptheory.com/blog/new-shipping-rule-options/)
- [ShipTheory — Updating Shipment Details with Rules](https://support.shiptheory.com/support/solutions/articles/24000052242-updating-shipment-details-with-rules)
- [ShipTheory — Guide to International Shipping](https://support.shiptheory.com/support/solutions/articles/24000081386-guide-to-international-shipping)
- [ShipTheory — Using Package Sizes](https://support.shiptheory.com/support/solutions/articles/24000026829-using-package-sizes)
- [ShipTheory — Mapping Shipping Methods from Shopify](http://support.shiptheory.com/support/solutions/articles/6000148679-mapping-shipping-methods-from-shopify)
- [ShipTheory — How to use customer's shipping Instructions](https://support.shiptheory.com/support/solutions/articles/6000093242-how-to-use-customer-s-shipping-structions)
- [ShipTheory — Pro Carrier Integration](https://shiptheory.com/procarrier/)
- [ShipTheory — Branded Tracking Page](https://tracking.shiptheory.com/)
- [ShipTheory — API Documentation](https://shiptheory.com/developer/)
- [Veeqo — Shipping Features](https://www.veeqo.com/shipping-software/shipping-features)
- [Veeqo — Automation Rules](https://help.veeqo.com/en/articles/6349113-automation-rules)
- [Linnworks — Assigning shipping based on channel services](https://help.linnworks.com/support/solutions/articles/7000058561-assigning-shipping-based-on-channel-services)
- [Linnworks — Shipping Service Allocation](https://www.linnworks.com/tutorial/shipping-service-allocation/)
- [Linnworks — Royal Mail OBA Rules & Guidelines](https://assets.linnworks.com/support/shipping-management/courier-integrations/royal-mail/rules-and-guidelines)
- [Mintsoft — Release Notes April 2025](https://www.mintsoft.com/resources/release-notes/april-2025/)
- [ShipEngine — Shipping Rules Guide](https://www.shipengine.com/docs/shipping/shipping-rules-guide/)
- [Shipium — Universal Rules Engine](https://www.shipium.com/platform/rules-engine)
- [ShipHawk — Packing & Carton Optimization](https://shiphawk.com/solutions/packing-optimization/)
- [Paccurate — Cartonization Software](https://paccurate.io/)
- [EasyPost — Customs & International Shipping](https://support.easypost.com/hc/en-us/articles/360042847751-Customs-Shipping-Internationally)
- [Shippo — Webhooks](https://docs.goshippo.com/docs/tracking/webhooks)
