# Growyze dashboard pack — sales source precedence (design)

**Date:** 2026-07-30
**Ledger:** O5 (Growyze default dashboards), feeds Plan 2 and Plan 3
**Status:** design approved, implementation plan to follow
**Author:** Claude (with Andy)

---

## 1. Problem

The Growyze default dashboard pack is meant to work on every Growyze-mapped organisation. But an organisation's *sales* can arrive from more than one place, and the pack currently has no rule for choosing:

- **Padel Social (10)** and **Dirty Sixth (18)** are Growyze-only. Growyze feeds their sales (`DL_SALES`/`DL_SALESDETAIL`/`DL_DISHES` → `GRYZ_LINEITEM`).
- **Ibis Heathrow (20)** and **Ibis Gloucester Road (21)** are Growyze + Mews. Mews is the POS; Growyze contributes **zero** line items.
- **The Oak & Vine (16)** carries four integrations — Growyze, MarketMan, Mews, NCRAloha. Its POS sales come from NCRAloha then Mews.

The three sales/margin datasets deployed on 2026-07-30 (`GrowyzeProfit`, `GrowyzeProfitPct`, `GrowyzeSalesByCategory`) are hardcoded to `SRC = 'int_growyze001'`. That is correct on the two Growyze-only orgs and returns **nothing** on the other three.

**Required behaviour:** use POS sales where the organisation has a POS integration; otherwise fall back to Growyze sales; otherwise show an empty card.

### 1.1 What this is NOT

This is **not** a fix for the £580k Three Rocks double-count (ledger **O10**). That was originally suspected to be a cross-integration overlap, but the 2026-07-02 audit established Three Rocks' `F_LINEITEM_15MIN` is NCRAloha-only and the inflation is a **join fan-out in `F_PRODUCT_MARGIN_DAY`'s product→cost map**. O10's fix is O7's `PRODUCT_COST_MAP` dedup. Confirmed again on 2026-07-30: Three Rocks emits PROD lines from `int_ncraloha001` only.

---

## 2. Ground truth (measured on UAT, 2026-07-30)

### 2.1 Which sources actually emit sales lines

`F_LINEITEM_15MIN`, `LI_TYPE = 'PROD'`:

| Org | Source | Rows | Net value | Date range |
|---|---|---|---|---|
| Padel Social (10) | `int_growyze001` | 9,796 | £204,866.82 | 2026-01-29 → 07-30 |
| Dirty Sixth (18) | `int_growyze001` | 16,278 | £466,582.61 | 2026-01-29 → 07-29 |
| Oak & Vine (16) | `int_ncraloha001` | 175,044 | £1,365,706.40 | 2025-10-01 → 2026-03-31 |
| Oak & Vine (16) | `int_mews001` | 1,368 | £55,221.06 | 2026-04-30 → 07-28 |
| Ibis Gloucester (21) | `int_mews001` | 875 | £33,144.54 | 2026-05-30 → 07-28 |
| Ibis Heathrow (20) | *(none)* | 0 | — | — |
| Three Rocks (1) | `int_ncraloha001` | 25,429 | £129,193.23 | 2025-12-31 → 2026-01-07 |

### 2.2 Oak & Vine's two POS sources do not overlap

Monthly source counts show `COUNT(DISTINCT SRC) = 1` for **every** month: NCRAloha Oct 2025 → Mar 2026, Mews Apr 2026 → Jul 2026. This is a **POS migration**, not duplication.

Consequence: precedence must not "pick one POS source per org" — that would discard either £1.37M of NCRAloha history or three months of Mews. **All POS sources are kept.** (Independent confirmation: June 2026 Mews net = £17,138.75, matching the Marge Brut June turnover of £17,138.71 recorded under O8.)

There is currently **no organisation where two sales sources overlap in time.** The rule's present-day effect is therefore to *exclude Growyze on POS orgs*; its forward-looking value is preventing a genuine double-count if Growyze's POS-sync is ever enabled on a Mews org.

### 2.3 Timestamp coverage

Counts below span **all** `LI_TYPE` values, so they are larger than the `PROD`-only figures in §2.1 (e.g. Oak & Vine Mews 2,252 here vs 1,368 PROD). Not a contradiction — different filters.

| Source | Rows | With timestamp | Distinct 15-min buckets |
|---|---|---|---|
| NCRAloha (Oak & Vine) | 262,376 | 262,376 (100%) | 8,643 |
| Mews (Oak & Vine) | 2,252 | 2,252 (100%) | 885 |
| Mews (Gloucester) | 1,464 | 1,464 (100%) | 589 |
| Growyze (Padel) | 10,464 | 1,070 (10%) | 151 |

POS sources carry full intra-day history already. The Growyze shortfall is the rolling-DL-window limitation recorded under O5; **Andy will land historical Growyze sales**, so this design assumes full history and does not work around the window.

### 2.4 Column shapes differ by source — the portability traps

| Property | Growyze | Mews | NCRAloha |
|---|---|---|---|
| `D_PRODUCT.BOTTOM_LEVEL_NAME` | `'Product'` | `'BOTTOM'` | `'BOTTOM'` |
| `TOP_NAME` | Beverages, Food, Retail, Other, Uncategorised (5) | Spirits, Wine, Soft Drinks, Hot Drinks, Bottled Beer, Food, Breakfast … (12) | Food, Drinks (2) |
| `MIDDLE_1_NAME` | identical to `TOP_NAME` (2-level) | product families — Peroni, Pinot Grigio (31+) | Mains, Cocktails, Burgers, Starters … (8) |
| `F_PRODUCT_MARGIN_DAY.SRC` | **column does not exist on the fact** | — | — |

---

## 3. Design

### 3.1 The resolver

A CTE prepended to each sales card. It joins the organisation's own `sys.schemas` to `core.core.Integrations`: a provisioned `int_*` schema is that org's local record of a mapped integration (the `OrganisationIntegrations` insert trigger creates it).

```sql
WITH org_pos AS (
    SELECT i.[SchemaName]
    FROM sys.schemas s
    INNER JOIN [core].[core].[Integrations] i ON s.name = i.[SchemaName]
    WHERE i.[IntegrationType] = 'POS'
),
sales_src AS (
    SELECT [SchemaName] AS SRC FROM org_pos              -- tier 1: ALL POS sources
    UNION ALL
    SELECT N'int_growyze001'                              -- tier 2: Growyze fallback
    WHERE NOT EXISTS (SELECT 1 FROM org_pos)
)
```

Then the fact is filtered by an inner join to `sales_src`.

**Tier 3 (empty) requires no code.** If neither tier matches any fact rows the join returns nothing, which is the correct output.

**Why this shape:**
- It follows a pattern already LIVE in the `Integrations` FilterList, so it is house style rather than invention.
- No per-org configuration and no hardcoded POS list — a new POS integration is honoured automatically. This matches the project's recorded preference for build-time auto-detect over flip-the-flag config.
- Precedence is driven by the **mapping** (Andy's decision), not by whether data has landed. Ibis Heathrow — Mews mapped, zero rows — therefore reads POS and shows an empty card rather than silently falling back to Growyze.

### 3.2 Two join variants

| Fact | Join |
|---|---|
| `F_LINEITEM_15MIN` (has `SRC`) | `INNER JOIN sales_src ss ON ss.SRC = F.[SRC]` |
| `F_PRODUCT_MARGIN_DAY` (no `SRC`) | `INNER JOIN sales_src ss ON ss.SRC = product.[BOTTOM_SRC]` |

The margin variant relies on the `D_PRODUCT` join already present in those templates. It is effectively an inner join on `product`, which is intended — a margin row whose product does not resolve is not attributable to a source.

### 3.3 Rules every precedence-aware card must follow

1. **Never filter `BOTTOM_LEVEL_NAME = 'Product'`** — source-specific (§2.4). It silently drops every POS product. Where a leaf restriction is genuinely needed, scope by `BOTTOM_SRC` instead.
2. **Category = `COALESCE(product.[TOP_MICROSERVICE_NAME], product.[TOP_NAME])`.** Correct for Mews (12 real categories) and Growyze (`TOP` ≡ `MIDDLE_1`); coarse but not wrong on NCRAloha (Food/Drinks — the same grain `OakVineMenuFoodDrinksSplit` already hardcoded, so no regression).
3. Keep `LI_TYPE = 'PROD'` and `NET_VALUE > 0` (excludes the ~18–22% comp/£0 lines).
4. **`CAST(F.[ORDER_DATE] AS DATE)` on `CALENDAR` joins.** `ORDER_DATE` is `datetime2` and POS sources *do* carry times, so an uncast equality would drop rows on precisely the orgs this change enables.
5. Date filters belong in `ParameterMappings` (`StartDate`/`EndDate`) — the only channel the date picker uses. Never an invented `FilterDefinitions` key.
6. Never repurpose `MICROSERVICE_NAME` to carry a category or grouping; it is the MDM display-name resolver.

### 3.4 Expected behaviour per org

| Org | Resolver returns | Sales cards show |
|---|---|---|
| Padel Social (10) | `int_growyze001` | Growyze sales — **unchanged** from today |
| Dirty Sixth (18) | `int_growyze001` | Growyze sales — **unchanged** from today |
| Oak & Vine (16) | `int_ncraloha001`, `int_mews001` | £1.42M POS sales (was empty) |
| Ibis Gloucester (21) | `int_mews001` | £33,144.54 Mews sales (was empty) |
| Ibis Heathrow (20) | `int_mews001` | empty — Mews mapped, no data yet |

---

## 4. Scope

**In scope**

1. Retrofit the three deployed datasets: `GrowyzeProfit`, `GrowyzeProfitPct` (margin variant), `GrowyzeSalesByCategory` (line-item variant, plus the `TOP_NAME` category change).
2. Apply the pattern to Plan 2's sales-derived cards.
3. A smoke test proving the cross-database read works through a real card stored procedure (§6, risk 1).
4. Verification per §5.

**Out of scope**

- The fact build (`PresentationControl`). Precedence lives in the vis queries only — decided to avoid rewriting shared global build steps that affect all 17 orgs and every existing card.
- O10 / O7 cost-map fan-out (§1.1).
- Mews' `BREAKFAST ADJUSTMENT` data-quality question (§6, risk 3).
- Any change to `OakVine*` shared datasets.

---

## 5. Verification

**Regression gate (must be identical to the pre-change values):**

All measured on UAT 2026-07-30, immediately before the change:

| Check | Padel (10) | Dirty Sixth (18) |
|---|---|---|
| `GrowyzeProfitPct` | 80.8% | 78.4% |
| Profit | £144,248.29 | £317,414.99 |
| Net value | £178,464.46 | £405,110.80 |
| Margin fact rows | 7,489 | 12,906 |
| `F_LINEITEM_15MIN` net sales (`PROD`) | £204,866.82 | £466,582.61 |

**New-coverage gate:**

- Oak & Vine (16): profit/net-value non-null; net value ≈ £1,420,927.46 across both POS sources; category pie shows Mews' 12 categories plus NCRAloha's Food/Drinks over the full range.
- Ibis Gloucester (21): net value ≈ £33,144.54, categories from Mews' `TOP_NAME`.
- Ibis Heathrow (20): returns zero rows without error.

**Resolver unit check** — run the CTE standalone per org and assert the returned source set matches §3.4.

**Negative check** — confirm no card returns rows from more than one *tier*: on a POS org, assert zero `int_growyze001` rows reach the result.

---

## 6. Risks

1. **Runtime cross-database permission (highest).** The resolver reads `core.core.Integrations` from inside the org database. Four LIVE vis queries already do this, but all are `FilterList`/`MarkdownCard`/`StaticBoxCard`. If the dashboard's runtime login lacks cross-database rights, **every** retrofitted sales card fails. *Mitigation:* smoke-test one retrofitted card end-to-end through its card SP before rolling the pattern out. This is the first implementation step, and a failure here forces a fallback to a per-org helper object.
2. **Oak & Vine's POS migration is visible.** A card spanning Oct 2025 → Jul 2026 mixes NCRAloha and Mews categories, so the legend changes mid-timeline. Not double-counting (zero month overlap). Accepted.
3. **Mews `BREAKFAST ADJUSTMENT` = £42,223.26 of £55,221.06** Oak & Vine Mews PROD sales (76%). Retrofitting surfaces it. Consistent with what Marge Brut already reports, so not a regression — flagged for separate decision.
4. **Growyze intra-day coverage** is only ~10% until historical sales land. Cards work either way; the heatmap is thin until then.
5. **Mapping-driven precedence is stale between loads by design.** A POS integration mapped but never loaded yields an empty card (Ibis Heathrow today). This is the chosen semantics, not a defect.

---

## 7. Decisions taken

| Decision | Choice | Rationale |
|---|---|---|
| Fallback trigger | Integration **mapped** | Predictable; avoids a card flipping source as data ebbs |
| Placement | **Vis queries only** | Zero blast radius on existing cards and other orgs |
| Retrofit deployed datasets | **All three** | One consistent rule across the pack |
| Category grain | **Always `TOP_NAME`** | Source-agnostic; matches the replaced card's existing grain |
| Multiple POS sources | **Keep all** | They are sequential (migration), not duplicate |
