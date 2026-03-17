-- Staging Control Steps Export
-- Schema: int_ncraloha001
-- Generated: 2026-01-12 14:26:40
-- Total Steps: 27

-- Step: Channel and Cust Order Link (Tier 1)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Channel and Cust Order Link')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET [staging_table] = N'NCR_CHANNEL_LINK',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_CHANNEL_LINK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_CHANNEL_LINK];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_CHANNEL_LINK]
FROM (
SELECT DISTINCT
	CONCAT_WS(''-'',[storeId],[dob],[id]) AS HEADER_SRC_KEY
	,CASE WHEN [takeOutOrderId] IS NULL THEN ''Pos''
	ELSE [revenueCenter_Label]
	END AS CHANNEL
	, ''Channel'' AS LEVE_NAME
	,1 AS BOTTOM_LEVEL
  FROM [int_ncraloha001].[DL_SALES_STREAM]
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["HEADER_SRC_KEY", "CHANNEL", "LEVE_NAME", "BOTTOM_LEVEL"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Channel and Cust Order Link';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Channel and Cust Order Link', N'NCR_CHANNEL_LINK', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_CHANNEL_LINK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_CHANNEL_LINK];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_CHANNEL_LINK]
FROM (
SELECT DISTINCT
	CONCAT_WS(''-'',[storeId],[dob],[id]) AS HEADER_SRC_KEY
	,CASE WHEN [takeOutOrderId] IS NULL THEN ''Pos''
	ELSE [revenueCenter_Label]
	END AS CHANNEL
	, ''Channel'' AS LEVE_NAME
	,1 AS BOTTOM_LEVEL
  FROM [int_ncraloha001].[DL_SALES_STREAM]
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, N'["HEADER_SRC_KEY", "CHANNEL", "LEVE_NAME", "BOTTOM_LEVEL"]', GETDATE(), GETDATE());
END
GO

-- Step: Deal (Tier 1)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Deal')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET [staging_table] = N'NCR_DEAL',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_DEAL'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_DEAL];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_DEAL]
FROM (
SELECT
	*
FROM
(
SELECT
	PARENT_ITEM_SRC_KEY
	,ITEM_SRC_KEY
	,LEVEL_NAME
	,label
	,BOTTOM_LEVEL
	,ROW_NUMBER() OVER(PARTITION BY ITEM_SRC_KEY ORDER BY LAST_DOB DESC) AS RN
FROM
(
	SELECT DISTINCT
		NULL AS PARENT_ITEM_SRC_KEY
		,SI.[typeId] AS ITEM_SRC_KEY
			,''Deal'' AS LEVEL_NAME
		,SI.label AS label
		,1 AS BOTTOM_LEVEL
		,MAX(SI.dOB) OVER(PARTITION BY SI.[typeId],SI.label) AS LAST_DOB
	FROM
		[int_ncraloha001].[DL_SALES_STREAM_PROMOS] SI

) SUB
) SUB2
WHERE RN = 1
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["PARENT_ITEM_SRC_KEY", "ITEM_SRC_KEY", "LEVEL_NAME", "label", "BOTTOM_LEVEL", "RN"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Deal';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Deal', N'NCR_DEAL', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_DEAL'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_DEAL];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_DEAL]
FROM (
SELECT
	*
FROM
(
SELECT
	PARENT_ITEM_SRC_KEY
	,ITEM_SRC_KEY
	,LEVEL_NAME
	,label
	,BOTTOM_LEVEL
	,ROW_NUMBER() OVER(PARTITION BY ITEM_SRC_KEY ORDER BY LAST_DOB DESC) AS RN
FROM
(
	SELECT DISTINCT
		NULL AS PARENT_ITEM_SRC_KEY
		,SI.[typeId] AS ITEM_SRC_KEY
			,''Deal'' AS LEVEL_NAME
		,SI.label AS label
		,1 AS BOTTOM_LEVEL
		,MAX(SI.dOB) OVER(PARTITION BY SI.[typeId],SI.label) AS LAST_DOB
	FROM
		[int_ncraloha001].[DL_SALES_STREAM_PROMOS] SI

) SUB
) SUB2
WHERE RN = 1
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, N'["PARENT_ITEM_SRC_KEY", "ITEM_SRC_KEY", "LEVEL_NAME", "label", "BOTTOM_LEVEL", "RN"]', GETDATE(), GETDATE());
END
GO

-- Step: Discount (Tier 1)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Discount')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET [staging_table] = N'NCR_DISC',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_DISC'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_DISC];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_DISC]
FROM (
SELECT
	*
FROM
(
SELECT
	PARENT_ITEM_SRC_KEY
	,ITEM_SRC_KEY
	,LEVEL_NAME
	,label
	,BOTTOM_LEVEL
	,ROW_NUMBER() OVER(PARTITION BY ITEM_SRC_KEY ORDER BY LAST_DOB DESC) AS RN
FROM
(
	SELECT DISTINCT
		NULL AS PARENT_ITEM_SRC_KEY
		,SI.[typeId] AS ITEM_SRC_KEY
			,''Discount'' AS LEVEL_NAME
		,SI.label AS label
		,1 AS BOTTOM_LEVEL
		,MAX(SI.dOB) OVER(PARTITION BY SI.[typeId],SI.label) AS LAST_DOB
	FROM
		[int_ncraloha001].[DL_SALES_STREAM_COMPS] SI

) SUB
) SUB2
WHERE RN = 1
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["PARENT_ITEM_SRC_KEY", "ITEM_SRC_KEY", "LEVEL_NAME", "label", "BOTTOM_LEVEL", "RN"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Discount';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Discount', N'NCR_DISC', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_DISC'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_DISC];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_DISC]
FROM (
SELECT
	*
FROM
(
SELECT
	PARENT_ITEM_SRC_KEY
	,ITEM_SRC_KEY
	,LEVEL_NAME
	,label
	,BOTTOM_LEVEL
	,ROW_NUMBER() OVER(PARTITION BY ITEM_SRC_KEY ORDER BY LAST_DOB DESC) AS RN
FROM
(
	SELECT DISTINCT
		NULL AS PARENT_ITEM_SRC_KEY
		,SI.[typeId] AS ITEM_SRC_KEY
			,''Discount'' AS LEVEL_NAME
		,SI.label AS label
		,1 AS BOTTOM_LEVEL
		,MAX(SI.dOB) OVER(PARTITION BY SI.[typeId],SI.label) AS LAST_DOB
	FROM
		[int_ncraloha001].[DL_SALES_STREAM_COMPS] SI

) SUB
) SUB2
WHERE RN = 1
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, N'["PARENT_ITEM_SRC_KEY", "ITEM_SRC_KEY", "LEVEL_NAME", "label", "BOTTOM_LEVEL", "RN"]', GETDATE(), GETDATE());
END
GO

-- Step: Employee Timecard (Tier 1)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Employee Timecard')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET [staging_table] = N'NCR_EMP_TIME',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_EMP_TIME'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_EMP_TIME];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_EMP_TIME]
FROM (
SELECT 
    CONCAT_WS(''-'',L.[storeId],L.[dob],L.[id], L.[employee_id]) AS TIMECARD_SRC_KEY
    ,TRY_CAST(L.[startDate] AS DATETIME2) AS TIMECARD_START_TIMESTAMP
    ,TRY_CAST(L.[endDate] AS DATETIME2) AS TIMECARD_END_TIMESTAMP
    ,TRY_CAST(L.[dob] AS DATE) AS TIMECARD_DATE
    ,CASE 
        WHEN CHARINDEX('' '', [employee_name]) = 0 THEN [employee_name]  -- Handle single names
        ELSE LEFT([employee_name], CHARINDEX('' '', [employee_name]) - 1)
    END AS FirstName
    
    -- Middle Names: Everything between first and last space
    ,CASE 
        WHEN LEN([employee_name]) - LEN(REPLACE([employee_name], '' '', '''')) <= 1 THEN ''''  -- No middle names
        ELSE LTRIM(RTRIM(SUBSTRING([employee_name], 
            CHARINDEX('' '', [employee_name]) + 1, 
            LEN([employee_name]) - CHARINDEX('' '', [employee_name]) - CHARINDEX('' '', REVERSE([employee_name])))))
    END AS MiddleNames
    
    -- Last Name: Everything after the last space
    ,CASE 
        WHEN CHARINDEX('' '', [employee_name]) = 0 THEN ''''  -- Handle single names
        ELSE RIGHT([employee_name], CHARINDEX('' '', REVERSE([employee_name])) - 1)
    END AS Surname
    ,[storeId] AS LOACTION_SRC_KEY
    ,[manager]
    ,[reportable]
    ,[state]
    ,CONCAT_WS(''-'',L.[storeId], L.[employee_id]) EMP_SRC_KEY
    ,[employee_name]
    ,[job_id] JOB_SRC_KEY
    ,[job_label]
FROM
    [int_ncraloha001].[DL_LABOR] L
WHERE L.[reportable] = 1
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["TIMECARD_SRC_KEY", "TIMECARD_START_TIMESTAMP", "TIMECARD_END_TIMESTAMP", "TIMECARD_DATE", "FirstName", "MiddleNames", "Surname", "LOACTION_SRC_KEY", "manager", "reportable", "state", "EMP_SRC_KEY", "employee_name", "JOB_SRC_KEY", "job_label"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Employee Timecard';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Employee Timecard', N'NCR_EMP_TIME', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_EMP_TIME'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_EMP_TIME];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_EMP_TIME]
FROM (
SELECT 
    CONCAT_WS(''-'',L.[storeId],L.[dob],L.[id], L.[employee_id]) AS TIMECARD_SRC_KEY
    ,TRY_CAST(L.[startDate] AS DATETIME2) AS TIMECARD_START_TIMESTAMP
    ,TRY_CAST(L.[endDate] AS DATETIME2) AS TIMECARD_END_TIMESTAMP
    ,TRY_CAST(L.[dob] AS DATE) AS TIMECARD_DATE
    ,CASE 
        WHEN CHARINDEX('' '', [employee_name]) = 0 THEN [employee_name]  -- Handle single names
        ELSE LEFT([employee_name], CHARINDEX('' '', [employee_name]) - 1)
    END AS FirstName
    
    -- Middle Names: Everything between first and last space
    ,CASE 
        WHEN LEN([employee_name]) - LEN(REPLACE([employee_name], '' '', '''')) <= 1 THEN ''''  -- No middle names
        ELSE LTRIM(RTRIM(SUBSTRING([employee_name], 
            CHARINDEX('' '', [employee_name]) + 1, 
            LEN([employee_name]) - CHARINDEX('' '', [employee_name]) - CHARINDEX('' '', REVERSE([employee_name])))))
    END AS MiddleNames
    
    -- Last Name: Everything after the last space
    ,CASE 
        WHEN CHARINDEX('' '', [employee_name]) = 0 THEN ''''  -- Handle single names
        ELSE RIGHT([employee_name], CHARINDEX('' '', REVERSE([employee_name])) - 1)
    END AS Surname
    ,[storeId] AS LOACTION_SRC_KEY
    ,[manager]
    ,[reportable]
    ,[state]
    ,CONCAT_WS(''-'',L.[storeId], L.[employee_id]) EMP_SRC_KEY
    ,[employee_name]
    ,[job_id] JOB_SRC_KEY
    ,[job_label]
FROM
    [int_ncraloha001].[DL_LABOR] L
WHERE L.[reportable] = 1
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, N'["TIMECARD_SRC_KEY", "TIMECARD_START_TIMESTAMP", "TIMECARD_END_TIMESTAMP", "TIMECARD_DATE", "FirstName", "MiddleNames", "Surname", "LOACTION_SRC_KEY", "manager", "reportable", "state", "EMP_SRC_KEY", "employee_name", "JOB_SRC_KEY", "job_label"]', GETDATE(), GETDATE());
END
GO

-- Step: Line Item Detail (Tier 1)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Line Item Detail')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET [staging_table] = N'NCR_LINE_ITEM_DETAIL',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_LINE_ITEM_DETAIL'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_LINE_ITEM_DETAIL];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_LINE_ITEM_DETAIL]
FROM (
SELECT
	SUB.*
	,MAX(SUB.EMPLOYEE_SRC_SUB) OVER(PARTITION BY SUB.HEADER_ID) AS EMPLOYEE_SRC_KEY
	,CONCAT_WS(''-'',SUB_SRC_KEY, LINEITEM_TYPE) AS SRC_KEY
	,HDR.GRAND_TOTAL_SRC
	,SUM(CASE WHEN SUB.LINEITEM_TYPE IN (''COMP'',''DISCOUNT'') THEN ISNULL(SUB.GROSS_VALUE,0) ELSE 0 END) OVER(PARTITION BY SUB.HEADER_ID) AS DISCOUNT_GROSS
	,HDR.NET_SALES_SRC
	,SUM(ISNULL(SUB.NET_VALUE,0)) OVER(PARTITION BY SUB.HEADER_ID) AS NET_SALES
	,SUM(ISNULL(SUB.TAX_VALUE,0)) OVER(PARTITION BY SUB.HEADER_ID) AS TAX_TOTAL
	,HDR.GROSS_SALES_SRC
	,HDR.PAYMENT
	,CASE WHEN HDR.PAYMENT >= HDR.GROSS_SALES_SRC THEN ''PAID'' ELSE
		CASE WHEN HDR.PAYMENT IS NOT NULL THEN ''PARTIAL'' ELSE NULL END END AS PAYMENT_STATUS
	,HDR.ORDER_STATUS
	,SUM(CASE WHEN SUB.LINEITEM_TYPE != ''TENDER'' THEN ISNULL(SUB.GROSS_VALUE,0) ELSE 0 END) OVER(PARTITION BY SUB.HEADER_ID) AS GROSS_SALES
	,SUM(CASE WHEN SUB.LINEITEM_TYPE != ''TAX'' THEN ISNULL(SUB.TAX_VALUE,0) ELSE 0 END) OVER(PARTITION BY SUB.HEADER_ID) AS SVC_CHARGE__TOTAL
	,SUM(ISNULL(SUB.QUANTITY,0)) OVER(PARTITION BY SUB.HEADER_ID) AS ITEM_COUNT
	,HDR.GUEST_COUNT
	,HDR.ORDER_COUNT
	,HDR.OPEN_TIME
	,HDR.CLOSE_TIME
	,HDR.ORDER_INFO
	,HDR.EXTERNAL_REFERENCE
	,HDR.REVENUE_CENTER_SRC_KEY
	,MAX(SUB.OCCASSION_SRC_SUB)  OVER(PARTITION BY SUB.HEADER_ID) AS OCCASSION_SRC_KEY
FROM
(
SELECT
	CONCAT_WS(''-'', SI.[storeId] ,SI.[dob] ,SI.[checks_id], SI.[id]) AS SUB_SRC_KEY
	,CONCAT_WS(''-'', SI.[storeId] ,SI.[dob] ,SI.[checks_id]) AS HEADER_ID
	,SI.[storeId] AS LOCATION_ID
	,CASE WHEN SI.[modifierInfo_type] IS NOT NULL
		THEN ''MOD''
		ELSE ''PROD''
	END AS LINEITEM_TYPE
	,TRY_CAST(SI.[amount] AS FLOAT) AS GROSS_VALUE
	,NULL AS TAX_VALUE
	,TRY_CAST(SI.[Netamount] AS FLOAT) AS NET_VALUE
	,TRY_CAST(SI.[quantity] AS FLOAT) AS QUANTITY
	,TRY_CAST(SI.[quantity] AS FLOAT) AS QUANTITY_INV
    ,TRY_CAST(SI.[createdOn] AS DATETIME2) AS LINEITEM_TIMESTAMP
    ,TRY_CAST(SI.[dob] AS DATETIME2) AS ITEM_DATE
    ,TRY_CAST(SI.[dob] AS DATETIME2) AS ORDER_DATE
    ,NULL AS VOID_FLAG
    ,SI.[id] AS LINE_ID
    ,ROW_NUMBER() OVER(PARTITION BY SI.[storeId] ,SI.[dob] ,SI.[checks_id] ORDER BY SI.[Id]) AS LINE_ORDER
    ,TRY_CAST(SI.[dob] AS DATETIME2) AS TRADING_DATE
	,CONCAT_WS(''-'', SI.[storeId] ,SI.[responsibleEmployeeId]) AS EMPLOYEE_SRC_SUB
	,SI.[typeId] AS ITEM_SRC_KEY
	,SI.[orderMode_id] AS OCCASSION_SRC_SUB
	,SI.[parentItemId] AS PARENT_ITEM_SRC_KEY

FROM
	[int_ncraloha001].[DL_SALES_STREAM_ITEMS] SI

UNION ALL

SELECT
    CONCAT_WS(''-'', [storeId] ,[dob] ,[checks_id], [id]) AS SUB_SRC_KEY
    ,CONCAT_WS(''-'', [storeId] ,[dob] ,[checks_id]) AS HEADER_ID
	  ,[storeId] AS LOCATION_ID
    ,CASE WHEN LOWER([type])  LIKE ''%tax%''
		THEN ''TAX''
		ELSE ''SVC''
	 END AS LINEITEM_TYPE
    ,NULL AS GROSS_VALUE
    ,TRY_CAST([amount] AS FLOAT) AS TAX_VALUE
    ,NULL AS NET_VALUE
    ,NULL AS QUANTITY
    ,NULL AS QUANTITY_INV
    ,TRY_CAST([createdOn] AS DATETIME2) AS LINEITEM_TIMESTAMP
    ,TRY_CAST([dob] AS DATETIME2) AS ITEM_DATE
    ,TRY_CAST([dob] AS DATETIME2) AS ORDER_DATE
    ,NULL AS VOID_FLAG
    ,[id] AS LINE_ID
    ,NULL AS LINE_ORDER
    ,TRY_CAST([dob] AS DATETIME2) AS TRADING_DATE
	,NULL AS EMPLOYEE_SRC_SUB
	,[typeId] AS ITEM_SRC_KEY
	,NULL AS OCCASSION_SRC_SUB
	,NULL AS PARENT_ITEM_SRC_KEY

FROM
    [int_ncraloha001].[DL_SALES_STREAM_SURCHARGES]

UNION ALL

SELECT
    CONCAT_WS(''-'', [storeId] ,[dob] ,[checks_id], [id]) AS SUB_SRC_KEY
    ,CONCAT_WS(''-'', [storeId] ,[dob] ,[checks_id]) AS HEADER_ID
	  ,[storeId] AS LOCATION_ID
    ,CASE WHEN LOWER([type])  LIKE ''%combo%''
		THEN ''DEAL''
		ELSE ''DEAL''
	 END AS LINEITEM_TYPE
    ,TRY_CAST([amount] AS FLOAT) AS GROSS_VALUE
    ,NULL AS TAX_VALUE
    ,NULL  AS NET_VALUE
    ,NULL AS QUANTITY
    ,NULL AS QUANTITY_INV
    ,TRY_CAST([createdOn] AS DATETIME2) AS LINEITEM_TIMESTAMP
    ,TRY_CAST([dob] AS DATETIME2) AS ITEM_DATE
    ,TRY_CAST([dob] AS DATETIME2) AS ORDER_DATE
    ,NULL AS VOID_FLAG
    ,[id] AS LINE_ID
    ,NULL AS LINE_ORDER
    ,TRY_CAST([dob] AS DATETIME2) AS TRADING_DATE
	,CONCAT_WS(''-'', [storeId] ,[responsibleEmployees_employee_id]) AS EMPLOYEE_SRC_SUB
	,[typeId] AS ITEM_SRC_KEY
	,NULL AS OCCASSION_SRC_SUB
	,NULL AS PARENT_ITEM_SRC_KEY

FROM
    [int_ncraloha001].[DL_SALES_STREAM_PROMOS]

UNION ALL


SELECT
    CONCAT_WS(''-'', [storeId] ,[dob] ,[checks_id], [id]) AS SUB_SRC_KEY
    ,CONCAT_WS(''-'', [storeId] ,[dob] ,[checks_id]) AS HEADER_ID
	  ,[storeId] AS LOCATION_ID
    ,CASE WHEN LOWER([type])  LIKE ''%default%''
		THEN ''DISCOUNT''
		ELSE ''DISCOUNT''
	 END AS LINEITEM_TYPE
    ,TRY_CAST([amount] AS FLOAT) * -1 AS GROSS_VALUE
    ,NULL AS TAX_VALUE
    ,NULL AS NET_VALUE
    ,1 AS QUANTITY
    ,NULL AS QUANTITY_INV
    ,TRY_CAST([createdOn] AS DATETIME2) AS LINEITEM_TIMESTAMP
    ,TRY_CAST([dob] AS DATETIME2) AS ITEM_DATE
    ,TRY_CAST([dob] AS DATETIME2) AS ORDER_DATE
    ,NULL AS VOID_FLAG
    ,[id] AS LINE_ID
    ,NULL AS LINE_ORDER
    ,TRY_CAST([dob] AS DATETIME2) AS TRADING_DATE
	,CONCAT_WS(''-'', [storeId] ,[responsibleEmployees_employee_id]) AS EMPLOYEE_SRC_SUB
	,[typeId] AS ITEM_SRC_KEY
	,NULL AS OCCASSION_SRC_SUB
	,NULL AS PARENT_ITEM_SRC_KEY

FROM
    [int_ncraloha001].[DL_SALES_STREAM_COMPS]

UNION ALL

SELECT
    CONCAT_WS(''-'', [storeId] ,[dob] ,[checks_id], [id]) AS SUB_SRC_KEY
    ,CONCAT_WS(''-'', [storeId] ,[dob] ,[checks_id]) AS HEADER_ID
	  ,[storeId] AS LOCATION_ID
    ,CASE WHEN LOWER([type])  LIKE ''%custom%''
		THEN ''TENDER''
		ELSE ''TENDER''
	 END AS LINEITEM_TYPE
    ,TRY_CAST([amount] AS FLOAT) AS GROSS_VALUE
    ,NULL AS TAX_VALUE
    ,NULL AS NET_VALUE
    ,1 AS QUANTITY
    ,NULL AS QUANTITY_INV
    ,TRY_CAST([createdOn] AS DATETIME2) AS LINEITEM_TIMESTAMP
    ,TRY_CAST([dob] AS DATETIME2) AS ITEM_DATE
    ,TRY_CAST([dob] AS DATETIME2) AS ORDER_DATE
    ,NULL AS VOID_FLAG
    ,[id] AS LINE_ID
    ,NULL AS LINE_ORDER
    ,TRY_CAST([dob] AS DATETIME2) AS TRADING_DATE
	,CONCAT_WS(''-'', [storeId] ,[responsibleEmployees_employee_id]) AS EMPLOYEE_SRC_SUB
	,[typeId] AS ITEM_SRC_KEY
	,NULL AS OCCASSION_SRC_SUB
	,NULL AS PARENT_ITEM_SRC_KEY

FROM
    [int_ncraloha001].[DL_SALES_STREAM_PAYMENTS]


) SUB

INNER JOIN
(
SELECT
	CONCAT_WS(''-'', DS.[storeId] ,DS.[dob] ,DS.[id]) AS HEADER_ID
	,TRY_CAST(DS.[grandAmount] AS FLOAT) AS GRAND_TOTAL_SRC
	,TRY_CAST(DS.[total] AS FLOAT) AS GROSS_SALES_SRC
	,TRY_CAST(DS.[netAmount] AS FLOAT) AS NET_SALES_SRC
	,TRY_CAST(DS.[guestCounting_guests] AS FLOAT) AS GUEST_COUNT
	,1 AS ORDER_COUNT
    ,TRY_CAST(DS.[dob] AS DATETIME2) AS ORDER_DATE
	,TRY_CAST(CD.OPEN_TIME AS DATETIME2) AS OPEN_TIME
	,TRY_CAST(CD.CLOSE_TIME AS DATETIME2) AS CLOSE_TIME
	,PM.PAYMENT
	,DS.[groupInfo_label] AS ORDER_INFO
	,DS.[takeOutOrderId] AS EXTERNAL_REFERENCE
    ,TRY_CAST(DS.[dob] AS DATETIME2) AS TRADING_DATE
	,DS.[revenueCenter_id] AS REVENUE_CENTER_SRC_KEY
	,''CLOSED'' AS ORDER_STATUS
FROM
	[int_ncraloha001].[DL_SALES_STREAM] DS
INNER JOIN
	[int_ncraloha001].[DL_SALES_CHECK] VC 
ON DS.[id] = VC.[id]
AND DS.[storeId] = VC.[storeId]
AND DS.[dob] = VC.[dob]
AND [isEmpty] != ''1''
AND [isTraining] != ''1''
AND [isClosed] = ''1''

INNER JOIN
(
SELECT
	[storeId]
	,[dob]
	,[checks_id]
	,MAX(TRY_CAST([time] AS DATETIME2)) AS CLOSE_TIME
	,MIN(TRY_CAST([time] AS DATETIME2)) AS OPEN_TIME
FROM
	[int_ncraloha001].[DL_SALES_STREAM_EVENTS]
GROUP BY
	[storeId]
	,[dob]
	,[checks_id]
	) CD
ON DS.[id] = CD.[checks_id]
AND DS.[storeId] = CD.[storeId]
AND DS.[dob] = CD.[dob]

INNER JOIN
(
SELECT
	[storeId]
	,[dob]
	,[checks_id]
	,SUM(TRY_CAST(AMOUNT AS FLOAT)) AS PAYMENT
FROM
	[int_ncraloha001].[DL_SALES_STREAM_PAYMENTS]
GROUP BY
	[storeId]
	,[dob]
	,[checks_id]
	) PM
ON DS.[id] = PM.[checks_id]
AND DS.[storeId] = PM.[storeId]
AND DS.[dob] = PM.[dob]
) HDR
ON SUB.HEADER_ID = HDR.HEADER_ID
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["SUB_SRC_KEY", "HEADER_ID", "LOCATION_ID", "LINEITEM_TYPE", "GROSS_VALUE", "TAX_VALUE", "NET_VALUE", "QUANTITY", "QUANTITY_INV", "LINEITEM_TIMESTAMP", "ITEM_DATE", "ORDER_DATE", "VOID_FLAG", "LINE_ID", "LINE_ORDER", "TRADING_DATE", "EMPLOYEE_SRC_SUB", "ITEM_SRC_KEY", "OCCASSION_SRC_SUB", "PARENT_ITEM_SRC_KEY", "EMPLOYEE_SRC_KEY", "SRC_KEY", "GRAND_TOTAL_SRC", "DISCOUNT_GROSS", "NET_SALES_SRC", "NET_SALES", "TAX_TOTAL", "GROSS_SALES_SRC", "PAYMENT", "PAYMENT_STATUS", "ORDER_STATUS", "GROSS_SALES", "SVC_CHARGE__TOTAL", "ITEM_COUNT", "GUEST_COUNT", "ORDER_COUNT", "OPEN_TIME", "CLOSE_TIME", "ORDER_INFO", "EXTERNAL_REFERENCE", "REVENUE_CENTER_SRC_KEY", "OCCASSION_SRC_KEY"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Line Item Detail';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Line Item Detail', N'NCR_LINE_ITEM_DETAIL', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_LINE_ITEM_DETAIL'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_LINE_ITEM_DETAIL];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_LINE_ITEM_DETAIL]
FROM (
SELECT
	SUB.*
	,MAX(SUB.EMPLOYEE_SRC_SUB) OVER(PARTITION BY SUB.HEADER_ID) AS EMPLOYEE_SRC_KEY
	,CONCAT_WS(''-'',SUB_SRC_KEY, LINEITEM_TYPE) AS SRC_KEY
	,HDR.GRAND_TOTAL_SRC
	,SUM(CASE WHEN SUB.LINEITEM_TYPE IN (''COMP'',''DISCOUNT'') THEN ISNULL(SUB.GROSS_VALUE,0) ELSE 0 END) OVER(PARTITION BY SUB.HEADER_ID) AS DISCOUNT_GROSS
	,HDR.NET_SALES_SRC
	,SUM(ISNULL(SUB.NET_VALUE,0)) OVER(PARTITION BY SUB.HEADER_ID) AS NET_SALES
	,SUM(ISNULL(SUB.TAX_VALUE,0)) OVER(PARTITION BY SUB.HEADER_ID) AS TAX_TOTAL
	,HDR.GROSS_SALES_SRC
	,HDR.PAYMENT
	,CASE WHEN HDR.PAYMENT >= HDR.GROSS_SALES_SRC THEN ''PAID'' ELSE
		CASE WHEN HDR.PAYMENT IS NOT NULL THEN ''PARTIAL'' ELSE NULL END END AS PAYMENT_STATUS
	,HDR.ORDER_STATUS
	,SUM(CASE WHEN SUB.LINEITEM_TYPE != ''TENDER'' THEN ISNULL(SUB.GROSS_VALUE,0) ELSE 0 END) OVER(PARTITION BY SUB.HEADER_ID) AS GROSS_SALES
	,SUM(CASE WHEN SUB.LINEITEM_TYPE != ''TAX'' THEN ISNULL(SUB.TAX_VALUE,0) ELSE 0 END) OVER(PARTITION BY SUB.HEADER_ID) AS SVC_CHARGE__TOTAL
	,SUM(ISNULL(SUB.QUANTITY,0)) OVER(PARTITION BY SUB.HEADER_ID) AS ITEM_COUNT
	,HDR.GUEST_COUNT
	,HDR.ORDER_COUNT
	,HDR.OPEN_TIME
	,HDR.CLOSE_TIME
	,HDR.ORDER_INFO
	,HDR.EXTERNAL_REFERENCE
	,HDR.REVENUE_CENTER_SRC_KEY
	,MAX(SUB.OCCASSION_SRC_SUB)  OVER(PARTITION BY SUB.HEADER_ID) AS OCCASSION_SRC_KEY
FROM
(
SELECT
	CONCAT_WS(''-'', SI.[storeId] ,SI.[dob] ,SI.[checks_id], SI.[id]) AS SUB_SRC_KEY
	,CONCAT_WS(''-'', SI.[storeId] ,SI.[dob] ,SI.[checks_id]) AS HEADER_ID
	,SI.[storeId] AS LOCATION_ID
	,CASE WHEN SI.[modifierInfo_type] IS NOT NULL
		THEN ''MOD''
		ELSE ''PROD''
	END AS LINEITEM_TYPE
	,TRY_CAST(SI.[amount] AS FLOAT) AS GROSS_VALUE
	,NULL AS TAX_VALUE
	,TRY_CAST(SI.[Netamount] AS FLOAT) AS NET_VALUE
	,TRY_CAST(SI.[quantity] AS FLOAT) AS QUANTITY
	,TRY_CAST(SI.[quantity] AS FLOAT) AS QUANTITY_INV
    ,TRY_CAST(SI.[createdOn] AS DATETIME2) AS LINEITEM_TIMESTAMP
    ,TRY_CAST(SI.[dob] AS DATETIME2) AS ITEM_DATE
    ,TRY_CAST(SI.[dob] AS DATETIME2) AS ORDER_DATE
    ,NULL AS VOID_FLAG
    ,SI.[id] AS LINE_ID
    ,ROW_NUMBER() OVER(PARTITION BY SI.[storeId] ,SI.[dob] ,SI.[checks_id] ORDER BY SI.[Id]) AS LINE_ORDER
    ,TRY_CAST(SI.[dob] AS DATETIME2) AS TRADING_DATE
	,CONCAT_WS(''-'', SI.[storeId] ,SI.[responsibleEmployeeId]) AS EMPLOYEE_SRC_SUB
	,SI.[typeId] AS ITEM_SRC_KEY
	,SI.[orderMode_id] AS OCCASSION_SRC_SUB
	,SI.[parentItemId] AS PARENT_ITEM_SRC_KEY

FROM
	[int_ncraloha001].[DL_SALES_STREAM_ITEMS] SI

UNION ALL

SELECT
    CONCAT_WS(''-'', [storeId] ,[dob] ,[checks_id], [id]) AS SUB_SRC_KEY
    ,CONCAT_WS(''-'', [storeId] ,[dob] ,[checks_id]) AS HEADER_ID
	  ,[storeId] AS LOCATION_ID
    ,CASE WHEN LOWER([type])  LIKE ''%tax%''
		THEN ''TAX''
		ELSE ''SVC''
	 END AS LINEITEM_TYPE
    ,NULL AS GROSS_VALUE
    ,TRY_CAST([amount] AS FLOAT) AS TAX_VALUE
    ,NULL AS NET_VALUE
    ,NULL AS QUANTITY
    ,NULL AS QUANTITY_INV
    ,TRY_CAST([createdOn] AS DATETIME2) AS LINEITEM_TIMESTAMP
    ,TRY_CAST([dob] AS DATETIME2) AS ITEM_DATE
    ,TRY_CAST([dob] AS DATETIME2) AS ORDER_DATE
    ,NULL AS VOID_FLAG
    ,[id] AS LINE_ID
    ,NULL AS LINE_ORDER
    ,TRY_CAST([dob] AS DATETIME2) AS TRADING_DATE
	,NULL AS EMPLOYEE_SRC_SUB
	,[typeId] AS ITEM_SRC_KEY
	,NULL AS OCCASSION_SRC_SUB
	,NULL AS PARENT_ITEM_SRC_KEY

FROM
    [int_ncraloha001].[DL_SALES_STREAM_SURCHARGES]

UNION ALL

SELECT
    CONCAT_WS(''-'', [storeId] ,[dob] ,[checks_id], [id]) AS SUB_SRC_KEY
    ,CONCAT_WS(''-'', [storeId] ,[dob] ,[checks_id]) AS HEADER_ID
	  ,[storeId] AS LOCATION_ID
    ,CASE WHEN LOWER([type])  LIKE ''%combo%''
		THEN ''DEAL''
		ELSE ''DEAL''
	 END AS LINEITEM_TYPE
    ,TRY_CAST([amount] AS FLOAT) AS GROSS_VALUE
    ,NULL AS TAX_VALUE
    ,NULL  AS NET_VALUE
    ,NULL AS QUANTITY
    ,NULL AS QUANTITY_INV
    ,TRY_CAST([createdOn] AS DATETIME2) AS LINEITEM_TIMESTAMP
    ,TRY_CAST([dob] AS DATETIME2) AS ITEM_DATE
    ,TRY_CAST([dob] AS DATETIME2) AS ORDER_DATE
    ,NULL AS VOID_FLAG
    ,[id] AS LINE_ID
    ,NULL AS LINE_ORDER
    ,TRY_CAST([dob] AS DATETIME2) AS TRADING_DATE
	,CONCAT_WS(''-'', [storeId] ,[responsibleEmployees_employee_id]) AS EMPLOYEE_SRC_SUB
	,[typeId] AS ITEM_SRC_KEY
	,NULL AS OCCASSION_SRC_SUB
	,NULL AS PARENT_ITEM_SRC_KEY

FROM
    [int_ncraloha001].[DL_SALES_STREAM_PROMOS]

UNION ALL


SELECT
    CONCAT_WS(''-'', [storeId] ,[dob] ,[checks_id], [id]) AS SUB_SRC_KEY
    ,CONCAT_WS(''-'', [storeId] ,[dob] ,[checks_id]) AS HEADER_ID
	  ,[storeId] AS LOCATION_ID
    ,CASE WHEN LOWER([type])  LIKE ''%default%''
		THEN ''DISCOUNT''
		ELSE ''DISCOUNT''
	 END AS LINEITEM_TYPE
    ,TRY_CAST([amount] AS FLOAT) * -1 AS GROSS_VALUE
    ,NULL AS TAX_VALUE
    ,NULL AS NET_VALUE
    ,1 AS QUANTITY
    ,NULL AS QUANTITY_INV
    ,TRY_CAST([createdOn] AS DATETIME2) AS LINEITEM_TIMESTAMP
    ,TRY_CAST([dob] AS DATETIME2) AS ITEM_DATE
    ,TRY_CAST([dob] AS DATETIME2) AS ORDER_DATE
    ,NULL AS VOID_FLAG
    ,[id] AS LINE_ID
    ,NULL AS LINE_ORDER
    ,TRY_CAST([dob] AS DATETIME2) AS TRADING_DATE
	,CONCAT_WS(''-'', [storeId] ,[responsibleEmployees_employee_id]) AS EMPLOYEE_SRC_SUB
	,[typeId] AS ITEM_SRC_KEY
	,NULL AS OCCASSION_SRC_SUB
	,NULL AS PARENT_ITEM_SRC_KEY

FROM
    [int_ncraloha001].[DL_SALES_STREAM_COMPS]

UNION ALL

SELECT
    CONCAT_WS(''-'', [storeId] ,[dob] ,[checks_id], [id]) AS SUB_SRC_KEY
    ,CONCAT_WS(''-'', [storeId] ,[dob] ,[checks_id]) AS HEADER_ID
	  ,[storeId] AS LOCATION_ID
    ,CASE WHEN LOWER([type])  LIKE ''%custom%''
		THEN ''TENDER''
		ELSE ''TENDER''
	 END AS LINEITEM_TYPE
    ,TRY_CAST([amount] AS FLOAT) AS GROSS_VALUE
    ,NULL AS TAX_VALUE
    ,NULL AS NET_VALUE
    ,1 AS QUANTITY
    ,NULL AS QUANTITY_INV
    ,TRY_CAST([createdOn] AS DATETIME2) AS LINEITEM_TIMESTAMP
    ,TRY_CAST([dob] AS DATETIME2) AS ITEM_DATE
    ,TRY_CAST([dob] AS DATETIME2) AS ORDER_DATE
    ,NULL AS VOID_FLAG
    ,[id] AS LINE_ID
    ,NULL AS LINE_ORDER
    ,TRY_CAST([dob] AS DATETIME2) AS TRADING_DATE
	,CONCAT_WS(''-'', [storeId] ,[responsibleEmployees_employee_id]) AS EMPLOYEE_SRC_SUB
	,[typeId] AS ITEM_SRC_KEY
	,NULL AS OCCASSION_SRC_SUB
	,NULL AS PARENT_ITEM_SRC_KEY

FROM
    [int_ncraloha001].[DL_SALES_STREAM_PAYMENTS]


) SUB

INNER JOIN
(
SELECT
	CONCAT_WS(''-'', DS.[storeId] ,DS.[dob] ,DS.[id]) AS HEADER_ID
	,TRY_CAST(DS.[grandAmount] AS FLOAT) AS GRAND_TOTAL_SRC
	,TRY_CAST(DS.[total] AS FLOAT) AS GROSS_SALES_SRC
	,TRY_CAST(DS.[netAmount] AS FLOAT) AS NET_SALES_SRC
	,TRY_CAST(DS.[guestCounting_guests] AS FLOAT) AS GUEST_COUNT
	,1 AS ORDER_COUNT
    ,TRY_CAST(DS.[dob] AS DATETIME2) AS ORDER_DATE
	,TRY_CAST(CD.OPEN_TIME AS DATETIME2) AS OPEN_TIME
	,TRY_CAST(CD.CLOSE_TIME AS DATETIME2) AS CLOSE_TIME
	,PM.PAYMENT
	,DS.[groupInfo_label] AS ORDER_INFO
	,DS.[takeOutOrderId] AS EXTERNAL_REFERENCE
    ,TRY_CAST(DS.[dob] AS DATETIME2) AS TRADING_DATE
	,DS.[revenueCenter_id] AS REVENUE_CENTER_SRC_KEY
	,''CLOSED'' AS ORDER_STATUS
FROM
	[int_ncraloha001].[DL_SALES_STREAM] DS
INNER JOIN
	[int_ncraloha001].[DL_SALES_CHECK] VC 
ON DS.[id] = VC.[id]
AND DS.[storeId] = VC.[storeId]
AND DS.[dob] = VC.[dob]
AND [isEmpty] != ''1''
AND [isTraining] != ''1''
AND [isClosed] = ''1''

INNER JOIN
(
SELECT
	[storeId]
	,[dob]
	,[checks_id]
	,MAX(TRY_CAST([time] AS DATETIME2)) AS CLOSE_TIME
	,MIN(TRY_CAST([time] AS DATETIME2)) AS OPEN_TIME
FROM
	[int_ncraloha001].[DL_SALES_STREAM_EVENTS]
GROUP BY
	[storeId]
	,[dob]
	,[checks_id]
	) CD
ON DS.[id] = CD.[checks_id]
AND DS.[storeId] = CD.[storeId]
AND DS.[dob] = CD.[dob]

INNER JOIN
(
SELECT
	[storeId]
	,[dob]
	,[checks_id]
	,SUM(TRY_CAST(AMOUNT AS FLOAT)) AS PAYMENT
FROM
	[int_ncraloha001].[DL_SALES_STREAM_PAYMENTS]
GROUP BY
	[storeId]
	,[dob]
	,[checks_id]
	) PM
ON DS.[id] = PM.[checks_id]
AND DS.[storeId] = PM.[storeId]
AND DS.[dob] = PM.[dob]
) HDR
ON SUB.HEADER_ID = HDR.HEADER_ID
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, N'["SUB_SRC_KEY", "HEADER_ID", "LOCATION_ID", "LINEITEM_TYPE", "GROSS_VALUE", "TAX_VALUE", "NET_VALUE", "QUANTITY", "QUANTITY_INV", "LINEITEM_TIMESTAMP", "ITEM_DATE", "ORDER_DATE", "VOID_FLAG", "LINE_ID", "LINE_ORDER", "TRADING_DATE", "EMPLOYEE_SRC_SUB", "ITEM_SRC_KEY", "OCCASSION_SRC_SUB", "PARENT_ITEM_SRC_KEY", "EMPLOYEE_SRC_KEY", "SRC_KEY", "GRAND_TOTAL_SRC", "DISCOUNT_GROSS", "NET_SALES_SRC", "NET_SALES", "TAX_TOTAL", "GROSS_SALES_SRC", "PAYMENT", "PAYMENT_STATUS", "ORDER_STATUS", "GROSS_SALES", "SVC_CHARGE__TOTAL", "ITEM_COUNT", "GUEST_COUNT", "ORDER_COUNT", "OPEN_TIME", "CLOSE_TIME", "ORDER_INFO", "EXTERNAL_REFERENCE", "REVENUE_CENTER_SRC_KEY", "OCCASSION_SRC_KEY"]', GETDATE(), GETDATE());
END
GO

-- Step: Location (Tier 1)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Location')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET [staging_table] = N'NCR_LOCATION',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_LOCATION'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_LOCATION];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_LOCATION]
FROM (
SELECT [storeId]
      ,[insightId]
      ,[name]
      ,[link]
      ,[LOADTS_UTC]
	,1 AS BOTTOM_LEVEL
	,''Location'' AS LEVEL_NAME
  FROM [int_ncraloha001].[DL_STORE]
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["storeId", "insightId", "name", "link", "LOADTS_UTC", "BOTTOM_LEVEL", "LEVEL_NAME"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Location';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Location', N'NCR_LOCATION', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_LOCATION'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_LOCATION];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_LOCATION]
FROM (
SELECT [storeId]
      ,[insightId]
      ,[name]
      ,[link]
      ,[LOADTS_UTC]
	,1 AS BOTTOM_LEVEL
	,''Location'' AS LEVEL_NAME
  FROM [int_ncraloha001].[DL_STORE]
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, N'["storeId", "insightId", "name", "link", "LOADTS_UTC", "BOTTOM_LEVEL", "LEVEL_NAME"]', GETDATE(), GETDATE());
END
GO

-- Step: Modifications (Tier 1)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Modifications')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET [staging_table] = N'NCR_MODS',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_MODS'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_MODS];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_MODS]
FROM (
SELECT DISTINCT
	C.id AS PARENT_ITEM_SRC_KEY
	,SI.[typeId] AS ITEM_SRC_KEY
        ,''Modification'' AS LEVEL_NAME
	,SI.label
	,1 AS BOTTOM_LEVEL
FROM
	[int_ncraloha001].[DL_SALES_STREAM_ITEMS] SI
INNER JOIN
	[int_ncraloha001].[DL_SALES_STREAM_ITEMS_CATEGORIES] C
ON SI.storeId = C.storeId
AND SI.dob = C.dob
AND SI.checks_id = C.checks_id
AND SI.id = C.items_id
AND C.[type] = ''sales''

WHERE SI.[modifierInfo_type] IS NOT NULL

UNION ALL

SELECT DISTINCT
	NULL AS PARENT_ITEM_SRC_KEY
	,C.id AS ITEM_SRC_KEY
        ,''Modification Category'' AS LEVEL_NAME
	,C.name
	,0 AS BOTTOM_LEVEL
FROM
	[int_ncraloha001].[DL_SALES_STREAM_ITEMS] SI
INNER JOIN
	[int_ncraloha001].[DL_SALES_STREAM_ITEMS_CATEGORIES] C
ON SI.storeId = C.storeId
AND SI.dob = C.dob
AND SI.checks_id = C.checks_id
AND SI.id = C.items_id
AND C.[type] = ''sales''


WHERE SI.[modifierInfo_type] IS NOT NULL
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["PARENT_ITEM_SRC_KEY", "ITEM_SRC_KEY", "LEVEL_NAME", "label", "BOTTOM_LEVEL"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Modifications';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Modifications', N'NCR_MODS', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_MODS'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_MODS];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_MODS]
FROM (
SELECT DISTINCT
	C.id AS PARENT_ITEM_SRC_KEY
	,SI.[typeId] AS ITEM_SRC_KEY
        ,''Modification'' AS LEVEL_NAME
	,SI.label
	,1 AS BOTTOM_LEVEL
FROM
	[int_ncraloha001].[DL_SALES_STREAM_ITEMS] SI
INNER JOIN
	[int_ncraloha001].[DL_SALES_STREAM_ITEMS_CATEGORIES] C
ON SI.storeId = C.storeId
AND SI.dob = C.dob
AND SI.checks_id = C.checks_id
AND SI.id = C.items_id
AND C.[type] = ''sales''

WHERE SI.[modifierInfo_type] IS NOT NULL

UNION ALL

SELECT DISTINCT
	NULL AS PARENT_ITEM_SRC_KEY
	,C.id AS ITEM_SRC_KEY
        ,''Modification Category'' AS LEVEL_NAME
	,C.name
	,0 AS BOTTOM_LEVEL
FROM
	[int_ncraloha001].[DL_SALES_STREAM_ITEMS] SI
INNER JOIN
	[int_ncraloha001].[DL_SALES_STREAM_ITEMS_CATEGORIES] C
ON SI.storeId = C.storeId
AND SI.dob = C.dob
AND SI.checks_id = C.checks_id
AND SI.id = C.items_id
AND C.[type] = ''sales''


WHERE SI.[modifierInfo_type] IS NOT NULL
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, N'["PARENT_ITEM_SRC_KEY", "ITEM_SRC_KEY", "LEVEL_NAME", "label", "BOTTOM_LEVEL"]', GETDATE(), GETDATE());
END
GO

-- Step: Occasion (Tier 1)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Occasion')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET [staging_table] = N'NCR_OCCASSION',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_OCCASSION'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_OCCASSION];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_OCCASSION]
FROM (
SELECT DISTINCT
	[orderMode_id]
	,[orderMode_label]
	,''Occassion'' AS LEVEL_NAME
	,1 AS BOTTOM_LEVEL
  
FROM [int_ncraloha001].[DL_SALES_STREAM_ITEMS]
WHERE [orderMode_id] IS NOT NULL
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["orderMode_id", "orderMode_label", "LEVEL_NAME", "BOTTOM_LEVEL"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Occasion';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Occasion', N'NCR_OCCASSION', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_OCCASSION'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_OCCASSION];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_OCCASSION]
FROM (
SELECT DISTINCT
	[orderMode_id]
	,[orderMode_label]
	,''Occassion'' AS LEVEL_NAME
	,1 AS BOTTOM_LEVEL
  
FROM [int_ncraloha001].[DL_SALES_STREAM_ITEMS]
WHERE [orderMode_id] IS NOT NULL
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, N'["orderMode_id", "orderMode_label", "LEVEL_NAME", "BOTTOM_LEVEL"]', GETDATE(), GETDATE());
END
GO

-- Step: Product (Tier 1)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Product')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET [staging_table] = N'NCR_PROD',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_PROD'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_PROD];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_PROD]
FROM (
SELECT
	*
FROM
(
SELECT
	PARENT_ITEM_SRC_KEY
	,ITEM_SRC_KEY
	,LEVEL_NAME
	,label
	,BOTTOM_LEVEL
	,ROW_NUMBER() OVER(PARTITION BY ITEM_SRC_KEY ORDER BY LAST_DOB DESC) AS RN
FROM
(
	SELECT DISTINCT
		C.id AS PARENT_ITEM_SRC_KEY
		,SI.[typeId] AS ITEM_SRC_KEY
			,''Product'' AS LEVEL_NAME
		,SI.label AS label
		,1 AS BOTTOM_LEVEL
		,MAX(SI.dOB) OVER(PARTITION BY C.id,SI.[typeId],SI.label) AS LAST_DOB
	FROM
		[int_ncraloha001].[DL_SALES_STREAM_ITEMS] SI
	INNER JOIN
		[int_ncraloha001].[DL_SALES_STREAM_ITEMS_CATEGORIES] C
	ON SI.storeId = C.storeId
	AND SI.dob = C.dob
	AND SI.checks_id = C.checks_id
	AND SI.id = C.items_id
	AND C.[type] = ''sales''

	WHERE SI.[modifierInfo_type] IS NULL

	UNION ALL

	SELECT DISTINCT
		NULL AS PARENT_ITEM_SRC_KEY
		,C.id AS ITEM_SRC_KEY
			,''Product Category'' AS LEVEL_NAME
		,C.name AS label
		,0 AS BOTTOM_LEVEL
		,MAX(SI.dOB) OVER(PARTITION BY C.id, C.name ) AS LAST_DOB
	FROM
		[int_ncraloha001].[DL_SALES_STREAM_ITEMS] SI
	INNER JOIN
		[int_ncraloha001].[DL_SALES_STREAM_ITEMS_CATEGORIES] C
	ON SI.storeId = C.storeId
	AND SI.dob = C.dob
	AND SI.checks_id = C.checks_id
	AND SI.id = C.items_id
	AND C.[type] = ''sales''

	WHERE SI.[modifierInfo_type] IS NULL
) SUB
) SUB2
WHERE RN = 1
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["PARENT_ITEM_SRC_KEY", "ITEM_SRC_KEY", "LEVEL_NAME", "label", "BOTTOM_LEVEL"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Product';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Product', N'NCR_PROD', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_PROD'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_PROD];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_PROD]
FROM (
SELECT
	*
FROM
(
SELECT
	PARENT_ITEM_SRC_KEY
	,ITEM_SRC_KEY
	,LEVEL_NAME
	,label
	,BOTTOM_LEVEL
	,ROW_NUMBER() OVER(PARTITION BY ITEM_SRC_KEY ORDER BY LAST_DOB DESC) AS RN
FROM
(
	SELECT DISTINCT
		C.id AS PARENT_ITEM_SRC_KEY
		,SI.[typeId] AS ITEM_SRC_KEY
			,''Product'' AS LEVEL_NAME
		,SI.label AS label
		,1 AS BOTTOM_LEVEL
		,MAX(SI.dOB) OVER(PARTITION BY C.id,SI.[typeId],SI.label) AS LAST_DOB
	FROM
		[int_ncraloha001].[DL_SALES_STREAM_ITEMS] SI
	INNER JOIN
		[int_ncraloha001].[DL_SALES_STREAM_ITEMS_CATEGORIES] C
	ON SI.storeId = C.storeId
	AND SI.dob = C.dob
	AND SI.checks_id = C.checks_id
	AND SI.id = C.items_id
	AND C.[type] = ''sales''

	WHERE SI.[modifierInfo_type] IS NULL

	UNION ALL

	SELECT DISTINCT
		NULL AS PARENT_ITEM_SRC_KEY
		,C.id AS ITEM_SRC_KEY
			,''Product Category'' AS LEVEL_NAME
		,C.name AS label
		,0 AS BOTTOM_LEVEL
		,MAX(SI.dOB) OVER(PARTITION BY C.id, C.name ) AS LAST_DOB
	FROM
		[int_ncraloha001].[DL_SALES_STREAM_ITEMS] SI
	INNER JOIN
		[int_ncraloha001].[DL_SALES_STREAM_ITEMS_CATEGORIES] C
	ON SI.storeId = C.storeId
	AND SI.dob = C.dob
	AND SI.checks_id = C.checks_id
	AND SI.id = C.items_id
	AND C.[type] = ''sales''

	WHERE SI.[modifierInfo_type] IS NULL
) SUB
) SUB2
WHERE RN = 1
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, N'["PARENT_ITEM_SRC_KEY", "ITEM_SRC_KEY", "LEVEL_NAME", "label", "BOTTOM_LEVEL"]', GETDATE(), GETDATE());
END
GO

-- Step: Revenue Center (Tier 1)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Revenue Center')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET [staging_table] = N'NCR_REVC',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_REVC'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_REVC];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_REVC]
FROM (
SELECT DISTINCT
      [revenueCenter_id]
      ,[revenueCenter_label]
      ,''Revenue Center'' AS Level_NAME
      ,1 as BOTTOM_LEVEL
  FROM [int_ncraloha001].[DL_SALES_STREAM]
  WHERE [revenueCenter_id] IS NOT NULL
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["revenueCenter_id", "revenueCenter_label", "Level_NAME", "BOTTOM_LEVEL"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Revenue Center';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Revenue Center', N'NCR_REVC', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_REVC'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_REVC];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_REVC]
FROM (
SELECT DISTINCT
      [revenueCenter_id]
      ,[revenueCenter_label]
      ,''Revenue Center'' AS Level_NAME
      ,1 as BOTTOM_LEVEL
  FROM [int_ncraloha001].[DL_SALES_STREAM]
  WHERE [revenueCenter_id] IS NOT NULL
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, N'["revenueCenter_id", "revenueCenter_label", "Level_NAME", "BOTTOM_LEVEL"]', GETDATE(), GETDATE());
END
GO

-- Step: Service Charge (Tier 1)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Service Charge')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET [staging_table] = N'NCR_SVC',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_SVC'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_SVC];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_SVC]
FROM (
SELECT
	*
FROM
(
SELECT
	PARENT_ITEM_SRC_KEY
	,ITEM_SRC_KEY
	,LEVEL_NAME
	,label
	,BOTTOM_LEVEL
	,ROW_NUMBER() OVER(PARTITION BY ITEM_SRC_KEY ORDER BY LAST_DOB DESC) AS RN
FROM
(
	SELECT DISTINCT
		NULL AS PARENT_ITEM_SRC_KEY
		,SI.[typeId] AS ITEM_SRC_KEY
			,''Service Charge'' AS LEVEL_NAME
		,SI.label AS label
		,1 AS BOTTOM_LEVEL
		,MAX(SI.dOB) OVER(PARTITION BY SI.[typeId],SI.label) AS LAST_DOB
	FROM
		[int_ncraloha001].[DL_SALES_STREAM_SURCHARGES] SI
	WHERE LOWER([type]) NOT LIKE ''%tax%''

) SUB
) SUB2
WHERE RN = 1
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["PARENT_ITEM_SRC_KEY", "ITEM_SRC_KEY", "LEVEL_NAME", "label", "BOTTOM_LEVEL", "RN"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Service Charge';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Service Charge', N'NCR_SVC', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_SVC'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_SVC];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_SVC]
FROM (
SELECT
	*
FROM
(
SELECT
	PARENT_ITEM_SRC_KEY
	,ITEM_SRC_KEY
	,LEVEL_NAME
	,label
	,BOTTOM_LEVEL
	,ROW_NUMBER() OVER(PARTITION BY ITEM_SRC_KEY ORDER BY LAST_DOB DESC) AS RN
FROM
(
	SELECT DISTINCT
		NULL AS PARENT_ITEM_SRC_KEY
		,SI.[typeId] AS ITEM_SRC_KEY
			,''Service Charge'' AS LEVEL_NAME
		,SI.label AS label
		,1 AS BOTTOM_LEVEL
		,MAX(SI.dOB) OVER(PARTITION BY SI.[typeId],SI.label) AS LAST_DOB
	FROM
		[int_ncraloha001].[DL_SALES_STREAM_SURCHARGES] SI
	WHERE LOWER([type]) NOT LIKE ''%tax%''

) SUB
) SUB2
WHERE RN = 1
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, N'["PARENT_ITEM_SRC_KEY", "ITEM_SRC_KEY", "LEVEL_NAME", "label", "BOTTOM_LEVEL", "RN"]', GETDATE(), GETDATE());
END
GO

-- Step: Tax (Tier 1)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Tax')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET [staging_table] = N'NCR_TAX',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_TAX'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_TAX];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_TAX]
FROM (
SELECT
	*
FROM
(
SELECT
	PARENT_ITEM_SRC_KEY
	,ITEM_SRC_KEY
	,LEVEL_NAME
	,label
	,BOTTOM_LEVEL
	,ROW_NUMBER() OVER(PARTITION BY ITEM_SRC_KEY ORDER BY LAST_DOB DESC) AS RN
FROM
(
	SELECT DISTINCT
		NULL AS PARENT_ITEM_SRC_KEY
		,SI.[typeId] AS ITEM_SRC_KEY
			,''Tax'' AS LEVEL_NAME
		,SI.label AS label
		,1 AS BOTTOM_LEVEL
		,MAX(SI.dOB) OVER(PARTITION BY SI.[typeId],SI.label) AS LAST_DOB
	FROM
		[int_ncraloha001].[DL_SALES_STREAM_SURCHARGES] SI
	WHERE LOWER([type])  LIKE ''%tax%''

) SUB
) SUB2
WHERE RN = 1
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["PARENT_ITEM_SRC_KEY", "ITEM_SRC_KEY", "LEVEL_NAME", "label", "BOTTOM_LEVEL", "RN"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Tax';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Tax', N'NCR_TAX', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_TAX'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_TAX];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_TAX]
FROM (
SELECT
	*
FROM
(
SELECT
	PARENT_ITEM_SRC_KEY
	,ITEM_SRC_KEY
	,LEVEL_NAME
	,label
	,BOTTOM_LEVEL
	,ROW_NUMBER() OVER(PARTITION BY ITEM_SRC_KEY ORDER BY LAST_DOB DESC) AS RN
FROM
(
	SELECT DISTINCT
		NULL AS PARENT_ITEM_SRC_KEY
		,SI.[typeId] AS ITEM_SRC_KEY
			,''Tax'' AS LEVEL_NAME
		,SI.label AS label
		,1 AS BOTTOM_LEVEL
		,MAX(SI.dOB) OVER(PARTITION BY SI.[typeId],SI.label) AS LAST_DOB
	FROM
		[int_ncraloha001].[DL_SALES_STREAM_SURCHARGES] SI
	WHERE LOWER([type])  LIKE ''%tax%''

) SUB
) SUB2
WHERE RN = 1
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, N'["PARENT_ITEM_SRC_KEY", "ITEM_SRC_KEY", "LEVEL_NAME", "label", "BOTTOM_LEVEL", "RN"]', GETDATE(), GETDATE());
END
GO

-- Step: Comp to Line Item (Tier 2)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Comp to Line Item')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET [staging_table] = N'COMP_LI_LNK',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.COMP_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[COMP_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[COMP_LI_LNK]
FROM (
SELECT
    [ITEM_SRC_KEY]
    ,[SRC_KEY]
FROM
    [stage].[NCR_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE = ''COMP''
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = N'Line Item Detail',
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["ITEM_SRC_KEY", "SRC_KEY"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Comp to Line Item';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Comp to Line Item', N'COMP_LI_LNK', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.COMP_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[COMP_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[COMP_LI_LNK]
FROM (
SELECT
    [ITEM_SRC_KEY]
    ,[SRC_KEY]
FROM
    [stage].[NCR_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE = ''COMP''
) AS source_query;', 2, N'Staging', 0, NULL, N'Line Item Detail', 3, 30, N'["ITEM_SRC_KEY", "SRC_KEY"]', GETDATE(), GETDATE());
END
GO

-- Step: Deal to Line Item (Tier 2)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Deal to Line Item')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET [staging_table] = N'DEAL_LI_LNK',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.DEAL_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[DEAL_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[DEAL_LI_LNK]
FROM (
SELECT
    [ITEM_SRC_KEY]
    ,[SRC_KEY]
FROM
    [stage].[NCR_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE IN (''DEAL'',''PROMO'')
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = N'Line Item Detail',
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["ITEM_SRC_KEY", "SRC_KEY"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Deal to Line Item';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Deal to Line Item', N'DEAL_LI_LNK', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.DEAL_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[DEAL_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[DEAL_LI_LNK]
FROM (
SELECT
    [ITEM_SRC_KEY]
    ,[SRC_KEY]
FROM
    [stage].[NCR_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE IN (''DEAL'',''PROMO'')
) AS source_query;', 2, N'Staging', 0, NULL, N'Line Item Detail', 3, 30, N'["ITEM_SRC_KEY", "SRC_KEY"]', GETDATE(), GETDATE());
END
GO

-- Step: Deals & Line Item to Line Item (Tier 2)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Deals & Line Item to Line Item')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET [staging_table] = N'NCR_DEAL_LI_LI',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_DEAL_LI_LI'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_DEAL_LI_LI];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_DEAL_LI_LI]
FROM (
SELECT
	LI.SRC_KEY AS CHILD_SRC_KEY
	,1 AS BOTTOM_LEVEL
	,''Deals'' AS Level_Name
	,SUB.*
FROM
(
	SELECT 
		CONCAT_WS(''-'', C.[storeId] ,C.[dob] ,C.[checks_id], C.[id], ''DEAL'') AS LI_PARENT_SRC_KEY
		,CONCAT_WS(''-'', C.[storeId] ,C.[dob] ,C.[checks_id]) AS HEADER_ID
		 ,C.[typeId] AS DEAL_SRC_KEY
		 ,C.[label] AS DEAL_NAME
		 ,CL.[id] AS CHILD_ID
		 ,CL.[amount]
	FROM
		[int_ncraloha001].[DL_SALES_STREAM_PROMOS] C

	INNER JOIN
		[int_ncraloha001].[DL_SALES_STREAM_PROMOS_LINKEDITEMS] CL
	ON CL.[storeId] = C.[storeId]
	AND CL.[dob] = C.[dob]
	AND CL.[checks_id] = C.[checks_id]
	AND CL.[promos_id] = C.[id]
) SUB

INNER JOIN
	[stage].NCR_LINE_ITEM_DETAIL LI
ON LI.HEADER_ID = SUB.HEADER_ID
AND LI.LINE_ID = SUB.CHILD_ID
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = N'Line Item Detail',
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["CHILD_SRC_KEY", "BOTTOM_LEVEL", "Level_Name", "LI_PARENT_SRC_KEY", "HEADER_ID", "DEAL_SRC_KEY", "DEAL_NAME", "CHILD_ID", "amount"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Deals & Line Item to Line Item';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Deals & Line Item to Line Item', N'NCR_DEAL_LI_LI', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_DEAL_LI_LI'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_DEAL_LI_LI];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_DEAL_LI_LI]
FROM (
SELECT
	LI.SRC_KEY AS CHILD_SRC_KEY
	,1 AS BOTTOM_LEVEL
	,''Deals'' AS Level_Name
	,SUB.*
FROM
(
	SELECT 
		CONCAT_WS(''-'', C.[storeId] ,C.[dob] ,C.[checks_id], C.[id], ''DEAL'') AS LI_PARENT_SRC_KEY
		,CONCAT_WS(''-'', C.[storeId] ,C.[dob] ,C.[checks_id]) AS HEADER_ID
		 ,C.[typeId] AS DEAL_SRC_KEY
		 ,C.[label] AS DEAL_NAME
		 ,CL.[id] AS CHILD_ID
		 ,CL.[amount]
	FROM
		[int_ncraloha001].[DL_SALES_STREAM_PROMOS] C

	INNER JOIN
		[int_ncraloha001].[DL_SALES_STREAM_PROMOS_LINKEDITEMS] CL
	ON CL.[storeId] = C.[storeId]
	AND CL.[dob] = C.[dob]
	AND CL.[checks_id] = C.[checks_id]
	AND CL.[promos_id] = C.[id]
) SUB

INNER JOIN
	[stage].NCR_LINE_ITEM_DETAIL LI
ON LI.HEADER_ID = SUB.HEADER_ID
AND LI.LINE_ID = SUB.CHILD_ID
) AS source_query;', 2, N'Staging', 0, NULL, N'Line Item Detail', 3, 30, N'["CHILD_SRC_KEY", "BOTTOM_LEVEL", "Level_Name", "LI_PARENT_SRC_KEY", "HEADER_ID", "DEAL_SRC_KEY", "DEAL_NAME", "CHILD_ID", "amount"]', GETDATE(), GETDATE());
END
GO

-- Step: Discount & Line Item to Line Item (Tier 2)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Discount & Line Item to Line Item')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET [staging_table] = N'NCR_DISC_LI_LI',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_DISC_LI_LI'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_DISC_LI_LI];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_DISC_LI_LI]
FROM (
SELECT
	LI.SRC_KEY AS CHILD_SRC_KEY
	,1 AS BOTTOM_LEVEL
	,''Discounts'' AS Level_Name
	,SUB.*
FROM
(
	SELECT
		CONCAT_WS(''-'', C.[storeId] ,C.[dob] ,C.[checks_id], C.[id], ''DISCOUNT'') AS LI_PARENT_SRC_KEY
		,CONCAT_WS(''-'', C.[storeId] ,C.[dob] ,C.[checks_id]) AS HEADER_ID
		 ,C.[typeId] AS DISC_SRC_KEY
		 ,C.[label] AS DISC_NAME
		 ,CL.[id] AS CHILD_ID
		 ,C.[note]
		 ,CAST(TRY_CAST(CL.[amount] AS FLOAT) AS DECIMAL(38, 2)) AS [amount]
		 ,CASE WHEN C.[type] = ''Default'' THEN ''VALUE'' ELSE ''PERC'' END AS VALUE_TYPE
		 ,C.[amount] AS MASTER_DISC_VALUE
	FROM
		[int_ncraloha001].[DL_SALES_STREAM_COMPS] C

	INNER JOIN
		[int_ncraloha001].[DL_SALES_STREAM_COMPS_LINKEDITEMS] CL
	ON CL.[storeId] = C.[storeId]
	AND CL.[dob] = C.[dob]
	AND CL.[checks_id] = C.[checks_id]
	AND CL.[comps_id] = C.[id]
) SUB

INNER JOIN
	[stage].NCR_LINE_ITEM_DETAIL LI
ON LI.HEADER_ID = SUB.HEADER_ID
AND LI.LINE_ID = SUB.CHILD_ID
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = N'Deal',
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["CHILD_SRC_KEY", "BOTTOM_LEVEL", "Level_Name", "LI_PARENT_SRC_KEY", "HEADER_ID", "DISC_SRC_KEY", "DISC_NAME", "CHILD_ID", "note", "amount", "VALUE_TYPE", "MASTER_DISC_VALUE"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Discount & Line Item to Line Item';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Discount & Line Item to Line Item', N'NCR_DISC_LI_LI', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_DISC_LI_LI'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_DISC_LI_LI];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_DISC_LI_LI]
FROM (
SELECT
	LI.SRC_KEY AS CHILD_SRC_KEY
	,1 AS BOTTOM_LEVEL
	,''Discounts'' AS Level_Name
	,SUB.*
FROM
(
	SELECT
		CONCAT_WS(''-'', C.[storeId] ,C.[dob] ,C.[checks_id], C.[id], ''DISCOUNT'') AS LI_PARENT_SRC_KEY
		,CONCAT_WS(''-'', C.[storeId] ,C.[dob] ,C.[checks_id]) AS HEADER_ID
		 ,C.[typeId] AS DISC_SRC_KEY
		 ,C.[label] AS DISC_NAME
		 ,CL.[id] AS CHILD_ID
		 ,C.[note]
		 ,CAST(TRY_CAST(CL.[amount] AS FLOAT) AS DECIMAL(38, 2)) AS [amount]
		 ,CASE WHEN C.[type] = ''Default'' THEN ''VALUE'' ELSE ''PERC'' END AS VALUE_TYPE
		 ,C.[amount] AS MASTER_DISC_VALUE
	FROM
		[int_ncraloha001].[DL_SALES_STREAM_COMPS] C

	INNER JOIN
		[int_ncraloha001].[DL_SALES_STREAM_COMPS_LINKEDITEMS] CL
	ON CL.[storeId] = C.[storeId]
	AND CL.[dob] = C.[dob]
	AND CL.[checks_id] = C.[checks_id]
	AND CL.[comps_id] = C.[id]
) SUB

INNER JOIN
	[stage].NCR_LINE_ITEM_DETAIL LI
ON LI.HEADER_ID = SUB.HEADER_ID
AND LI.LINE_ID = SUB.CHILD_ID
) AS source_query;', 2, N'Staging', 0, NULL, N'Deal', 3, 30, N'["CHILD_SRC_KEY", "BOTTOM_LEVEL", "Level_Name", "LI_PARENT_SRC_KEY", "HEADER_ID", "DISC_SRC_KEY", "DISC_NAME", "CHILD_ID", "note", "amount", "VALUE_TYPE", "MASTER_DISC_VALUE"]', GETDATE(), GETDATE());
END
GO

-- Step: Discount to Line Item (Tier 2)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Discount to Line Item')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET [staging_table] = N'DISC_LI_LNK',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.DISC_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[DISC_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[DISC_LI_LNK]
FROM (
SELECT
    [ITEM_SRC_KEY]
    ,[SRC_KEY]
FROM
    [stage].[NCR_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE = ''DISCOUNT''
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = N'Line Item Detail',
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["ITEM_SRC_KEY", "SRC_KEY"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Discount to Line Item';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Discount to Line Item', N'DISC_LI_LNK', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.DISC_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[DISC_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[DISC_LI_LNK]
FROM (
SELECT
    [ITEM_SRC_KEY]
    ,[SRC_KEY]
FROM
    [stage].[NCR_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE = ''DISCOUNT''
) AS source_query;', 2, N'Staging', 0, NULL, N'Line Item Detail', 3, 30, N'["ITEM_SRC_KEY", "SRC_KEY"]', GETDATE(), GETDATE());
END
GO

-- Step: Mod to Line Item (Tier 2)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Mod to Line Item')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET [staging_table] = N'MOD_LI_LNK',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MOD_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MOD_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[MOD_LI_LNK]
FROM (
SELECT
    [ITEM_SRC_KEY]
    ,[SRC_KEY]
FROM
    [stage].[NCR_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE = ''MOD''
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["ITEM_SRC_KEY", "SRC_KEY"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Mod to Line Item';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Mod to Line Item', N'MOD_LI_LNK', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MOD_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MOD_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[MOD_LI_LNK]
FROM (
SELECT
    [ITEM_SRC_KEY]
    ,[SRC_KEY]
FROM
    [stage].[NCR_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE = ''MOD''
) AS source_query;', 2, N'Staging', 0, NULL, NULL, 3, 30, N'["ITEM_SRC_KEY", "SRC_KEY"]', GETDATE(), GETDATE());
END
GO

-- Step: Occasion to Line Item (Tier 2)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Occasion to Line Item')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET [staging_table] = N'OCC_LI_LNK',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.OCC_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[OCC_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[OCC_LI_LNK]
FROM (
SELECT
    SRC_KEY,
    OCCASSION_SRC_KEY
FROM
    [stage].[NCR_LINE_ITEM_DETAIL]
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["SRC_KEY", "OCCASSION_SRC_KEY"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Occasion to Line Item';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Occasion to Line Item', N'OCC_LI_LNK', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.OCC_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[OCC_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[OCC_LI_LNK]
FROM (
SELECT
    SRC_KEY,
    OCCASSION_SRC_KEY
FROM
    [stage].[NCR_LINE_ITEM_DETAIL]
) AS source_query;', 2, N'Staging', 0, NULL, NULL, 3, 30, N'["SRC_KEY", "OCCASSION_SRC_KEY"]', GETDATE(), GETDATE());
END
GO

-- Step: Product to Line Item (Tier 2)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Product to Line Item')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET [staging_table] = N'PROD_LI_LNK',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.PROD_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[PROD_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[PROD_LI_LNK]
FROM (
SELECT
    [ITEM_SRC_KEY]
    ,[SRC_KEY]
FROM
    [stage].[NCR_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE = ''PROD''
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = N'Line Item Detail',
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["ITEM_SRC_KEY", "SRC_KEY"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Product to Line Item';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Product to Line Item', N'PROD_LI_LNK', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.PROD_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[PROD_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[PROD_LI_LNK]
FROM (
SELECT
    [ITEM_SRC_KEY]
    ,[SRC_KEY]
FROM
    [stage].[NCR_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE = ''PROD''
) AS source_query;', 2, N'Staging', 0, NULL, N'Line Item Detail', 3, 30, N'["ITEM_SRC_KEY", "SRC_KEY"]', GETDATE(), GETDATE());
END
GO

-- Step: Product to Location and Occasion (Tier 2)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Product to Location and Occasion')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET [staging_table] = N'LOC_OCC_PROD_LNK',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.LOC_OCC_PROD_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[LOC_OCC_PROD_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[LOC_OCC_PROD_LNK]
FROM (
SELECT 
    [ITEM_SRC_KEY]
    ,ISNULL([OCCASSION_SRC_KEY],''-999'') AS [OCCASSION_SRC_KEY]
    ,[LOCATION_ID]
	,MAX(NET_VALUE/QUANTITY) AS Net_Price
FROM
    [stage].[NCR_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE = ''PROD''
AND [LOCATION_ID] IS NOT NULL
AND [ITEM_SRC_KEY] IS NOT NULL
GROUP BY [ITEM_SRC_KEY]
    ,ISNULL([OCCASSION_SRC_KEY],''-999'') 
    ,[LOCATION_ID]
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["ITEM_SRC_KEY", "OCCASSION_SRC_KEY", "LOCATION_ID", "Net_Price"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Product to Location and Occasion';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Product to Location and Occasion', N'LOC_OCC_PROD_LNK', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.LOC_OCC_PROD_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[LOC_OCC_PROD_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[LOC_OCC_PROD_LNK]
FROM (
SELECT 
    [ITEM_SRC_KEY]
    ,ISNULL([OCCASSION_SRC_KEY],''-999'') AS [OCCASSION_SRC_KEY]
    ,[LOCATION_ID]
	,MAX(NET_VALUE/QUANTITY) AS Net_Price
FROM
    [stage].[NCR_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE = ''PROD''
AND [LOCATION_ID] IS NOT NULL
AND [ITEM_SRC_KEY] IS NOT NULL
GROUP BY [ITEM_SRC_KEY]
    ,ISNULL([OCCASSION_SRC_KEY],''-999'') 
    ,[LOCATION_ID]
) AS source_query;', 2, N'Staging', 0, NULL, NULL, 3, 30, N'["ITEM_SRC_KEY", "OCCASSION_SRC_KEY", "LOCATION_ID", "Net_Price"]', GETDATE(), GETDATE());
END
GO

-- Step: Service Charge & Line Item to Line Item (Tier 2)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Service Charge & Line Item to Line Item')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET [staging_table] = N'NCR_SVC_LI_LI',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_SVC_LI_LI'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_SVC_LI_LI];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_SVC_LI_LI]
FROM (
SELECT
	LI.SRC_KEY AS CHILD_SRC_KEY
	,1 AS BOTTOM_LEVEL
	,''Service Charge'' AS Level_Name
	,SUB.*
FROM
(
	SELECT 
		CONCAT_WS(''-'', C.[storeId] ,C.[dob] ,C.[checks_id], C.[id], ''SVC'') AS LI_PARENT_SRC_KEY
		,CONCAT_WS(''-'', C.[storeId] ,C.[dob] ,C.[checks_id]) AS HEADER_ID
		 ,C.[typeId] AS SVC_SRC_KEY
		 ,C.[label] AS SVC_NAME
		 ,CL.[linkedItems] AS CHILD_ID
		 ,C.rate
		 ,C.accounting
		 ,C.type
	FROM
		[int_ncraloha001].[DL_SALES_STREAM_SURCHARGES] C

	INNER JOIN
		[int_ncraloha001].[DL_SALES_STREAM_SURCHARGES_LINKEDITEMS] CL
	ON CL.[storeId] = C.[storeId]
	AND CL.[dob] = C.[dob]
	AND CL.[checks_id] = C.[checks_id]
	AND CL.[surcharges_id] = C.[id]
	WHERE LOWER(C.type) != ''tax''
) SUB

INNER JOIN
	[stage].NCR_LINE_ITEM_DETAIL LI
ON LI.HEADER_ID = SUB.HEADER_ID
AND LI.LINE_ID = SUB.CHILD_ID
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = N'Line Item Detail',
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["CHILD_SRC_KEY", "BOTTOM_LEVEL", "Level_Name", "LI_PARENT_SRC_KEY", "HEADER_ID", "SVC_SRC_KEY", "SVC_NAME", "CHILD_ID", "rate", "accounting", "type"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Service Charge & Line Item to Line Item';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Service Charge & Line Item to Line Item', N'NCR_SVC_LI_LI', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_SVC_LI_LI'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_SVC_LI_LI];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_SVC_LI_LI]
FROM (
SELECT
	LI.SRC_KEY AS CHILD_SRC_KEY
	,1 AS BOTTOM_LEVEL
	,''Service Charge'' AS Level_Name
	,SUB.*
FROM
(
	SELECT 
		CONCAT_WS(''-'', C.[storeId] ,C.[dob] ,C.[checks_id], C.[id], ''SVC'') AS LI_PARENT_SRC_KEY
		,CONCAT_WS(''-'', C.[storeId] ,C.[dob] ,C.[checks_id]) AS HEADER_ID
		 ,C.[typeId] AS SVC_SRC_KEY
		 ,C.[label] AS SVC_NAME
		 ,CL.[linkedItems] AS CHILD_ID
		 ,C.rate
		 ,C.accounting
		 ,C.type
	FROM
		[int_ncraloha001].[DL_SALES_STREAM_SURCHARGES] C

	INNER JOIN
		[int_ncraloha001].[DL_SALES_STREAM_SURCHARGES_LINKEDITEMS] CL
	ON CL.[storeId] = C.[storeId]
	AND CL.[dob] = C.[dob]
	AND CL.[checks_id] = C.[checks_id]
	AND CL.[surcharges_id] = C.[id]
	WHERE LOWER(C.type) != ''tax''
) SUB

INNER JOIN
	[stage].NCR_LINE_ITEM_DETAIL LI
ON LI.HEADER_ID = SUB.HEADER_ID
AND LI.LINE_ID = SUB.CHILD_ID
) AS source_query;', 2, N'Staging', 0, NULL, N'Line Item Detail', 3, 30, N'["CHILD_SRC_KEY", "BOTTOM_LEVEL", "Level_Name", "LI_PARENT_SRC_KEY", "HEADER_ID", "SVC_SRC_KEY", "SVC_NAME", "CHILD_ID", "rate", "accounting", "type"]', GETDATE(), GETDATE());
END
GO

-- Step: Service Charge to Line Item (Tier 2)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Service Charge to Line Item')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET [staging_table] = N'SVC_LI_LNK',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.SVC_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[SVC_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[SVC_LI_LNK]
FROM (
SELECT
    [ITEM_SRC_KEY]
    ,[SRC_KEY]
FROM
    [stage].[NCR_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE IN (''SVC'')
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = N'Line Item Detail',
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["ITEM_SRC_KEY", "SRC_KEY"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Service Charge to Line Item';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Service Charge to Line Item', N'SVC_LI_LNK', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.SVC_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[SVC_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[SVC_LI_LNK]
FROM (
SELECT
    [ITEM_SRC_KEY]
    ,[SRC_KEY]
FROM
    [stage].[NCR_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE IN (''SVC'')
) AS source_query;', 2, N'Staging', 0, NULL, N'Line Item Detail', 3, 30, N'["ITEM_SRC_KEY", "SRC_KEY"]', GETDATE(), GETDATE());
END
GO

-- Step: Tax & Line Item to Line Item (Tier 2)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Tax & Line Item to Line Item')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET [staging_table] = N'NCR_TAX_LI_LI',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_TAX_LI_LI'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_TAX_LI_LI];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_TAX_LI_LI]
FROM (
SELECT
	LI.SRC_KEY AS CHILD_SRC_KEY
	,1 AS BOTTOM_LEVEL
	,''Tax'' AS Level_Name
	,SUB.*
FROM
(
	SELECT 
		CONCAT_WS(''-'', C.[storeId] ,C.[dob] ,C.[checks_id], C.[id], ''TAX'') AS LI_PARENT_SRC_KEY
		,CONCAT_WS(''-'', C.[storeId] ,C.[dob] ,C.[checks_id]) AS HEADER_ID
		 ,C.[typeId] AS TAX_SRC_KEY
		 ,C.[label] AS TAX_NAME
		 ,CL.[linkedItems] AS CHILD_ID
		 ,C.rate
		 ,C.accounting
		 ,C.type
	FROM
		[int_ncraloha001].[DL_SALES_STREAM_SURCHARGES] C

	INNER JOIN
		[int_ncraloha001].[DL_SALES_STREAM_SURCHARGES_LINKEDITEMS] CL
	ON CL.[storeId] = C.[storeId]
	AND CL.[dob] = C.[dob]
	AND CL.[checks_id] = C.[checks_id]
	AND CL.[surcharges_id] = C.[id]
	WHERE LOWER(C.type) = ''tax''
) SUB

INNER JOIN
	[stage].NCR_LINE_ITEM_DETAIL LI
ON LI.HEADER_ID = SUB.HEADER_ID
AND LI.LINE_ID = SUB.CHILD_ID
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["CHILD_SRC_KEY", "BOTTOM_LEVEL", "Level_Name", "LI_PARENT_SRC_KEY", "HEADER_ID", "TAX_SRC_KEY", "TAX_NAME", "CHILD_ID", "rate", "accounting", "type"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Tax & Line Item to Line Item';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Tax & Line Item to Line Item', N'NCR_TAX_LI_LI', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_TAX_LI_LI'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_TAX_LI_LI];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_TAX_LI_LI]
FROM (
SELECT
	LI.SRC_KEY AS CHILD_SRC_KEY
	,1 AS BOTTOM_LEVEL
	,''Tax'' AS Level_Name
	,SUB.*
FROM
(
	SELECT 
		CONCAT_WS(''-'', C.[storeId] ,C.[dob] ,C.[checks_id], C.[id], ''TAX'') AS LI_PARENT_SRC_KEY
		,CONCAT_WS(''-'', C.[storeId] ,C.[dob] ,C.[checks_id]) AS HEADER_ID
		 ,C.[typeId] AS TAX_SRC_KEY
		 ,C.[label] AS TAX_NAME
		 ,CL.[linkedItems] AS CHILD_ID
		 ,C.rate
		 ,C.accounting
		 ,C.type
	FROM
		[int_ncraloha001].[DL_SALES_STREAM_SURCHARGES] C

	INNER JOIN
		[int_ncraloha001].[DL_SALES_STREAM_SURCHARGES_LINKEDITEMS] CL
	ON CL.[storeId] = C.[storeId]
	AND CL.[dob] = C.[dob]
	AND CL.[checks_id] = C.[checks_id]
	AND CL.[surcharges_id] = C.[id]
	WHERE LOWER(C.type) = ''tax''
) SUB

INNER JOIN
	[stage].NCR_LINE_ITEM_DETAIL LI
ON LI.HEADER_ID = SUB.HEADER_ID
AND LI.LINE_ID = SUB.CHILD_ID
) AS source_query;', 2, N'Staging', 0, NULL, NULL, 3, 30, N'["CHILD_SRC_KEY", "BOTTOM_LEVEL", "Level_Name", "LI_PARENT_SRC_KEY", "HEADER_ID", "TAX_SRC_KEY", "TAX_NAME", "CHILD_ID", "rate", "accounting", "type"]', GETDATE(), GETDATE());
END
GO

-- Step: Tax to Line Item (Tier 2)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Tax to Line Item')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET [staging_table] = N'TAX_LI_LNK',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TAX_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TAX_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[TAX_LI_LNK]
FROM (
SELECT
    [ITEM_SRC_KEY]
    ,[SRC_KEY]
FROM
    [stage].[NCR_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE IN (''TAX'')
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = N'Line Item Detail',
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["ITEM_SRC_KEY", "SRC_KEY"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Tax to Line Item';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Tax to Line Item', N'TAX_LI_LNK', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TAX_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TAX_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[TAX_LI_LNK]
FROM (
SELECT
    [ITEM_SRC_KEY]
    ,[SRC_KEY]
FROM
    [stage].[NCR_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE IN (''TAX'')
) AS source_query;', 2, N'Staging', 0, NULL, N'Line Item Detail', 3, 30, N'["ITEM_SRC_KEY", "SRC_KEY"]', GETDATE(), GETDATE());
END
GO

-- Step: Tender to Line Item (Tier 2)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Tender to Line Item')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET [staging_table] = N'TEND_LI_LINK',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TEND_LI_LINK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TEND_LI_LINK];

-- Create the staging table from the query
SELECT * INTO [stage].[TEND_LI_LINK]
FROM (
SELECT
    [ITEM_SRC_KEY]
    ,[SRC_KEY]
FROM
    [stage].[NCR_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE IN (''TENDER'')
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["ITEM_SRC_KEY", "SRC_KEY"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Tender to Line Item';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Tender to Line Item', N'TEND_LI_LINK', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TEND_LI_LINK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TEND_LI_LINK];

-- Create the staging table from the query
SELECT * INTO [stage].[TEND_LI_LINK]
FROM (
SELECT
    [ITEM_SRC_KEY]
    ,[SRC_KEY]
FROM
    [stage].[NCR_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE IN (''TENDER'')
) AS source_query;', 2, N'Staging', 0, NULL, NULL, 3, 30, N'["ITEM_SRC_KEY", "SRC_KEY"]', GETDATE(), GETDATE());
END
GO

-- Step: Line Item to Line Item (Tier 3)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Line Item to Line Item')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET [staging_table] = N'LI_LI_LINK',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.LI_LI_LINK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[LI_LI_LINK];

-- Create the staging table from the query
SELECT * INTO [stage].[LI_LI_LINK]
FROM (
SELECT
	LI.SRC_KEY AS PARENT_SRC_KEY
	,PIT.SRC_KEY AS CHILD_SRC_KEY
	,NULL AS LABEL
	,NULL AS VALUE
	,NULL AS INFO
FROM [stage].[NCR_LINE_ITEM_DETAIL] LI

INNER JOIN
  
[stage].[NCR_LINE_ITEM_DETAIL] PIT
ON LI.HEADER_ID = PIT.HEADER_ID
AND LI.PARENT_ITEM_SRC_KEY = PIT.LINE_ID

UNION ALL

SELECT
	DI.LI_PARENT_SRC_KEY AS PARENT_SRC_KEY
	,DI.CHILD_SRC_KEY
	,DI.DISC_NAME AS LABEL
	,DI.AMOUNT AS VALUE
	,DI.NOTE AS INFO
FROM
	[stage].NCR_DISC_LI_LI DI

UNION ALL

SELECT
	DA.LI_PARENT_SRC_KEY AS PARENT_SRC_KEY
	,DA.CHILD_SRC_KEY
	,DA.DEAL_NAME AS LABEL
	,DA.AMOUNT AS VALUE
	,NULL AS INFO
FROM
	[stage].NCR_DEAL_LI_LI DA

UNION ALL

SELECT
	TA.LI_PARENT_SRC_KEY AS PARENT_SRC_KEY
	,TA.CHILD_SRC_KEY
	,TA.TAX_NAME AS LABEL
	,NULL AS VALUE
	,NULL AS INFO
FROM
	[stage].NCR_TAX_LI_LI TA

UNION ALL

SELECT
	SVC.LI_PARENT_SRC_KEY AS PARENT_SRC_KEY
	,SVC.CHILD_SRC_KEY
	,SVC.SVC_NAME AS LABEL
	,NULL AS VALUE
	,NULL AS INFO
FROM
	[stage].NCR_SVC_LI_LI SVC
) AS source_query;',
        [tier] = 3,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["PARENT_SRC_KEY", "CHILD_SRC_KEY", "LABEL", "VALUE", "INFO"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Line Item to Line Item';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Line Item to Line Item', N'LI_LI_LINK', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.LI_LI_LINK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[LI_LI_LINK];

-- Create the staging table from the query
SELECT * INTO [stage].[LI_LI_LINK]
FROM (
SELECT
	LI.SRC_KEY AS PARENT_SRC_KEY
	,PIT.SRC_KEY AS CHILD_SRC_KEY
	,NULL AS LABEL
	,NULL AS VALUE
	,NULL AS INFO
FROM [stage].[NCR_LINE_ITEM_DETAIL] LI

INNER JOIN
  
[stage].[NCR_LINE_ITEM_DETAIL] PIT
ON LI.HEADER_ID = PIT.HEADER_ID
AND LI.PARENT_ITEM_SRC_KEY = PIT.LINE_ID

UNION ALL

SELECT
	DI.LI_PARENT_SRC_KEY AS PARENT_SRC_KEY
	,DI.CHILD_SRC_KEY
	,DI.DISC_NAME AS LABEL
	,DI.AMOUNT AS VALUE
	,DI.NOTE AS INFO
FROM
	[stage].NCR_DISC_LI_LI DI

UNION ALL

SELECT
	DA.LI_PARENT_SRC_KEY AS PARENT_SRC_KEY
	,DA.CHILD_SRC_KEY
	,DA.DEAL_NAME AS LABEL
	,DA.AMOUNT AS VALUE
	,NULL AS INFO
FROM
	[stage].NCR_DEAL_LI_LI DA

UNION ALL

SELECT
	TA.LI_PARENT_SRC_KEY AS PARENT_SRC_KEY
	,TA.CHILD_SRC_KEY
	,TA.TAX_NAME AS LABEL
	,NULL AS VALUE
	,NULL AS INFO
FROM
	[stage].NCR_TAX_LI_LI TA

UNION ALL

SELECT
	SVC.LI_PARENT_SRC_KEY AS PARENT_SRC_KEY
	,SVC.CHILD_SRC_KEY
	,SVC.SVC_NAME AS LABEL
	,NULL AS VALUE
	,NULL AS INFO
FROM
	[stage].NCR_SVC_LI_LI SVC
) AS source_query;', 3, N'Staging', 0, NULL, NULL, 3, 30, N'["PARENT_SRC_KEY", "CHILD_SRC_KEY", "LABEL", "VALUE", "INFO"]', GETDATE(), GETDATE());
END
GO
