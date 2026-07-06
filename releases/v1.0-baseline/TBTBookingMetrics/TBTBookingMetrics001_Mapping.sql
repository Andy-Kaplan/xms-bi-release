-- ============================================
-- Entity Mappings Export
-- Source: UAT [core].[int_tbtbookingmetrics001].[EntityMappings]
-- Generated: 2026-06-02 10:45:23
-- Total Records: 1
-- ============================================

-- entity_name=BOOKINGREPORT
IF EXISTS (SELECT 1 FROM [core].[int_tbtbookingmetrics001].[EntityMappings] WHERE [entity_name] = N'BOOKINGREPORT')
BEGIN
    UPDATE [core].[int_tbtbookingmetrics001].[EntityMappings]
    SET
        [source_table] = N'STG_BOOKINGREPORT',
        [source_columns] = N'[{"name": "BOOKINGREPORT_SRC_KEY", "hash": 1}, {"name": "METRIC_HOUR", "hash": 0}, {"name": "METRIC_DATE", "hash": 0}, {"name": "BRAND_NAME", "hash": 0}, {"name": "BRAND_KEY", "hash": 0}, {"name": "TOTAL_BOOKINGS", "hash": 0}, {"name": "TOTAL_COVERS", "hash": 0}, {"name": "SESSIONS", "hash": 0}, {"name": "ACTIVE_USERS", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "METRIC_HOUR", "METRIC_DATE", "BRAND_NAME", "BRAND_KEY", "TOTAL_BOOKINGS", "TOTAL_COVERS", "SESSIONS", "ACTIVE_USERS"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-04-07 13:51:42.377',
        [updated_at] = '2026-04-07 13:51:42.377',
        [is_active] = 1
    WHERE [entity_name] = N'BOOKINGREPORT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_tbtbookingmetrics001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'BOOKINGREPORT', N'STG_BOOKINGREPORT', N'[{"name": "BOOKINGREPORT_SRC_KEY", "hash": 1}, {"name": "METRIC_HOUR", "hash": 0}, {"name": "METRIC_DATE", "hash": 0}, {"name": "BRAND_NAME", "hash": 0}, {"name": "BRAND_KEY", "hash": 0}, {"name": "TOTAL_BOOKINGS", "hash": 0}, {"name": "TOTAL_COVERS", "hash": 0}, {"name": "SESSIONS", "hash": 0}, {"name": "ACTIVE_USERS", "hash": 0}]', N'["HUB_ID", "METRIC_HOUR", "METRIC_DATE", "BRAND_NAME", "BRAND_KEY", "TOTAL_BOOKINGS", "TOTAL_COVERS", "SESSIONS", "ACTIVE_USERS"]', NULL, NULL, NULL, NULL, 0, 0, '2026-04-07 13:51:42.377', '2026-04-07 13:51:42.377', 1);
END
GO
