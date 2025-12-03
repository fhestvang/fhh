# dbt State Tracking Setup

This guide explains how to use dbt's state comparison to track which models have changed.

## Initial Setup (Do this once)

1. **Close DBeaver connection** to the database (if open)

2. **Compile and save baseline state:**
   ```bash
   cd 2_transformation

   # Compile all models to generate manifest.json
   dbt.bat compile

   # Create state directory if it doesn't exist
   mkdir state

   # Save the current manifest as baseline
   copy target\manifest.json state\manifest.json
   ```

## Daily Workflow

### 1. Make changes to your models
Edit any `.sql` files in the `models/` directory

### 2. See what changed
```bash
cd 2_transformation

# List all modified models (and their downstream dependencies)
dbt.bat list --select state:modified+ --state ./state

# Just show directly modified models (no downstream)
dbt.bat list --select state:modified --state ./state
```

### 3. Run only changed models
```bash
# Run modified models and everything downstream
dbt.bat run --select state:modified+ --state ./state

# Test modified models and downstream
dbt.bat test --select state:modified+ --state ./state
```

### 4. Update baseline (after committing changes)
```bash
# After you're happy with changes and have committed to git
dbt.bat compile
copy target\manifest.json state\manifest.json
```

## Common State Selectors

| Selector | Description |
|----------|-------------|
| `state:modified` | Models whose code has changed |
| `state:modified+` | Modified models + all downstream models |
| `+state:modified` | Modified models + all upstream models |
| `+state:modified+` | Modified models + all upstream + downstream |
| `state:new` | Models that don't exist in the baseline |

## Examples

### See what will run if you change orders model:
```bash
# Edit brz_jaffle_shop_api__orders.sql
# Then check impact:
dbt.bat list --select state:modified+ --state ./state
```

### Run only affected models:
```bash
dbt.bat run --select state:modified+ --state ./state
```

### Check compiled SQL differences:
```bash
# Before changes
dbt.bat compile --select brz_jaffle_shop_api__orders
type target\compiled\test_proj\models\bronze\jaffle_shop_api\brz_jaffle_shop_api__orders.sql

# Make changes to the model

# After changes - compare the compiled SQL
dbt.bat compile --select brz_jaffle_shop_api__orders
type target\compiled\test_proj\models\bronze\jaffle_shop_api\brz_jaffle_shop_api__orders.sql
```

## Tips

- **Update state after merging PRs** so your baseline stays current
- **Don't commit `target/` or `state/`** directories (already in .gitignore)
- **Use with CI/CD** to run only changed models in production
- **Combine with other selectors**: `dbt run --select state:modified+,tag:daily`

## Troubleshooting

### "Got a state selector method, but no comparison manifest"
- Make sure you've run the setup steps above
- Check that `state/manifest.json` exists
- Verify you're using `--state ./state` flag

### Database locked by DBeaver
- Close all database connections in DBeaver
- Or quit DBeaver entirely
- Then re-run dbt commands
