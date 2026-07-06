# ============================================================================
# 02_extract_control_data.ps1 - Regenerate the 8_*.sql records files from UAT
# ============================================================================
# Produces in releases\v1.0-baseline\:
#   8_DataVaultEntities.sql
#   8_Deployment_Objects_Records.sql
#   8_PresentationControl.sql
#   8_PresentationTables.sql
#   8_VisualisationQueries.sql
#
# Output is IF EXISTS / UPDATE / ELSE / INSERT upserts (matches the existing
# release-file pattern; re-runnable without unique-key conflicts).
# ============================================================================

. (Join-Path $PSScriptRoot '00_common.ps1')

Ensure-BaselineDirs

# ----------------------------------------------------------------------------
# Per-table extraction config
#   keyCols  : natural key (used in WHERE for IF EXISTS / UPDATE)
#   orderBy  : deterministic ordering so re-runs produce stable diffs
#   skipCols : columns to omit from INSERT/UPDATE (defaults, identity, etc.)
# ----------------------------------------------------------------------------
$extractions = @(
    @{
        Table    = '[core].[core].[DataVaultEntities]'
        Schema   = 'core'; TableName = 'DataVaultEntities'
        File     = '8_DataVaultEntities.sql'
        KeyCols  = @('ENTITY_NAME','VERSION')
        OrderBy  = 'ENTITY_NAME, VERSION'
        SkipCols = @()
        Title    = 'Data Vault Entities'
    },
    @{
        Table    = '[core].[core].[DeploymentObjects]'
        Schema   = 'core'; TableName = 'DeploymentObjects'
        File     = '8_Deployment_Objects_Records.sql'
        KeyCols  = @('ObjectName','ObjectType')
        OrderBy  = 'ExecutionOrder, ObjectName'
        SkipCols = @()       # ObjectID is identity - auto-skipped
        Title    = 'Deployment Objects'
    },
    @{
        Table    = '[core].[core].[PresentationControl]'
        Schema   = 'core'; TableName = 'PresentationControl'
        File     = '8_PresentationControl.sql'
        KeyCols  = @('step_name')
        OrderBy  = 'tier, priority, step_name'
        SkipCols = @()       # keep id - the existing file preserves it
        Title    = 'Presentation Control'
    },
    @{
        Table    = '[core].[core].[PresentationTables]'
        Schema   = 'core'; TableName = 'PresentationTables'
        File     = '8_PresentationTables.sql'
        KeyCols  = @('table_name')
        OrderBy  = 'table_name'
        SkipCols = @()
        Title    = 'Presentation Tables'
    },
    @{
        Table    = '[core].[core].[VisualisationQueries]'
        Schema   = 'core'; TableName = 'VisualisationQueries'
        File     = '8_VisualisationQueries.sql'
        KeyCols  = @('DataSetName','VisualizationType')
        OrderBy  = 'DataSetName, VisualizationType'
        SkipCols = @()
        Title    = 'Visualisation Queries'
    }
)

function Get-ColumnList {
    param([string]$schema, [string]$table)
    Invoke-UatQuery -Database 'core' -Query @"
SELECT c.name AS col_name,
       t.name AS type_name,
       c.is_identity,
       c.is_computed,
       COALESCE(c.collation_name,'') AS coll
FROM sys.columns c
INNER JOIN sys.types t ON t.user_type_id = c.user_type_id
INNER JOIN sys.tables tb ON tb.object_id = c.object_id
INNER JOIN sys.schemas s ON s.schema_id = tb.schema_id
WHERE s.name = '$schema' AND tb.name = '$table'
ORDER BY c.column_id
"@
}

function Format-Upsert {
    param(
        [hashtable]$cfg,
        [array]$colMeta,
        $row
    )
    # Build columns we will write (skip identity, computed, configured skips)
    $writeCols = @()
    foreach ($c in $colMeta) {
        if ($c.is_identity -or $c.is_computed) { continue }
        if ($cfg.SkipCols -contains $c.col_name) { continue }
        $writeCols += $c.col_name
    }

    $keyCols = $cfg.KeyCols

    $whereClause = ($keyCols | ForEach-Object {
        $val = ConvertTo-SqlLiteral $row.$_
        "[$_] = $val"
    }) -join ' AND '

    $setPairs = ($writeCols | Where-Object { $keyCols -notcontains $_ } | ForEach-Object {
        $val = ConvertTo-SqlLiteral $row.$_
        "        [$_] = $val"
    }) -join ",`r`n"

    $insertCols = ($writeCols | ForEach-Object { "[$_]" }) -join ', '
    $insertVals = ($writeCols | ForEach-Object { ConvertTo-SqlLiteral $row.$_ }) -join ', '

    $tbl = $cfg.Table

    $idLabel = ($keyCols | ForEach-Object { "$_=$($row.$_)" }) -join ' / '

    return @"
-- $idLabel
IF EXISTS (SELECT 1 FROM $tbl WHERE $whereClause)
BEGIN
    UPDATE $tbl
    SET
$setPairs
    WHERE $whereClause;
END
ELSE
BEGIN
    INSERT INTO $tbl ($insertCols)
    VALUES ($insertVals);
END
GO

"@
}

# ----------------------------------------------------------------------------
foreach ($cfg in $extractions) {
    Write-Host ""
    Write-Host "==> Extracting $($cfg.Title) from $($cfg.Table)..."

    $colMeta = Get-ColumnList -schema $cfg.Schema -table $cfg.TableName
    Write-Host "    columns: $($colMeta.Count)"

    $rows = Invoke-UatQuery -Database 'core' -Query "SELECT * FROM $($cfg.Table) ORDER BY $($cfg.OrderBy)"
    $rowCount = if ($null -eq $rows) { 0 } elseif ($rows -is [array]) { $rows.Count } else { 1 }
    Write-Host "    rows: $rowCount"

    $sb = New-Object System.Text.StringBuilder
    [void]$sb.AppendLine("-- ============================================")
    [void]$sb.AppendLine("-- $($cfg.Title) Export")
    [void]$sb.AppendLine("-- Source: UAT ($script:UatServer)")
    [void]$sb.AppendLine("-- Generated: $script:Timestamp")
    [void]$sb.AppendLine("-- Total Records: $rowCount")
    [void]$sb.AppendLine("-- Natural Key: $($cfg.KeyCols -join ', ')")
    [void]$sb.AppendLine("-- ============================================")
    [void]$sb.AppendLine("")

    if ($rowCount -gt 0) {
        foreach ($row in $rows) {
            [void]$sb.Append((Format-Upsert -cfg $cfg -colMeta $colMeta -row $row))
        }
    }

    $path = Join-Path $script:BaselineRoot $cfg.File
    Write-SqlFile -Path $path -Content $sb.ToString()
}

Write-Host ""
Write-Host "02_extract_control_data.ps1 complete."
