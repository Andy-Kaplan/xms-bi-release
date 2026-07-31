# O13 — UAT DashboardGroupMapping empty → dashboards silently invisible **[CLOSED — MISDIAGNOSIS]**

> Detail file for ledger item **O13**. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | **CLOSED 2026-07-29 — misdiagnosis, no work was ever needed** |
| **Area** | Microservice report DB / dashboard visibility |
| **Owner / decides** | Andy |
| **Next action** | None. Retained as a record of the diagnostic error |
| **Sources** | `docs/microservice-report-database.md` §5.3 + §11 + §12, four-agent UAT report-DB audit 2026-07-29 |

## Why this was closed

O13 was raised on 2026-07-02 on the observation that **`dbo.DashboardGroupMapping` on the UAT report DB has 0 rows**, and concluded that dashboards were therefore silently invisible platform-wide, potentially blocking O4 (Group Overview) and O8 (Marge Brut).

**The observation was correct but the table was the wrong one.** There are three parallel group-mapping junctions, one per configuration tier:

| Junction | Joins to | UAT rows | Role |
|---|---|---|---|
| `DashboardGroupMapping` | `DashboardConfig` | **0** | Platform-default tier — `DashboardConfig` is also 0 rows and has never been used |
| `OrganisationDashboardGroupMapping` | `OrganisationDashboardConfig` | **86 live** | **The load-bearing junction** — every real dashboard goes through this |
| `StaffDashboardGroupMapping` | `StaffDashboardConfig` | 0 | Staff tier, unused on UAT |

O13 measured the platform-default junction, which is empty *by design*. The junction that actually governs visibility was already fully populated.

## Evidence (verified 2026-07-29, UAT `report` DB)

```sql
SELECT (SELECT COUNT(*) FROM dbo.OrganisationDashboardGroupMapping WHERE IsDeleted=0) AS live_org_mappings,
       (SELECT MIN(DateCreated) FROM dbo.OrganisationDashboardGroupMapping) AS first_mapping,
       (SELECT MAX(DateCreated) FROM dbo.OrganisationDashboardGroupMapping) AS last_mapping,
       (SELECT COUNT(*) FROM dbo.OrganisationDashboardConfig c
         WHERE c.IsDeleted=0 AND NOT EXISTS (
           SELECT 1 FROM dbo.OrganisationDashboardGroupMapping m
             JOIN dbo.DashboardGroup g ON g.DashboardGroupId=m.DashboardGroupId AND g.IsDeleted=0
            WHERE m.OrganisationDashboardConfigId=c.OrganisationDashboardConfigId)) AS ungrouped_live_configs;
```

| live_org_mappings | first_mapping | last_mapping | ungrouped_live_configs |
|---|---|---|---|
| 86 | 2026-05-18 13:20:59 | 2026-06-08 16:46:14 | **0** |

- All 86 live `OrganisationDashboardConfig` rows have exactly one live mapping. **Zero** dashboards are ungrouped.
- 19 `DashboardGroup` rows: 18 named `All Dashboards` (one per `BiConfig` org, created 2026-05-18 13:20:59) plus one `Development` group for Dirty Sixth.
- `01_populate_uat_dashboard_groups.sql` therefore **ran on 2026-05-18 — six weeks before O13 was raised.** The "fix script not confirmed run" premise was false.

## Consequences for other items

- **O4 (Group Overview)** — was never blocked here. "Group Overview" is live for Nabil Enterprises: grid `5D85AE3A-E74B-4250-84F4-2E2B1801C8A4`, `IconName='CorporateFare'`, group-mapped, 9 live cards + 2 filters, all 10 card-type entitlements present.
- **O8 (Marge Brut)** — was never blocked here. "Marge Brut" is live for Oak & Vine: grid `FA17D12F-1CFB-4D15-87D6-21B22DFA5EE3`, `IconName='Restaurant'`, group-mapped, all 9 designed cards present.

## What remains true, and was folded into the reference doc

The *mechanism* O13 described is real and still a provisioning trap: an `OrganisationDashboardConfig` row with no matching `OrganisationDashboardGroupMapping` row is absent from the `DashboardGroup_Load` payload entirely, with no error. That warning is retained in `docs/microservice-report-database.md` §5.3 and §12 — but as a design trap for new provisioning and environment promotion, **not** as an outstanding UAT data problem.

The same audit found two genuine defects in this area that O13 did not surface, now tracked separately:
- `DashboardGroup_Load` never filters the mapping tables' own `IsDeleted`, so soft-deleting a mapping does not hide a dashboard.
- A group with `OrganisationId IS NULL` leaks one org's dashboard names into every org's navigation.

## Lesson

The platform-default tier (`DashboardConfig` + `DashboardGroupMapping`) being empty is normal and expected. When checking dashboard visibility, always query the tier that matches the config rows in use — for every real dashboard on UAT that is the **organisation** tier.
