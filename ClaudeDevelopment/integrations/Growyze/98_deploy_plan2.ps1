# ============================================================================
# 98_deploy_plan2.ps1 - Deploy Growyze dashboards Plan 2 (cards & vis queries)
# ============================================================================
# Ledger: O5.  Plan: docs/plans/2026-07-10-growyze-dashboards-2-cards.md (rev 2)
#
# Deploys the twelve Plan 2 visualisation-query deltas to {ENV} core. Every one is
# an idempotent MERGE (or, for Task L, a keyed idempotent UPDATE) on
# core.core.VisualisationQueries.
#
#   Task A  42_growyze_active_stocktakes.sql ......... GrowyzeActiveStocktakes
#   Task B  43_growyze_deliveries_value.sql .......... GrowyzeDeliveriesValue
#   Task C  44_growyze_avg_cost_spend.sql ............ GrowyzeAvgCostSpend
#   Task D  45_growyze_best_category.sql ............. GrowyzeBestCategory
#   Task E  46_growyze_menu_highlights.sql ........... 4 highlight KPIs
#   Task F  47_growyze_venue_extremes.sql ............ Highest/Lowest venue
#   Task G  48_growyze_category_stock_trend.sql ...... GrowyzeCategoryStockTrend
#   Task H  49_growyze_menu_profitability_trend.sql .. GrowyzeMenuProfitabilityTrend
#   Task I  50_growyze_menu_engineering.sql .......... GrowyzeMenuEngineering
#   Task J  51_growyze_sales_heatmap.sql ............. GrowyzeSalesHeatmap
#   Task K  52_growyze_productscomp_filter.sql ....... GrowyzeProductsCompFilter
#   Task L  53_invmargebrut_filter_fix.sql ........... InvMargeBrut filter fix
#
# *** NO RELOAD AND NO PRESENTATION REBUILD ARE NEEDED ***
# Unlike Plan 1, nothing here changes staging, entity mappings or presentation
# build logic. Visualisation queries are read at CARD EXECUTION time, so these
# take effect on the next card render for every organisation. That is also why
# this runner touches only `core` and never iterates organisations.
#
# 15 datasets are created/updated in total (Task E creates 4 and Task F 2).
# All are new Growyze* datasets except Task L, which edits the SHARED InvMargeBrut
# FilterDefinitions - see its header for the justification and rollback.
#
# Usage:
#   .\98_deploy_plan2.ps1 -Environment UAT -WhatIf     # list steps, change nothing
#   .\98_deploy_plan2.ps1 -Environment UAT
#   .\98_deploy_plan2.ps1 -Environment UAT -StartAt 7  # resume after a failure
#   .\98_deploy_plan2.ps1 -Environment UAT -SkipTaskL  # leave the shared dataset alone
#
# Rollback: set Status='RETIRED' on the new Growyze* datasets (they are additive and
# wired to nothing until Plan 3 runs); restore InvMargeBrut's FilterDefinitions from
# git for Task L.
# ============================================================================

[CmdletBinding()]
param(
    [Parameter()][ValidateSet('DEV','TEST','UAT')]
    [string]$Environment = 'UAT',
    [int]$StartAt = 1,
    [switch]$SkipTaskL,
    [switch]$WhatIf
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Read an env var from Process, then User, then Machine. 95 read the process scope
# only, which is empty in a non-interactive/agent shell even when the variable is
# set for the user - a spurious "Missing env vars" failure.
function Get-EnvAny {
    param([Parameter(Mandatory)][string]$Name)
    foreach ($scope in @('Process','User','Machine')) {
        $v = [Environment]::GetEnvironmentVariable($Name, $scope)
        if ($v) { return $v }
    }
    return $null
}

$server   = Get-EnvAny "XMS_BI_MANAGED_${Environment}_SERVER"
$user     = Get-EnvAny "XMS_BI_MANAGED_${Environment}_USER"
$password = Get-EnvAny "XMS_BI_MANAGED_${Environment}_PASSWORD"
if (-not $server -or -not $user -or -not $password) {
    throw "Missing env vars XMS_BI_MANAGED_${Environment}_SERVER / _USER / _PASSWORD."
}
if ($server -notmatch ',\d+$' -and $server -match '\.public\.') { $server = "$server,3342" }
if ($server -match 'prod') { throw "Refusing to run against a server whose name contains 'prod': $server" }

if (-not (Get-Module -ListAvailable -Name SqlServer)) {
    throw "SqlServer module not found. Run: Install-Module SqlServer -Scope CurrentUser -AllowClobber"
}
Import-Module SqlServer -DisableNameChecking -WarningAction SilentlyContinue

$scriptDir = $PSScriptRoot
$logPath   = Join-Path $scriptDir ("deploy_PLAN2_${Environment}_" + (Get-Date -Format 'yyyyMMdd_HHmmss') + '.log')

function Write-Log {
    param([string]$Message)
    $line = "[{0}] {1}" -f (Get-Date -Format 'HH:mm:ss'), $Message
    Write-Host $line
    Add-Content -Path $logPath -Value $line -Encoding utf8
}

function Invoke-Sql {
    param([Parameter(Mandatory)][string]$Database, [string]$File, [string]$Query)
    $splat = @{
        ServerInstance = $server; Database = $Database
        Username = $user; Password = $password
        TrustServerCertificate = $true; QueryTimeout = 0
        ErrorAction = 'Stop'; OutputSqlErrors = $true
    }
    if ($File)  { $splat['InputFile'] = $File }
    if ($Query) { $splat['Query']     = $Query }
    Invoke-Sqlcmd @splat
}

Write-Log '=== Growyze dashboards Plan 2 - cards & visualisation queries (O5) ==='
Write-Log "Environment : $Environment"
Write-Log "Server      : $server"
Write-Log "Log         : $logPath"
if ($WhatIf) { Write-Log 'MODE        : -WhatIf (no changes will be made)' }

$steps = @(
    @{ N = 1;  Task = 'A'; File = 'reporting_queries/42_growyze_active_stocktakes.sql';        Desc = 'GrowyzeActiveStocktakes' }
    @{ N = 2;  Task = 'B'; File = 'reporting_queries/43_growyze_deliveries_value.sql';         Desc = 'GrowyzeDeliveriesValue' }
    @{ N = 3;  Task = 'C'; File = 'reporting_queries/44_growyze_avg_cost_spend.sql';           Desc = 'GrowyzeAvgCostSpend' }
    @{ N = 4;  Task = 'D'; File = 'reporting_queries/45_growyze_best_category.sql';            Desc = 'GrowyzeBestCategory' }
    @{ N = 5;  Task = 'E'; File = 'reporting_queries/46_growyze_menu_highlights.sql';          Desc = '4 Menu Item Highlight KPIs' }
    @{ N = 6;  Task = 'F'; File = 'reporting_queries/47_growyze_venue_extremes.sql';           Desc = 'Highest/Lowest stock venue' }
    @{ N = 7;  Task = 'G'; File = 'reporting_queries/48_growyze_category_stock_trend.sql';     Desc = 'GrowyzeCategoryStockTrend' }
    @{ N = 8;  Task = 'H'; File = 'reporting_queries/49_growyze_menu_profitability_trend.sql'; Desc = 'GrowyzeMenuProfitabilityTrend' }
    @{ N = 9;  Task = 'I'; File = 'reporting_queries/50_growyze_menu_engineering.sql';         Desc = 'GrowyzeMenuEngineering' }
    @{ N = 10; Task = 'J'; File = 'reporting_queries/51_growyze_sales_heatmap.sql';            Desc = 'GrowyzeSalesHeatmap' }
    @{ N = 11; Task = 'K'; File = 'reporting_queries/52_growyze_productscomp_filter.sql';      Desc = 'GrowyzeProductsCompFilter' }
    @{ N = 12; Task = 'L'; File = 'reporting_queries/53_invmargebrut_filter_fix.sql';          Desc = 'InvMargeBrut filter fix (SHARED dataset)' }
)

# Fail before touching anything if a script is missing.
foreach ($s in $steps) {
    $full = Join-Path $scriptDir $s.File
    if (-not (Test-Path $full)) { throw "Missing script: $full" }
}
Write-Log ("All {0} scripts present." -f $steps.Count)

$done = 0; $skipped = 0
foreach ($s in $steps) {
    $label = "Step {0,2} (Task {1}) - {2}" -f $s.N, $s.Task, $s.Desc

    if ($s.N -lt $StartAt) { Write-Log "$label : SKIPPED (-StartAt $StartAt)"; $skipped++; continue }
    if ($s.Task -eq 'L' -and $SkipTaskL) { Write-Log "$label : SKIPPED (-SkipTaskL)"; $skipped++; continue }
    if ($WhatIf) { Write-Log "$label : would run $($s.File)"; continue }

    Write-Log "$label : running $($s.File)"
    try {
        Invoke-Sql -Database 'core' -File (Join-Path $scriptDir $s.File) | Out-Null
        Write-Log "$label : OK"
        $done++
    }
    catch {
        Write-Log "$label : FAILED - $($_.Exception.Message)"
        Write-Log "Resume after fixing with: -StartAt $($s.N)"
        throw
    }
}

if ($WhatIf) {
    Write-Log '=== -WhatIf complete; nothing was changed ==='
    return
}

Write-Log "=== Deployed $done step(s); skipped $skipped ==="

# ---------------------------------------------------------------------------
# Post-deploy sanity: every expected dataset must be LIVE, must carry
# ParameterMappings (except the FilterList), must have no unreplaced {{token}},
# and must not have had its non-ASCII characters mangled by the file encoding.
# ---------------------------------------------------------------------------
$check = @'
DECLARE @expected TABLE (DataSetName NVARCHAR(200), VisualizationType NVARCHAR(100), NeedsPm BIT);
INSERT INTO @expected VALUES
 (N'GrowyzeActiveStocktakes',       N'SingleKPICard',     1),
 (N'GrowyzeDeliveriesValue',        N'SingleKPICard',     1),
 (N'GrowyzeAvgCostSpend',           N'SingleKPICard',     1),
 (N'GrowyzeBestCategory',           N'SingleKPICard',     1),
 (N'GrowyzeTopRevenueItem',         N'SingleKPICard',     1),
 (N'GrowyzeHighestGPItem',          N'SingleKPICard',     1),
 (N'GrowyzeMostSoldItem',           N'SingleKPICard',     1),
 (N'GrowyzeLowestItem',             N'SingleKPICard',     1),
 (N'GrowyzeHighestVenue',           N'SingleKPICard',     1),
 (N'GrowyzeLowestVenue',            N'SingleKPICard',     1),
 (N'GrowyzeCategoryStockTrend',     N'CustomDataGrid',    1),
 (N'GrowyzeMenuProfitabilityTrend', N'CombinedChartCard', 1),
 (N'GrowyzeMenuEngineering',        N'CustomDataGrid',    1),
 (N'GrowyzeSalesHeatmap',           N'HeatmapCard',       1),
 (N'GrowyzeProductsCompFilter',     N'FilterList',        0);

SELECT
    e.DataSetName,
    CASE WHEN v.DataSetName IS NULL THEN 'MISSING'
         WHEN v.Status <> N'LIVE'   THEN 'NOT LIVE: ' + v.Status
         WHEN e.NeedsPm = 1 AND v.ParameterMappings IS NULL THEN 'NULL ParameterMappings (date picker dead)'
         WHEN v.QueryTemplate LIKE N'%{{%' THEN 'UNREPLACED TOKEN'
         WHEN v.QueryTemplate LIKE N'%Ã%' OR v.QueryTemplate LIKE N'%â%' THEN 'MOJIBAKE - encoding mangled'
         ELSE 'OK' END AS verdict
FROM @expected e
LEFT JOIN [core].[core].[VisualisationQueries] v
       ON v.DataSetName = e.DataSetName AND v.VisualizationType = e.VisualizationType
ORDER BY CASE WHEN v.DataSetName IS NULL OR v.Status <> N'LIVE' THEN 0 ELSE 1 END, e.DataSetName;
'@

Write-Log '--- Post-deploy dataset check ---'
$rows = @(Invoke-Sql -Database 'core' -Query $check)
$bad = 0
foreach ($r in $rows) {
    Write-Log ("  {0,-32} {1}" -f $r.DataSetName, $r.verdict)
    if ($r.verdict -ne 'OK') { $bad++ }
}
if ($bad -gt 0) {
    Write-Log "!!! $bad dataset(s) failed the post-deploy check."
    throw "Post-deploy check failed for $bad dataset(s); see $logPath"
}
Write-Log 'All 15 datasets LIVE and well-formed.'
Write-Log 'Next: run 99_verify_plan2.sql against each Growyze org DB (NOT from core - see its header).'
