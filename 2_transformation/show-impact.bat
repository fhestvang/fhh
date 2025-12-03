@echo off
REM Show impact of a specific model
REM Usage: show-impact model_name
REM Example: show-impact brz_jaffle_shop_api__orders

if "%~1"=="" (
    echo.
    echo Usage: show-impact MODEL_NAME
    echo.
    echo Example:
    echo   show-impact brz_jaffle_shop_api__orders
    echo.
    echo This will show you what depends on that model
    echo.
    exit /b 1
)

set MODEL=%~1

echo.
echo ═══════════════════════════════════════════════════════════
echo   IMPACT ANALYSIS FOR: %MODEL%
echo ═══════════════════════════════════════════════════════════
echo.

echo [1] What feeds INTO this model (parents):
echo ────────────────────────────────────────────────────────
dbt list --select +%MODEL% --exclude %MODEL% --resource-type model 2>nul
if errorlevel 1 (
    echo   (none - this is a source/bronze layer model^)
) else (
    echo.
)

echo.
echo [2] What depends ON this model (children):
echo ────────────────────────────────────────────────────────
dbt list --select %MODEL%+ --exclude %MODEL% --resource-type model 2>nul
if errorlevel 1 (
    echo   (none - nothing depends on this model^)
) else (
    echo.
)

echo.
echo [3] FULL IMPACT - everything that would need to run:
echo ────────────────────────────────────────────────────────
dbt list --select %MODEL%+ --resource-type model
echo.

echo.
echo ═══════════════════════════════════════════════════════════
echo   SUMMARY
echo ═══════════════════════════════════════════════════════════
echo.
echo If you change %MODEL%, you should run:
echo.
echo   dbt run --select %MODEL%+
echo.
echo ═══════════════════════════════════════════════════════════
echo.
