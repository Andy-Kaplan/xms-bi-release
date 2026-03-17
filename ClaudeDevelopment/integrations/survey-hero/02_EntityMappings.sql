-- =============================================================================
-- SurveyHero Integration: EntityMappings Records
-- Schema: int_surveyhero001
-- Source: XMS BI DEV (2026-03-13)
-- Total Mappings: 4 (3 hub + 1 link)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Entity: ANSWER (Hub)
-- Source: SH_MAIN | Key: ANSWER_ID (hashed)
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[EntityMappings] WHERE [entity_name] = N'ANSWER')
BEGIN
    UPDATE [core].[int_surveyhero001].[EntityMappings]
    SET [source_table] = N'SH_MAIN',
        [source_columns] = N'[{"name": "ANSWER_ID", "hash": 1}, {"name": "ANSWER", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "ANSWER_LEVEL_NAME", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "ANSWER", "BOTTOM_LEVEL", "LEVEL_NAME"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [is_active] = 1,
        [updated_at] = GETDATE()
    WHERE [entity_name] = N'ANSWER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[EntityMappings]
    ([entity_name], [source_table], [source_columns], [entity_columns],
     [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions],
     [track_deletions], [split_by_source], [is_active], [created_at], [updated_at])
    VALUES (N'ANSWER', N'SH_MAIN',
            N'[{"name": "ANSWER_ID", "hash": 1}, {"name": "ANSWER", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "ANSWER_LEVEL_NAME", "hash": 0}]',
            N'["HUB_ID", "ANSWER", "BOTTOM_LEVEL", "LEVEL_NAME"]',
            NULL, NULL, NULL, NULL, 0, 0, 1, GETDATE(), GETDATE());
END
GO

-- -----------------------------------------------------------------------------
-- Entity: QUESTION (Hub)
-- Source: SH_QUESTIONS | Key: QUESTION_ID (hashed)
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[EntityMappings] WHERE [entity_name] = N'QUESTION')
BEGIN
    UPDATE [core].[int_surveyhero001].[EntityMappings]
    SET [source_table] = N'SH_QUESTIONS',
        [source_columns] = N'[{"name": "QUESTION_ID", "hash": 1}, {"name": "parent_element_id", "hash": 0}, {"name": "question_text", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "QUESTION_ID", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "PARENT_ID", "QUESTION", "LEVEL_NAME", "BOTTOM_LEVEL", "QUESTION_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [is_active] = 1,
        [updated_at] = GETDATE()
    WHERE [entity_name] = N'QUESTION';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[EntityMappings]
    ([entity_name], [source_table], [source_columns], [entity_columns],
     [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions],
     [track_deletions], [split_by_source], [is_active], [created_at], [updated_at])
    VALUES (N'QUESTION', N'SH_QUESTIONS',
            N'[{"name": "QUESTION_ID", "hash": 1}, {"name": "parent_element_id", "hash": 0}, {"name": "question_text", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "QUESTION_ID", "hash": 0}]',
            N'["HUB_ID", "PARENT_ID", "QUESTION", "LEVEL_NAME", "BOTTOM_LEVEL", "QUESTION_ID"]',
            NULL, NULL, NULL, NULL, 0, 0, 1, GETDATE(), GETDATE());
END
GO

-- -----------------------------------------------------------------------------
-- Entity: TOUCHPOINT (Hub)
-- Source: SH_MAIN | Key: TOUCHPOINT_ID (hashed)
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[EntityMappings] WHERE [entity_name] = N'TOUCHPOINT')
BEGIN
    UPDATE [core].[int_surveyhero001].[EntityMappings]
    SET [source_table] = N'SH_MAIN',
        [source_columns] = N'[{"name": "TOUCHPOINT_ID", "hash": 1}, {"name": "TOUCHPOINT_TYPE", "hash": 0}, {"name": "TOUCHPOINT_DATE", "hash": 0}, {"name": "TOUCHPOINT_STATUS", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "TOUCHPOINT_TYPE", "TOUCHPOINT_DATETIME", "TOUCHPOINT_STATUS"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [is_active] = 1,
        [updated_at] = GETDATE()
    WHERE [entity_name] = N'TOUCHPOINT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[EntityMappings]
    ([entity_name], [source_table], [source_columns], [entity_columns],
     [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions],
     [track_deletions], [split_by_source], [is_active], [created_at], [updated_at])
    VALUES (N'TOUCHPOINT', N'SH_MAIN',
            N'[{"name": "TOUCHPOINT_ID", "hash": 1}, {"name": "TOUCHPOINT_TYPE", "hash": 0}, {"name": "TOUCHPOINT_DATE", "hash": 0}, {"name": "TOUCHPOINT_STATUS", "hash": 0}]',
            N'["HUB_ID", "TOUCHPOINT_TYPE", "TOUCHPOINT_DATETIME", "TOUCHPOINT_STATUS"]',
            NULL, NULL, NULL, NULL, 0, 0, 1, GETDATE(), GETDATE());
END
GO

-- -----------------------------------------------------------------------------
-- Entity: ANSWER_QUESTION_TOUCHPOINT (Link)
-- Source: SH_MAIN | Key: TOUCHPOINT_ID + QUESTION_ID + ANSWER_ID (all hashed)
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[EntityMappings] WHERE [entity_name] = N'ANSWER_QUESTION_TOUCHPOINT')
BEGIN
    UPDATE [core].[int_surveyhero001].[EntityMappings]
    SET [source_table] = N'SH_MAIN',
        [source_columns] = N'[{"name": "TOUCHPOINT_ID", "hash": 1}, {"name": "QUESTION_ID", "hash": 1}, {"name": "ANSWER_ID", "hash": 1}]',
        [entity_columns] = N'["TOUCHPOINT_HUB_ID", "QUESTION_HUB_ID", "ANSWER_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [is_active] = 1,
        [updated_at] = GETDATE()
    WHERE [entity_name] = N'ANSWER_QUESTION_TOUCHPOINT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[EntityMappings]
    ([entity_name], [source_table], [source_columns], [entity_columns],
     [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions],
     [track_deletions], [split_by_source], [is_active], [created_at], [updated_at])
    VALUES (N'ANSWER_QUESTION_TOUCHPOINT', N'SH_MAIN',
            N'[{"name": "TOUCHPOINT_ID", "hash": 1}, {"name": "QUESTION_ID", "hash": 1}, {"name": "ANSWER_ID", "hash": 1}]',
            N'["TOUCHPOINT_HUB_ID", "QUESTION_HUB_ID", "ANSWER_HUB_ID"]',
            NULL, NULL, NULL, NULL, 0, 0, 1, GETDATE(), GETDATE());
END
GO
