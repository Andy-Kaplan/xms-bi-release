# Suggestion System Redesign — Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the over-engineered Python/WPF suggestion prototype with a pure-SQL suggestion system that generates data-driven alert banners (StaticBoxCard) and analysis cards (MarkdownCard) on dashboard pages, starting with inventory/margin.

**Architecture:** Suggestions are standard VisualisationQueries that compute metrics directly from presentation tables at page-load time. A `SuggestionTemplates` config table in `core.core` stores configurable markdown/text templates with `{placeholder}` tokens. Queries join to templates, replace placeholders with computed values, and return results in the card-type's expected column format. If no suggestion condition is met, the query returns zero rows and XMSE-948 hides the card.

**Tech Stack:** SQL Server (Azure Managed Instance), VisualisationQueries framework, StaticBoxCard (order 65) + MarkdownCard (order 64) stored procedures, report DB configuration.

**Jira:** XMSE-948 — MarkdownCard and StaticBoxCard should not render when query returns no data (prerequisite for auto-hide behaviour).

---

## Prerequisites & Context

### What Already Exists (UAT)
- **StaticBoxCard SP** — DeploymentObjects order 65, VisualisationProcedure ID 16. Correctly references `'StaticBoxCard'`.
- **MarkdownCard SP** — DeploymentObjects order 64, VisualisationProcedure ID 17. **Correctly references `'MarkdownCard'` in UAT** (bug only in dev release scripts).
- **Report DB wiring** — Both card types enabled for 9 orgs. KUDU has dataset mappings for `InvMMHeader` (StaticBoxCard + MarkdownCard) and `InvMMHeader2` (StaticBoxCard).
- **Static mockup queries** — `InvMMHeader` and `InvMMHeader2` exist as hardcoded static text in `core.core.VisualisationQueries`. These will be replaced with data-driven queries.

### What Needs Building
1. `core.core.SuggestionTemplates` table — configurable template storage
2. Data-driven VisualisationQueries replacing the static mockups
3. Dev release script fixes (MarkdownCard bug, missing StaticBoxCard)
4. Template seed data for inventory/margin

### Card Output Formats (verified from UAT)

**StaticBoxCard** returns: `severity` (warning/error), `text` (message), `title` (nullable), `dismissable` (True/False)

**MarkdownCard** returns: `markdown` (full markdown string)

### Existing Reference Scripts
- `ClaudeDevelopment/products_without_invitem_recipes.sql` — query for products with no recipe mapping (adapt for missing recipes metric)
- `ClaudeDevelopment/products_with_invitem_recipes.sql` — query for product↔recipe detail

### DataSetName Strategy
Keep existing DataSetNames (`InvMMHeader`, `InvMMHeader2`) to avoid report DB changes. Replace the static queries with data-driven ones in place.

---

## File Structure

All scripts go in `ClaudeDevelopment/suggestions/`:

| File | Purpose |
|---|---|
| `01_suggestion_templates_table.sql` | CREATE TABLE for `core.core.SuggestionTemplates` |
| `02_fix_markdowncard_sp.sql` | Fix MarkdownCard DeploymentObjects record (dev only) |
| `03_add_staticboxcard_sp.sql` | Add StaticBoxCard DeploymentObjects record (dev only) |
| `04_seed_inventory_templates.sql` | MERGE template records for inventory/margin |
| `05_inventory_banner_queries.sql` | Replace `InvMMHeader` + `InvMMHeader2` StaticBoxCard queries |
| `06_inventory_analysis_query.sql` | Replace `InvMMHeader` MarkdownCard query |

---

## Chunk 1: Infrastructure

### Task 1: Create SuggestionTemplates Table

**Files:**
- Create: `ClaudeDevelopment/suggestions/01_suggestion_templates_table.sql`

- [ ] **Step 1: Write the CREATE TABLE script**

```sql
-- =====================================================
-- SuggestionTemplates: Configurable text templates
-- for suggestion banners and analysis cards.
-- Templates store text with {placeholder} tokens that
-- VisualisationQuery SQL replaces with computed values.
-- =====================================================

IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'core' AND TABLE_NAME = 'SuggestionTemplates'
)
BEGIN
    CREATE TABLE [core].[SuggestionTemplates] (
        TemplateID      INT IDENTITY(1,1) PRIMARY KEY,
        TemplateName    NVARCHAR(100)  NOT NULL,
        Category        NVARCHAR(50)   NOT NULL,
        Severity        NVARCHAR(20)   NOT NULL DEFAULT 'INFO',
        OutputType      NVARCHAR(20)   NOT NULL,
        TemplateText    NVARCHAR(MAX)  NOT NULL,
        SortOrder       INT            NOT NULL DEFAULT 50,
        IsActive        BIT            NOT NULL DEFAULT 1,
        CreatedDate     DATETIME2      DEFAULT GETDATE(),
        ModifiedDate    DATETIME2      DEFAULT GETDATE(),

        CONSTRAINT UQ_SuggestionTemplates_Name
            UNIQUE (TemplateName),

        CONSTRAINT CK_SuggestionTemplates_Severity
            CHECK (Severity IN ('INFO', 'WARNING', 'ERROR')),

        CONSTRAINT CK_SuggestionTemplates_OutputType
            CHECK (OutputType IN ('Banner', 'Section'))
    );
END;
```

**Column notes:**
- `TemplateName` — unique key, used by VisualisationQuery SQL to select the template
- `Category` — grouping tag (e.g., 'Inventory', 'Sales', 'Products', 'Survey')
- `Severity` — INFO/WARNING/ERROR; banners map this to `severity` output column
- `OutputType` — 'Banner' (single-line for StaticBoxCard) or 'Section' (markdown block for MarkdownCard)
- `TemplateText` — text with `{placeholder}` tokens, e.g., `'{count} menu items are missing recipes'`
- `SortOrder` — controls order when multiple sections are concatenated into a MarkdownCard

- [ ] **Step 2: Test by running against dev core DB via MCP**

Verify the table is created. If running via MCP (read-only), this script must be executed by the developer. Verify afterward:
```sql
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'core' AND TABLE_NAME = 'SuggestionTemplates'
```

- [ ] **Step 3: Commit**

```bash
git add ClaudeDevelopment/suggestions/01_suggestion_templates_table.sql
git commit -m "feat(suggestions): add SuggestionTemplates table DDL"
```

---

### Task 2: Fix MarkdownCard SP (Dev Release Scripts)

The dev release script `8_Deployment_Objects_Records.sql` has a bug: the MarkdownCard SP references `VisualizationType = 'BarChartCard'` instead of `'MarkdownCard'`, and error messages reference `CustomDataGrid`. This is already fixed in UAT.

**Files:**
- Create: `ClaudeDevelopment/suggestions/02_fix_markdowncard_sp.sql`

- [ ] **Step 1: Write the fix script**

This MERGE updates the existing MarkdownCard DeploymentObjects record with the corrected SP (matching the UAT version):

```sql
-- =====================================================
-- Fix MarkdownCard SP: correct VisualizationType reference
-- Bug: dev script references 'BarChartCard' instead of 'MarkdownCard'
-- This matches the UAT-deployed version.
-- =====================================================

MERGE INTO [core].[DeploymentObjects] AS tgt
USING (VALUES (N'MarkdownCard', N'PROCEDURE')) AS src (ObjectName, ObjectType)
ON tgt.ObjectName = src.ObjectName AND tgt.ObjectType = src.ObjectType
WHEN MATCHED THEN
    UPDATE SET
        CreationScript = N'CREATE OR ALTER PROCEDURE {SCHEMA}.[MarkdownCard]
    @StartDate DATE = NULL,
    @EndDate DATE = NULL,
    @LocationList NVARCHAR(MAX) = NULL,
    @DataSet NVARCHAR(100),
    @Filters NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @ErrorMsg NVARCHAR(500);
    DECLARE @ParameterMappings NVARCHAR(MAX);
    DECLARE @FilterDefinitions NVARCHAR(MAX);
    DECLARE @FilterClause NVARCHAR(MAX);

    SELECT
        @SQL = COALESCE(ExecutionQuery, QueryTemplate),
        @ParameterMappings = ParameterMappings,
        @FilterDefinitions = FilterDefinitions
    FROM [core].[core].[VisualisationQueries]
    WHERE DataSetName = @DataSet
    AND VisualizationType = ''MarkdownCard''
    AND Status = ''LIVE'';

    IF @SQL IS NULL
    BEGIN
        RAISERROR(''DataSet "%s" not found for Markdown or inactive'', 16, 1, @DataSet);
        RETURN;
    END

    BEGIN TRY
        EXEC {SCHEMA}.[BuildDynamicWhereClause]
            @StartDate = @StartDate,
            @EndDate = @EndDate,
            @LocationList = @LocationList,
            @Filters = @Filters,
            @ParameterMappings = @ParameterMappings,
            @FilterDefinitions = @FilterDefinitions,
            @FilterClause = @FilterClause OUTPUT;

        SET @SQL = REPLACE(@SQL, ''@FilterClause'', @FilterClause);
        EXEC sp_executesql @SQL;

    END TRY
    BEGIN CATCH
        SET @ErrorMsg = ''Error executing Markdown for DataSet "'' + @DataSet + ''": '' + ERROR_MESSAGE();
        RAISERROR(@ErrorMsg, 16, 1);
    END CATCH
END;',
        ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN
    -- MarkdownCard always exists in both dev and UAT (added in 8_Deployment_Objects_Records.sql).
    -- This branch is defensive only — if it fires, the record will be created with the correct SP.
    INSERT (ObjectName, ObjectType, CreationScript, ExecutionOrder, Category, IsActive, CreatedDate, ModifiedDate)
    VALUES (N'MarkdownCard', N'PROCEDURE',
        N'CREATE OR ALTER PROCEDURE {SCHEMA}.[MarkdownCard]
    @StartDate DATE = NULL, @EndDate DATE = NULL, @LocationList NVARCHAR(MAX) = NULL,
    @DataSet NVARCHAR(100), @Filters NVARCHAR(MAX) = NULL
AS BEGIN SET NOCOUNT ON;
    DECLARE @SQL NVARCHAR(MAX), @ErrorMsg NVARCHAR(500), @ParameterMappings NVARCHAR(MAX),
            @FilterDefinitions NVARCHAR(MAX), @FilterClause NVARCHAR(MAX);
    SELECT @SQL = COALESCE(ExecutionQuery, QueryTemplate), @ParameterMappings = ParameterMappings,
           @FilterDefinitions = FilterDefinitions
    FROM [core].[core].[VisualisationQueries]
    WHERE DataSetName = @DataSet AND VisualizationType = ''MarkdownCard'' AND Status = ''LIVE'';
    IF @SQL IS NULL BEGIN RAISERROR(''DataSet "%s" not found for Markdown or inactive'', 16, 1, @DataSet); RETURN; END
    BEGIN TRY
        EXEC {SCHEMA}.[BuildDynamicWhereClause] @StartDate=@StartDate, @EndDate=@EndDate,
            @LocationList=@LocationList, @Filters=@Filters, @ParameterMappings=@ParameterMappings,
            @FilterDefinitions=@FilterDefinitions, @FilterClause=@FilterClause OUTPUT;
        SET @SQL = REPLACE(@SQL, ''@FilterClause'', @FilterClause); EXEC sp_executesql @SQL;
    END TRY BEGIN CATCH
        SET @ErrorMsg = ''Error executing Markdown for DataSet "'' + @DataSet + ''": '' + ERROR_MESSAGE();
        RAISERROR(@ErrorMsg, 16, 1);
    END CATCH END;',
        64, N'Visualisation Procedures', 1, GETDATE(), GETDATE());
```

- [ ] **Step 2: Verify the fix matches UAT**

Compare key lines: the WHERE clause should read `VisualizationType = ''MarkdownCard''` and error messages should reference `MarkdownCard`.

- [ ] **Step 3: Commit**

```bash
git add ClaudeDevelopment/suggestions/02_fix_markdowncard_sp.sql
git commit -m "fix(suggestions): correct MarkdownCard SP VisualizationType reference"
```

---

### Task 3: Add StaticBoxCard SP (Dev Release Scripts)

StaticBoxCard exists in UAT (order 65) but is missing from dev release scripts. Add it.

**Files:**
- Create: `ClaudeDevelopment/suggestions/03_add_staticboxcard_sp.sql`

- [ ] **Step 1: Write the DeploymentObjects MERGE**

```sql
-- =====================================================
-- Add StaticBoxCard SP to DeploymentObjects
-- Matches UAT-deployed version (ExecutionOrder 65)
-- =====================================================

MERGE INTO [core].[DeploymentObjects] AS tgt
USING (VALUES (N'StaticBoxCard', N'PROCEDURE')) AS src (ObjectName, ObjectType)
ON tgt.ObjectName = src.ObjectName AND tgt.ObjectType = src.ObjectType
WHEN MATCHED THEN
    UPDATE SET
        CreationScript = N'CREATE OR ALTER PROCEDURE {SCHEMA}.[StaticBoxCard]
    @StartDate DATE = NULL,
    @EndDate DATE = NULL,
    @LocationList NVARCHAR(MAX) = NULL,
    @DataSet NVARCHAR(100),
    @Filters NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @ErrorMsg NVARCHAR(500);
    DECLARE @ParameterMappings NVARCHAR(MAX);
    DECLARE @FilterDefinitions NVARCHAR(MAX);
    DECLARE @FilterClause NVARCHAR(MAX);

    SELECT
        @SQL = COALESCE(ExecutionQuery, QueryTemplate),
        @ParameterMappings = ParameterMappings,
        @FilterDefinitions = FilterDefinitions
    FROM [core].[core].[VisualisationQueries]
    WHERE DataSetName = @DataSet
    AND VisualizationType = ''StaticBoxCard''
    AND Status = ''LIVE'';

    IF @SQL IS NULL
    BEGIN
        RAISERROR(''DataSet "%s" not found for StaticBox or inactive'', 16, 1, @DataSet);
        RETURN;
    END

    BEGIN TRY
        EXEC {SCHEMA}.[BuildDynamicWhereClause]
            @StartDate = @StartDate,
            @EndDate = @EndDate,
            @LocationList = @LocationList,
            @Filters = @Filters,
            @ParameterMappings = @ParameterMappings,
            @FilterDefinitions = @FilterDefinitions,
            @FilterClause = @FilterClause OUTPUT;

        SET @SQL = REPLACE(@SQL, ''@FilterClause'', @FilterClause);
        EXEC sp_executesql @SQL;

    END TRY
    BEGIN CATCH
        SET @ErrorMsg = ''Error executing StaticBox for DataSet "'' + @DataSet + ''": '' + ERROR_MESSAGE();
        RAISERROR(@ErrorMsg, 16, 1);
    END CATCH
END;',
        ExecutionOrder = 65,
        Category = N'Visualisation Procedures',
        IsActive = 1,
        ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (ObjectName, ObjectType, CreationScript, ExecutionOrder, Category, IsActive, CreatedDate, ModifiedDate)
    VALUES (N'StaticBoxCard', N'PROCEDURE',
        N'CREATE OR ALTER PROCEDURE {SCHEMA}.[StaticBoxCard]
    @StartDate DATE = NULL,
    @EndDate DATE = NULL,
    @LocationList NVARCHAR(MAX) = NULL,
    @DataSet NVARCHAR(100),
    @Filters NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @ErrorMsg NVARCHAR(500);
    DECLARE @ParameterMappings NVARCHAR(MAX);
    DECLARE @FilterDefinitions NVARCHAR(MAX);
    DECLARE @FilterClause NVARCHAR(MAX);

    SELECT
        @SQL = COALESCE(ExecutionQuery, QueryTemplate),
        @ParameterMappings = ParameterMappings,
        @FilterDefinitions = FilterDefinitions
    FROM [core].[core].[VisualisationQueries]
    WHERE DataSetName = @DataSet
    AND VisualizationType = ''StaticBoxCard''
    AND Status = ''LIVE'';

    IF @SQL IS NULL
    BEGIN
        RAISERROR(''DataSet "%s" not found for StaticBox or inactive'', 16, 1, @DataSet);
        RETURN;
    END

    BEGIN TRY
        EXEC {SCHEMA}.[BuildDynamicWhereClause]
            @StartDate = @StartDate,
            @EndDate = @EndDate,
            @LocationList = @LocationList,
            @Filters = @Filters,
            @ParameterMappings = @ParameterMappings,
            @FilterDefinitions = @FilterDefinitions,
            @FilterClause = @FilterClause OUTPUT;

        SET @SQL = REPLACE(@SQL, ''@FilterClause'', @FilterClause);
        EXEC sp_executesql @SQL;

    END TRY
    BEGIN CATCH
        SET @ErrorMsg = ''Error executing StaticBox for DataSet "'' + @DataSet + ''": '' + ERROR_MESSAGE();
        RAISERROR(@ErrorMsg, 16, 1);
    END CATCH
END;',
        65, N'Visualisation Procedures', 1, GETDATE(), GETDATE());
```

- [ ] **Step 2: Commit**

```bash
git add ClaudeDevelopment/suggestions/03_add_staticboxcard_sp.sql
git commit -m "feat(suggestions): add StaticBoxCard SP to DeploymentObjects"
```

---

## Chunk 2: Templates & Queries

### Task 4: Seed Inventory/Margin Templates

**Files:**
- Create: `ClaudeDevelopment/suggestions/04_seed_inventory_templates.sql`

- [ ] **Step 1: Write template MERGE statements**

```sql
-- =====================================================
-- Seed SuggestionTemplates for Inventory/Margin category
-- Templates use {placeholder} tokens replaced at runtime
-- =====================================================

-- Banner: Missing recipes alert
MERGE INTO [core].[SuggestionTemplates] AS tgt
USING (VALUES (N'InvMissingRecipesBanner')) AS src (TemplateName)
ON tgt.TemplateName = src.TemplateName
WHEN MATCHED THEN
    UPDATE SET
        Category     = N'Inventory',
        Severity     = N'WARNING',
        OutputType   = N'Banner',
        TemplateText = N'{count} menu items are missing recipes',
        SortOrder    = 10,
        IsActive     = 1,
        ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (TemplateName, Category, Severity, OutputType, TemplateText, SortOrder, IsActive)
    VALUES (N'InvMissingRecipesBanner', N'Inventory', N'WARNING', N'Banner',
            N'{count} menu items are missing recipes', 10, 1);

-- Banner: High variance alert
MERGE INTO [core].[SuggestionTemplates] AS tgt
USING (VALUES (N'InvHighVarianceBanner')) AS src (TemplateName)
ON tgt.TemplateName = src.TemplateName
WHEN MATCHED THEN
    UPDATE SET
        Category     = N'Inventory',
        Severity     = N'ERROR',
        OutputType   = N'Banner',
        TemplateText = N'Inventory variance is significantly higher than expected',
        SortOrder    = 20,
        IsActive     = 1,
        ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (TemplateName, Category, Severity, OutputType, TemplateText, SortOrder, IsActive)
    VALUES (N'InvHighVarianceBanner', N'Inventory', N'ERROR', N'Banner',
            N'Inventory variance is significantly higher than expected', 20, 1);

-- Card section: Missing Recipes
MERGE INTO [core].[SuggestionTemplates] AS tgt
USING (VALUES (N'InvMissingRecipesSection')) AS src (TemplateName)
ON tgt.TemplateName = src.TemplateName
WHEN MATCHED THEN
    UPDATE SET
        Category     = N'Inventory',
        Severity     = N'WARNING',
        OutputType   = N'Section',
        TemplateText = N'## Missing Recipes
**Status:** {missing_recipes_status}',
        SortOrder    = 10,
        IsActive     = 1,
        ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (TemplateName, Category, Severity, OutputType, TemplateText, SortOrder, IsActive)
    VALUES (N'InvMissingRecipesSection', N'Inventory', N'WARNING', N'Section',
            N'## Missing Recipes
**Status:** {missing_recipes_status}', 10, 1);

-- Card section: Inventory Health
MERGE INTO [core].[SuggestionTemplates] AS tgt
USING (VALUES (N'InvHealthSection')) AS src (TemplateName)
ON tgt.TemplateName = src.TemplateName
WHEN MATCHED THEN
    UPDATE SET
        Category     = N'Inventory',
        Severity     = N'ERROR',
        OutputType   = N'Section',
        TemplateText = N'## Inventory Health
**Overall Status:** {variance_status}

{variance_explanation}',
        SortOrder    = 20,
        IsActive     = 1,
        ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (TemplateName, Category, Severity, OutputType, TemplateText, SortOrder, IsActive)
    VALUES (N'InvHealthSection', N'Inventory', N'ERROR', N'Section',
            N'## Inventory Health
**Overall Status:** {variance_status}

{variance_explanation}', 20, 1);

-- Card section: Key Metrics
MERGE INTO [core].[SuggestionTemplates] AS tgt
USING (VALUES (N'InvKeyMetricsSection')) AS src (TemplateName)
ON tgt.TemplateName = src.TemplateName
WHEN MATCHED THEN
    UPDATE SET
        Category     = N'Inventory',
        Severity     = N'INFO',
        OutputType   = N'Section',
        TemplateText = N'### Key Metrics
- **Inventory Variance:** {variance_pct}
- **Missing Recipes:** {missing_count}',
        SortOrder    = 30,
        IsActive     = 1,
        ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (TemplateName, Category, Severity, OutputType, TemplateText, SortOrder, IsActive)
    VALUES (N'InvKeyMetricsSection', N'Inventory', N'INFO', N'Section',
            N'### Key Metrics
- **Inventory Variance:** {variance_pct}
- **Missing Recipes:** {missing_count}', 30, 1);

-- Card section: Recommendation
MERGE INTO [core].[SuggestionTemplates] AS tgt
USING (VALUES (N'InvRecommendationSection')) AS src (TemplateName)
ON tgt.TemplateName = src.TemplateName
WHEN MATCHED THEN
    UPDATE SET
        Category     = N'Inventory',
        Severity     = N'INFO',
        OutputType   = N'Section',
        TemplateText = N'### Recommendation

{recommendation_text}',
        SortOrder    = 40,
        IsActive     = 1,
        ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (TemplateName, Category, Severity, OutputType, TemplateText, SortOrder, IsActive)
    VALUES (N'InvRecommendationSection', N'Inventory', N'INFO', N'Section',
            N'### Recommendation

{recommendation_text}', 40, 1);
```

- [ ] **Step 2: Verify templates via MCP**

```sql
SELECT TemplateName, Category, Severity, OutputType, SortOrder
FROM core.core.SuggestionTemplates
WHERE Category = 'Inventory'
ORDER BY SortOrder
```

Expected: 6 rows (2 Banner + 4 Section). Note: Banners and Sections share SortOrder values (10, 20) — SortOrder only matters within the same OutputType.

- [ ] **Step 3: Commit**

```bash
git add ClaudeDevelopment/suggestions/04_seed_inventory_templates.sql
git commit -m "feat(suggestions): seed inventory/margin suggestion templates"
```

---

### Task 5: Create Inventory Banner Queries (StaticBoxCard)

Replace the hardcoded `InvMMHeader` and `InvMMHeader2` StaticBoxCard queries with data-driven versions.

**Files:**
- Create: `ClaudeDevelopment/suggestions/05_inventory_banner_queries.sql`

**Important:** The missing-recipes metric requires joining to Data Vault link tables (`LNK_INVITEM_OCCASION_PRODUCT` and/or `LNK_INVITEM_LOCATION_OCCASION_PRODUCT`). These exist in the `datavault` schema of each client DB. The reference script `ClaudeDevelopment/products_without_invitem_recipes.sql` shows the exact join path. **This metric is inherently org-wide** — recipes are a product property, not location/date-specific — so the missing-recipes banner does NOT use `@FilterClause`.

The variance metric uses `F_INV_COUNTS_DAY` directly and IS filter-aware.

- [ ] **Step 1: Investigate the missing-recipes join path**

Read `ClaudeDevelopment/products_without_invitem_recipes.sql` to determine:
- The exact link table(s) and column names used to identify products without recipe mappings
- Whether `LNK_INVITEM_OCCASION_PRODUCT` or `LNK_INVITEM_LOCATION_OCCASION_PRODUCT` is the correct join target (the reference script uses both via two NOT EXISTS checks)
- Whether to filter out deleted products (`BOTTOM_IS_DELETED`) — D_PRODUCT includes deleted products, and the reference script filters them

Also verify `F_INV_COUNTS_DAY` columns for variance calculation:
```sql
SELECT TOP 10 VARIANCE, THEO_USAGE, ACTUAL_USAGE
FROM [{clientDB}].[presentation].[F_INV_COUNTS_DAY]
```

- [ ] **Step 2: Write the banner queries**

The InvMMHeader query uses a placeholder join that MUST be replaced with the verified path from Step 1. The InvMMHeader2 variance query is ready to use.

```sql
-- =====================================================
-- Replace InvMMHeader (StaticBoxCard) — Missing Recipes Banner
-- Returns a row ONLY when missing recipe count > 0.
-- This metric is org-wide (no @FilterClause) because
-- recipe mappings are a product property, not location/date.
-- =====================================================

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (
    N'InvMMHeader', N'StaticBoxCard', 1, N'LIVE'
)) AS src (DataSetName, VisualizationType, [Version], [Status])
ON  tgt.DataSetName       = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.[Version]         = src.[Version]
WHEN MATCHED THEN
    UPDATE SET
        QueryTemplate = N'
WITH missing AS (
    -- IMPLEMENT: Replace with verified join from products_without_invitem_recipes.sql
    -- Reference tables: [datavault].[LNK_INVITEM_OCCASION_PRODUCT],
    --                   [datavault].[LNK_INVITEM_LOCATION_OCCASION_PRODUCT]
    -- Must count leaf products (D_PRODUCT.BOTTOM_HUB_ID) with no recipe link.
    SELECT COUNT(*) AS missing_count
    FROM [presentation].[D_PRODUCT] p
    WHERE NOT EXISTS (
        SELECT 1 FROM [datavault].[LNK_INVITEM_OCCASION_PRODUCT] lpi
        WHERE lpi.PRODUCT_HUB_ID = p.BOTTOM_HUB_ID
    )
    AND NOT EXISTS (
        SELECT 1 FROM [datavault].[LNK_INVITEM_LOCATION_OCCASION_PRODUCT] llpi
        WHERE llpi.PRODUCT_HUB_ID = p.BOTTOM_HUB_ID
    )
)
SELECT
    t.Severity AS severity,
    REPLACE(t.TemplateText, ''{count}'', CAST(m.missing_count AS NVARCHAR(20))) AS text,
    NULL AS title,
    ''True'' AS dismissable
FROM missing m
CROSS JOIN [core].[core].[SuggestionTemplates] t
WHERE t.TemplateName = ''InvMissingRecipesBanner''
AND t.IsActive = 1
AND m.missing_count > 0',
        ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
        FilterDefinitions = N'{}',
        ExecutionQuery = NULL,
        Description = N'Alert banner: count of menu items without recipe mappings (org-wide)',
        ModifiedDate = GETDATE(),
        ModifiedBy = N'suggestion-system-redesign',
        [Status] = N'LIVE'
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, [Version], [Status],
            QueryTemplate, ParameterMappings, FilterDefinitions,
            OutputDefinitions, Description, CreatedBy, ModifiedBy)
    VALUES (N'InvMMHeader', N'StaticBoxCard', 1, N'LIVE',
            N'
WITH missing AS (
    SELECT COUNT(*) AS missing_count
    FROM [presentation].[D_PRODUCT] p
    WHERE NOT EXISTS (
        SELECT 1 FROM [datavault].[LNK_INVITEM_OCCASION_PRODUCT] lpi
        WHERE lpi.PRODUCT_HUB_ID = p.BOTTOM_HUB_ID
    )
    AND NOT EXISTS (
        SELECT 1 FROM [datavault].[LNK_INVITEM_LOCATION_OCCASION_PRODUCT] llpi
        WHERE llpi.PRODUCT_HUB_ID = p.BOTTOM_HUB_ID
    )
)
SELECT
    t.Severity AS severity,
    REPLACE(t.TemplateText, ''{count}'', CAST(m.missing_count AS NVARCHAR(20))) AS text,
    NULL AS title,
    ''True'' AS dismissable
FROM missing m
CROSS JOIN [core].[core].[SuggestionTemplates] t
WHERE t.TemplateName = ''InvMissingRecipesBanner''
AND t.IsActive = 1
AND m.missing_count > 0',
            N'{"LocationList": "", "StartDate": "", "EndDate": ""}',
            N'{}', N'{}',
            N'Alert banner: missing recipes count (org-wide)',
            N'suggestion-system-redesign', N'suggestion-system-redesign');

-- =====================================================
-- Replace InvMMHeader2 (StaticBoxCard) — High Variance Banner
-- Returns a row ONLY when overall variance % > 15%.
-- Filter-aware via @FilterClause on F_INV_COUNTS_DAY.
-- =====================================================

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (
    N'InvMMHeader2', N'StaticBoxCard', 1, N'LIVE'
)) AS src (DataSetName, VisualizationType, [Version], [Status])
ON  tgt.DataSetName       = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.[Version]         = src.[Version]
WHEN MATCHED THEN
    UPDATE SET
        QueryTemplate = N'
WITH variance_calc AS (
    SELECT
        CASE WHEN SUM(ABS(THEO_USAGE)) > 0
             THEN SUM(ABS(VARIANCE)) / SUM(ABS(THEO_USAGE)) * 100
             ELSE 0
        END AS variance_pct
    FROM [presentation].[F_INV_COUNTS_DAY]
    WHERE 1=1
    @FilterClause
)
SELECT
    t.Severity AS severity,
    t.TemplateText AS text,
    NULL AS title,
    ''True'' AS dismissable
FROM variance_calc v
CROSS JOIN [core].[core].[SuggestionTemplates] t
WHERE t.TemplateName = ''InvHighVarianceBanner''
AND t.IsActive = 1
AND v.variance_pct > 15',
        ParameterMappings = N'{
  "LocationList": "LOCATION_HUB_ID",
  "StartDate": "COUNT_DATE",
  "EndDate": "COUNT_DATE"
}',
        FilterDefinitions = N'{
  "Locations": {
    "column": "LOCATION_HUB_ID",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
        ExecutionQuery = NULL,
        Description = N'Alert banner: inventory variance exceeds 15% threshold',
        ModifiedDate = GETDATE(),
        ModifiedBy = N'suggestion-system-redesign',
        [Status] = N'LIVE'
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, [Version], [Status],
            QueryTemplate, ParameterMappings, FilterDefinitions,
            OutputDefinitions, Description, CreatedBy, ModifiedBy)
    VALUES (N'InvMMHeader2', N'StaticBoxCard', 1, N'LIVE',
            N'
WITH variance_calc AS (
    SELECT
        CASE WHEN SUM(ABS(THEO_USAGE)) > 0
             THEN SUM(ABS(VARIANCE)) / SUM(ABS(THEO_USAGE)) * 100
             ELSE 0
        END AS variance_pct
    FROM [presentation].[F_INV_COUNTS_DAY]
    WHERE 1=1
    @FilterClause
)
SELECT
    t.Severity AS severity,
    t.TemplateText AS text,
    NULL AS title,
    ''True'' AS dismissable
FROM variance_calc v
CROSS JOIN [core].[core].[SuggestionTemplates] t
WHERE t.TemplateName = ''InvHighVarianceBanner''
AND t.IsActive = 1
AND v.variance_pct > 15',
            N'{"LocationList": "LOCATION_HUB_ID", "StartDate": "COUNT_DATE", "EndDate": "COUNT_DATE"}',
            N'{"Locations": {"column": "LOCATION_HUB_ID", "type": "IN", "dataType": "VARCHAR"}}',
            N'{}',
            N'Alert banner: high inventory variance',
            N'suggestion-system-redesign', N'suggestion-system-redesign');
```

- [ ] **Step 3: Test the variance banner query via MCP**

Strip comments, add three-part naming for the client DB, run from core:
```sql
WITH variance_calc AS (
    SELECT
        CASE WHEN SUM(ABS(THEO_USAGE)) > 0
             THEN SUM(ABS(VARIANCE)) / SUM(ABS(THEO_USAGE)) * 100
             ELSE 0
        END AS variance_pct
    FROM [{clientDB}].[presentation].[F_INV_COUNTS_DAY]
)
SELECT
    'error' AS severity,
    'Inventory variance is significantly higher than expected' AS text,
    NULL AS title,
    'True' AS dismissable
FROM variance_calc v
WHERE v.variance_pct > 15
```

Expected: Returns one row if variance > 15%, zero rows otherwise.

- [ ] **Step 4: Test the missing recipes banner query via MCP**

Adapt based on the join path verified in Step 1. Verify it returns a row with the correct count when recipes are missing, and zero rows when all products have recipes.

- [ ] **Step 5: Commit**

```bash
git add ClaudeDevelopment/suggestions/05_inventory_banner_queries.sql
git commit -m "feat(suggestions): data-driven inventory banner queries"
```

---

### Task 6: Create Inventory Health Analysis Query (MarkdownCard)

Replace the hardcoded `InvMMHeader` MarkdownCard query with a data-driven version that pulls templates from `SuggestionTemplates` and fills in computed metrics.

**Files:**
- Create: `ClaudeDevelopment/suggestions/06_inventory_analysis_query.sql`

- [ ] **Step 1: Write the MarkdownCard query**

This query:
1. Computes metrics (missing recipe count, variance %)
2. Fetches Section templates from SuggestionTemplates
3. Conditionally includes sections based on metric thresholds
4. Replaces `{placeholder}` tokens with computed values
5. Concatenates sections into a single markdown string
6. Returns zero rows if no conditions are met

The query SQL is stored as `@QuerySQL` variable for reuse in both MERGE branches:

```sql
-- =====================================================
-- Replace InvMMHeader (MarkdownCard) — Inventory Health Analysis
-- Computes metrics from presentation tables, merges with
-- templates from SuggestionTemplates, returns markdown.
-- Note: Missing recipes subquery is org-wide (no @FilterClause);
-- variance subquery IS filter-aware. The HAVING COUNT(*) > 0
-- ensures zero rows returned when no conditions are met.
-- =====================================================

DECLARE @QuerySQL NVARCHAR(MAX) = N'
WITH metrics AS (
    SELECT
        -- Missing recipes count (org-wide — recipes are not location/date-specific)
        -- IMPLEMENT: Verify join path against products_without_invitem_recipes.sql
        (SELECT COUNT(*)
         FROM [presentation].[D_PRODUCT] p
         WHERE NOT EXISTS (
             SELECT 1 FROM [datavault].[LNK_INVITEM_OCCASION_PRODUCT] lpi
             WHERE lpi.PRODUCT_HUB_ID = p.BOTTOM_HUB_ID
         )
         AND NOT EXISTS (
             SELECT 1 FROM [datavault].[LNK_INVITEM_LOCATION_OCCASION_PRODUCT] llpi
             WHERE llpi.PRODUCT_HUB_ID = p.BOTTOM_HUB_ID
         )
        ) AS missing_count,

        -- Inventory variance % (filter-aware)
        (SELECT
            CASE WHEN SUM(ABS(THEO_USAGE)) > 0
                 THEN SUM(ABS(VARIANCE)) / SUM(ABS(THEO_USAGE)) * 100
                 ELSE 0
            END
         FROM [presentation].[F_INV_COUNTS_DAY]
         WHERE 1=1
         @FilterClause
        ) AS variance_pct
),
rendered_sections AS (
    SELECT
        t.SortOrder,
        CASE t.TemplateName
            WHEN ''InvMissingRecipesSection'' THEN
                REPLACE(t.TemplateText,
                    ''{missing_recipes_status}'',
                    CASE WHEN m.missing_count > 0
                         THEN ''There are '' + CAST(m.missing_count AS NVARCHAR(20)) + '' menu items which don'' + CHAR(39) + ''t have recipes''
                         ELSE ''All menu items have recipes configured''
                    END)

            WHEN ''InvHealthSection'' THEN
                REPLACE(REPLACE(t.TemplateText,
                    ''{variance_status}'',
                    CASE WHEN m.variance_pct > 15 THEN ''Higher than expected variance''
                         WHEN m.variance_pct > 10 THEN ''Moderate variance''
                         ELSE ''Variance within acceptable range''
                    END),
                    ''{variance_explanation}'',
                    CASE WHEN m.missing_count > 50 AND m.variance_pct > 15
                         THEN ''This variance is likely due to a high number of missing recipes.''
                         WHEN m.variance_pct > 15
                         THEN ''Consider investigating the top variance items for root causes.''
                         ELSE ''''
                    END)

            WHEN ''InvKeyMetricsSection'' THEN
                REPLACE(REPLACE(t.TemplateText,
                    ''{variance_pct}'',
                    CASE WHEN m.variance_pct > 15 THEN ''> 15%''
                         ELSE CAST(CAST(m.variance_pct AS DECIMAL(5,1)) AS NVARCHAR(10)) + ''%''
                    END),
                    ''{missing_count}'',
                    CAST(m.missing_count AS NVARCHAR(20)))

            WHEN ''InvRecommendationSection'' THEN
                REPLACE(t.TemplateText,
                    ''{recommendation_text}'',
                    CASE WHEN m.missing_count > 50 AND m.variance_pct > 15
                         THEN ''Consider reviewing inventory management practices to address the missing recipes alert and ensure optimal system configuration.''
                         WHEN m.missing_count > 0
                         THEN ''Review the missing recipes list and configure recipe mappings to improve inventory tracking accuracy.''
                         WHEN m.variance_pct > 15
                         THEN ''Investigate the top variance items and review count procedures to reduce discrepancies.''
                         ELSE ''Inventory health is within acceptable parameters. Continue monitoring.''
                    END)
        END AS rendered_text
    FROM [core].[core].[SuggestionTemplates] t
    CROSS JOIN metrics m
    WHERE t.Category = ''Inventory''
    AND t.OutputType = ''Section''
    AND t.IsActive = 1
    AND (m.missing_count > 0 OR m.variance_pct > 10)
)
SELECT
    STRING_AGG(rendered_text, CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10))
        WITHIN GROUP (ORDER BY SortOrder)
    AS markdown
FROM rendered_sections
WHERE rendered_text IS NOT NULL
HAVING COUNT(*) > 0';

DECLARE @ParamMappings NVARCHAR(MAX) = N'{"LocationList": "LOCATION_HUB_ID", "StartDate": "COUNT_DATE", "EndDate": "COUNT_DATE"}';
DECLARE @FilterDefs NVARCHAR(MAX) = N'{"Locations": {"column": "LOCATION_HUB_ID", "type": "IN", "dataType": "VARCHAR"}}';

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (
    N'InvMMHeader', N'MarkdownCard', 1, N'LIVE'
)) AS src (DataSetName, VisualizationType, [Version], [Status])
ON  tgt.DataSetName       = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.[Version]         = src.[Version]
WHEN MATCHED THEN
    UPDATE SET
        QueryTemplate     = @QuerySQL,
        ParameterMappings = @ParamMappings,
        FilterDefinitions = @FilterDefs,
        ExecutionQuery    = NULL,
        Description       = N'Inventory health analysis card: missing recipes, variance, recommendations',
        ModifiedDate      = GETDATE(),
        ModifiedBy        = N'suggestion-system-redesign',
        [Status]          = N'LIVE'
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, [Version], [Status],
            QueryTemplate, ParameterMappings, FilterDefinitions,
            OutputDefinitions, Description, CreatedBy, ModifiedBy)
    VALUES (N'InvMMHeader', N'MarkdownCard', 1, N'LIVE',
            @QuerySQL, @ParamMappings, @FilterDefs, N'{}',
            N'Inventory health analysis card',
            N'suggestion-system-redesign', N'suggestion-system-redesign');
```

**Note on quote escaping:** The `DECLARE @QuerySQL = N'...'` uses double-quote escaping (`''` → `'`). The variable value is stored directly into QueryTemplate — no additional escaping layer. When `sp_executesql` runs the QueryTemplate, the single quotes are correct SQL string delimiters. The implementing agent should test the extracted query via MCP before inserting to verify quoting is correct.

- [ ] **Step 2: Test the analysis query via MCP**

Strip comments, add three-part naming, run from core. Verify:
- Returns a single `markdown` column
- Markdown contains the expected section headings
- Placeholder tokens are fully replaced (no `{...}` in output)
- Returns zero rows when no conditions are met

- [ ] **Step 3: Verify filter behaviour**

Run the query with a location filter applied. Confirm the variance metrics change when filtering to a single location.

- [ ] **Step 4: Commit**

```bash
git add ClaudeDevelopment/suggestions/06_inventory_analysis_query.sql
git commit -m "feat(suggestions): data-driven inventory health MarkdownCard query"
```

---

## Chunk 3: Deployment & Documentation

### Task 7: Update QUERY_STATUS.md

- [ ] **Step 1: Add entries for all new scripts**

Add entries to `ClaudeDevelopment/QUERY_STATUS.md` for scripts 01-06, recording purpose, test results, and deployment status.

- [ ] **Step 2: Commit**

```bash
git add ClaudeDevelopment/QUERY_STATUS.md
git commit -m "docs: add suggestion system scripts to QUERY_STATUS"
```

---

### Task 8: Report DB Configuration (Dev Environment)

If deploying to dev (where report DB has no StaticBoxCard/MarkdownCard config), the following records are needed. If deploying to UAT (where config already exists for KUDU), this task may only require updating VisualisationDataSetMap entries.

**Files:**
- Create: `ClaudeDevelopment/suggestions/07_report_db_config.sql` (if needed)

- [ ] **Step 1: Check current report DB state**

Query the target environment's report DB to determine what already exists:
```sql
SELECT vp.ProcedureName, vc.OrganisationId, vdsm.DataSet
FROM dbo.VisualisationProcedure vp
LEFT JOIN dbo.VisualisationConfig vc ON vp.VisualisationId = vc.VisualisationId
LEFT JOIN dbo.VisualisationDataSetMap vdsm ON vc.VisualisationConfigId = vdsm.VisualisationConfigId
WHERE vp.ProcedureName IN ('core.StaticBoxCard', 'core.MarkdownCard')
```

- [ ] **Step 2: Write INSERT statements for any missing records**

Follow the pattern from `ClaudeDevelopment/Deploy/growyze_report_db_dev.sql`. Required records:
- `VisualisationProcedure` — StaticBoxCard (if missing)
- `VisualisationProcedure` — MarkdownCard (if missing)
- `VisualisationConfig` — enable both card types for target org(s)
- `VisualisationDataSetMap` — map `InvMMHeader` to both StaticBoxCard and MarkdownCard configs, `InvMMHeader2` to StaticBoxCard config
- `DashboardGrid` / `DashboardItem` — place cards on the Margin Management dashboard page

Remember report DB INSERT rules:
- `TransactionId` is IDENTITY — never include
- `IsDeleted` has no DEFAULT — must pass `0`
- PK columns have `DEFAULT NEWSEQUENTIALID()` — can omit unless needed for references

- [ ] **Step 3: Test end-to-end**

After deploying all scripts:
1. Open the dashboard and navigate to Margin Management
2. Verify alert banners appear (or don't appear) based on actual data
3. Verify the analysis card renders markdown correctly
4. Apply a location filter and confirm the suggestions update
5. Dismiss a banner and confirm it reappears on page refresh

- [ ] **Step 4: Commit**

```bash
git add ClaudeDevelopment/suggestions/07_report_db_config.sql
git commit -m "feat(suggestions): report DB configuration for suggestion cards"
```

---

## Deployment Order

Scripts must be deployed in this order:

```
01_suggestion_templates_table.sql     → Core DB (creates table)
02_fix_markdowncard_sp.sql            → Core DB (fixes DeploymentObjects)
03_add_staticboxcard_sp.sql           → Core DB (adds DeploymentObjects)
   ↓
   sp_DeployObjects                   → Propagates SPs to all client DBs
   ↓
04_seed_inventory_templates.sql       → Core DB (seeds templates)
05_inventory_banner_queries.sql       → Core DB (replaces VisualisationQueries)
06_inventory_analysis_query.sql       → Core DB (replaces VisualisationQueries)
   ↓
07_report_db_config.sql               → Report DB (if needed per environment)
```

## Dependencies

| Dependency | Status | Impact |
|---|---|---|
| XMSE-948: Hide empty cards | Open | Without this, suggestion cards show as blank boxes when no conditions are met. Workaround: return a "no issues detected" message instead of zero rows. |
| StaticBoxCard SP in UAT | Done | Already deployed (order 65) |
| MarkdownCard SP in UAT | Done | Already deployed and fixed |
| Report DB config in UAT | Partial | KUDU has dataset mappings; other orgs need VisualisationDataSetMap entries |

## Extending to Other Categories

To add suggestions for a new category (e.g., Sales):

1. **Add templates** — MERGE new records into `SuggestionTemplates` with `Category = 'Sales'`
2. **Create VisualisationQueries** — Write queries that compute sales metrics from presentation tables (`F_LINEITEM_15MIN`, `F_PRODUCT_MARGIN_DAY`), join to templates, return StaticBoxCard/MarkdownCard format
3. **Wire report DB** — Add `VisualisationDataSetMap` entries and `DashboardItem` placement for the target dashboard page(s)

The framework (table, SPs, card types) is already in place — extending is purely data/config.

## What Happens to the Old Prototype

The Python/WPF code in `XMSBI_Suggestion_Generator/` is superseded by this redesign. The existing 4 suggestion tables in `7_Dynamic Suggestion Tables.sql` (`ActionInferenceRules`, `DescriptionRules`, `DescriptionTemplates`, `MetricDefinitions`) remain in place but are unused — they can be retired in a future release script update.
