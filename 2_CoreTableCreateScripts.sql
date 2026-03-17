USE [core]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*##########################################################################*/
/*##########################################################################*/
------------------------CREATE CORE TABLES-----------------------------------
/*##########################################################################*/
/*##########################################################################*/

/*##################################*/
/*      Data Vault Entities         */
/*##################################*/

IF NOT EXISTS (SELECT * FROM sys.tables WHERE schema_id = SCHEMA_ID('core') AND name = 'DataVaultEntities')
BEGIN
    CREATE TABLE [core].[DataVaultEntities](
        [ID] [int] IDENTITY(1,1) NOT NULL,
        [ENTITY_NAME] [varchar](255) NOT NULL,
        [DESCRIPTION] [text] NULL,
        [ATTRIBUTE_NAMES] [varchar](max) NULL,
        [ATTRIBUTE_TYPES] [varchar](max) NULL,
        [PRIMARY_SOURCE_TYPE] [varchar](255) NULL,
        [TIME_SERIES] [bit] NULL,
        [TIME_SERIES_COLUMN] [varchar](255) NULL,
        [CREATED_AT] [datetime] NULL,
        [UPDATED_AT] [datetime] NULL,
        [VERSION] [int] NOT NULL,
        [RELEASE_STATE] [varchar](20) NOT NULL,
        [SPLIT_MAP] [varchar](20) NULL,
    PRIMARY KEY CLUSTERED 
    (
        [ID] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
     CONSTRAINT [UQ_DataVaultEntities_Name_Version] UNIQUE NONCLUSTERED 
    (
        [ENTITY_NAME] ASC,
        [VERSION] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

    -- Add defaults
    ALTER TABLE [core].[DataVaultEntities] ADD DEFAULT (getdate()) FOR [CREATED_AT]
    ALTER TABLE [core].[DataVaultEntities] ADD DEFAULT (getdate()) FOR [UPDATED_AT]
    ALTER TABLE [core].[DataVaultEntities] ADD DEFAULT ((1)) FOR [VERSION]
    ALTER TABLE [core].[DataVaultEntities] ADD DEFAULT ('Build') FOR [RELEASE_STATE]
END
GO

/*##################################*/
/*      Global Parameters           */
/*##################################*/

IF NOT EXISTS (SELECT * FROM sys.tables WHERE schema_id = SCHEMA_ID('core') AND name = 'GlobalParameters')
BEGIN
    CREATE TABLE [core].[GlobalParameters](
        [ParameterID] [int] IDENTITY(1,1) NOT NULL,
        [ParameterKey] [nvarchar](100) NOT NULL,
        [ParameterValue] [nvarchar](4000) NULL,
        [DataType] [varchar](20) NOT NULL,
        [Category] [nvarchar](50) NULL,
        [Description] [nvarchar](500) NULL,
        [IsActive] [bit] NOT NULL,
        [CreatedBy] [nvarchar](100) NOT NULL,
        [CreatedDate] [datetime2](7) NOT NULL,
        [ModifiedBy] [nvarchar](100) NULL,
        [ModifiedDate] [datetime2](7) NULL,
        [Version] [int] NOT NULL,
     CONSTRAINT [PK_core_GlobalParameters] PRIMARY KEY CLUSTERED 
    (
        [ParameterID] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
     CONSTRAINT [UK_core_GlobalParameters_Key] UNIQUE NONCLUSTERED 
    (
        [ParameterKey] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
    ) ON [PRIMARY]

    -- Add defaults
    ALTER TABLE [core].[GlobalParameters] ADD DEFAULT ('STRING') FOR [DataType]
    ALTER TABLE [core].[GlobalParameters] ADD DEFAULT ((1)) FOR [IsActive]
    ALTER TABLE [core].[GlobalParameters] ADD DEFAULT (suser_sname()) FOR [CreatedBy]
    ALTER TABLE [core].[GlobalParameters] ADD DEFAULT (getdate()) FOR [CreatedDate]
    ALTER TABLE [core].[GlobalParameters] ADD DEFAULT ((1)) FOR [Version]
END
GO

-- Add check constraint if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE name = 'CK_core_GlobalParameters_DataType')
BEGIN
    ALTER TABLE [core].[GlobalParameters] WITH CHECK ADD CONSTRAINT [CK_core_GlobalParameters_DataType] 
    CHECK (([DataType]='JSON' OR [DataType]='DATETIME' OR [DataType]='DATE' OR [DataType]='BOOLEAN' OR [DataType]='DECIMAL' OR [DataType]='INT' OR [DataType]='STRING'))
    
    ALTER TABLE [core].[GlobalParameters] CHECK CONSTRAINT [CK_core_GlobalParameters_DataType]
END
GO

-- Create indexes if they don't exist
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_core_GlobalParameters_Active')
BEGIN
    CREATE NONCLUSTERED INDEX [IX_core_GlobalParameters_Active] ON [core].[GlobalParameters]
    (
        [IsActive] ASC
    )
    INCLUDE([ParameterKey],[ParameterValue],[DataType]) 
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_core_GlobalParameters_Category')
BEGIN
    CREATE NONCLUSTERED INDEX [IX_core_GlobalParameters_Category] ON [core].[GlobalParameters]
    (
        [Category] ASC
    )
    WHERE ([IsActive]=(1))
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
END
GO

/*##################################*/
/*      Integrations                */
/*##################################*/

IF NOT EXISTS (SELECT * FROM sys.tables WHERE schema_id = SCHEMA_ID('core') AND name = 'Integrations')
BEGIN
    CREATE TABLE [core].[Integrations](
        [IntegrationID] [int] IDENTITY(1,1) NOT NULL,
        [IntegrationCode] [uniqueidentifier] NOT NULL,
        [IntegrationName] [nvarchar](100) NOT NULL,
        [IntegrationDisplayName] [nvarchar](200) NULL,
        [SchemaName] [nvarchar](128) NULL,
        [SchemaCreated] [bit] NOT NULL,
        [SchemaCreationRequested] [bit] NOT NULL,
        [Version] [nvarchar](20) NOT NULL,
        [Description] [nvarchar](500) NULL,
        [IsActive] [bit] NOT NULL,
        [CreatedBy] [nvarchar](100) NOT NULL,
        [CreatedDate] [datetime2](7) NOT NULL,
        [ModifiedBy] [nvarchar](100) NULL,
        [ModifiedDate] [datetime2](7) NULL,
        [SchemaCreatedDate] [datetime2](7) NULL,
        [APIEndpointDetail] [varchar](max) NULL,
        [IntegrationType] [nvarchar](50) NULL,
     CONSTRAINT [PK_core_Integrations] PRIMARY KEY CLUSTERED 
    (
        [IntegrationID] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
     CONSTRAINT [UK_core_Integrations_Code] UNIQUE NONCLUSTERED 
    (
        [IntegrationCode] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
     CONSTRAINT [UK_core_Integrations_Name] UNIQUE NONCLUSTERED 
    (
        [IntegrationName] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
     CONSTRAINT [UK_core_Integrations_Schema] UNIQUE NONCLUSTERED 
    (
        [SchemaName] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

    -- Add defaults
    ALTER TABLE [core].[Integrations] ADD DEFAULT (newid()) FOR [IntegrationCode]
    ALTER TABLE [core].[Integrations] ADD DEFAULT ((0)) FOR [SchemaCreated]
    ALTER TABLE [core].[Integrations] ADD DEFAULT ((1)) FOR [SchemaCreationRequested]
    ALTER TABLE [core].[Integrations] ADD DEFAULT ('1.0.0') FOR [Version]
    ALTER TABLE [core].[Integrations] ADD DEFAULT ((1)) FOR [IsActive]
    ALTER TABLE [core].[Integrations] ADD DEFAULT (suser_sname()) FOR [CreatedBy]
    ALTER TABLE [core].[Integrations] ADD DEFAULT (getdate()) FOR [CreatedDate]
END
GO

-- Create index if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_core_Integrations_Active')
BEGIN
    CREATE NONCLUSTERED INDEX [IX_core_Integrations_Active] ON [core].[Integrations]
    (
        [IsActive] ASC
    )
    INCLUDE([IntegrationName],[SchemaName],[SchemaCreated]) 
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
END
GO

/*##################################*/
/*      Organisations               */
/*##################################*/

IF NOT EXISTS (SELECT * FROM sys.tables WHERE schema_id = SCHEMA_ID('core') AND name = 'Organisations')
BEGIN
    CREATE TABLE [core].[Organisations](
        [OrganisationID] [int] IDENTITY(1,1) NOT NULL,
        [OrganisationCode] [uniqueidentifier] NOT NULL,
        [ParentOrganisationCode] [uniqueidentifier] NULL,
        [OrganisationName] [nvarchar](255) NOT NULL,
        [OrganisationPrefix] [nvarchar](255) NOT NULL,
        [DatabaseName] [nvarchar](128) NULL,
        [DatabaseStatus] [varchar](20) NOT NULL,
        [DatabaseCreationRequested] [bit] NOT NULL,
        [DatabaseCreated] [bit] NOT NULL,
        [IsActive] [bit] NOT NULL,
        [CreatedBy] [nvarchar](100) NOT NULL,
        [CreatedDate] [datetime2](7) NOT NULL,
        [ModifiedBy] [nvarchar](100) NULL,
        [ModifiedDate] [datetime2](7) NULL,
        [DatabaseCreatedDate] [datetime2](7) NULL,
        [Notes] [nvarchar](1000) NULL,
     CONSTRAINT [PK_core_Organisations] PRIMARY KEY CLUSTERED 
    (
        [OrganisationID] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
     CONSTRAINT [UK_core_Organisations_Code] UNIQUE NONCLUSTERED 
    (
        [OrganisationCode] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
     CONSTRAINT [UK_core_Organisations_Database] UNIQUE NONCLUSTERED 
    (
        [DatabaseName] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
    ) ON [PRIMARY]

    -- Add defaults
    ALTER TABLE [core].[Organisations] ADD DEFAULT (newid()) FOR [OrganisationCode]
    ALTER TABLE [core].[Organisations] ADD DEFAULT ('PENDING') FOR [DatabaseStatus]
    ALTER TABLE [core].[Organisations] ADD DEFAULT ((0)) FOR [DatabaseCreationRequested]
    ALTER TABLE [core].[Organisations] ADD DEFAULT ((0)) FOR [DatabaseCreated]
    ALTER TABLE [core].[Organisations] ADD DEFAULT ((1)) FOR [IsActive]
    ALTER TABLE [core].[Organisations] ADD DEFAULT (suser_sname()) FOR [CreatedBy]
    ALTER TABLE [core].[Organisations] ADD DEFAULT (getdate()) FOR [CreatedDate]
END
GO

-- Add check constraint if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE name = 'CK_core_Organisations_Status')
BEGIN
    ALTER TABLE [core].[Organisations] WITH CHECK ADD CONSTRAINT [CK_core_Organisations_Status] 
    CHECK (([DatabaseStatus]='ARCHIVED' OR [DatabaseStatus]='MAINTENANCE' OR [DatabaseStatus]='INACTIVE' OR [DatabaseStatus]='FAILED' OR [DatabaseStatus]='ACTIVE' OR [DatabaseStatus]='CREATING' OR [DatabaseStatus]='PENDING'))
    
    ALTER TABLE [core].[Organisations] CHECK CONSTRAINT [CK_core_Organisations_Status]
END
GO

-- Create indexes if they don't exist
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_core_Organisations_Active')
BEGIN
    CREATE NONCLUSTERED INDEX [IX_core_Organisations_Active] ON [core].[Organisations]
    (
        [IsActive] ASC
    )
    INCLUDE([OrganisationCode],[OrganisationName],[DatabaseName],[DatabaseStatus]) 
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_core_Organisations_CreationPending')
BEGIN
    CREATE NONCLUSTERED INDEX [IX_core_Organisations_CreationPending] ON [core].[Organisations]
    (
        [DatabaseCreationRequested] ASC,
        [DatabaseCreated] ASC
    )
    WHERE ([IsActive]=(1) AND [DatabaseCreated]=(0))
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_core_Organisations_Status')
BEGIN
    CREATE NONCLUSTERED INDEX [IX_core_Organisations_Status] ON [core].[Organisations]
    (
        [DatabaseStatus] ASC
    )
    WHERE ([IsActive]=(1))
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
END
GO

/*######################################################*/
/*      Organisations to Integrations Mapping           */
/*######################################################*/

IF NOT EXISTS (SELECT * FROM sys.tables WHERE schema_id = SCHEMA_ID('core') AND name = 'OrganisationIntegrations')
BEGIN
    CREATE TABLE [core].[OrganisationIntegrations](
        [OrganisationIntegrationID] [int] IDENTITY(1,1) NOT NULL,
        [OrganisationID] [int] NOT NULL,
        [IntegrationID] [int] NOT NULL,
        [ConnectionString] [nvarchar](1000) NULL,
        [APIKey] [nvarchar](500) NULL,
        [Username] [nvarchar](200) NULL,
        [PasswordHash] [nvarchar](500) NULL,
        [BaseURL] [nvarchar](1000) NULL,
        [CustomSettings] [nvarchar](max) NULL,
        [IsEnabled] [bit] NOT NULL,
        [LastSyncDate] [datetime2](7) NULL,
        [SyncStatus] [varchar](20) NOT NULL,
        [Notes] [nvarchar](1000) NULL,
        [CreatedBy] [nvarchar](100) NOT NULL,
        [CreatedDate] [datetime2](7) NOT NULL,
        [ModifiedBy] [nvarchar](100) NULL,
        [ModifiedDate] [datetime2](7) NULL,
     CONSTRAINT [PK_core_OrganisationIntegrations] PRIMARY KEY CLUSTERED 
    (
        [OrganisationIntegrationID] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
     CONSTRAINT [UK_core_OrganisationIntegrations_OrganisationInt] UNIQUE NONCLUSTERED 
    (
        [OrganisationID] ASC,
        [IntegrationID] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

    -- Add defaults
    ALTER TABLE [core].[OrganisationIntegrations] ADD DEFAULT ((1)) FOR [IsEnabled]
    ALTER TABLE [core].[OrganisationIntegrations] ADD DEFAULT ('PENDING') FOR [SyncStatus]
    ALTER TABLE [core].[OrganisationIntegrations] ADD DEFAULT (suser_sname()) FOR [CreatedBy]
    ALTER TABLE [core].[OrganisationIntegrations] ADD DEFAULT (getdate()) FOR [CreatedDate]
END
GO

-- Add foreign key constraints if they don't exist
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_OrganisationIntegrations_Integration')
BEGIN
    ALTER TABLE [core].[OrganisationIntegrations] WITH CHECK ADD CONSTRAINT [FK_OrganisationIntegrations_Integration] 
    FOREIGN KEY([IntegrationID]) REFERENCES [core].[Integrations] ([IntegrationID])
    
    ALTER TABLE [core].[OrganisationIntegrations] CHECK CONSTRAINT [FK_OrganisationIntegrations_Integration]
END
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_OrganisationIntegrations_Organisation')
BEGIN
    ALTER TABLE [core].[OrganisationIntegrations] WITH CHECK ADD CONSTRAINT [FK_OrganisationIntegrations_Organisation] 
    FOREIGN KEY([OrganisationID]) REFERENCES [core].[Organisations] ([OrganisationID])
    
    ALTER TABLE [core].[OrganisationIntegrations] CHECK CONSTRAINT [FK_OrganisationIntegrations_Organisation]
END
GO

-- Add check constraint if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE name = 'CK_core_OrganisationIntegrations_SyncStatus')
BEGIN
    ALTER TABLE [core].[OrganisationIntegrations] WITH CHECK ADD CONSTRAINT [CK_core_OrganisationIntegrations_SyncStatus] 
    CHECK (([SyncStatus]='DISABLED' OR [SyncStatus]='ERROR' OR [SyncStatus]='ACTIVE' OR [SyncStatus]='PENDING'))
    
    ALTER TABLE [core].[OrganisationIntegrations] CHECK CONSTRAINT [CK_core_OrganisationIntegrations_SyncStatus]
END
GO

-- Create indexes if they don't exist
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_core_OrganisationIntegrations_Integration')
BEGIN
    CREATE NONCLUSTERED INDEX [IX_core_OrganisationIntegrations_Integration] ON [core].[OrganisationIntegrations]
    (
        [IntegrationID] ASC
    )
    INCLUDE([OrganisationID],[IsEnabled],[SyncStatus]) 
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_core_OrganisationIntegrations_Organisation')
BEGIN
    CREATE NONCLUSTERED INDEX [IX_core_OrganisationIntegrations_Organisation] ON [core].[OrganisationIntegrations]
    (
        [OrganisationID] ASC
    )
    INCLUDE([IntegrationID],[IsEnabled],[SyncStatus]) 
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_core_OrganisationIntegrations_Status')
BEGIN
    CREATE NONCLUSTERED INDEX [IX_core_OrganisationIntegrations_Status] ON [core].[OrganisationIntegrations]
    (
        [SyncStatus] ASC
    )
    WHERE ([IsEnabled]=(1))
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
END
GO




/*######################################################*/
/*                Presentation Control                  */
/*######################################################*/

IF NOT EXISTS (SELECT * FROM sys.tables WHERE schema_id = SCHEMA_ID('core') AND name = 'PresentationControl')
BEGIN

CREATE TABLE [core].[PresentationControl](
	[id] [uniqueidentifier] NOT NULL DEFAULT newid(),
	[step_name] [varchar](255) NOT NULL,
	[table_name] [varchar](255) NOT NULL,
	[query_sql] [text] NOT NULL,
	[tier] [int] NOT NULL,
	[table_type] [varchar](50) NOT NULL, -- 'Staging', 'Fact', 'Dimension'
	
	-- Column Mapping (JSON structure for flexibility)
	[column_mappings] [nvarchar](max) NULL, -- JSON: [{"query_column":"col1", "table_column":"target_col1", "data_type":"varchar(50)"}]
	
	-- Processing Control
	[exclude] [bit] NULL DEFAULT (0),
	[priority] [int] NULL DEFAULT (100), -- For ordering within tier
	
	-- Error Handling and Retries
	[retry_count] [int] NULL DEFAULT (3),
	[timeout_minutes] [int] NULL DEFAULT (30),
	
	-- Dependencies
	[depends_on_steps] [text] NULL, -- Comma-separated list of step_names
    
	[time_series_entity] [varchar](255) NULL,

	[time_series_target_column] [varchar](255) NULL,
	
	-- Metadata and Documentation
	[description] [text] NULL,
	[created_by] [varchar](255) NULL,
	
	-- Audit Trail
	[created_at] [datetime] NOT NULL DEFAULT getdate(),
	[updated_at] [datetime] NOT NULL DEFAULT getdate(),
	
	CONSTRAINT [PK_PresentationControl] PRIMARY KEY CLUSTERED ([id] ASC),
	CONSTRAINT [UQ_PresentationControl_StepName] UNIQUE ([step_name])
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

-- Add indexes for performance
CREATE INDEX [IX_PresentationControl_Tier_Status] ON [core].[PresentationControl] ([tier], [exclude], [priority])
CREATE INDEX [IX_PresentationControl_CreatedAt] ON [core].[PresentationControl] ([created_at])
END
GO



----


/*######################################################*/
/*                Presentation Tables                   */
/*######################################################*/

IF NOT EXISTS (SELECT * FROM sys.tables WHERE schema_id = SCHEMA_ID('core') AND name = 'PresentationTables')
BEGIN

CREATE TABLE [core].[PresentationTables](
	[id] [uniqueidentifier] NOT NULL DEFAULT newid(),
	[table_name] [varchar](255) NOT NULL,
	[table_type] [varchar](50) NOT NULL, -- 'Fact', 'Dimension'
	[schema_name] [varchar](128) NOT NULL DEFAULT 'dbo',
	
	-- DDL and Structure
	[ddl_script] [nvarchar](max) NOT NULL, -- Full CREATE TABLE statement
	[column_definitions] [nvarchar](max) NOT NULL, -- JSON array of column details
	
	-- Table Metadata
	[description] [text] NULL,
	[business_owner] [varchar](255) NULL,
	[data_source] [varchar](500) NULL, -- Description of where data comes from
	
	-- Version and Status Management
	[version] [int] NOT NULL DEFAULT (1),
	[status] [varchar](50) NOT NULL DEFAULT (1),
	[is_system_generated] [bit] NOT NULL DEFAULT (0), -- True for app-created tables
	
	-- Dependencies and Relationships
	[parent_tables] [varchar](max) NULL, -- Comma-separated list of dependent tables
	[child_tables] [varchar](max) NULL, -- Tables that depend on this one
	
	-- Audit Fields
	[created_by] [varchar](255) NULL,
	[created_at] [datetime] NOT NULL DEFAULT getdate(),
	[updated_by] [varchar](255) NULL,
	[updated_at] [datetime] NOT NULL DEFAULT getdate(),
	
	CONSTRAINT [PK_PresentationTables] PRIMARY KEY CLUSTERED ([id] ASC),
	CONSTRAINT [UQ_PresentationTables_TableName_Version] UNIQUE ([table_name], [version])
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

-- Indexes for performance
--CREATE INDEX [IX_PresentationTables_TableName_Active] ON [core].[PresentationTables] ([table_name], [is_active])
--CREATE INDEX [IX_PresentationTables_TableType_Active] ON [core].[PresentationTables] ([table_type], [is_active])
END
GO


/*######################################################*/
/*                Visualisation Queries                   */
/*######################################################*/


IF NOT EXISTS (SELECT * FROM sys.tables WHERE schema_id = SCHEMA_ID('core') AND name = 'VisualisationQueries')
BEGIN

CREATE TABLE [core].[VisualisationQueries](
	[DataSetName] [nvarchar](100) NOT NULL,
	[VisualizationType] [nvarchar](100) NOT NULL,
	[Version] [int] NOT NULL,
	[Status] [nvarchar](20) NOT NULL,
	[QueryTemplate] [nvarchar](max) NOT NULL,
	[ParameterMappings] [nvarchar](max) NULL,
	[FilterDefinitions] [nvarchar](max) NULL,
	[Description] [nvarchar](500) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[ModifiedBy] [nvarchar](100) NULL,
	[OutputDefinitions] [nvarchar](max) NULL,
	[ExecutionQuery] [nvarchar](max) NULL,
 CONSTRAINT [PK_VisualisationQueries] PRIMARY KEY CLUSTERED 
(
	[DataSetName] ASC,
	[VisualizationType] ASC,
	[Version] ASC,
	[Status] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UK_VisualisationQueries_Live] UNIQUE NONCLUSTERED 
(
	[DataSetName] ASC,
	[VisualizationType] ASC,
	[Status] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

ALTER TABLE [core].[VisualisationQueries] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO

ALTER TABLE [core].[VisualisationQueries] ADD  DEFAULT (getdate()) FOR [ModifiedDate]
GO

ALTER TABLE [core].[VisualisationQueries]  WITH CHECK ADD CHECK  (([Status]='LIVE' OR [Status]='RETIRED' OR [Status]='TEST' OR [Status]='BUILD'))
GO

ALTER TABLE [core].[VisualisationQueries]  WITH CHECK ADD CHECK  (([Status]='LIVE' OR [Status]='RETIRED' OR [Status]='TEST' OR [Status]='BUILD'))
GO






/*##########################################################################*/
/*##########################################################################*/
-------------------------------TRIGGERS---------------------------------------
/*##########################################################################*/
/*##########################################################################*/

/*##################################*/
/*      Organisations               */
/*##################################*/

-- Drop and recreate trigger to ensure consistency
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_CreateOrganisationDatabase')
    DROP TRIGGER [core].[trg_CreateOrganisationDatabase]
GO

CREATE TRIGGER [core].[trg_CreateOrganisationDatabase]
ON [core].[Organisations]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @OrganisationCode uniqueidentifier;
    DECLARE @OrganisationName nvarchar(255);
    DECLARE @OrganisationPrefix nvarchar(255);
    DECLARE @CreateRequested bit;
    DECLARE @OrganisationCodeStr nvarchar(36);
    DECLARE @JobName nvarchar(128);
    DECLARE @Command nvarchar(4000);
    
    -- Process each inserted record that needs database creation
    DECLARE Organisation_cursor CURSOR FOR
    SELECT [OrganisationCode], [OrganisationName], [DatabaseCreationRequested], [OrganisationPrefix]
    FROM inserted
    WHERE [DatabaseCreationRequested] = 1 AND [IsActive] = 1;
    
    OPEN Organisation_cursor;
    FETCH NEXT FROM Organisation_cursor INTO @OrganisationCode, @OrganisationName, @CreateRequested, @OrganisationPrefix;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            SET @OrganisationCodeStr = CONVERT(nvarchar(36), @OrganisationCode);
            SET @JobName = 'CreateOrganisationDB_' + @OrganisationCodeStr;
            SET @Command = 'EXEC [core].[CreateOrganisationDatabase] @OrganisationCode = ''' + @OrganisationCodeStr + ''', @OrganisationPrefix = ''' + @OrganisationPrefix + ''';';
            
            -- Create a SQL Server Agent job to handle database creation
            -- This runs outside the current transaction context
            EXEC msdb.dbo.sp_add_job
                @job_name = @JobName,
                @enabled = 1,
                @delete_level = 3; -- Delete job after completion
            
            EXEC msdb.dbo.sp_add_jobstep
                @job_name = @JobName,
                @step_name = 'CreateDatabase',
                @command = @Command;
            
            EXEC msdb.dbo.sp_add_jobserver
                @job_name = @JobName;
            
            -- Start the job immediately
            EXEC msdb.dbo.sp_start_job
                @job_name = @JobName;
            
            PRINT 'Trigger: Queued database creation job for Organisation: ' + @OrganisationName + ' (Job: ' + @JobName + ')';
            
        END TRY
        BEGIN CATCH
            -- If SQL Agent jobs are not available, log the error but don't fail the insert
            PRINT 'Trigger: Could not create SQL Agent job for ' + @OrganisationName + '. Error: ' + ERROR_MESSAGE();
            PRINT 'Trigger: You can manually create the database using: EXEC [core].[CreateOrganisationDatabase] @OrganisationCode = ''' + CONVERT(nvarchar(36), @OrganisationCode) + ''', @OrganisationPrefix = ''' + @OrganisationPrefix + ''';';
        END CATCH
        
        FETCH NEXT FROM Organisation_cursor INTO @OrganisationCode, @OrganisationName, @CreateRequested, @OrganisationPrefix;
    END
    
    CLOSE Organisation_cursor;
    DEALLOCATE Organisation_cursor;
END;
GO

/*######################################################*/
/*      Organisations to Integrations Mapping           */
/*######################################################*/

-- Drop and recreate trigger to ensure consistency
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_OrganisationIntegrations_AfterInsert')
    DROP TRIGGER [core].[trg_OrganisationIntegrations_AfterInsert]
GO

CREATE OR ALTER TRIGGER [core].[trg_OrganisationIntegrations_AfterInsert]
ON [core].[core].[OrganisationIntegrations]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @OrganisationID INT;
    DECLARE @IntegrationID INT;
    DECLARE @DatabaseName NVARCHAR(255);
    DECLARE @SchemaName NVARCHAR(255);
    DECLARE @ParameterValue NVARCHAR(MAX);
    DECLARE @DynamicSQL NVARCHAR(MAX);
    DECLARE @FullTableName NVARCHAR(500);
    
    -- Cursor for processing multiple inserted rows
    DECLARE insert_cursor CURSOR FOR
    SELECT OrganisationID, IntegrationID
    FROM inserted;
    
    OPEN insert_cursor;
    FETCH NEXT FROM insert_cursor INTO @OrganisationID, @IntegrationID;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            -- Get database name from OrganisationID
            SELECT @DatabaseName = [core].[GetDatabaseFromOrganisationID](@OrganisationID);
            
            -- Get schema name from IntegrationID
            SELECT @SchemaName = [core].[GetSchemaFromIntegrationID](@IntegrationID);
            
            -- Validate that we got valid database and schema names
            IF @DatabaseName IS NOT NULL AND @SchemaName IS NOT NULL
            BEGIN

            EXEC [core].[CreateDatabaseSchemas]  @DatabaseName = @DatabaseName, @SchemaList = @SchemaName; 

                -- Build the full table name for GlobalParameters
                SET @FullTableName = QUOTENAME('core') + '.' + QUOTENAME(@SchemaName) + '.' + QUOTENAME('GlobalParameters');
                
                -- Create temp table to store DDL parameters
                CREATE TABLE #DDLParameters (
                    ID INT IDENTITY(1,1),
                    ParameterValue NVARCHAR(MAX)
                );
                
                -- Get DDL parameters into temp table
                DECLARE @ParameterSQL NVARCHAR(MAX);
                SET @ParameterSQL = N'
                    INSERT INTO #DDLParameters (ParameterValue)
                    SELECT ParameterValue 
                    FROM ' + @FullTableName + N'
                    WHERE Category = ''STAGE_DDL''
                    AND ParameterValue IS NOT NULL
                    AND LEN(LTRIM(RTRIM(ParameterValue))) > 0';
                
                EXEC sp_executesql @ParameterSQL;
                
                -- Create cursor for DDL parameters from temp table
                DECLARE ddl_cursor CURSOR FOR
                    SELECT ParameterValue FROM #DDLParameters;
                
                OPEN ddl_cursor;
                FETCH NEXT FROM ddl_cursor INTO @ParameterValue;
                
                WHILE @@FETCH_STATUS = 0
                BEGIN
                    BEGIN TRY
                        -- Build dynamic SQL to execute in the target database.stage schema
                        SET @DynamicSQL = N'USE ' + QUOTENAME(@DatabaseName) + N'; ' + @ParameterValue;
                        
                        -- Execute the DDL script
                        EXEC sp_executesql @DynamicSQL;
                        
                        -- Log successful execution (optional)
                        PRINT 'Successfully executed DDL for Organisation ID: ' + CAST(@OrganisationID AS NVARCHAR(10)) + 
                              ', Integration ID: ' + CAST(@IntegrationID AS NVARCHAR(10));
                              
                    END TRY
                    BEGIN CATCH
                        -- Log error but continue processing other DDL scripts
                        DECLARE @ErrorMsg NVARCHAR(4000);
                        SET @ErrorMsg = 'Error executing DDL for Organisation ID: ' + CAST(@OrganisationID AS NVARCHAR(10)) + 
                                       ', Integration ID: ' + CAST(@IntegrationID AS NVARCHAR(10)) + 
                                       '. Error: ' + ERROR_MESSAGE();
                        
                        -- You might want to log this to an error table instead of using RAISERROR
                        PRINT @ErrorMsg;
                        
                        -- Optionally, you can insert error details into an audit/error log table
                        -- INSERT INTO [core].[ErrorLog] (ErrorMessage, OrganisationID, IntegrationID, ErrorDate)
                        -- VALUES (@ErrorMsg, @OrganisationID, @IntegrationID, GETDATE());
                    END CATCH
                    
                    FETCH NEXT FROM ddl_cursor INTO @ParameterValue;
                END
                
                CLOSE ddl_cursor;
                DEALLOCATE ddl_cursor;
                
                -- Clean up temp table
                DROP TABLE #DDLParameters;
            END
            ELSE
            BEGIN
                PRINT 'Invalid database or schema name for Organisation ID: ' + CAST(@OrganisationID AS NVARCHAR(10)) + 
                      ', Integration ID: ' + CAST(@IntegrationID AS NVARCHAR(10));
            END
            
        END TRY
        BEGIN CATCH
            -- Handle outer exception
            DECLARE @OuterErrorMsg NVARCHAR(4000);
            SET @OuterErrorMsg = 'Outer error processing Organisation ID: ' + CAST(@OrganisationID AS NVARCHAR(10)) + 
                               ', Integration ID: ' + CAST(@IntegrationID AS NVARCHAR(10)) + 
                               '. Error: ' + ERROR_MESSAGE();
            PRINT @OuterErrorMsg;
            
            -- Clean up cursor if still open
            IF CURSOR_STATUS('local', 'ddl_cursor') >= 0
            BEGIN
                CLOSE ddl_cursor;
                DEALLOCATE ddl_cursor;
            END
            
            -- Clean up temp table if it exists
            IF OBJECT_ID('tempdb..#DDLParameters') IS NOT NULL
                DROP TABLE #DDLParameters;
        END CATCH
        
        FETCH NEXT FROM insert_cursor INTO @OrganisationID, @IntegrationID;
    END
    
    CLOSE insert_cursor;
    DEALLOCATE insert_cursor;
END
GO

/*##################################*/
/*      Integrations                */
/*##################################*/

-- Drop and recreate trigger to ensure consistency
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_CreateIntegrationSchema')
    DROP TRIGGER [core].[trg_CreateIntegrationSchema]
GO

CREATE TRIGGER [core].[trg_CreateIntegrationSchema]
ON [core].[Integrations]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @IntegrationID int;
    DECLARE @IntegrationName nvarchar(100);
    DECLARE @CreateRequested bit;
    DECLARE @JobName nvarchar(128);
    DECLARE @Command nvarchar(4000);
    
    -- Process each inserted record that needs schema creation
    DECLARE integration_cursor CURSOR FOR
    SELECT [IntegrationID], [IntegrationName], [SchemaCreationRequested]
    FROM inserted
    WHERE [SchemaCreationRequested] = 1 AND [IsActive] = 1;
    
    OPEN integration_cursor;
    FETCH NEXT FROM integration_cursor INTO @IntegrationID, @IntegrationName, @CreateRequested;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            SET @JobName = 'CreateIntegrationSchema_' + CAST(@IntegrationID AS nvarchar(10));
            SET @Command = 'EXEC [core].[CreateIntegrationSchema] @IntegrationID = ' + CAST(@IntegrationID AS nvarchar(10)) + ';';
            
            -- Create a SQL Server Agent job to handle schema creation
            EXEC msdb.dbo.sp_add_job
                @job_name = @JobName,
                @enabled = 1,
                @delete_level = 3; -- Delete job after completion
            
            EXEC msdb.dbo.sp_add_jobstep
                @job_name = @JobName,
                @step_name = 'CreateSchema',
                @command = @Command;
            
            EXEC msdb.dbo.sp_add_jobserver
                @job_name = @JobName;
            
            -- Start the job immediately
            EXEC msdb.dbo.sp_start_job
                @job_name = @JobName;
            
            PRINT 'Trigger: Queued schema creation job for integration: ' + @IntegrationName + ' (Job: ' + @JobName + ')';
            
        END TRY
        BEGIN CATCH
            -- If SQL Agent jobs are not available, log the error but don't fail the insert
            PRINT 'Trigger: Could not create SQL Agent job for ' + @IntegrationName + '. Error: ' + ERROR_MESSAGE();
            PRINT 'Trigger: You can manually create the schema using: EXEC [core].[CreateIntegrationSchema] @IntegrationID = ' + CAST(@IntegrationID AS nvarchar(10)) + ';';
        END CATCH
        
        FETCH NEXT FROM integration_cursor INTO @IntegrationID, @IntegrationName, @CreateRequested;
    END
    
    CLOSE integration_cursor;
    DEALLOCATE integration_cursor;
END
GO

/*##################################*/
/*      Data Vault Entities         */
/*##################################*/

-- Drop and recreate trigger to ensure consistency
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_DataVaultEntities_RetireOlderVersions')
    DROP TRIGGER [core].[trg_DataVaultEntities_RetireOlderVersions]
GO

CREATE TRIGGER [core].[trg_DataVaultEntities_RetireOlderVersions]
ON [core].[DataVaultEntities]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Only proceed if RELEASE_STATE was actually updated
    IF UPDATE(RELEASE_STATE)
    BEGIN
        -- Retire older versions when a newer version is set to 'Live'
        UPDATE dve
        SET RELEASE_STATE = 'Retired',
            UPDATED_AT = GETUTCDATE()
        FROM [core].[DataVaultEntities] dve
        INNER JOIN inserted i ON dve.ENTITY_NAME = i.ENTITY_NAME
        WHERE 
            -- Only retire if the inserted row is now 'Live'
            i.RELEASE_STATE = 'Live'
            -- Only retire rows with lower version numbers
            AND dve.VERSION < i.VERSION
            -- Don't retire rows that are already retired
            AND dve.RELEASE_STATE != 'Retired'
            -- Don't update the same row that was just inserted/updated
            AND dve.ID != i.ID;
            
        -- Optional: Log the retirement action
        IF @@ROWCOUNT > 0
        BEGIN
            DECLARE @RetiredCount INT = @@ROWCOUNT;
            DECLARE @Message NVARCHAR(255) = 
                CONCAT('Retired ', @RetiredCount, ' older version(s) due to new Live version(s)');
            
            -- Uncomment the next line if you want to log to SQL Server error log
            -- RAISERROR(@Message, 0, 1) WITH NOWAIT;
        END
    END
END
GO

PRINT 'Core tables, constraints, indexes, and triggers created successfully!'
GO