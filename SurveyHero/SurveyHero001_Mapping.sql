-- Data Vault Entity Mappings Export
-- Schema: int_surveyhero001
-- Generated: 2026-01-22 23:33:23
-- Total Mappings: 4

-- Entity: ANSWER
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_surveyhero001.EntityMappings WHERE entity_name = 'ANSWER')
BEGIN
    UPDATE core.int_surveyhero001.EntityMappings
    SET source_table = 'SH_MAIN',
        source_columns = '[{"name": "ANSWER_ID", "hash": 1}, {"name": "ANSWER", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "ANSWER_LEVEL_NAME", "hash": 0}]',
        entity_columns = '["HUB_ID", "ANSWER", "BOTTOM_LEVEL", "LEVEL_NAME"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'ANSWER';
END
ELSE
BEGIN
    INSERT INTO core.int_surveyhero001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('6232278F-48D2-48BB-9139-4BEC19BFA235', 'ANSWER', 'SH_MAIN',
            '[{"name": "ANSWER_ID", "hash": 1}, {"name": "ANSWER", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "ANSWER_LEVEL_NAME", "hash": 0}]', '["HUB_ID", "ANSWER", "BOTTOM_LEVEL", "LEVEL_NAME"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: ANSWER_QUESTION_TOUCHPOINT
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_surveyhero001.EntityMappings WHERE entity_name = 'ANSWER_QUESTION_TOUCHPOINT')
BEGIN
    UPDATE core.int_surveyhero001.EntityMappings
    SET source_table = 'SH_MAIN',
        source_columns = '[{"name": "TOUCHPOINT_ID", "hash": 1}, {"name": "QUESTION_ID", "hash": 1}, {"name": "ANSWER_ID", "hash": 1}]',
        entity_columns = '["TOUCHPOINT_HUB_ID", "QUESTION_HUB_ID", "ANSWER_HUB_ID"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'ANSWER_QUESTION_TOUCHPOINT';
END
ELSE
BEGIN
    INSERT INTO core.int_surveyhero001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('C96673DD-E213-4633-BB6B-2C3B84C313CB', 'ANSWER_QUESTION_TOUCHPOINT', 'SH_MAIN',
            '[{"name": "TOUCHPOINT_ID", "hash": 1}, {"name": "QUESTION_ID", "hash": 1}, {"name": "ANSWER_ID", "hash": 1}]', '["TOUCHPOINT_HUB_ID", "QUESTION_HUB_ID", "ANSWER_HUB_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: QUESTION
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_surveyhero001.EntityMappings WHERE entity_name = 'QUESTION')
BEGIN
    UPDATE core.int_surveyhero001.EntityMappings
    SET source_table = 'SH_QUESTIONS',
        source_columns = '[{"name": "QUESTION_ID", "hash": 1}, {"name": "parent_element_id", "hash": 0}, {"name": "question_text", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "QUESTION_ID", "hash": 0}]',
        entity_columns = '["HUB_ID", "PARENT_ID", "QUESTION", "LEVEL_NAME", "BOTTOM_LEVEL", "QUESTION_ID"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'QUESTION';
END
ELSE
BEGIN
    INSERT INTO core.int_surveyhero001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('E3E70234-7825-4C51-97B7-2869C937CCCA', 'QUESTION', 'SH_QUESTIONS',
            '[{"name": "QUESTION_ID", "hash": 1}, {"name": "parent_element_id", "hash": 0}, {"name": "question_text", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "QUESTION_ID", "hash": 0}]', '["HUB_ID", "PARENT_ID", "QUESTION", "LEVEL_NAME", "BOTTOM_LEVEL", "QUESTION_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: TOUCHPOINT
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_surveyhero001.EntityMappings WHERE entity_name = 'TOUCHPOINT')
BEGIN
    UPDATE core.int_surveyhero001.EntityMappings
    SET source_table = 'SH_MAIN',
        source_columns = '[{"name": "TOUCHPOINT_ID", "hash": 1}, {"name": "TOUCHPOINT_TYPE", "hash": 0}, {"name": "TOUCHPOINT_DATE", "hash": 0}, {"name": "TOUCHPOINT_STATUS", "hash": 0}]',
        entity_columns = '["HUB_ID", "TOUCHPOINT_TYPE", "TOUCHPOINT_DATETIME", "TOUCHPOINT_STATUS"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'TOUCHPOINT';
END
ELSE
BEGIN
    INSERT INTO core.int_surveyhero001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('19902566-A41C-4875-AF49-8DFD3043D115', 'TOUCHPOINT', 'SH_MAIN',
            '[{"name": "TOUCHPOINT_ID", "hash": 1}, {"name": "TOUCHPOINT_TYPE", "hash": 0}, {"name": "TOUCHPOINT_DATE", "hash": 0}, {"name": "TOUCHPOINT_STATUS", "hash": 0}]', '["HUB_ID", "TOUCHPOINT_TYPE", "TOUCHPOINT_DATETIME", "TOUCHPOINT_STATUS"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO
