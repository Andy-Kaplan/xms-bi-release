-- ============================================
-- 2_CoreTableCreateScripts.sql
-- Regenerated from UAT 2026-06-02 10:44:53
-- Server: xms-mssqlman-ne-uat.public.9358333fb9bd.database.windows.net
-- ============================================

-- ============================================
-- Table: [core].[DataVaultEntities]
-- ============================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DataVaultEntities]') AND type in (N'U'))
BEGIN
CREATE TABLE [core].[DataVaultEntities](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ENTITY_NAME] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DESCRIPTION] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ATTRIBUTE_NAMES] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ATTRIBUTE_TYPES] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PRIMARY_SOURCE_TYPE] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TIME_SERIES] [bit] NULL,
	[TIME_SERIES_COLUMN] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CREATED_AT] [datetime] NULL,
	[UPDATED_AT] [datetime] NULL,
	[VERSION] [int] NOT NULL,
	[RELEASE_STATE] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SPLIT_MAP] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__DataVault__CREAT__4AB81AF0]') AND type = 'D')
BEGIN
ALTER TABLE [core].[DataVaultEntities] ADD  DEFAULT (getdate()) FOR [CREATED_AT]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__DataVault__UPDAT__4BAC3F29]') AND type = 'D')
BEGIN
ALTER TABLE [core].[DataVaultEntities] ADD  DEFAULT (getdate()) FOR [UPDATED_AT]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__DataVault__VERSI__4CA06362]') AND type = 'D')
BEGIN
ALTER TABLE [core].[DataVaultEntities] ADD  DEFAULT ((1)) FOR [VERSION]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__DataVault__RELEA__4D94879B]') AND type = 'D')
BEGIN
ALTER TABLE [core].[DataVaultEntities] ADD  DEFAULT ('Build') FOR [RELEASE_STATE]
END

GO


-- ============================================
-- Table: [core].[GlobalParameters]
-- ============================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[GlobalParameters]') AND type in (N'U'))
BEGIN
CREATE TABLE [core].[GlobalParameters](
	[ParameterID] [int] IDENTITY(1,1) NOT NULL,
	[ParameterKey] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ParameterValue] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DataType] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Category] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Description] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedBy] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
	[ModifiedBy] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[core].[GlobalParameters]') AND name = N'IX_core_GlobalParameters_Active')
CREATE NONCLUSTERED INDEX [IX_core_GlobalParameters_Active] ON [core].[GlobalParameters]
(
	[IsActive] ASC
)
INCLUDE([ParameterKey],[ParameterValue],[DataType]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[core].[GlobalParameters]') AND name = N'IX_core_GlobalParameters_Category')
CREATE NONCLUSTERED INDEX [IX_core_GlobalParameters_Category] ON [core].[GlobalParameters]
(
	[Category] ASC
)
WHERE ([IsActive]=(1))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__GlobalPar__DataT__5165187F]') AND type = 'D')
BEGIN
ALTER TABLE [core].[GlobalParameters] ADD  DEFAULT ('STRING') FOR [DataType]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__GlobalPar__IsAct__52593CB8]') AND type = 'D')
BEGIN
ALTER TABLE [core].[GlobalParameters] ADD  DEFAULT ((1)) FOR [IsActive]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__GlobalPar__Creat__534D60F1]') AND type = 'D')
BEGIN
ALTER TABLE [core].[GlobalParameters] ADD  DEFAULT (suser_sname()) FOR [CreatedBy]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__GlobalPar__Creat__5441852A]') AND type = 'D')
BEGIN
ALTER TABLE [core].[GlobalParameters] ADD  DEFAULT (getdate()) FOR [CreatedDate]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__GlobalPar__Versi__5535A963]') AND type = 'D')
BEGIN
ALTER TABLE [core].[GlobalParameters] ADD  DEFAULT ((1)) FOR [Version]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[core].[CK_core_GlobalParameters_DataType]') AND parent_object_id = OBJECT_ID(N'[core].[GlobalParameters]'))
ALTER TABLE [core].[GlobalParameters]  WITH CHECK ADD  CONSTRAINT [CK_core_GlobalParameters_DataType] CHECK  (([DataType]='JSON' OR [DataType]='DATETIME' OR [DataType]='DATE' OR [DataType]='BOOLEAN' OR [DataType]='DECIMAL' OR [DataType]='INT' OR [DataType]='STRING'))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[core].[CK_core_GlobalParameters_DataType]') AND parent_object_id = OBJECT_ID(N'[core].[GlobalParameters]'))
ALTER TABLE [core].[GlobalParameters] CHECK CONSTRAINT [CK_core_GlobalParameters_DataType]
GO


-- ============================================
-- Table: [core].[Integrations]
-- ============================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[Integrations]') AND type in (N'U'))
BEGIN
CREATE TABLE [core].[Integrations](
	[IntegrationID] [int] IDENTITY(1,1) NOT NULL,
	[IntegrationCode] [uniqueidentifier] NOT NULL,
	[IntegrationName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[IntegrationDisplayName] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SchemaName] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SchemaCreated] [bit] NOT NULL,
	[SchemaCreationRequested] [bit] NOT NULL,
	[Version] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Description] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedBy] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
	[ModifiedBy] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[SchemaCreatedDate] [datetime2](7) NULL,
	[APIEndpointDetail] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IntegrationType] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[core].[Integrations]') AND name = N'IX_core_Integrations_Active')
CREATE NONCLUSTERED INDEX [IX_core_Integrations_Active] ON [core].[Integrations]
(
	[IsActive] ASC
)
INCLUDE([IntegrationName],[SchemaName],[SchemaCreated]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Integrati__Integ__5BE2A6F2]') AND type = 'D')
BEGIN
ALTER TABLE [core].[Integrations] ADD  DEFAULT (newid()) FOR [IntegrationCode]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Integrati__Schem__5CD6CB2B]') AND type = 'D')
BEGIN
ALTER TABLE [core].[Integrations] ADD  DEFAULT ((0)) FOR [SchemaCreated]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Integrati__Schem__5DCAEF64]') AND type = 'D')
BEGIN
ALTER TABLE [core].[Integrations] ADD  DEFAULT ((1)) FOR [SchemaCreationRequested]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Integrati__Versi__5EBF139D]') AND type = 'D')
BEGIN
ALTER TABLE [core].[Integrations] ADD  DEFAULT ('1.0.0') FOR [Version]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Integrati__IsAct__5FB337D6]') AND type = 'D')
BEGIN
ALTER TABLE [core].[Integrations] ADD  DEFAULT ((1)) FOR [IsActive]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Integrati__Creat__60A75C0F]') AND type = 'D')
BEGIN
ALTER TABLE [core].[Integrations] ADD  DEFAULT (suser_sname()) FOR [CreatedBy]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Integrati__Creat__619B8048]') AND type = 'D')
BEGIN
ALTER TABLE [core].[Integrations] ADD  DEFAULT (getdate()) FOR [CreatedDate]
END

GO


-- ============================================
-- Table: [core].[OrganisationIntegrations]
-- ============================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[OrganisationIntegrations]') AND type in (N'U'))
BEGIN
CREATE TABLE [core].[OrganisationIntegrations](
	[OrganisationIntegrationID] [int] IDENTITY(1,1) NOT NULL,
	[OrganisationID] [int] NOT NULL,
	[IntegrationID] [int] NOT NULL,
	[ConnectionString] [nvarchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[APIKey] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Username] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PasswordHash] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BaseURL] [nvarchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CustomSettings] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsEnabled] [bit] NOT NULL,
	[LastSyncDate] [datetime2](7) NULL,
	[SyncStatus] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Notes] [nvarchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedBy] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
	[ModifiedBy] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[core].[OrganisationIntegrations]') AND name = N'IX_core_OrganisationIntegrations_Integration')
CREATE NONCLUSTERED INDEX [IX_core_OrganisationIntegrations_Integration] ON [core].[OrganisationIntegrations]
(
	[IntegrationID] ASC
)
INCLUDE([OrganisationID],[IsEnabled],[SyncStatus]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[core].[OrganisationIntegrations]') AND name = N'IX_core_OrganisationIntegrations_Organisation')
CREATE NONCLUSTERED INDEX [IX_core_OrganisationIntegrations_Organisation] ON [core].[OrganisationIntegrations]
(
	[OrganisationID] ASC
)
INCLUDE([IntegrationID],[IsEnabled],[SyncStatus]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[core].[OrganisationIntegrations]') AND name = N'IX_core_OrganisationIntegrations_Status')
CREATE NONCLUSTERED INDEX [IX_core_OrganisationIntegrations_Status] ON [core].[OrganisationIntegrations]
(
	[SyncStatus] ASC
)
WHERE ([IsEnabled]=(1))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Organisat__IsEna__70DDC3D8]') AND type = 'D')
BEGIN
ALTER TABLE [core].[OrganisationIntegrations] ADD  DEFAULT ((1)) FOR [IsEnabled]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Organisat__SyncS__71D1E811]') AND type = 'D')
BEGIN
ALTER TABLE [core].[OrganisationIntegrations] ADD  DEFAULT ('PENDING') FOR [SyncStatus]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Organisat__Creat__72C60C4A]') AND type = 'D')
BEGIN
ALTER TABLE [core].[OrganisationIntegrations] ADD  DEFAULT (suser_sname()) FOR [CreatedBy]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Organisat__Creat__73BA3083]') AND type = 'D')
BEGIN
ALTER TABLE [core].[OrganisationIntegrations] ADD  DEFAULT (getdate()) FOR [CreatedDate]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[core].[CK_core_OrganisationIntegrations_SyncStatus]') AND parent_object_id = OBJECT_ID(N'[core].[OrganisationIntegrations]'))
ALTER TABLE [core].[OrganisationIntegrations]  WITH CHECK ADD  CONSTRAINT [CK_core_OrganisationIntegrations_SyncStatus] CHECK  (([SyncStatus]='DISABLED' OR [SyncStatus]='ERROR' OR [SyncStatus]='ACTIVE' OR [SyncStatus]='PENDING'))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[core].[CK_core_OrganisationIntegrations_SyncStatus]') AND parent_object_id = OBJECT_ID(N'[core].[OrganisationIntegrations]'))
ALTER TABLE [core].[OrganisationIntegrations] CHECK CONSTRAINT [CK_core_OrganisationIntegrations_SyncStatus]
GO


-- ============================================
-- Table: [core].[Organisations]
-- ============================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[Organisations]') AND type in (N'U'))
BEGIN
CREATE TABLE [core].[Organisations](
	[OrganisationID] [int] IDENTITY(1,1) NOT NULL,
	[OrganisationCode] [uniqueidentifier] NOT NULL,
	[OrganisationName] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[OrganisationPrefix] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DatabaseName] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DatabaseStatus] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DatabaseCreationRequested] [bit] NOT NULL,
	[DatabaseCreated] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedBy] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
	[ModifiedBy] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[DatabaseCreatedDate] [datetime2](7) NULL,
	[Notes] [nvarchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ParentOrganisationCode] [uniqueidentifier] NULL,
	[QuorumPercentage] [decimal](5, 2) NOT NULL,
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
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[core].[Organisations]') AND name = N'IX_core_Organisations_Active')
CREATE NONCLUSTERED INDEX [IX_core_Organisations_Active] ON [core].[Organisations]
(
	[IsActive] ASC
)
INCLUDE([OrganisationCode],[OrganisationName],[DatabaseName],[DatabaseStatus]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[core].[Organisations]') AND name = N'IX_core_Organisations_CreationPending')
CREATE NONCLUSTERED INDEX [IX_core_Organisations_CreationPending] ON [core].[Organisations]
(
	[DatabaseCreationRequested] ASC,
	[DatabaseCreated] ASC
)
WHERE ([IsActive]=(1) AND [DatabaseCreated]=(0))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[core].[Organisations]') AND name = N'IX_core_Organisations_Status')
CREATE NONCLUSTERED INDEX [IX_core_Organisations_Status] ON [core].[Organisations]
(
	[DatabaseStatus] ASC
)
WHERE ([IsActive]=(1))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Organisat__Organ__66603565]') AND type = 'D')
BEGIN
ALTER TABLE [core].[Organisations] ADD  DEFAULT (newid()) FOR [OrganisationCode]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Organisat__Datab__6754599E]') AND type = 'D')
BEGIN
ALTER TABLE [core].[Organisations] ADD  DEFAULT ('PENDING') FOR [DatabaseStatus]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Organisat__Datab__68487DD7]') AND type = 'D')
BEGIN
ALTER TABLE [core].[Organisations] ADD  DEFAULT ((0)) FOR [DatabaseCreationRequested]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Organisat__Datab__693CA210]') AND type = 'D')
BEGIN
ALTER TABLE [core].[Organisations] ADD  DEFAULT ((0)) FOR [DatabaseCreated]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Organisat__IsAct__6A30C649]') AND type = 'D')
BEGIN
ALTER TABLE [core].[Organisations] ADD  DEFAULT ((1)) FOR [IsActive]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Organisat__Creat__6B24EA82]') AND type = 'D')
BEGIN
ALTER TABLE [core].[Organisations] ADD  DEFAULT (suser_sname()) FOR [CreatedBy]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Organisat__Creat__6C190EBB]') AND type = 'D')
BEGIN
ALTER TABLE [core].[Organisations] ADD  DEFAULT (getdate()) FOR [CreatedDate]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF_core_Organisations_QuorumPercentage]') AND type = 'D')
BEGIN
ALTER TABLE [core].[Organisations] ADD  CONSTRAINT [DF_core_Organisations_QuorumPercentage]  DEFAULT ((100.00)) FOR [QuorumPercentage]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[core].[CK_core_Organisations_Status]') AND parent_object_id = OBJECT_ID(N'[core].[Organisations]'))
ALTER TABLE [core].[Organisations]  WITH CHECK ADD  CONSTRAINT [CK_core_Organisations_Status] CHECK  (([DatabaseStatus]='ARCHIVED' OR [DatabaseStatus]='MAINTENANCE' OR [DatabaseStatus]='INACTIVE' OR [DatabaseStatus]='FAILED' OR [DatabaseStatus]='ACTIVE' OR [DatabaseStatus]='CREATING' OR [DatabaseStatus]='PENDING'))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[core].[CK_core_Organisations_Status]') AND parent_object_id = OBJECT_ID(N'[core].[Organisations]'))
ALTER TABLE [core].[Organisations] CHECK CONSTRAINT [CK_core_Organisations_Status]
GO


-- ============================================
-- Table: [core].[ParentBuildStatus]
-- ============================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[ParentBuildStatus]') AND type in (N'U'))
BEGIN
CREATE TABLE [core].[ParentBuildStatus](
	[ParentOrganisationCode] [uniqueidentifier] NOT NULL,
	[ChildOrganisationCode] [uniqueidentifier] NOT NULL,
	[LastCompletedDate] [date] NOT NULL,
	[CompletedAt] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_core_ParentBuildStatus] PRIMARY KEY CLUSTERED 
(
	[ParentOrganisationCode] ASC,
	[ChildOrganisationCode] ASC,
	[LastCompletedDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[core].[ParentBuildStatus]') AND name = N'IX_core_ParentBuildStatus_ParentDate')
CREATE NONCLUSTERED INDEX [IX_core_ParentBuildStatus_ParentDate] ON [core].[ParentBuildStatus]
(
	[ParentOrganisationCode] ASC,
	[LastCompletedDate] ASC
)
INCLUDE([ChildOrganisationCode],[CompletedAt]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO


-- ============================================
-- Table: [core].[PresentationControl]
-- ============================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[PresentationControl]') AND type in (N'U'))
BEGIN
CREATE TABLE [core].[PresentationControl](
	[id] [uniqueidentifier] NOT NULL,
	[step_name] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[table_name] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[query_sql] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[tier] [int] NOT NULL,
	[table_type] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[column_mappings] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[exclude] [bit] NULL,
	[priority] [int] NULL,
	[retry_count] [int] NULL,
	[timeout_minutes] [int] NULL,
	[depends_on_steps] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[time_series_entity] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[time_series_target_column] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[description] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_by] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_at] [datetime] NOT NULL,
	[updated_at] [datetime] NOT NULL,
 CONSTRAINT [PK_PresentationControl] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_PresentationControl_StepName] UNIQUE NONCLUSTERED 
(
	[step_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[core].[PresentationControl]') AND name = N'IX_PresentationControl_CreatedAt')
CREATE NONCLUSTERED INDEX [IX_PresentationControl_CreatedAt] ON [core].[PresentationControl]
(
	[created_at] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[core].[PresentationControl]') AND name = N'IX_PresentationControl_Tier_Status')
CREATE NONCLUSTERED INDEX [IX_PresentationControl_Tier_Status] ON [core].[PresentationControl]
(
	[tier] ASC,
	[exclude] ASC,
	[priority] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Presentation__id__7A672E12]') AND type = 'D')
BEGIN
ALTER TABLE [core].[PresentationControl] ADD  DEFAULT (newid()) FOR [id]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Presentat__exclu__7B5B524B]') AND type = 'D')
BEGIN
ALTER TABLE [core].[PresentationControl] ADD  DEFAULT ((0)) FOR [exclude]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Presentat__prior__7C4F7684]') AND type = 'D')
BEGIN
ALTER TABLE [core].[PresentationControl] ADD  DEFAULT ((100)) FOR [priority]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Presentat__retry__7D439ABD]') AND type = 'D')
BEGIN
ALTER TABLE [core].[PresentationControl] ADD  DEFAULT ((3)) FOR [retry_count]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Presentat__timeo__7E37BEF6]') AND type = 'D')
BEGIN
ALTER TABLE [core].[PresentationControl] ADD  DEFAULT ((30)) FOR [timeout_minutes]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Presentat__creat__7F2BE32F]') AND type = 'D')
BEGIN
ALTER TABLE [core].[PresentationControl] ADD  DEFAULT (getdate()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Presentat__updat__00200768]') AND type = 'D')
BEGIN
ALTER TABLE [core].[PresentationControl] ADD  DEFAULT (getdate()) FOR [updated_at]
END

GO


-- ============================================
-- Table: [core].[PresentationTables]
-- ============================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[PresentationTables]') AND type in (N'U'))
BEGIN
CREATE TABLE [core].[PresentationTables](
	[id] [uniqueidentifier] NOT NULL,
	[table_name] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[table_type] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[schema_name] [varchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ddl_script] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[column_definitions] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[description] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[business_owner] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[data_source] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[version] [int] NOT NULL,
	[status] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[is_system_generated] [bit] NOT NULL,
	[parent_tables] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[child_tables] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_by] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_at] [datetime] NOT NULL,
	[updated_by] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[updated_at] [datetime] NOT NULL,
 CONSTRAINT [PK_PresentationTables] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_PresentationTables_TableName_Version] UNIQUE NONCLUSTERED 
(
	[table_name] ASC,
	[version] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Presentation__id__03F0984C]') AND type = 'D')
BEGIN
ALTER TABLE [core].[PresentationTables] ADD  DEFAULT (newid()) FOR [id]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Presentat__schem__04E4BC85]') AND type = 'D')
BEGIN
ALTER TABLE [core].[PresentationTables] ADD  DEFAULT ('dbo') FOR [schema_name]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Presentat__versi__05D8E0BE]') AND type = 'D')
BEGIN
ALTER TABLE [core].[PresentationTables] ADD  DEFAULT ((1)) FOR [version]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Presentat__statu__06CD04F7]') AND type = 'D')
BEGIN
ALTER TABLE [core].[PresentationTables] ADD  DEFAULT ((1)) FOR [status]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Presentat__is_sy__07C12930]') AND type = 'D')
BEGIN
ALTER TABLE [core].[PresentationTables] ADD  DEFAULT ((0)) FOR [is_system_generated]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Presentat__creat__08B54D69]') AND type = 'D')
BEGIN
ALTER TABLE [core].[PresentationTables] ADD  DEFAULT (getdate()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Presentat__updat__09A971A2]') AND type = 'D')
BEGIN
ALTER TABLE [core].[PresentationTables] ADD  DEFAULT (getdate()) FOR [updated_at]
END

GO


-- ============================================
-- Table: [core].[SuggestionTemplates]
-- ============================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[SuggestionTemplates]') AND type in (N'U'))
BEGIN
CREATE TABLE [core].[SuggestionTemplates](
	[TemplateID] [int] IDENTITY(1,1) NOT NULL,
	[TemplateName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Category] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Severity] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[OutputType] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TemplateText] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SortOrder] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedDate] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[TemplateID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_SuggestionTemplates_Name] UNIQUE NONCLUSTERED 
(
	[TemplateName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Suggestio__Sever__0EF836A4]') AND type = 'D')
BEGIN
ALTER TABLE [core].[SuggestionTemplates] ADD  DEFAULT ('INFO') FOR [Severity]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Suggestio__SortO__0FEC5ADD]') AND type = 'D')
BEGIN
ALTER TABLE [core].[SuggestionTemplates] ADD  DEFAULT ((50)) FOR [SortOrder]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Suggestio__IsAct__10E07F16]') AND type = 'D')
BEGIN
ALTER TABLE [core].[SuggestionTemplates] ADD  DEFAULT ((1)) FOR [IsActive]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Suggestio__Creat__11D4A34F]') AND type = 'D')
BEGIN
ALTER TABLE [core].[SuggestionTemplates] ADD  DEFAULT (getdate()) FOR [CreatedDate]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Suggestio__Modif__12C8C788]') AND type = 'D')
BEGIN
ALTER TABLE [core].[SuggestionTemplates] ADD  DEFAULT (getdate()) FOR [ModifiedDate]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[core].[CK_SuggestionTemplates_OutputType]') AND parent_object_id = OBJECT_ID(N'[core].[SuggestionTemplates]'))
ALTER TABLE [core].[SuggestionTemplates]  WITH CHECK ADD  CONSTRAINT [CK_SuggestionTemplates_OutputType] CHECK  (([OutputType]='Section' OR [OutputType]='Banner'))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[core].[CK_SuggestionTemplates_OutputType]') AND parent_object_id = OBJECT_ID(N'[core].[SuggestionTemplates]'))
ALTER TABLE [core].[SuggestionTemplates] CHECK CONSTRAINT [CK_SuggestionTemplates_OutputType]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[core].[CK_SuggestionTemplates_Severity]') AND parent_object_id = OBJECT_ID(N'[core].[SuggestionTemplates]'))
ALTER TABLE [core].[SuggestionTemplates]  WITH CHECK ADD  CONSTRAINT [CK_SuggestionTemplates_Severity] CHECK  (([Severity]='ERROR' OR [Severity]='WARNING' OR [Severity]='INFO'))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[core].[CK_SuggestionTemplates_Severity]') AND parent_object_id = OBJECT_ID(N'[core].[SuggestionTemplates]'))
ALTER TABLE [core].[SuggestionTemplates] CHECK CONSTRAINT [CK_SuggestionTemplates_Severity]
GO


-- ============================================
-- Table: [core].[VisualisationQueries]
-- ============================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[VisualisationQueries]') AND type in (N'U'))
BEGIN
CREATE TABLE [core].[VisualisationQueries](
	[DataSetName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[VisualizationType] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Version] [int] NOT NULL,
	[Status] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[QueryTemplate] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ParameterMappings] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FilterDefinitions] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Description] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[CreatedBy] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ModifiedBy] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OutputDefinitions] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ExecutionQuery] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Visualisa__Creat__5E8A0973]') AND type = 'D')
BEGIN
ALTER TABLE [core].[VisualisationQueries] ADD  DEFAULT (getdate()) FOR [CreatedDate]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Visualisa__Modif__5F7E2DAC]') AND type = 'D')
BEGIN
ALTER TABLE [core].[VisualisationQueries] ADD  DEFAULT (getdate()) FOR [ModifiedDate]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[core].[CK__Visualisa__Statu__607251E5]') AND parent_object_id = OBJECT_ID(N'[core].[VisualisationQueries]'))
ALTER TABLE [core].[VisualisationQueries]  WITH CHECK ADD CHECK  (([Status]='LIVE' OR [Status]='RETIRED' OR [Status]='TEST' OR [Status]='BUILD'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[core].[CK__Visualisa__Statu__6166761E]') AND parent_object_id = OBJECT_ID(N'[core].[VisualisationQueries]'))
ALTER TABLE [core].[VisualisationQueries]  WITH CHECK ADD CHECK  (([Status]='LIVE' OR [Status]='RETIRED' OR [Status]='TEST' OR [Status]='BUILD'))
GO


-- ============================================
-- SQL_TRIGGER : [core].[trg_CreateIntegrationSchema]
-- ============================================
CREATE OR ALTER TRIGGER [core].[trg_CreateIntegrationSchema]
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


-- ============================================
-- SQL_TRIGGER : [core].[trg_CreateOrganisationDatabase]
-- ============================================
CREATE OR ALTER TRIGGER [core].[trg_CreateOrganisationDatabase]
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


-- ============================================
-- SQL_TRIGGER : [core].[trg_DataVaultEntities_RetireOlderVersions]
-- ============================================
CREATE OR ALTER TRIGGER [core].[trg_DataVaultEntities_RetireOlderVersions]
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


