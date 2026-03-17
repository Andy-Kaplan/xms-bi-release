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
