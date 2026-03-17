-- API Table DDL Export
-- Schema: int_surveyhero001
-- Generated: 2026-01-12 14:27:19
-- Total Tables: 8

-- Table: DL_ANSWERS
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_surveyhero001].[GlobalParameters] WHERE ParameterKey = N'DL_ANSWERS' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_surveyhero001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_surveyhero001].[DL_ANSWERS] (
    survey_id BIGINT,
    response_id BIGINT,
    element_id BIGINT,
    question_text NVARCHAR(MAX),
    answer_type NVARCHAR(50), 
    text_value NVARCHAR(MAX),
    number_value FLOAT, 
    file_value NVARCHAR(MAX), 
    LOADTS_UTC DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'base answer data',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_ANSWERS' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_surveyhero001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_ANSWERS', N'CREATE TABLE [int_surveyhero001].[DL_ANSWERS] (
    survey_id BIGINT,
    response_id BIGINT,
    element_id BIGINT,
    question_text NVARCHAR(MAX),
    answer_type NVARCHAR(50), 
    text_value NVARCHAR(MAX),
    number_value FLOAT, 
    file_value NVARCHAR(MAX), 
    LOADTS_UTC DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'base answer data', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_ANSWERS_CHOICES
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_surveyhero001].[GlobalParameters] WHERE ParameterKey = N'DL_ANSWERS_CHOICES' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_surveyhero001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_surveyhero001].[DL_ANSWERS_CHOICES] (
    survey_id BIGINT,
    response_id BIGINT,
    element_id BIGINT,
    choice_id BIGINT,
    label NVARCHAR(MAX),
    image_url NVARCHAR(MAX),
    row_id BIGINT NULL,
    LOADTS_UTC DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_ANSWERS_CHOICES (exploded choices from answers)',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_ANSWERS_CHOICES' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_surveyhero001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_ANSWERS_CHOICES', N'CREATE TABLE [int_surveyhero001].[DL_ANSWERS_CHOICES] (
    survey_id BIGINT,
    response_id BIGINT,
    element_id BIGINT,
    choice_id BIGINT,
    label NVARCHAR(MAX),
    image_url NVARCHAR(MAX),
    row_id BIGINT NULL,
    LOADTS_UTC DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_ANSWERS_CHOICES (exploded choices from answers)', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_ANSWERS_INPUT_TABLE
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_surveyhero001].[GlobalParameters] WHERE ParameterKey = N'DL_ANSWERS_INPUT_TABLE' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_surveyhero001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_surveyhero001].[DL_ANSWERS_INPUT_TABLE] (
    survey_id BIGINT,
    response_id BIGINT,
    element_id BIGINT,
    row_id BIGINT,
    row_label NVARCHAR(MAX),
    column_id BIGINT,
    column_label NVARCHAR(MAX),
    answer_type NVARCHAR(50),
    number_value FLOAT,
    text_value NVARCHAR(MAX),
    LOADTS_UTC DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_ANSWERS_INPUT_TABLE (for input_table questions)',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_ANSWERS_INPUT_TABLE' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_surveyhero001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_ANSWERS_INPUT_TABLE', N'CREATE TABLE [int_surveyhero001].[DL_ANSWERS_INPUT_TABLE] (
    survey_id BIGINT,
    response_id BIGINT,
    element_id BIGINT,
    row_id BIGINT,
    row_label NVARCHAR(MAX),
    column_id BIGINT,
    column_label NVARCHAR(MAX),
    answer_type NVARCHAR(50),
    number_value FLOAT,
    text_value NVARCHAR(MAX),
    LOADTS_UTC DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_ANSWERS_INPUT_TABLE (for input_table questions)', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_ANSWERS_RANKING
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_surveyhero001].[GlobalParameters] WHERE ParameterKey = N'DL_ANSWERS_RANKING' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_surveyhero001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_surveyhero001].[DL_ANSWERS_RANKING] (
    survey_id BIGINT,
    response_id BIGINT,
    element_id BIGINT,
    choice_id BIGINT,
    label NVARCHAR(MAX),
    rank_order INT,
    is_not_applicable BIT,
    LOADTS_UTC DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_ANSWERS_RANKING (for ranking questions)',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_ANSWERS_RANKING' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_surveyhero001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_ANSWERS_RANKING', N'CREATE TABLE [int_surveyhero001].[DL_ANSWERS_RANKING] (
    survey_id BIGINT,
    response_id BIGINT,
    element_id BIGINT,
    choice_id BIGINT,
    label NVARCHAR(MAX),
    rank_order INT,
    is_not_applicable BIT,
    LOADTS_UTC DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_ANSWERS_RANKING (for ranking questions)', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_ELEMENTS
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_surveyhero001].[GlobalParameters] WHERE ParameterKey = N'DL_ELEMENTS' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_surveyhero001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS] (
    survey_id BIGINT,
    element_id BIGINT,
    type NVARCHAR(50),
    question_text NVARCHAR(MAX),
    description_text NVARCHAR(MAX),
    question_type NVARCHAR(50),
    is_required BIT,
    settings_json NVARCHAR(MAX),
    LOADTS_UTC DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'Information about the components of each survey',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_ELEMENTS' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_surveyhero001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_ELEMENTS', N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS] (
    survey_id BIGINT,
    element_id BIGINT,
    type NVARCHAR(50),
    question_text NVARCHAR(MAX),
    description_text NVARCHAR(MAX),
    question_type NVARCHAR(50),
    is_required BIT,
    settings_json NVARCHAR(MAX),
    LOADTS_UTC DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'Information about the components of each survey', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_ELEMENTS_CHOICES
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_surveyhero001].[GlobalParameters] WHERE ParameterKey = N'DL_ELEMENTS_CHOICES' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_surveyhero001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_CHOICES] (
    survey_id BIGINT,
    element_id BIGINT,
    choice_id BIGINT,
    label NVARCHAR(MAX),
    image_url NVARCHAR(MAX),
    row_id BIGINT NULL,
    column_id BIGINT NULL,
    LOADTS_UTC DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_ELEMENTS_CHOICES (exploded choices from elements)',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_ELEMENTS_CHOICES' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_surveyhero001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_ELEMENTS_CHOICES', N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_CHOICES] (
    survey_id BIGINT,
    element_id BIGINT,
    choice_id BIGINT,
    label NVARCHAR(MAX),
    image_url NVARCHAR(MAX),
    row_id BIGINT NULL,
    column_id BIGINT NULL,
    LOADTS_UTC DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_ELEMENTS_CHOICES (exploded choices from elements)', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_RESPONSES
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_surveyhero001].[GlobalParameters] WHERE ParameterKey = N'DL_RESPONSES' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_surveyhero001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_surveyhero001].[DL_RESPONSES] (
    survey_id BIGINT,
    response_id BIGINT,
    collector_id BIGINT,
    started_on DATETIME2,
    last_updated_on DATETIME2,
    access_code NVARCHAR(255),
    email_address NVARCHAR(255),
    recipient_data NVARCHAR(MAX),
    link_parameters NVARCHAR(MAX),
    language NVARCHAR(50),
    ip_address NVARCHAR(50),
    meta_data_device NVARCHAR(50),
    meta_data_user_agent NVARCHAR(MAX),
    status NVARCHAR(50),
    LOADTS_UTC DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'All Responses to each survey',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_RESPONSES' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_surveyhero001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_RESPONSES', N'CREATE TABLE [int_surveyhero001].[DL_RESPONSES] (
    survey_id BIGINT,
    response_id BIGINT,
    collector_id BIGINT,
    started_on DATETIME2,
    last_updated_on DATETIME2,
    access_code NVARCHAR(255),
    email_address NVARCHAR(255),
    recipient_data NVARCHAR(MAX),
    link_parameters NVARCHAR(MAX),
    language NVARCHAR(50),
    ip_address NVARCHAR(50),
    meta_data_device NVARCHAR(50),
    meta_data_user_agent NVARCHAR(MAX),
    status NVARCHAR(50),
    LOADTS_UTC DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'All Responses to each survey', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_SURVEYS
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_surveyhero001].[GlobalParameters] WHERE ParameterKey = N'DL_SURVEYS' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_surveyhero001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_surveyhero001].[DL_SURVEYS] (
    survey_id BIGINT,
    title NVARCHAR(500),
    internal_name NVARCHAR(500),
    created_on DATETIME2,
    number_of_questions INT,
    number_of_collectors INT,
    number_of_responses INT,
    LOADTS_UTC DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'All surveys at endpoint',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_SURVEYS' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_surveyhero001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_SURVEYS', N'CREATE TABLE [int_surveyhero001].[DL_SURVEYS] (
    survey_id BIGINT,
    title NVARCHAR(500),
    internal_name NVARCHAR(500),
    created_on DATETIME2,
    number_of_questions INT,
    number_of_collectors INT,
    number_of_responses INT,
    LOADTS_UTC DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'All surveys at endpoint', 1, SYSTEM_USER, GETDATE(), 1);
END
GO
