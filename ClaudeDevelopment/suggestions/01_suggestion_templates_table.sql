-- =====================================================
-- SuggestionTemplates: Configurable text templates
-- for suggestion banners and analysis cards.
-- Templates store text with {placeholder} tokens that
-- VisualisationQuery SQL replaces with computed values.
-- =====================================================

IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'core' AND TABLE_NAME = 'SuggestionTemplates'
)
BEGIN
    CREATE TABLE [core].[SuggestionTemplates] (
        TemplateID      INT IDENTITY(1,1) PRIMARY KEY,
        TemplateName    NVARCHAR(100)  NOT NULL,
        Category        NVARCHAR(50)   NOT NULL,
        Severity        NVARCHAR(20)   NOT NULL DEFAULT 'INFO',
        OutputType      NVARCHAR(20)   NOT NULL,
        TemplateText    NVARCHAR(MAX)  NOT NULL,
        SortOrder       INT            NOT NULL DEFAULT 50,
        IsActive        BIT            NOT NULL DEFAULT 1,
        CreatedDate     DATETIME2      DEFAULT GETDATE(),
        ModifiedDate    DATETIME2      DEFAULT GETDATE(),

        CONSTRAINT UQ_SuggestionTemplates_Name
            UNIQUE (TemplateName),

        CONSTRAINT CK_SuggestionTemplates_Severity
            CHECK (Severity IN ('INFO', 'WARNING', 'ERROR')),

        CONSTRAINT CK_SuggestionTemplates_OutputType
            CHECK (OutputType IN ('Banner', 'Section'))
    );
END;
