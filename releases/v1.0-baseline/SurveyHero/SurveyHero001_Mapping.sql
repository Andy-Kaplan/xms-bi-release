-- ============================================
-- Entity Mappings Export
-- Source: UAT [core].[int_surveyhero001].[EntityMappings]
-- Generated: 2026-07-06 15:17:46
-- Total Records: 4
-- ============================================

-- entity_name=ANSWER
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[EntityMappings] WHERE [entity_name] = N'ANSWER')
BEGIN
    UPDATE [core].[int_surveyhero001].[EntityMappings]
    SET
        [source_table] = N'SH_MAIN',
        [source_columns] = N'[{"name": "ANSWER_ID", "hash": 1}, {"name": "ANSWER", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "ANSWER_LEVEL_NAME", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "ANSWER", "BOTTOM_LEVEL", "LEVEL_NAME"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-13 14:12:30.857',
        [updated_at] = '2026-03-13 14:12:30.857',
        [is_active] = 1
    WHERE [entity_name] = N'ANSWER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'ANSWER', N'SH_MAIN', N'[{"name": "ANSWER_ID", "hash": 1}, {"name": "ANSWER", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "ANSWER_LEVEL_NAME", "hash": 0}]', N'["HUB_ID", "ANSWER", "BOTTOM_LEVEL", "LEVEL_NAME"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-13 14:12:30.857', '2026-03-13 14:12:30.857', 1);
END
GO
-- entity_name=ANSWER_QUESTION_TOUCHPOINT
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[EntityMappings] WHERE [entity_name] = N'ANSWER_QUESTION_TOUCHPOINT')
BEGIN
    UPDATE [core].[int_surveyhero001].[EntityMappings]
    SET
        [source_table] = N'SH_MAIN',
        [source_columns] = N'[{"name": "TOUCHPOINT_ID", "hash": 1}, {"name": "QUESTION_ID", "hash": 1}, {"name": "ANSWER_ID", "hash": 1}]',
        [entity_columns] = N'["TOUCHPOINT_HUB_ID", "QUESTION_HUB_ID", "ANSWER_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-13 14:12:31.137',
        [updated_at] = '2026-03-13 14:12:31.137',
        [is_active] = 1
    WHERE [entity_name] = N'ANSWER_QUESTION_TOUCHPOINT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'ANSWER_QUESTION_TOUCHPOINT', N'SH_MAIN', N'[{"name": "TOUCHPOINT_ID", "hash": 1}, {"name": "QUESTION_ID", "hash": 1}, {"name": "ANSWER_ID", "hash": 1}]', N'["TOUCHPOINT_HUB_ID", "QUESTION_HUB_ID", "ANSWER_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-13 14:12:31.137', '2026-03-13 14:12:31.137', 1);
END
GO
-- entity_name=QUESTION
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[EntityMappings] WHERE [entity_name] = N'QUESTION')
BEGIN
    UPDATE [core].[int_surveyhero001].[EntityMappings]
    SET
        [source_table] = N'SH_QUESTIONS',
        [source_columns] = N'[{"name": "QUESTION_ID", "hash": 1}, {"name": "parent_element_id", "hash": 0}, {"name": "question_text", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "QUESTION_ID", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "PARENT_ID", "QUESTION", "LEVEL_NAME", "BOTTOM_LEVEL", "QUESTION_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-13 14:12:30.950',
        [updated_at] = '2026-03-13 14:12:30.950',
        [is_active] = 1
    WHERE [entity_name] = N'QUESTION';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'QUESTION', N'SH_QUESTIONS', N'[{"name": "QUESTION_ID", "hash": 1}, {"name": "parent_element_id", "hash": 0}, {"name": "question_text", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "QUESTION_ID", "hash": 0}]', N'["HUB_ID", "PARENT_ID", "QUESTION", "LEVEL_NAME", "BOTTOM_LEVEL", "QUESTION_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-13 14:12:30.950', '2026-03-13 14:12:30.950', 1);
END
GO
-- entity_name=TOUCHPOINT
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[EntityMappings] WHERE [entity_name] = N'TOUCHPOINT')
BEGIN
    UPDATE [core].[int_surveyhero001].[EntityMappings]
    SET
        [source_table] = N'SH_MAIN',
        [source_columns] = N'[{"name": "TOUCHPOINT_ID", "hash": 1}, {"name": "TOUCHPOINT_TYPE", "hash": 0}, {"name": "TOUCHPOINT_DATE", "hash": 0}, {"name": "TOUCHPOINT_STATUS", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "TOUCHPOINT_TYPE", "TOUCHPOINT_DATETIME", "TOUCHPOINT_STATUS"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-13 14:12:31.040',
        [updated_at] = '2026-03-13 14:12:31.040',
        [is_active] = 1
    WHERE [entity_name] = N'TOUCHPOINT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'TOUCHPOINT', N'SH_MAIN', N'[{"name": "TOUCHPOINT_ID", "hash": 1}, {"name": "TOUCHPOINT_TYPE", "hash": 0}, {"name": "TOUCHPOINT_DATE", "hash": 0}, {"name": "TOUCHPOINT_STATUS", "hash": 0}]', N'["HUB_ID", "TOUCHPOINT_TYPE", "TOUCHPOINT_DATETIME", "TOUCHPOINT_STATUS"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-13 14:12:31.040', '2026-03-13 14:12:31.040', 1);
END
GO
