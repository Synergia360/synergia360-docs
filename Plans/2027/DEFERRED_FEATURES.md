# Synergia 2027 — Deferred Features

Features confirmed out of scope for the current greenfield build. Revisit during 2027 planning.

---

## Self-Serve Customer Returns Portal

**Deferred from:** Phase 6 (Order Management)  
**Target:** 2027

### Why deferred
Synergia is a B2B platform — consumers never access it directly. In the current model, buyers initiate returns on the marketplace (eBay, Amazon, TikTok Shop, etc.) and Synergia receives those requests via API. A Synergia-hosted returns portal would only make sense for orders placed through a merchant's own storefront (Shopify, WooCommerce) where no marketplace return flow exists. This is a meaningful product extension but not required for the core marketplace management use case.

### What it would add (when built)
- Branded URL per company (e.g. `returns.yourbrand.com` or `/returns`) — for direct/storefront orders only
- Buyer-initiated RMA form: return reason, quantity, optional photo upload
- Auto-approve rules: configurable per channel/product/value threshold — system approves, generates return label, notifies customer without operator touch
- Return shipping label delivered to customer automatically on approval
- Operator override: manual review queue for returns outside auto-approve rules
- Integration with operator-side returns management already built in Phase 6

### What is already in the current plan (Phase 6)
- Marketplace return requests synced automatically via marketplace APIs
- Operator can manually initiate a return inside Synergia
- Operator RMA queue (approve, reject, partial)
- Return label generation
- Warehouse receipt confirmation
- Stock fate decisions (restock / quarantine / write-off)
- Refund trigger via marketplace API
- Return reason reporting
