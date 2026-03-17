-- =============================================================================
-- SurveyHero Integration: GlobalParameters Records (STAGE_DDL)
-- Schema: int_surveyhero001
-- Source: XMS BI DEV (2026-03-13)
-- Total Parameters: 41 (all STAGE_DDL category)
-- =============================================================================
-- The original 8 STAGE_DDL records were never updated to match the actual
-- DL tables created by the API flattener. This script:
--   1. Removes 5 obsolete keys that don't correspond to real tables
--      (DL_ANSWERS, DL_ANSWERS_CHOICES, DL_ANSWERS_INPUT_TABLE,
--       DL_ANSWERS_RANKING, DL_ELEMENTS_CHOICES)
--   2. Updates 3 existing keys with correct DDL (DL_ELEMENTS, DL_RESPONSES,
--      DL_SURVEYS) — all columns are NVARCHAR(MAX), not typed
--   3. Adds 38 new keys for the remaining DL tables
--
-- All DL table columns are NVARCHAR(MAX) NULL (API flattener convention)
-- plus system columns LOADTS_UTC and INT_FETCH_DATE.
-- =============================================================================

-- =============================================================================
-- PHASE 1: Remove obsolete GlobalParameters keys
-- =============================================================================
DELETE FROM [core].[int_surveyhero001].[GlobalParameters]
WHERE [Category] = N'STAGE_DDL'
  AND [ParameterKey] IN (
    N'DL_ANSWERS',
    N'DL_ANSWERS_CHOICES',
    N'DL_ANSWERS_INPUT_TABLE',
    N'DL_ANSWERS_RANKING',
    N'DL_ELEMENTS_CHOICES'
  );
GO

-- =============================================================================
-- PHASE 2: Upsert all 41 DL table DDL records
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. DL_ELEMENTS
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[GlobalParameters] WHERE [ParameterKey] = N'DL_ELEMENTS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_surveyhero001].[GlobalParameters]
    SET [ParameterValue] = N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [element_type] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [Description] = N'Survey element metadata',
        [IsActive] = 1,
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [ParameterKey] = N'DL_ELEMENTS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[GlobalParameters]
    ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [Version])
    VALUES (N'DL_ELEMENTS', N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [element_type] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'Survey element metadata', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- -----------------------------------------------------------------------------
-- 2. DL_ELEMENTS_CODES
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[GlobalParameters] WHERE [ParameterKey] = N'DL_ELEMENTS_CODES' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_surveyhero001].[GlobalParameters]
    SET [ParameterValue] = N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_CODES] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [code] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [Description] = N'Element code values',
        [IsActive] = 1,
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [ParameterKey] = N'DL_ELEMENTS_CODES' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[GlobalParameters]
    ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [Version])
    VALUES (N'DL_ELEMENTS_CODES', N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_CODES] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [code] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'Element code values', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- -----------------------------------------------------------------------------
-- 3. DL_ELEMENTS_IMAGES
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[GlobalParameters] WHERE [ParameterKey] = N'DL_ELEMENTS_IMAGES' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_surveyhero001].[GlobalParameters]
    SET [ParameterValue] = N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_IMAGES] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [text] NVARCHAR(MAX) NULL,
    [image_url] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [Description] = N'Element image data',
        [IsActive] = 1,
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [ParameterKey] = N'DL_ELEMENTS_IMAGES' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[GlobalParameters]
    ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [Version])
    VALUES (N'DL_ELEMENTS_IMAGES', N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_IMAGES] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [text] NVARCHAR(MAX) NULL,
    [image_url] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'Element image data', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- -----------------------------------------------------------------------------
-- 4. DL_ELEMENTS_QUESTIONS
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[GlobalParameters] WHERE [ParameterKey] = N'DL_ELEMENTS_QUESTIONS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_surveyhero001].[GlobalParameters]
    SET [ParameterValue] = N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_QUESTIONS] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [question_text] NVARCHAR(MAX) NULL,
    [description_text] NVARCHAR(MAX) NULL,
    [question_type] NVARCHAR(MAX) NULL,
    [settings_is_required] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [Description] = N'Survey question definitions',
        [IsActive] = 1,
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [ParameterKey] = N'DL_ELEMENTS_QUESTIONS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[GlobalParameters]
    ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [Version])
    VALUES (N'DL_ELEMENTS_QUESTIONS', N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_QUESTIONS] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [question_text] NVARCHAR(MAX) NULL,
    [description_text] NVARCHAR(MAX) NULL,
    [question_type] NVARCHAR(MAX) NULL,
    [settings_is_required] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'Survey question definitions', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- -----------------------------------------------------------------------------
-- 5. DL_ELEMENTS_QUESTIONS_CHOICELISTS
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[GlobalParameters] WHERE [ParameterKey] = N'DL_ELEMENTS_QUESTIONS_CHOICELISTS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_surveyhero001].[GlobalParameters]
    SET [ParameterValue] = N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_QUESTIONS_CHOICELISTS] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [settings_allows_multiple_choices] NVARCHAR(MAX) NULL,
    [settings_min_number_of_choices] NVARCHAR(MAX) NULL,
    [settings_max_number_of_choices] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [Description] = N'Choice list settings for questions',
        [IsActive] = 1,
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [ParameterKey] = N'DL_ELEMENTS_QUESTIONS_CHOICELISTS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[GlobalParameters]
    ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [Version])
    VALUES (N'DL_ELEMENTS_QUESTIONS_CHOICELISTS', N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_QUESTIONS_CHOICELISTS] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [settings_allows_multiple_choices] NVARCHAR(MAX) NULL,
    [settings_min_number_of_choices] NVARCHAR(MAX) NULL,
    [settings_max_number_of_choices] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'Choice list settings for questions', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- -----------------------------------------------------------------------------
-- 6. DL_ELEMENTS_QUESTIONS_CHOICELISTS_CHOICES
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[GlobalParameters] WHERE [ParameterKey] = N'DL_ELEMENTS_QUESTIONS_CHOICELISTS_CHOICES' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_surveyhero001].[GlobalParameters]
    SET [ParameterValue] = N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_QUESTIONS_CHOICELISTS_CHOICES] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [choice_id] NVARCHAR(MAX) NULL,
    [label] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [Description] = N'Individual choices within choice lists',
        [IsActive] = 1,
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [ParameterKey] = N'DL_ELEMENTS_QUESTIONS_CHOICELISTS_CHOICES' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[GlobalParameters]
    ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [Version])
    VALUES (N'DL_ELEMENTS_QUESTIONS_CHOICELISTS_CHOICES', N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_QUESTIONS_CHOICELISTS_CHOICES] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [choice_id] NVARCHAR(MAX) NULL,
    [label] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'Individual choices within choice lists', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- -----------------------------------------------------------------------------
-- 7. DL_ELEMENTS_QUESTIONS_CHOICETABLES
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[GlobalParameters] WHERE [ParameterKey] = N'DL_ELEMENTS_QUESTIONS_CHOICETABLES' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_surveyhero001].[GlobalParameters]
    SET [ParameterValue] = N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_QUESTIONS_CHOICETABLES] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [settings_allows_multiple_choices_per_row] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [Description] = N'Choice table settings for matrix questions',
        [IsActive] = 1,
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [ParameterKey] = N'DL_ELEMENTS_QUESTIONS_CHOICETABLES' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[GlobalParameters]
    ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [Version])
    VALUES (N'DL_ELEMENTS_QUESTIONS_CHOICETABLES', N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_QUESTIONS_CHOICETABLES] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [settings_allows_multiple_choices_per_row] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'Choice table settings for matrix questions', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- -----------------------------------------------------------------------------
-- 8. DL_ELEMENTS_QUESTIONS_CHOICETABLES_CHOICES
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[GlobalParameters] WHERE [ParameterKey] = N'DL_ELEMENTS_QUESTIONS_CHOICETABLES_CHOICES' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_surveyhero001].[GlobalParameters]
    SET [ParameterValue] = N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_QUESTIONS_CHOICETABLES_CHOICES] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [choice_id] NVARCHAR(MAX) NULL,
    [label] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [Description] = N'Column choices within choice tables',
        [IsActive] = 1,
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [ParameterKey] = N'DL_ELEMENTS_QUESTIONS_CHOICETABLES_CHOICES' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[GlobalParameters]
    ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [Version])
    VALUES (N'DL_ELEMENTS_QUESTIONS_CHOICETABLES_CHOICES', N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_QUESTIONS_CHOICETABLES_CHOICES] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [choice_id] NVARCHAR(MAX) NULL,
    [label] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'Column choices within choice tables', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- -----------------------------------------------------------------------------
-- 9. DL_ELEMENTS_QUESTIONS_CHOICETABLES_ROWS
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[GlobalParameters] WHERE [ParameterKey] = N'DL_ELEMENTS_QUESTIONS_CHOICETABLES_ROWS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_surveyhero001].[GlobalParameters]
    SET [ParameterValue] = N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_QUESTIONS_CHOICETABLES_ROWS] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [row_id] NVARCHAR(MAX) NULL,
    [label] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [Description] = N'Row definitions within choice tables',
        [IsActive] = 1,
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [ParameterKey] = N'DL_ELEMENTS_QUESTIONS_CHOICETABLES_ROWS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[GlobalParameters]
    ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [Version])
    VALUES (N'DL_ELEMENTS_QUESTIONS_CHOICETABLES_ROWS', N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_QUESTIONS_CHOICETABLES_ROWS] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [row_id] NVARCHAR(MAX) NULL,
    [label] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'Row definitions within choice tables', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- -----------------------------------------------------------------------------
-- 10. DL_ELEMENTS_QUESTIONS_FILEUPLOADS
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[GlobalParameters] WHERE [ParameterKey] = N'DL_ELEMENTS_QUESTIONS_FILEUPLOADS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_surveyhero001].[GlobalParameters]
    SET [ParameterValue] = N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_QUESTIONS_FILEUPLOADS] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [max_file_size_in_mb] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [Description] = N'File upload question settings',
        [IsActive] = 1,
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [ParameterKey] = N'DL_ELEMENTS_QUESTIONS_FILEUPLOADS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[GlobalParameters]
    ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [Version])
    VALUES (N'DL_ELEMENTS_QUESTIONS_FILEUPLOADS', N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_QUESTIONS_FILEUPLOADS] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [max_file_size_in_mb] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'File upload question settings', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- -----------------------------------------------------------------------------
-- 11. DL_ELEMENTS_QUESTIONS_FILEUPLOADS_ACCEPTEDFILETYPES
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[GlobalParameters] WHERE [ParameterKey] = N'DL_ELEMENTS_QUESTIONS_FILEUPLOADS_ACCEPTEDFILETYPES' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_surveyhero001].[GlobalParameters]
    SET [ParameterValue] = N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_QUESTIONS_FILEUPLOADS_ACCEPTEDFILETYPES] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [file_type] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [Description] = N'Accepted file types for upload questions',
        [IsActive] = 1,
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [ParameterKey] = N'DL_ELEMENTS_QUESTIONS_FILEUPLOADS_ACCEPTEDFILETYPES' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[GlobalParameters]
    ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [Version])
    VALUES (N'DL_ELEMENTS_QUESTIONS_FILEUPLOADS_ACCEPTEDFILETYPES', N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_QUESTIONS_FILEUPLOADS_ACCEPTEDFILETYPES] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [file_type] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'Accepted file types for upload questions', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- -----------------------------------------------------------------------------
-- 12. DL_ELEMENTS_QUESTIONS_IMAGECHOICELISTS
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[GlobalParameters] WHERE [ParameterKey] = N'DL_ELEMENTS_QUESTIONS_IMAGECHOICELISTS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_surveyhero001].[GlobalParameters]
    SET [ParameterValue] = N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_QUESTIONS_IMAGECHOICELISTS] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [settings_allows_multiple_choices] NVARCHAR(MAX) NULL,
    [settings_min_number_of_choices] NVARCHAR(MAX) NULL,
    [settings_max_number_of_choices] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [Description] = N'Image choice list settings',
        [IsActive] = 1,
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [ParameterKey] = N'DL_ELEMENTS_QUESTIONS_IMAGECHOICELISTS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[GlobalParameters]
    ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [Version])
    VALUES (N'DL_ELEMENTS_QUESTIONS_IMAGECHOICELISTS', N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_QUESTIONS_IMAGECHOICELISTS] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [settings_allows_multiple_choices] NVARCHAR(MAX) NULL,
    [settings_min_number_of_choices] NVARCHAR(MAX) NULL,
    [settings_max_number_of_choices] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'Image choice list settings', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- -----------------------------------------------------------------------------
-- 13. DL_ELEMENTS_QUESTIONS_IMAGECHOICELISTS_CHOICES
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[GlobalParameters] WHERE [ParameterKey] = N'DL_ELEMENTS_QUESTIONS_IMAGECHOICELISTS_CHOICES' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_surveyhero001].[GlobalParameters]
    SET [ParameterValue] = N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_QUESTIONS_IMAGECHOICELISTS_CHOICES] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [choice_id] NVARCHAR(MAX) NULL,
    [label] NVARCHAR(MAX) NULL,
    [image_url] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [Description] = N'Individual choices within image choice lists',
        [IsActive] = 1,
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [ParameterKey] = N'DL_ELEMENTS_QUESTIONS_IMAGECHOICELISTS_CHOICES' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[GlobalParameters]
    ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [Version])
    VALUES (N'DL_ELEMENTS_QUESTIONS_IMAGECHOICELISTS_CHOICES', N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_QUESTIONS_IMAGECHOICELISTS_CHOICES] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [choice_id] NVARCHAR(MAX) NULL,
    [label] NVARCHAR(MAX) NULL,
    [image_url] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'Individual choices within image choice lists', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- -----------------------------------------------------------------------------
-- 14. DL_ELEMENTS_QUESTIONS_INPUTLISTS
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[GlobalParameters] WHERE [ParameterKey] = N'DL_ELEMENTS_QUESTIONS_INPUTLISTS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_surveyhero001].[GlobalParameters]
    SET [ParameterValue] = N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_QUESTIONS_INPUTLISTS] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [accepts] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [Description] = N'Input list question settings',
        [IsActive] = 1,
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [ParameterKey] = N'DL_ELEMENTS_QUESTIONS_INPUTLISTS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[GlobalParameters]
    ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [Version])
    VALUES (N'DL_ELEMENTS_QUESTIONS_INPUTLISTS', N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_QUESTIONS_INPUTLISTS] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [accepts] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'Input list question settings', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- -----------------------------------------------------------------------------
-- 15. DL_ELEMENTS_QUESTIONS_INPUTLISTS_INPUTS
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[GlobalParameters] WHERE [ParameterKey] = N'DL_ELEMENTS_QUESTIONS_INPUTLISTS_INPUTS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_surveyhero001].[GlobalParameters]
    SET [ParameterValue] = N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_QUESTIONS_INPUTLISTS_INPUTS] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [input_id] NVARCHAR(MAX) NULL,
    [label] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [Description] = N'Individual inputs within input lists',
        [IsActive] = 1,
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [ParameterKey] = N'DL_ELEMENTS_QUESTIONS_INPUTLISTS_INPUTS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[GlobalParameters]
    ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [Version])
    VALUES (N'DL_ELEMENTS_QUESTIONS_INPUTLISTS_INPUTS', N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_QUESTIONS_INPUTLISTS_INPUTS] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [input_id] NVARCHAR(MAX) NULL,
    [label] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'Individual inputs within input lists', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- -----------------------------------------------------------------------------
-- 16. DL_ELEMENTS_QUESTIONS_INPUTS
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[GlobalParameters] WHERE [ParameterKey] = N'DL_ELEMENTS_QUESTIONS_INPUTS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_surveyhero001].[GlobalParameters]
    SET [ParameterValue] = N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_QUESTIONS_INPUTS] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [default_value] NVARCHAR(MAX) NULL,
    [placeholder_value] NVARCHAR(MAX) NULL,
    [accepts] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [Description] = N'Single input question settings',
        [IsActive] = 1,
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [ParameterKey] = N'DL_ELEMENTS_QUESTIONS_INPUTS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[GlobalParameters]
    ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [Version])
    VALUES (N'DL_ELEMENTS_QUESTIONS_INPUTS', N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_QUESTIONS_INPUTS] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [default_value] NVARCHAR(MAX) NULL,
    [placeholder_value] NVARCHAR(MAX) NULL,
    [accepts] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'Single input question settings', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- -----------------------------------------------------------------------------
-- 17. DL_ELEMENTS_QUESTIONS_INPUTTABLES
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[GlobalParameters] WHERE [ParameterKey] = N'DL_ELEMENTS_QUESTIONS_INPUTTABLES' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_surveyhero001].[GlobalParameters]
    SET [ParameterValue] = N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_QUESTIONS_INPUTTABLES] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [accepts] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [Description] = N'Input table question settings',
        [IsActive] = 1,
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [ParameterKey] = N'DL_ELEMENTS_QUESTIONS_INPUTTABLES' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[GlobalParameters]
    ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [Version])
    VALUES (N'DL_ELEMENTS_QUESTIONS_INPUTTABLES', N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_QUESTIONS_INPUTTABLES] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [accepts] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'Input table question settings', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- -----------------------------------------------------------------------------
-- 18. DL_ELEMENTS_QUESTIONS_INPUTTABLES_COLUMNS
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[GlobalParameters] WHERE [ParameterKey] = N'DL_ELEMENTS_QUESTIONS_INPUTTABLES_COLUMNS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_surveyhero001].[GlobalParameters]
    SET [ParameterValue] = N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_QUESTIONS_INPUTTABLES_COLUMNS] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [column_id] NVARCHAR(MAX) NULL,
    [label] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [Description] = N'Column definitions within input tables',
        [IsActive] = 1,
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [ParameterKey] = N'DL_ELEMENTS_QUESTIONS_INPUTTABLES_COLUMNS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[GlobalParameters]
    ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [Version])
    VALUES (N'DL_ELEMENTS_QUESTIONS_INPUTTABLES_COLUMNS', N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_QUESTIONS_INPUTTABLES_COLUMNS] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [column_id] NVARCHAR(MAX) NULL,
    [label] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'Column definitions within input tables', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- -----------------------------------------------------------------------------
-- 19. DL_ELEMENTS_QUESTIONS_INPUTTABLES_ROWS
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[GlobalParameters] WHERE [ParameterKey] = N'DL_ELEMENTS_QUESTIONS_INPUTTABLES_ROWS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_surveyhero001].[GlobalParameters]
    SET [ParameterValue] = N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_QUESTIONS_INPUTTABLES_ROWS] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [row_id] NVARCHAR(MAX) NULL,
    [label] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [Description] = N'Row definitions within input tables',
        [IsActive] = 1,
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [ParameterKey] = N'DL_ELEMENTS_QUESTIONS_INPUTTABLES_ROWS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[GlobalParameters]
    ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [Version])
    VALUES (N'DL_ELEMENTS_QUESTIONS_INPUTTABLES_ROWS', N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_QUESTIONS_INPUTTABLES_ROWS] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [row_id] NVARCHAR(MAX) NULL,
    [label] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'Row definitions within input tables', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- -----------------------------------------------------------------------------
-- 20. DL_ELEMENTS_QUESTIONS_RANKINGS
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[GlobalParameters] WHERE [ParameterKey] = N'DL_ELEMENTS_QUESTIONS_RANKINGS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_surveyhero001].[GlobalParameters]
    SET [ParameterValue] = N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_QUESTIONS_RANKINGS] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [settings_allows_not_applicable] NVARCHAR(MAX) NULL,
    [settings_not_applicable_label] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [Description] = N'Ranking question settings',
        [IsActive] = 1,
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [ParameterKey] = N'DL_ELEMENTS_QUESTIONS_RANKINGS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[GlobalParameters]
    ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [Version])
    VALUES (N'DL_ELEMENTS_QUESTIONS_RANKINGS', N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_QUESTIONS_RANKINGS] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [settings_allows_not_applicable] NVARCHAR(MAX) NULL,
    [settings_not_applicable_label] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'Ranking question settings', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- -----------------------------------------------------------------------------
-- 21. DL_ELEMENTS_QUESTIONS_RANKINGS_CHOICES
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[GlobalParameters] WHERE [ParameterKey] = N'DL_ELEMENTS_QUESTIONS_RANKINGS_CHOICES' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_surveyhero001].[GlobalParameters]
    SET [ParameterValue] = N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_QUESTIONS_RANKINGS_CHOICES] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [choice_id] NVARCHAR(MAX) NULL,
    [label] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [Description] = N'Choices within ranking questions',
        [IsActive] = 1,
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [ParameterKey] = N'DL_ELEMENTS_QUESTIONS_RANKINGS_CHOICES' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[GlobalParameters]
    ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [Version])
    VALUES (N'DL_ELEMENTS_QUESTIONS_RANKINGS_CHOICES', N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_QUESTIONS_RANKINGS_CHOICES] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [choice_id] NVARCHAR(MAX) NULL,
    [label] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'Choices within ranking questions', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- -----------------------------------------------------------------------------
-- 22. DL_ELEMENTS_QUESTIONS_RATINGSCALES
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[GlobalParameters] WHERE [ParameterKey] = N'DL_ELEMENTS_QUESTIONS_RATINGSCALES' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_surveyhero001].[GlobalParameters]
    SET [ParameterValue] = N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_QUESTIONS_RATINGSCALES] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [style] NVARCHAR(MAX) NULL,
    [left_label] NVARCHAR(MAX) NULL,
    [left_value] NVARCHAR(MAX) NULL,
    [right_label] NVARCHAR(MAX) NULL,
    [right_value] NVARCHAR(MAX) NULL,
    [step_size] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [Description] = N'Rating scale question definitions',
        [IsActive] = 1,
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [ParameterKey] = N'DL_ELEMENTS_QUESTIONS_RATINGSCALES' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[GlobalParameters]
    ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [Version])
    VALUES (N'DL_ELEMENTS_QUESTIONS_RATINGSCALES', N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_QUESTIONS_RATINGSCALES] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [style] NVARCHAR(MAX) NULL,
    [left_label] NVARCHAR(MAX) NULL,
    [left_value] NVARCHAR(MAX) NULL,
    [right_label] NVARCHAR(MAX) NULL,
    [right_value] NVARCHAR(MAX) NULL,
    [step_size] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'Rating scale question definitions', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- -----------------------------------------------------------------------------
-- 23. DL_ELEMENTS_SEPARATORS
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[GlobalParameters] WHERE [ParameterKey] = N'DL_ELEMENTS_SEPARATORS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_surveyhero001].[GlobalParameters]
    SET [ParameterValue] = N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_SEPARATORS] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [separator] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [Description] = N'Element separator data',
        [IsActive] = 1,
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [ParameterKey] = N'DL_ELEMENTS_SEPARATORS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[GlobalParameters]
    ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [Version])
    VALUES (N'DL_ELEMENTS_SEPARATORS', N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_SEPARATORS] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [separator] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'Element separator data', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- -----------------------------------------------------------------------------
-- 24. DL_ELEMENTS_TEXTS
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[GlobalParameters] WHERE [ParameterKey] = N'DL_ELEMENTS_TEXTS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_surveyhero001].[GlobalParameters]
    SET [ParameterValue] = N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_TEXTS] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [value] NVARCHAR(MAX) NULL,
    [style] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [Description] = N'Element text content',
        [IsActive] = 1,
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [ParameterKey] = N'DL_ELEMENTS_TEXTS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[GlobalParameters]
    ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [Version])
    VALUES (N'DL_ELEMENTS_TEXTS', N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_TEXTS] (
    [survey_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [value] NVARCHAR(MAX) NULL,
    [style] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'Element text content', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- -----------------------------------------------------------------------------
-- 25. DL_RESPONSES
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[GlobalParameters] WHERE [ParameterKey] = N'DL_RESPONSES' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_surveyhero001].[GlobalParameters]
    SET [ParameterValue] = N'CREATE TABLE [int_surveyhero001].[DL_RESPONSES] (
    [survey_id] NVARCHAR(MAX) NULL,
    [response_id] NVARCHAR(MAX) NULL,
    [collector_id] NVARCHAR(MAX) NULL,
    [started_on] NVARCHAR(MAX) NULL,
    [last_updated_on] NVARCHAR(MAX) NULL,
    [access_code] NVARCHAR(MAX) NULL,
    [email_address] NVARCHAR(MAX) NULL,
    [recipient_data] NVARCHAR(MAX) NULL,
    [link_parameters] NVARCHAR(MAX) NULL,
    [language_code] NVARCHAR(MAX) NULL,
    [language_name] NVARCHAR(MAX) NULL,
    [ip_address] NVARCHAR(MAX) NULL,
    [meta_data_device] NVARCHAR(MAX) NULL,
    [meta_data_user_agent] NVARCHAR(MAX) NULL,
    [status] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [Description] = N'All responses to each survey',
        [IsActive] = 1,
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [ParameterKey] = N'DL_RESPONSES' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[GlobalParameters]
    ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [Version])
    VALUES (N'DL_RESPONSES', N'CREATE TABLE [int_surveyhero001].[DL_RESPONSES] (
    [survey_id] NVARCHAR(MAX) NULL,
    [response_id] NVARCHAR(MAX) NULL,
    [collector_id] NVARCHAR(MAX) NULL,
    [started_on] NVARCHAR(MAX) NULL,
    [last_updated_on] NVARCHAR(MAX) NULL,
    [access_code] NVARCHAR(MAX) NULL,
    [email_address] NVARCHAR(MAX) NULL,
    [recipient_data] NVARCHAR(MAX) NULL,
    [link_parameters] NVARCHAR(MAX) NULL,
    [language_code] NVARCHAR(MAX) NULL,
    [language_name] NVARCHAR(MAX) NULL,
    [ip_address] NVARCHAR(MAX) NULL,
    [meta_data_device] NVARCHAR(MAX) NULL,
    [meta_data_user_agent] NVARCHAR(MAX) NULL,
    [status] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'All responses to each survey', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- -----------------------------------------------------------------------------
-- 26. DL_RESPONSES_ANSWERS
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[GlobalParameters] WHERE [ParameterKey] = N'DL_RESPONSES_ANSWERS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_surveyhero001].[GlobalParameters]
    SET [ParameterValue] = N'CREATE TABLE [int_surveyhero001].[DL_RESPONSES_ANSWERS] (
    [survey_id] NVARCHAR(MAX) NULL,
    [response_id] NVARCHAR(MAX) NULL,
    [collector_id] NVARCHAR(MAX) NULL,
    [started_on] NVARCHAR(MAX) NULL,
    [last_updated_on] NVARCHAR(MAX) NULL,
    [access_code] NVARCHAR(MAX) NULL,
    [email_address] NVARCHAR(MAX) NULL,
    [recipient_data] NVARCHAR(MAX) NULL,
    [link_parameters] NVARCHAR(MAX) NULL,
    [language_code] NVARCHAR(MAX) NULL,
    [language_name] NVARCHAR(MAX) NULL,
    [ip_address] NVARCHAR(MAX) NULL,
    [meta_data_device] NVARCHAR(MAX) NULL,
    [meta_data_user_agent] NVARCHAR(MAX) NULL,
    [status] NVARCHAR(MAX) NULL,
    [answer_element_id] NVARCHAR(MAX) NULL,
    [answer_question_text] NVARCHAR(MAX) NULL,
    [answer_type] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [Description] = N'Response-level answer metadata',
        [IsActive] = 1,
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [ParameterKey] = N'DL_RESPONSES_ANSWERS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[GlobalParameters]
    ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [Version])
    VALUES (N'DL_RESPONSES_ANSWERS', N'CREATE TABLE [int_surveyhero001].[DL_RESPONSES_ANSWERS] (
    [survey_id] NVARCHAR(MAX) NULL,
    [response_id] NVARCHAR(MAX) NULL,
    [collector_id] NVARCHAR(MAX) NULL,
    [started_on] NVARCHAR(MAX) NULL,
    [last_updated_on] NVARCHAR(MAX) NULL,
    [access_code] NVARCHAR(MAX) NULL,
    [email_address] NVARCHAR(MAX) NULL,
    [recipient_data] NVARCHAR(MAX) NULL,
    [link_parameters] NVARCHAR(MAX) NULL,
    [language_code] NVARCHAR(MAX) NULL,
    [language_name] NVARCHAR(MAX) NULL,
    [ip_address] NVARCHAR(MAX) NULL,
    [meta_data_device] NVARCHAR(MAX) NULL,
    [meta_data_user_agent] NVARCHAR(MAX) NULL,
    [status] NVARCHAR(MAX) NULL,
    [answer_element_id] NVARCHAR(MAX) NULL,
    [answer_question_text] NVARCHAR(MAX) NULL,
    [answer_type] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'Response-level answer metadata', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- -----------------------------------------------------------------------------
-- 27. DL_RESPONSES_ANSWERS_CHOICES
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[GlobalParameters] WHERE [ParameterKey] = N'DL_RESPONSES_ANSWERS_CHOICES' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_surveyhero001].[GlobalParameters]
    SET [ParameterValue] = N'CREATE TABLE [int_surveyhero001].[DL_RESPONSES_ANSWERS_CHOICES] (
    [survey_id] NVARCHAR(MAX) NULL,
    [response_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [choice_id] NVARCHAR(MAX) NULL,
    [label] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [Description] = N'Choice answers from responses',
        [IsActive] = 1,
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [ParameterKey] = N'DL_RESPONSES_ANSWERS_CHOICES' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[GlobalParameters]
    ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [Version])
    VALUES (N'DL_RESPONSES_ANSWERS_CHOICES', N'CREATE TABLE [int_surveyhero001].[DL_RESPONSES_ANSWERS_CHOICES] (
    [survey_id] NVARCHAR(MAX) NULL,
    [response_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [choice_id] NVARCHAR(MAX) NULL,
    [label] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'Choice answers from responses', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- -----------------------------------------------------------------------------
-- 28. DL_RESPONSES_ANSWERS_CHOICETABLES
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[GlobalParameters] WHERE [ParameterKey] = N'DL_RESPONSES_ANSWERS_CHOICETABLES' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_surveyhero001].[GlobalParameters]
    SET [ParameterValue] = N'CREATE TABLE [int_surveyhero001].[DL_RESPONSES_ANSWERS_CHOICETABLES] (
    [survey_id] NVARCHAR(MAX) NULL,
    [response_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [row_id] NVARCHAR(MAX) NULL,
    [label] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [Description] = N'Choice table row answers from responses',
        [IsActive] = 1,
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [ParameterKey] = N'DL_RESPONSES_ANSWERS_CHOICETABLES' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[GlobalParameters]
    ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [Version])
    VALUES (N'DL_RESPONSES_ANSWERS_CHOICETABLES', N'CREATE TABLE [int_surveyhero001].[DL_RESPONSES_ANSWERS_CHOICETABLES] (
    [survey_id] NVARCHAR(MAX) NULL,
    [response_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [row_id] NVARCHAR(MAX) NULL,
    [label] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'Choice table row answers from responses', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- -----------------------------------------------------------------------------
-- 29. DL_RESPONSES_ANSWERS_CHOICETABLES_CHOICES
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[GlobalParameters] WHERE [ParameterKey] = N'DL_RESPONSES_ANSWERS_CHOICETABLES_CHOICES' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_surveyhero001].[GlobalParameters]
    SET [ParameterValue] = N'CREATE TABLE [int_surveyhero001].[DL_RESPONSES_ANSWERS_CHOICETABLES_CHOICES] (
    [survey_id] NVARCHAR(MAX) NULL,
    [response_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [row_id] NVARCHAR(MAX) NULL,
    [choice_id] NVARCHAR(MAX) NULL,
    [label] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [Description] = N'Choice table cell selections from responses',
        [IsActive] = 1,
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [ParameterKey] = N'DL_RESPONSES_ANSWERS_CHOICETABLES_CHOICES' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[GlobalParameters]
    ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [Version])
    VALUES (N'DL_RESPONSES_ANSWERS_CHOICETABLES_CHOICES', N'CREATE TABLE [int_surveyhero001].[DL_RESPONSES_ANSWERS_CHOICETABLES_CHOICES] (
    [survey_id] NVARCHAR(MAX) NULL,
    [response_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [row_id] NVARCHAR(MAX) NULL,
    [choice_id] NVARCHAR(MAX) NULL,
    [label] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'Choice table cell selections from responses', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- -----------------------------------------------------------------------------
-- 30. DL_RESPONSES_ANSWERS_DATES
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[GlobalParameters] WHERE [ParameterKey] = N'DL_RESPONSES_ANSWERS_DATES' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_surveyhero001].[GlobalParameters]
    SET [ParameterValue] = N'CREATE TABLE [int_surveyhero001].[DL_RESPONSES_ANSWERS_DATES] (
    [survey_id] NVARCHAR(MAX) NULL,
    [response_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [value] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [Description] = N'Date-type answers from responses',
        [IsActive] = 1,
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [ParameterKey] = N'DL_RESPONSES_ANSWERS_DATES' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[GlobalParameters]
    ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [Version])
    VALUES (N'DL_RESPONSES_ANSWERS_DATES', N'CREATE TABLE [int_surveyhero001].[DL_RESPONSES_ANSWERS_DATES] (
    [survey_id] NVARCHAR(MAX) NULL,
    [response_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [value] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'Date-type answers from responses', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- -----------------------------------------------------------------------------
-- 31. DL_RESPONSES_ANSWERS_FILES
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[GlobalParameters] WHERE [ParameterKey] = N'DL_RESPONSES_ANSWERS_FILES' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_surveyhero001].[GlobalParameters]
    SET [ParameterValue] = N'CREATE TABLE [int_surveyhero001].[DL_RESPONSES_ANSWERS_FILES] (
    [survey_id] NVARCHAR(MAX) NULL,
    [response_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [file_name] NVARCHAR(MAX) NULL,
    [file_size] NVARCHAR(MAX) NULL,
    [file_path] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [Description] = N'File upload answers from responses',
        [IsActive] = 1,
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [ParameterKey] = N'DL_RESPONSES_ANSWERS_FILES' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[GlobalParameters]
    ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [Version])
    VALUES (N'DL_RESPONSES_ANSWERS_FILES', N'CREATE TABLE [int_surveyhero001].[DL_RESPONSES_ANSWERS_FILES] (
    [survey_id] NVARCHAR(MAX) NULL,
    [response_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [file_name] NVARCHAR(MAX) NULL,
    [file_size] NVARCHAR(MAX) NULL,
    [file_path] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'File upload answers from responses', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- -----------------------------------------------------------------------------
-- 32. DL_RESPONSES_ANSWERS_INPUTS
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[GlobalParameters] WHERE [ParameterKey] = N'DL_RESPONSES_ANSWERS_INPUTS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_surveyhero001].[GlobalParameters]
    SET [ParameterValue] = N'CREATE TABLE [int_surveyhero001].[DL_RESPONSES_ANSWERS_INPUTS] (
    [survey_id] NVARCHAR(MAX) NULL,
    [response_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [input_id] NVARCHAR(MAX) NULL,
    [label] NVARCHAR(MAX) NULL,
    [answer] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [Description] = N'Input-type answers from responses',
        [IsActive] = 1,
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [ParameterKey] = N'DL_RESPONSES_ANSWERS_INPUTS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[GlobalParameters]
    ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [Version])
    VALUES (N'DL_RESPONSES_ANSWERS_INPUTS', N'CREATE TABLE [int_surveyhero001].[DL_RESPONSES_ANSWERS_INPUTS] (
    [survey_id] NVARCHAR(MAX) NULL,
    [response_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [input_id] NVARCHAR(MAX) NULL,
    [label] NVARCHAR(MAX) NULL,
    [answer] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'Input-type answers from responses', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- -----------------------------------------------------------------------------
-- 33. DL_RESPONSES_ANSWERS_INPUTTABLES
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[GlobalParameters] WHERE [ParameterKey] = N'DL_RESPONSES_ANSWERS_INPUTTABLES' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_surveyhero001].[GlobalParameters]
    SET [ParameterValue] = N'CREATE TABLE [int_surveyhero001].[DL_RESPONSES_ANSWERS_INPUTTABLES] (
    [survey_id] NVARCHAR(MAX) NULL,
    [response_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [row_id] NVARCHAR(MAX) NULL,
    [label] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [Description] = N'Input table row answers from responses',
        [IsActive] = 1,
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [ParameterKey] = N'DL_RESPONSES_ANSWERS_INPUTTABLES' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[GlobalParameters]
    ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [Version])
    VALUES (N'DL_RESPONSES_ANSWERS_INPUTTABLES', N'CREATE TABLE [int_surveyhero001].[DL_RESPONSES_ANSWERS_INPUTTABLES] (
    [survey_id] NVARCHAR(MAX) NULL,
    [response_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [row_id] NVARCHAR(MAX) NULL,
    [label] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'Input table row answers from responses', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- -----------------------------------------------------------------------------
-- 34. DL_RESPONSES_ANSWERS_INPUTTABLES_COLUMNS
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[GlobalParameters] WHERE [ParameterKey] = N'DL_RESPONSES_ANSWERS_INPUTTABLES_COLUMNS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_surveyhero001].[GlobalParameters]
    SET [ParameterValue] = N'CREATE TABLE [int_surveyhero001].[DL_RESPONSES_ANSWERS_INPUTTABLES_COLUMNS] (
    [survey_id] NVARCHAR(MAX) NULL,
    [response_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [row_id] NVARCHAR(MAX) NULL,
    [column_id] NVARCHAR(MAX) NULL,
    [label] NVARCHAR(MAX) NULL,
    [answer] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [Description] = N'Input table cell answers from responses',
        [IsActive] = 1,
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [ParameterKey] = N'DL_RESPONSES_ANSWERS_INPUTTABLES_COLUMNS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[GlobalParameters]
    ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [Version])
    VALUES (N'DL_RESPONSES_ANSWERS_INPUTTABLES_COLUMNS', N'CREATE TABLE [int_surveyhero001].[DL_RESPONSES_ANSWERS_INPUTTABLES_COLUMNS] (
    [survey_id] NVARCHAR(MAX) NULL,
    [response_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [row_id] NVARCHAR(MAX) NULL,
    [column_id] NVARCHAR(MAX) NULL,
    [label] NVARCHAR(MAX) NULL,
    [answer] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'Input table cell answers from responses', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- -----------------------------------------------------------------------------
-- 35. DL_RESPONSES_ANSWERS_NUMBERS
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[GlobalParameters] WHERE [ParameterKey] = N'DL_RESPONSES_ANSWERS_NUMBERS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_surveyhero001].[GlobalParameters]
    SET [ParameterValue] = N'CREATE TABLE [int_surveyhero001].[DL_RESPONSES_ANSWERS_NUMBERS] (
    [survey_id] NVARCHAR(MAX) NULL,
    [response_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [value] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [Description] = N'Numeric answers from responses',
        [IsActive] = 1,
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [ParameterKey] = N'DL_RESPONSES_ANSWERS_NUMBERS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[GlobalParameters]
    ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [Version])
    VALUES (N'DL_RESPONSES_ANSWERS_NUMBERS', N'CREATE TABLE [int_surveyhero001].[DL_RESPONSES_ANSWERS_NUMBERS] (
    [survey_id] NVARCHAR(MAX) NULL,
    [response_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [value] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'Numeric answers from responses', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- -----------------------------------------------------------------------------
-- 36. DL_RESPONSES_ANSWERS_RANKINGS
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[GlobalParameters] WHERE [ParameterKey] = N'DL_RESPONSES_ANSWERS_RANKINGS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_surveyhero001].[GlobalParameters]
    SET [ParameterValue] = N'CREATE TABLE [int_surveyhero001].[DL_RESPONSES_ANSWERS_RANKINGS] (
    [survey_id] NVARCHAR(MAX) NULL,
    [response_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [Description] = N'Ranking answer metadata from responses',
        [IsActive] = 1,
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [ParameterKey] = N'DL_RESPONSES_ANSWERS_RANKINGS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[GlobalParameters]
    ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [Version])
    VALUES (N'DL_RESPONSES_ANSWERS_RANKINGS', N'CREATE TABLE [int_surveyhero001].[DL_RESPONSES_ANSWERS_RANKINGS] (
    [survey_id] NVARCHAR(MAX) NULL,
    [response_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'Ranking answer metadata from responses', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- -----------------------------------------------------------------------------
-- 37. DL_RESPONSES_ANSWERS_RANKINGS_NOTAPPLICABLE
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[GlobalParameters] WHERE [ParameterKey] = N'DL_RESPONSES_ANSWERS_RANKINGS_NOTAPPLICABLE' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_surveyhero001].[GlobalParameters]
    SET [ParameterValue] = N'CREATE TABLE [int_surveyhero001].[DL_RESPONSES_ANSWERS_RANKINGS_NOTAPPLICABLE] (
    [survey_id] NVARCHAR(MAX) NULL,
    [response_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [choice_id] NVARCHAR(MAX) NULL,
    [label] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [Description] = N'Not-applicable ranking choices from responses',
        [IsActive] = 1,
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [ParameterKey] = N'DL_RESPONSES_ANSWERS_RANKINGS_NOTAPPLICABLE' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[GlobalParameters]
    ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [Version])
    VALUES (N'DL_RESPONSES_ANSWERS_RANKINGS_NOTAPPLICABLE', N'CREATE TABLE [int_surveyhero001].[DL_RESPONSES_ANSWERS_RANKINGS_NOTAPPLICABLE] (
    [survey_id] NVARCHAR(MAX) NULL,
    [response_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [choice_id] NVARCHAR(MAX) NULL,
    [label] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'Not-applicable ranking choices from responses', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- -----------------------------------------------------------------------------
-- 38. DL_RESPONSES_ANSWERS_RANKINGS_RANKED
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[GlobalParameters] WHERE [ParameterKey] = N'DL_RESPONSES_ANSWERS_RANKINGS_RANKED' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_surveyhero001].[GlobalParameters]
    SET [ParameterValue] = N'CREATE TABLE [int_surveyhero001].[DL_RESPONSES_ANSWERS_RANKINGS_RANKED] (
    [survey_id] NVARCHAR(MAX) NULL,
    [response_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [choice_id] NVARCHAR(MAX) NULL,
    [label] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [Description] = N'Ranked choices from responses',
        [IsActive] = 1,
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [ParameterKey] = N'DL_RESPONSES_ANSWERS_RANKINGS_RANKED' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[GlobalParameters]
    ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [Version])
    VALUES (N'DL_RESPONSES_ANSWERS_RANKINGS_RANKED', N'CREATE TABLE [int_surveyhero001].[DL_RESPONSES_ANSWERS_RANKINGS_RANKED] (
    [survey_id] NVARCHAR(MAX) NULL,
    [response_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [choice_id] NVARCHAR(MAX) NULL,
    [label] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'Ranked choices from responses', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- -----------------------------------------------------------------------------
-- 39. DL_RESPONSES_ANSWERS_TEXTS
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[GlobalParameters] WHERE [ParameterKey] = N'DL_RESPONSES_ANSWERS_TEXTS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_surveyhero001].[GlobalParameters]
    SET [ParameterValue] = N'CREATE TABLE [int_surveyhero001].[DL_RESPONSES_ANSWERS_TEXTS] (
    [survey_id] NVARCHAR(MAX) NULL,
    [response_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [value] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [Description] = N'Free-text answers from responses',
        [IsActive] = 1,
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [ParameterKey] = N'DL_RESPONSES_ANSWERS_TEXTS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[GlobalParameters]
    ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [Version])
    VALUES (N'DL_RESPONSES_ANSWERS_TEXTS', N'CREATE TABLE [int_surveyhero001].[DL_RESPONSES_ANSWERS_TEXTS] (
    [survey_id] NVARCHAR(MAX) NULL,
    [response_id] NVARCHAR(MAX) NULL,
    [element_id] NVARCHAR(MAX) NULL,
    [value] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'Free-text answers from responses', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- -----------------------------------------------------------------------------
-- 40. DL_SURVEYS
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[GlobalParameters] WHERE [ParameterKey] = N'DL_SURVEYS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_surveyhero001].[GlobalParameters]
    SET [ParameterValue] = N'CREATE TABLE [int_surveyhero001].[DL_SURVEYS] (
    [survey_id] NVARCHAR(MAX) NULL,
    [title] NVARCHAR(MAX) NULL,
    [internal_name] NVARCHAR(MAX) NULL,
    [created_on] NVARCHAR(MAX) NULL,
    [number_of_questions] NVARCHAR(MAX) NULL,
    [number_of_collectors] NVARCHAR(MAX) NULL,
    [number_of_responses] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [Description] = N'All surveys at endpoint',
        [IsActive] = 1,
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [ParameterKey] = N'DL_SURVEYS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[GlobalParameters]
    ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [Version])
    VALUES (N'DL_SURVEYS', N'CREATE TABLE [int_surveyhero001].[DL_SURVEYS] (
    [survey_id] NVARCHAR(MAX) NULL,
    [title] NVARCHAR(MAX) NULL,
    [internal_name] NVARCHAR(MAX) NULL,
    [created_on] NVARCHAR(MAX) NULL,
    [number_of_questions] NVARCHAR(MAX) NULL,
    [number_of_collectors] NVARCHAR(MAX) NULL,
    [number_of_responses] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'All surveys at endpoint', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- -----------------------------------------------------------------------------
-- 41. DL_SURVEYS_DETAILS
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[GlobalParameters] WHERE [ParameterKey] = N'DL_SURVEYS_DETAILS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_surveyhero001].[GlobalParameters]
    SET [ParameterValue] = N'CREATE TABLE [int_surveyhero001].[DL_SURVEYS_DETAILS] (
    [survey_id] NVARCHAR(MAX) NULL,
    [title] NVARCHAR(MAX) NULL,
    [created_on] NVARCHAR(MAX) NULL,
    [number_of_elements] NVARCHAR(MAX) NULL,
    [number_of_questions] NVARCHAR(MAX) NULL,
    [number_of_collectors] NVARCHAR(MAX) NULL,
    [number_of_responses] NVARCHAR(MAX) NULL,
    [number_of_webhooks] NVARCHAR(MAX) NULL,
    [settings_is_anonymous] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [Description] = N'Detailed survey metadata',
        [IsActive] = 1,
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [ParameterKey] = N'DL_SURVEYS_DETAILS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[GlobalParameters]
    ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [Version])
    VALUES (N'DL_SURVEYS_DETAILS', N'CREATE TABLE [int_surveyhero001].[DL_SURVEYS_DETAILS] (
    [survey_id] NVARCHAR(MAX) NULL,
    [title] NVARCHAR(MAX) NULL,
    [created_on] NVARCHAR(MAX) NULL,
    [number_of_elements] NVARCHAR(MAX) NULL,
    [number_of_questions] NVARCHAR(MAX) NULL,
    [number_of_collectors] NVARCHAR(MAX) NULL,
    [number_of_responses] NVARCHAR(MAX) NULL,
    [number_of_webhooks] NVARCHAR(MAX) NULL,
    [settings_is_anonymous] NVARCHAR(MAX) NULL,
    [LOADTS_UTC] DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'Detailed survey metadata', 1, SYSTEM_USER, GETDATE(), 1);
END
GO
