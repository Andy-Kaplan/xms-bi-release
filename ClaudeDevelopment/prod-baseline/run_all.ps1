# ============================================================================
# run_all.ps1 - Run all three extraction scripts in order
# ============================================================================
# After this completes, inspect releases\v1.0-baseline\ and diff against root.
# ============================================================================

. (Join-Path $PSScriptRoot '00_common.ps1')

Write-Host ""
Write-Host "======================================================================"
Write-Host " XMS BI Prod Baseline Regeneration"
Write-Host " Source: UAT ($script:UatServer)"
Write-Host " Target: $script:BaselineRoot"
Write-Host " Started: $script:Timestamp"
Write-Host "======================================================================"

& (Join-Path $PSScriptRoot '01_extract_core_ddl.ps1')
& (Join-Path $PSScriptRoot '02_extract_control_data.ps1')
& (Join-Path $PSScriptRoot '03_extract_integration_metadata.ps1')

Write-Host ""
Write-Host "======================================================================"
Write-Host " Done. Next steps:"
Write-Host "   1. Inspect $script:BaselineRoot"
Write-Host "   2. Diff against repo root: git diff --no-index . releases\v1.0-baseline\"
Write-Host "   3. Deploy to a throwaway DB to validate (see BASELINE_NOTES.md)"
Write-Host "   4. Swap into root and commit as new baseline"
Write-Host "======================================================================"
