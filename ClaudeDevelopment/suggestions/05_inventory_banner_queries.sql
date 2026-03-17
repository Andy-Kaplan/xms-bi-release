-- =====================================================
-- Replace InvMMHeader (StaticBoxCard) — Missing Recipes Banner
-- Returns a row ONLY when missing recipe count > 0.
-- This metric is org-wide (no @FilterClause) because
-- recipe mappings are a product property, not location/date.
--
-- Join path verified against products_without_invitem_recipes.sql:
--   D_PRODUCT.BOTTOM_HUB_ID → LNK_INVITEM_OCCASION_PRODUCT.PRODUCT_HUB_ID
--   D_PRODUCT.BOTTOM_HUB_ID → LNK_INVITEM_LOCATION_OCCASION_PRODUCT.PRODUCT_HUB_ID
-- Filters: BOTTOM_IS_DELETED excluded (deleted products ignored)
-- Uses COUNT(DISTINCT) to avoid double-counting across hierarchy paths
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
    SELECT COUNT(DISTINCT p.BOTTOM_HUB_ID) AS missing_count
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
    SELECT COUNT(DISTINCT p.BOTTOM_HUB_ID) AS missing_count
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
