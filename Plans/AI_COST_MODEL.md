# Synergia AI Cost Model

> **Status:** DRAFT — initial estimates pending validation against real Anthropic pricing + usage telemetry
> **Last updated:** 2026-05-07
> **Owner:** Founder / Product
> **Review cadence:** Phase 0 (initial), Phase 5 (post-launch trio live), Phase 10 (post-reports), Phase 13 (post-MCP), monthly thereafter

This document estimates per-tenant AI consumption costs across every AI feature, validates margin per plan tier, and informs the per-feature daily token caps documented in D2.

---

## Pricing assumptions (2026)

> **NOTE:** Replace these with current Anthropic pricing at time of contract. Pricing as of plan-writing date 2026-05-07.

| Model | Input ($/MTok) | Output ($/MTok) | Use for |
|---|---|---|---|
| Claude Sonnet 4.6 | $3.00 | $15.00 | Default — listing optimisation, repricing suggestions, return triage, report authoring, chat, research |
| Claude Haiku 4.5 | $0.80 | $4.00 | High-volume / low-complexity — batch translation, summarisation, AI digest emails |
| Claude Opus 4.7 | $15.00 | $75.00 | Reserved for: AI agents (multi-step reasoning), Tier-C arbitrage analysis (when added) |

Conversion rate assumed: **$1.00 = £0.79** (refresh quarterly).

---

## Per-feature cost estimates

### Listing optimisation (Phase 5)

**When:** operator clicks "Suggest improvements" on a listing, OR runs bulk suggestion job on N listings.

| Element | Estimate |
|---|---|
| Avg input tokens per listing | 800 (product fields + 5 example top-listed competitors + system prompt) |
| Avg output tokens per listing | 400 (3 title alternatives + keyword list + image scoring) |
| Model | Sonnet 4.6 |
| Cost per call | (0.0008 × $3) + (0.0004 × $15) = **$0.0084 ≈ £0.0066** |
| Avg calls per active tenant per month | 60 (Starter), 200 (Growth), 800 (Scale) |
| **Cost / tenant / month** | **£0.40** (Starter) · **£1.32** (Growth) · **£5.30** (Scale) |

### Return triage (Phase 7)

**When:** every return request received → AI suggests decision + fraud risk score.

| Element | Estimate |
|---|---|
| Avg input tokens | 1,200 (return reason + buyer history + product return history + system prompt) |
| Avg output tokens | 250 (decision + reasoning + risk score) |
| Model | Sonnet 4.6 |
| Cost per return | (0.0012 × $3) + (0.00025 × $15) = **$0.0074 ≈ £0.0058** |
| Avg returns / tenant / month | 30 (Starter), 200 (Growth), 1,500 (Scale) |
| **Cost / tenant / month** | **£0.17** · **£1.16** · **£8.71** |

### Repricing suggestions (Phase 10)

**When:** AI repricing rule triggers OR operator asks for advice on a SKU.

| Element | Estimate |
|---|---|
| Avg input tokens | 1,500 (current price + competitor prices + margin floor + sales velocity + 30-day history) |
| Avg output tokens | 300 (suggested price + rationale) |
| Model | Sonnet 4.6 |
| Cost per call | (0.0015 × $3) + (0.0003 × $15) = **$0.009 ≈ £0.0071** |
| Avg calls / tenant / month | 50 (Starter), 300 (Growth), 1,500 (Scale) |
| **Cost / tenant / month** | **£0.36** · **£2.13** · **£10.65** |

### Marketplace messaging AI assist (Phase 11/13)

**When:** operator clicks "AI draft reply" on an inbound marketplace message.

| Element | Estimate |
|---|---|
| Avg input tokens | 2,000 (full conversation thread + order context + brand voice memory) |
| Avg output tokens | 350 (draft reply) |
| Model | Sonnet 4.6 |
| Cost per draft | (0.002 × $3) + (0.00035 × $15) = **$0.0113 ≈ £0.0089** |
| Avg drafts / tenant / month | 20 (Starter), 100 (Growth), 500 (Scale) |
| **Cost / tenant / month** | **£0.18** · **£0.89** · **£4.45** |

### AI report authoring (Phase 13)

**When:** operator types natural-language request in chat → AI generates `ReportSpec`. **Saved reports run free forever after.**

| Element | Estimate |
|---|---|
| Avg input tokens | 3,000 (system prompt with full ReportSpec contract + schema + examples) |
| Avg output tokens | 500 (structured spec JSON) |
| Model | Sonnet 4.6 |
| Cost per report-author session | (0.003 × $3) + (0.0005 × $15) = **$0.0165 ≈ £0.0130** |
| Avg new reports authored / tenant / month | 5 (Starter), 15 (Growth), 40 (Scale) |
| **Cost / tenant / month** | **£0.07** · **£0.20** · **£0.52** |

### In-app chat assistant (Phase 13)

**When:** operator chats in the slide-out panel.

| Element | Estimate |
|---|---|
| Avg input tokens per turn | 4,000 (system + tenant memory + conversation history + tool results) |
| Avg output tokens per turn | 600 (reply + structured cards) |
| Avg turns per session | 5 |
| Model | Sonnet 4.6 |
| Cost per session | 5 × ((0.004 × $3) + (0.0006 × $15)) = **$0.105 ≈ £0.083** |
| Avg sessions / tenant / month | 30 (Starter), 100 (Growth), 300 (Scale) |
| **Cost / tenant / month** | **£2.49** · **£8.30** · **£24.90** |

### AI digest email (Phase 11)

**When:** daily/weekly per opted-in operator.

| Element | Estimate |
|---|---|
| Avg input tokens | 5,000 (yesterday's metrics + anomaly checks + previous digest) |
| Avg output tokens | 800 (formatted email body) |
| Model | Haiku 4.5 (cheap; structured output) |
| Cost per digest | (0.005 × $0.80) + (0.0008 × $4) = **$0.0072 ≈ £0.0057** |
| Digests / tenant / month | 22 (daily) or 4 (weekly); assume 15 average |
| **Cost / tenant / month** | **£0.09** (all tiers) |

### AI demand forecasting upgrade (Phase 13)

**When:** nightly recurring job per tenant; seasonal decomposition + external signals.

| Element | Estimate |
|---|---|
| Avg input tokens | 8,000 (12-month sales history + external signals) |
| Avg output tokens | 600 (forecast adjustments + reasoning) |
| Model | Sonnet 4.6 |
| Cost per nightly run | (0.008 × $3) + (0.0006 × $15) = **$0.033 ≈ £0.026** |
| Runs / tenant / month | 30 |
| **Cost / tenant / month** | **£0.78** (all tiers with feature) |

### Tier-A research recommendations (Phase 13)

**When:** operator opens research workspace OR weekly digest.

| Element | Estimate |
|---|---|
| Avg input tokens | 6,000 (catalogue summary + sales history + workspace items) |
| Avg output tokens | 1,000 (recommendations with rationale) |
| Model | Sonnet 4.6 |
| Cost per analysis | (0.006 × $3) + (0.001 × $15) = **$0.033 ≈ £0.026** |
| Avg analyses / tenant / month | 4 (Starter), 12 (Growth), 30 (Scale) |
| **Cost / tenant / month** | **£0.10** · **£0.31** · **£0.78** |

### Tier-B research opportunity feed (Phase 14)

**When:** weekly AI scan of marketplace data → generated opportunities.

| Element | Estimate |
|---|---|
| Avg input tokens | 12,000 (marketplace data + tenant context + niche stats) |
| Avg output tokens | 1,500 (5–10 opportunities with full analysis) |
| Model | Sonnet 4.6 |
| Cost per scan | (0.012 × $3) + (0.0015 × $15) = **$0.0585 ≈ £0.046** |
| Scans / tenant / month | 4 (weekly) |
| **Cost / tenant / month** | **£0.18** (Growth+ tiers only) |

### Tier-C image-match supplier finding (Phase 15)

**When:** operator clicks "find supplier" on a research item.

| Element | Estimate |
|---|---|
| Avg input | 1 image + 100 candidate images |
| Vision model cost | ~$0.02 per image-match job (estimate; refresh with actual provider pricing) |
| Avg jobs / tenant / month | 5 (Growth), 30 (Scale) |
| **Cost / tenant / month** | **£0.08** · **£0.47** (Tier-C tiers only) |

PLUS Keepa / DataForSEO / AliExpress feed costs (passthrough or quota — separate from AI).

### Urdu translation (one-off, amortised)

**When:** Phase 5 launch, full key set translated; new keys translated as they're added.

| Element | Estimate |
|---|---|
| Avg input tokens | 30,000 (full en-GB.json: ~3,000 keys × 10 tokens avg) |
| Avg output tokens | 30,000 (Urdu equivalent) |
| Model | Haiku 4.5 |
| Cost (one-off) | (0.030 × $0.80) + (0.030 × $4) = **$0.144 ≈ £0.11** |
| Plus ongoing per-PR translation | ~10 keys per PR × 12 PRs/month = 120 keys × £0.0001 = negligible |
| **Cost (platform-level, not per-tenant)** | **~£15 / month for the platform** |

---

## Cost roll-up per tenant tier

> Adds up the per-feature costs above, by which features each tier has access to.

### Free tier (no AI)

**Cost / tenant / month: £0.00**

(Free tier excludes AI features per D2 / D13. Free tier exists to convert to Starter.)

### Starter tier

| Feature | Monthly cost |
|---|---|
| Listing optimisation (Phase 5) | £0.40 |
| Return triage (Phase 7) | £0.17 |
| Repricing suggestions (Phase 10) | £0.36 |
| Messaging AI assist (Phase 11+) | £0.18 |
| Report authoring (Phase 13+) | £0.07 |
| In-app chat (Phase 13+) | £2.49 |
| AI digest email | £0.09 |
| AI forecasting | £0.78 |
| Tier-A research recommendations | £0.10 |
| **Total** | **£4.64 / tenant / month** |

### Growth tier

| Feature | Monthly cost |
|---|---|
| Listing optimisation | £1.32 |
| Return triage | £1.16 |
| Repricing suggestions | £2.13 |
| Messaging AI assist | £0.89 |
| Report authoring | £0.20 |
| In-app chat | £8.30 |
| AI digest email | £0.09 |
| AI forecasting | £0.78 |
| Tier-A research recommendations | £0.31 |
| Tier-B opportunity feed | £0.18 |
| **Total** | **£15.36 / tenant / month** |

### Scale tier

| Feature | Monthly cost |
|---|---|
| Listing optimisation | £5.30 |
| Return triage | £8.71 |
| Repricing suggestions | £10.65 |
| Messaging AI assist | £4.45 |
| Report authoring | £0.52 |
| In-app chat | £24.90 |
| AI digest email | £0.09 |
| AI forecasting | £0.78 |
| Tier-A research recommendations | £0.78 |
| Tier-B opportunity feed | £0.18 |
| Tier-C image-match (own usage) | £0.47 |
| **Total** | **£56.83 / tenant / month** |

### Enterprise tier

Higher caps; cost ranges **£100–250 / tenant / month** depending on volume and AI agent runtime.

---

## Margin validation per plan tier

> Plan tier prices are placeholder until Phase 3 pricing decision is finalised.

| Tier | Plan price (placeholder) | AI cost | Other infra cost / tenant | Gross margin per tenant |
|---|---|---|---|---|
| Free | £0 | £0 | £2 (shared infra amortised) | **−£2** (acceptable acquisition cost) |
| Starter | £49 / month | £4.64 | £4 | **£40 (82%)** |
| Growth | £149 / month | £15.36 | £8 | **£126 (84%)** |
| Scale | £349 / month | £56.83 | £20 | **£272 (78%)** |
| Enterprise | £999+ / month | £100–250 | £40 | **£700+ (70%+)** |

**All paid tiers maintain ≥ 70% gross margin even at upper-bound AI usage.** Free tier is the only loss-leader (deliberate, capped at low usage limits).

---

## Daily caps (enforced via `IAiCostService`)

| Feature | Free | Starter | Growth | Scale | Enterprise |
|---|---|---|---|---|---|
| Listing suggestions | 0 | 5/day | 20/day | 100/day | unlimited |
| Return triage | 0 | unlimited (driven by return volume) | unlimited | unlimited | unlimited |
| Repricing suggestions | 0 | 10/day | 50/day | 250/day | unlimited |
| Messaging drafts | 0 | 5/day | 25/day | 100/day | unlimited |
| Report authoring | 0 | 1/day | 5/day | 20/day | unlimited |
| In-app chat sessions | 0 | 3/day | 10/day | 50/day | unlimited |
| AI digest | – | weekly | daily | daily | daily |
| Forecasting | 0 | nightly auto | nightly auto | nightly auto | nightly auto |
| Research recommendations | 0 | weekly | weekly | daily | daily |

Soft warning to operator at 80% of daily cap; hard cap at 100% with "upgrade to lift cap" CTA.

Monthly company aggregate ceiling: **2× expected from daily caps** (catches outliers).

---

## Validation milestones

- [ ] **Phase 0:** confirm Anthropic pricing and contract terms; lock model + pricing assumptions
- [ ] **Phase 5 launch:** instrument every AI call with actual tokens; replace estimates with measured averages
- [ ] **Phase 11 (post-launch):** validate 5 paying tenants' actual AI costs against this model; adjust caps if reality diverges > 20%
- [ ] **Phase 13:** post-MCP launch — measure chat session costs in production; this is the largest single AI cost line
- [ ] **Monthly thereafter:** finance review checks AI cost / revenue per tier stays ≥ 70% gross margin

---

## Risk scenarios

### Scenario 1 — Chat heavy power user
A Scale tenant operator chats 50 sessions / day × 30 days = 1,500 sessions = £125 / month in chat alone. Daily cap of 50 sessions × £0.083 = £4.15/day = £125/month max. **Mitigation: daily cap is the right value; tenants needing more move to Enterprise.**

### Scenario 2 — Listing AI bulk run
Operator bulk-runs AI suggestions on 5,000-listing catalogue — £33 in one run. **Mitigation: bulk runs require explicit operator confirmation showing estimated cost; not auto-runnable.**

### Scenario 3 — Per-tenant abuse / scraping
Bad actor signs up free tier and tries to drive AI usage. **Mitigation: free tier has zero AI; Starter has hard caps; new tenants on Starter rate-limited for first 30 days.**

### Scenario 4 — Anthropic price increase
Pricing assumptions could change. **Mitigation: contract terms, multi-vendor option (Azure OpenAI as fallback) at Phase 13 if needed.**

---

## Action items before Phase 0

1. ☐ Get current Anthropic pricing in writing
2. ☐ Validate per-feature token estimates against 100 real prompt examples (use Phase 0 research time)
3. ☐ Decide chat session cap per tier (largest cost variable)
4. ☐ Finalise plan-tier prices in collaboration with finance
5. ☐ Set up Application Insights custom metric: `ai.cost_per_tenant_per_feature_per_day`
