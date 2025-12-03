# Simple Impact Viewer
# Shows what depends on a model

param(
    [string]$Model
)

# If no model specified, try to detect from current directory or ask
if (-not $Model) {
    Write-Host ""
    Write-Host "Usage: .\impact.ps1 MODEL_NAME" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Cyan
    Write-Host "  .\impact.ps1 brz_jaffle_shop_api__orders" -ForegroundColor White
    Write-Host "  .\impact.ps1 dim_customers" -ForegroundColor White
    Write-Host "  .\impact.ps1 fct_orders" -ForegroundColor White
    Write-Host ""
    exit 1
}

# Remove fhh. prefix if provided
$Model = $Model -replace "^fhh\.", ""

Write-Host ""
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host "  IMPACT ANALYSIS: $Model" -ForegroundColor Cyan
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host ""

# Get parents (what feeds into this)
Write-Host "PARENTS (what feeds INTO this model)" -ForegroundColor Yellow
Write-Host "-----------------------------------------------------------" -ForegroundColor DarkGray

$parents = dbt list --select "+$Model" --exclude "$Model" --resource-type model 2>$null |
           Where-Object { $_ -match "fhh\." }

if ($parents.Count -eq 0) {
    Write-Host "  (none - source/bronze layer)" -ForegroundColor DarkGray
} else {
    foreach ($parent in $parents) {
        $parentName = $parent -replace "fhh\.", ""
        Write-Host "  <- $parentName" -ForegroundColor Blue
    }
}
Write-Host ""

# Get children (what depends on this)
Write-Host "CHILDREN (what depends ON this model)" -ForegroundColor Magenta
Write-Host "-----------------------------------------------------------" -ForegroundColor DarkGray

$children = dbt list --select "$Model+" --exclude "$Model" --resource-type model 2>$null |
            Where-Object { $_ -match "fhh\." }

if ($children.Count -eq 0) {
    Write-Host "  (none - no downstream impact!)" -ForegroundColor Green
} else {
    foreach ($child in $children) {
        $childName = $child -replace "fhh\.", ""
        Write-Host "  -> $childName" -ForegroundColor Magenta
    }
}
Write-Host ""

# Show full lineage
Write-Host "FULL LINEAGE (everything in the chain)" -ForegroundColor Cyan
Write-Host "-----------------------------------------------------------" -ForegroundColor DarkGray

$fullLineage = dbt list --select "$Model+" --resource-type model 2>$null |
               Where-Object { $_ -match "fhh\." }

$foundModel = $false
foreach ($item in $fullLineage) {
    $itemName = $item -replace "fhh\.", ""

    if ($item -match $Model) {
        Write-Host "  * $itemName" -ForegroundColor Yellow -NoNewline
        Write-Host " <- YOU ARE HERE" -ForegroundColor White
        $foundModel = $true
    } elseif (-not $foundModel) {
        Write-Host "  ^ $itemName" -ForegroundColor Blue
    } else {
        Write-Host "  v $itemName" -ForegroundColor Magenta
    }
}

Write-Host ""
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host "  SUMMARY" -ForegroundColor Cyan
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host ""

if ($children.Count -eq 0) {
    Write-Host "  Good news!" -ForegroundColor Green
    Write-Host "  No downstream models depend on this" -ForegroundColor Green
    Write-Host "  Changes only affect this model" -ForegroundColor Green
    Write-Host ""
    Write-Host "  To rebuild just this model:" -ForegroundColor White
    Write-Host "    dbt run --select $Model" -ForegroundColor Cyan
} else {
    Write-Host "  Impact detected!" -ForegroundColor Yellow
    $childCount = $children.Count
    Write-Host "  $childCount downstream model(s) affected" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "  To rebuild this + all affected:" -ForegroundColor White
    Write-Host "    dbt run --select ${Model}+" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  To test everything:" -ForegroundColor White
    Write-Host "    dbt test --select ${Model}+" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host ""
