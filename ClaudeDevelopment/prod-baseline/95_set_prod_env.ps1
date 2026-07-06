# ============================================================================
# 95_set_prod_env.ps1 - Register the XMS_BI_MANAGED_PROD_* environment vars
# ============================================================================
# Run this INTERACTIVELY in a normal PowerShell window (it prompts; do not run
# it through automation). Sets User-scope environment variables matching the
# existing DEV/TEST/UAT pattern, then optionally test-connects.
#
#   cd "C:\threerocks_data\XMS BI\Release\ClaudeDevelopment\prod-baseline"
#   .\95_set_prod_env.ps1
#
# New env vars are visible to NEW processes only - open a fresh terminal
# (or restart the Claude Code session) before running 90_deploy_baseline.ps1.
# ============================================================================

$ErrorActionPreference = 'Stop'

Write-Host "=== XMS BI Prod connection setup ===" -ForegroundColor Cyan
Write-Host "Values are stored as User-scope environment variables, same as DEV/TEST/UAT."
Write-Host ""

# --- server -------------------------------------------------------------------
$server = Read-Host "Prod MI server FQDN (e.g. xms-mssqlman-ne-prod.public.<id>.database.windows.net)"
$server = $server.Trim()
if (-not $server) { throw "Server name is required." }
if ($server -notmatch '\.database\.windows\.net(,\d+)?$') {
    Write-Warning "That doesn't look like a Managed Instance FQDN (*.database.windows.net). Continuing anyway."
}
if ($server -notmatch '\.public\.') {
    Write-Warning "No '.public.' in the name - the deploy runner only auto-appends port 3342 for public endpoints. If this is a private endpoint on port 1433 that is fine; otherwise include ',<port>' explicitly."
}

# --- user ----------------------------------------------------------------------
$user = Read-Host "SQL admin login [dbadmin]"
if (-not $user.Trim()) { $user = 'dbadmin' }

# --- password (prompted without echo) ------------------------------------------
$secure = Read-Host "Password for $user" -AsSecureString
$bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
try     { $password = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr) }
finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
if (-not $password) { throw "Password is required." }

# --- store ----------------------------------------------------------------------
[Environment]::SetEnvironmentVariable('XMS_BI_MANAGED_PROD_SERVER',   $server,   'User')
[Environment]::SetEnvironmentVariable('XMS_BI_MANAGED_PROD_USER',     $user,     'User')
[Environment]::SetEnvironmentVariable('XMS_BI_MANAGED_PROD_PASSWORD', $password, 'User')
# also expose in this session so the optional test below works immediately
$env:XMS_BI_MANAGED_PROD_SERVER   = $server
$env:XMS_BI_MANAGED_PROD_USER     = $user
$env:XMS_BI_MANAGED_PROD_PASSWORD = $password

Write-Host ""
Write-Host "Stored (User scope):" -ForegroundColor Green
Write-Host "  XMS_BI_MANAGED_PROD_SERVER   = $server"
Write-Host "  XMS_BI_MANAGED_PROD_USER     = $user"
Write-Host "  XMS_BI_MANAGED_PROD_PASSWORD = ********"

# --- optional connectivity test --------------------------------------------------
$test = Read-Host "Test the connection now? [Y/n]"
if ($test -notmatch '^[nN]') {
    $srv = $server
    if ($srv -notmatch ',\d+$' -and $srv -match '\.public\.') { $srv = "$srv,3342" }
    $cs = "Server=$srv;Database=master;User Id=$user;Password=$password;TrustServerCertificate=True;Encrypt=True;Connection Timeout=20;"
    $cn = New-Object System.Data.SqlClient.SqlConnection $cs
    try {
        $cn.Open()
        $cmd = $cn.CreateCommand()
        $cmd.CommandText = "SELECT @@SERVERNAME AS srv, SERVERPROPERTY('ProductVersion') AS ver, (SELECT COUNT(*) FROM sys.databases WHERE name = 'core') AS core_exists"
        $r = $cmd.ExecuteReader(); [void]$r.Read()
        Write-Host ("CONNECTED: {0} (SQL {1}) - core DB {2}" -f $r['srv'], $r['ver'], $(if ([int]$r['core_exists'] -gt 0) {'ALREADY EXISTS'} else {'not present (fresh instance)'})) -ForegroundColor Green
        $r.Close()
    }
    catch {
        Write-Warning "Connection FAILED: $($_.Exception.Message)"
        Write-Warning "Common causes: firewall/NSG not opened for this workstation's IP; public endpoint not enabled; wrong credentials. Env vars are stored regardless - re-test after fixing."
    }
    finally { if ($cn.State -eq 'Open') { $cn.Close() } }
}

Write-Host ""
Write-Host "Done. Open a NEW terminal (or restart the Claude Code session), then run:" -ForegroundColor Cyan
Write-Host "  .\90_deploy_baseline.ps1 -Environment PROD -WhatIf"
