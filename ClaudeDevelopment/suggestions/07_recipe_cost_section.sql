-- =============================================================================
-- Add dynamic Recipe Cost / POS integration check to MarkdownCard
-- =============================================================================
-- Adds a new section to the InvMMHeader MarkdownCard that dynamically detects
-- when an organisation has inventory count data but no recipe usage (SALE_QTY)
-- flowing, indicating the inventory provider is not connected to a POS system.
--
-- Changes:
--   1. New SuggestionTemplate: InvRecipeCostSection
--   2. Updated SuggestionTemplate: InvKeyMetricsSection (adds recipe cost line)
--   3. Updated InvMMHeader MarkdownCard query (new metric + rendering)
-- =============================================================================

-- =====================================================
-- 1. New template: Recipe Cost section
-- =====================================================
MERGE INTO [core].[SuggestionTemplates] AS tgt
USING (VALUES (N'InvRecipeCostSection')) AS src (TemplateName)
ON tgt.TemplateName = src.TemplateName
WHEN MATCHED THEN
    UPDATE SET
        Category     = N'Inventory',
        Severity     = N'WARNING',
        OutputType   = N'Section',
        TemplateText = N'## Recipe Costs
**Status:** {recipe_cost_status}

{recipe_cost_explanation}',
        SortOrder    = 25,
        IsActive     = 1,
        ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (TemplateName, Category, Severity, OutputType, TemplateText, SortOrder, IsActive)
    VALUES (N'InvRecipeCostSection', N'Inventory', N'WARNING', N'Section',
            N'## Recipe Costs
**Status:** {recipe_cost_status}

{recipe_cost_explanation}', 25, 1);

-- =====================================================
-- 2. Updated template: Key Metrics (add recipe line)
-- =====================================================
MERGE INTO [core].[SuggestionTemplates] AS tgt
USING (VALUES (N'InvKeyMetricsSection')) AS src (TemplateName)
ON tgt.TemplateName = src.TemplateName
WHEN MATCHED THEN
    UPDATE SET
        TemplateText = N'### Key Metrics
- **Inventory Variance:** {variance_pct}
- **Missing Recipes:** {missing_count}
- **Recipe Costs:** {recipe_cost_brief}',
        ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (TemplateName, Category, Severity, OutputType, TemplateText, SortOrder, IsActive)
    VALUES (N'InvKeyMetricsSection', N'Inventory', N'INFO', N'Section',
            N'### Key Metrics
- **Inventory Variance:** {variance_pct}
- **Missing Recipes:** {missing_count}
- **Recipe Costs:** {recipe_cost_brief}', 30, 1);

-- =====================================================
-- 3. Updated InvMMHeader MarkdownCard query
-- =====================================================
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'InvMMHeader', N'MarkdownCard')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN
    UPDATE SET
        QueryTemplate = N'
WITH metrics AS (
    SELECT
        (SELECT COUNT(DISTINCT p.BOTTOM_HUB_ID)
         FROM [presentation].[D_PRODUCT] p
         WHERE (p.BOTTOM_IS_DELETED IS NULL OR p.BOTTOM_IS_DELETED = 0)
         AND NOT EXISTS (
             SELECT 1 FROM [datavault].[LNK_INVITEM_OCCASION_PRODUCT] lpi
             WHERE lpi.PRODUCT_HUB_ID = p.BOTTOM_HUB_ID
         )
         AND NOT EXISTS (
             SELECT 1 FROM [datavault].[LNK_INVITEM_LOCATION_OCCASION_PRODUCT] llpi
             WHERE llpi.PRODUCT_HUB_ID = p.BOTTOM_HUB_ID
         )
        ) AS missing_count,

        (SELECT
            CASE WHEN SUM(ABS(THEO_USAGE)) > 0
                 THEN SUM(ABS(VARIANCE)) / SUM(ABS(THEO_USAGE)) * 100
                 ELSE 0
            END
         FROM [presentation].[F_INV_COUNTS_DAY]
         WHERE 1=1
         @FilterClause
        ) AS variance_pct,

        (SELECT
            CASE WHEN COUNT(*) > 0
                      AND ISNULL(SUM(ABS(ISNULL(SALE_QTY, 0))), 0) = 0
                 THEN 1
                 ELSE 0
            END
         FROM [presentation].[F_INV_COUNTS_DAY]
         WHERE 1=1
         @FilterClause
        ) AS recipe_data_missing
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

            WHEN ''InvRecipeCostSection'' THEN
                CASE WHEN m.recipe_data_missing = 1 THEN
                    REPLACE(REPLACE(t.TemplateText,
                        ''{recipe_cost_status}'',
                        ''No recipe usage data available''),
                        ''{recipe_cost_explanation}'',
                        ''Recipe costs cannot be calculated because no theoretical usage data is being received from your inventory management system. ''
                        + ''This typically means your inventory provider does not have an active connection to a point-of-sale system. ''
                        + ''Contact your inventory system administrator to configure the POS integration.'')
                ELSE NULL
                END

            WHEN ''InvKeyMetricsSection'' THEN
                REPLACE(REPLACE(REPLACE(t.TemplateText,
                    ''{variance_pct}'',
                    CASE WHEN m.variance_pct > 15 THEN ''> 15%''
                         ELSE CAST(CAST(m.variance_pct AS DECIMAL(5,1)) AS NVARCHAR(10)) + ''%''
                    END),
                    ''{missing_count}'',
                    CAST(m.missing_count AS NVARCHAR(20))),
                    ''{recipe_cost_brief}'',
                    CASE WHEN m.recipe_data_missing = 1
                         THEN ''Not available (no POS link detected)''
                         ELSE ''Active''
                    END)

            WHEN ''InvRecommendationSection'' THEN
                REPLACE(t.TemplateText,
                    ''{recommendation_text}'',
                    CASE WHEN m.recipe_data_missing = 1 AND m.missing_count > 50 AND m.variance_pct > 15
                         THEN ''Priority: Configure the POS integration in your inventory provider to enable recipe cost tracking. Also review missing recipes and investigate top variance items.''
                         WHEN m.recipe_data_missing = 1 AND m.variance_pct > 15
                         THEN ''Configure the POS integration in your inventory provider to enable recipe cost tracking, and investigate the top variance items for root causes.''
                         WHEN m.recipe_data_missing = 1
                         THEN ''Configure the POS integration in your inventory provider to enable recipe cost tracking. This will allow the system to calculate theoretical usage and provide accurate recipe cost analysis.''
                         WHEN m.missing_count > 50 AND m.variance_pct > 15
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
    AND (m.missing_count > 0 OR m.variance_pct > 10 OR m.recipe_data_missing = 1)
)
SELECT
    STRING_AGG(rendered_text, CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10))
        WITHIN GROUP (ORDER BY SortOrder)
    AS markdown
FROM rendered_sections
WHERE rendered_text IS NOT NULL
HAVING COUNT(*) > 0',
        ExecutionQuery = NULL,
        ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, QueryTemplate, Status)
    VALUES (N'InvMMHeader', N'MarkdownCard', N'-- placeholder', N'LIVE');
