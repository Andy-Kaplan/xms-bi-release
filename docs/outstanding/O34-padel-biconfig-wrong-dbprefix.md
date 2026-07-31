# O34 — Padel Social's report-DB `BiConfig.DbPrefix` points at a database that has never existed

> Detail file for ledger item **O34**. Read only when picking up this item. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | DOC-DEBT — ✅ **the row is FIXED (2026-07-31)**; only the documentation correction remains |
| **Priority** | 4 — *downgraded from 2* |
| **Area** | Microservice `report` DB / org configuration (UAT) + doc correction |
| **Owner / decides** | Andy |
| **Next action** | **Fix `docs/microservice-report-database.md`** — §1 still states `DbPrefix` resolves the client database as `{DbPrefix}_XMS_{OrganisationId}`, and §11 still lists `BiConfig` as the first result set of the card-render config load. The running system demonstrably does not depend on it. Say what actually resolves the client database, or say plainly that it is unverified. Optional follow-on: the cheap Prod sweep below, once Prod has orgs |

## ✅ The row was fixed on 2026-07-31

Corrected `20251208` → `20260310` as **step 1 of [O5](O5-growyze-default-dashboards.md)'s Plan 3 deploy**
(`ClaudeDevelopment/integrations/Growyze/report_config/01_prereqs_biconfig_visconfig.sql`), then independently
re-verified through MCP on a separate connection.

- The UPDATE is guarded on the current value (`AND DbPrefix <> N'20260310'`), so it reports `rows changed = 1` on the
  first run and is a no-op on every re-run. The old value is recorded in the script as a comment for rollback.
- **All `BiConfig` rows now resolve to a database that exists.** The count went **19 → 20** in the same deploy,
  because Ibis Heathrow — which had no `BiConfig` row at all — was provisioned alongside it. That org, not Padel,
  turned out to be the more consequential gap: Padel's wrong row was never read, whereas Heathrow's *missing* row
  sat under an org with no dashboards at all.
- Nothing changed in the front end as a result, which is the expected outcome given the correction above: the value
  is not the resolver.

**The doc half is untouched and is now the whole of this item.**
| **Found by** | [O32](O32-growyze-pantry-cogs-dashboard.md) rollout to Padel Social, 2026-07-31 |

> ## ⚠️ CORRECTION — the original severity claim here was WRONG
>
> This item was first written asserting that Padel's 4 dashboards "have never returned data on UAT". **That was an
> inference from the schema and the docs, and it is false.** Andy opened Padel Social's *Cost & Margins* dashboard
> and it renders fully populated cards. `InvCOGSByCategory` was then executed against the **real** database
> (`20260310_XMS_94A4B719-…`) and returns Beverages £35,573.16 / Other £10,731.42 / Food £3,985.27 /
> Uncategorised £3,519.59 / Retail £2,379.55 — **matching the rendered dashboard exactly**, £56,189 total.
>
> So the front end resolves the client database through some path that does **not** depend on
> `BiConfig.DbPrefix`. What remains unknown is *which*: whether `DbPrefix` is entirely unused, whether something
> falls back when the named database is absent, or whether resolution happens in the `organisation` microservice.
> Distinguishing those needs the microservice source, not this database.
>
> **Consequence: this never blocked anything.** [O32](O32-growyze-pantry-cogs-dashboard.md)'s Pantry COGS wiring
> on Padel was held back on the strength of the wrong claim; that hold has been lifted.
>
> **Lesson worth keeping:** the docs said `DbPrefix` resolves the database, the schema was consistent with that,
> and the audit trail corroborated a plausible story — and the conclusion was still wrong, because none of that
> is the running system. One glance at the UI settled what three sources of documentary evidence could not.

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

## Why it looked load-bearing (and why that was wrong)

⚠️ **Everything in this section is the reasoning that led to the WRONG conclusion.** It is kept because the
documentary case looked strong and someone will reconstruct it otherwise. The observed behaviour above overrides
all of it. Per `docs/microservice-report-database.md`:

- §1: *"`DbPrefix` (in `BiConfig`) — resolves to the MI database name `{DbPrefix}_XMS_{OrganisationId}`"*
- §11: `BiConfig_GetEntities_ByOrganisationIdentifier` is the *"Main config load for a card render"* and returns
  `BiConfig` as its first result set; `Filter_GetEntities_ByDashboardIdentifier` returns `BiConfig` + the filter
  datasets. There is no documented fallback resolution path.

Padel Social has **4 dashboards** wired in the report DB (Cost & Margins, Period Analysis, Products, Stock
Activity). The reasoning ran: if card rendering resolves the client database through `BiConfig`, none of them can
ever have returned data.

**It was tested and it is false** — see the correction at the top. All four render, from the real database. The
documentary chain (docs §1 + docs §11 + a corroborating audit trail) was consistent, coherent, and wrong about
the running system. `DbPrefix` being described as the resolver does not make it the resolver.

## The fix — APPLIED 2026-07-31 (kept for the record)

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

**Now optional and low-risk.** Since rendering demonstrably does not depend on this value, the update is
hygiene — it stops the next person reaching the same wrong conclusion. Low priority, but worth doing precisely
*because* the wrong value cost a session's reasoning once already.

## Also fix the documentation

`docs/microservice-report-database.md` §1 states plainly that `DbPrefix` *"resolves to the MI database name
`{DbPrefix}_XMS_{OrganisationId}`"*, and §11 lists `BiConfig` as the first result set of the "main config load for
a card render". Whatever was once true, **the running UAT system renders Padel's dashboards correctly while that
value points at a database that does not exist.** The doc should say what actually resolves the client database,
or say that it is unverified — the repo rule is that docs must reflect reality, and this one does not.

## Related

- **Did NOT block [O32](O32-growyze-pantry-cogs-dashboard.md) after all.** Pantry COGS wiring on Padel was held
  back on the strength of the wrong severity claim; the hold is lifted. Dirty Sixth was wired successfully and
  its prefix is correct, so nothing there is affected either way.
- Worth a one-off sweep for the same class of error on **Prod** once that has orgs — nothing currently checks that
  a `BiConfig` row resolves to a database that exists. The query is cheap: join `BiConfig` to `sys.databases` on
  `DbPrefix + '_XMS_' + OrganisationId`.
