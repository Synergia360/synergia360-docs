# B2B Wholesale Portal

> Status: FUTURE PRODUCT — not in current roadmap  
> Moved from main plan: 2026-05-07  
> Target: 2027 (phase TBD once core platform is stable)

---

## Overview

A self-serve ordering surface for operators' wholesale buyers — brands and retailers who purchase in bulk directly from the Synergia operator. Operators set up buyer accounts, price lists, and approval rules. Buyers log in, browse the catalogue at their assigned price, and place orders without contacting the operator.

Wholesale orders flow through the standard `orders` table and fulfilment pipeline — no separate system.

## Why This Is Deferred

The core platform (channels, WMS, orders, inventory, analytics) must be stable and generating revenue before adding a new buyer-facing persona. Building this before the operator-facing product is mature increases complexity without near-term commercial return. Revisit once Phase 9 (Marketplace Depth + 3PL Portal) is live and operators are asking for it.

## Competitive Context

Brightpearl and Cin7 have wholesale portal capability. Linnworks and StoreFEEDER do not. Operators currently using Orderspace, Faire, or manual spreadsheets for wholesale would benefit from consolidation into Synergia.

---

## Operator Setup

- Wholesale customer account management: invite buyers by email, assign price list, set credit terms
- Price lists: named lists with per-SKU override prices (never RRP visible to buyer) and start/end dates
- Order approval rules: auto-approve orders under £X, require manual review above threshold
- Branded portal URL per company (subdomain or path — decision deferred: `wholesale.company.com` vs `/wholesale`)

## Buyer Experience

- Buyer logs in → sees their assigned price list only
- Browses the operator's product catalogue
- Places a wholesale order (e.g. 500 units across 10 SKUs)
- Receives order confirmation email automatically
- Views account statement and order history

## Order Fulfilment

- Wholesale order maps directly to the standard `orders` table — same pick/pack/ship pipeline, same WMS flow
- Invoice generated automatically at order placement
- Stock allocated the same way as any marketplace order

## Schema Requirements (additions to core schema)

These tables are NOT in the Phase 1 locked schema — add via migration when this product is built:

```
wholesale_customers         — buyer accounts per company
wholesale_price_lists       — named price lists
wholesale_price_list_items  — per-SKU price overrides per list
wholesale_customer_lists    — buyer ↔ price list assignment
wholesale_payment_terms     — credit terms per buyer (net-30 etc.)
```

## Key Decisions Deferred

1. Subdomain (`wholesale.company.com`) vs embedded path (`/wholesale`) — decide at build time
2. Credit terms v1 scope: cash/proforma only for v1; net-30/60 in v2
3. Whether wholesale buyers get mobile app access (likely read-only via 3PL Client mode)
4. Multi-currency pricing for EU expansion

## Acceptance Criteria (when built)

- Wholesale buyer logs in, places order for 50 units of 3 SKUs, receives confirmation email — no operator intervention
- Price list enforced: buyer cannot see or order at RRP
- Wholesale order appears in operator's standard order queue; picked and shipped via normal WMS flow
- Invoice generated and attached to confirmation email

## Risks

- B2B credit terms (net-30 etc.) require payment terms tracking and potential credit risk management — scope to cash/proforma only for v1
- Branded subdomain requires DNS delegation from the operator — needs onboarding documentation
- Wholesale buyer persona is a new auth context distinct from operator users — needs careful token scoping
