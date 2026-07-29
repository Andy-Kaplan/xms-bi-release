# XMS Service Bus messaging — warehouse-side SQL (handover)

**For:** XMS BI Release project
**From:** XMS BI Integrations (ledger item **O8**)
**Date:** 2026-07-27
**Status:** SQL pre-written, **not yet executed anywhere** — needs review then a Dev run

---

## 1. What this is

The Python side of the XMS Service Bus outbox/inbox mechanism is **built, reviewed and
merged** to the Integrations `dev` branch (PR 13813 / commit 5469612, 2026-07-22) and rides
the normal deployment train. It is **inert** in every environment — both feature flags
default `false` and the Service Bus trigger does not register until its binding settings
exist.

It is blocked on warehouse-side objects that live in this project. Rather than hand over a
prose specification, the SQL is pre-written here so Release only has to review, run and fold
it into the master files.

**Source design spec (read this first if you want the full picture):**
`XMS BI/Integrations/docs/superpowers/specs/2026-07-21-service-bus-messaging-design.md`

### The flow

1. An API pull discovers a location the org DB has never seen → the function app inserts
   `core.LOCATION` **and** enqueues a `xmsbi.location.discovered` row in `core.EVENT_OUTBOX`,
   in the same transaction.
2. An end-of-run activity drains `EVENT_OUTBOX` → publishes to the `location-events` topic.
3. The XMS location microservice replies with its GUID.
4. A Service Bus topic trigger lands the reply envelope in that org's `core.EVENT_INBOX`.
5. **`core.sp_ApplyEventInbox` (this handover) applies it to the warehouse.**

---

## 2. Files, in deploy order

| # | File | Target DB | What it does |
|---|---|---|---|
| 01 | `01_event_tables_deployment_objects.sql` | CORE | Registers `core.EVENT_OUTBOX` (order 109) + `core.EVENT_INBOX` (order 110) as DeploymentObjects |
| 02 | `02_sp_apply_event_inbox.sql` | CORE | Registers `core.sp_ApplyEventInbox` (order 111) as a DeploymentObject |
| 03 | `03_getorgintegrations_org_guid.sql` | CORE | Appends `OrganisationGuid` as the 4th column of `core.GetOrgIntegrations` |
| 04 | `04_rollout_to_org_dbs.sql` | CORE | Deploys the three new objects into every ACTIVE org DB (`@WhatIf = 1` by default) |
| 05 | `05_validate.sql` | CORE | Read-only PASS/FAIL + health checks |

All five are idempotent and re-runnable. 01–03 are pure control-plane changes and change no
behaviour on their own; 04 is the only one that touches org databases.

---

## 3. Two questions the spec left open — both now answered

### 3.1 "Confirm the actual `SAT_LOCATION` microservice column name"

It is **`MICROSERVICE_ID` `NVARCHAR(255)`**, with a companion
**`MICROSERVICE_ID_BIN` `BINARY(32)`** (SHA-256 of the ID, for join optimisation). There is
also `MICROSERVICE_NAME NVARCHAR(255)`.

`sp_ApplyEventInbox` writes `MICROSERVICE_ID` and `MICROSERVICE_ID_BIN`. It deliberately
**does not touch `MICROSERVICE_NAME`** — that is the manually curated cross-integration
display name that `COALESCE(MICROSERVICE_NAME, LOCATION_NAME)` resolves against in the
presentation layer, and the inbound payload carries no name. **Open decision for Andrew —
see §6.1.**

### 3.2 "Add an org XMS GUID column to the CORE org table"

**Not needed — it already exists.** `core.Organisations.OrganisationCode` is a
`UNIQUEIDENTIFIER` and *is* the XMS org GUID: `core.CreateOrganisation` builds the org
database name as `@OrganisationPrefix + '_XMS_' + @OrganisationCodeStr`, which is why org DBs
are named e.g. `20260129_XMS_5AD1BEAC-31FD-F011-8D4C-0022489A1D57`. The GUID in every org DB
name **is** `OrganisationCode`.

So this dependency collapses to appending one column to `GetOrgIntegrations` (file 03).
It is backward-compatible in both directions: the function app reads the 4th tuple element
defensively (`if len(org_int) >= 4 and org_int[3]`), so old-app/new-proc and new-app/old-proc
both work. **Append only, never reorder** — every integration reads this tuple positionally.

---

## 4. The significant design change: reconciliation, not one-shot apply

**The spec's "`EVENT_INBOX` → `SAT_LOCATION` microservice column" would not have held.**

`core.sp_ProcessHubSat` step 2 **DELETEs** SAT rows whose CDC change type is `T1` or `N`, then
step 5 re-INSERTs them from `load.LOCATION` using only the columns listed in the entity
mapping's `entity_columns` — for LOCATION that is
`["HUB_ID","LOCATION_ID","LOCATION_NAME","BOTTOM_LEVEL","LEVEL_NAME"]`. `MICROSERVICE_*` is
not in that list, so it comes back **NULL**.

Consequence of a SAT-only write: the first time a location's name changes (an ordinary `T1`
change) the microservice GUID is **silently wiped** — and the location microservice only ever
emits it once, in reply to `location.discovered`, so it would never be resent. A `T2` change
has the same effect on the new current row.

### What the proc does instead

`core.LOCATION.MicroserviceId` (`UNIQUEIDENTIFIER`) is the **authoritative store**. It already
exists in every org DB, and its `UQ_LOCATION_Integration` unique constraint on
`(IntegrationLocationId, IntegrationSrc)` is *exactly* the event round-trip key. Nothing new
had to be created for it.

`SAT_LOCATION.MICROSERVICE_ID` / `_BIN` then becomes a **projection** of that, re-derived on
every call — so it **self-heals** after any T1/T2 SAT rebuild. `05_validate.sql` reports
`SatProjectionDrift` so the gap is visible when it exists.

### Why this is safe for CDC

`MICROSERVICE_*` columns are absent from LOCATION's `entity_columns`, so `sp_GenerateCDC`
never includes them in its `CHECKSUM` comparison. Writing them **cannot** cause spurious
T1/T2 churn.

> ⚠️ **Caveat:** if `MICROSERVICE_*` are ever added to LOCATION's `entity_columns`, issue
> **M3** in `docs/data-vault-reference.md` bites — the filter is
> `!= '[MICROSERVICE%'` (literal equality) where it should be `NOT LIKE '[MICROSERVICE%'`, so
> the columns *would* enter the checksum and cause endless spurious changes. Fix M3 first.

### Join path

`SAT_LOCATION.LOCATION_ID` (the un-hashed integration store id) → `core.LOCATION.IntegrationLocationId`,
plus `SAT_LOCATION.SRC` → `core.LOCATION.IntegrationSrc`. `SRC` is the integration schema name
(`sp_DataVaultLoad` passes `@SchemaName`), which is exactly what the function app writes as
`IntegrationSrc` (`integration_src=schema_name` in every integration's store-list activity).

The proc deliberately **does not** re-derive `HUB_ID` via `core.SHA256Hash` — joining on the
plain business key avoids depending on the hash convention.

---

## 5. Release actions

### 5.1 Run order

1. **Dev** — run 01, 02, 03 against CORE. Run 04 with `@WhatIf = 1`, read the plan, then
   `@WhatIf = 0`. Run 05 — Part 1 must be all-PASS.
2. Repeat for **Test**, **UAT**, then **Prod** (Prod via the PowerShell runner per
   `docs/release-guide.md` §6 — MCP `execute` is blocked on Prod).

### 5.2 Wire up the call site — needs a master-file edit

`sp_ApplyEventInbox` is not yet invoked by anything. It should run **inside `sp_DataVaultLoad`,
after the entity/schema loop completes and *before* `EXEC core.sp_ProcessPresentation`**, so
the GUIDs land in the same cycle the presentation layer is rebuilt from:

```sql
EXEC core.sp_ApplyEventInbox @JobID = @JobID;   -- add here, ~line 3000
EXEC @ReturnCode = core.sp_ProcessPresentation ...
```

`sp_DataVaultLoad` lives in `8_Deployment_Objects_Records.sql` (~line 2617), which is
read-only to Claude under this project's `CLAUDE.md`, so **this one edit is left for a
human.** It also has to be non-fatal — a messaging failure must never fail a DV load; wrap it
the same way the surrounding steps handle `@ReturnCode`.

> This is the same region of `sp_DataVaultLoad` as ledger item **O5** (the
> `sp_InitEntityDeltaParameters`-runs-after-`sp_ProcessPresentation` first-run bug). If both
> are actioned, coordinate them in one change.

### 5.3 Fold back into master files

Nothing here is a permanent home:

- 01 + 02 → new DeploymentObjects records in `8_Deployment_Objects_Records.sql`
  (orders 109/110/111 — currently free; 108 is LOCATION and the next existing object is 120).
- 03 → `3_CoreStoredProceduresAndFunctions.sql` (~line 989).
- 5.2 → `sp_DataVaultLoad` in `8_Deployment_Objects_Records.sql`.
- Promote to `releases/v{X.Y}/` per `docs/release-guide.md`, and update `QUERY_STATUS.md`.

---

## 6. Open decisions (Andrew / microservices team)

### 6.1 Should the GUID also drive `MICROSERVICE_NAME`?

Currently no. `core.LOCATION.MicroserviceName` exists and the presentation layer resolves
`COALESCE(MICROSERVICE_NAME, LOCATION_NAME)`, so projecting a name would **change dashboard
labels**. Left out on purpose as a behaviour change nobody asked for. If the location
microservice starts returning a canonical name, this becomes a deliberate MDM decision rather
than a side effect.

### 6.2 Event-type strings are placeholders

`sp_ApplyEventInbox` defaults to `@LocationCreatedEventType = N'xms.location.created'`. The
microservices team has not confirmed naming conventions. It is a **parameter**, so no redeploy
is needed to change it — but until it matches, inbound rows sit at `Status='Received'` and
are reported as `StillReceived` by `05_validate.sql`. Unrecognised event types are *not*
errored, so a later handler can still pick them up.

### 6.3 Still outstanding elsewhere (not this project)

- `location-events` topic + XMS BI subscription per environment (microservices team)
- The location microservice's consumer/response itself (microservices team)
- KV secret `service-bus-client-secret` + SB app settings per env; `Azure Service Bus Data
  Sender` + `Data Receiver` RBAC for the service principal
- Jira ticket for the feature (branch was merged as `feature/service-bus-messaging`)

---

## 7. ⚠️ Enablement gate — order matters

`SB_OUTBOX_ENABLED` is **app-global**, not per-org. If `core.EVENT_OUTBOX` is missing from
**any** org DB, that org's store-list staging activity fails on the enqueue and the ETL run
breaks.

**Do not set `SB_OUTBOX_ENABLED` in an environment until `05_validate.sql` Part 1 is
all-PASS for that environment.** The script prints a single go/no-go line for exactly this.

Safe order per environment: 01–04 → 05 all-PASS → topic + subscription exist → SB app
settings + KV secret → `SB_PUBLISH_ENABLED` → `SB_OUTBOX_ENABLED`.

---

## 8. Testing status — read this before trusting anything above

**None of this SQL has been executed.** It was written against the source of
`4_DeploymentTools.sql`, `6_GenerateDataVaultTables.sql`, `8_Deployment_Objects_Records.sql`
and `shared/services/sql.py`, and every column name, type and join key above was verified
against those files — but syntax, the metasql escaping in file 04, and the `OPENJSON`
shredding in the proc have **not** been run against a real database.

What has been verified on a real DB, separately: the function app's `MERGE ... OUTPUT $action`
new-location detection, smoke-tested against Dev org DB `20260413_XMS_C8D4A193` via
`scripts/sb_merge_output_smoke.py` (synthetic rows cleaned up).

### Suggested Dev smoke, once 01–04 have run

```sql
-- 1. Hand-land a fake reply for a location that really exists in this org DB
DECLARE @src NVARCHAR(50), @locId NVARCHAR(100);
SELECT TOP 1 @src = IntegrationSrc, @locId = IntegrationLocationId
FROM core.LOCATION WHERE MicroserviceId IS NULL;

INSERT INTO core.EVENT_INBOX (MessageId, EventType, CorrelationId, Payload)
VALUES (N'smoke-' + CONVERT(NVARCHAR(36), NEWID()),
        N'xms.location.created',
        NULL,
        N'{"eventId":"' + CONVERT(NVARCHAR(36), NEWID()) + N'",
           "eventType":"xms.location.created",
           "source":"xms-location-service",
           "tenantId":"00000000-0000-0000-0000-000000000000",
           "version":"1.0",
           "payload":{"integrationSrc":"' + @src + N'",
                      "integrationLocationId":"' + @locId + N'",
                      "microserviceId":"11111111-2222-3333-4444-555555555555"}}');

-- 2. Apply and inspect the counters
EXEC core.sp_ApplyEventInbox @Debug = 1;

-- 3. Expect: MicroserviceId set, SAT current row carrying the same GUID
SELECT IntegrationSrc, IntegrationLocationId, MicroserviceId, UpdatedBy
FROM core.LOCATION WHERE IntegrationLocationId = @locId AND IntegrationSrc = @src;

SELECT S.LOCATION_ID, S.SRC, S.MICROSERVICE_ID, S.MICROSERVICE_ID_BIN
FROM datavault.SAT_LOCATION S
WHERE S.LOCATION_ID = @locId AND S.SRC = @src AND S.CURRENT_FLAG = 1;

-- 4. Re-run to confirm idempotency: counters should come back all zero
EXEC core.sp_ApplyEventInbox @Debug = 1;
```

Worth also exercising deliberately: a malformed payload, an unknown location, a duplicate
`MessageId`, and a missing `$.payload` — all four should mark the row `Error` with a readable
`LastError` and leave nothing stuck at `Received`.

**Clean up the synthetic rows afterwards** (`core.EVENT_INBOX` row, and reset that location's
`MicroserviceId` / the SAT columns to `NULL`) so Dev is not left carrying a fake GUID.
