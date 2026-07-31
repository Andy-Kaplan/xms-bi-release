# O20 — Presentation layer: switch cross-integration joins from MICROSERVICE_NAME to MICROSERVICE_ID

> Detail file for ledger item **O20**. Read only when picking up this item. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | OPEN (the MDM registry mechanism now **exists and is proven on Dev** — Integrations **O8** — so this item is no longer blocked on the mechanism itself, only on real ID coverage) |
| **Owner / decides** | Andy |
| **Area** | Presentation / dimension builds + visualisation queries (`8_PresentationControl.sql`, `8_VisualisationQueries.sql`) |
| **Next action** | O8 deployed the registry to **Dev only** (Test/UAT/Prod remain) and proved it populates `MICROSERVICE_ID`/`_ID_BIN` correctly, including self-healing a `T1` wipe on real data. This item still cannot start for real: Dev's identities are synthetic-smoke-tested-then-cleaned-up, not a real population from the microservice, so there is no genuine coverage to inventory joins against yet. Once real identities exist (post microservices-team integration): inventory every place cross-integration alignment resolves on name, decide the join key (`MICROSERVICE_ID` vs `MICROSERVICE_ID_BIN`), migrate per entity behind a before/after row-count + label diff |
| **Sources** | `XMS BI/Integrations/docs/superpowers/specs/2026-07-28-mdm-registry-design.md` §9 |

## Context

The MDM layer (`MICROSERVICE_ID`, `MICROSERVICE_NAME`, `MICROSERVICE_ID_BIN` on ~18 dimension
hubs) exists so records from different integrations can be aligned onto one canonical entity.

**Today that alignment resolves on `MICROSERVICE_NAME`, not on ID** — 133 references across
`8_PresentationControl.sql`. That was a workaround: storing microservice IDs was never solved, so
name became the de facto key. `MICROSERVICE_ID_BIN` (`BINARY(32)`) was added to give a clean
fixed-width ID join key, but it is referenced **zero** times in the presentation builds and has
never been populated.

Joining dimensions on a display name is fragile — renames silently re-key records, and two
genuinely different entities sharing a name collapse into one.

### Why it was never solved (the actual root cause)

`MICROSERVICE_ID` is `NVARCHAR(255)` and GUID text is not canonical: casing, surrounding braces
and whitespace vary by producer. That gives two failures pointing opposite ways:

- Under a case-insensitive collation `'abc…' = 'ABC…'` is **true**, so text comparisons hide
  differences.
- `core.SHA256Hash` is `HASHBYTES('SHA2_256', CAST(@input AS VARBINARY(MAX)))` — byte-sensitive
  over UTF-16 — so `SHA256Hash('abc…') <> SHA256Hash('ABC…')`.

So `MICROSERVICE_ID_BIN` only works if something canonicalises the text **before** hashing, and
under manual-entry-only there was no single writer to enforce that.

### What unblocks it

Integrations **O8** introduces a generic MDM registry (`core.MDM_RECORD` +
`core.MDM_PROJECTION` per org DB) fed from the Service Bus inbox. It becomes the **single writer**
of the MDM columns and owns canonicalisation (trim → strip braces → canonical uppercase 36-char
GUID form → `_ID_BIN` = SHA-256 of that). That structurally removes the root cause above.

Good news for this item: the dimension builds already carry `MICROSERVICE_ID` through
**symmetrically** at every tier — `BOTTOM_MICROSERVICE_ID`, `MIDDLE_1_MICROSERVICE_ID`,
`TOP_MICROSERVICE_ID` all exist and reach the `D_*` tables. They are NULL only because nothing
populated the source. So O8 lights up the ID pipeline end-to-end **with no presentation change**;
this item is only about moving the *joins*.

## Scope

1. Inventory every place cross-integration alignment resolves on `MICROSERVICE_NAME` (distinguish
   genuine join/matching use from pass-through plumbing and display-only use — most of the 133 are
   the latter).
2. Decide the join key: `MICROSERVICE_ID` (canonical text, now reliable) or `MICROSERVICE_ID_BIN`
   (`BINARY(32)`, narrower and collation-proof, matches the vault's hash-key convention).
3. Migrate per entity, not in one pass. LOCATION first — it is the first entity O8 populates.
4. Keep `MICROSERVICE_NAME` for **display**; retire it only as a *join* key.

## Sequencing constraint (important)

**Do not enable the `MICROSERVICE_NAME` projection rule in O8 until this item lands.** While
joins are name-based, pushing a canonical name down from the microservice would change *join
identity*, not merely a displayed label. O8 therefore seeds that rule with `IsActive = 0`;
flipping it is a one-row, reversible switch that belongs at the end of this item.

## Risks

- **Dashboard regression** is the main risk: a changed join key changes row counts and grouping.
  Every entity migration needs a before/after row-count and label diff on a real org DB.
- **Partial population.** Until every location/product has been through a bus round-trip,
  `MICROSERVICE_ID` will be NULL for some records. An ID join must degrade gracefully —
  `COALESCE(MICROSERVICE_ID, native_ID)`-style fallback, or stay on name until coverage is
  complete per entity. Decide this before migrating, not during.
- **Issue M3** (`docs/data-vault-reference.md`): the CDC MICROSERVICE-exclusion filter is
  `!= '[MICROSERVICE%'` where `NOT LIKE '[MICROSERVICE%'` was intended. Harmless today because no
  mapping lists `MICROSERVICE_*` in `entity_columns` — but if this item's work ever adds them,
  fix M3 first or the columns enter the CDC CHECKSUM and cause endless spurious T1/T2 changes.

## Progress log

- **2026-07-28** — Item raised while designing the Integrations O8 MDM registry. Established from
  source: 133 `MICROSERVICE_NAME` references in `8_PresentationControl.sql` vs **0** for
  `MICROSERVICE_ID_BIN`; ID columns already plumbed through all three dimension tiers into `D_*`;
  root cause of non-adoption identified as the GUID canonicalisation trap (see Context). Andy
  confirmed the intent: "ideally all presentation queries will join on an id column, rather than
  name." No code changes yet — blocked on O8.

- **2026-07-30** — Integrations O8's MDM registry **deployed to Dev and validated**: 5 objects on
  all 20 ACTIVE org DBs, `06_validate.sql` all-PASS, and all 8 spec smoke cases passed — including
  the `T1`-wipe-and-repair case, which proved the registry's canonicalisation + self-healing
  projection on real `int_marketman001`/`int_ncraloha001` data. This item is **no longer blocked
  on the mechanism existing**; the blocker narrows to real ID coverage, which requires the
  microservices team's side (topic, location microservice, payload routing fields) and running the
  registry past Dev — none of which has happened yet, so no migration work can start for real.
  `MICROSERVICE_NAME` push-down remains seeded `IsActive = 0` in the registry; enabling it still
  gates on this item landing first (unchanged).

## Pick-up notes (resume here)

- Read `XMS BI/Integrations/docs/superpowers/specs/2026-07-28-mdm-registry-design.md` §9 first —
  it holds the reasoning and the sequencing constraint.
- Do not start until `MICROSERVICE_ID` is actually populated in a Dev org DB; the migration cannot
  be validated against NULL columns.
- `ClaudeDevelopment/cost-path-redesign/07_remove_microservice_mappings.sql` NULLed
  `MICROSERVICE_NAME`/`MICROSERVICE_ID` in `SAT_LOCATION`/`SAT_PRODUCT`/`SAT_SUPPLIER`, so there is
  no legacy MDM data to reconcile — a clean start.
- Presentation SQL lives in control tables, so changes are `MERGE` upserts into
  `PresentationControl` / `VisualisationQueries`, per the house upsert rule.
