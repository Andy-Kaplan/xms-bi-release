# ============================================================================
# 90_deploy_cogs.ps1 - Deploy the Growyze Pantry COGS dashboard (F_COGS_PERIOD)
# ============================================================================
# Runs the 11-step sequence in DEPLOY.txt against ONE target org in ONE
# environment. Mirrors ClaudeDevelopment/prod-baseline/90_deploy_baseline.ps1:
# same env-var convention, same -WhatIf preflight, same typed confirmation,
# same halt-on-error / -StartAt resume, same per-run log file, PASS/FAIL
# validation run through the same connection via 99_verify_cogs_period.sql.
#
# Connection comes from env vars:
#   XMS_BI_MANAGED_{ENV}_SERVER / _USER / _PASSWORD   (e.g. ..._UAT_SERVER)
#
# NOT YET RUN. This script was authored without database access in this
# session - nothing in this file has been executed against any server. See
# README.md for the folder's current state.
#
# ----------------------------------------------------------------------------
# TWO HARD SAFETY RULES BUILT INTO THIS SCRIPT - do not work around them.
# ----------------------------------------------------------------------------
#
# 1. THIS RUNNER NEVER CALLS [core].[DeployPresentationTables].
#    That procedure (releases/v1.0-baseline/6_DeployPresentationTables.sql)
#    cursors over every row in core.PresentationTables with status = 'Live'
#    and unconditionally DROPs + recreates each one in the target database
#    (see its cursor at line 70 and the DROP TABLE at line 123 of that file).
#    Calling it against a live org would drop and rebuild EVERY registered
#    presentation table in that org's database, not just F_COGS_PERIOD.
#    Step 5 below deploys F_COGS_PERIOD individually instead: it reads
#    F_COGS_PERIOD's own DDL out of core.PresentationTables and runs only
#    that, against only that one table, in the target database. As a second
#    line of defence, every .sql file this script executes (and the DDL text
#    read back for step 5) is scanned for a call to DeployPresentationTables
#    before anything runs; a match aborts the whole run.
#
# 2. THIS RUNNER REFUSES TO EXECUTE 08_report_db_config.sql.
#    That script targets the `report` MICROSERVICE database on a different
#    server (the microservice SQL server, not the XMS BI Managed Instance
#    this runner connects to) - see its own header. This runner only ever
#    holds XMS_BI_MANAGED_* credentials and will never attempt a connection
#    for it. Step 10 is listed below purely for order/documentation; when
#    reached, the script logs an explicit refusal and the reason, then moves
#    on. Run 08_report_db_config.sql by hand, directly against `report`,
#    per DEPLOY.txt step 10.
#
# NOTE ON VERIFY RUNS: 99_verify_cogs_period.sql runs THREE times (steps 1,
# 7, 9), not two. Check 8 (VisualisationQueries length checks) has nothing to
# check until the vis scripts (step 8) have run, so its PASS at step 7 is
# vacuous - a check that cannot fail there is worse than no check. Step 9 is
# the real gate for check 8. See the Note on each verify step below.
#
# Usage:
#   .\90_deploy_cogs.ps1 -Environment UAT -TargetDatabase <client_db> -WhatIf
#   .\90_deploy_cogs.ps1 -Environment UAT -TargetDatabase <client_db>
#   .\90_deploy_cogs.ps1 -Environment UAT -TargetDatabase <client_db> -StartAt 5
#
# First-deploy target per DEPLOY.txt: Ibis Gloucester Road, UAT org 21.
# ============================================================================

[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidateSet('DEV','TEST','UAT','PROD')]
    [string]$Environment,

    # The client's GUID-named database, e.g. '20260317_XMS_7ED2E768-0D22-...'.
    # Required for every real run (steps 1, 5, 6, 7, 9 run against this
    # database; steps 2-4 and 8 run against 'core'). Not required for -WhatIf.
    [string]$TargetDatabase,

    [string]$CogsPath = $PSScriptRoot,

    # [double] (not [int], unlike 90_deploy_baseline.ps1) so a run can resume
    # mid-way through the four vis-script sub-steps (8.1-8.4) rather than only
    # at whole-step boundaries.
    [double]$StartAt = 1,

    [switch]$WhatIf,
    [switch]$Force,

    # Tier passed to [core].[sp_ProcessPresentation] @TierFilter at step 6.
    # Default 110 (this dashboard's own build step only) keeps the rebuild's
    # blast radius to the thing just deployed. Use -FullRebuild to run every
    # PresentationControl step instead (matches how "Presentation rebuild" is
    # used elsewhere in this repo, but touches far more than this change).
    [int]$TierFilter = 110,
    [switch]$FullRebuild
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# --- connection ---------------------------------------------------------------
$server   = [Environment]::GetEnvironmentVariable("XMS_BI_MANAGED_${Environment}_SERVER")
$user     = [Environment]::GetEnvironmentVariable("XMS_BI_MANAGED_${Environment}_USER")
$password = [Environment]::GetEnvironmentVariable("XMS_BI_MANAGED_${Environment}_PASSWORD")
if (-not $server -or -not $user -or -not $password) {
    throw "Missing env vars XMS_BI_MANAGED_${Environment}_SERVER / _USER / _PASSWORD."
}
if ($server -notmatch ',\d+$' -and $server -match '\.public\.') { $server = "$server,3342" }

if (-not $WhatIf -and -not $TargetDatabase) {
    throw "TargetDatabase is required (except for -WhatIf). This is the client's GUID-named database - see DEPLOY.txt for the first-deploy target (Ibis Gloucester Road, UAT org 21)."
}

if (-not (Get-Module -ListAvailable -Name SqlServer)) {
    throw "SqlServer module missing. Run: Install-Module SqlServer -Scope CurrentUser -AllowClobber"
}
Import-Module SqlServer -DisableNameChecking -WarningAction SilentlyContinue

# --- deploy sequence (mirrors DEPLOY.txt steps 1-10) ---------------------------
# Kind:
#   File        - run the named .sql file via Invoke-Sqlcmd against Db
#   TableDeploy - inline, safe single-table deploy of F_COGS_PERIOD (reads its
#                 own DDL out of core.PresentationTables; never calls
#                 DeployPresentationTables - see header)
#   Rebuild     - inline EXEC [core].[sp_ProcessPresentation] against $TargetDatabase
#   Refuse      - never executed by this runner (08_report_db_config.sql)
#   Manual      - not a database action; logged as a reminder only
$deploySteps = @(
    @{ Num = 1;   Kind = 'File';        File = '99_verify_cogs_period.sql';  Db = 'TargetDatabase'; ExpectFailure = $true; Label = 'Verify (expect FAIL - table absent; this is the test)' },
    @{ Num = 2;   Kind = 'File';        File = '01_cogs_period_table.sql';   Db = 'core';           Label = 'PresentationTables MERGE' },
    @{ Num = 3;   Kind = 'File';        File = '02_cogs_period_build.sql';   Db = 'core';           Label = 'PresentationControl MERGE (tier 110)' },
    # Step 4 runs against TargetDatabase, NOT core (final-review C1). GlobalParameters is a
    # per-database deployable object, and 02's build query reads it with a two-part name from
    # inside the client database (sp_ProcessPresentation executes each query_sql in the calling
    # database's context). Writing this row to `core` left the break-out config in a table the
    # build never reads: STRING_SPLIT(NULL,'|') returns zero rows rather than erroring, so
    # REPORT_GROUP silently collapsed to CATEGORY for every row while every check still passed.
    @{ Num = 4;   Kind = 'File';        File = '03_report_group_config.sql'; Db = 'TargetDatabase'; Label = 'GlobalParameters MERGE - against the CLIENT database, not core' },
    @{ Num = 5;   Kind = 'TableDeploy'; Label = 'Deploy F_COGS_PERIOD - THIS TABLE ONLY, never DeployPresentationTables' },
    @{ Num = 6;   Kind = 'Rebuild';     Label = 'Presentation rebuild (tier 110)' },
    @{ Num = 7;   Kind = 'File';        File = '99_verify_cogs_period.sql';  Db = 'TargetDatabase'; ExpectPass = $true;
        Label = 'Verify (expect PASS on 1,3,4,6a,7,9,10; PASS-or-WARN on 11; INFO on 5,6b; check 2 SKIPPED; check 8 VACUOUS - see note)'
        Note  = 'Check 8 (VisualisationQueries length checks, filtered to PantryCOGS%) has ZERO rows to look at until step 8 runs the vis scripts. A PASS here proves nothing about check 8 - do not read it as coverage. The real gate for check 8 is step 9.' },
    @{ Num = 8.1; Kind = 'File';        File = '04_vis_kpis.sql';            Db = 'core';           Label = 'VisualisationQueries: KPIs' },
    @{ Num = 8.2; Kind = 'File';        File = '05_vis_charts.sql';          Db = 'core';           Label = 'VisualisationQueries: charts' },
    @{ Num = 8.3; Kind = 'File';        File = '06_vis_grids.sql';           Db = 'core';           Label = 'VisualisationQueries: grids' },
    @{ Num = 8.4; Kind = 'File';        File = '07_vis_filters.sql';         Db = 'core';           Label = 'VisualisationQueries: filters' },
    @{ Num = 9;   Kind = 'File';        File = '99_verify_cogs_period.sql';  Db = 'TargetDatabase'; ExpectPass = $true;
        Label = 'Verify (expect PASS INCLUDING check 8, now that PantryCOGS vis rows exist)'
        Note  = 'This is the real acceptance gate for check 8. Check 2 (Growyze reconciliation) still reports SKIPPED until a real export is loaded into [reference].[GROWYZE_COGS_EXPORT_STAGING].' },
    @{ Num = 10;  Kind = 'Refuse';      File = '08_report_db_config.sql';    Label = 'Report-DB wiring - REFUSED by this runner, run by hand against report' },
    @{ Num = 11;  Kind = 'Manual';      Label = 'UI check - exercise all three filters as the target org' }
)

# --- guard: no .sql file this runner touches may call DeployPresentationTables -
$forbidden = [regex]'(?i)EXEC(UTE)?\s*\(?\s*\[?core\]?\.\[?DeployPresentationTables\]?'
foreach ($s in $deploySteps) {
    if ($s.Kind -eq 'File') {
        $p = Join-Path $CogsPath $s.File
        if (Test-Path $p) {
            $fileContent = Get-Content -Raw -Path $p
            if ($forbidden.IsMatch($fileContent)) {
                throw "REFUSED: $($s.File) calls DeployPresentationTables. This runner will never execute that call (see script header) - fix the file, don't work around this guard."
            }
        }
    }
}

# --- preflight -----------------------------------------------------------------
$log = Join-Path $PSScriptRoot ("deploy_cogs_{0}_{1}.log" -f $Environment, (Get-Date -Format 'yyyyMMdd_HHmmss'))
function Log([string]$msg) {
    $line = "[{0}] {1}" -f (Get-Date -Format 'HH:mm:ss'), $msg
    Write-Host $line
    Add-Content -Path $log -Value $line
}

Log "Target environment : $Environment"
Log "Target server      : $server"
Log "Target database    : $(if ($TargetDatabase) { $TargetDatabase } else { '(not set - WhatIf preflight only)' })"
Log "Cogs script path    : $CogsPath"
Log "Tier filter         : $(if ($FullRebuild) { 'ALL (full rebuild)' } else { $TierFilter })"
Log "Steps               : $($deploySteps.Count) (DEPLOY.txt 1-11; step 10 refused, step 11 manual)"

$missing = $deploySteps | Where-Object { $_.Kind -eq 'File' -and -not (Test-Path (Join-Path $CogsPath $_.File)) }
if ($missing) { throw "Missing cogs files: $(($missing | ForEach-Object { $_.File }) -join ', ')" }
Log "All required .sql files present."

$connArgs = @{
    ServerInstance         = $server
    Username               = $user
    Password               = $password
    TrustServerCertificate = $true
    ErrorAction            = 'Stop'
}

function Resolve-Db([string]$dbToken) {
    if ($dbToken -eq 'TargetDatabase') { return $TargetDatabase }
    return $dbToken
}

if ($WhatIf) {
    Log 'WhatIf: preflight complete, no scripts executed. Planned order:'
    foreach ($s in $deploySteps) {
        $dbLabel = if ($s.Kind -eq 'File') { Resolve-Db $s.Db } elseif ($s.Kind -in @('TableDeploy', 'Rebuild')) { '(TargetDatabase)' } else { '-' }
        Log ("  {0,4}. [{1,-11}] [{2,-18}] {3}" -f $s.Num, $s.Kind, $dbLabel, $s.Label)
    }
    Log "REFUSED step (10): 08_report_db_config.sql - targets 'report' on a different server. Run by hand."
    Log "NEVER called: [core].[DeployPresentationTables] (drops and recreates every registered presentation table)."
    return
}

$verInfo = Invoke-Sqlcmd @connArgs -Database 'master' -Query "SELECT @@SERVERNAME AS srv, SERVERPROPERTY('ProductVersion') AS ver"
Log "Connected: $($verInfo.srv) (SQL $($verInfo.ver))"

if (-not $Force) {
    $ack = Read-Host "About to deploy Growyze Pantry COGS to $Environment / $TargetDatabase ($server). Type the target database name to confirm"
    if ($ack -cne $TargetDatabase) { Log 'Aborted by operator.'; return }
}

# --- execute -------------------------------------------------------------------
foreach ($step in $deploySteps) {
    if ($step.Num -lt $StartAt) { continue }

    switch ($step.Kind) {

        'Refuse' {
            Log ("STEP {0,4} REFUSED: {1} - {2}" -f $step.Num, $step.File, $step.Label)
            Log "  Reason: targets the 'report' microservice database on a different server."
            Log "  Action: run $($step.File) directly against report, by hand. See DEPLOY.txt step 10."
        }

        'Manual' {
            Log ("STEP {0,4} MANUAL: {1}" -f $step.Num, $step.Label)
            Log "  Not a database action - this runner stops here. Perform the UI check yourself."
        }

        'File' {
            $db = Resolve-Db $step.Db
            $path = Join-Path $CogsPath $step.File
            Log ("STEP {0,4} [{1}] {2}" -f $step.Num, $db, $step.File)
            try {
                $rows = Invoke-Sqlcmd @connArgs -Database $db -InputFile $path -QueryTimeout 1800 -Verbose 4>&1
                # WARN is a real verdict, not a typo: check 11 returns it when the break-out
                # config is readable but this org holds no rows in any configured category, so
                # the break-out is UNPROVEN rather than proven. It must be counted and printed -
                # a WARN that only reaches the raw row dump gives back most of what the verdict
                # was added for. It deliberately does NOT halt the deploy; only FAIL does.
                $verdicts = @{ PASS = 0; FAIL = 0; WARN = 0; SKIPPED = 0; INFO = 0 }
                foreach ($r in $rows) {
                    Add-Content -Path $log -Value ("    " + ($r | Out-String).TrimEnd())
                    if ($r -is [System.Management.Automation.VerboseRecord]) { continue }
                    if ($r.PSObject.Properties.Match('Verdict').Count -gt 0) {
                        $v = [string]$r.Verdict
                        if ($verdicts.ContainsKey($v)) { $verdicts[$v]++ }
                    }
                }
                if ($step.ContainsKey('ExpectPass') -or $step.ContainsKey('ExpectFailure')) {
                    Log ("  Verdicts: PASS={0} FAIL={1} WARN={2} SKIPPED={3} INFO={4}" -f $verdicts.PASS, $verdicts.FAIL, $verdicts.WARN, $verdicts.SKIPPED, $verdicts.INFO)
                    if ($verdicts.WARN -gt 0) {
                        Log ("  {0} check(s) reported WARN - not a failure, but something is UNPROVEN. Read the WARN row's Reason column in the log above before continuing." -f $verdicts.WARN)
                    }
                    if ($step.ContainsKey('Note')) { Log ("  NOTE: {0}" -f $step.Note) }
                    if ($step.ContainsKey('ExpectPass') -and $verdicts.FAIL -gt 0) {
                        throw "$($verdicts.FAIL) check(s) reported FAIL - halting."
                    }
                }
                Log ("STEP {0,4} OK" -f $step.Num)
            }
            catch {
                if ($step.ContainsKey('ExpectFailure')) {
                    Log ("STEP {0,4} FAILED AS EXPECTED: {1}" -f $step.Num, $_.Exception.Message)
                    Log "  presentation.F_COGS_PERIOD does not exist yet - this confirms step ordering. Continuing."
                    continue
                }
                Log ("STEP {0,4} FAILED: {1}" -f $step.Num, $_.Exception.Message)
                Log "Deployment halted. Fix the issue and resume with: .\90_deploy_cogs.ps1 -Environment $Environment -TargetDatabase $TargetDatabase -StartAt $($step.Num)"
                throw
            }
        }

        'TableDeploy' {
            Log ("STEP {0,4} [{1}] {2}" -f $step.Num, $TargetDatabase, $step.Label)
            try {
                # Read F_COGS_PERIOD's own DDL out of core.PresentationTables - do NOT
                # call [core].[DeployPresentationTables] (see script header, guard above).
                $row = Invoke-Sqlcmd @connArgs -Database 'core' -Query @"
SELECT schema_name, table_name, ddl_script
FROM core.PresentationTables
WHERE table_name = 'F_COGS_PERIOD' AND schema_name = 'presentation' AND status = 'live'
"@
                if (-not $row -or -not $row.ddl_script) {
                    throw "F_COGS_PERIOD not found (or not status='live') in core.PresentationTables. Run step 2 (01_cogs_period_table.sql) first."
                }
                $ddl = [string]$row.ddl_script
                if ($forbidden.IsMatch($ddl)) { throw "REFUSED: the registered DDL for F_COGS_PERIOD calls DeployPresentationTables." }

                # Scoped to exactly this one table: create the schema if missing,
                # drop ONLY [presentation].[F_COGS_PERIOD] if it already exists (e.g.
                # a re-run), then run its registered DDL. Never touches any other
                # presentation table in the target database.
                $deploySql = @"
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'presentation')
BEGIN
    EXEC('CREATE SCHEMA [presentation]');
END;
IF EXISTS (SELECT 1 FROM sys.tables t INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
           WHERE s.name = 'presentation' AND t.name = 'F_COGS_PERIOD')
BEGIN
    DROP TABLE [presentation].[F_COGS_PERIOD];
END;
$ddl
"@
                Invoke-Sqlcmd @connArgs -Database $TargetDatabase -Query $deploySql -QueryTimeout 1800 |
                    ForEach-Object { Add-Content -Path $log -Value ("    " + ($_ | Out-String).TrimEnd()) }
                Log ("STEP {0,4} OK - F_COGS_PERIOD deployed to {1} only." -f $step.Num, $TargetDatabase)
            }
            catch {
                Log ("STEP {0,4} FAILED: {1}" -f $step.Num, $_.Exception.Message)
                Log "Deployment halted. Fix the issue and resume with: .\90_deploy_cogs.ps1 -Environment $Environment -TargetDatabase $TargetDatabase -StartAt $($step.Num)"
                throw
            }
        }

        'Rebuild' {
            Log ("STEP {0,4} [{1}] {2}" -f $step.Num, $TargetDatabase, $step.Label)
            try {
                $tierArg = if ($FullRebuild) { '' } else { " @TierFilter = $TierFilter" }
                $sql = "EXEC [core].[sp_ProcessPresentation]$tierArg;"
                Invoke-Sqlcmd @connArgs -Database $TargetDatabase -Query $sql -QueryTimeout 3600 -Verbose 4>&1 |
                    ForEach-Object { Add-Content -Path $log -Value ("    " + ($_ | Out-String).TrimEnd()) }
                Log ("STEP {0,4} OK" -f $step.Num)
            }
            catch {
                Log ("STEP {0,4} FAILED: {1}" -f $step.Num, $_.Exception.Message)
                Log "Deployment halted. Fix the issue and resume with: .\90_deploy_cogs.ps1 -Environment $Environment -TargetDatabase $TargetDatabase -StartAt $($step.Num)"
                throw
            }
        }
    }
}

Log 'Deployment run complete through the automated steps.'
Log 'Remaining by hand: step 10 (08_report_db_config.sql against report) and step 11 (UI check).'
