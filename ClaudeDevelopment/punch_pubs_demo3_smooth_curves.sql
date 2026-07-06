-- =============================================================================
-- Punch Pubs - Demo Dashboard 3: smooth the line curves
-- Target: UAT MI core DB (xms-bi-uat, database = core)
-- =============================================================================
-- Curve column: 'linear' (angular) -> 'natural' (smooth spline)
-- =============================================================================

UPDATE [core].[core].[VisualisationQueries]
SET [QueryTemplate] = REPLACE(CAST([QueryTemplate] AS NVARCHAR(MAX)),
                              N'''linear'' AS Curve',
                              N'''natural'' AS Curve'),
    [ModifiedDate] = GETDATE(),
    [ModifiedBy] = SUSER_SNAME()
WHERE [DataSetName] IN (N'RedLionTipRateByDay', N'RedLionTipRateByBillSize')
  AND [Status] = N'LIVE';

PRINT 'Curve set to natural on RedLionTipRateByDay and RedLionTipRateByBillSize';
