<#
.SYNOPSIS
    Loads demo CSV data into an XMS BI org database via bcp.

.DESCRIPTION
    Self-contained per-table loader. For each of 52 tables:
      1. Creates the staging table (all NVARCHAR columns)
      2. Bulk-loads the CSV via bcp
      3. Converts to datavault target with type casts, then drops the staging table

    This minimizes peak disk usage by only having one staging table alive at a time.

    Requires: bcp.exe, sqlcmd.exe on PATH (SQL Server command-line tools).

.PARAMETER Server
    SQL Server Managed Instance hostname (e.g. myserver.database.windows.net)

.PARAMETER DatabaseName
    Target org database name (e.g. 20260324_XMS_XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX)

.PARAMETER Username
    SQL authentication username

.PARAMETER Password
    SQL authentication password

.PARAMETER CsvPath
    Path to CSV output folder. Default: .\output

.EXAMPLE
    .\load_bcp.ps1 -Server "myserver.public.12345.database.windows.net,3342" `
                    -DatabaseName "20260324_XMS_ABC12345-1234-1234-1234-123456789ABC" `
                    -Username "admin" -Password "secret"
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$Server,

    [Parameter(Mandatory=$true)]
    [string]$DatabaseName,

    [Parameter(Mandatory=$true)]
    [string]$Username,

    [Parameter(Mandatory=$true)]
    [string]$Password,

    [string]$CsvPath = ".\output"
)

$ErrorActionPreference = "Stop"
$startTime = Get-Date

# ============================================================================
# Helpers
# ============================================================================
function Write-Phase([string]$msg) {
    Write-Host ""
    Write-Host ("=" * 70) -ForegroundColor Cyan
    Write-Host "  $msg" -ForegroundColor Cyan
    Write-Host ("=" * 70) -ForegroundColor Cyan
    Write-Host ""
}

function Write-Step([string]$msg) {
    Write-Host "  $msg" -ForegroundColor White
}

function Write-Ok([string]$msg) {
    Write-Host "  [OK] $msg" -ForegroundColor Green
}

function Write-Fail([string]$msg) {
    Write-Host "  [FAIL] $msg" -ForegroundColor Red
}

function Invoke-Sqlcmd-Safe([string]$sql, [string]$label) {
    $tempSql = [System.IO.Path]::GetTempFileName() + ".sql"
    try {
        Set-Content -Path $tempSql -Value $sql -Encoding UTF8
        $output = & sqlcmd -S $Server -d $DatabaseName -U $Username -P $Password -i $tempSql -b 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Fail "$label failed (exit code $LASTEXITCODE)"
            Write-Host ($output | Out-String) -ForegroundColor Red
            exit 1
        }
        return ($output | Out-String)
    }
    finally {
        if (Test-Path $tempSql) { Remove-Item $tempSql -Force }
    }
}

function Get-TargetRowCount([string]$dvTable) {
    $checkSql = "SET NOCOUNT ON; SELECT cnt = COUNT(*) FROM [datavault].[$dvTable];"
    $tempSql = [System.IO.Path]::GetTempFileName() + ".sql"
    try {
        Set-Content -Path $tempSql -Value $checkSql -Encoding UTF8
        $output = & sqlcmd -S $Server -d $DatabaseName -U $Username -P $Password -i $tempSql -h -1 -W 2>&1
        if ($LASTEXITCODE -eq 0) {
            $val = ($output | Out-String).Trim()
            if ($val -match '^\d+$') { return [int]$val }
        }
        return 0
    }
    finally {
        if (Test-Path $tempSql) { Remove-Item $tempSql -Force }
    }
}

# ============================================================================
# Validate prerequisites
# ============================================================================
Write-Phase "Validating prerequisites"

$bcpPath = Get-Command bcp -ErrorAction SilentlyContinue
if (-not $bcpPath) {
    Write-Fail "bcp.exe not found on PATH. Install SQL Server command-line tools."
    exit 1
}
Write-Ok "bcp found: $($bcpPath.Source)"

$sqlcmdPath = Get-Command sqlcmd -ErrorAction SilentlyContinue
if (-not $sqlcmdPath) {
    Write-Fail "sqlcmd.exe not found on PATH. Install SQL Server command-line tools."
    exit 1
}
Write-Ok "sqlcmd found: $($sqlcmdPath.Source)"

$CsvPath = Resolve-Path $CsvPath -ErrorAction SilentlyContinue
if (-not $CsvPath) {
    Write-Fail "CSV path not found: $CsvPath"
    exit 1
}
Write-Ok "CSV path: $CsvPath"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# ============================================================================
# SQL generators for common table patterns
# ============================================================================

function Get-HubCreateSql([string]$entity) {
    $lower = $entity.ToLower()
    return @"
CREATE TABLE [dbo].[stg_hub_$lower] (
    HUB_ID      NVARCHAR(64),
    SRC         NVARCHAR(255),
    IS_DELETED  NVARCHAR(5),
    LOAD_TS     NVARCHAR(50)
);
"@
}

function Get-HubConvertSql([string]$entity) {
    $upper = $entity.ToUpper()
    $lower = $entity.ToLower()
    return @"
SET NOCOUNT ON;
INSERT INTO [datavault].[HUB_$upper] (HUB_ID, SRC, IS_DELETED, LOAD_TS)
SELECT CONVERT(BINARY(32), HUB_ID, 2), SRC, CAST(IS_DELETED AS BIT), CAST(LOAD_TS AS DATETIME2)
FROM [dbo].[stg_hub_$lower];
PRINT 'Rows: ' + CAST(@@ROWCOUNT AS VARCHAR(20));
DROP TABLE [dbo].[stg_hub_$lower];
"@
}

function Get-DimSatCreateSql([string]$entity) {
    $lower = $entity.ToLower()
    $upper = $entity.ToUpper()
    return @"
CREATE TABLE [dbo].[stg_sat_$lower] (
    HUB_ID              NVARCHAR(64),
    SRC                 NVARCHAR(255),
    LOAD_TS             NVARCHAR(50),
    EFFECTIVEFROM       NVARCHAR(50),
    EFFECTIVETO         NVARCHAR(50),
    CURRENT_FLAG        NVARCHAR(5),
    IS_DELETED          NVARCHAR(5),
    ${upper}_NAME       NVARCHAR(255),
    PARENT_ID           NVARCHAR(255),
    LEVEL_NAME          NVARCHAR(50),
    BOTTOM_LEVEL        NVARCHAR(5),
    ATTR_1              NVARCHAR(255),
    ATTR_2              NVARCHAR(255),
    ATTR_3              NVARCHAR(255),
    ATTR_4              NVARCHAR(255),
    ATTR_5              NVARCHAR(255),
    ${upper}_ID         NVARCHAR(255),
    MICROSERVICE_ID     NVARCHAR(255),
    MICROSERVICE_NAME   NVARCHAR(255),
    MICROSERVICE_ID_BIN NVARCHAR(64)
);
"@
}

function Get-DimSatConvertSql([string]$entity) {
    $upper = $entity.ToUpper()
    $lower = $entity.ToLower()
    return @"
SET NOCOUNT ON;
INSERT INTO [datavault].[SAT_$upper]
    (HUB_ID, SRC, LOAD_TS, EFFECTIVEFROM, EFFECTIVETO, CURRENT_FLAG, IS_DELETED,
     ${upper}_NAME, PARENT_ID, LEVEL_NAME, BOTTOM_LEVEL, ATTR_1, ATTR_2, ATTR_3, ATTR_4, ATTR_5,
     ${upper}_ID, MICROSERVICE_ID, MICROSERVICE_NAME, MICROSERVICE_ID_BIN)
SELECT CONVERT(BINARY(32), HUB_ID, 2), SRC, CAST(LOAD_TS AS DATETIME2),
    CAST(EFFECTIVEFROM AS DATETIME2), CAST(EFFECTIVETO AS DATETIME2),
    CAST(CURRENT_FLAG AS BIT), CAST(IS_DELETED AS BIT),
    ${upper}_NAME, PARENT_ID, LEVEL_NAME, CAST(BOTTOM_LEVEL AS BIT),
    ATTR_1, ATTR_2, ATTR_3, ATTR_4, ATTR_5,
    ${upper}_ID, MICROSERVICE_ID, MICROSERVICE_NAME,
    CONVERT(BINARY(32), MICROSERVICE_ID_BIN, 2)
FROM [dbo].[stg_sat_$lower];
PRINT 'Rows: ' + CAST(@@ROWCOUNT AS VARCHAR(20));
DROP TABLE [dbo].[stg_sat_$lower];
"@
}

function Get-StdLinkCreateSql([string]$hub1, [string]$hub2) {
    $h1u = $hub1.ToUpper()
    $h2u = $hub2.ToUpper()
    $lower = ($hub1 + "_" + $hub2).ToLower()
    return @"
CREATE TABLE [dbo].[stg_lnk_$lower] (
    LNK_ID          NVARCHAR(64),
    SRC             NVARCHAR(255),
    LOAD_TS         NVARCHAR(50),
    ${h1u}_HUB_ID   NVARCHAR(64),
    ${h2u}_HUB_ID   NVARCHAR(64),
    ${h1u}_AGG      NVARCHAR(50),
    ${h2u}_AGG      NVARCHAR(50)
);
"@
}

function Get-StdLinkConvertSql([string]$hub1, [string]$hub2) {
    $h1u = $hub1.ToUpper()
    $h2u = $hub2.ToUpper()
    $upper = ($hub1 + "_" + $hub2).ToUpper()
    $lower = ($hub1 + "_" + $hub2).ToLower()
    return @"
SET NOCOUNT ON;
INSERT INTO [datavault].[LNK_$upper]
    (LNK_ID, SRC, LOAD_TS, ${h1u}_HUB_ID, ${h2u}_HUB_ID, ${h1u}_AGG, ${h2u}_AGG)
SELECT CONVERT(BINARY(32),LNK_ID,2), SRC, CAST(LOAD_TS AS DATETIME2),
    CONVERT(BINARY(32),${h1u}_HUB_ID,2), CONVERT(BINARY(32),${h2u}_HUB_ID,2),
    CAST(${h1u}_AGG AS INT), CAST(${h2u}_AGG AS INT)
FROM [dbo].[stg_lnk_$lower];
PRINT 'Rows: ' + CAST(@@ROWCOUNT AS VARCHAR(20));
DROP TABLE [dbo].[stg_lnk_$lower];
"@
}

function Get-SelfRefLinkCreateSql([string]$entity) {
    $lower = ($entity + "_" + $entity).ToLower()
    return @"
CREATE TABLE [dbo].[stg_lnk_$lower] (
    LNK_ID          NVARCHAR(64),
    SRC             NVARCHAR(255),
    LOAD_TS         NVARCHAR(50),
    PARENT_HUB_ID   NVARCHAR(64),
    CHILD_HUB_ID    NVARCHAR(64),
    PARENT_AGG      NVARCHAR(50),
    CHILD_AGG       NVARCHAR(50)
);
"@
}

function Get-SelfRefLinkConvertSql([string]$entity) {
    $upper = ($entity + "_" + $entity).ToUpper()
    $lower = ($entity + "_" + $entity).ToLower()
    return @"
SET NOCOUNT ON;
INSERT INTO [datavault].[LNK_$upper]
    (LNK_ID, SRC, LOAD_TS, PARENT_HUB_ID, CHILD_HUB_ID, PARENT_AGG, CHILD_AGG)
SELECT CONVERT(BINARY(32),LNK_ID,2), SRC, CAST(LOAD_TS AS DATETIME2),
    CONVERT(BINARY(32),PARENT_HUB_ID,2), CONVERT(BINARY(32),CHILD_HUB_ID,2),
    CAST(PARENT_AGG AS INT), CAST(CHILD_AGG AS INT)
FROM [dbo].[stg_lnk_$lower];
PRINT 'Rows: ' + CAST(@@ROWCOUNT AS VARCHAR(20));
DROP TABLE [dbo].[stg_lnk_$lower];
"@
}

# ============================================================================
# Build the table list - each entry is a hashtable with CsvFile, StgTable,
# CreateSql, ConvertSql, and Label
# ============================================================================
$allTables = @()

# --- HUBS (14) ---
$hubEntities = @('LOCATION','PRODUCT','INVITEM','SUPPLIER','EMPLOYEE','OCCASION',
                  'TENDER','TAX','REVCENTER','DISCOUNT','CUSTORDER','LINEITEM',
                  'STOCKEVENT','INVREPORT')

foreach ($e in $hubEntities) {
    $lower = $e.ToLower()
    $allTables += @{
        CsvFile    = "hub_$lower.csv"
        StgTable   = "stg_hub_$lower"
        CreateSql  = (Get-HubCreateSql $e)
        ConvertSql = (Get-HubConvertSql $e)
        Label      = "HUB_$e"
    }
}

# --- DIMENSION SATELLITES (6 standard + 2 special) ---
$dimSatEntities = @('LOCATION','PRODUCT','SUPPLIER','TENDER','TAX','DISCOUNT')

foreach ($e in $dimSatEntities) {
    $lower = $e.ToLower()
    $allTables += @{
        CsvFile    = "sat_$lower.csv"
        StgTable   = "stg_sat_$lower"
        CreateSql  = (Get-DimSatCreateSql $e)
        ConvertSql = (Get-DimSatConvertSql $e)
        Label      = "SAT_$e"
    }
}

# SAT_OCCASION - DB column is OCCASSION_ID (typo in original DDL)
$allTables += @{
    CsvFile    = "sat_occasion.csv"
    StgTable   = "stg_sat_occasion"
    CreateSql  = (Get-DimSatCreateSql 'OCCASION')
    ConvertSql = @"
SET NOCOUNT ON;
INSERT INTO [datavault].[SAT_OCCASION]
    (HUB_ID, SRC, LOAD_TS, EFFECTIVEFROM, EFFECTIVETO, CURRENT_FLAG, IS_DELETED,
     OCCASION_NAME, PARENT_ID, LEVEL_NAME, BOTTOM_LEVEL, ATTR_1, ATTR_2, ATTR_3, ATTR_4, ATTR_5,
     OCCASSION_ID, MICROSERVICE_ID, MICROSERVICE_NAME, MICROSERVICE_ID_BIN)
SELECT CONVERT(BINARY(32), HUB_ID, 2), SRC, CAST(LOAD_TS AS DATETIME2),
    CAST(EFFECTIVEFROM AS DATETIME2), CAST(EFFECTIVETO AS DATETIME2),
    CAST(CURRENT_FLAG AS BIT), CAST(IS_DELETED AS BIT),
    OCCASION_NAME, PARENT_ID, LEVEL_NAME, CAST(BOTTOM_LEVEL AS BIT),
    ATTR_1, ATTR_2, ATTR_3, ATTR_4, ATTR_5,
    OCCASION_ID, MICROSERVICE_ID, MICROSERVICE_NAME,
    CONVERT(BINARY(32), MICROSERVICE_ID_BIN, 2)
FROM [dbo].[stg_sat_occasion];
PRINT 'Rows: ' + CAST(@@ROWCOUNT AS VARCHAR(20));
DROP TABLE [dbo].[stg_sat_occasion];
"@
    Label      = "SAT_OCCASION"
}

# SAT_REVCENTER - DB column is REVC_ID (not REVCENTER_ID)
$allTables += @{
    CsvFile    = "sat_revcenter.csv"
    StgTable   = "stg_sat_revcenter"
    CreateSql  = (Get-DimSatCreateSql 'REVCENTER')
    ConvertSql = @"
SET NOCOUNT ON;
INSERT INTO [datavault].[SAT_REVCENTER]
    (HUB_ID, SRC, LOAD_TS, EFFECTIVEFROM, EFFECTIVETO, CURRENT_FLAG, IS_DELETED,
     REVC_NAME, REVC_ID, PARENT_ID, LEVEL_NAME, BOTTOM_LEVEL, ATTR_1, ATTR_2, ATTR_3, ATTR_4, ATTR_5,
     MICROSERVICE_ID, MICROSERVICE_NAME, MICROSERVICE_ID_BIN)
SELECT CONVERT(BINARY(32), HUB_ID, 2), SRC, CAST(LOAD_TS AS DATETIME2),
    CAST(EFFECTIVEFROM AS DATETIME2), CAST(EFFECTIVETO AS DATETIME2),
    CAST(CURRENT_FLAG AS BIT), CAST(IS_DELETED AS BIT),
    REVCENTER_NAME, REVCENTER_ID, PARENT_ID, LEVEL_NAME, CAST(BOTTOM_LEVEL AS BIT),
    ATTR_1, ATTR_2, ATTR_3, ATTR_4, ATTR_5,
    MICROSERVICE_ID, MICROSERVICE_NAME,
    CONVERT(BINARY(32), MICROSERVICE_ID_BIN, 2)
FROM [dbo].[stg_sat_revcenter];
PRINT 'Rows: ' + CAST(@@ROWCOUNT AS VARCHAR(20));
DROP TABLE [dbo].[stg_sat_revcenter];
"@
    Label      = "SAT_REVCENTER"
}

# --- SAT_INVITEM (dim sat + UOM column) ---
$allTables += @{
    CsvFile    = "sat_invitem.csv"
    StgTable   = "stg_sat_invitem"
    Label      = "SAT_INVITEM"
    CreateSql  = @"
CREATE TABLE [dbo].[stg_sat_invitem] (
    HUB_ID              NVARCHAR(64),
    SRC                 NVARCHAR(255),
    LOAD_TS             NVARCHAR(50),
    EFFECTIVEFROM       NVARCHAR(50),
    EFFECTIVETO         NVARCHAR(50),
    CURRENT_FLAG        NVARCHAR(5),
    IS_DELETED          NVARCHAR(5),
    INVITEM_NAME        NVARCHAR(255),
    PARENT_ID           NVARCHAR(255),
    LEVEL_NAME          NVARCHAR(50),
    BOTTOM_LEVEL        NVARCHAR(5),
    ATTR_1              NVARCHAR(255),
    ATTR_2              NVARCHAR(255),
    ATTR_3              NVARCHAR(255),
    ATTR_4              NVARCHAR(255),
    ATTR_5              NVARCHAR(255),
    UOM                 NVARCHAR(50),
    INVITEM_ID          NVARCHAR(255),
    MICROSERVICE_ID     NVARCHAR(255),
    MICROSERVICE_NAME   NVARCHAR(255),
    MICROSERVICE_ID_BIN NVARCHAR(64)
);
"@
    ConvertSql = @"
SET NOCOUNT ON;
INSERT INTO [datavault].[SAT_INVITEM]
    (HUB_ID, SRC, LOAD_TS, EFFECTIVEFROM, EFFECTIVETO, CURRENT_FLAG, IS_DELETED,
     INVITEM_NAME, PARENT_ID, LEVEL_NAME, BOTTOM_LEVEL, ATTR_1, ATTR_2, ATTR_3, ATTR_4, ATTR_5,
     INVITEM_ID, MICROSERVICE_ID, MICROSERVICE_NAME, MICROSERVICE_ID_BIN, UOM)
SELECT CONVERT(BINARY(32), HUB_ID, 2), SRC, CAST(LOAD_TS AS DATETIME2),
    CAST(EFFECTIVEFROM AS DATETIME2), CAST(EFFECTIVETO AS DATETIME2),
    CAST(CURRENT_FLAG AS BIT), CAST(IS_DELETED AS BIT),
    INVITEM_NAME, PARENT_ID, LEVEL_NAME, CAST(BOTTOM_LEVEL AS BIT),
    ATTR_1, ATTR_2, ATTR_3, ATTR_4, ATTR_5,
    INVITEM_ID, MICROSERVICE_ID, MICROSERVICE_NAME,
    CONVERT(BINARY(32), MICROSERVICE_ID_BIN, 2), UOM
FROM [dbo].[stg_sat_invitem];
PRINT 'Rows: ' + CAST(@@ROWCOUNT AS VARCHAR(20));
DROP TABLE [dbo].[stg_sat_invitem];
"@
}

# --- SAT_EMPLOYEE ---
$allTables += @{
    CsvFile    = "sat_employee.csv"
    StgTable   = "stg_sat_employee"
    Label      = "SAT_EMPLOYEE"
    CreateSql  = @"
CREATE TABLE [dbo].[stg_sat_employee] (
    HUB_ID              NVARCHAR(64),
    SRC                 NVARCHAR(255),
    LOAD_TS             NVARCHAR(50),
    EFFECTIVEFROM       NVARCHAR(50),
    EFFECTIVETO         NVARCHAR(50),
    CURRENT_FLAG        NVARCHAR(5),
    IS_DELETED          NVARCHAR(5),
    SURNAME             NVARCHAR(255),
    FIRST_NAME          NVARCHAR(255),
    MIDDLE_NAME         NVARCHAR(255),
    POST_DESC           NVARCHAR(255),
    ACTIVE_DATE         NVARCHAR(50),
    END_DATE            NVARCHAR(50),
    PAYTYPE             NVARCHAR(50),
    TRONC_OPTOUT_DATE   NVARCHAR(50),
    MICROSERVICE_ID     NVARCHAR(255),
    MICROSERVICE_NAME   NVARCHAR(255),
    MICROSERVICE_ID_BIN NVARCHAR(64)
);
"@
    ConvertSql = @"
SET NOCOUNT ON;
INSERT INTO [datavault].[SAT_EMPLOYEE]
    (HUB_ID, SRC, LOAD_TS, EFFECTIVEFROM, EFFECTIVETO, CURRENT_FLAG, IS_DELETED,
     SURNAME, FIRST_NAME, MIDDLE_NAME, POST_DESC,
     ACTIVE_DATE, END_DATE, TRONC_OPTOUT_DATE, PAYTYPE,
     MICROSERVICE_ID, MICROSERVICE_NAME, MICROSERVICE_ID_BIN)
SELECT CONVERT(BINARY(32), HUB_ID, 2), SRC, CAST(LOAD_TS AS DATETIME2),
    CAST(EFFECTIVEFROM AS DATETIME2), CAST(EFFECTIVETO AS DATETIME2),
    CAST(CURRENT_FLAG AS BIT), CAST(IS_DELETED AS BIT),
    SURNAME, FIRST_NAME, MIDDLE_NAME, POST_DESC,
    CASE WHEN NULLIF(ACTIVE_DATE, N'') IS NULL THEN NULL ELSE CAST(ACTIVE_DATE AS DECIMAL(18,2)) END,
    CASE WHEN NULLIF(END_DATE, N'') IS NULL THEN NULL ELSE CAST(END_DATE AS DECIMAL(18,2)) END,
    CASE WHEN NULLIF(TRONC_OPTOUT_DATE, N'') IS NULL THEN NULL ELSE CAST(TRONC_OPTOUT_DATE AS DATETIME2) END,
    PAYTYPE,
    MICROSERVICE_ID, MICROSERVICE_NAME, CONVERT(BINARY(32), MICROSERVICE_ID_BIN, 2)
FROM [dbo].[stg_sat_employee];
PRINT 'Rows: ' + CAST(@@ROWCOUNT AS VARCHAR(20));
DROP TABLE [dbo].[stg_sat_employee];
"@
}

# --- SAT_CUSTORDER ---
$allTables += @{
    CsvFile    = "sat_custorder.csv"
    StgTable   = "stg_sat_custorder"
    Label      = "SAT_CUSTORDER"
    CreateSql  = @"
CREATE TABLE [dbo].[stg_sat_custorder] (
    HUB_ID              NVARCHAR(64),
    SRC                 NVARCHAR(255),
    LOAD_TS             NVARCHAR(50),
    EFFECTIVEFROM       NVARCHAR(50),
    EFFECTIVETO         NVARCHAR(50),
    CURRENT_FLAG        NVARCHAR(5),
    IS_DELETED          NVARCHAR(5),
    GRAND_TOTAL         NVARCHAR(50),
    GRAND_TOTAL_SRC     NVARCHAR(50),
    DISCOUNT_GROSS      NVARCHAR(50),
    DISCOUNT_GROSS_SRC  NVARCHAR(50),
    SVC_CHARGE_TOTAL    NVARCHAR(50),
    SVC_CHARGE_TOTAL_SRC NVARCHAR(50),
    GROSS_SALES         NVARCHAR(50),
    GROSS_SALES_SRC     NVARCHAR(50),
    TAX_TOTAL           NVARCHAR(50),
    TAX_TOTAL_SRC       NVARCHAR(50),
    NET_SALES           NVARCHAR(50),
    NET_SALES_SRC       NVARCHAR(50),
    GUEST_COUNT         NVARCHAR(50),
    ITEM_COUNT          NVARCHAR(50),
    ITEM_COUNT_SRC      NVARCHAR(50),
    ORDER_COUNT         NVARCHAR(50),
    OPEN_TIME           NVARCHAR(50),
    CLOSE_TIME          NVARCHAR(50),
    ORDER_DATE          NVARCHAR(50),
    TABLE_NO            NVARCHAR(255),
    ORDER_INFO          NVARCHAR(255),
    EXTERNAL_REFERENCE  NVARCHAR(255),
    ORDER_STATUS        NVARCHAR(50),
    PAYMENT_STATUS      NVARCHAR(50),
    DISCOUNT_NET        NVARCHAR(50),
    DISCOUNT_NET_SRC    NVARCHAR(50),
    DISCOUNT_TAX        NVARCHAR(50),
    DISCOUNT_TAX_SRC    NVARCHAR(50),
    TENDERED_SALES      NVARCHAR(50),
    TRADING_DATE        NVARCHAR(50)
);
"@
    ConvertSql = @"
SET NOCOUNT ON;
INSERT INTO [datavault].[SAT_CUSTORDER]
    (HUB_ID, SRC, LOAD_TS, EFFECTIVEFROM, EFFECTIVETO, CURRENT_FLAG, IS_DELETED,
     GRAND_TOTAL, GRAND_TOTAL_SRC, DISCOUNT_GROSS, DISCOUNT_GROSS_SRC,
     SVC_CHARGE_TOTAL, SVC_CHARGE_TOTAL_SRC, GROSS_SALES, GROSS_SALES_SRC,
     TAX_TOTAL, TAX_TOTAL_SRC, NET_SALES, NET_SALES_SRC,
     GUEST_COUNT, ITEM_COUNT, ITEM_COUNT_SRC, ORDER_COUNT,
     OPEN_TIME, CLOSE_TIME, ORDER_DATE, TABLE_NO, ORDER_INFO,
     EXTERNAL_REFERENCE, ORDER_STATUS, PAYMENT_STATUS,
     DISCOUNT_NET, DISCOUNT_NET_SRC, DISCOUNT_TAX, DISCOUNT_TAX_SRC,
     TENDERED_SALES, TRADING_DATE)
SELECT CONVERT(BINARY(32), HUB_ID, 2), SRC, CAST(LOAD_TS AS DATETIME2),
    CAST(EFFECTIVEFROM AS DATETIME2), CAST(EFFECTIVETO AS DATETIME2),
    CAST(CURRENT_FLAG AS BIT), CAST(IS_DELETED AS BIT),
    CAST(GRAND_TOTAL AS DECIMAL(18,4)), CAST(GRAND_TOTAL_SRC AS DECIMAL(18,4)),
    CAST(DISCOUNT_GROSS AS DECIMAL(18,4)), CAST(DISCOUNT_GROSS_SRC AS DECIMAL(18,4)),
    CAST(SVC_CHARGE_TOTAL AS DECIMAL(18,4)), CAST(SVC_CHARGE_TOTAL_SRC AS DECIMAL(18,4)),
    CAST(GROSS_SALES AS DECIMAL(18,4)), CAST(GROSS_SALES_SRC AS DECIMAL(18,4)),
    CAST(TAX_TOTAL AS DECIMAL(18,4)), CAST(TAX_TOTAL_SRC AS DECIMAL(18,4)),
    CAST(NET_SALES AS DECIMAL(18,4)), CAST(NET_SALES_SRC AS DECIMAL(18,4)),
    CAST(GUEST_COUNT AS INT), CAST(ITEM_COUNT AS INT), CAST(ITEM_COUNT_SRC AS INT), CAST(ORDER_COUNT AS INT),
    CASE WHEN NULLIF(OPEN_TIME, N'') IS NULL THEN NULL ELSE CAST(OPEN_TIME AS DATETIME2) END,
    CASE WHEN NULLIF(CLOSE_TIME, N'') IS NULL THEN NULL ELSE CAST(CLOSE_TIME AS DATETIME2) END,
    CASE WHEN NULLIF(ORDER_DATE, N'') IS NULL THEN NULL ELSE CAST(ORDER_DATE AS DATETIME2) END,
    TABLE_NO, ORDER_INFO, EXTERNAL_REFERENCE, ORDER_STATUS, PAYMENT_STATUS,
    CAST(DISCOUNT_NET AS DECIMAL(18,4)), CAST(DISCOUNT_NET_SRC AS DECIMAL(18,4)),
    CAST(DISCOUNT_TAX AS DECIMAL(18,4)), CAST(DISCOUNT_TAX_SRC AS DECIMAL(18,4)),
    CAST(TENDERED_SALES AS DECIMAL(18,4)),
    CASE WHEN NULLIF(TRADING_DATE, N'') IS NULL THEN NULL ELSE CAST(TRADING_DATE AS DATE) END
FROM [dbo].[stg_sat_custorder];
PRINT 'Rows: ' + CAST(@@ROWCOUNT AS VARCHAR(20));
DROP TABLE [dbo].[stg_sat_custorder];
"@
}

# --- SAT_LINEITEM ---
$allTables += @{
    CsvFile    = "sat_lineitem.csv"
    StgTable   = "stg_sat_lineitem"
    Label      = "SAT_LINEITEM"
    CreateSql  = @"
CREATE TABLE [dbo].[stg_sat_lineitem] (
    HUB_ID              NVARCHAR(64),
    SRC                 NVARCHAR(255),
    LOAD_TS             NVARCHAR(50),
    EFFECTIVEFROM       NVARCHAR(50),
    EFFECTIVETO         NVARCHAR(50),
    CURRENT_FLAG        NVARCHAR(5),
    IS_DELETED          NVARCHAR(5),
    HEADER_ID           NVARCHAR(255),
    LINEITEM_TYPE       NVARCHAR(50),
    GROSS_VALUE         NVARCHAR(50),
    TAX_VALUE           NVARCHAR(50),
    NET_VALUE           NVARCHAR(50),
    QUANTITY            NVARCHAR(50),
    QUANTITY_INV        NVARCHAR(50),
    LINEITEM_TIMESTAMP  NVARCHAR(50),
    ITEM_DATE           NVARCHAR(50),
    ORDER_DATE          NVARCHAR(50),
    VOID_FLAG           NVARCHAR(5),
    LINE_ID             NVARCHAR(255),
    LINE_ORDER          NVARCHAR(50),
    TRADING_DATE        NVARCHAR(50),
    SRC_KEY             NVARCHAR(255)
);
"@
    ConvertSql = @"
SET NOCOUNT ON;
INSERT INTO [datavault].[SAT_LINEITEM]
    (HUB_ID, SRC, LOAD_TS, EFFECTIVEFROM, EFFECTIVETO, CURRENT_FLAG, IS_DELETED,
     HEADER_ID, LINEITEM_TYPE, GROSS_VALUE, TAX_VALUE, NET_VALUE,
     QUANTITY, QUANTITY_INV, LINEITEM_TIMESTAMP, ITEM_DATE, ORDER_DATE,
     VOID_FLAG, LINE_ID, LINE_ORDER, TRADING_DATE, SRC_KEY)
SELECT CONVERT(BINARY(32), HUB_ID, 2), SRC, CAST(LOAD_TS AS DATETIME2),
    CAST(EFFECTIVEFROM AS DATETIME2), CAST(EFFECTIVETO AS DATETIME2),
    CAST(CURRENT_FLAG AS BIT), CAST(IS_DELETED AS BIT),
    HEADER_ID, LINEITEM_TYPE,
    CAST(GROSS_VALUE AS DECIMAL(18,4)), CAST(TAX_VALUE AS DECIMAL(18,4)), CAST(NET_VALUE AS DECIMAL(18,4)),
    CAST(QUANTITY AS DECIMAL(18,4)), CAST(QUANTITY_INV AS DECIMAL(18,4)),
    CASE WHEN NULLIF(LINEITEM_TIMESTAMP, N'') IS NULL THEN NULL ELSE CAST(LINEITEM_TIMESTAMP AS DATETIME2) END,
    CASE WHEN NULLIF(ITEM_DATE, N'') IS NULL THEN NULL ELSE CAST(ITEM_DATE AS DATE) END,
    CASE WHEN NULLIF(ORDER_DATE, N'') IS NULL THEN NULL ELSE CAST(ORDER_DATE AS DATETIME2) END,
    CAST(VOID_FLAG AS BIT), LINE_ID, CAST(LINE_ORDER AS INT),
    CASE WHEN NULLIF(TRADING_DATE, N'') IS NULL THEN NULL ELSE CAST(TRADING_DATE AS DATE) END,
    SRC_KEY
FROM [dbo].[stg_sat_lineitem];
PRINT 'Rows: ' + CAST(@@ROWCOUNT AS VARCHAR(20));
DROP TABLE [dbo].[stg_sat_lineitem];
"@
}

# --- SAT_STOCKEVENT ---
$allTables += @{
    CsvFile    = "sat_stockevent.csv"
    StgTable   = "stg_sat_stockevent"
    Label      = "SAT_STOCKEVENT"
    CreateSql  = @"
CREATE TABLE [dbo].[stg_sat_stockevent] (
    HUB_ID              NVARCHAR(64),
    SRC                 NVARCHAR(255),
    LOAD_TS             NVARCHAR(50),
    EFFECTIVEFROM       NVARCHAR(50),
    EFFECTIVETO         NVARCHAR(50),
    CURRENT_FLAG        NVARCHAR(5),
    IS_DELETED          NVARCHAR(5),
    EVENT_TYPE          NVARCHAR(50),
    EVENT_TS            NVARCHAR(50),
    PACK_DESC           NVARCHAR(255),
    PACK_QUANTITY       NVARCHAR(50),
    UOM                 NVARCHAR(50),
    UOM_QUANITY         NVARCHAR(50),
    EXTERNAL_REF        NVARCHAR(255),
    INTERNAL_REF        NVARCHAR(255),
    EVENT_BEHAVIOUR     NVARCHAR(10)
);
"@
    ConvertSql = @"
SET NOCOUNT ON;
INSERT INTO [datavault].[SAT_STOCKEVENT]
    (HUB_ID, SRC, LOAD_TS, EFFECTIVEFROM, EFFECTIVETO, CURRENT_FLAG, IS_DELETED,
     EVENT_TYPE, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, UOM_QUANITY,
     EXTERNAL_REF, INTERNAL_REF, EVENT_BEHAVIOUR)
SELECT CONVERT(BINARY(32), HUB_ID, 2), SRC, CAST(LOAD_TS AS DATETIME2),
    CAST(EFFECTIVEFROM AS DATETIME2), CAST(EFFECTIVETO AS DATETIME2),
    CAST(CURRENT_FLAG AS BIT), CAST(IS_DELETED AS BIT),
    EVENT_TYPE,
    CASE WHEN NULLIF(EVENT_TS, N'') IS NULL THEN NULL ELSE CAST(EVENT_TS AS DATETIME2) END,
    PACK_DESC, CAST(PACK_QUANTITY AS DECIMAL(18,4)), UOM, CAST(UOM_QUANITY AS DECIMAL(18,4)),
    EXTERNAL_REF, INTERNAL_REF, EVENT_BEHAVIOUR
FROM [dbo].[stg_sat_stockevent];
PRINT 'Rows: ' + CAST(@@ROWCOUNT AS VARCHAR(20));
DROP TABLE [dbo].[stg_sat_stockevent];
"@
}

# --- SAT_INVREPORT ---
$allTables += @{
    CsvFile    = "sat_invreport.csv"
    StgTable   = "stg_sat_invreport"
    Label      = "SAT_INVREPORT"
    CreateSql  = @"
CREATE TABLE [dbo].[stg_sat_invreport] (
    HUB_ID              NVARCHAR(64),
    SRC                 NVARCHAR(255),
    LOAD_TS             NVARCHAR(50),
    EFFECTIVEFROM       NVARCHAR(50),
    EFFECTIVETO         NVARCHAR(50),
    CURRENT_FLAG        NVARCHAR(5),
    IS_DELETED          NVARCHAR(5),
    THEO_USAGE          NVARCHAR(50),
    ACTUAL_USAGE        NVARCHAR(50),
    THEO_COST           NVARCHAR(50),
    ACTUAL_COST         NVARCHAR(50),
    VARIANCE_QTY        NVARCHAR(50),
    VARIANCE_VALUE      NVARCHAR(50),
    WASTE_QTY           NVARCHAR(50),
    WASTE_VALUE         NVARCHAR(50),
    REPORTING_DATE      NVARCHAR(50),
    REPORTING_UOM       NVARCHAR(50),
    UOM_COST            NVARCHAR(50),
    SALES_QTY           NVARCHAR(50),
    ORDER_QTY           NVARCHAR(50),
    TRANSFER_QTY        NVARCHAR(50),
    COUNT_FREQUENCY     NVARCHAR(50),
    COUNT_RECENCY       NVARCHAR(50)
);
"@
    ConvertSql = @"
SET NOCOUNT ON;
INSERT INTO [datavault].[SAT_INVREPORT]
    (HUB_ID, SRC, LOAD_TS, EFFECTIVEFROM, EFFECTIVETO, CURRENT_FLAG, IS_DELETED,
     THEO_USAGE, ACTUAL_USAGE, THEO_COST, ACTUAL_COST,
     VARIANCE_QTY, VARIANCE_VALUE, WASTE_QTY, WASTE_VALUE,
     REPORTING_DATE, REPORTING_UOM, UOM_COST,
     SALES_QTY, ORDER_QTY, TRANSFER_QTY, COUNT_FREQUENCY, COUNT_RECENCY)
SELECT CONVERT(BINARY(32), HUB_ID, 2), SRC, CAST(LOAD_TS AS DATETIME2),
    CAST(EFFECTIVEFROM AS DATETIME2), CAST(EFFECTIVETO AS DATETIME2),
    CAST(CURRENT_FLAG AS BIT), CAST(IS_DELETED AS BIT),
    CAST(THEO_USAGE AS DECIMAL(18,4)), CAST(ACTUAL_USAGE AS DECIMAL(18,4)),
    CAST(THEO_COST AS DECIMAL(18,4)), CAST(ACTUAL_COST AS DECIMAL(18,4)),
    CAST(VARIANCE_QTY AS DECIMAL(18,4)), CAST(VARIANCE_VALUE AS DECIMAL(18,4)),
    CAST(WASTE_QTY AS DECIMAL(18,4)), CAST(WASTE_VALUE AS DECIMAL(18,4)),
    CASE WHEN NULLIF(REPORTING_DATE, N'') IS NULL THEN NULL ELSE CAST(REPORTING_DATE AS DATETIME2) END,
    REPORTING_UOM, CAST(UOM_COST AS DECIMAL(18,4)),
    CAST(SALES_QTY AS DECIMAL(18,4)), CAST(ORDER_QTY AS DECIMAL(18,4)),
    CAST(TRANSFER_QTY AS DECIMAL(18,4)), CAST(COUNT_FREQUENCY AS DECIMAL(18,4)),
    CASE WHEN NULLIF(COUNT_RECENCY, N'') IS NULL THEN NULL ELSE CAST(COUNT_RECENCY AS DECIMAL(18,4)) END
FROM [dbo].[stg_sat_invreport];
PRINT 'Rows: ' + CAST(@@ROWCOUNT AS VARCHAR(20));
DROP TABLE [dbo].[stg_sat_invreport];
"@
}

# --- STANDARD LINKS (14) ---
$stdLinks = @(
    @('CUSTORDER','LOCATION'),
    @('CUSTORDER','EMPLOYEE'),
    @('CUSTORDER','LINEITEM'),
    @('CUSTORDER','OCCASION'),
    @('CUSTORDER','REVCENTER'),
    @('LINEITEM','PRODUCT'),
    @('LINEITEM','TAX'),
    @('LINEITEM','OCCASION'),
    @('EMPLOYEE','LINEITEM'),
    @('DISCOUNT','LINEITEM'),
    @('INVITEM','STOCKEVENT'),
    @('LOCATION','STOCKEVENT'),
    @('INVITEM','INVREPORT'),
    @('INVREPORT','LOCATION')
)

foreach ($pair in $stdLinks) {
    $h1 = $pair[0]
    $h2 = $pair[1]
    $lower = ($h1 + "_" + $h2).ToLower()
    $upper = ($h1 + "_" + $h2).ToUpper()
    $allTables += @{
        CsvFile    = "lnk_$lower.csv"
        StgTable   = "stg_lnk_$lower"
        CreateSql  = (Get-StdLinkCreateSql $h1 $h2)
        ConvertSql = (Get-StdLinkConvertSql $h1 $h2)
        Label      = "LNK_$upper"
    }
}

# --- SELF-REF LINKS (2) ---
foreach ($e in @('LINEITEM','INVITEM')) {
    $lower = ($e + "_" + $e).ToLower()
    $upper = ($e + "_" + $e).ToUpper()
    $allTables += @{
        CsvFile    = "lnk_$lower.csv"
        StgTable   = "stg_lnk_$lower"
        CreateSql  = (Get-SelfRefLinkCreateSql $e)
        ConvertSql = (Get-SelfRefLinkConvertSql $e)
        Label      = "LNK_$upper"
    }
}

# --- MULTI-WAY LINKS (3) ---

# LNK_INVITEM_OCCASION_PRODUCT
$allTables += @{
    CsvFile    = "lnk_invitem_occasion_product.csv"
    StgTable   = "stg_lnk_invitem_occasion_product"
    Label      = "LNK_INVITEM_OCCASION_PRODUCT"
    CreateSql  = @"
CREATE TABLE [dbo].[stg_lnk_invitem_occasion_product] (
    LNK_ID          NVARCHAR(64),
    SRC             NVARCHAR(255),
    LOAD_TS         NVARCHAR(50),
    INVITEM_HUB_ID  NVARCHAR(64),
    OCCASION_HUB_ID NVARCHAR(64),
    PRODUCT_HUB_ID  NVARCHAR(64)
);
"@
    ConvertSql = @"
SET NOCOUNT ON;
INSERT INTO [datavault].[LNK_INVITEM_OCCASION_PRODUCT]
    (LNK_ID, SRC, LOAD_TS, INVITEM_HUB_ID, OCCASION_HUB_ID, PRODUCT_HUB_ID)
SELECT CONVERT(BINARY(32),LNK_ID,2), SRC, CAST(LOAD_TS AS DATETIME2),
    CONVERT(BINARY(32),INVITEM_HUB_ID,2), CONVERT(BINARY(32),OCCASION_HUB_ID,2),
    CONVERT(BINARY(32),PRODUCT_HUB_ID,2)
FROM [dbo].[stg_lnk_invitem_occasion_product];
PRINT 'Rows: ' + CAST(@@ROWCOUNT AS VARCHAR(20));
DROP TABLE [dbo].[stg_lnk_invitem_occasion_product];
"@
}

# LNK_LOCATION_OCCASION_PRODUCT
$allTables += @{
    CsvFile    = "lnk_location_occasion_product.csv"
    StgTable   = "stg_lnk_location_occasion_product"
    Label      = "LNK_LOCATION_OCCASION_PRODUCT"
    CreateSql  = @"
CREATE TABLE [dbo].[stg_lnk_location_occasion_product] (
    LNK_ID          NVARCHAR(64),
    SRC             NVARCHAR(255),
    LOAD_TS         NVARCHAR(50),
    LOCATION_HUB_ID NVARCHAR(64),
    OCCASION_HUB_ID NVARCHAR(64),
    PRODUCT_HUB_ID  NVARCHAR(64)
);
"@
    ConvertSql = @"
SET NOCOUNT ON;
INSERT INTO [datavault].[LNK_LOCATION_OCCASION_PRODUCT]
    (LNK_ID, SRC, LOAD_TS, LOCATION_HUB_ID, OCCASION_HUB_ID, PRODUCT_HUB_ID)
SELECT CONVERT(BINARY(32),LNK_ID,2), SRC, CAST(LOAD_TS AS DATETIME2),
    CONVERT(BINARY(32),LOCATION_HUB_ID,2), CONVERT(BINARY(32),OCCASION_HUB_ID,2),
    CONVERT(BINARY(32),PRODUCT_HUB_ID,2)
FROM [dbo].[stg_lnk_location_occasion_product];
PRINT 'Rows: ' + CAST(@@ROWCOUNT AS VARCHAR(20));
DROP TABLE [dbo].[stg_lnk_location_occasion_product];
"@
}

# LNK_INVITEM_LOCATION_OCCASION_PRODUCT
$allTables += @{
    CsvFile    = "lnk_invitem_location_occasion_product.csv"
    StgTable   = "stg_lnk_invitem_location_occasion_product"
    Label      = "LNK_INVITEM_LOCATION_OCCASION_PRODUCT"
    CreateSql  = @"
CREATE TABLE [dbo].[stg_lnk_invitem_location_occasion_product] (
    LNK_ID          NVARCHAR(64),
    SRC             NVARCHAR(255),
    LOAD_TS         NVARCHAR(50),
    INVITEM_HUB_ID  NVARCHAR(64),
    LOCATION_HUB_ID NVARCHAR(64),
    OCCASION_HUB_ID NVARCHAR(64),
    PRODUCT_HUB_ID  NVARCHAR(64)
);
"@
    ConvertSql = @"
SET NOCOUNT ON;
INSERT INTO [datavault].[LNK_INVITEM_LOCATION_OCCASION_PRODUCT]
    (LNK_ID, SRC, LOAD_TS, INVITEM_HUB_ID, LOCATION_HUB_ID, OCCASION_HUB_ID, PRODUCT_HUB_ID)
SELECT CONVERT(BINARY(32),LNK_ID,2), SRC, CAST(LOAD_TS AS DATETIME2),
    CONVERT(BINARY(32),INVITEM_HUB_ID,2), CONVERT(BINARY(32),LOCATION_HUB_ID,2),
    CONVERT(BINARY(32),OCCASION_HUB_ID,2), CONVERT(BINARY(32),PRODUCT_HUB_ID,2)
FROM [dbo].[stg_lnk_invitem_location_occasion_product];
PRINT 'Rows: ' + CAST(@@ROWCOUNT AS VARCHAR(20));
DROP TABLE [dbo].[stg_lnk_invitem_location_occasion_product];
"@
}

# --- LINK SATELLITES (5) ---

# SAT_LNK_LINEITEM_LINEITEM
$allTables += @{
    CsvFile    = "sat_lnk_lineitem_lineitem.csv"
    StgTable   = "stg_sat_lnk_lineitem_lineitem"
    Label      = "SAT_LNK_LINEITEM_LINEITEM"
    CreateSql  = @"
CREATE TABLE [dbo].[stg_sat_lnk_lineitem_lineitem] (
    LNK_ID  NVARCHAR(64),
    SRC     NVARCHAR(255),
    LOAD_TS NVARCHAR(50),
    LABEL   NVARCHAR(255),
    VALUE   NVARCHAR(255),
    INFO    NVARCHAR(255)
);
"@
    ConvertSql = @"
SET NOCOUNT ON;
INSERT INTO [datavault].[SAT_LNK_LINEITEM_LINEITEM] (LNK_ID, SRC, LOAD_TS, LABEL, VALUE, INFO)
SELECT CONVERT(BINARY(32),LNK_ID,2), SRC, CAST(LOAD_TS AS DATETIME2), LABEL, VALUE, INFO
FROM [dbo].[stg_sat_lnk_lineitem_lineitem];
PRINT 'Rows: ' + CAST(@@ROWCOUNT AS VARCHAR(20));
DROP TABLE [dbo].[stg_sat_lnk_lineitem_lineitem];
"@
}

# SAT_LNK_INVITEM_INVITEM
$allTables += @{
    CsvFile    = "sat_lnk_invitem_invitem.csv"
    StgTable   = "stg_sat_lnk_invitem_invitem"
    Label      = "SAT_LNK_INVITEM_INVITEM"
    CreateSql  = @"
CREATE TABLE [dbo].[stg_sat_lnk_invitem_invitem] (
    LNK_ID    NVARCHAR(64),
    SRC       NVARCHAR(255),
    LOAD_TS   NVARCHAR(50),
    UOM       NVARCHAR(50),
    UOM_VALUE NVARCHAR(50)
);
"@
    ConvertSql = @"
SET NOCOUNT ON;
INSERT INTO [datavault].[SAT_LNK_INVITEM_INVITEM] (LNK_ID, SRC, LOAD_TS, UOM, UOM_VALUE)
SELECT CONVERT(BINARY(32),LNK_ID,2), SRC, CAST(LOAD_TS AS DATETIME2), UOM, CAST(UOM_VALUE AS DECIMAL(18,6))
FROM [dbo].[stg_sat_lnk_invitem_invitem];
PRINT 'Rows: ' + CAST(@@ROWCOUNT AS VARCHAR(20));
DROP TABLE [dbo].[stg_sat_lnk_invitem_invitem];
"@
}

# SAT_LNK_INVITEM_OCCASION_PRODUCT
$allTables += @{
    CsvFile    = "sat_lnk_invitem_occasion_product.csv"
    StgTable   = "stg_sat_lnk_invitem_occasion_product"
    Label      = "SAT_LNK_INVITEM_OCCASION_PRODUCT"
    CreateSql  = @"
CREATE TABLE [dbo].[stg_sat_lnk_invitem_occasion_product] (
    LNK_ID    NVARCHAR(64),
    SRC       NVARCHAR(255),
    LOAD_TS   NVARCHAR(50),
    UOM       NVARCHAR(50),
    UOM_VALUE NVARCHAR(50)
);
"@
    ConvertSql = @"
SET NOCOUNT ON;
INSERT INTO [datavault].[SAT_LNK_INVITEM_OCCASION_PRODUCT] (LNK_ID, SRC, LOAD_TS, UOM, UOM_VALUE)
SELECT CONVERT(BINARY(32),LNK_ID,2), SRC, CAST(LOAD_TS AS DATETIME2), UOM, CAST(UOM_VALUE AS DECIMAL(18,6))
FROM [dbo].[stg_sat_lnk_invitem_occasion_product];
PRINT 'Rows: ' + CAST(@@ROWCOUNT AS VARCHAR(20));
DROP TABLE [dbo].[stg_sat_lnk_invitem_occasion_product];
"@
}

# SAT_LNK_LOCATION_OCCASION_PRODUCT
$allTables += @{
    CsvFile    = "sat_lnk_location_occasion_product.csv"
    StgTable   = "stg_sat_lnk_location_occasion_product"
    Label      = "SAT_LNK_LOCATION_OCCASION_PRODUCT"
    CreateSql  = @"
CREATE TABLE [dbo].[stg_sat_lnk_location_occasion_product] (
    LNK_ID     NVARCHAR(64),
    SRC        NVARCHAR(255),
    LOAD_TS    NVARCHAR(50),
    NET_PRICE  NVARCHAR(50),
    NET_COST   NVARCHAR(50),
    PRODUCT_ID NVARCHAR(255)
);
"@
    ConvertSql = @"
SET NOCOUNT ON;
INSERT INTO [datavault].[SAT_LNK_LOCATION_OCCASION_PRODUCT] (LNK_ID, SRC, LOAD_TS, NET_PRICE, NET_COST, PRODUCT_ID)
SELECT CONVERT(BINARY(32),LNK_ID,2), SRC, CAST(LOAD_TS AS DATETIME2),
    CAST(NET_PRICE AS DECIMAL(18,4)), CAST(NET_COST AS DECIMAL(18,4)), PRODUCT_ID
FROM [dbo].[stg_sat_lnk_location_occasion_product];
PRINT 'Rows: ' + CAST(@@ROWCOUNT AS VARCHAR(20));
DROP TABLE [dbo].[stg_sat_lnk_location_occasion_product];
"@
}

# SAT_LNK_INVITEM_LOCATION_OCCASION_PRODUCT
$allTables += @{
    CsvFile    = "sat_lnk_invitem_location_occasion_product.csv"
    StgTable   = "stg_sat_lnk_invitem_location_occasion_product"
    Label      = "SAT_LNK_INVITEM_LOCATION_OCCASION_PRODUCT"
    CreateSql  = @"
CREATE TABLE [dbo].[stg_sat_lnk_invitem_location_occasion_product] (
    LNK_ID    NVARCHAR(64),
    SRC       NVARCHAR(255),
    LOAD_TS   NVARCHAR(50),
    UOM       NVARCHAR(50),
    UOM_VALUE NVARCHAR(50)
);
"@
    ConvertSql = @"
SET NOCOUNT ON;
INSERT INTO [datavault].[SAT_LNK_INVITEM_LOCATION_OCCASION_PRODUCT] (LNK_ID, SRC, LOAD_TS, UOM, UOM_VALUE)
SELECT CONVERT(BINARY(32),LNK_ID,2), SRC, CAST(LOAD_TS AS DATETIME2), UOM, CAST(UOM_VALUE AS DECIMAL(18,6))
FROM [dbo].[stg_sat_lnk_invitem_location_occasion_product];
PRINT 'Rows: ' + CAST(@@ROWCOUNT AS VARCHAR(20));
DROP TABLE [dbo].[stg_sat_lnk_invitem_location_occasion_product];
"@
}

# ============================================================================
# Validate all CSV files exist
# ============================================================================
Write-Step "Checking $($allTables.Count) CSV files..."
$missing = @()
foreach ($entry in $allTables) {
    $csvFile = Join-Path $CsvPath $entry.CsvFile
    if (-not (Test-Path $csvFile)) {
        $missing += $entry.CsvFile
    }
}
if ($missing.Count -gt 0) {
    Write-Fail "Missing $($missing.Count) CSV file(s):"
    foreach ($f in $missing) {
        Write-Host "    - $f" -ForegroundColor Red
    }
    exit 1
}
Write-Ok "All $($allTables.Count) CSV files found"

# ============================================================================
# Phase 0: Drop any leftover staging tables + set GlobalParameters
# ============================================================================
Write-Phase "Phase 0: Cleanup and GlobalParameters"

Write-Step "Dropping any leftover staging tables..."
$dropSql = @"
SET NOCOUNT ON;
DECLARE @drop NVARCHAR(MAX) = N'';
SELECT @drop += 'DROP TABLE [dbo].[' + name + '];' + CHAR(10)
FROM sys.tables
WHERE schema_id = SCHEMA_ID('dbo') AND name LIKE 'stg[_]%';
IF LEN(@drop) > 0
BEGIN
    EXEC sp_executesql @drop;
    PRINT 'Dropped leftover staging tables.';
END
ELSE
    PRINT 'No leftover staging tables found.';
"@
Invoke-Sqlcmd-Safe $dropSql "Drop leftover staging tables"
Write-Ok "Cleanup complete"

Write-Step "Setting load-window parameters..."
$gpSql = @"
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
MERGE INTO [core].[GlobalParameters] AS tgt
USING (VALUES
    (N'LINEITEM_START',    N'2025-10-01', N'DATE_RANGE', N'STRING'),
    (N'LINEITEM_END',      N'2026-03-31', N'DATE_RANGE', N'STRING'),
    (N'STOCKEVENT_START',  N'2025-10-01', N'DATE_RANGE', N'STRING'),
    (N'STOCKEVENT_END',    N'2026-03-31', N'DATE_RANGE', N'STRING')
) AS src (ParameterKey, ParameterValue, Category, DataType)
ON tgt.ParameterKey = src.ParameterKey
WHEN MATCHED THEN UPDATE SET ParameterValue = src.ParameterValue
WHEN NOT MATCHED THEN INSERT (ParameterKey, ParameterValue, Category, DataType) VALUES (src.ParameterKey, src.ParameterValue, src.Category, src.DataType);
PRINT 'Load-window parameters set.';
"@
Invoke-Sqlcmd-Safe $gpSql "Set GlobalParameters"
Write-Ok "GlobalParameters set"

# ============================================================================
# Main loop: for each table, create staging -> bcp load -> convert + drop
# ============================================================================
Write-Phase "Loading $($allTables.Count) tables (per-table: create, bcp, convert, drop)"

$errDir = Join-Path $ScriptDir "bcp_errors"
if (-not (Test-Path $errDir)) {
    New-Item -ItemType Directory -Path $errDir -Force | Out-Null
}

$successCount = 0
$skippedCount = 0
$totalRows = 0
$totalFiles = $allTables.Count
$fileIndex = 0

foreach ($entry in $allTables) {
    $fileIndex++
    $tableName = $entry.StgTable
    $csvFile = Join-Path $CsvPath $entry.CsvFile
    $errFile = Join-Path $errDir "$tableName.err"
    $label = $entry.Label

    $fileSize = (Get-Item $csvFile).Length
    $fileSizeMB = [math]::Round($fileSize / 1MB, 1)

    Write-Step "[$fileIndex/$totalFiles] $label ($fileSizeMB MB)"

    # Resume logic: skip if target already has data
    $existingRows = Get-TargetRowCount $label
    if ($existingRows -gt 0) {
        Write-Host "  [SKIP] Already loaded - $existingRows rows" -ForegroundColor DarkYellow
        $skippedCount++
        $successCount++
        continue
    }

    # Step 1: Create staging table
    Invoke-Sqlcmd-Safe $entry.CreateSql "Create $tableName"

    # Step 2: bcp load
    $bcpArgs = @(
        "dbo.$tableName",
        "in",
        $csvFile,
        "-S", $Server,
        "-d", $DatabaseName,
        "-U", $Username,
        "-P", $Password,
        "-c",
        "-t", "|",
        "-r", "0x0a",
        "-F", "2",
        "-b", "5000",
        "-e", $errFile
    )

    $bcpOutput = & bcp @bcpArgs 2>&1
    $bcpExit = $LASTEXITCODE

    if ($bcpExit -ne 0) {
        Write-Fail "bcp failed for $tableName (exit code $bcpExit)"
        Write-Host ($bcpOutput | Out-String) -ForegroundColor Red
        if (Test-Path $errFile) {
            Write-Host "  Error file: $errFile" -ForegroundColor Red
        }
        Write-Fail "Stopping - referential integrity requires earlier tables to succeed."
        exit 1
    }

    # Extract row count from bcp output
    $rows = 0
    $bcpText = $bcpOutput | Out-String
    if ($bcpText -match '(\d+) rows copied') {
        $rows = [int]$Matches[1]
        $totalRows += $rows
    }

    # Clean up empty error files
    if ((Test-Path $errFile) -and (Get-Item $errFile).Length -eq 0) {
        Remove-Item $errFile -Force
    }

    # Step 3: Convert + drop staging table
    Invoke-Sqlcmd-Safe $entry.ConvertSql "Convert $tableName"

    Write-Ok "$label - $rows rows"
    $successCount++
}

# Clean up error directory if empty
$errFiles = Get-ChildItem $errDir -ErrorAction SilentlyContinue
if (-not $errFiles -or $errFiles.Count -eq 0) {
    Remove-Item $errDir -Force -ErrorAction SilentlyContinue
}

# ============================================================================
# Summary
# ============================================================================
$elapsed = (Get-Date) - $startTime

Write-Phase "Load Summary"
Write-Step "Server:       $Server"
Write-Step "Database:     $DatabaseName"
Write-Step "CSV path:     $CsvPath"
Write-Step "Files loaded: $successCount / $totalFiles (skipped: $skippedCount)"
Write-Step "Total rows:   $totalRows"
Write-Step "Elapsed:      $($elapsed.ToString('hh\:mm\:ss'))"
Write-Host ""
Write-Host "  Next steps:" -ForegroundColor Yellow
Write-Host '    1. EXEC [core].[sp_PopulateCalendar] @YearsBefore = 2, @YearsAfter = 2' -ForegroundColor Yellow
Write-Host '    2. EXEC [core].[sp_ProcessPresentation]' -ForegroundColor Yellow
Write-Host ""
