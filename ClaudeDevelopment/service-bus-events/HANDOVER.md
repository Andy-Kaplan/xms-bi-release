# XMS Service Bus messaging — generic MDM registry (warehouse-side SQL)

**For:** XMS BI Release project
**From:** XMS BI Integrations (ledger item **O8**)
**Date:** 2026-07-30 (supersedes the 2026-07-27 LOCATION-specific version of this document)
**Status:** Deployed and smoke-tested on **Dev only**. Test, UAT and Prod are untouched.

---

## 1. What this is

The Python side of the XMS Service Bus outbox/inbox mechanism is **built, reviewed and
merged** to the Integrations `dev` branch (PR 13813 / commit 5469612, 2026-07-22) and rides
the normal deployment train. It is **inert** in every environment — both feature flags
default `false` and the Service Bus trigger does not register until its binding settings
exist.

What sits *behind* the inbox has been redesigned since the first version of this handover.
The original plan applied inbound events directly to `datavault.SAT_LOCATION`'s microservice
column. That does not generalise — there is no equivalent of `core.LOCATION` for PRODUCT,
SUPPLIER, or the other ~16 dimension hubs that already carry `MICROSERVICE_ID` /
`MICROSERVICE_NAME` / `MICROSERVICE_ID_BIN` in anticipation of exactly this functionality.

It is now a **generic MDM registry**: one durable store per org DB (`core.MDM_RECORD`), one
tiny control table of projection rules (`core.MDM_PROJECTION`), and one generic procedure
(`core.sp_ApplyEventInbox`) that contains no entity names. Adding a new MDM entity costs zero
warehouse DDL and zero configuration.

**Design spec (read this first for the full reasoning):**
`XMS BI/Integrations/docs/superpowers/specs/2026-07-28-mdm-registry-design.md`

### The flow

1. An API pull discovers a location the org DB has never seen → the function app inserts
   `core.LOCATION` **and** enqueues a `xmsbi.location.discovered` row in `core.EVENT_OUTBOX`,
   in the same transaction.
2. An end-of-run activity drains `EVENT_OUTBOX` → publishes to the `location-events` topic.
3. The XMS location microservice replies with its GUID (and, for entities it masters,
   further canonical attributes).
4. A Service Bus topic trigger lands the reply envelope in that org's `core.EVENT_INBOX`.
5. **`core.sp_ApplyEventInbox` (this handover) shreds it into `core.MDM_RECORD`, the system
   of record, then projects it onto `datavault.SAT_<Entity>.MICROSERVICE_*` for current
   rows.**

---

## 2. Files, in deploy order

Files are numbered so file order equals execution order. Every registration script (`01`,
`02`, `03`) is **generated** — the `*a_*` files are the plain, readable T-SQL bodies a
maintainer actually edits; `build_registration.py` escapes them into a
`core.DeploymentObjects` registration script. **Never hand-edit a generated file** — edit its
body and regenerate (`python build_registration.py <manifest>.json`).

| # | File | Generated from | Target DB | What it does |
|---|---|---|---|---|
| 01 | `01_event_tables_deployment_objects.sql` | `01a_event_outbox_body.sql`, `01a_event_inbox_body.sql` | CORE | Registers `core.EVENT_OUTBOX` (order 109) + `core.EVENT_INBOX` (order 110) |
| 02 | `02_mdm_registry_deployment_objects.sql` | `02a_mdm_record_body.sql`, `02a_mdm_projection_body.sql` | CORE | Registers `core.MDM_RECORD` (order 111) + `core.MDM_PROJECTION` (order 112), the latter seeded with two wildcard rules |
| 03 | `03_sp_apply_event_inbox.sql` | `03a_sp_apply_event_inbox_body.sql` | CORE | Registers `core.sp_ApplyEventInbox` (order 113) |
| 04 | `04_getorgintegrations_org_guid.sql` | — (hand-written, unchanged since 2026-07-27) | CORE | Appends `OrganisationGuid` as the 4th column of `core.GetOrgIntegrations` |
| 05 | `05_rollout_to_org_dbs.sql` | — | CORE | Deploys all five objects into every ACTIVE org DB (`@WhatIf = 1` by default) |
| 06 | `06_validate.sql` | — | CORE | Read-only PASS/FAIL + health checks (object presence, column-contract counts, registry/projection state, orphans, drift) |

Supporting tooling: `build_registration.py` (the generator), `check_literals.py` +
`test_check_literals.py` (verifies every T-SQL string literal in a script terminates where
intended — the main failure mode when hand-escaping T-SQL), `01_manifest.json` /
`02_manifest.json` / `03_manifest.json` (the generator's inputs), `DEPLOY.txt` (run order +
enablement gate + the Dev deployment record).

All are idempotent and re-runnable. 01–04 are pure control-plane changes and change no
behaviour on their own; 05 is the only one that touches org databases.

---

## 3. Two questions the original spec left open — both answered

### 3.1 Target column

`sp_ApplyEventInbox` writes exactly two columns, per entity: **`MICROSERVICE_ID`
`NVARCHAR(255)`** and its companion **`MICROSERVICE_ID_BIN` `BINARY(32)`** (a SHA-256 hash of
the canonicalised ID text, for a collation-proof join key). `MICROSERVICE_NAME` is also
projectable but ships **inactive** (§7 below).

### 3.2 Org GUID column

**No new column was needed.** `core.Organisations.OrganisationCode` already **is** the XMS
org GUID: `core.CreateOrganisation` builds the org database name as
`@OrganisationPrefix + '_XMS_' + @OrganisationCodeStr`, which is why org DBs are named e.g.
`20260129_XMS_5AD1BEAC-31FD-F011-8D4C-0022489A1D57`. So this dependency collapsed to appending
one column to `GetOrgIntegrations` (file 04) — backward-compatible in both directions, since
the function app reads the 4th tuple element defensively. **Append only, never reorder** —
every integration reads this tuple positionally.

---

## 4. The significant design decision: reconciliation, not one-shot apply

`core.sp_ProcessHubSat` step 2 **DELETEs** SAT rows whose CDC change type is `T1` or `N`, then
step 5 re-INSERTs them from `load.{Entity}` using only the columns named in that entity
mapping's `entity_columns`. `MICROSERVICE_*` is in no mapping's `entity_columns`, so it comes
back **NULL**.

So a SAT-only write would not have held: the first time a dimension record's name changes — an
ordinary `T1` — the microservice identity would be silently wiped, and the microservice only
ever emits it once, in reply to `*.discovered`, so it would never be resent.

**Neither would a table per entity.** `core.LOCATION` happens to be a viable identity store for
LOCATION only because it already exists as the API-pull registry — there is no equivalent for
PRODUCT, SUPPLIER, INVITEM, or the rest, and building one per entity would mean 15–18 bespoke
tables and projections.

### What the mechanism does instead

`core.MDM_RECORD` is the **durable, entity-agnostic system of record**, keyed
`(EntityName, IntegrationSrc, BusinessKey)`. `datavault.SAT_<Entity>.MICROSERVICE_*` is a
**derived projection** of it, re-computed **in full, every run** — not just for newly-arrived
rows. That full reconciliation is exactly what self-heals a `T1`/`T2` satellite rebuild:
whatever the DV load just wiped, the next projection pass puts back. `06_validate.sql` reports
`SatProjectionDrift` so any gap is visible rather than silent.

### Why this is safe for CDC

`MICROSERVICE_*` columns are absent from every entity's `entity_columns`, so `sp_GenerateCDC`
never includes them in its `CHECKSUM` comparison. Writing them **cannot** cause spurious
T1/T2 churn.

> ⚠️ **M3 caveat.** Issue **M3** in `docs/data-vault-reference.md`: the CDC MICROSERVICE-exclusion
> filter is `!= '[MICROSERVICE%'` (literal equality) where it should be `NOT LIKE
> '[MICROSERVICE%'`. It is currently harmless because no mapping lists `MICROSERVICE_*` in
> `entity_columns` — but **M3 must be fixed before any mapping ever does**, or those columns
> would enter the CHECKSUM and cause endless spurious T1/T2 changes.

### Join path

The projection joins `datavault.SAT_<Entity>` to `core.MDM_RECORD` on the **salted** `HUB_ID`
hash plus `SRC`, computed inline (never via `core.SHA256Hash`, which does not exist in org
databases — see §6):

```sql
S.HUB_ID = HASHBYTES('SHA2_256', CAST(CONCAT_WS('|', R.BusinessKey, R.IntegrationSrc) AS VARBINARY(MAX)))
AND S.SRC = R.IntegrationSrc
AND S.CURRENT_FLAG = 1
```

This sidesteps the vault's native-id column naming inconsistencies entirely (mostly
`<ENTITY>_ID`, but `OCCASION` uses `OCCASSION_ID`, `REVCENTER` uses `REVC_ID`, `SVCCHARGE` uses
`SVC_ID`, and `EMPLOYEE` has no native-id column at all) — the hub's own hash is the join key,
not any per-entity id column.

---

## 5. Canonicalisation, and why `MICROSERVICE_ID_BIN` needs it

`MICROSERVICE_ID` is `NVARCHAR(255)`; GUID text is not canonical — casing, surrounding braces
and whitespace vary by producer. Under a case-insensitive collation, `'abc…' = 'ABC…'` is
*true*, so text comparisons hide differences — but `HASHBYTES('SHA2_256', …)` is byte-sensitive
over UTF-16, so the *hash* of the same two strings disagrees. `MICROSERVICE_ID_BIN` was
introduced years ago to give a clean fixed-width join key, but it only holds if something
canonicalises the text **before** hashing — which is exactly what had never existed, and is why
the ID columns were never adopted (the presentation layer joins on name instead — see Release
ledger O20).

A registry with exactly one writer removes the discipline problem by construction. Applied
once, on the way in, deterministic and idempotent:

1. Trim leading/trailing whitespace.
2. Strip a single pair of surrounding braces `{}`.
3. If `TRY_CONVERT(UNIQUEIDENTIFIER, x)` succeeds → store SQL Server's canonical form
   (uppercase, hyphenated, unbraced, 36 characters).
4. Otherwise → the trimmed string as-is (non-GUID microservice IDs remain supported).
5. `MicroserviceIdBin` = unsalted `HASHBYTES('SHA2_256', CAST(MicroserviceId AS VARBINARY(MAX)))`
   of the canonical string.

Drift detection compares `MICROSERVICE_ID_BIN` — binary, exact — never the text column under a
CI collation, because that would hide precisely the casing differences this exists to fix.

---

## 6. Hashing: inline, and salted for `HUB_ID` only

Corrected 2026-07-29 after probing Dev; the original spec assumed both of the following
incorrectly.

**`core.SHA256Hash` does not exist in org databases** — it is defined only in the `core`
control database. Every hash in `sp_ApplyEventInbox` is computed inline with
`HASHBYTES('SHA2_256', CAST(… AS VARBINARY(MAX)))`, which is exactly what that function does.

**`HUB_ID` is salted with the integration schema.** The DV load generates
`HASHBYTES('SHA2_256', CAST(CONCAT_WS('|', <column>, '<intSchema>') AS VARBINARY(MAX)))`
(`3_CoreStoredProceduresAndFunctions.sql:1312`), and `SRC` holds that same `<intSchema>`.
Proven on Dev (`20250917_XMS_C14CF568-588D-F011-B3CD-000D3AD9E9D4`): the salted form matched
**9/9** `int_marketman001` and **6/6** `int_ncraloha001` current `SAT_LOCATION` rows, plus
**1015/1015** and **234/234** `SAT_PRODUCT` rows; the un-salted form matched **0**.

`MICROSERVICE_ID_BIN` stays **unsalted** — it is an identity hash of the canonical ID text, not
a hub key.

**Known exception:** `int_troap001` rows do not satisfy the salted `HUB_ID` formula, because
TROAP's hashed source column is not `LOCATION_ID`. TROAP is out of scope — it does not use
`global_location_data_upsert`, so it never publishes discovery events. `06_validate.sql`'s
orphan count keeps any such mismatch visible rather than silent.

---

## 7. Three safety guards

Only `MICROSERVICE_%` columns may ever be written by this mechanism, enforced independently in
three places so the ownership rule is structural rather than merely documented:

1. `core.MDM_PROJECTION.TargetColumn` has a `CHECK` constraint: `TargetColumn LIKE
   N'MICROSERVICE[_]%'`.
2. The seed rows are curated and INSERT-only (a re-deploy cannot reset `IsActive`).
3. `sp_ApplyEventInbox` itself refuses any `TargetColumn` not matching that same pattern,
   skipping and logging it — so a bad control-table row cannot cause the bus to overwrite
   integration-sourced data such as `PRODUCT_NAME` or `ATTR_3`.

Proven on Dev (smoke case 8): a deliberately bad `MDM_PROJECTION` row naming `PRODUCT_NAME` was
refused by the table `CHECK`; with the `CHECK` disabled, the procedure's own guard still left
`PRODUCT_NAME` untouched.

`MICROSERVICE_NAME` push-down ships **`IsActive = 0`**. Presentation currently resolves
cross-integration alignment on **name** (133 references in `8_PresentationControl.sql`);
pushing a canonical name down while joins are name-based would change *join identity*, not
merely a displayed label. Enabling it is a one-row, reversible switch, gated on Release ledger
**O20** landing first.

---

## 8. The `sp_DataVaultLoad` call site — still a human edit

`sp_ApplyEventInbox` is not yet invoked by anything. It must run **inside `sp_DataVaultLoad`,
after the entity/schema loop and before `EXEC core.sp_ProcessPresentation`**, so identities
reach the presentation rebuild in the same cycle:

```sql
EXEC core.sp_ApplyEventInbox @JobID = @JobID;   -- add here, ~line 3000
EXEC @ReturnCode = core.sp_ProcessPresentation ...
```

`sp_DataVaultLoad` lives in `8_Deployment_Objects_Records.sql` (~line 2617), which is read-only
to Claude under this project's `CLAUDE.md`, so **this edit is left for a human.** It must be
non-fatal — a messaging failure must never fail a DV load — wrapped the same way the
surrounding steps handle `@ReturnCode`.

> This is the same region of `sp_DataVaultLoad` as ledger item **O5** (the
> `sp_InitEntityDeltaParameters`-runs-after-`sp_ProcessPresentation` first-run bug). If both are
> actioned, coordinate them in one change.

---

## 9. Enablement gate — order matters

`SB_OUTBOX_ENABLED` is **app-global**, not per-org. If `core.EVENT_OUTBOX` is missing from
**any** org DB, that org's store-list staging activity fails on the enqueue and the ETL run
breaks.

**Do not set `SB_OUTBOX_ENABLED` in an environment until `06_validate.sql` Part 1 is all-PASS
for that environment.** Full order, per environment, from `DEPLOY.txt`:

```
01 → 02 → 03 → 04 → 05 (@WhatIf=1, read the plan, then @WhatIf=0) → 06 all-PASS
  → confirm MDM_PROJECTION has MICROSERVICE_NAME at IsActive=0
  → topic + subscription exist
  → SB app settings + KV secret
  → SB_PUBLISH_ENABLED
  → SB_OUTBOX_ENABLED
```

`SB_OUTBOX_ENABLED` has **not** been set anywhere. Neither has any other Service Bus app
setting — those are out of scope for this warehouse work.

---

## 10. Testing status — what has actually been proven

**Deployed and smoke-tested on Dev only.** Test, UAT and Prod have not been touched.

Registered in Dev CORE: `EVENT_OUTBOX` (109), `EVENT_INBOX` (110), `MDM_RECORD` (111),
`MDM_PROJECTION` (112), `sp_ApplyEventInbox` (113) — 5 rows, `IsActive = 1`. Rolled out to all
**20 ACTIVE org DBs** (dry-run then real, 100/100 SUCCESS, 0 errors). `06_validate.sql`: Part 1
100/100 PASS (gate: *"PASS — safe to set SB_OUTBOX_ENABLED"*); Part 2 80/80 PASS, column counts
10 (EVENT_OUTBOX) / 8 (EVENT_INBOX) / 12 (MDM_RECORD) / 4 (MDM_PROJECTION) for every org DB;
Part 3 one health row per org DB, every signal zero. `MDM_PROJECTION` holds exactly the two
seed rows, `MICROSERVICE_NAME` at `IsActive = 0`.

All **eight** spec §11 smoke cases passed, against org DB
`20250917_XMS_C14CF568-588D-F011-B3CD-000D3AD9E9D4` (chosen for real `int_marketman001` /
`int_ncraloha001` data, not the plan's original nominee, which had zero current rows and would
have passed every case vacuously):

1. Identity-only record for an existing LOCATION → `MICROSERVICE_ID` + `_ID_BIN` populated.
2. Same record replayed → all counters zero (idempotency).
3. **T1 wipe and repair** — the design's central claim, proved on real data: wiped 2 rows'
   identities → validation drift 2 → `sp_ApplyEventInbox` restored `SatProjected = 2` → drift 0,
   restored exactly.
4. Identity arriving before its entity is loaded → registry row kept, counted as an orphan, no
   SAT write.
5. **PRODUCT**, a second entity, projected with **zero configuration added** — `MDM_PROJECTION`
   stayed at 2 rows.
6. Canonicalisation — a lower-case, brace-wrapped, whitespace-padded GUID produced the same
   canonical, uppercase, unbraced `MicroserviceId` and a matching `MicroserviceIdBin`.
7. Five failure-path messages classified exactly per spec (malformed JSON, missing
   `businessKey`, unknown entity → `Error`; absent/bare-scalar `$.payload` → left `Received`).
8. Both safety guards proven independently (§7 above).

Synthetic data was cleaned up afterwards (all `smoke-`/`bad-` inbox rows deleted,
`core.MDM_RECORD` emptied, `MICROSERVICE_*` reset to NULL — in the smoke DB only).
`06_validate.sql` re-run: Part 1 all-PASS, Part 3 all zero. The one org DB holding real curated
MDM data (`20251208_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14` — 7 `SAT_LOCATION` + 2162
`SAT_PRODUCT` rows with `MICROSERVICE_ID` populated) received the five new objects via the
additive rollout but was never targeted by any smoke case or cleanup statement; its counts are
unchanged.

Full run detail: `DEPLOY.txt`'s Dev deployment record.

### Still outstanding, not part of this warehouse work

- **Microservices team:** `location-events` topic + XMS BI subscription per environment; the
  §8 payload routing fields (`entityName` / `integrationSrc` / `businessKey`); the location
  microservice's consumer/response.
- **Infrastructure:** KV secret `service-bus-client-secret`, SB app settings per environment,
  `Azure Service Bus Data Sender` + `Data Receiver` RBAC for the service principal.
- **This project:** the `sp_DataVaultLoad` call site (§8 above); a Jira ticket for the feature;
  running 01–06 against Test, UAT and Prod.
- **Release ledger O20:** migrate presentation cross-integration joins from name to ID. Gates
  enabling the `MICROSERVICE_NAME` rule.
