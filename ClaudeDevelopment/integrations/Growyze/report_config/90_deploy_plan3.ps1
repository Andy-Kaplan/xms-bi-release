# ============================================================================
# 90_deploy_plan3.ps1 - Deploy Growyze dashboards Plan 3 (Report DB wiring)
# ============================================================================
# Ledger: O5.  Plan: docs/plans/2026-07-10-growyze-dashboards-3-report-db.md (rev 2)
#
# TARGET: the microservice `report` database.
#   This is an Azure SQL Database, NOT the Managed Instance. The MI runners
#   (95/97/98_*.ps1) do not reach it and their env vars are the wrong ones.
#   MCP against `report` is READ-ONLY, which is why writes come through here.
#
# Steps:
#   1  01_prereqs_biconfig_visconfig.sql .. Padel DbPrefix (O34) + card-type grants
#   2  01b_provision_heathrow.sql ......... Ibis Heathrow BiConfig + All Dashboards group
#   3  02_dataset_map.sql ................. 26 datasets x 5 orgs
#   4  03_grids_configs_groups.sql ........ 3 grids + 15 configs + group mappings
#   5  04_items_overview.sql .............. Overview:  8 items + 2 filters
#   6  05_items_sales.sql ................. Sales:    15 items + 3 filters
#   7  06_items_inventory.sql ............. Inventory: 9 items + 2 filters
#   8  99_verify_plan3.sql ................ report-DB checks A1-A9 (the gate)
#   9  cross-server check ................. every wired DataSet is LIVE on the MI
#
# *** NOT DEPLOYED BY THIS RUNNER: Task 1c ***
#   The Oak & Vine Growyze venue-label fix (MICROSERVICE_NAME) is an MI change
#   and needs a presentation rebuild. It is a separate script under
#   ClaudeDevelopment/integrations/Growyze/, run with the MI runners.
#
# WHY STEP 9 EXISTS AND IS NOT OPTIONAL
#   Steps 1-8 only prove the report DB agrees with ITSELF. A DataSet name is the
#   cross-system key: if it drifts by one character from the MI's DataSetName,
#   every report-DB check still passes and the card renders blank with no clue
#   why. Step 9 reads the ACTUAL wired names out of `report` (it does not
#   re-declare them, so it cannot share a typo with the deploy scripts) and
#   confirms each is LIVE on the MI with a matching VisualizationType.
#
# Usage:
#   .\90_deploy_plan3.ps1 -WhatIf              # list steps, change nothing
#   .\90_deploy_plan3.ps1 -VerifyOnly          # run steps 8-9 only, read-only
#   .\90_deploy_plan3.ps1
#   .\90_deploy_plan3.ps1 -StartAt 4           # resume after a failure
#
# Rollback: each .sql carries its own rollback block. Order matters - children
# (grid items/filters, group mappings) before parents (configs, grids).
# ============================================================================

[CmdletBinding()]
param(
    [Parameter()][ValidateSet('UAT')]
    [string]$Environment = 'UAT',
    [int]$StartAt = 1,
    [switch]$VerifyOnly,
    [switch]$WhatIf
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Read an env var from Process, then User, then Machine. A non-interactive agent
# shell often has an empty Process scope even when the variable is set for the
# user - reading Process alone gives a spurious "missing env vars" failure.
function Get-EnvAny {
    param([Parameter(Mandatory)][string]$Name)
    foreach ($scope in @('Process','User','Machine')) {
        $v = [Environment]::GetEnvironmentVariable($Name, $scope)
        if ($v) { return $v }
    }
    return $null
}

# ---- Connections -----------------------------------------------------------
$reportServer = Get-EnvAny "AZURE_MICROSERVICE_${Environment}_SERVER"
$reportUser   = Get-EnvAny "AZURE_MICROSERVICE_${Environment}_USER"
$reportPwd    = Get-EnvAny "AZURE_MICROSERVICE_${Environment}_PASSWORD"
if (-not $reportServer -or -not $reportUser -or -not $reportPwd) {
    throw "Missing env vars AZURE_MICROSERVICE_${Environment}_SERVER / _USER / _PASSWORD."
}
if ($reportServer -match 'prod') { throw "Refusing to run against a server whose name contains 'prod': $reportServer" }

$miServer = Get-EnvAny "XMS_BI_MANAGED_${Environment}_SERVER"
$miUser   = Get-EnvAny "XMS_BI_MANAGED_${Environment}_USER"
$miPwd    = Get-EnvAny "XMS_BI_MANAGED_${Environment}_PASSWORD"
if ($miServer -and $miServer -notmatch ',\d+$' -and $miServer -match '\.public\.') { $miServer = "$miServer,3342" }
if ($miServer -match 'prod') { throw "Refusing: MI server name contains 'prod': $miServer" }

if (-not (Get-Module -ListAvailable -Name SqlServer)) {
    throw "SqlServer module not found. Run: Install-Module SqlServer -Scope CurrentUser -AllowClobber"
}
Import-Module SqlServer -DisableNameChecking -WarningAction SilentlyContinue

$reportCred = New-Object System.Management.Automation.PSCredential(
    $reportUser, (ConvertTo-SecureString $reportPwd -AsPlainText -Force))
$miCred = if ($miUser) { New-Object System.Management.Automation.PSCredential(
    $miUser, (ConvertTo-SecureString $miPwd -AsPlainText -Force)) } else { $null }

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$log  = Join-Path $here ("deploy_PLAN3_{0}_{1}.log" -f $Environment, (Get-Date -Format 'yyyyMMdd_HHmmss'))

function Write-Log {
    param([string]$Message)
    $line = "{0}  {1}" -f (Get-Date -Format 'HH:mm:ss'), $Message
    Write-Host $line
    Add-Content -Path $log -Value $line -Encoding utf8
}

# ---- Step table ------------------------------------------------------------
$steps = @(
    @{ N=1; File='01_prereqs_biconfig_visconfig.sql'; Desc='Padel DbPrefix (O34) + card-type grants' }
    @{ N=2; File='01b_provision_heathrow.sql';        Desc='Ibis Heathrow BiConfig + All Dashboards group' }
    @{ N=3; File='02_dataset_map.sql';                Desc='26 datasets x 5 orgs' }
    @{ N=4; File='03_grids_configs_groups.sql';       Desc='3 grids + 15 configs + group mappings' }
    @{ N=5; File='04_items_overview.sql';             Desc='Overview: 8 items + 2 filters' }
    @{ N=6; File='05_items_sales.sql';                Desc='Sales: 15 items + 3 filters' }
    @{ N=7; File='06_items_inventory.sql';            Desc='Inventory: 9 items + 2 filters' }
)

Write-Log "=== Growyze Plan 3 (rev 2) - Report DB wiring ==="
Write-Log "report server : $reportServer  (database: report)"
Write-Log "MI server     : $(if ($miServer) { $miServer } else { '<not configured - step 9 will be skipped>' })"
Write-Log "log           : $log"
Write-Log ""

if ($WhatIf) {
    Write-Log "-WhatIf: listing steps only, nothing will be changed."
    foreach ($s in $steps) { Write-Log ("  step {0}: {1,-38} {2}" -f $s.N, $s.File, $s.Desc) }
    Write-Log "  step 8: 99_verify_plan3.sql             report-DB checks A1-A9"
    Write-Log "  step 9: cross-server check              every wired DataSet is LIVE on the MI"
    Write-Log ""
    Write-Log "Task 1c (Oak & Vine venue label) is NOT in this runner - it is an MI change."
    return
}

# ---- Steps 1-7: writes against `report` ------------------------------------
if (-not $VerifyOnly) {
    foreach ($s in $steps) {
        if ($s.N -lt $StartAt) { Write-Log ("step {0}: SKIPPED (-StartAt {1})" -f $s.N, $StartAt); continue }
        $path = Join-Path $here $s.File
        if (-not (Test-Path $path)) { throw "step $($s.N): file not found: $path" }
        Write-Log ("step {0}: {1} - {2}" -f $s.N, $s.File, $s.Desc)
        try {
            $out = Invoke-Sqlcmd -ServerInstance $reportServer -Database 'report' -Credential $reportCred `
                       -InputFile $path -QueryTimeout 300 -TrustServerCertificate -Verbose 4>&1
            foreach ($line in $out) { if ("$line".Trim()) { Write-Log ("       | " + "$line".Trim()) } }
            Write-Log ("step {0}: OK" -f $s.N)
        } catch {
            Write-Log ("step {0}: FAILED - {1}" -f $s.N, $_.Exception.Message)
            Write-Log "Each script is a single transaction with XACT_ABORT, so this step rolled back."
            Write-Log "Fix the cause and resume with: .\90_deploy_plan3.ps1 -StartAt $($s.N)"
            throw
        }
        Write-Log ""
    }
} else {
    Write-Log "-VerifyOnly: skipping steps 1-7, no writes."
    Write-Log ""
}

# ---- Step 8: the report-DB gate -------------------------------------------
Write-Log "step 8: 99_verify_plan3.sql - report-DB checks A1-A9"
$verify = Invoke-Sqlcmd -ServerInstance $reportServer -Database 'report' -Credential $reportCred `
              -InputFile (Join-Path $here '99_verify_plan3.sql') `
              -QueryTimeout 300 -TrustServerCertificate -OutputAs DataTables

foreach ($tbl in $verify) {
    foreach ($row in $tbl.Rows) {
        if ($tbl.Columns.Contains('Chk')) {
            Write-Log ("       {0}  {1,-7}  {2,-40}  {3}" -f $row.Chk, $row.Verdict, $row.Inspected, $row.Detail)
        } else {
            Write-Log ("       SUMMARY  PASS={0} FAIL={1} WARN={2} VACUOUS={3}" -f $row.PASS, $row.FAIL, $row.WARN, $row.VACUOUS)
            if ([int]$row.FAIL -gt 0) { Write-Log "step 8: FAIL - see the checks above. This is the gate; do not proceed." }
        }
    }
}
Write-Log ""

# ---- Step 9: the cross-server check (the independent witness) --------------
# Reads the ACTUAL wired names out of `report` rather than re-declaring them, so
# it cannot inherit a typo from the deploy scripts, then confirms each is LIVE on
# the MI with a matching VisualizationType.
if (-not $miServer) {
    Write-Log "step 9: SKIPPED - MI env vars not set, so the cross-system check cannot run."
    Write-Log "        A clean step 8 alone does NOT prove the cards will render."
} else {
    Write-Log "step 9: cross-server check - every wired DataSet is LIVE on the MI"

    $cardTypeName = @{
        1='BarChartCard'; 2='CombinedChartCard'; 3='CustomDataGrid'; 4='CustomGroupedDataGrid';
        5='CustomPinnedDataGrid'; 6='HeatmapCard'; 7='LineChartCard'; 8='MultiLineChartCard';
        9='PieChartCard'; 10='SingleKPICard'; 11='StackedBarChartCard'; 12='StatCard';
        13='TreeViewCard'; 15='RadarChartCard'; 16='StaticBoxCard'; 17='MarkdownCard'
    }

    $wiredSql = @"
SELECT DISTINCT dgi.DataSet, dgi.VisualisationId, N'card' AS Kind
FROM dbo.DashboardGridItem dgi
WHERE dgi.IsDeleted = 0
  AND dgi.DashboardGridId IN ('B0A1D000-0001-4A00-9E00-000000000001',
                              'B0A1D000-0002-4A00-9E00-000000000002',
                              'B0A1D000-0003-4A00-9E00-000000000003')
UNION
SELECT DISTINCT dgf.DataSet, NULL, N'filter'
FROM dbo.DashboardGridFilter dgf
WHERE dgf.IsDeleted = 0
  AND dgf.DashboardGridId IN ('B0A1D000-0001-4A00-9E00-000000000001',
                              'B0A1D000-0002-4A00-9E00-000000000002',
                              'B0A1D000-0003-4A00-9E00-000000000003');
"@
    $wired = @(Invoke-Sqlcmd -ServerInstance $reportServer -Database 'report' -Credential $reportCred `
                   -Query $wiredSql -QueryTimeout 120 -TrustServerCertificate)

    if ($wired.Count -eq 0) {
        Write-Log "       VACUOUS - nothing is wired to the pack grids, so there is nothing to check."
    } else {
        # One MI round trip for the whole set.
        $names = ($wired | ForEach-Object { "N'" + ($_.DataSet -replace "'", "''") + "'" }) -join ','
        $miSql = "SELECT DataSetName, VisualizationType, Status FROM core.core.VisualisationQueries WHERE DataSetName IN ($names);"
        $live = @(Invoke-Sqlcmd -ServerInstance $miServer -Database 'core' -Credential $miCred `
                      -Query $miSql -QueryTimeout 120 -TrustServerCertificate)

        $bad = 0
        foreach ($w in $wired) {
            $wantType = if ($w.Kind -eq 'filter') { 'FilterList' } else { $cardTypeName[[int]$w.VisualisationId] }
            $match = $live | Where-Object { $_.DataSetName -ceq $w.DataSet -and $_.VisualizationType -eq $wantType -and $_.Status -eq 'LIVE' }
            if (-not $match) {
                $bad++
                $any = $live | Where-Object { $_.DataSetName -ceq $w.DataSet }
                $why = if (-not $any) { 'NO vis query of that name on the MI (name drift?)' }
                       else { 'name exists but not LIVE as ' + $wantType + ' - found: ' +
                              (($any | ForEach-Object { "$($_.VisualizationType)/$($_.Status)" }) -join ', ') }
                Write-Log ("       MISMATCH  {0,-32} want {1,-22} {2}" -f $w.DataSet, $wantType, $why)
            }
        }
        $verdict = if ($bad -eq 0) { 'PASS' } else { 'FAIL' }
        Write-Log ("       {0} - inspected {1} wired (DataSet, type) pairs against the MI; {2} mismatch(es)." -f $verdict, $wired.Count, $bad)
        if ($bad -gt 0) { Write-Log "       Any mismatch means that card or filter renders BLANK. Fix before sign-off." }
    }
}

Write-Log ""
Write-Log "=== Done. Log: $log ==="
Write-Log "REMAINING BY HAND: Task 1c (Oak & Vine venue label, MI) and the front-end smoke test"
Write-Log "(Plan 3 Task 7 Step 6 lists the expected reading per card per org, so a wrong number is recognisable)."
