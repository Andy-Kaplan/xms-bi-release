# O34 — Padel Social's report-DB `BiConfig.DbPrefix` points at a database that has never existed

> Detail file for ledger item **O34**. Read only when picking up this item. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | OPEN — root cause established; **fix identified but deliberately NOT applied** (it changes 4 existing dashboards, so it needs Andy's nod) |
| **Priority** | 2 |
| **Area** | Microservice `report` DB / org configuration (UAT) |
| **Owner / decides** | Andy |
| **Next action** | Decide whether to run the one-row fix below. It is required before [O32](O32-growyze-pantry-cogs-dashboard.md)'s Pantry COGS dashboard can resolve any data on Padel Social |
| **Found by** | [O32](O32-growyze-pantry-cogs-dashboard.md) rollout to Padel Social, 2026-07-31 |

## The defect

`report.dbo.BiConfig` maps an organisation to its Managed-Instance database as
`{DbPrefix}_XMS_{OrganisationId}`. For **Padel Social** (`94A4B719-EB0F-421F-AD03-ABECDD888B14`) it holds
`DbPrefix = 20251208`, which resolves to:

```
20251208_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14      <- does not exist
20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14      <- the real database
```

Confirmed against `sys.databases`: exactly **one** database exists for that GUID, created 2026-03-10. Padel Social
is the **only mismatch of all 19 `BiConfig` rows** — the other 18 all resolve to a database that exists.

## It was wrong from the first write, not drift

`Audit.BiConfig` for this org:

| AuditId | Action | AuditDate | DbPrefix |
|---|---|---|---|
| 11 | **I** (insert) | 2026-03-11 15:26:49 | `20251208` |
| 31–34 | U (update ×2 pairs) | 2026-07-03 10:56–10:57 | `20251208` (unchanged) |

The org's own `Organisations` row was **created** 2026-03-10 20:53 (`CreatedDate`, not a later `ModifiedDate`), so
the database already existed with the `20260310` prefix when the `BiConfig` row was inserted the next day. The
inserted value was simply wrong — `20251208` is the prefix **three other UAT orgs** legitimately share
(`44775945-…`, `9C4FAF85-…`, `B66AA165-…`), so this looks like a copy-paste from a sibling row. Two later updates
on 2026-07-03 touched the row without correcting it.

**So this is not stale config that drifted out of date — it has never pointed at a live database.**

## Why it matters

`DbPrefix` is load-bearing, not decorative. Per `docs/microservice-report-database.md`:

- §1: *"`DbPrefix` (in `BiConfig`) — resolves to the MI database name `{DbPrefix}_XMS_{OrganisationId}`"*
- §11: `BiConfig_GetEntities_ByOrganisationIdentifier` is the *"Main config load for a card render"* and returns
  `BiConfig` as its first result set; `Filter_GetEntities_ByDashboardIdentifier` returns `BiConfig` + the filter
  datasets. There is no documented fallback resolution path.

Padel Social currently has **4 dashboards** wired in the report DB (Cost & Margins, Period Analysis, Products,
Stock Activity). If card rendering resolves the client database through `BiConfig`, **none of them has ever
returned data on UAT.**

⚠️ **That conclusion is inferred from the schema and docs, not observed in the running front end.** It is possible
the microservice resolves the database some other way and `DbPrefix` is vestigial in practice — in which case the
row is merely wrong rather than harmful. **Confirming which is true is part of this item**, and it is worth
knowing generally: if `DbPrefix` really is unused, that changes how much anyone needs to care about `BiConfig`.
The cheapest test is to open one of Padel's four existing dashboards in the UI and see whether it renders.

## The fix

One row, reversible. Record the old value first.

```sql
-- report DB (xms-sql-fog-uat), by hand - MCP is read-only there
UPDATE dbo.BiConfig
   SET DbPrefix = N'20260310', DateUpdated = SYSUTCDATETIME()
 WHERE OrganisationId = '94A4B719-EB0F-421F-AD03-ABECDD888B14'
   AND IsDeleted = 0;
-- old value: 20251208
```

Prefer the `BiConfig_UpdateEntity` SP over a bare `UPDATE` if it fits — the audit trigger on this table works
(unlike the two broken ones in [O22](O22-report-db-audit-trigger-regression.md)), so either path leaves a record.

**Not applied yet** because it changes the behaviour of 4 dashboards outside O32's scope. It should be a strict
improvement — the current value cannot be correct, since the database it names does not exist — but that is
Andy's call, not an assumption to make silently.

## Related

- Blocks [O32](O32-growyze-pantry-cogs-dashboard.md) on Padel Social: the Pantry COGS report-DB wiring was
  deliberately **not** run there, because `08_report_db_config.sql`'s `BiConfig` step is an
  `IF NOT EXISTS` guard — it would skip the existing row, leave the dead prefix in place, and wire a dashboard
  that cannot resolve data. Dirty Sixth was wired successfully; its prefix is correct.
- Worth a one-off sweep for the same class of error on **Prod** once that has orgs — nothing currently checks that
  a `BiConfig` row resolves to a database that exists. The query is cheap: join `BiConfig` to `sys.databases` on
  `DbPrefix + '_XMS_' + OrganisationId`.
