-- ============================================
-- 7_Dynamic Suggestion Tables.sql
-- Regenerated from UAT 2026-07-06 15:17:16
-- Server: xms-mssqlman-ne-uat.public.9358333fb9bd.database.windows.net
-- ============================================

-- ============================================
-- Table: [core].[ActionInferenceRules]
-- ============================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[ActionInferenceRules]') AND type in (N'U'))
BEGIN
CREATE TABLE [core].[ActionInferenceRules](
	[InferenceRuleID] [int] IDENTITY(1,1) NOT NULL,
	[RuleName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SuggestionType] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DetectionConditionsJSON] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[EffectivenessConditionsJSON] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ConfidenceScore] [int] NULL,
	[TimeWindowDays] [int] NULL,
	[RequiresAllConditions] [bit] NULL,
	[Priority] [int] NULL,
	[IsActive] [bit] NULL,
	[CreatedDate] [datetime] NULL,
	[UpdatedDate] [datetime] NULL,
	[CreatedBy] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Notes] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_ActionInferenceRules] PRIMARY KEY CLUSTERED 
(
	[InferenceRuleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__ActionInf__Requi__0880433F]') AND type = 'D')
BEGIN
ALTER TABLE [core].[ActionInferenceRules] ADD  DEFAULT ((1)) FOR [RequiresAllConditions]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__ActionInf__Prior__09746778]') AND type = 'D')
BEGIN
ALTER TABLE [core].[ActionInferenceRules] ADD  DEFAULT ((50)) FOR [Priority]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__ActionInf__IsAct__0A688BB1]') AND type = 'D')
BEGIN
ALTER TABLE [core].[ActionInferenceRules] ADD  DEFAULT ((1)) FOR [IsActive]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__ActionInf__Creat__0B5CAFEA]') AND type = 'D')
BEGIN
ALTER TABLE [core].[ActionInferenceRules] ADD  DEFAULT (getdate()) FOR [CreatedDate]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__ActionInf__Updat__0C50D423]') AND type = 'D')
BEGIN
ALTER TABLE [core].[ActionInferenceRules] ADD  DEFAULT (getdate()) FOR [UpdatedDate]
END

GO


-- ============================================
-- Table: [core].[DescriptionRules]
-- ============================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DescriptionRules]') AND type in (N'U'))
BEGIN
CREATE TABLE [core].[DescriptionRules](
	[RuleID] [int] IDENTITY(1,1) NOT NULL,
	[RuleName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Dataset] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Catery] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ConditionsJSON] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DescriptionType] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Priority] [int] NULL,
	[Severity] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ExecutionOrder] [int] NULL,
	[DependsOnRuleID] [int] NULL,
	[PassMetricsToNext] [bit] NULL,
	[ReferencesRuleIDs] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ReferenceCondition] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CalculatesScore] [bit] NULL,
	[ScoreFormulaJSON] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[GeneratesSuggestion] [bit] NULL,
	[SuggestionTemplateID] [int] NULL,
	[ThresholdsJSON] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsActive] [bit] NULL,
	[CreatedDate] [datetime] NULL,
	[UpdatedDate] [datetime] NULL,
	[Notes] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_DescriptionRules] PRIMARY KEY CLUSTERED 
(
	[RuleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Descripti__Prior__0F2D40CE]') AND type = 'D')
BEGIN
ALTER TABLE [core].[DescriptionRules] ADD  DEFAULT ((50)) FOR [Priority]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Descripti__PassM__10216507]') AND type = 'D')
BEGIN
ALTER TABLE [core].[DescriptionRules] ADD  DEFAULT ((0)) FOR [PassMetricsToNext]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Descripti__Calcu__11158940]') AND type = 'D')
BEGIN
ALTER TABLE [core].[DescriptionRules] ADD  DEFAULT ((0)) FOR [CalculatesScore]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Descripti__Gener__1209AD79]') AND type = 'D')
BEGIN
ALTER TABLE [core].[DescriptionRules] ADD  DEFAULT ((0)) FOR [GeneratesSuggestion]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Descripti__IsAct__12FDD1B2]') AND type = 'D')
BEGIN
ALTER TABLE [core].[DescriptionRules] ADD  DEFAULT ((1)) FOR [IsActive]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Descripti__Creat__13F1F5EB]') AND type = 'D')
BEGIN
ALTER TABLE [core].[DescriptionRules] ADD  DEFAULT (getdate()) FOR [CreatedDate]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Descripti__Updat__14E61A24]') AND type = 'D')
BEGIN
ALTER TABLE [core].[DescriptionRules] ADD  DEFAULT (getdate()) FOR [UpdatedDate]
END

GO


-- ============================================
-- Table: [core].[DescriptionTemplates]
-- ============================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DescriptionTemplates]') AND type in (N'U'))
BEGIN
CREATE TABLE [core].[DescriptionTemplates](
	[TemplateID] [int] IDENTITY(1,1) NOT NULL,
	[TemplateName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Dataset] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DescriptionType] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TemplateText] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TemplateVariablesJSON] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ConditionsJSON] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Scope] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Priority] [int] NULL,
	[Catery] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Severity] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsActive] [bit] NULL,
	[IsDefault] [bit] NULL,
	[CreatedDate] [datetime] NULL,
	[UpdatedDate] [datetime] NULL,
	[CreatedBy] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Notes] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_DescriptionTemplates] PRIMARY KEY CLUSTERED 
(
	[TemplateID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Descripti__Scope__18B6AB08]') AND type = 'D')
BEGIN
ALTER TABLE [core].[DescriptionTemplates] ADD  DEFAULT ('Both') FOR [Scope]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Descripti__Prior__19AACF41]') AND type = 'D')
BEGIN
ALTER TABLE [core].[DescriptionTemplates] ADD  DEFAULT ((50)) FOR [Priority]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Descripti__IsAct__1A9EF37A]') AND type = 'D')
BEGIN
ALTER TABLE [core].[DescriptionTemplates] ADD  DEFAULT ((1)) FOR [IsActive]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Descripti__IsDef__1B9317B3]') AND type = 'D')
BEGIN
ALTER TABLE [core].[DescriptionTemplates] ADD  DEFAULT ((0)) FOR [IsDefault]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Descripti__Creat__1C873BEC]') AND type = 'D')
BEGIN
ALTER TABLE [core].[DescriptionTemplates] ADD  DEFAULT (getdate()) FOR [CreatedDate]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Descripti__Updat__1D7B6025]') AND type = 'D')
BEGIN
ALTER TABLE [core].[DescriptionTemplates] ADD  DEFAULT (getdate()) FOR [UpdatedDate]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[core].[CK_DescriptionTemplates_Scope]') AND parent_object_id = OBJECT_ID(N'[core].[DescriptionTemplates]'))
ALTER TABLE [core].[DescriptionTemplates]  WITH CHECK ADD  CONSTRAINT [CK_DescriptionTemplates_Scope] CHECK  (([Scope]='Both' OR [Scope]='Global' OR [Scope]='Location'))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[core].[CK_DescriptionTemplates_Scope]') AND parent_object_id = OBJECT_ID(N'[core].[DescriptionTemplates]'))
ALTER TABLE [core].[DescriptionTemplates] CHECK CONSTRAINT [CK_DescriptionTemplates_Scope]
GO


-- ============================================
-- Table: [core].[MetricDefinitions]
-- ============================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[MetricDefinitions]') AND type in (N'U'))
BEGIN
CREATE TABLE [core].[MetricDefinitions](
	[MetricID] [int] IDENTITY(1,1) NOT NULL,
	[MetricName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DisplayName] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Description] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Catery] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SourceType] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SourceSQL] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsLocationSpecific] [bit] NULL,
	[AggregationType] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RequiresMetrics] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CalculationFormula] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DataType] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UnitOfMeasure] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ExampleValue] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsActive] [bit] NULL,
	[CreatedDate] [datetime] NULL,
	[UpdatedDate] [datetime] NULL,
	[Notes] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_MetricDefinitions] PRIMARY KEY CLUSTERED 
(
	[MetricID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_MetricDefinitions_MetricName] UNIQUE NONCLUSTERED 
(
	[MetricName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__MetricDef__IsLoc__22401542]') AND type = 'D')
BEGIN
ALTER TABLE [core].[MetricDefinitions] ADD  DEFAULT ((1)) FOR [IsLocationSpecific]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__MetricDef__IsAct__2334397B]') AND type = 'D')
BEGIN
ALTER TABLE [core].[MetricDefinitions] ADD  DEFAULT ((1)) FOR [IsActive]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__MetricDef__Creat__24285DB4]') AND type = 'D')
BEGIN
ALTER TABLE [core].[MetricDefinitions] ADD  DEFAULT (getdate()) FOR [CreatedDate]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__MetricDef__Updat__251C81ED]') AND type = 'D')
BEGIN
ALTER TABLE [core].[MetricDefinitions] ADD  DEFAULT (getdate()) FOR [UpdatedDate]
END

GO


