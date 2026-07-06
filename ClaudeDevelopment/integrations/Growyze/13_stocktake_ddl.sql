/*
================================================================================
  Growyze Integration - Stocktake DL Table DDL Records
  File:    13_stocktake_ddl.sql
  Date:    2026-03-17
  Target:  [core].[int_growyze001].[GlobalParameters]

  Purpose:
    Adds STAGE_DDL records for the three new stocktake DL tables so that
    sp_CreateIntegrationTables can provision them in new org databases.
    These tables are sourced from the Growyze stocktake API endpoint.

    Tables:
      - DL_STOCKTAKEREPORTS        (report headers with timestamps/discrepancy)
      - DL_STOCKTAKEREPORTDETAIL   (richer headers with products/recipes split)
      - DL_STOCKTAKEREPORTPRODUCTS (product-level count lines — the core data)

  Note: These records already exist in DEV (auto-created by the API endpoint
  config). This script ensures they exist in all environments (Test, UAT, Prod).

  Uses MERGE upsert pattern for idempotent re-runs.
================================================================================
*/

-- ============================================================================
-- DL_STOCKTAKEREPORTS
-- Report headers: one row per parent stocktake report × sub-report.
-- Contains timestamps, status, product counts, total values, and
-- discrepancy data (totalDiscrepancyAmount, periodFrom, periodTo).
-- ============================================================================

MERGE INTO [core].[int_growyze001].[GlobalParameters] AS tgt
USING (VALUES (N'DL_STOCKTAKEREPORTS', N'STAGE_DDL')) AS src (ParameterKey, Category)
ON tgt.ParameterKey = src.ParameterKey AND tgt.Category = src.Category
WHEN MATCHED THEN
    UPDATE SET
        ParameterValue = N'CREATE TABLE [int_growyze001].[DL_STOCKTAKEREPORTS](
    [stockTakeReport_id] [nvarchar](max) NULL,
    [stockTakeReport_name] [nvarchar](max) NULL,
    [stockTakeReport_note] [nvarchar](max) NULL,
    [stockTakeReport_createdAt] [nvarchar](max) NULL,
    [stockTakeReport_completedAt] [nvarchar](max) NULL,
    [stockTakeReport_status] [nvarchar](max) NULL,
    [stockTakeReport_productsCount] [nvarchar](max) NULL,
    [stockTakeReport_totalAmount] [nvarchar](max) NULL,
    [discrepancyReportId] [nvarchar](max) NULL,
    [totalDiscrepancyAmount] [nvarchar](max) NULL,
    [periodFrom] [nvarchar](max) NULL,
    [periodTo] [nvarchar](max) NULL,
    [stockTakeReport_subStockTakeReports_id] [nvarchar](max) NULL,
    [stockTakeReport_subStockTakeReports_name] [nvarchar](max) NULL,
    [stockTakeReport_subStockTakeReports_note] [nvarchar](max) NULL,
    [stockTakeReport_subStockTakeReports_createdAt] [nvarchar](max) NULL,
    [stockTakeReport_subStockTakeReports_completedAt] [nvarchar](max) NULL,
    [stockTakeReport_subStockTakeReports_status] [nvarchar](max) NULL,
    [stockTakeReport_subStockTakeReports_productsCount] [nvarchar](max) NULL,
    [stockTakeReport_subStockTakeReports_subStockTakeReports] [nvarchar](max) NULL,
    [stockTakeReport_subStockTakeReports_totalAmount] [nvarchar](max) NULL,
    [stockTakeReport_organizations] [nvarchar](max) NULL,
    [stockTakeReport_subStockTakeReports_organizations] [nvarchar](max) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL,
    [LOADTS_UTC] [datetime2](7) NULL
);',
        Description    = N'DL_STOCKTAKEREPORTS',
        IsActive       = 1,
        ModifiedBy     = SYSTEM_USER,
        ModifiedDate   = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (ParameterKey, ParameterValue, DataType, Category, Description,
            IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_STOCKTAKEREPORTS',
            N'CREATE TABLE [int_growyze001].[DL_STOCKTAKEREPORTS](
    [stockTakeReport_id] [nvarchar](max) NULL,
    [stockTakeReport_name] [nvarchar](max) NULL,
    [stockTakeReport_note] [nvarchar](max) NULL,
    [stockTakeReport_createdAt] [nvarchar](max) NULL,
    [stockTakeReport_completedAt] [nvarchar](max) NULL,
    [stockTakeReport_status] [nvarchar](max) NULL,
    [stockTakeReport_productsCount] [nvarchar](max) NULL,
    [stockTakeReport_totalAmount] [nvarchar](max) NULL,
    [discrepancyReportId] [nvarchar](max) NULL,
    [totalDiscrepancyAmount] [nvarchar](max) NULL,
    [periodFrom] [nvarchar](max) NULL,
    [periodTo] [nvarchar](max) NULL,
    [stockTakeReport_subStockTakeReports_id] [nvarchar](max) NULL,
    [stockTakeReport_subStockTakeReports_name] [nvarchar](max) NULL,
    [stockTakeReport_subStockTakeReports_note] [nvarchar](max) NULL,
    [stockTakeReport_subStockTakeReports_createdAt] [nvarchar](max) NULL,
    [stockTakeReport_subStockTakeReports_completedAt] [nvarchar](max) NULL,
    [stockTakeReport_subStockTakeReports_status] [nvarchar](max) NULL,
    [stockTakeReport_subStockTakeReports_productsCount] [nvarchar](max) NULL,
    [stockTakeReport_subStockTakeReports_subStockTakeReports] [nvarchar](max) NULL,
    [stockTakeReport_subStockTakeReports_totalAmount] [nvarchar](max) NULL,
    [stockTakeReport_organizations] [nvarchar](max) NULL,
    [stockTakeReport_subStockTakeReports_organizations] [nvarchar](max) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL,
    [LOADTS_UTC] [datetime2](7) NULL
);',
            N'STRING', N'STAGE_DDL', N'DL_STOCKTAKEREPORTS',
            1, SYSTEM_USER, GETDATE(), 1);
GO

-- ============================================================================
-- DL_STOCKTAKEREPORTDETAIL
-- Richer report headers: adds products/recipes value split and template IDs.
-- One row per parent × sub-report (same grain as DL_STOCKTAKEREPORTS).
-- ============================================================================

MERGE INTO [core].[int_growyze001].[GlobalParameters] AS tgt
USING (VALUES (N'DL_STOCKTAKEREPORTDETAIL', N'STAGE_DDL')) AS src (ParameterKey, Category)
ON tgt.ParameterKey = src.ParameterKey AND tgt.Category = src.Category
WHEN MATCHED THEN
    UPDATE SET
        ParameterValue = N'CREATE TABLE [int_growyze001].[DL_STOCKTAKEREPORTDETAIL](
    [id] [nvarchar](max) NULL,
    [name] [nvarchar](max) NULL,
    [note] [nvarchar](max) NULL,
    [createdAt] [nvarchar](max) NULL,
    [completedAt] [nvarchar](max) NULL,
    [status] [nvarchar](max) NULL,
    [totalAmount] [nvarchar](max) NULL,
    [totalAmountProducts] [nvarchar](max) NULL,
    [totalAmountRecipes] [nvarchar](max) NULL,
    [stockTakeTemplateId] [nvarchar](max) NULL,
    [amountByCategories] [nvarchar](max) NULL,
    [lastUpdatedAmountByCategories] [nvarchar](max) NULL,
    [subStockTakeReports_id] [nvarchar](max) NULL,
    [subStockTakeReports_name] [nvarchar](max) NULL,
    [subStockTakeReports_note] [nvarchar](max) NULL,
    [subStockTakeReports_createdAt] [nvarchar](max) NULL,
    [subStockTakeReports_completedAt] [nvarchar](max) NULL,
    [subStockTakeReports_status] [nvarchar](max) NULL,
    [subStockTakeReports_subStockTakeReports] [nvarchar](max) NULL,
    [subStockTakeReports_totalAmount] [nvarchar](max) NULL,
    [subStockTakeReports_totalAmountProducts] [nvarchar](max) NULL,
    [subStockTakeReports_totalAmountRecipes] [nvarchar](max) NULL,
    [subStockTakeReports_stockTakeTemplateId] [nvarchar](max) NULL,
    [subStockTakeReports_amountByCategories] [nvarchar](max) NULL,
    [subStockTakeReports_lastUpdatedAmountByCategories] [nvarchar](max) NULL,
    [organizations] [nvarchar](max) NULL,
    [subStockTakeReports_organizations] [nvarchar](max) NULL,
    [report_id] [nvarchar](max) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL,
    [LOADTS_UTC] [datetime2](7) NULL
);',
        Description    = N'DL_STOCKTAKEREPORTDETAIL',
        IsActive       = 1,
        ModifiedBy     = SYSTEM_USER,
        ModifiedDate   = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (ParameterKey, ParameterValue, DataType, Category, Description,
            IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_STOCKTAKEREPORTDETAIL',
            N'CREATE TABLE [int_growyze001].[DL_STOCKTAKEREPORTDETAIL](
    [id] [nvarchar](max) NULL,
    [name] [nvarchar](max) NULL,
    [note] [nvarchar](max) NULL,
    [createdAt] [nvarchar](max) NULL,
    [completedAt] [nvarchar](max) NULL,
    [status] [nvarchar](max) NULL,
    [totalAmount] [nvarchar](max) NULL,
    [totalAmountProducts] [nvarchar](max) NULL,
    [totalAmountRecipes] [nvarchar](max) NULL,
    [stockTakeTemplateId] [nvarchar](max) NULL,
    [amountByCategories] [nvarchar](max) NULL,
    [lastUpdatedAmountByCategories] [nvarchar](max) NULL,
    [subStockTakeReports_id] [nvarchar](max) NULL,
    [subStockTakeReports_name] [nvarchar](max) NULL,
    [subStockTakeReports_note] [nvarchar](max) NULL,
    [subStockTakeReports_createdAt] [nvarchar](max) NULL,
    [subStockTakeReports_completedAt] [nvarchar](max) NULL,
    [subStockTakeReports_status] [nvarchar](max) NULL,
    [subStockTakeReports_subStockTakeReports] [nvarchar](max) NULL,
    [subStockTakeReports_totalAmount] [nvarchar](max) NULL,
    [subStockTakeReports_totalAmountProducts] [nvarchar](max) NULL,
    [subStockTakeReports_totalAmountRecipes] [nvarchar](max) NULL,
    [subStockTakeReports_stockTakeTemplateId] [nvarchar](max) NULL,
    [subStockTakeReports_amountByCategories] [nvarchar](max) NULL,
    [subStockTakeReports_lastUpdatedAmountByCategories] [nvarchar](max) NULL,
    [organizations] [nvarchar](max) NULL,
    [subStockTakeReports_organizations] [nvarchar](max) NULL,
    [report_id] [nvarchar](max) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL,
    [LOADTS_UTC] [datetime2](7) NULL
);',
            N'STRING', N'STAGE_DDL', N'DL_STOCKTAKEREPORTDETAIL',
            1, SYSTEM_USER, GETDATE(), 1);
GO

-- ============================================================================
-- DL_STOCKTAKEREPORTPRODUCTS
-- Product-level count lines: one row per product per stocktake report.
-- Core operational data: barcode, quantity, price, totalAmount, UOM.
-- ============================================================================

MERGE INTO [core].[int_growyze001].[GlobalParameters] AS tgt
USING (VALUES (N'DL_STOCKTAKEREPORTPRODUCTS', N'STAGE_DDL')) AS src (ParameterKey, Category)
ON tgt.ParameterKey = src.ParameterKey AND tgt.Category = src.Category
WHEN MATCHED THEN
    UPDATE SET
        ParameterValue = N'CREATE TABLE [int_growyze001].[DL_STOCKTAKEREPORTPRODUCTS](
    [barcode] [nvarchar](max) NULL,
    [description] [nvarchar](max) NULL,
    [unit] [nvarchar](max) NULL,
    [size] [nvarchar](max) NULL,
    [measure] [nvarchar](max) NULL,
    [category] [nvarchar](max) NULL,
    [subCategory] [nvarchar](max) NULL,
    [quantity] [nvarchar](max) NULL,
    [price] [nvarchar](max) NULL,
    [totalAmount] [nvarchar](max) NULL,
    [highestPrice] [nvarchar](max) NULL,
    [caseSize] [nvarchar](max) NULL,
    [countedInCase] [nvarchar](max) NULL,
    [report_id] [nvarchar](max) NULL,
    [organizations] [nvarchar](max) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL,
    [LOADTS_UTC] [datetime2](7) NULL
);',
        Description    = N'DL_STOCKTAKEREPORTPRODUCTS',
        IsActive       = 1,
        ModifiedBy     = SYSTEM_USER,
        ModifiedDate   = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (ParameterKey, ParameterValue, DataType, Category, Description,
            IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_STOCKTAKEREPORTPRODUCTS',
            N'CREATE TABLE [int_growyze001].[DL_STOCKTAKEREPORTPRODUCTS](
    [barcode] [nvarchar](max) NULL,
    [description] [nvarchar](max) NULL,
    [unit] [nvarchar](max) NULL,
    [size] [nvarchar](max) NULL,
    [measure] [nvarchar](max) NULL,
    [category] [nvarchar](max) NULL,
    [subCategory] [nvarchar](max) NULL,
    [quantity] [nvarchar](max) NULL,
    [price] [nvarchar](max) NULL,
    [totalAmount] [nvarchar](max) NULL,
    [highestPrice] [nvarchar](max) NULL,
    [caseSize] [nvarchar](max) NULL,
    [countedInCase] [nvarchar](max) NULL,
    [report_id] [nvarchar](max) NULL,
    [organizations] [nvarchar](max) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL,
    [LOADTS_UTC] [datetime2](7) NULL
);',
            N'STRING', N'STAGE_DDL', N'DL_STOCKTAKEREPORTPRODUCTS',
            1, SYSTEM_USER, GETDATE(), 1);
GO
