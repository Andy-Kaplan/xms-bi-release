-- ==============================================
-- Parent Organisation Reporting: Core Schema Changes
-- Date: 2026-03-09
-- ==============================================

-- 1. Add QuorumPercentage column to Organisations
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('[core].[Organisations]') AND name = 'QuorumPercentage')
BEGIN
    ALTER TABLE [core].[Organisations] ADD [QuorumPercentage] [decimal](5, 2) NOT NULL CONSTRAINT [DF_core_Organisations_QuorumPercentage] DEFAULT (100.00);
    PRINT 'Added QuorumPercentage column to Organisations table.';
END
ELSE
    PRINT 'QuorumPercentage column already exists.';
GO

-- 2. Create ParentBuildStatus table
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
        ) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
    ) ON [PRIMARY];
    PRINT 'Created ParentBuildStatus table.';
END;
GO

-- 3. Index for querying by parent + date
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_core_ParentBuildStatus_ParentDate')
CREATE NONCLUSTERED INDEX [IX_core_ParentBuildStatus_ParentDate]
ON [core].[ParentBuildStatus] ([ParentOrganisationCode], [LastCompletedDate])
INCLUDE ([ChildOrganisationCode], [CompletedAt])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];
GO
