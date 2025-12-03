# Inspect Changes Tool

Quick tool to see what models you've changed and what needs to be rebuilt.

## Quick Start

```cmd
# Simple - just see what changed
what-changed

# With diffs - see actual SQL changes
what-changed -ShowDiff

# Detailed - see extra explanations
what-changed -Detailed
```

## All Usage Options

### Easy Way (Recommended)

```cmd
what-changed                    # Basic inspection
what-changed -ShowDiff          # Show SQL code changes
what-changed -Detailed          # Show extra details
what-changed -ShowDiff -Detailed  # Everything
```

### PowerShell (Same thing, longer)

```powershell
.\inspect_changes.ps1
.\inspect_changes.ps1 -ShowDiff
.\inspect_changes.ps1 -Detailed
.\inspect_changes.ps1 -ShowDiff -Detailed
```

### Batch Script (Basic version)

```cmd
inspect_changes.bat
```

## What It Shows

1. **Modified Models** - Which models have changed code
2. **Downstream Impact** - Which models depend on your changes and need rebuilding
3. **File Changes** - Git status of SQL/YAML files
4. **Code Diffs** - Actual SQL changes (with `-ShowDiff` flag)
5. **Impact Explanation** - What changed and why it matters

## Example Output

```
═══════════════════════════════════════════════════════════
  DBT IMPACT ANALYSIS
═══════════════════════════════════════════════════════════

[1/5 Modified Models]
────────────────────────────────────────────────────────
  ⚠ MODIFIED: 1 model(s)

    • brz_jaffle_shop_api__orders

[2/5 Downstream Impact]
────────────────────────────────────────────────────────
  → DOWNSTREAM: 2 model(s) affected

    → dim_customers
    → fct_orders

[5/5 Impact Explanation]
────────────────────────────────────────────────────────

  What Changed:

    • brz_jaffle_shop_api__orders
      → Layer: Bronze (raw data)
      → Type: model

  Why It Matters:
    → 2 downstream model(s) depend on these changes
    → They need to be rebuilt to reflect the latest data/logic

═══════════════════════════════════════════════════════════
  SUMMARY
═══════════════════════════════════════════════════════════

  Modified:   1 model(s)
  Downstream: 2 model(s)
  Total:      3 model(s) need rebuilding

RECOMMENDED ACTIONS:
────────────────────────────────────────────────────────

  1. Review changes above

  2. Run affected models:
     dbt run --select state:modified+ --state ./state

  3. Test affected models:
     dbt test --select state:modified+ --state ./state

  4. Update baseline after commit:
     dbt compile
     copy target\manifest.json state\manifest.json
```

## First Time Setup

Before using this tool for the first time, create a baseline:

```bash
dbt compile
copy target\manifest.json state\manifest.json
```

## After Committing Changes

Update the baseline so future comparisons work:

```bash
dbt compile
copy target\manifest.json state\manifest.json
```

## Flags (PowerShell Only)

- `-ShowDiff` - Show actual SQL code changes with colors (added lines in green, removed in red)
- `-Detailed` - Show extra details about each model (layer, description, etc.)

## Tips

- Run this BEFORE `dbt run` to see what will be affected
- Use `-ShowDiff` to review your code changes before running
- The tool uses git and dbt's state comparison to detect changes
- Green = good/no impact, Yellow = modified, Magenta = downstream impact
