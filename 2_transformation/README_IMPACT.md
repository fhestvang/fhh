# Impact Analysis - Quick Guide

## The Problem You Had
"I don't know what my model changes affect downstream!"

## The Solution
```cmd
impact MODEL_NAME
```

## Examples

### Check impact of orders model:
```cmd
impact brz_jaffle_shop_api__orders
```

**Output:**
```
CHILDREN (what depends ON this model)
  -> dim_customers
  -> fct_orders

SUMMARY:
  2 downstream model(s) affected
  Run: dbt run --select brz_jaffle_shop_api__orders+
```

### Check impact of dim_customers:
```cmd
impact dim_customers
```

### Check impact of any model:
```cmd
impact fct_orders
impact dim_dates
impact slv_payments__pivoted
```

## What It Shows

1. **PARENTS** - Models that feed INTO this one
2. **CHILDREN** - Models that depend ON this one ⚠️ (this is what you care about!)
3. **FULL LINEAGE** - Complete dependency chain
4. **SUMMARY** - How many affected + exact command to run

## Quick Workflow

```cmd
# 1. Check what you're about to break
impact brz_jaffle_shop_api__orders

# 2. Make your changes to the SQL file
# (edit brz_jaffle_shop_api__orders.sql)

# 3. Run the affected models (use command from output)
dbt run --select brz_jaffle_shop_api__orders+

# 4. Test everything
dbt test --select brz_jaffle_shop_api__orders+
```

## Color Guide
- **Blue** (^) - Parent models (upstream)
- **Yellow** (*) - Current model (YOU ARE HERE)
- **Magenta** (v) - Child models (downstream) ⚠️
- **Green** - No impact!

## Pro Tip
Before editing ANY model, run `impact MODEL_NAME` to see what you'll affect!

---

## All Available Tools

| Command | What It Does |
|---------|-------------|
| `impact MODEL_NAME` | Show what depends on a specific model |
| `what-changed` | Show ALL changed models across project |
| `what-changed -ShowDiff` | Show changed models + SQL diffs |

Use `impact` when you want to check **one specific model**.
Use `what-changed` when you want to see **everything you've modified**.
