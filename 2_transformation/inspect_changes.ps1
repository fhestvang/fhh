# DBT Impact Analysis Tool
# Shows what models changed and detailed impact analysis

param(
    [switch]$ShowDiff,      # Show SQL diffs for changed files
    [switch]$Detailed       # Show detailed explanations
)

$ErrorActionPreference = "SilentlyContinue"

# Colors
function Write-Header($text) {
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  $text" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Section($text) {
    Write-Host ""
    Write-Host "[$text]" -ForegroundColor Yellow
    Write-Host "────────────────────────────────────────────────────────" -ForegroundColor DarkGray
}

# Check if state exists
if (-not (Test-Path "state\manifest.json")) {
    Write-Host ""
    Write-Host "[ERROR] No baseline state found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Run this first to create a baseline:" -ForegroundColor Yellow
    Write-Host "  dbt compile" -ForegroundColor White
    Write-Host "  copy target\manifest.json state\manifest.json" -ForegroundColor White
    Write-Host ""
    exit 1
}

Write-Header "DBT IMPACT ANALYSIS"

# Step 1: Get modified models
Write-Section "1/5 Modified Models"

$modified = dbt list --select state:modified --state ./state --resource-type model 2>$null
$modifiedList = $modified | Where-Object { $_ -match "fhh\." }

if ($modifiedList.Count -eq 0) {
    Write-Host "  ✓ No models modified" -ForegroundColor Green
} else {
    Write-Host "  ⚠ MODIFIED: $($modifiedList.Count) model(s)" -ForegroundColor Yellow
    Write-Host ""
    foreach ($model in $modifiedList) {
        $modelName = $model -replace "fhh\.", ""
        Write-Host "    • $modelName" -ForegroundColor Yellow

        if ($Detailed) {
            # Try to get model description from YAML
            $layer = $modelName -replace "__.*", ""
            Write-Host "      Layer: $layer" -ForegroundColor DarkGray
        }
    }
}

# Step 2: Get downstream impact
Write-Section "2/5 Downstream Impact"

$impact = dbt list --select state:modified+ --state ./state --resource-type model 2>$null
$impactList = $impact | Where-Object { $_ -match "fhh\." }

$downstreamList = $impactList | Where-Object { $modifiedList -notcontains $_ }

if ($downstreamList.Count -eq 0) {
    Write-Host "  ✓ No downstream models affected" -ForegroundColor Green
} else {
    Write-Host "  → DOWNSTREAM: $($downstreamList.Count) model(s) affected" -ForegroundColor Magenta
    Write-Host ""
    foreach ($model in $downstreamList) {
        $modelName = $model -replace "fhh\.", ""
        Write-Host "    → $modelName" -ForegroundColor Magenta
    }
}

# Step 3: File-level changes
Write-Section "3/5 File Changes"

$gitStatus = git status --short models/ 2>$null | Select-String "\.sql$|\.yml$"

if ($gitStatus.Count -eq 0) {
    Write-Host "  ✓ No uncommitted file changes" -ForegroundColor Green
} else {
    Write-Host ""
    foreach ($line in $gitStatus) {
        $status = $line.ToString().Substring(0, 2).Trim()
        $file = $line.ToString().Substring(3)

        switch ($status) {
            "M"  { Write-Host "    [Modified]  " -NoNewline -ForegroundColor Yellow; Write-Host $file }
            "A"  { Write-Host "    [Added]     " -NoNewline -ForegroundColor Green; Write-Host $file }
            "D"  { Write-Host "    [Deleted]   " -NoNewline -ForegroundColor Red; Write-Host $file }
            "??" { Write-Host "    [New]       " -NoNewline -ForegroundColor Cyan; Write-Host $file }
            default { Write-Host "    [$status]       " -NoNewline; Write-Host $file }
        }
    }
}

# Step 4: Show diffs if requested
if ($ShowDiff -and $gitStatus.Count -gt 0) {
    Write-Section "4/5 Code Changes (Diff)"

    $sqlFiles = $gitStatus | Where-Object { $_ -match "\.sql$" }

    if ($sqlFiles.Count -eq 0) {
        Write-Host "  (No SQL file changes to show)" -ForegroundColor DarkGray
    } else {
        foreach ($line in $sqlFiles) {
            $file = $line.ToString().Substring(3).Trim()
            Write-Host ""
            Write-Host "  File: $file" -ForegroundColor Cyan
            Write-Host "  ────────────────────────────────────" -ForegroundColor DarkGray

            $diff = git diff $file 2>$null
            if ($diff) {
                foreach ($diffLine in $diff) {
                    if ($diffLine -match "^\+\+\+|^---") {
                        # Skip file markers
                    } elseif ($diffLine -match "^@@") {
                        Write-Host "  $diffLine" -ForegroundColor DarkGray
                    } elseif ($diffLine -match "^\+") {
                        Write-Host "  $diffLine" -ForegroundColor Green
                    } elseif ($diffLine -match "^-") {
                        Write-Host "  $diffLine" -ForegroundColor Red
                    } else {
                        Write-Host "  $diffLine" -ForegroundColor DarkGray
                    }
                }
            } else {
                Write-Host "  (New file - no diff)" -ForegroundColor DarkGray
            }
        }
    }
} else {
    Write-Section "4/5 Code Changes"
    Write-Host "  ℹ Use -ShowDiff flag to see SQL changes" -ForegroundColor DarkGray
}

# Step 5: Model explanations
Write-Section "5/5 Impact Explanation"

if ($modifiedList.Count -eq 0) {
    Write-Host "  No models modified - no impact!" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "  What Changed:" -ForegroundColor White
    foreach ($model in $modifiedList) {
        $modelName = $model -replace "fhh\.", ""
        $layer = "unknown"
        $type = "model"

        # Determine layer and type
        if ($modelName -match "^brz_") { $layer = "Bronze (raw data)" }
        elseif ($modelName -match "^slv_") { $layer = "Silver (cleaned)" }
        elseif ($modelName -match "^dim_") { $layer = "Gold (dimension)"; $type = "dimension" }
        elseif ($modelName -match "^fct_") { $layer = "Gold (fact)"; $type = "fact table" }

        Write-Host ""
        Write-Host "    • $modelName" -ForegroundColor Yellow
        Write-Host "      → Layer: $layer" -ForegroundColor DarkGray
        Write-Host "      → Type: $type" -ForegroundColor DarkGray
    }

    Write-Host ""
    Write-Host "  Why It Matters:" -ForegroundColor White

    if ($downstreamList.Count -gt 0) {
        Write-Host "    → $($downstreamList.Count) downstream model(s) depend on these changes" -ForegroundColor Magenta
        Write-Host "    → They need to be rebuilt to reflect the latest data/logic" -ForegroundColor DarkGray
    } else {
        Write-Host "    → No downstream dependencies - isolated change" -ForegroundColor Green
    }
}

# Summary
Write-Header "SUMMARY"

$totalImpact = $modifiedList.Count + $downstreamList.Count

Write-Host "  Modified:   " -NoNewline -ForegroundColor White
Write-Host "$($modifiedList.Count) model(s)" -ForegroundColor Yellow

Write-Host "  Downstream: " -NoNewline -ForegroundColor White
Write-Host "$($downstreamList.Count) model(s)" -ForegroundColor Magenta

Write-Host "  Total:      " -NoNewline -ForegroundColor White
Write-Host "$totalImpact model(s) need rebuilding" -ForegroundColor Cyan

if ($totalImpact -gt 0) {
    Write-Host ""
    Write-Host "RECOMMENDED ACTIONS:" -ForegroundColor Yellow
    Write-Host "────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  1. Review changes above" -ForegroundColor White
    Write-Host ""
    Write-Host "  2. Run affected models:" -ForegroundColor White
    Write-Host "     dbt run --select state:modified+ --state ./state" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  3. Test affected models:" -ForegroundColor White
    Write-Host "     dbt test --select state:modified+ --state ./state" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  4. Update baseline after commit:" -ForegroundColor White
    Write-Host "     dbt compile" -ForegroundColor Cyan
    Write-Host "     copy target\manifest.json state\manifest.json" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "  ✓ Everything is up to date!" -ForegroundColor Green
    Write-Host "  ✓ No models need rebuilding" -ForegroundColor Green
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
