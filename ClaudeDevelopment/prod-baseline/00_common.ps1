# ============================================================================
# 00_common.ps1 - Shared helpers for the UAT baseline regeneration scripts
# ============================================================================
# Dot-source this file from 01/02/03 to get connection helpers and SMO setup.
#
# Required env vars (already present on the dev box):
#   XMS_BI_MANAGED_UAT_SERVER, XMS_BI_MANAGED_UAT_USER, XMS_BI_MANAGED_UAT_PASSWORD
#
# Dependencies: SMO assemblies (loaded by name; ship with SSMS / SQL tools).
# System.Data.SqlClient is part of the .NET Framework - no module needed.
# ============================================================================

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# --- env vars ----------------------------------------------------------------
$script:UatServer   = $env:XMS_BI_MANAGED_UAT_SERVER
$script:UatUser     = $env:XMS_BI_MANAGED_UAT_USER
$script:UatPassword = $env:XMS_BI_MANAGED_UAT_PASSWORD

if (-not $script:UatServer -or -not $script:UatUser -or -not $script:UatPassword) {
    throw "UAT credentials missing. Set XMS_BI_MANAGED_UAT_SERVER / _USER / _PASSWORD."
}

# --- assembly load -----------------------------------------------------------
# SMO is needed for table scripting. We get it by importing whichever module
# is installed (SqlServer preferred, SQLPS fallback - both load SMO from GAC).
# System.Data.SqlClient is part of the .NET Framework - no module needed.
$smoLoaded = $false
if (Get-Module -ListAvailable -Name SqlServer) {
    Import-Module SqlServer -DisableNameChecking -WarningAction SilentlyContinue
    $smoLoaded = $true
}
elseif (Get-Module -ListAvailable -Name SQLPS) {
    # SQLPS changes CWD on import - capture and restore
    Push-Location
    try { Import-Module SQLPS -DisableNameChecking -WarningAction SilentlyContinue }
    finally { Pop-Location }
    $smoLoaded = $true
}
if (-not $smoLoaded -or -not [System.Type]::GetType('Microsoft.SqlServer.Management.Smo.Server, Microsoft.SqlServer.Smo')) {
    throw "SMO is not available. Install SSMS (provides SQLPS) or run: Install-Module SqlServer -Scope CurrentUser -AllowClobber"
}

# --- repo paths --------------------------------------------------------------
$script:RepoRoot     = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)  # ...\Release
$script:BaselineRoot = Join-Path $script:RepoRoot 'releases\v1.0-baseline'
$script:Timestamp    = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')

function Ensure-BaselineDirs {
    $dirs = @(
        $script:BaselineRoot,
        (Join-Path $script:BaselineRoot 'NCRAloha'),
        (Join-Path $script:BaselineRoot 'MarketMan'),
        (Join-Path $script:BaselineRoot 'Growyze'),
        (Join-Path $script:BaselineRoot 'SurveyHero'),
        (Join-Path $script:BaselineRoot 'TROAP')
    )
    foreach ($d in $dirs) {
        if (-not (Test-Path $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
    }
}

# --- connection string -------------------------------------------------------
# Managed Instance public endpoints listen on 3342 (not 1433). Append the port
# if the server string doesn't already specify one.
function Get-UatConnectionString {
    param([string]$Database = 'core')
    $srv = $script:UatServer
    if ($srv -notmatch ',\d+$' -and $srv -match '\.public\.') { $srv = "$srv,3342" }
    "Server=$srv;Database=$Database;User Id=$($script:UatUser);Password=$($script:UatPassword);TrustServerCertificate=True;Encrypt=True;Connection Timeout=30;"
}

# --- query helper - returns array of PSCustomObject (one per row) ------------
function Invoke-UatQuery {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Database,
        [Parameter(Mandatory)][string]$Query,
        [int]$QueryTimeout = 600
    )
    $cn = New-Object System.Data.SqlClient.SqlConnection (Get-UatConnectionString -Database $Database)
    try {
        $cn.Open()
        $cmd = $cn.CreateCommand()
        $cmd.CommandText = $Query
        $cmd.CommandTimeout = $QueryTimeout
        $adapter = New-Object System.Data.SqlClient.SqlDataAdapter $cmd
        $dt = New-Object System.Data.DataTable
        [void]$adapter.Fill($dt)
        $rows = @()
        foreach ($r in $dt.Rows) {
            $obj = [ordered]@{}
            foreach ($col in $dt.Columns) {
                $val = $r[$col]
                if ($val -is [System.DBNull]) { $val = $null }
                $obj[$col.ColumnName] = $val
            }
            $rows += [pscustomobject]$obj
        }
        return ,$rows   # force array even for 0/1 rows
    }
    finally {
        if ($cn.State -eq 'Open') { $cn.Close() }
    }
}

# --- SMO server helper -------------------------------------------------------
function Connect-UatSmo {
    [CmdletBinding()]
    param([string]$Database = 'core')

    # Pass server/login/password strings rather than a SqlConnection object:
    # SMO 22.x (SqlServer module) is built on Microsoft.Data.SqlClient, so the
    # ServerConnection(System.Data.SqlClient.SqlConnection) overload no longer
    # binds - PowerShell silently falls back to the string overload via
    # ToString(), producing "Failed to connect to server
    # System.Data.SqlClient.SqlConnection". The string-args overload exists on
    # every SMO version.
    $srv = $script:UatServer
    if ($srv -notmatch ',\d+$' -and $srv -match '\.public\.') { $srv = "$srv,3342" }
    $serverConn = New-Object Microsoft.SqlServer.Management.Common.ServerConnection($srv, $script:UatUser, $script:UatPassword)
    $serverConn.DatabaseName = $Database
    if ($serverConn.PSObject.Properties['EncryptConnection'])      { $serverConn.EncryptConnection = $true }
    if ($serverConn.PSObject.Properties['TrustServerCertificate']) { $serverConn.TrustServerCertificate = $true }
    $server = New-Object Microsoft.SqlServer.Management.Smo.Server $serverConn
    # Force connection so SMO uses the supplied credentials
    $null = $server.ConnectionContext.ExecuteScalar("SELECT 1")
    return $server
}

# --- T-SQL string literal escape ---------------------------------------------
function ConvertTo-SqlLiteral {
    param($Value)
    if ($null -eq $Value -or $Value -is [System.DBNull]) { return 'NULL' }
    if ($Value -is [bool])    { return $(if ($Value) { '1' } else { '0' }) }
    if ($Value -is [int] -or $Value -is [long] -or $Value -is [int16] -or $Value -is [byte] -or `
        $Value -is [decimal] -or $Value -is [double] -or $Value -is [single]) {
        return $Value.ToString([System.Globalization.CultureInfo]::InvariantCulture)
    }
    if ($Value -is [datetime]) { return "'$($Value.ToString('yyyy-MM-dd HH:mm:ss.fff'))'" }
    if ($Value -is [guid])     { return "'$($Value.ToString())'" }
    if ($Value -is [byte[]])   {
        $hex = ($Value | ForEach-Object { $_.ToString('X2') }) -join ''
        return "0x$hex"
    }
    # default: treat as NVARCHAR string
    $s = [string]$Value
    return "N'" + ($s -replace "'", "''") + "'"
}

# --- write file with UTF-8 BOM (matches the existing release files) ---------
function Write-SqlFile {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Content
    )
    $dir = Split-Path -Parent $Path
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $utf8Bom = New-Object System.Text.UTF8Encoding($true)
    [System.IO.File]::WriteAllText($Path, $Content, $utf8Bom)
    $kb = [math]::Round((Get-Item $Path).Length / 1KB, 1)
    Write-Host "  wrote $Path ($kb KB)"
}

Write-Host "00_common.ps1 loaded. UAT server: $script:UatServer | Baseline root: $script:BaselineRoot"
