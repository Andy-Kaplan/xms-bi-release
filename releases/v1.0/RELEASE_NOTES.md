# Release v1.0 — Growyze orphan product fix + F_LINEITEM_15MIN hub validation

**Date:** 2026-05-18
**Author:** Andrew Kaplan
**Rollback Tier:** 2 (data records only)

---

## Summary

Two-layer fix for a Growyze data-quality leak that silently drops product slices from dashboards.

- **Root cause (Growyze-only):** `stage.GRYZ_LINEITEM` LEFT-joins `DL_DISHES` on `(items_posId, organizations)`. When a sale-detail's `items_posId` does not resolve to a dish, `PRODUCT_KEY` is NULL; the Data Vault load hashes NULL into a deterministic SHA256 and writes a `LNK_LINEITEM_PRODUCT` row whose `PRODUCT_HUB_ID` has no matching `HUB_PRODUCT`. Any vis query that joins or groups by product silently drops the affected lines. Confirmed on Dirty Sixth UAT (`20260327_XMS_7B50D717-…`) 2026-05-09: orphan ≈ £1,454.84 NET (~8.4 % of day's £17,405.50 total).
- **Defensive (platform-wide):** future orphan classes from any integration would behave the same way, so the `F_LINEITEM_15MIN` presentation build now validates `LNK_LINEITEM_PRODUCT.PRODUCT_HUB_ID` against `HUB_PRODUCT` and routes unresolvable keys through the existing `-999` "Unknown" sentinel.

## Changes

### Core Platform
- Patched `core.PresentationControl` row `131C3A84-F72D-4A12-B958-BFB519973BE0` (`F_LINEITEM_15MIN`) so the LEFT JOIN to `LNK_LINEITEM_PRODUCT` is wrapped in a derived table that INNER-joins `HUB_PRODUCT`. — `03_core_f_lineitem_15min_hub_validation.sql`
- Master file `8_PresentationControl.sql` amended to match (same commit).

### Integration: Growyze
- Added tier-2 staging step `Growyze LineItem Product Link` that materialises `stage.GRYZ_LINEITEM_PRODUCT` filtered to rows with non-null `PRODUCT_KEY`. — `01_growyze_orphan_staging_fix.sql`
- Re-pointed `LINEITEM_PRODUCT` entity mapping from `GRYZ_LINEITEM` → `GRYZ_LINEITEM_PRODUCT` (DELETE old composite-key row + MERGE new). — `01_growyze_orphan_staging_fix.sql`
- Called `UploadEntityMappings` for `int_growyze001` to regenerate the auto-managed Load steps so they reference the new source table. — `02_growyze_upload_entity_mappings.sql`
- Master files `ClaudeDevelopment/integrations/Growyze/02_staging_tier1.sql` and `04_entity_mappings.sql` amended to match (same commit).

### Microservice Report DB
- No changes.

## Per-Org Steps Required

- [ ] None. All changes are control-table updates that take effect at the next scheduled staging / DV load / presentation rebuild per organisation. No `sp_DeployObjects`, `sp_GenerateDataVaultTables`, or targeted table creation needed.

## Document Sync

- [ ] `docs/data-pipeline.md` — Growyze staging section to mention the new tier-2 `GRYZ_LINEITEM_PRODUCT` step and the orphan-prevention design.
- [ ] `docs/integrations-reference.md` — Growyze entity mapping table: `LINEITEM_PRODUCT` source changed to `GRYZ_LINEITEM_PRODUCT`.
- [ ] `docs/presentation-and-visualisation.md` — `F_LINEITEM_15MIN` build description: note the hub-validated `LNK_LINEITEM_PRODUCT` join.
- [ ] `docs/integration-mappings.html` — Growyze tab: refresh LINEITEM_PRODUCT source-table reference.
- [ ] `ClaudeDevelopment/QUERY_STATUS.md` entry #79 marked **deployed** after Dev → Test → UAT → Prod completes.

## Rollback

**Tier 2 — compensating SQL.** Both changes are control-table edits; no schema or DV-entity changes.

**To revert Section 1 (Growyze staging + entity mapping):**

```sql
-- Restore EntityMapping #13 LINEITEM_PRODUCT to its pre-v1.0 source_table.
DELETE FROM [core].[int_growyze001].[EntityMappings]
WHERE entity_name = N'LINEITEM_PRODUCT'
  AND source_table = N'GRYZ_LINEITEM_PRODUCT';

MERGE INTO [core].[int_growyze001].[EntityMappings] AS tgt
USING (VALUES (N'LINEITEM_PRODUCT', N'GRYZ_LINEITEM')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN NOT MATCHED THEN
    INSERT (entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'LINEITEM_PRODUCT', N'GRYZ_LINEITEM',
            N'[{"name": "SRC_KEY", "hash": 1}, {"name": "PRODUCT_KEY", "hash": 1}]',
            N'["LINEITEM_HUB_ID", "PRODUCT_HUB_ID"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);

-- (Optional) Remove the new staging step; harmless to leave in place.
DELETE FROM [core].[int_growyze001].[StagingControl]
WHERE step_name = N'Growyze LineItem Product Link';

-- Re-call UploadEntityMappings to regenerate Load steps.
EXEC [core].[UploadEntityMappings] @IntegrationSchema = N'int_growyze001';
```

**To revert Section 2 (F_LINEITEM_15MIN patch):**

```sql
DECLARE @new_join NVARCHAR(MAX) = N'LEFT OUTER JOIN
    (SELECT L.[LINEITEM_HUB_ID], L.[PRODUCT_HUB_ID]
     FROM [datavault].[LNK_LINEITEM_PRODUCT] L
     INNER JOIN [datavault].[HUB_PRODUCT] HP ON L.[PRODUCT_HUB_ID] = HP.[HUB_ID]) PROD
ON
LI.[HUB_ID] = PROD.[LINEITEM_HUB_ID]';

DECLARE @old_join NVARCHAR(MAX) = N'LEFT OUTER JOIN
    [datavault].[LNK_LINEITEM_PRODUCT] PROD
ON
LI.[HUB_ID] = PROD.[LINEITEM_HUB_ID]';

UPDATE [core].[PresentationControl]
SET query_sql  = REPLACE(CAST(query_sql AS NVARCHAR(MAX)), @new_join, @old_join),
    updated_at = GETDATE()
WHERE id = N'131C3A84-F72D-4A12-B958-BFB519973BE0';
```

The next presentation rebuild on each org will pick up the reverted SQL.

## Validation Checklist

- [ ] All delta scripts executed without error on target environment
- [ ] `EntityMappings` for `int_growyze001` shows exactly one `LINEITEM_PRODUCT` row, `source_table = GRYZ_LINEITEM_PRODUCT`
- [ ] `StagingControl` for `int_growyze001` contains a tier-2 `Growyze LineItem Product Link` step and an auto-managed Load step for `LINEITEM_PRODUCT` referencing the new source table
- [ ] `core.PresentationControl` row `131C3A84-…` contains the marker substring `INNER JOIN [datavault].[HUB_PRODUCT] HP`
- [ ] After next Growyze staging + DV + presentation rebuild on Dirty Sixth UAT: zero orphan `LNK_LINEITEM_PRODUCT` rows (left-join to `HUB_PRODUCT` returns no NULLs)
- [ ] After next presentation rebuild on Dirty Sixth UAT: previously-dropped slice surfaces under "Unknown" in product-breakdown cards; total `NetSales` KPI is unchanged
- [ ] Spot-check vis cards in frontend (Test/UAT/Prod only) — `NetSales` KPI, `TopProducts` grid, any product-breakdown card on Padel Social and Dirty Sixth dashboards
- [ ] Document sync items above completed
- [ ] `ClaudeDevelopment/QUERY_STATUS.md` entry #79 marked deployed
