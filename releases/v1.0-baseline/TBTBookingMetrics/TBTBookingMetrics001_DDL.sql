-- ============================================
-- STAGE_DDL Parameters Export
-- Source: UAT [core].[int_tbtbookingmetrics001].[GlobalParameters]
-- Generated: 2026-07-06 15:17:46
-- Total Records: 1
-- ============================================

-- ParameterKey=DL_BOOKING_METRICS / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_tbtbookingmetrics001].[GlobalParameters] WHERE [ParameterKey] = N'DL_BOOKING_METRICS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_tbtbookingmetrics001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_tbtbookingmetrics001].[DL_BOOKING_METRICS]
(
    [hour] NVARCHAR(MAX),
    [brandName] NVARCHAR(MAX),
    [brandKey] NVARCHAR(MAX),
    [totalBookings] NVARCHAR(MAX),
    [totalCovers] NVARCHAR(MAX),
    [sessions] NVARCHAR(MAX),
    [activeUsers] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_BOOKING_METRICS',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-04-07 10:23:39.260',
        [ModifiedBy] = N'dbadmin',
        [ModifiedDate] = '2026-04-07 13:51:21.683',
        [Version] = 1
    WHERE [ParameterKey] = N'DL_BOOKING_METRICS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_tbtbookingmetrics001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_BOOKING_METRICS', N'CREATE TABLE [int_tbtbookingmetrics001].[DL_BOOKING_METRICS]
(
    [hour] NVARCHAR(MAX),
    [brandName] NVARCHAR(MAX),
    [brandKey] NVARCHAR(MAX),
    [totalBookings] NVARCHAR(MAX),
    [totalCovers] NVARCHAR(MAX),
    [sessions] NVARCHAR(MAX),
    [activeUsers] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_BOOKING_METRICS', 1, N'dbadmin', '2026-04-07 10:23:39.260', N'dbadmin', '2026-04-07 13:51:21.683', 1);
END
GO
