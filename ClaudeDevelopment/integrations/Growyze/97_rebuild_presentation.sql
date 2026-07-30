/* ============================================================================
   Presentation rebuild with an explicit load window (Growyze Plan 1, O5)
   Run against the target ORGANISATION database (two-part names throughout).
   Companion to 95_deploy_plan1.ps1, which executes this per org after
   sp_DataVaultLoad.

   WHY THIS SCRIPT EXISTS
   ----------------------
   Plan 1 says "staging -> DV load -> presentation rebuild" as if that were one
   action. It is not, and the gap silently swallows two of its tasks:

   1. sp_DataVaultLoad does NOT rebuild the presentation layer. It never
      references PresentationControl; core.sp_ProcessPresentation is a separate
      procedure that must be called explicitly.

   2. sp_ProcessPresentation treats the two table types very differently
      (see core.sp_ExecuteQuery):
        - Dimension : TRUNCATE + full rebuild, unconditional, no date window.
        - Fact      : the step's own SQL filters
                      `ORDER_DATE BETWEEN @StartDate AND @EndDate`, read from
                      THIS database's [core].[GlobalParameters] keys
                      LINEITEM_START / LINEITEM_END (and STOCKEVENT_* for the
                      inventory facts). Those keys sit at NULL between loads -
                      the documented resting state - so `BETWEEN NULL AND NULL`
                      returns no rows, and the fact is left entirely untouched.

   Consequences for Plan 1:
     - Task 1 (category sentinel) lands on D_PRODUCT, a Dimension => a plain
       rebuild is enough, no window needed.
     - Task 6 (LINEITEM_TIMESTAMP) and Task 7 (F_PURCHASES_DAY) land on Facts
       => without a window they achieve NOTHING VISIBLE, however many times the
       load is re-run. Hence the widening below.

   SAFETY: an empty fact result is a true no-op, not a wipe - sp_ExecuteQuery
   guards its DELETE with `IF @MinDate IS NOT NULL AND @MaxDate IS NOT NULL`.
   The DELETE is NOT source-scoped, but neither is the rebuild SELECT, so a
   window rebuilds every source in that range consistently. That is why we widen
   the LINEITEM window ONLY on orgs that actually carry Growyze line items -
   widening it on a Mews/NCRAloha org would needlessly rebuild that org's POS
   facts. Same reasoning for STOCKEVENT: widened only where F_PURCHASES_DAY is
   still empty but its source rows exist, which self-limits to the org that just
   had the table created and makes re-runs no-ops.

   Idempotent. Always restores all four keys to NULL, even on failure.
   ============================================================================ */

SET NOCOUNT ON;

DECLARE @widen_lineitem   BIT = 0;
DECLARE @widen_stockevent BIT = 0;
DECLARE @li_min DATE, @li_max DATE, @se_min DATE, @se_max DATE;

/* -- Does this org carry Growyze line items? (Padel + Dirty Sixth do; the
      Mews-POS orgs hold zero, so Task 6 is a no-op for them.) -------------- */
IF EXISTS (SELECT 1 FROM [datavault].[SAT_LINEITEM]
           WHERE CURRENT_FLAG = 1 AND SRC = 'int_growyze001')
BEGIN
    SELECT @li_min = CAST(MIN([ORDER_DATE]) AS DATE),
           @li_max = CAST(MAX([ORDER_DATE]) AS DATE)
    FROM [datavault].[SAT_LINEITEM]
    WHERE CURRENT_FLAG = 1;

    IF @li_min IS NOT NULL AND @li_max IS NOT NULL
    BEGIN
        SET @widen_lineitem = 1;
        /* +1 day on the upper bound: ORDER_DATE is datetime2 but the bound is a
           DATE (midnight), so a same-day bound silently drops any row carrying a
           time. Growyze lands at midnight, but other sources in range may not. */
        SET @li_max = DATEADD(DAY, 1, @li_max);
    END
END

/* -- Is F_PURCHASES_DAY present-but-empty with source rows available?
      True only on the org that just had the table created (Task 7). --------- */
IF EXISTS (SELECT 1 FROM sys.tables t JOIN sys.schemas s ON s.schema_id = t.schema_id
           WHERE s.name = 'presentation' AND t.name = 'F_PURCHASES_DAY')
   AND NOT EXISTS (SELECT 1 FROM [presentation].[F_PURCHASES_DAY])
   AND EXISTS (SELECT 1 FROM [datavault].[SAT_LNK_INVITEM_STOCKORDER])
BEGIN
    /* SAT_STOCKEVENT's date column is EVENT_TS (there is no EVENT_DATE). */
    SELECT @se_min = CAST(MIN([EVENT_TS]) AS DATE),
           @se_max = CAST(MAX([EVENT_TS]) AS DATE)
    FROM [datavault].[SAT_STOCKEVENT]
    WHERE CURRENT_FLAG = 1;

    IF @se_min IS NOT NULL AND @se_max IS NOT NULL
    BEGIN
        SET @widen_stockevent = 1;
        SET @se_max = DATEADD(DAY, 1, @se_max);
    END
END

PRINT 'widen_lineitem   = ' + CAST(@widen_lineitem AS VARCHAR(1))
    + ISNULL('  (' + CONVERT(VARCHAR(10), @li_min, 23) + ' .. ' + CONVERT(VARCHAR(10), @li_max, 23) + ')', '');
PRINT 'widen_stockevent = ' + CAST(@widen_stockevent AS VARCHAR(1))
    + ISNULL('  (' + CONVERT(VARCHAR(10), @se_min, 23) + ' .. ' + CONVERT(VARCHAR(10), @se_max, 23) + ')', '');

BEGIN TRY

    IF @widen_lineitem = 1
    BEGIN
        UPDATE [core].[GlobalParameters]
        SET ParameterValue = CONVERT(NVARCHAR(10), @li_min, 23), ModifiedDate = GETDATE()
        WHERE ParameterKey = N'LINEITEM_START';

        UPDATE [core].[GlobalParameters]
        SET ParameterValue = CONVERT(NVARCHAR(10), @li_max, 23), ModifiedDate = GETDATE()
        WHERE ParameterKey = N'LINEITEM_END';
    END

    IF @widen_stockevent = 1
    BEGIN
        UPDATE [core].[GlobalParameters]
        SET ParameterValue = CONVERT(NVARCHAR(10), @se_min, 23), ModifiedDate = GETDATE()
        WHERE ParameterKey = N'STOCKEVENT_START';

        UPDATE [core].[GlobalParameters]
        SET ParameterValue = CONVERT(NVARCHAR(10), @se_max, 23), ModifiedDate = GETDATE()
        WHERE ParameterKey = N'STOCKEVENT_END';
    END

    EXEC [core].[sp_ProcessPresentation];

END TRY
BEGIN CATCH
    DECLARE @err NVARCHAR(MAX) = ERROR_MESSAGE();
    /* Restore the resting state before surfacing the error, so a failed run
       never leaves a stale window behind for the next scheduled load. */
    UPDATE [core].[GlobalParameters]
    SET ParameterValue = NULL, ModifiedDate = GETDATE()
    WHERE ParameterKey IN (N'LINEITEM_START', N'LINEITEM_END',
                           N'STOCKEVENT_START', N'STOCKEVENT_END');
    RAISERROR(N'Presentation rebuild failed: %s', 16, 1, @err);
    RETURN;
END CATCH

/* NULL is the expected resting state - it means the last cycle completed. */
UPDATE [core].[GlobalParameters]
SET ParameterValue = NULL, ModifiedDate = GETDATE()
WHERE ParameterKey IN (N'LINEITEM_START', N'LINEITEM_END',
                       N'STOCKEVENT_START', N'STOCKEVENT_END');

PRINT 'Presentation rebuild complete; load window reset to NULL.';
