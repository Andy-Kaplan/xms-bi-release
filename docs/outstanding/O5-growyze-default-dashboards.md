# O5 — Growyze default dashboards rebuild

> Detail file for ledger item **O5**. Read only when picking up this item. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | DIAGNOSED — 1 of 3 blockers now fixed (UOM_COST), 2 remain |
| **Area** | Growyze / presentation + Report DB |
| **Owner / decides** | Andy |
| **Next action** | Resolve the remaining two data blockers (NULL `LINEITEM_TIMESTAMP`, `D_PRODUCT` category fall-through), then build the default dashboards per the re-plan |
| **Sources** | `memory/growyze-default-dashboards.md`, mockup `ClaudeDevelopment/integrations/Growyze/dashboard_mockups/kati_default_dashboards.html`, `docs/superpowers/specs/2026-07-29-growyze-uom-cost-pack-size-design.md` |

## Context
Default dashboards for Growyze orgs. **The 2026-05-20 plan is STALE** (P1 filter void; Growyze sales already in facts; cost is `F_PRODUCT_MARGIN_DAY.AVG_NET_COST`, not `D_PRODUCT`). Re-planned 2026-06-05 via a 6-agent UAT deep dive into 3 split plans (data-quality+enablement / cards+InvMargeBrut / Report DB wiring).

Real blockers before dashboards can be trusted:
1. **NULL `LINEITEM_TIMESTAMP`** on Growyze line items. — still open.
2. ~~**Inventory `UOM_COST` pack-vs-unit inflation** (16-113×).~~ — **fixed 2026-07-29**, see below.
3. **`D_PRODUCT` category fall-through.** — still open.

## Progress log
- **2026-05-20** — Initial plan (now stale).
- **2026-06-05** — Re-planned via 6-agent UAT deep dive; blockers identified.
- **2026-07-02** — Logged to ledger from memory.
- **2026-07-02 (DB audit, UAT Padel Social + Dirty Sixth)** — 2 of 3 blockers cleared:
  1. **NULL LINEITEM_TIMESTAMP — STILL-OPEN but has workaround.** `F_LINEITEM_15MIN` is 100% NULL on LINEITEM_TIMESTAMP (Padel 9,394/9,394, Dirty Sixth 15,722/15,722), BUT sibling `ORDER_DATE` is fully populated (Padel 2026-01-29→05-13, net £184,480). Only intra-day / time-of-day cards are blocked; date-grain cards work off ORDER_DATE.
  2. **UOM_COST pack-vs-unit inflation — RESOLVED / not present.** `F_INV_USAGE_DAY` (Padel 9,990 rows): min 0, avg 1.77, max 134.30, only 16 rows >100, none >1000. Top values are genuinely expensive retail items (padel rackets), not unit-vs-pack inflation.
  3. **D_PRODUCT category fall-through — PARTIALLY-RESOLVED (minor).** `D_PRODUCT` 2,169 rows, 0 NULL categories; 4 real categories cover 95%; ~109 (5%) fall through to self-name, "Other" holds 276 (12.7%). Small residual, not systemic.
  Net: dashboards can be built now on the date grain; timestamp blocker only limits intra-day cards.
- **2026-07-29 (UOM_COST blocker reopened and fixed)** — The 2026-07-02 "RESOLVED / not present" verdict measured Padel Social's `F_INV_USAGE_DAY` only, where usage happened to already be carried in pack units. The defect actually lives in `F_INV_COUNTS_DAY` (stock counts, in base units): `DL_PRODUCTS.price` is per pack while `ACTUAL_COUNT` is in base units (ml/g) — the count step stores `quantity × size` but cost was never divided by `size` to match, inflating stock value 16-113× per item (~93× across a whole stocktake). Root cause, design and blast-radius analysis: `docs/superpowers/specs/2026-07-29-growyze-uom-cost-pack-size-design.md`.
  - **Fix:** `UOM_COST = price / COALESCE(NULLIF(size,0),1)` in the `Growyze Inventory Items` staging step (`ClaudeDevelopment/integrations/Growyze/19_invitem_uom_cost_pack_size.sql`). Presentation layer deliberately unchanged — its existing `/ CONVERSION_FACTOR` division continues to carry measure → base unit.
  - **Deployed to UAT 2026-07-29**, all 4 Growyze orgs (Padel Social 10, Dirty Sixth 18, Ibis Heathrow 20, Ibis Gloucester Road 21) via `92_deploy_uom_cost_fix.ps1`.
  - **Acceptance gate PASSED** on Ibis Gloucester Road (`COUNT_DATE` 2026-06-30): stock value **£762,277.46 → £8,157.61** across the same 151 count lines, 0 null costs. Spot checks: Hendricks £27,655.60 → £39.51; SALAMI SLICED MILANO £46,620.00 → £93.24; ONE WATER STILL GLASS £53,460.00 → £71.28.
  - **Second defect found and fixed during deployment:** 4 items on Ibis Gloucester Road whose other Growyze attributes were unchanged between the pre-fix and post-fix batches kept their old per-pack cost — the staging fix + reload alone never propagated to them. CONFIRMED: the symptom (4 stuck rows, repaired by the backfill). NOT ESTABLISHED: the cause — `EntityMappings.entity_columns` for this entity includes `UOM_COST` and `sp_GenerateCDC` hashes it along with every other mapped column, so on paper `UOM_COST` *is* part of the CDC checksum; an earlier note in this branch stating it "does not participate in CDC change detection" is contradicted by the code and has been withdrawn. Candidate mechanisms (none established): a `CHECKSUM` collision in `sp_GenerateCDC`, the 4 items being absent from `load.INVITEM` on the affected run, or something else in the CDC path. Remedied by a targeted, idempotent backfill (`21_invitem_uom_cost_backfill.sql` + `93_backfill_uom_cost.ps1`) plus a reload. Post-backfill: 0 genuinely stuck rows across all 4 orgs. **Open risk, separate from this item:** a cost-only correction may not propagate to every row via a reload alone; the underlying mechanism needs its own investigation before anyone treats this as closed. Note also: items with `size = 1` are not evidence of this gap — for them the new staging expression yields an identical cost either way, so "no change" is the correct, non-defective outcome.
  - **MarketMan regression: PASS** — untouched (deploy scoped to Growyze-mapped orgs only).
  - **Blast radius narrower than predicted:** Padel Social and Dirty Sixth figures did **not** move — their catalogue items have `size = 1`, so `price / 1 = price` makes the division a no-op. Only the Ibis orgs were materially affected.
  - **New, separate open item (not caused by this work):** Padel Social (~£587k) and Dirty Sixth (~£791k–£1.2M) single-date stock values remain implausibly high — a pre-existing issue (likely `size = 1` catalogue entries and/or quantity semantics), untouched and unworsened by this fix. Needs its own investigation.
  - **Known source-data residual, unchanged:** items where Growyze's `size` is recorded in the wrong unit — ROCKET WILD (`kg` with `size` 500 meaning grams — reads too low) and CORONET WHITE SUGAR STICKS (`each`, size 1, £6.10 implying £6.10 per sugar stick — reads too high). These are catalogue errors, not SQL defects; `20_verify_uom_cost_pack_size.sql` Section D flags `size >= 100` items for review.

## Pick-up notes (resume here)
- Read `memory/growyze-default-dashboards.md` for the full re-plan and the 3 split plans.
- Remaining blockers: NULL `LINEITEM_TIMESTAMP` (workaround exists — build on `ORDER_DATE`) and `D_PRODUCT` category fall-through (minor, ~5%).
- New follow-up needed: Padel Social / Dirty Sixth implausibly-high stock values (see 2026-07-29 entry above) — not yet its own ledger item.
- These blockers overlap with O10 (£580k double-count) — check whether they share a root cause before fixing.
- Don't mark Closed until the user confirms.
