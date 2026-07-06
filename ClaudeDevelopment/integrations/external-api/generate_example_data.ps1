<#
.SYNOPSIS
  Calls the external API stored procedures (sp_Api_Get*) against the Oak & Vine UAT
  database and writes their raw tabular output as CSV files.

.DESCRIPTION
  Produces five CSVs in $OutputDir, one per result set:
    - locations.csv             (sp_Api_GetLocations)
    - catalog_products.csv      (sp_Api_GetCatalog, result set 1)
    - catalog_categories.csv    (sp_Api_GetCatalog, result set 2)
    - orders.csv                (sp_Api_GetOrders, result set 1)
    - orders_line_items.csv     (sp_Api_GetOrders, result set 2)

  Connection details are read from the same env vars used by the xms-bi-uat MCP:
    XMS_BI_MANAGED_UAT_SERVER / _USER / _PASSWORD / _PORT (defaults to 3342)

.PARAMETER LocationId
  Override which outlet is used for /catalog and /orders. Defaults to the first
  outlet returned by /locations.

.PARAMETER OrderPageSize
  Max number of orders to fetch (passed as @PageSize to sp_Api_GetOrders). Default 10.

.PARAMETER OrderWindowDays
  Size of the date window used for /orders, ending at the most recent order time.
  Default 7.

.EXAMPLE
  ./generate_example_data.ps1
  ./generate_example_data.ps1 -OutputDir ./tubr_samples -OrderPageSize 25
#>
[CmdletBinding()]
param(
    [string]$Server         = $env:XMS_BI_MANAGED_UAT_SERVER,
    [int]   $Port           = [int]($(if ($env:XMS_BI_MANAGED_UAT_PORT) { $env:XMS_BI_MANAGED_UAT_PORT } else { 3342 })),
    [string]$User           = $env:XMS_BI_MANAGED_UAT_USER,
    [string]$Password       = $env:XMS_BI_MANAGED_UAT_PASSWORD,
    [string]$Database       = '20260317_XMS_7ED2E768-0D22-F111-832F-000D3AB27D87',  # Oak & Vine UAT
    [string]$LocationId     = $null,
    [int]   $OrderPageSize  = 10,
    [int]   $OrderWindowDays = 7,
    [string]$OutputDir      = (Join-Path $PSScriptRoot 'example_output')
)

$ErrorActionPreference = 'Stop'

if (-not $Server)   { throw 'XMS_BI_MANAGED_UAT_SERVER not set and -Server not supplied.' }
if (-not $User)     { throw 'XMS_BI_MANAGED_UAT_USER not set and -User not supplied.' }
if (-not $Password) { throw 'XMS_BI_MANAGED_UAT_PASSWORD not set and -Password not supplied.' }

if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

$connString = "Server=tcp:$Server,$Port;Database=$Database;User ID=$User;Password=$Password;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

# ---------- helpers ----------

function Invoke-StoredProc {
    param([string]$ProcName, [hashtable]$Parameters = @{})

    $conn = New-Object System.Data.SqlClient.SqlConnection $connString
    $conn.Open()
    try {
        $cmd = $conn.CreateCommand()
        $cmd.CommandType = [System.Data.CommandType]::StoredProcedure
        $cmd.CommandText = $ProcName
        $cmd.CommandTimeout = 120
        foreach ($key in $Parameters.Keys) {
            $val = $Parameters[$key]
            if ($null -eq $val) { $val = [System.DBNull]::Value }
            [void]$cmd.Parameters.AddWithValue($key, $val)
        }
        $reader = $cmd.ExecuteReader()
        $resultSets = New-Object System.Collections.Generic.List[object]
        do {
            $rows = New-Object System.Collections.Generic.List[object]
            while ($reader.Read()) {
                $row = [ordered]@{}
                for ($i = 0; $i -lt $reader.FieldCount; $i++) {
                    $name = $reader.GetName($i)
                    $value = $reader.GetValue($i)
                    if ($value -is [System.DBNull]) { $value = $null }
                    elseif ($value -is [byte[]])     { $value = ($value | ForEach-Object { '{0:x2}' -f $_ }) -join '' }
                    elseif ($value -is [datetime])   { $value = $value.ToString('o') }
                    $row[$name] = $value
                }
                $rows.Add([pscustomobject]$row)
            }
            $resultSets.Add($rows.ToArray())
        } while ($reader.NextResult())
        $reader.Close()
        return ,$resultSets.ToArray()
    } finally {
        $conn.Close()
    }
}

function Write-Csv {
    param([object[]]$Rows, [string]$Path)
    if (-not $Rows -or $Rows.Count -eq 0) {
        # write an empty file so the artifact is still present
        Set-Content -Path $Path -Value '' -Encoding utf8
    } else {
        $Rows | Export-Csv -Path $Path -NoTypeInformation -Encoding utf8
    }
    Write-Host ("  written: {0}  ({1} rows)" -f $Path, $Rows.Count)
}

# ---------- /locations ----------

Write-Host "[1/3] sp_Api_GetLocations"
$locResults = Invoke-StoredProc -ProcName '[core].[sp_Api_GetLocations]'
$locations  = $locResults[0]
Write-Csv -Rows $locations -Path (Join-Path $OutputDir 'locations.csv')

if (-not $LocationId) {
    if ($locations.Count -eq 0) {
        throw 'No locations returned; cannot continue without a LocationId. Pass -LocationId to override.'
    }
    $LocationId = $locations[0].id
    Write-Host ("  using LocationId: {0} ({1})" -f $LocationId, $locations[0].name)
}

# ---------- /catalog ----------

Write-Host "[2/3] sp_Api_GetCatalog @LocationId=$LocationId"
$catResults = Invoke-StoredProc -ProcName '[core].[sp_Api_GetCatalog]' -Parameters @{ LocationId = $LocationId }
Write-Csv -Rows $catResults[0] -Path (Join-Path $OutputDir 'catalog_products.csv')
Write-Csv -Rows $catResults[1] -Path (Join-Path $OutputDir 'catalog_categories.csv')

# ---------- /orders ----------

Write-Host "[3/3] sp_Api_GetOrders"

# Find the most recent OPEN_TIME for this outlet so we hit a date window with data.
$probeConn = New-Object System.Data.SqlClient.SqlConnection $connString
$probeConn.Open()
try {
    $probeCmd = $probeConn.CreateCommand()
    $probeCmd.CommandText = @'
SELECT MAX(sc.OPEN_TIME) AS max_open
FROM [datavault].[SAT_CUSTORDER] sc
INNER JOIN [datavault].[LNK_CUSTORDER_LOCATION] lcl ON lcl.CUSTORDER_HUB_ID = sc.HUB_ID
INNER JOIN [datavault].[SAT_LOCATION] loc
    ON loc.HUB_ID = lcl.LOCATION_HUB_ID AND loc.CURRENT_FLAG = 1
WHERE sc.CURRENT_FLAG = 1 AND loc.LOCATION_ID = @LocationId
'@
    [void]$probeCmd.Parameters.AddWithValue('@LocationId', $LocationId)
    $maxOpen = $probeCmd.ExecuteScalar()
} finally {
    $probeConn.Close()
}

if (-not $maxOpen -or $maxOpen -is [System.DBNull]) {
    Write-Warning "  no orders found for $LocationId - emitting empty orders CSVs"
    Write-Csv -Rows @() -Path (Join-Path $OutputDir 'orders.csv')
    Write-Csv -Rows @() -Path (Join-Path $OutputDir 'orders_line_items.csv')
    return
}

$endDate   = ([datetime]$maxOpen).AddSeconds(1)   # exclusive upper bound, +1s so we include the latest order
$startDate = $endDate.AddDays(-$OrderWindowDays)
Write-Host ("  date window: {0:u} -> {1:u}" -f $startDate, $endDate)

$ordResults = Invoke-StoredProc -ProcName '[core].[sp_Api_GetOrders]' -Parameters @{
    LocationId = $LocationId
    StartDate  = $startDate
    EndDate    = $endDate
    PageNumber = 1
    PageSize   = $OrderPageSize
}
Write-Csv -Rows $ordResults[0] -Path (Join-Path $OutputDir 'orders.csv')
Write-Csv -Rows $ordResults[1] -Path (Join-Path $OutputDir 'orders_line_items.csv')

Write-Host ""
Write-Host "Done. Files in $OutputDir"
