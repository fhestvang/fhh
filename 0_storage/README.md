# 0️⃣ Storage Layer

This folder contains all database files and data storage for the platform.

## Purpose

Centralized storage layer for all data across environments:
- **Separation of Concerns**: Storage is independent from transformation logic
- **Environment Management**: Clear separation between test and production
- **Backup & Recovery**: Single location for database backups
- **Access Control**: Easier to manage permissions and access

## Database Structure

### Production Database
- **File**: `databases/edw_prod.duckdb`
- **Purpose**: Production enterprise data warehouse
- **Schemas**:
  - `jaffle_shop_raw` - Raw data loaded by dlt (Bronze layer)
  - `bronze` - Bronze layer views
  - `silver` - Silver layer ephemeral models
  - `gold` - Gold layer business-ready tables

### Test Database
- **File**: `databases/edw_test.duckdb`
- **Purpose**: Development and testing
- **Usage**: Used by dbt `dev` target for local development

## Usage

### dlt Ingestion
```python
# Load to prod
python 1_ingestion/jaffle_shop/pipelines/jaffle_shop_pipeline.py

# Load to test
# (modify run_pipeline call to use environment="test")
```

### dbt Transformation
```bash
# Run against test database (default)
cd 2_transformation
dbt run

# Run against production
dbt run --target prod
```

## Data Flow

```
External API
    ↓
1_ingestion (dlt) → 0_storage/databases/edw_*.duckdb
    ↓
2_transformation (dbt) reads/writes from 0_storage
    ↓
3_serving reads from 0_storage
```

## Backup Strategy

- **Production**: Automated backups before each dlt run
- **Test**: No backup needed (can be regenerated)
- **Location**: `databases/backups/` (to be created)

## Security Notes

- Add `*.duckdb` to `.gitignore` (databases should not be in version control)
- Production database access should be restricted
- Use environment variables for sensitive connection strings
