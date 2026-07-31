# O22 — Report DB: audit-trigger regression blocks the platform-default and staff config tiers

> Detail file for ledger item **O22**. Read only when picking up this item. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | DIAGNOSED — verified on UAT, not yet remediated |
| **Area** | Microservice report DB / correctness |
| **Owner / decides** | Andy |
| **Next action** | Update `DashboardConfig_Audit` and `StaffDashboardConfig_Audit` to populate `DashboardGridId`, `IconName`, `SortOrder`; ship as a numbered migration script |
| **Raised** | 2026-07-29 (four-agent report-DB audit) |
| **Sources** | `docs/microservice-report-database.md` §5, §7.3, §8.1, §12 |

## The problem

The 2026-04-09 release (RoundhousE `1.0.18`, scripts `014`–`019`) rebuilt the three dashboard-config tables and appended `IconName` and `SortOrder`. The `Audit` mirrors gained those columns as **`NOT NULL` with no default** — but only one of the three `_Audit` triggers was updated to populate them.

**Result: any INSERT or UPDATE against `dbo.DashboardConfig` or `dbo.StaffDashboardConfig` fails inside its audit trigger on a NOT NULL violation.** Two of the three documented configuration tiers are physically unwritable.

Both tables being empty has been read as "unused by design" — including in ledger item O13, now closed as a misdiagnosis. It is more accurately a **symptom**: the platform-default tier and the staff tier cannot be populated at all.

## Evidence (verified 2026-07-29, UAT `report` DB)

```sql
SELECT t.name AS trigger_name, LEN(m.definition) AS def_len,
       CASE WHEN m.definition LIKE '%IconName%'        THEN 1 ELSE 0 END AS mentions_iconname,
       CASE WHEN m.definition LIKE '%SortOrder%'       THEN 1 ELSE 0 END AS mentions_sortorder,
       CASE WHEN m.definition LIKE '%DashboardGridId%' THEN 1 ELSE 0 END AS mentions_gridid
FROM sys.triggers t JOIN sys.sql_modules m ON m.object_id = t.object_id
WHERE t.name LIKE '%Config_Audit';
```

| trigger | def_len | IconName | SortOrder | DashboardGridId |
|---|---|---|---|---|
| `DashboardConfig_Audit` | 835 | 0 | 0 | 0 |
| `StaffDashboardConfig_Audit` | 970 | 0 | 0 | 0 |
| `OrganisationDashboardConfig_Audit` | 1232 | 1 | 1 | 1 |

And the mirror columns that the two broken triggers fail to supply:

```sql
SELECT c.name, c.is_nullable, c.default_object_id
FROM sys.columns c JOIN sys.tables t ON t.object_id = c.object_id
JOIN sys.schemas s ON s.schema_id = t.schema_id
WHERE s.name = 'Audit' AND t.name = 'DashboardConfig'
  AND c.name IN ('DashboardGridId','IconName','SortOrder');
```

All three return `is_nullable = 0`, `default_object_id = 0` — NOT NULL, no default.

`DashboardConfig_Audit` inserts only `(AuditAction, DashboardConfigId, TransactionId, Name, IsDeleted, DateCreated, DateUpdated)`.

## Why it has gone unnoticed

Both source tables are empty, so nothing has attempted a write. The organisation tier — which carries all 86 real dashboards — has the fixed trigger and works normally. The defect only surfaces the moment someone tries to use the platform-default or staff tier.

## Impact

- **The platform-default tier is unusable.** This is the tier that would let a newly provisioned organisation inherit a default dashboard set automatically. Today every org must be configured individually (`docs/microservice-report-database.md` §5.3, "No auto-defaulting").
- **The staff tier is unusable on UAT.** Memory notes record staff-tier rows on DEV; if true, DEV's trigger may differ — worth checking before assuming the defect is environment-wide.
- Any plan involving platform-wide default dashboards, or staff-personal dashboards, is blocked until this is fixed.

## Pick-up notes

- Fix by bringing both triggers in line with `OrganisationDashboardConfig_Audit` (1232 chars), which is the known-good reference — read its definition from `sys.sql_modules` and mirror the column list.
- Ship as a numbered RoundhousE script. Note the related release-process gap in **O21**: recent report-DB procedure work was hand-applied and never captured, so confirm this fix lands in the migration history rather than only on UAT.
- Verify on DEV and Test as well — the same 2026-04-09 release ran everywhere, so the regression is likely present in all environments including Prod.
- After fixing, a smoke test is cheap: insert one row into `dbo.DashboardConfig`, confirm the `Audit.DashboardConfig` row appears with all three columns populated, then remove it (via `DashboardConfig_Delete`, the soft-delete path — **not** `_DeleteEntity`, which hard-deletes).
- Report-DB writes are human-run: MCP `execute` is not enabled on any `microservice-*` server.
