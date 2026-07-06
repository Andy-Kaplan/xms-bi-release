-- =============================================================================
-- Punch Pubs - Demo Dashboard 3: hide point markers on the line charts
-- Target: UAT MI core DB (xms-bi-uat, database = core)
-- =============================================================================
-- Sets ShowMark from 'true' to 'false' on the two MultiLineChartCard queries.
-- =============================================================================

UPDATE [core].[core].[VisualisationQueries]
SET [QueryTemplate] = REPLACE(CAST([QueryTemplate] AS NVARCHAR(MAX)),
                              N'''true'' AS ShowMark',
                              N'''false'' AS ShowMark'),
    [ModifiedDate] = GETDATE(),
    [ModifiedBy] = SUSER_SNAME()
WHERE [DataSetName] IN (N'RedLionTipRateByDay', N'RedLionTipRateByBillSize')
  AND [Status] = N'LIVE';

PRINT 'ShowMark set to false on RedLionTipRateByDay and RedLionTipRateByBillSize';
