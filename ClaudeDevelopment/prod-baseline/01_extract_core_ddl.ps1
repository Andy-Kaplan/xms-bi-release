# ============================================================================
# 01_extract_core_ddl.ps1 - Regenerate core DDL files from UAT
# ============================================================================
# Produces in releases\v1.0-baseline\:
#   1__DBInit.sql                        (static boilerplate)
#   2_CoreTableCreateScripts.sql         (core tables + triggers)
#   3_CoreStoredProceduresAndFunctions.sql
#   4_DeploymentTools.sql                (DeploymentObjects table + sp_DeployObjects)
#   5_CreateIntegrationTables.sql        (sp_CreateIntegrationTables)
#   6_GenerateDataVaultTables.sql        (sp_GenerateDataVaultTables)
#   6_DeployPresentationTables.sql       (DeployPresentationTables SP)
#   7_IntegrationTrigger.sql             (trg_OrganisationIntegrations_AfterInsert)
#   7_Dynamic Suggestion Tables.sql      (4 suggestion tables)
#
# DDL sources:
#   - Tables: scripted via SMO (column types, indexes, defaults, PKs all included)
#   - Programmable objects (SPs, fns, triggers): OBJECT_DEFINITION() returns the
#     exact current source from UAT, including comments
# ============================================================================

. (Join-Path $PSScriptRoot '00_common.ps1')

Ensure-BaselineDirs

Write-Host ""
Write-Host "==> Connecting to UAT core DB..."
$smoServer = Connect-UatSmo -Database 'core'
$coreDb = $smoServer.Databases['core']
if (-not $coreDb) { throw "core database not found on UAT server." }

# ----------------------------------------------------------------------------
# Object-to-file mapping
# ----------------------------------------------------------------------------
# Tables that live in dedicated files (not in 2_)
$tableFileMap = @{
    'DeploymentObjects'    = '4_DeploymentTools.sql'
    'ActionInferenceRules' = '7_Dynamic Suggestion Tables.sql'
    'DescriptionRules'     = '7_Dynamic Suggestion Tables.sql'
    'DescriptionTemplates' = '7_Dynamic Suggestion Tables.sql'
    'MetricDefinitions'    = '7_Dynamic Suggestion Tables.sql'
    # Anything else in [core] schema falls through to 2_CoreTableCreateScripts.sql
}

# Programmable objects with dedicated files
$progFileMap = @{
    'sp_DeployObjects'                       = '4_DeploymentTools.sql'
    'sp_CreateIntegrationTables'             = '5_CreateIntegrationTables.sql'
    'sp_GenerateDataVaultTables'             = '6_GenerateDataVaultTables.sql'
    'DeployPresentationTables'               = '6_DeployPresentationTables.sql'
    'trg_OrganisationIntegrations_AfterInsert' = '7_IntegrationTrigger.sql'
    # Anything else (functions, other SPs) falls through to 3_
}

# Triggers that belong with 2_ (table-level housekeeping triggers)
$tableTriggers = @(
    'trg_CreateOrganisationDatabase',
    'trg_CreateIntegrationSchema',
    'trg_DataVaultEntities_RetireOlderVersions'
)

# ----------------------------------------------------------------------------
# Build SMO scripting options for tables
# ----------------------------------------------------------------------------
$scrOpts = New-Object Microsoft.SqlServer.Management.Smo.ScriptingOptions
$scrOpts.IncludeIfNotExists      = $true
$scrOpts.SchemaQualify           = $true
$scrOpts.Indexes                 = $true
$scrOpts.ClusteredIndexes        = $true
$scrOpts.NonClusteredIndexes     = $true
$scrOpts.DriPrimaryKey           = $true
$scrOpts.DriUniqueKeys           = $true
$scrOpts.DriDefaults             = $true
$scrOpts.DriChecks               = $true
$scrOpts.DriForeignKeys          = $false   # FK rows extracted separately to avoid cycles
$scrOpts.NoCommandTerminator     = $false
$scrOpts.AnsiPadding             = $false
$scrOpts.WithDependencies        = $false
$scrOpts.IncludeHeaders          = $false
$scrOpts.ScriptBatchTerminator   = $true
$scrOpts.AnsiFile                = $false
$scrOpts.Encoding                = [System.Text.Encoding]::UTF8

function Script-Table {
    param([Microsoft.SqlServer.Management.Smo.Table]$tbl)
    $sb = New-Object System.Text.StringBuilder
    foreach ($line in $tbl.Script($scrOpts)) {
        [void]$sb.AppendLine($line)
        [void]$sb.AppendLine('GO')
    }
    return $sb.ToString()
}

function Script-Object-FromDefinition {
    param([string]$schema, [string]$name)
    $row = Invoke-UatQuery -Database 'core' -Query @"
SELECT m.definition AS body
FROM sys.sql_modules m
INNER JOIN sys.objects o ON o.object_id = m.object_id
INNER JOIN sys.schemas s ON s.schema_id = o.schema_id
WHERE s.name = '$schema' AND o.name = '$name'
"@
    if (-not $row) { return $null }
    $def = $row.body
    if ([string]::IsNullOrWhiteSpace($def)) { return $null }
    # Normalise to CREATE OR ALTER for re-runnability
    $def = [regex]::Replace($def, '^\s*CREATE\s+(PROCEDURE|FUNCTION|TRIGGER|VIEW)\b', 'CREATE OR ALTER $1', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    return ($def.TrimEnd() + "`r`nGO`r`n")
}

# ----------------------------------------------------------------------------
# Per-file accumulators
# ----------------------------------------------------------------------------
$bucket = @{}
function Add-ToBucket {
    param([string]$file, [string]$body)
    if (-not $bucket.ContainsKey($file)) { $bucket[$file] = New-Object System.Text.StringBuilder }
    [void]$bucket[$file].AppendLine($body)
    [void]$bucket[$file].AppendLine()
}

# ----------------------------------------------------------------------------
# 1__DBInit.sql - static boilerplate (no UAT query needed)
# ----------------------------------------------------------------------------
$dbInit = @"
-- =============================================
-- SQL Server Managed Instance Initialization Script
-- Creates databases and schemas for new instances
-- Regenerated from UAT $script:Timestamp
-- =============================================

USE master;
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'core')
BEGIN
    CREATE DATABASE [core];
    PRINT 'core database created successfully.';
END
ELSE
BEGIN
    PRINT 'core database already exists.';
END
GO

USE [core];
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'core')
BEGIN
    EXEC('CREATE SCHEMA [core]');
    PRINT 'Schema [core] created successfully.';
END
ELSE
BEGIN
    PRINT 'Schema [core] already exists.';
END
GO
"@
Add-ToBucket -file '1__DBInit.sql' -body $dbInit

# ----------------------------------------------------------------------------
# Tables in [core] schema
# ----------------------------------------------------------------------------
Write-Host "==> Scripting tables in [core] schema..."
$coreTables = $coreDb.Tables | Where-Object { $_.Schema -eq 'core' } | Sort-Object Name
Write-Host "    found $($coreTables.Count) tables: $(($coreTables | ForEach-Object Name) -join ', ')"

foreach ($tbl in $coreTables) {
    $target = if ($tableFileMap.ContainsKey($tbl.Name)) { $tableFileMap[$tbl.Name] } else { '2_CoreTableCreateScripts.sql' }
    $header = "-- ============================================`r`n-- Table: [core].[$($tbl.Name)]`r`n-- ============================================"
    $ddl    = Script-Table -tbl $tbl
    Add-ToBucket -file $target -body "$header`r`n$ddl"
}

# ----------------------------------------------------------------------------
# Programmable objects in [core] schema
# ----------------------------------------------------------------------------
Write-Host "==> Enumerating programmable objects in [core] schema..."
$progRows = Invoke-UatQuery -Database 'core' -Query @"
SELECT s.name AS schema_name, o.name AS object_name, o.type_desc
FROM sys.objects o
INNER JOIN sys.schemas s ON s.schema_id = o.schema_id
WHERE s.name = 'core'
  AND o.type IN ('P','FN','IF','TF','TR','V')
  AND o.is_ms_shipped = 0
ORDER BY
    CASE o.type WHEN 'FN' THEN 1 WHEN 'IF' THEN 1 WHEN 'TF' THEN 1
                WHEN 'V'  THEN 2
                WHEN 'P'  THEN 3
                WHEN 'TR' THEN 4 END,
    o.name
"@

Write-Host "    found $($progRows.Count) programmable objects"

foreach ($row in $progRows) {
    $name   = $row.object_name
    $schema = $row.schema_name
    $type   = $row.type_desc

    if ($progFileMap.ContainsKey($name)) {
        $target = $progFileMap[$name]
    }
    elseif ($type -eq 'SQL_TRIGGER') {
        if ($tableTriggers -contains $name) {
            $target = '2_CoreTableCreateScripts.sql'
        } else {
            $target = '7_IntegrationTrigger.sql'   # fallback for unknown triggers
        }
    }
    else {
        $target = '3_CoreStoredProceduresAndFunctions.sql'
    }

    $body = Script-Object-FromDefinition -schema $schema -name $name
    if ($null -eq $body) {
        Write-Warning "  no definition for [$schema].[$name]"
        continue
    }
    $header = "-- ============================================`r`n-- $type : [$schema].[$name]`r`n-- ============================================"
    Add-ToBucket -file $target -body "$header`r`n$body"
}

# ----------------------------------------------------------------------------
# Flush all buckets to disk
# ----------------------------------------------------------------------------
Write-Host ""
Write-Host "==> Writing baseline files..."
foreach ($file in $bucket.Keys | Sort-Object) {
    $path = Join-Path $script:BaselineRoot $file
    $hdr  = "-- ============================================`r`n-- $file`r`n-- Regenerated from UAT $script:Timestamp`r`n-- Server: $script:UatServer`r`n-- ============================================`r`n`r`n"
    Write-SqlFile -Path $path -Content ($hdr + $bucket[$file].ToString())
}

Write-Host ""
Write-Host "01_extract_core_ddl.ps1 complete."
