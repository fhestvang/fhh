# dbt Quick Reference

## See What Changed

```cmd
what-changed              # See modified models and impact
what-changed -ShowDiff    # See SQL changes too
```

## Run Changed Models

```cmd
# Run only models that changed + downstream
dbt run --select state:modified+ --state ./state

# Test only what changed
dbt test --select state:modified+ --state ./state
```

## Update Baseline (After Commit)

```cmd
dbt compile
copy target\manifest.json state\manifest.json
```

## Common dbt Commands

```cmd
# Run specific model and everything downstream
dbt run --select dim_customers+

# Run specific model only
dbt run --select dim_customers

# Test specific model
dbt test --select dim_customers

# Run all models
dbt run

# Test all models
dbt test

# See lineage/dependencies
dbt list --select dim_customers+
```

## Typical Workflow

1. **Make changes** to SQL files
2. **Check impact**: `what-changed`
3. **Run changed models**: `dbt run --select state:modified+ --state ./state`
4. **Test**: `dbt test --select state:modified+ --state ./state`
5. **Commit** changes
6. **Update baseline**:
   ```
   dbt compile
   copy target\manifest.json state\manifest.json
   ```

## Selection Syntax

- `model_name` - Just this model
- `model_name+` - This model + all downstream (children)
- `+model_name` - All upstream (parents) + this model
- `+model_name+` - All parents, this model, and all children
- `state:modified` - Only models that changed
- `state:modified+` - Changed models + their children
- `tag:critical` - All models with "critical" tag
- `bronze.*` - All models in bronze folder

## Troubleshooting

**"No baseline state found"**
```cmd
dbt compile
copy target\manifest.json state\manifest.json
```

**"Database locked"**
- Close any database connections (DBeaver, etc.)
- Or wait a moment and try again

**"Column not found"**
- Check your YAML tests match your SQL columns
- Run `dbt compile` to see generated SQL
