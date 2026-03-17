USE [core]


SET ANSI_NULLS ON


SET QUOTED_IDENTIFIER ON


/*##################################*/
/*      ActionInferenceRules         */
/*##################################*/

IF NOT EXISTS (SELECT * FROM sys.tables WHERE schema_id = SCHEMA_ID('core') AND name = 'ActionInferenceRules')
BEGIN
    CREATE TABLE [core].[ActionInferenceRules](
		[InferenceRuleID] [int] IDENTITY(1,1) NOT NULL,
		[RuleName] [nvarchar](100) NOT NULL,
		[SuggestionType] [nvarchar](50) NOT NULL,
		[DetectionConditionsJSON] [nvarchar](max) NOT NULL,
		[EffectivenessConditionsJSON] [nvarchar](max) NULL,
		[ConfidenceScore] [int] NULL,
		[TimeWindowDays] [int] NULL,
		[RequiresAllConditions] [bit] NULL,
		[Priority] [int] NULL,
		[IsActive] [bit] NULL,
		[CreatedDate] [datetime] NULL,
		[UpdatedDate] [datetime] NULL,
		[CreatedBy] [nvarchar](100) NULL,
		[Notes] [nvarchar](500) NULL,
	 CONSTRAINT [PK_ActionInferenceRules] PRIMARY KEY CLUSTERED 
	(
		[InferenceRuleID] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
	) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
	

	ALTER TABLE [core].[ActionInferenceRules] ADD  DEFAULT ((1)) FOR [RequiresAllConditions]
	

	ALTER TABLE [core].[ActionInferenceRules] ADD  DEFAULT ((50)) FOR [Priority]
	

	ALTER TABLE [core].[ActionInferenceRules] ADD  DEFAULT ((1)) FOR [IsActive]
	

	ALTER TABLE [core].[ActionInferenceRules] ADD  DEFAULT (getdate()) FOR [CreatedDate]
	

	ALTER TABLE [core].[ActionInferenceRules] ADD  DEFAULT (getdate()) FOR [UpdatedDate]
	
END
GO


/*##################################*/
/*      DescriptionRules         */
/*##################################*/

IF NOT EXISTS (SELECT * FROM sys.tables WHERE schema_id = SCHEMA_ID('core') AND name = 'DescriptionRules')
BEGIN

CREATE TABLE [core].[DescriptionRules](
		[RuleID] [int] IDENTITY(1,1) NOT NULL,
		[RuleName] [nvarchar](100) NOT NULL,
		[Dataset] [nvarchar](100) NOT NULL,
		[Catery] [nvarchar](50) NULL,
		[ConditionsJSON] [nvarchar](max) NOT NULL,
		[DescriptionType] [nvarchar](50) NULL,
		[Priority] [int] NULL,
		[Severity] [nvarchar](20) NULL,
		[ExecutionOrder] [int] NULL,
		[DependsOnRuleID] [int] NULL,
		[PassMetricsToNext] [bit] NULL,
		[ReferencesRuleIDs] [nvarchar](500) NULL,
		[ReferenceCondition] [nvarchar](max) NULL,
		[CalculatesScore] [bit] NULL,
		[ScoreFormulaJSON] [nvarchar](max) NULL,
		[GeneratesSuggestion] [bit] NULL,
		[SuggestionTemplateID] [int] NULL,
		[ThresholdsJSON] [nvarchar](max) NULL,
		[IsActive] [bit] NULL,
		[CreatedDate] [datetime] NULL,
		[UpdatedDate] [datetime] NULL,
		[Notes] [nvarchar](500) NULL,
	 CONSTRAINT [PK_DescriptionRules] PRIMARY KEY CLUSTERED 
	(
		[RuleID] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
	) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
	

	ALTER TABLE [core].[DescriptionRules] ADD  DEFAULT ((50)) FOR [Priority]
	

	ALTER TABLE [core].[DescriptionRules] ADD  DEFAULT ((0)) FOR [PassMetricsToNext]
	

	ALTER TABLE [core].[DescriptionRules] ADD  DEFAULT ((0)) FOR [CalculatesScore]
	

	ALTER TABLE [core].[DescriptionRules] ADD  DEFAULT ((0)) FOR [GeneratesSuggestion]
	

	ALTER TABLE [core].[DescriptionRules] ADD  DEFAULT ((1)) FOR [IsActive]
	

	ALTER TABLE [core].[DescriptionRules] ADD  DEFAULT (getdate()) FOR [CreatedDate]
	

	ALTER TABLE [core].[DescriptionRules] ADD  DEFAULT (getdate()) FOR [UpdatedDate]
	

	ALTER TABLE [core].[DescriptionRules]  WITH CHECK ADD  CONSTRAINT [FK_DescriptionRules_DependsOnRuleID] FOREIGN KEY([DependsOnRuleID])
	REFERENCES [core].[DescriptionRules] ([RuleID])
	

	ALTER TABLE [core].[DescriptionRules] CHECK CONSTRAINT [FK_DescriptionRules_DependsOnRuleID]
	


END
GO


/*##################################*/
/*      DescriptionTemplates         */
/*##################################*/

IF NOT EXISTS (SELECT * FROM sys.tables WHERE schema_id = SCHEMA_ID('core') AND name = 'DescriptionTemplates')
BEGIN

	CREATE TABLE [core].[DescriptionTemplates](
		[TemplateID] [int] IDENTITY(1,1) NOT NULL,
		[TemplateName] [nvarchar](100) NOT NULL,
		[Dataset] [nvarchar](100) NOT NULL,
		[DescriptionType] [nvarchar](50) NOT NULL,
		[TemplateText] [nvarchar](max) NOT NULL,
		[TemplateVariablesJSON] [nvarchar](max) NULL,
		[ConditionsJSON] [nvarchar](max) NULL,
		[Scope] [nvarchar](20) NULL,
		[Priority] [int] NULL,
		[Catery] [nvarchar](50) NULL,
		[Severity] [nvarchar](20) NULL,
		[IsActive] [bit] NULL,
		[IsDefault] [bit] NULL,
		[CreatedDate] [datetime] NULL,
		[UpdatedDate] [datetime] NULL,
		[CreatedBy] [nvarchar](100) NULL,
		[Notes] [nvarchar](500) NULL,
	 CONSTRAINT [PK_DescriptionTemplates] PRIMARY KEY CLUSTERED 
	(
		[TemplateID] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
	) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]


	ALTER TABLE [core].[DescriptionTemplates] ADD  DEFAULT ('Both') FOR [Scope]


	ALTER TABLE [core].[DescriptionTemplates] ADD  DEFAULT ((50)) FOR [Priority]


	ALTER TABLE [core].[DescriptionTemplates] ADD  DEFAULT ((1)) FOR [IsActive]


	ALTER TABLE [core].[DescriptionTemplates] ADD  DEFAULT ((0)) FOR [IsDefault]


	ALTER TABLE [core].[DescriptionTemplates] ADD  DEFAULT (getdate()) FOR [CreatedDate]


	ALTER TABLE [core].[DescriptionTemplates] ADD  DEFAULT (getdate()) FOR [UpdatedDate]


	ALTER TABLE [core].[DescriptionTemplates]  WITH CHECK ADD  CONSTRAINT [CK_DescriptionTemplates_Scope] CHECK  (([Scope]='Both' OR [Scope]='Global' OR [Scope]='Location'))


	ALTER TABLE [core].[DescriptionTemplates] CHECK CONSTRAINT [CK_DescriptionTemplates_Scope]


END
GO

/*##################################*/
/*      MetricDefinitions         */
/*##################################*/

IF NOT EXISTS (SELECT * FROM sys.tables WHERE schema_id = SCHEMA_ID('core') AND name = 'MetricDefinitions')
BEGIN

	CREATE TABLE [core].[MetricDefinitions](
	[MetricID] [int] IDENTITY(1,1) NOT NULL,
	[MetricName] [nvarchar](100) NOT NULL,
	[DisplayName] [nvarchar](200) NULL,
	[Description] [nvarchar](500) NULL,
	[Catery] [nvarchar](50) NULL,
	[SourceType] [nvarchar](50) NULL,
	[SourceSQL] [nvarchar](max) NULL,
	[IsLocationSpecific] [bit] NULL,
	[AggregationType] [nvarchar](50) NULL,
	[RequiresMetrics] [nvarchar](500) NULL,
	[CalculationFormula] [nvarchar](max) NULL,
	[DataType] [nvarchar](20) NULL,
	[UnitOfMeasure] [nvarchar](50) NULL,
	[ExampleValue] [nvarchar](100) NULL,
	[IsActive] [bit] NULL,
	[CreatedDate] [datetime] NULL,
	[UpdatedDate] [datetime] NULL,
	[Notes] [nvarchar](500) NULL,
 CONSTRAINT [PK_MetricDefinitions] PRIMARY KEY CLUSTERED 
(
	[MetricID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_MetricDefinitions_MetricName] UNIQUE NONCLUSTERED 
(
	[MetricName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]


ALTER TABLE [core].[MetricDefinitions] ADD  DEFAULT ((1)) FOR [IsLocationSpecific]


ALTER TABLE [core].[MetricDefinitions] ADD  DEFAULT ((1)) FOR [IsActive]


ALTER TABLE [core].[MetricDefinitions] ADD  DEFAULT (getdate()) FOR [CreatedDate]


ALTER TABLE [core].[MetricDefinitions] ADD  DEFAULT (getdate()) FOR [UpdatedDate]


END
GO