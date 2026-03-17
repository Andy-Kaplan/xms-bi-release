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
