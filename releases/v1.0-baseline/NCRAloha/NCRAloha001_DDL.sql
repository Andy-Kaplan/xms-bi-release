-- ============================================
-- STAGE_DDL Parameters Export
-- Source: UAT [core].[int_ncraloha001].[GlobalParameters]
-- Generated: 2026-07-06 15:17:46
-- Total Records: 21
-- ============================================

-- ParameterKey=DL_LABOR / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[GlobalParameters] WHERE [ParameterKey] = N'DL_LABOR' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_ncraloha001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_ncraloha001].[DL_LABOR](
	[storeId] [nvarchar](max) NULL,
	[dob] [nvarchar](max) NULL,
	[marker] [nvarchar](max) NULL,
	[moreDataImmediatelyAvailable] [nvarchar](max) NULL,
	[link] [nvarchar](max) NULL,
	[id] [nvarchar](max) NULL,
	[manager] [nvarchar](max) NULL,
	[reportable] [nvarchar](max) NULL,
	[state] [nvarchar](max) NULL,
	[startDate] [nvarchar](max) NULL,
	[endDate] [nvarchar](max) NULL,
	[totalPay] [nvarchar](max) NULL,
	[declaredTips] [nvarchar](max) NULL,
	[creditCardTips] [nvarchar](max) NULL,
	[employee_id] [nvarchar](max) NULL,
	[employee_name] [nvarchar](max) NULL,
	[job_id] [nvarchar](max) NULL,
	[job_label] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]',
        [DataType] = N'STRING',
        [Description] = N'DL_LABOR',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:34:50.160',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_LABOR' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_LABOR', N'CREATE TABLE [int_ncraloha001].[DL_LABOR](
	[storeId] [nvarchar](max) NULL,
	[dob] [nvarchar](max) NULL,
	[marker] [nvarchar](max) NULL,
	[moreDataImmediatelyAvailable] [nvarchar](max) NULL,
	[link] [nvarchar](max) NULL,
	[id] [nvarchar](max) NULL,
	[manager] [nvarchar](max) NULL,
	[reportable] [nvarchar](max) NULL,
	[state] [nvarchar](max) NULL,
	[startDate] [nvarchar](max) NULL,
	[endDate] [nvarchar](max) NULL,
	[totalPay] [nvarchar](max) NULL,
	[declaredTips] [nvarchar](max) NULL,
	[creditCardTips] [nvarchar](max) NULL,
	[employee_id] [nvarchar](max) NULL,
	[employee_name] [nvarchar](max) NULL,
	[job_id] [nvarchar](max) NULL,
	[job_label] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]', N'STRING', N'STAGE_DDL', N'DL_LABOR', 1, N'dbadmin', '2026-01-07 10:34:50.160', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_LABOR_PAYRATES / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[GlobalParameters] WHERE [ParameterKey] = N'DL_LABOR_PAYRATES' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_ncraloha001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_ncraloha001].[DL_LABOR_PAYRATES](
	[storeId] [nvarchar](max) NULL,
	[dob] [nvarchar](max) NULL,
	[shifts_id] [nvarchar](max) NULL,
	[rate] [nvarchar](max) NULL,
	[appliedAfter] [nvarchar](max) NULL,
	[time] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]',
        [DataType] = N'STRING',
        [Description] = N'DL_LABOR_PAYRATES',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:34:50.273',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_LABOR_PAYRATES' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_LABOR_PAYRATES', N'CREATE TABLE [int_ncraloha001].[DL_LABOR_PAYRATES](
	[storeId] [nvarchar](max) NULL,
	[dob] [nvarchar](max) NULL,
	[shifts_id] [nvarchar](max) NULL,
	[rate] [nvarchar](max) NULL,
	[appliedAfter] [nvarchar](max) NULL,
	[time] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]', N'STRING', N'STAGE_DDL', N'DL_LABOR_PAYRATES', 1, N'dbadmin', '2026-01-07 10:34:50.273', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_SALES / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[GlobalParameters] WHERE [ParameterKey] = N'DL_SALES' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_ncraloha001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_ncraloha001].[DL_SALES](
	[storeId] [nvarchar](max) NULL,
	[dob] [nvarchar](max) NULL,
	[netSales] [nvarchar](max) NULL,
	[giftCardSales] [nvarchar](max) NULL,
	[payments] [nvarchar](max) NULL,
	[tips] [nvarchar](max) NULL,
	[gratuities] [nvarchar](max) NULL,
	[promos] [nvarchar](max) NULL,
	[comps] [nvarchar](max) NULL,
	[voids] [nvarchar](max) NULL,
	[checkCount] [nvarchar](max) NULL,
	[guestCount] [nvarchar](max) NULL,
	[serviceType] [nvarchar](max) NULL,
	[links] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]',
        [DataType] = N'STRING',
        [Description] = N'DL_SALES',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:34:50.373',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_SALES' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_SALES', N'CREATE TABLE [int_ncraloha001].[DL_SALES](
	[storeId] [nvarchar](max) NULL,
	[dob] [nvarchar](max) NULL,
	[netSales] [nvarchar](max) NULL,
	[giftCardSales] [nvarchar](max) NULL,
	[payments] [nvarchar](max) NULL,
	[tips] [nvarchar](max) NULL,
	[gratuities] [nvarchar](max) NULL,
	[promos] [nvarchar](max) NULL,
	[comps] [nvarchar](max) NULL,
	[voids] [nvarchar](max) NULL,
	[checkCount] [nvarchar](max) NULL,
	[guestCount] [nvarchar](max) NULL,
	[serviceType] [nvarchar](max) NULL,
	[links] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]', N'STRING', N'STAGE_DDL', N'DL_SALES', 1, N'dbadmin', '2026-01-07 10:34:50.373', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_SALES_CHECK / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[GlobalParameters] WHERE [ParameterKey] = N'DL_SALES_CHECK' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_ncraloha001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_ncraloha001].[DL_SALES_CHECK](
	[storeId] [nvarchar](max) NULL,
	[dob] [nvarchar](max) NULL,
	[id] [nvarchar](max) NULL,
	[printableId] [nvarchar](max) NULL,
	[marker] [nvarchar](max) NULL,
	[total] [nvarchar](max) NULL,
	[netAmount] [nvarchar](max) NULL,
	[isClosed] [nvarchar](max) NULL,
	[isEmpty] [nvarchar](max) NULL,
	[isTraining] [nvarchar](max) NULL,
	[link] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]',
        [DataType] = N'STRING',
        [Description] = N'DL_SALES_CHECK',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:34:50.480',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_SALES_CHECK' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_SALES_CHECK', N'CREATE TABLE [int_ncraloha001].[DL_SALES_CHECK](
	[storeId] [nvarchar](max) NULL,
	[dob] [nvarchar](max) NULL,
	[id] [nvarchar](max) NULL,
	[printableId] [nvarchar](max) NULL,
	[marker] [nvarchar](max) NULL,
	[total] [nvarchar](max) NULL,
	[netAmount] [nvarchar](max) NULL,
	[isClosed] [nvarchar](max) NULL,
	[isEmpty] [nvarchar](max) NULL,
	[isTraining] [nvarchar](max) NULL,
	[link] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]', N'STRING', N'STAGE_DDL', N'DL_SALES_CHECK', 1, N'dbadmin', '2026-01-07 10:34:50.480', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_SALES_STREAM / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[GlobalParameters] WHERE [ParameterKey] = N'DL_SALES_STREAM' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_ncraloha001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_ncraloha001].[DL_SALES_STREAM](
	[storeId] [nvarchar](max) NULL,
	[dob] [nvarchar](max) NULL,
	[marker] [nvarchar](max) NULL,
	[moreDataImmediatelyAvailable] [nvarchar](max) NULL,
	[link] [nvarchar](max) NULL,
	[terminalId] [nvarchar](max) NULL,
	[grossAmount] [nvarchar](max) NULL,
	[grandAmount] [nvarchar](max) NULL,
	[id] [nvarchar](max) NULL,
	[printedCheckId] [nvarchar](max) NULL,
	[netAmount] [nvarchar](max) NULL,
	[total] [nvarchar](max) NULL,
	[isRefund] [nvarchar](max) NULL,
	[training] [nvarchar](max) NULL,
	[closed] [nvarchar](max) NULL,
	[isTaxExemptApplied] [nvarchar](max) NULL,
	[takeOutOrderId] [nvarchar](max) NULL,
	[groupInfo_id] [nvarchar](max) NULL,
	[groupInfo_label] [nvarchar](max) NULL,
	[guestCounting_guests] [nvarchar](max) NULL,
	[guestCounting_mode] [nvarchar](max) NULL,
	[revenueCenter_id] [nvarchar](max) NULL,
	[revenueCenter_label] [nvarchar](max) NULL,
	[period_id] [nvarchar](max) NULL,
	[period_label] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]',
        [DataType] = N'STRING',
        [Description] = N'DL_SALES_STREAM',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:34:50.590',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_SALES_STREAM' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_SALES_STREAM', N'CREATE TABLE [int_ncraloha001].[DL_SALES_STREAM](
	[storeId] [nvarchar](max) NULL,
	[dob] [nvarchar](max) NULL,
	[marker] [nvarchar](max) NULL,
	[moreDataImmediatelyAvailable] [nvarchar](max) NULL,
	[link] [nvarchar](max) NULL,
	[terminalId] [nvarchar](max) NULL,
	[grossAmount] [nvarchar](max) NULL,
	[grandAmount] [nvarchar](max) NULL,
	[id] [nvarchar](max) NULL,
	[printedCheckId] [nvarchar](max) NULL,
	[netAmount] [nvarchar](max) NULL,
	[total] [nvarchar](max) NULL,
	[isRefund] [nvarchar](max) NULL,
	[training] [nvarchar](max) NULL,
	[closed] [nvarchar](max) NULL,
	[isTaxExemptApplied] [nvarchar](max) NULL,
	[takeOutOrderId] [nvarchar](max) NULL,
	[groupInfo_id] [nvarchar](max) NULL,
	[groupInfo_label] [nvarchar](max) NULL,
	[guestCounting_guests] [nvarchar](max) NULL,
	[guestCounting_mode] [nvarchar](max) NULL,
	[revenueCenter_id] [nvarchar](max) NULL,
	[revenueCenter_label] [nvarchar](max) NULL,
	[period_id] [nvarchar](max) NULL,
	[period_label] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]', N'STRING', N'STAGE_DDL', N'DL_SALES_STREAM', 1, N'dbadmin', '2026-01-07 10:34:50.590', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_SALES_STREAM_CLEARS / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[GlobalParameters] WHERE [ParameterKey] = N'DL_SALES_STREAM_CLEARS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_ncraloha001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_ncraloha001].[DL_SALES_STREAM_CLEARS](
	[storeId] [nvarchar](max) NULL,
	[dob] [nvarchar](max) NULL,
	[checks_id] [nvarchar](max) NULL,
	[type] [nvarchar](max) NULL,
	[id] [nvarchar](max) NULL,
	[typeId] [nvarchar](max) NULL,
	[label] [nvarchar](max) NULL,
	[amount] [nvarchar](max) NULL,
	[createdOn] [nvarchar](max) NULL,
	[responsibleEmployees_employee_id] [nvarchar](max) NULL,
	[responsibleEmployees_employee_name] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]',
        [DataType] = N'STRING',
        [Description] = N'DL_SALES_STREAM_CLEARS',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:34:50.696',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_SALES_STREAM_CLEARS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_SALES_STREAM_CLEARS', N'CREATE TABLE [int_ncraloha001].[DL_SALES_STREAM_CLEARS](
	[storeId] [nvarchar](max) NULL,
	[dob] [nvarchar](max) NULL,
	[checks_id] [nvarchar](max) NULL,
	[type] [nvarchar](max) NULL,
	[id] [nvarchar](max) NULL,
	[typeId] [nvarchar](max) NULL,
	[label] [nvarchar](max) NULL,
	[amount] [nvarchar](max) NULL,
	[createdOn] [nvarchar](max) NULL,
	[responsibleEmployees_employee_id] [nvarchar](max) NULL,
	[responsibleEmployees_employee_name] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]', N'STRING', N'STAGE_DDL', N'DL_SALES_STREAM_CLEARS', 1, N'dbadmin', '2026-01-07 10:34:50.696', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_SALES_STREAM_CLEARS_LINKEDITEMS / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[GlobalParameters] WHERE [ParameterKey] = N'DL_SALES_STREAM_CLEARS_LINKEDITEMS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_ncraloha001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_ncraloha001].[DL_SALES_STREAM_CLEARS_LINKEDITEMS](
	[storeId] [nvarchar](max) NULL,
	[dob] [nvarchar](max) NULL,
	[checks_id] [nvarchar](max) NULL,
	[clears_id] [nvarchar](max) NULL,
	[id] [nvarchar](max) NULL,
	[amount] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]',
        [DataType] = N'STRING',
        [Description] = N'DL_SALES_STREAM_CLEARS_LINKEDITEMS',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:34:50.790',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_SALES_STREAM_CLEARS_LINKEDITEMS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_SALES_STREAM_CLEARS_LINKEDITEMS', N'CREATE TABLE [int_ncraloha001].[DL_SALES_STREAM_CLEARS_LINKEDITEMS](
	[storeId] [nvarchar](max) NULL,
	[dob] [nvarchar](max) NULL,
	[checks_id] [nvarchar](max) NULL,
	[clears_id] [nvarchar](max) NULL,
	[id] [nvarchar](max) NULL,
	[amount] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]', N'STRING', N'STAGE_DDL', N'DL_SALES_STREAM_CLEARS_LINKEDITEMS', 1, N'dbadmin', '2026-01-07 10:34:50.790', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_SALES_STREAM_COMPS / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[GlobalParameters] WHERE [ParameterKey] = N'DL_SALES_STREAM_COMPS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_ncraloha001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_ncraloha001].[DL_SALES_STREAM_COMPS](
	[storeId] [nvarchar](max) NULL,
	[dob] [nvarchar](max) NULL,
	[checks_id] [nvarchar](max) NULL,
	[type] [nvarchar](max) NULL,
	[note] [nvarchar](max) NULL,
	[id] [nvarchar](max) NULL,
	[typeId] [nvarchar](max) NULL,
	[label] [nvarchar](max) NULL,
	[amount] [nvarchar](max) NULL,
	[createdOn] [nvarchar](max) NULL,
	[responsibleEmployees_employee_id] [nvarchar](max) NULL,
	[responsibleEmployees_employee_name] [nvarchar](max) NULL,
	[responsibleEmployees_manager_id] [nvarchar](max) NULL,
	[responsibleEmployees_manager_name] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]',
        [DataType] = N'STRING',
        [Description] = N'DL_SALES_STREAM_COMPS',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:34:50.900',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_SALES_STREAM_COMPS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_SALES_STREAM_COMPS', N'CREATE TABLE [int_ncraloha001].[DL_SALES_STREAM_COMPS](
	[storeId] [nvarchar](max) NULL,
	[dob] [nvarchar](max) NULL,
	[checks_id] [nvarchar](max) NULL,
	[type] [nvarchar](max) NULL,
	[note] [nvarchar](max) NULL,
	[id] [nvarchar](max) NULL,
	[typeId] [nvarchar](max) NULL,
	[label] [nvarchar](max) NULL,
	[amount] [nvarchar](max) NULL,
	[createdOn] [nvarchar](max) NULL,
	[responsibleEmployees_employee_id] [nvarchar](max) NULL,
	[responsibleEmployees_employee_name] [nvarchar](max) NULL,
	[responsibleEmployees_manager_id] [nvarchar](max) NULL,
	[responsibleEmployees_manager_name] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]', N'STRING', N'STAGE_DDL', N'DL_SALES_STREAM_COMPS', 1, N'dbadmin', '2026-01-07 10:34:50.900', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_SALES_STREAM_COMPS_LINKEDITEMS / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[GlobalParameters] WHERE [ParameterKey] = N'DL_SALES_STREAM_COMPS_LINKEDITEMS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_ncraloha001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_ncraloha001].[DL_SALES_STREAM_COMPS_LINKEDITEMS](
	[storeId] [nvarchar](max) NULL,
	[dob] [nvarchar](max) NULL,
	[checks_id] [nvarchar](max) NULL,
	[comps_id] [nvarchar](max) NULL,
	[id] [nvarchar](max) NULL,
	[amount] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]',
        [DataType] = N'STRING',
        [Description] = N'DL_SALES_STREAM_COMPS_LINKEDITEMS',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:34:50.986',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_SALES_STREAM_COMPS_LINKEDITEMS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_SALES_STREAM_COMPS_LINKEDITEMS', N'CREATE TABLE [int_ncraloha001].[DL_SALES_STREAM_COMPS_LINKEDITEMS](
	[storeId] [nvarchar](max) NULL,
	[dob] [nvarchar](max) NULL,
	[checks_id] [nvarchar](max) NULL,
	[comps_id] [nvarchar](max) NULL,
	[id] [nvarchar](max) NULL,
	[amount] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]', N'STRING', N'STAGE_DDL', N'DL_SALES_STREAM_COMPS_LINKEDITEMS', 1, N'dbadmin', '2026-01-07 10:34:50.986', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_SALES_STREAM_EVENTS / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[GlobalParameters] WHERE [ParameterKey] = N'DL_SALES_STREAM_EVENTS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_ncraloha001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_ncraloha001].[DL_SALES_STREAM_EVENTS](
	[storeId] [nvarchar](max) NULL,
	[dob] [nvarchar](max) NULL,
	[checks_id] [nvarchar](max) NULL,
	[customEventLabel] [nvarchar](max) NULL,
	[time] [nvarchar](max) NULL,
	[type] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]',
        [DataType] = N'STRING',
        [Description] = N'DL_SALES_STREAM_EVENTS',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:34:51.093',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_SALES_STREAM_EVENTS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_SALES_STREAM_EVENTS', N'CREATE TABLE [int_ncraloha001].[DL_SALES_STREAM_EVENTS](
	[storeId] [nvarchar](max) NULL,
	[dob] [nvarchar](max) NULL,
	[checks_id] [nvarchar](max) NULL,
	[customEventLabel] [nvarchar](max) NULL,
	[time] [nvarchar](max) NULL,
	[type] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]', N'STRING', N'STAGE_DDL', N'DL_SALES_STREAM_EVENTS', 1, N'dbadmin', '2026-01-07 10:34:51.093', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_SALES_STREAM_ITEMS / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[GlobalParameters] WHERE [ParameterKey] = N'DL_SALES_STREAM_ITEMS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_ncraloha001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_ncraloha001].[DL_SALES_STREAM_ITEMS](
	[storeId] [nvarchar](max) NULL,
	[dob] [nvarchar](max) NULL,
	[checks_id] [nvarchar](max) NULL,
	[responsibleEmployeeId] [nvarchar](max) NULL,
	[netAmount] [nvarchar](max) NULL,
	[originalPrice] [nvarchar](max) NULL,
	[quantity] [nvarchar](max) NULL,
	[seat] [nvarchar](max) NULL,
	[parentItemId] [nvarchar](max) NULL,
	[revenue] [nvarchar](max) NULL,
	[processedInKitchen] [nvarchar](max) NULL,
	[giftCard] [nvarchar](max) NULL,
	[id] [nvarchar](max) NULL,
	[typeId] [nvarchar](max) NULL,
	[label] [nvarchar](max) NULL,
	[amount] [nvarchar](max) NULL,
	[createdOn] [nvarchar](max) NULL,
	[modifierInfo_type] [nvarchar](max) NULL,
	[orderMode_id] [nvarchar](max) NULL,
	[orderMode_label] [nvarchar](max) NULL,
	[period_id] [nvarchar](max) NULL,
	[period_label] [nvarchar](max) NULL,
	[modifierInfo_id_id] [nvarchar](max) NULL,
	[modifierInfo_id_label] [nvarchar](max) NULL,
	[responsibleEmployees_employee_id] [nvarchar](max) NULL,
	[responsibleEmployees_employee_name] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]',
        [DataType] = N'STRING',
        [Description] = N'DL_SALES_STREAM_ITEMS',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:34:51.156',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_SALES_STREAM_ITEMS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_SALES_STREAM_ITEMS', N'CREATE TABLE [int_ncraloha001].[DL_SALES_STREAM_ITEMS](
	[storeId] [nvarchar](max) NULL,
	[dob] [nvarchar](max) NULL,
	[checks_id] [nvarchar](max) NULL,
	[responsibleEmployeeId] [nvarchar](max) NULL,
	[netAmount] [nvarchar](max) NULL,
	[originalPrice] [nvarchar](max) NULL,
	[quantity] [nvarchar](max) NULL,
	[seat] [nvarchar](max) NULL,
	[parentItemId] [nvarchar](max) NULL,
	[revenue] [nvarchar](max) NULL,
	[processedInKitchen] [nvarchar](max) NULL,
	[giftCard] [nvarchar](max) NULL,
	[id] [nvarchar](max) NULL,
	[typeId] [nvarchar](max) NULL,
	[label] [nvarchar](max) NULL,
	[amount] [nvarchar](max) NULL,
	[createdOn] [nvarchar](max) NULL,
	[modifierInfo_type] [nvarchar](max) NULL,
	[orderMode_id] [nvarchar](max) NULL,
	[orderMode_label] [nvarchar](max) NULL,
	[period_id] [nvarchar](max) NULL,
	[period_label] [nvarchar](max) NULL,
	[modifierInfo_id_id] [nvarchar](max) NULL,
	[modifierInfo_id_label] [nvarchar](max) NULL,
	[responsibleEmployees_employee_id] [nvarchar](max) NULL,
	[responsibleEmployees_employee_name] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]', N'STRING', N'STAGE_DDL', N'DL_SALES_STREAM_ITEMS', 1, N'dbadmin', '2026-01-07 10:34:51.156', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_SALES_STREAM_ITEMS_CATEGORIES / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[GlobalParameters] WHERE [ParameterKey] = N'DL_SALES_STREAM_ITEMS_CATEGORIES' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_ncraloha001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_ncraloha001].[DL_SALES_STREAM_ITEMS_CATEGORIES](
	[storeId] [nvarchar](max) NULL,
	[dob] [nvarchar](max) NULL,
	[checks_id] [nvarchar](max) NULL,
	[items_id] [nvarchar](max) NULL,
	[id] [nvarchar](max) NULL,
	[name] [nvarchar](max) NULL,
	[type] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]',
        [DataType] = N'STRING',
        [Description] = N'DL_SALES_STREAM_ITEMS_CATEGORIES',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:34:51.210',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_SALES_STREAM_ITEMS_CATEGORIES' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_SALES_STREAM_ITEMS_CATEGORIES', N'CREATE TABLE [int_ncraloha001].[DL_SALES_STREAM_ITEMS_CATEGORIES](
	[storeId] [nvarchar](max) NULL,
	[dob] [nvarchar](max) NULL,
	[checks_id] [nvarchar](max) NULL,
	[items_id] [nvarchar](max) NULL,
	[id] [nvarchar](max) NULL,
	[name] [nvarchar](max) NULL,
	[type] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]', N'STRING', N'STAGE_DDL', N'DL_SALES_STREAM_ITEMS_CATEGORIES', 1, N'dbadmin', '2026-01-07 10:34:51.210', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_SALES_STREAM_PAYMENTS / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[GlobalParameters] WHERE [ParameterKey] = N'DL_SALES_STREAM_PAYMENTS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_ncraloha001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_ncraloha001].[DL_SALES_STREAM_PAYMENTS](
	[storeId] [nvarchar](max) NULL,
	[dob] [nvarchar](max) NULL,
	[checks_id] [nvarchar](max) NULL,
	[tip] [nvarchar](max) NULL,
	[type] [nvarchar](max) NULL,
	[card] [nvarchar](max) NULL,
	[overpayment] [nvarchar](max) NULL,
	[id] [nvarchar](max) NULL,
	[typeId] [nvarchar](max) NULL,
	[label] [nvarchar](max) NULL,
	[amount] [nvarchar](max) NULL,
	[createdOn] [nvarchar](max) NULL,
	[responsibleEmployees_employee_id] [nvarchar](max) NULL,
	[responsibleEmployees_employee_name] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL,
	[authorizationInfo_authorizationCode] [nvarchar](max) NULL,
	[authorizationInfo_authAmount] [nvarchar](max) NULL,
	[authorizationInfo_refId] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]',
        [DataType] = N'STRING',
        [Description] = N'DL_SALES_STREAM_PAYMENTS',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:34:51.310',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_SALES_STREAM_PAYMENTS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_SALES_STREAM_PAYMENTS', N'CREATE TABLE [int_ncraloha001].[DL_SALES_STREAM_PAYMENTS](
	[storeId] [nvarchar](max) NULL,
	[dob] [nvarchar](max) NULL,
	[checks_id] [nvarchar](max) NULL,
	[tip] [nvarchar](max) NULL,
	[type] [nvarchar](max) NULL,
	[card] [nvarchar](max) NULL,
	[overpayment] [nvarchar](max) NULL,
	[id] [nvarchar](max) NULL,
	[typeId] [nvarchar](max) NULL,
	[label] [nvarchar](max) NULL,
	[amount] [nvarchar](max) NULL,
	[createdOn] [nvarchar](max) NULL,
	[responsibleEmployees_employee_id] [nvarchar](max) NULL,
	[responsibleEmployees_employee_name] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL,
	[authorizationInfo_authorizationCode] [nvarchar](max) NULL,
	[authorizationInfo_authAmount] [nvarchar](max) NULL,
	[authorizationInfo_refId] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]', N'STRING', N'STAGE_DDL', N'DL_SALES_STREAM_PAYMENTS', 1, N'dbadmin', '2026-01-07 10:34:51.310', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_SALES_STREAM_PROMOS / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[GlobalParameters] WHERE [ParameterKey] = N'DL_SALES_STREAM_PROMOS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_ncraloha001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_ncraloha001].[DL_SALES_STREAM_PROMOS](
	[storeId] [nvarchar](max) NULL,
	[dob] [nvarchar](max) NULL,
	[checks_id] [nvarchar](max) NULL,
	[discount] [nvarchar](max) NULL,
	[type] [nvarchar](max) NULL,
	[id] [nvarchar](max) NULL,
	[typeId] [nvarchar](max) NULL,
	[label] [nvarchar](max) NULL,
	[amount] [nvarchar](max) NULL,
	[createdOn] [nvarchar](max) NULL,
	[responsibleEmployees_employee_id] [nvarchar](max) NULL,
	[responsibleEmployees_employee_name] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]',
        [DataType] = N'STRING',
        [Description] = N'DL_SALES_STREAM_PROMOS',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:34:51.386',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_SALES_STREAM_PROMOS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_SALES_STREAM_PROMOS', N'CREATE TABLE [int_ncraloha001].[DL_SALES_STREAM_PROMOS](
	[storeId] [nvarchar](max) NULL,
	[dob] [nvarchar](max) NULL,
	[checks_id] [nvarchar](max) NULL,
	[discount] [nvarchar](max) NULL,
	[type] [nvarchar](max) NULL,
	[id] [nvarchar](max) NULL,
	[typeId] [nvarchar](max) NULL,
	[label] [nvarchar](max) NULL,
	[amount] [nvarchar](max) NULL,
	[createdOn] [nvarchar](max) NULL,
	[responsibleEmployees_employee_id] [nvarchar](max) NULL,
	[responsibleEmployees_employee_name] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]', N'STRING', N'STAGE_DDL', N'DL_SALES_STREAM_PROMOS', 1, N'dbadmin', '2026-01-07 10:34:51.386', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_SALES_STREAM_PROMOS_LINKEDITEMS / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[GlobalParameters] WHERE [ParameterKey] = N'DL_SALES_STREAM_PROMOS_LINKEDITEMS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_ncraloha001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_ncraloha001].[DL_SALES_STREAM_PROMOS_LINKEDITEMS](
	[storeId] [nvarchar](max) NULL,
	[dob] [nvarchar](max) NULL,
	[checks_id] [nvarchar](max) NULL,
	[promos_id] [nvarchar](max) NULL,
	[id] [nvarchar](max) NULL,
	[amount] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]',
        [DataType] = N'STRING',
        [Description] = N'DL_SALES_STREAM_PROMOS_LINKEDITEMS',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:34:51.480',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_SALES_STREAM_PROMOS_LINKEDITEMS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_SALES_STREAM_PROMOS_LINKEDITEMS', N'CREATE TABLE [int_ncraloha001].[DL_SALES_STREAM_PROMOS_LINKEDITEMS](
	[storeId] [nvarchar](max) NULL,
	[dob] [nvarchar](max) NULL,
	[checks_id] [nvarchar](max) NULL,
	[promos_id] [nvarchar](max) NULL,
	[id] [nvarchar](max) NULL,
	[amount] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]', N'STRING', N'STAGE_DDL', N'DL_SALES_STREAM_PROMOS_LINKEDITEMS', 1, N'dbadmin', '2026-01-07 10:34:51.480', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_SALES_STREAM_RESPONSIBLEEMPLOYEES / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[GlobalParameters] WHERE [ParameterKey] = N'DL_SALES_STREAM_RESPONSIBLEEMPLOYEES' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_ncraloha001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_ncraloha001].[DL_SALES_STREAM_RESPONSIBLEEMPLOYEES](
	[storeId] [nvarchar](max) NULL,
	[dob] [nvarchar](max) NULL,
	[checks_id] [nvarchar](max) NULL,
	[shiftId] [nvarchar](max) NULL,
	[isTippableEmployee] [nvarchar](max) NULL,
	[roleId] [nvarchar](max) NULL,
	[roleName] [nvarchar](max) NULL,
	[id] [nvarchar](max) NULL,
	[name] [nvarchar](max) NULL,
	[time] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]',
        [DataType] = N'STRING',
        [Description] = N'DL_SALES_STREAM_RESPONSIBLEEMPLOYEES',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:34:51.586',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_SALES_STREAM_RESPONSIBLEEMPLOYEES' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_SALES_STREAM_RESPONSIBLEEMPLOYEES', N'CREATE TABLE [int_ncraloha001].[DL_SALES_STREAM_RESPONSIBLEEMPLOYEES](
	[storeId] [nvarchar](max) NULL,
	[dob] [nvarchar](max) NULL,
	[checks_id] [nvarchar](max) NULL,
	[shiftId] [nvarchar](max) NULL,
	[isTippableEmployee] [nvarchar](max) NULL,
	[roleId] [nvarchar](max) NULL,
	[roleName] [nvarchar](max) NULL,
	[id] [nvarchar](max) NULL,
	[name] [nvarchar](max) NULL,
	[time] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]', N'STRING', N'STAGE_DDL', N'DL_SALES_STREAM_RESPONSIBLEEMPLOYEES', 1, N'dbadmin', '2026-01-07 10:34:51.586', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_SALES_STREAM_SURCHARGES / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[GlobalParameters] WHERE [ParameterKey] = N'DL_SALES_STREAM_SURCHARGES' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_ncraloha001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_ncraloha001].[DL_SALES_STREAM_SURCHARGES](
	[storeId] [nvarchar](max) NULL,
	[dob] [nvarchar](max) NULL,
	[checks_id] [nvarchar](max) NULL,
	[rate] [nvarchar](max) NULL,
	[type] [nvarchar](max) NULL,
	[accounting] [nvarchar](max) NULL,
	[taxableSales] [nvarchar](max) NULL,
	[id] [nvarchar](max) NULL,
	[typeId] [nvarchar](max) NULL,
	[label] [nvarchar](max) NULL,
	[amount] [nvarchar](max) NULL,
	[createdOn] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]',
        [DataType] = N'STRING',
        [Description] = N'DL_SALES_STREAM_SURCHARGES',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:34:51.666',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_SALES_STREAM_SURCHARGES' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_SALES_STREAM_SURCHARGES', N'CREATE TABLE [int_ncraloha001].[DL_SALES_STREAM_SURCHARGES](
	[storeId] [nvarchar](max) NULL,
	[dob] [nvarchar](max) NULL,
	[checks_id] [nvarchar](max) NULL,
	[rate] [nvarchar](max) NULL,
	[type] [nvarchar](max) NULL,
	[accounting] [nvarchar](max) NULL,
	[taxableSales] [nvarchar](max) NULL,
	[id] [nvarchar](max) NULL,
	[typeId] [nvarchar](max) NULL,
	[label] [nvarchar](max) NULL,
	[amount] [nvarchar](max) NULL,
	[createdOn] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]', N'STRING', N'STAGE_DDL', N'DL_SALES_STREAM_SURCHARGES', 1, N'dbadmin', '2026-01-07 10:34:51.666', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_SALES_STREAM_SURCHARGES_LINKEDITEMS / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[GlobalParameters] WHERE [ParameterKey] = N'DL_SALES_STREAM_SURCHARGES_LINKEDITEMS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_ncraloha001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_ncraloha001].[DL_SALES_STREAM_SURCHARGES_LINKEDITEMS](
	[storeId] [nvarchar](max) NULL,
	[dob] [nvarchar](max) NULL,
	[checks_id] [nvarchar](max) NULL,
	[surcharges_id] [nvarchar](max) NULL,
	[linkedItems] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]',
        [DataType] = N'STRING',
        [Description] = N'DL_SALES_STREAM_SURCHARGES_LINKEDITEMS',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:34:51.773',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_SALES_STREAM_SURCHARGES_LINKEDITEMS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_SALES_STREAM_SURCHARGES_LINKEDITEMS', N'CREATE TABLE [int_ncraloha001].[DL_SALES_STREAM_SURCHARGES_LINKEDITEMS](
	[storeId] [nvarchar](max) NULL,
	[dob] [nvarchar](max) NULL,
	[checks_id] [nvarchar](max) NULL,
	[surcharges_id] [nvarchar](max) NULL,
	[linkedItems] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]', N'STRING', N'STAGE_DDL', N'DL_SALES_STREAM_SURCHARGES_LINKEDITEMS', 1, N'dbadmin', '2026-01-07 10:34:51.773', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_SALES_STREAM_VOIDS / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[GlobalParameters] WHERE [ParameterKey] = N'DL_SALES_STREAM_VOIDS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_ncraloha001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_ncraloha001].[DL_SALES_STREAM_VOIDS](
	[storeId] [nvarchar](max) NULL,
	[dob] [nvarchar](max) NULL,
	[checks_id] [nvarchar](max) NULL,
	[type] [nvarchar](max) NULL,
	[id] [nvarchar](max) NULL,
	[typeId] [nvarchar](max) NULL,
	[label] [nvarchar](max) NULL,
	[amount] [nvarchar](max) NULL,
	[createdOn] [nvarchar](max) NULL,
	[responsibleEmployees_employee_id] [nvarchar](max) NULL,
	[responsibleEmployees_employee_name] [nvarchar](max) NULL,
	[responsibleEmployees_manager_id] [nvarchar](max) NULL,
	[responsibleEmployees_manager_name] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]',
        [DataType] = N'STRING',
        [Description] = N'DL_SALES_STREAM_VOIDS',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:34:51.850',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_SALES_STREAM_VOIDS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_SALES_STREAM_VOIDS', N'CREATE TABLE [int_ncraloha001].[DL_SALES_STREAM_VOIDS](
	[storeId] [nvarchar](max) NULL,
	[dob] [nvarchar](max) NULL,
	[checks_id] [nvarchar](max) NULL,
	[type] [nvarchar](max) NULL,
	[id] [nvarchar](max) NULL,
	[typeId] [nvarchar](max) NULL,
	[label] [nvarchar](max) NULL,
	[amount] [nvarchar](max) NULL,
	[createdOn] [nvarchar](max) NULL,
	[responsibleEmployees_employee_id] [nvarchar](max) NULL,
	[responsibleEmployees_employee_name] [nvarchar](max) NULL,
	[responsibleEmployees_manager_id] [nvarchar](max) NULL,
	[responsibleEmployees_manager_name] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]', N'STRING', N'STAGE_DDL', N'DL_SALES_STREAM_VOIDS', 1, N'dbadmin', '2026-01-07 10:34:51.850', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_SALES_STREAM_VOIDS_LINKEDITEMS / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[GlobalParameters] WHERE [ParameterKey] = N'DL_SALES_STREAM_VOIDS_LINKEDITEMS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_ncraloha001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_ncraloha001].[DL_SALES_STREAM_VOIDS_LINKEDITEMS](
	[storeId] [nvarchar](max) NULL,
	[dob] [nvarchar](max) NULL,
	[checks_id] [nvarchar](max) NULL,
	[voids_id] [nvarchar](max) NULL,
	[id] [nvarchar](max) NULL,
	[amount] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]',
        [DataType] = N'STRING',
        [Description] = N'DL_SALES_STREAM_VOIDS_LINKEDITEMS',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:34:51.960',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_SALES_STREAM_VOIDS_LINKEDITEMS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_SALES_STREAM_VOIDS_LINKEDITEMS', N'CREATE TABLE [int_ncraloha001].[DL_SALES_STREAM_VOIDS_LINKEDITEMS](
	[storeId] [nvarchar](max) NULL,
	[dob] [nvarchar](max) NULL,
	[checks_id] [nvarchar](max) NULL,
	[voids_id] [nvarchar](max) NULL,
	[id] [nvarchar](max) NULL,
	[amount] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]', N'STRING', N'STAGE_DDL', N'DL_SALES_STREAM_VOIDS_LINKEDITEMS', 1, N'dbadmin', '2026-01-07 10:34:51.960', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_STORE / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[GlobalParameters] WHERE [ParameterKey] = N'DL_STORE' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_ncraloha001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_ncraloha001].[DL_STORE](
	[storeId] [nvarchar](max) NULL,
	[insightId] [nvarchar](max) NULL,
	[name] [nvarchar](max) NULL,
	[link] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]',
        [DataType] = N'STRING',
        [Description] = N'DL_STORE',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:34:52.070',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_STORE' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_STORE', N'CREATE TABLE [int_ncraloha001].[DL_STORE](
	[storeId] [nvarchar](max) NULL,
	[insightId] [nvarchar](max) NULL,
	[name] [nvarchar](max) NULL,
	[link] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]', N'STRING', N'STAGE_DDL', N'DL_STORE', 1, N'dbadmin', '2026-01-07 10:34:52.070', NULL, NULL, 1);
END
GO
