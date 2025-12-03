@echo off
REM Impact Analysis Tool for dbt Changes
REM Shows what models changed and what needs to be rebuilt

echo.
echo ═══════════════════════════════════════════════════════════
echo   DBT IMPACT ANALYSIS
echo ═══════════════════════════════════════════════════════════
echo.

REM Check if state directory exists
if not exist "state\manifest.json" (
    echo [ERROR] No baseline state found!
    echo.
    echo Run this first to create a baseline:
    echo   dbt compile
    echo   copy target\manifest.json state\manifest.json
    echo.
    exit /b 1
)

echo [1/4] Checking for modified models...
echo.

REM Get list of modified models
dbt list --select state:modified --state ./state --resource-type model > .tmp_modified.txt 2>nul

REM Count modified models
for /f %%a in ('type .tmp_modified.txt ^| find /c /v ""') do set modified_count=%%a

if %modified_count%==0 (
    echo ✓ No models modified
    echo.
) else (
    echo ⚠ MODIFIED MODELS: %modified_count%
    echo ────────────────────────────────────────────────────────
    for /f "delims=" %%i in (.tmp_modified.txt) do (
        echo   • %%i
    )
    echo.
)

echo [2/4] Checking downstream impact...
echo.

REM Get full impact (modified + downstream)
dbt list --select state:modified+ --state ./state --resource-type model > .tmp_impact.txt 2>nul

REM Count total impact
for /f %%a in ('type .tmp_impact.txt ^| find /c /v ""') do set impact_count=%%a

if %impact_count%==0 (
    echo ✓ No impact
) else (
    echo ⚠ TOTAL MODELS AFFECTED: %impact_count%
    echo ────────────────────────────────────────────────────────

    REM Show all affected models
    for /f "delims=" %%i in (.tmp_impact.txt) do (
        REM Check if this is a modified model or downstream
        findstr /x "%%i" .tmp_modified.txt >nul 2>&1
        if errorlevel 1 (
            echo   → %%i  [downstream]
        ) else (
            echo   • %%i  [modified]
        )
    )
    echo.
)

echo [3/4] Generating file-level changes...
echo.

REM Show git status for SQL and YAML files
git status --short models/ 2>nul | findstr /R "\.sql$ \.yml$" > .tmp_git.txt

for /f %%a in ('type .tmp_git.txt 2^>nul ^| find /c /v ""') do set git_count=%%a

if %git_count%==0 (
    echo ✓ No uncommitted file changes
    echo.
) else (
    echo FILE CHANGES:
    echo ────────────────────────────────────────────────────────
    for /f "tokens=1,* delims= " %%a in (.tmp_git.txt) do (
        if "%%a"=="M" (
            echo   [Modified]  %%b
        ) else if "%%a"=="A" (
            echo   [Added]     %%b
        ) else if "%%a"=="D" (
            echo   [Deleted]   %%b
        ) else if "%%a"=="??" (
            echo   [New]       %%b
        ) else (
            echo   [%%a]       %%b
        )
    )
    echo.
)

echo [4/4] Summary
echo ═══════════════════════════════════════════════════════════

if %modified_count%==0 (
    if %git_count%==0 (
        echo.
        echo   ✓ Everything is up to date!
        echo   ✓ No models need rebuilding
        echo.
    ) else (
        echo.
        echo   ⚠ You have uncommitted file changes
        echo   ℹ Compile to see dbt-level changes: dbt compile
        echo.
    )
) else (
    echo.
    echo   Modified:   %modified_count% model(s^)
    echo   Downstream: %impact_count% model(s^) total
    echo.
    echo RECOMMENDED ACTIONS:
    echo ────────────────────────────────────────────────────────
    echo   1. Review changes in modified models
    echo   2. Run affected models:
    echo      dbt run --select state:modified+ --state ./state
    echo.
    echo   3. Test affected models:
    echo      dbt test --select state:modified+ --state ./state
    echo.
    echo   4. Update baseline after committing:
    echo      dbt compile
    echo      copy target\manifest.json state\manifest.json
    echo.
)

REM Cleanup temp files
del .tmp_modified.txt 2>nul
del .tmp_impact.txt 2>nul
del .tmp_git.txt 2>nul

echo ═══════════════════════════════════════════════════════════
echo.
