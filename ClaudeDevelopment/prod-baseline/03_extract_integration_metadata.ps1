# ============================================================================
# 03_extract_integration_metadata.ps1 - Regenerate per-integration files
# ============================================================================
# For each integration, regenerates from UAT:
#   {Folder}/{Name}_INIT.sql      - AddIntegration call + APIEndpointDetail
#   {Folder}/{Name}_DDL.sql       - STAGE_DDL GlobalParameters upserts
#   {Folder}/{Name}_Staging.sql   - StagingControl upserts (skipped if empty)
#   {Folder}/{Name}_Mapping.sql   - EntityMappings upserts (skipped if empty)
#   {Folder}/{Name}_Final.sql     - UploadEntityMappings call
#
# All data is read from the core DB - integration metadata lives in
# core.int_{name}.{GlobalParameters|StagingControl|EntityMappings}.
# ============================================================================

. (Join-Path $PSScriptRoot '00_common.ps1')

Ensure-BaselineDirs

# ----------------------------------------------------------------------------
# Integration discovery - read live state from UAT instead of hardcoding
# ----------------------------------------------------------------------------
# Folder name = strip trailing version digits from IntegrationName.
# e.g. NCRAloha001 -> NCRAloha, MarketMan001 -> MarketMan
function Get-FolderName {
    param([string]$intName)
    return ($intName -replace '\d+$', '')
}

Write-Host "==> Discovering integrations from core.Integrations..."
$intRows = Invoke-UatQuery -Database 'core' -Query @"
SELECT IntegrationName, IntegrationDisplayName,
       LOWER(CONCAT('int_', IntegrationName)) AS SchemaName
FROM [core].[core].[Integrations]
ORDER BY IntegrationName
"@
$integrations = @()
foreach ($r in $intRows) {
    $folder = Get-FolderName $r.IntegrationName
    $integrations += @{
        Folder      = $folder
        Name        = $r.IntegrationName
        Schema      = $r.SchemaName
        DisplayName = $r.IntegrationDisplayName
    }
}
Write-Host "    discovered $($integrations.Count) integrations: $(($integrations | ForEach-Object Name) -join ', ')"

# Ensure folders exist for any newly-discovered integrations
foreach ($intg in $integrations) {
    $dir = Join-Path $script:BaselineRoot $intg.Folder
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
}

# ----------------------------------------------------------------------------
function Get-Columns {
    param([string]$schema,[string]$table)
    Invoke-UatQuery -Database 'core' -Query @"
SELECT c.name AS col_name, c.is_identity, c.is_computed
FROM sys.columns c
INNER JOIN sys.tables tb ON tb.object_id = c.object_id
INNER JOIN sys.schemas s ON s.schema_id = tb.schema_id
WHERE s.name = '$schema' AND tb.name = '$table'
ORDER BY c.column_id
"@
}

function Format-Upsert {
    param(
        [string]$table,
        [array]$colMeta,
        [string[]]$keyCols,
        [string[]]$skipCols,
        $row
    )
    $writeCols = @()
    foreach ($c in $colMeta) {
        if ($c.is_identity -or $c.is_computed) { continue }
        if ($skipCols -contains $c.col_name) { continue }
        $writeCols += $c.col_name
    }
    $whereClause = ($keyCols | ForEach-Object {
        "[$_] = $(ConvertTo-SqlLiteral $row.$_)"
    }) -join ' AND '
    $setPairs = ($writeCols | Where-Object { $keyCols -notcontains $_ } | ForEach-Object {
        "        [$_] = $(ConvertTo-SqlLiteral $row.$_)"
    }) -join ",`r`n"
    $insertCols = ($writeCols | ForEach-Object { "[$_]" }) -join ', '
    $insertVals = ($writeCols | ForEach-Object { ConvertTo-SqlLiteral $row.$_ }) -join ', '
    $idLabel = ($keyCols | ForEach-Object { "$_=$($row.$_)" }) -join ' / '

    return @"
-- $idLabel
IF EXISTS (SELECT 1 FROM $table WHERE $whereClause)
BEGIN
    UPDATE $table
    SET
$setPairs
    WHERE $whereClause;
END
ELSE
BEGIN
    INSERT INTO $table ($insertCols)
    VALUES ($insertVals);
END
GO

"@
}

# ----------------------------------------------------------------------------
# Pull the Integrations row for INIT
# ----------------------------------------------------------------------------
function Get-IntegrationRow {
    param([string]$name)
    $rows = Invoke-UatQuery -Database 'core' -Query "SELECT * FROM [core].[core].[Integrations] WHERE [IntegrationName] = '$name'"
    if (-not $rows) { return $null }
    if ($rows -is [array]) { return $rows[0] } else { return $rows }
}

function Build-InitSql {
    param([hashtable]$intg, $intRow)
    $name = $intg.Name
    $display = $intg.DisplayName

    # APIEndpointDetail may be NULL - emit only if present
    $apiBlock = ''
    if ($intRow -and $intRow.PSObject.Properties['APIEndpointDetail'] -and -not [string]::IsNullOrEmpty([string]$intRow.APIEndpointDetail)) {
        # JSON literal - replace single quotes with doubled for T-SQL
        $json = ([string]$intRow.APIEndpointDetail).Replace("'", "''")
        $apiBlock = @"

UPDATE [core].[Integrations] SET
[APIEndpointDetail] = '$json'
WHERE [IntegrationName] = N'$name';
GO

"@
    }

    return @"
-- ============================================
-- $name INIT - regenerated from UAT $script:Timestamp
-- ============================================
USE [core]
GO

DECLARE	@return_value int

EXEC	@return_value = [core].[AddIntegration]
		@IntegrationName = N'$name',
		@IntegrationDisplayName = N'$display'

SELECT	'Return Value' = @return_value

GO
$apiBlock
"@
}

function Build-FinalSql {
    param([hashtable]$intg)
    return @"
-- ============================================
-- $($intg.Name) FINAL - regenerated from UAT $script:Timestamp
-- Uploads entity mappings to the data vault load engine
-- ============================================
USE [core]
GO

DECLARE	@return_value int

EXEC	@return_value = [core].[UploadEntityMappings]
		@intSchema = N'$($intg.Schema)'

SELECT	'Return Value' = @return_value

GO
"@
}

function Build-RecordsFile {
    param(
        [string]$title,
        [string]$schema,
        [string]$intName,
        [string]$tableName,
        [string]$qualifiedTable,
        [string[]]$keyCols,
        [string[]]$skipCols,
        [string]$orderBy,
        [string]$whereClause = ''
    )
    $colMeta = Get-Columns -schema $schema -table $tableName
    if (-not $colMeta) {
        Write-Warning "    table $schema.$tableName not found"
        return $null
    }

    $where = if ([string]::IsNullOrEmpty($whereClause)) { '' } else { "WHERE $whereClause" }
    $rows = Invoke-UatQuery -Database 'core' -Query "SELECT * FROM $qualifiedTable $where ORDER BY $orderBy"
    $rowCount = if ($null -eq $rows) { 0 } elseif ($rows -is [array]) { $rows.Count } else { 1 }

    $sb = New-Object System.Text.StringBuilder
    [void]$sb.AppendLine("-- ============================================")
    [void]$sb.AppendLine("-- $title Export")
    [void]$sb.AppendLine("-- Source: UAT $qualifiedTable")
    [void]$sb.AppendLine("-- Generated: $script:Timestamp")
    [void]$sb.AppendLine("-- Total Records: $rowCount")
    [void]$sb.AppendLine("-- ============================================")
    [void]$sb.AppendLine("")

    if ($rowCount -gt 0) {
        foreach ($row in $rows) {
            [void]$sb.Append((Format-Upsert -table $qualifiedTable -colMeta $colMeta -keyCols $keyCols -skipCols $skipCols -row $row))
        }
    }

    return @{ Content = $sb.ToString(); Count = $rowCount }
}

# ----------------------------------------------------------------------------
foreach ($intg in $integrations) {
    Write-Host ""
    Write-Host "==> Integration: $($intg.Name) (schema $($intg.Schema))"

    $outDir = Join-Path $script:BaselineRoot $intg.Folder

    # --- INIT ----------------------------------------------------------------
    $intRow = Get-IntegrationRow -name $intg.Name
    if (-not $intRow) {
        Write-Warning "    no row in core.Integrations for $($intg.Name) - skipping"
        continue
    }
    Write-SqlFile -Path (Join-Path $outDir "$($intg.Name)_INIT.sql") -Content (Build-InitSql -intg $intg -intRow $intRow)

    # --- DDL (GlobalParameters STAGE_DDL) -------------------------------------
    $ddlResult = Build-RecordsFile `
        -title "STAGE_DDL Parameters" `
        -schema $intg.Schema -intName $intg.Name `
        -tableName 'GlobalParameters' `
        -qualifiedTable "[core].[$($intg.Schema)].[GlobalParameters]" `
        -keyCols @('ParameterKey','Category') `
        -skipCols @() `
        -orderBy 'ParameterKey' `
        -whereClause "Category = 'STAGE_DDL'"
    if ($ddlResult) {
        Write-Host "    DDL parameters: $($ddlResult.Count)"
        Write-SqlFile -Path (Join-Path $outDir "$($intg.Name)_DDL.sql") -Content $ddlResult.Content
    }

    # --- Staging (StagingControl) --------------------------------------------
    $stgResult = Build-RecordsFile `
        -title "Staging Control Steps" `
        -schema $intg.Schema -intName $intg.Name `
        -tableName 'StagingControl' `
        -qualifiedTable "[core].[$($intg.Schema)].[StagingControl]" `
        -keyCols @('step_name') `
        -skipCols @('id') `
        -orderBy 'tier, step_name'
    if ($stgResult) {
        Write-Host "    Staging steps: $($stgResult.Count)"
        if ($stgResult.Count -gt 0) {
            Write-SqlFile -Path (Join-Path $outDir "$($intg.Name)_Staging.sql") -Content $stgResult.Content
        } else {
            Write-Host "    (no staging steps - file not written)"
        }
    }

    # --- Mapping (EntityMappings) --------------------------------------------
    $mapResult = Build-RecordsFile `
        -title "Entity Mappings" `
        -schema $intg.Schema -intName $intg.Name `
        -tableName 'EntityMappings' `
        -qualifiedTable "[core].[$($intg.Schema)].[EntityMappings]" `
        -keyCols @('entity_name') `
        -skipCols @('id') `
        -orderBy 'entity_name'
    if ($mapResult) {
        Write-Host "    Entity mappings: $($mapResult.Count)"
        if ($mapResult.Count -gt 0) {
            Write-SqlFile -Path (Join-Path $outDir "$($intg.Name)_Mapping.sql") -Content $mapResult.Content
        } else {
            Write-Host "    (no entity mappings - file not written)"
        }
    }

    # --- Final ---------------------------------------------------------------
    Write-SqlFile -Path (Join-Path $outDir "$($intg.Name)_Final.sql") -Content (Build-FinalSql -intg $intg)
}

Write-Host ""
Write-Host "03_extract_integration_metadata.ps1 complete."
