# Pantry COGS Dashboard — Task 1 Preflight

Scope: answers to the three gating questions for the Growyze Pantry COGS dashboard build.
No database access was available in this session — every finding below is sourced from
reading files in the repository and cited `file:line`. Where the source alone cannot
settle a question, that is stated explicitly rather than inferred.

---

## Q1 — Delivery event type

**Source:** `ClaudeDevelopment/integrations/Growyze/02_staging_tier1.sql`, Step 10 `Growyze DN Events`, staging table `GRYZ_DN_EVENTS`, line 290 (`WHEN MATCHED` branch) and line 305 (`WHEN NOT MATCHED` branch — identical literal).

**Emits:** `EVENT_TYPE = 'ORDER'` — literal `''ORDER'' AS EVENT_TYPE` in both branches of the MERGE.

**Verdict:** `'ORDER'` already. The staging step does **not** emit `'DELIVERY'`.

Corroborating evidence:
- `ClaudeDevelopment/integrations/Growyze/14_dn_events_size_multiplier_fix.sql` (dated 2026-05-18, a later patch to the same step) reproduces the identical `''ORDER'' AS EVENT_TYPE'` literal at lines 76 and 91 while only changing the `UOM_QUANTITY` expression — confirming the `'ORDER'` value has not regressed since 02's original authoring (2026-03-05) through at least the 05-18 patch.
- `ClaudeDevelopment/integrations/Growyze/growyze_integration_audit.md` (2026-03-18), row `SAT_STOCKEVENT | 8,822 | 2,050 COUNT + 128 WASTE + 5,379 SALE + 1,265 ORDER` — 1,265 real `ORDER`-typed rows exist in the satellite, consistent with `GRYZ_DN_EVENTS` successfully feeding `ORDER` events.

**Discrepancy found:** `docs/stockevent-ruleset.md:81` currently reads *"Growyze | ORDER, WASTE, SALE, COUNT | `DELIVERY` used in GRYZ_DN_EVENTS (should be `ORDER`) — fix pending in 02_staging_tier1.sql."* This is **stale** — the fix has already been applied in the source file. The doc should be updated (out of scope for this task; flagging for whoever owns `docs/stockevent-ruleset.md`).

**Consequence:** step 9's (`F_INV_COUNTS_DAY`'s) `ORDER_QTY` is **populated** for Growyze orgs — the STOCKEVENT_TYPE gate is not the blocker some earlier documentation assumed.

**Action for 02_cogs_period_build.sql:** the brief's defensive instruction — `read EVENT_TYPE IN ('ORDER','DELIVERY')` regardless — is still good practice for forward-compatibility (protects against any other integration or a future regression), even though Growyze itself only ever emits `'ORDER'` today.

---

## Q2 — Two-level category integrity

**TOP_NAME sourced from:** the dimension-flatten recursive CTE's row where `PARENT_ID IS NULL` — `8_PresentationControl.sql:1852` (`COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN INVITEM_NAME END),''All INVITEMs'') as TOP_NAME`). That row, for Growyze, is the `Category` row seeded by `GRYZ_INVITEMS` staging.

**MIDDLE_1_NAME sourced from:** the recursive CTE's row at `RN = 2` (one hop up from the leaf item) provided it isn't itself the top — `8_PresentationControl.sql:1831` (`COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN INVITEM_NAME END), MAX(CASE WHEN PARENT_ID IS NULL THEN INVITEM_NAME END) ,''All INVITEMs'') as MIDDLE_1_NAME`). That row, for Growyze, is the `Sub Category` row.

**Growyze staging (the source of both tiers):** `ClaudeDevelopment/integrations/Growyze/02_staging_tier1.sql`, Step 2 `Growyze Inventory Items` (`GRYZ_INVITEMS`), lines 43–70 (query at line 50, duplicated at line 65). The staging query is a genuine 3-row-type `UNION ALL` producing a real parent/child chain:

| Row type | HUB_ID | PARENT_ID | LEVEL_NAME | BOTTOM_LEVEL |
|---|---|---|---|---|
| Inventory Item | `id` | `CONCAT(organizations,'-',subCategory)` | `Inventory Item` | 1 |
| Sub Category (only `WHERE subCategory IS NOT NULL`) | `CONCAT(organizations,'-',subCategory)` | `category` | `Sub Category` | 0 |
| Category (only `WHERE category IS NOT NULL`) | `category` | `NULL` | `Category` | 0 |

This is a real 3-tier chain: **Item → Sub Category → Category**, not a 2-tier chain with a duplicated label. `TOP_NAME` resolves to the real Growyze *Category*; `MIDDLE_1_NAME` resolves to the real Growyze *Sub Category* — they are two independently-sourced values, not the same value read twice.

**Empirical confirmation (no DB access needed — this is documented, not queried live):** `ClaudeDevelopment/integrations/Growyze/growyze_integration_audit.md`:
- Line 102: `SAT_INVITEM | 3,504 | 3,377 leaf items + 120 subcats + 7 categories` — 120 distinct subcategories vs. 7 distinct categories on Padel Social UAT. If MIDDLE_1 were collapsing into TOP, these counts could not both be non-trivial and different from each other.
- Line 163: *"All dimensions are well-formed for Growyze: no NULL names, coherent BOTTOM/MIDDLE_1/TOP paths, correct TOTAL_LEVELS."*

**Verdict: both levels distinct.**

**Caveat (not a blocker, but worth knowing before Task 4 writes the break-out rule):** `CONCAT()` in SQL Server treats `NULL` as an empty string, not `NULL`. So for an item whose `subCategory` is `NULL`, `PARENT_ID` becomes `CONCAT(organizations,'-',NULL)` = `"{org}-"` — a non-null string — but the Sub Category seed row for that value is never created (its `WHERE subCategory IS NOT NULL` guard, `02_staging_tier1.sql:50`). The recursive CTE's `INNER JOIN ... ON d.INVITEM_ID = h.PARENT_ID` (`8_PresentationControl.sql:1741`) then finds no match, the chain terminates at the leaf, and **both** `MIDDLE_1_NAME` and `TOP_NAME` fall through to the `'All INVITEMs'` sentinel for that item — not to a real Category, and not a collapse of one real value into another. This only affects items with a genuinely missing `subCategory`; it does not affect the general mechanism and does not block the `REPORT_GROUP` break-out rule, but downstream cards should expect an `'All INVITEMs'` bucket to appear for such items.

**Blocks the break-out rule:** **no.**

---

## Q3 — MICROSERVICE_NAME pollution on INVITEM

**Staging (source of the pollution):** `ClaudeDevelopment/integrations/Growyze/02_staging_tier1.sql`, Step 2 `Growyze Inventory Items`, line 50 (and 65) — the `GRYZ_INVITEMS` query hardcodes `''growyze'' AS MICROSERVICE_NAME` in **all three** row types (Inventory Item, Sub Category, Category).

**EntityMappings row for INVITEM:** `ClaudeDevelopment/integrations/Growyze/04_entity_mappings.sql`, mapping #1 (lines 17–39). Note a structural oddity here: the `WHEN MATCHED` branch's `entity_columns`/`source_columns` (line 23–24) **excludes** `MICROSERVICE_NAME`/`MICROSERVICE_ID` (12 columns), while the `WHEN NOT MATCHED` (insert) branch (lines 35–36) **includes** them (14 columns) — the two branches of the same idempotent MERGE disagree. This was later superseded/reconciled by `ClaudeDevelopment/integrations/Growyze/16_invitem_mapping_hotfix.sql` (2026-05-20), whose canonical 13-column list (lines 66–67, 78–79) **also excludes** `MICROSERVICE_NAME`/`MICROSERVICE_ID` in both branches, adding `UOM_COST` instead. Taken alone, this would suggest the entity-mapping layer no longer selects `MICROSERVICE_NAME` into the INVITEM hub/satellite.

**However — direct, independent evidence contradicts relying on the entity-mapping exclusion alone.** Two purpose-built fix scripts confirm the pollution actually reached the satellite and presentation layers:

- `ClaudeDevelopment/integrations/Growyze/reporting_queries/12_staging_microservice_name_fix.sql` — patches the **deployed** `StagingControl.query_sql` (via a `REPLACE('''growyze'' AS MICROSERVICE_NAME', 'NULL AS MICROSERVICE_NAME')`), explicitly listing `Growyze Inventory Items` as one of 4 affected staging steps (lines 13–17). This is a runtime patch over the deployed row, **not an edit to the `02_staging_tier1.sql` source file** — so if `02_staging_tier1.sql` is ever redeployed after this patch without re-running it, the hardcoded literal is reintroduced.
- `ClaudeDevelopment/integrations/Growyze/reporting_queries/14_null_microservice_columns.sql` — retroactively nulls `MICROSERVICE_NAME`/`MICROSERVICE_ID` in `datavault.SAT_INVITEM` (lines 41–45) and all three tiers of `presentation.D_INVITEM` (lines 72–78) wherever the value is `'growyze'`. Its header comment states real, counted impact on Padel Social UAT: **`datavault.SAT_INVITEM` — 3,490 rows** and **`presentation.D_INVITEM` — 3,363 rows** were affected. This is direct proof the hardcoded literal **did** reach `D_INVITEM` in practice — regardless of what the entity-mapping JSON theoretically excludes, `MICROSERVICE_NAME` was in fact populated with `'growyze'` on real INVITEM satellite/dimension rows.
- `ClaudeDevelopment/integrations/Growyze/growyze_integration_audit.md:101` (dated 2026-03-18) confirms this cleanup batch **was deployed** to UAT, at least for `SAT_PRODUCT` ("MICROSERVICE_NAME should be NULL (cleanup deployed)"). The audit's per-entity table does not separately re-confirm INVITEM's post-cleanup state, but 12/14 explicitly scope `GRYZ_INVITEMS`/`SAT_INVITEM`/`D_INVITEM` into the same fix.

**Verdict: hardcoded literal — historically confirmed reaching `D_INVITEM`; must not `COALESCE`.**

A fix exists and appears to have been deployed to at least one UAT environment by 2026-03-18, but:
1. This session has no DB access, so the *current* live state of `D_INVITEM.*_MICROSERVICE_NAME` for the actual target org cannot be confirmed from source alone.
2. The canonical staging source file (`02_staging_tier1.sql`) itself still contains the unfixed hardcoded literal — the fix lives only in a later, separate runtime patch (`12_staging_microservice_name_fix.sql`), not in the file the brief told us to treat as the tier-1 reference.

**Action for downstream tasks:** do not write `COALESCE(D_INVITEM.*_MICROSERVICE_NAME, native_name)` against Growyze data without first confirming (via a live query, not source-reading) that the target org's `D_INVITEM` rows have `MICROSERVICE_NAME IS NULL`. If not confirmed clean, use the native `*_NAME`/`*_INVITEM_NAME` columns directly and skip the `COALESCE`.

---

## Summary

| Question | Verdict | Blocks build? |
|---|---|---|
| Q1 — delivery EVENT_TYPE | `'ORDER'` already (docs/stockevent-ruleset.md is stale) | No |
| Q2 — two-level category | Both levels distinct (Category=TOP, Sub Category=MIDDLE_1); minor NULL-subCategory fallthrough edge case | No |
| Q3 — MICROSERVICE_NAME on INVITEM | Historically polluted; fix exists but unverified as currently live for this target org | No hard block, but downstream tasks must not blindly COALESCE — verify live before relying on it |
