# Architecture Documentation

## System Overview

This project implements a modern ELT (Extract, Load, Transform) data pipeline using best-in-class open-source tools.

## Architecture Diagram

```
┌─────────────────┐
│   CSV Files     │
│  (Jaffle Shop)  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   dlt Pipeline  │  ← Extract & Load
│  (Python code)  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│    DuckDB       │  ← Storage
│  (jaffle_shop   │
│   database)     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   dbt Models    │  ← Transform
│  (SQL-based)    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Analytics-     │
│  Ready Tables   │
└─────────────────┘
```

## Component Details

### 1. Data Sources

**Jaffle Shop Demo Data**
- `raw_customers.csv`: Customer master data
- `raw_orders.csv`: Order transactions
- `raw_payments.csv`: Payment details

### 2. Data Loading Layer (dlt)

**Technology**: dlt (data load tool)

**Purpose**:
- Efficiently load CSV data into DuckDB
- Handle schema inference
- Manage incremental loads (if configured)

**Configuration**:
- Pipeline definition: `dlt_pipelines/jaffle_shop_pipeline.py`
- dlt config: `dlt_pipelines/.dlt/config.toml`
- Destination: DuckDB at `data/jaffle_shop.duckdb`

**Key Features**:
- Automatic schema inference
- Type detection and conversion
- Built-in incremental loading support
- Pipeline state management

### 3. Storage Layer (DuckDB)

**Technology**: DuckDB

**Why DuckDB?**
- Embedded database (no server needed)
- Excellent analytical query performance
- SQL interface
- Small footprint
- Perfect for development and small-to-medium datasets

**Schema Organization**:
- `jaffle_shop_raw.*`: Raw data loaded by dlt
- `main.staging.*`: Staging models (views)
- `main.marts.*`: Business logic models (tables)

### 4. Transformation Layer (dbt)

**Technology**: dbt-core with dbt-duckdb adapter

**Architecture Layers**:

#### Staging Layer
- **Purpose**: Clean and standardize raw data
- **Materialization**: Views (no storage overhead)
- **Models**:
  - `stg_customers`: Rename columns, standardize format
  - `stg_orders`: Clean order data
  - `stg_payments`: Convert amounts, clean payment data

#### Marts Layer
- **Purpose**: Business logic and aggregations
- **Materialization**: Tables (optimized for queries)
- **Models**:
  - `customers`: Customer 360 view with metrics
  - `orders`: Order details with payment breakdowns

**dbt Project Structure**:
```
dbt_project/
├── dbt_project.yml          # Project configuration
├── profiles.yml             # Connection configuration
└── models/
    ├── staging/             # Staging layer
    │   ├── stg_*.sql       # Staging models
    │   └── schema.yml      # Tests & documentation
    └── marts/              # Marts layer
        └── core/           # Core business models
            ├── *.sql       # Mart models
            └── schema.yml  # Tests & documentation
```

## Data Flow

### Step 1: Data Ingestion
```python
# Run dlt pipeline
python dlt_pipelines/jaffle_shop_pipeline.py
```

1. Read CSV files from `data/` directory
2. Infer schema and types
3. Load into DuckDB `jaffle_shop_raw` schema
4. Create tables: `raw_customers`, `raw_orders`, `raw_payments`

### Step 2: Staging Transformation
```bash
# Run dbt staging models
dbt run --select staging.*
```

1. Read from `jaffle_shop_raw.*` tables
2. Apply cleaning and renaming logic
3. Create views in `staging` schema

### Step 3: Marts Transformation
```bash
# Run dbt marts models
dbt run --select marts.*
```

1. Read from staging views
2. Apply business logic and aggregations
3. Create tables in `marts` schema

### Step 4: Data Quality
```bash
# Run dbt tests
dbt test
```

1. Validate unique constraints
2. Check not-null constraints
3. Verify referential integrity

## Design Decisions

### Why dlt?
- **Modern Python API**: Easy to extend and customize
- **Schema Evolution**: Handles changes in source data
- **Built-in Best Practices**: Normalization, typing, state management
- **No External Dependencies**: Works with local files

### Why dbt?
- **SQL-Based**: Familiar to analysts and engineers
- **Version Control**: Models are code
- **Testing Framework**: Built-in data quality checks
- **Documentation**: Auto-generated from code
- **Modularity**: Easy to refactor and maintain

### Why DuckDB?
- **Zero Configuration**: No database server to manage
- **Fast**: Optimized for analytical queries
- **Portable**: Single file database
- **Compatible**: Works with standard SQL
- **Development-Friendly**: Easy to reset and test

### Layered Architecture Benefits

**Staging Layer (Views)**:
- No data duplication
- Always reflects current raw data
- Fast to rebuild
- Clear source-to-model lineage

**Marts Layer (Tables)**:
- Optimized query performance
- Pre-aggregated metrics
- Stable schema for BI tools
- Clear business logic separation

## Scalability Considerations

### Current Scale
- Dataset: Small (demo data)
- Queries: Fast (<1s)
- Storage: Minimal (<1MB)

### When to Evolve

**To PostgreSQL/MySQL**:
- Multi-user access needed
- Application integration required
- 24/7 availability needed

**To Snowflake/BigQuery**:
- Data size >100GB
- Complex analytical queries
- Multiple concurrent users
- Cloud-native requirements

**To Airflow/Prefect**:
- Complex orchestration needed
- Multiple dependencies
- Scheduling requirements
- Error handling and retries

## Development Workflow

### Local Development
```bash
# 1. Make changes to dlt pipeline or dbt models
# 2. Test dlt pipeline
uv run python dlt_pipelines/jaffle_shop_pipeline.py

# 3. Test dbt models
cd dbt_project
uv run dbt run --select <model_name>

# 4. Validate with tests
uv run dbt test --select <model_name>

# 5. Check documentation
uv run dbt docs generate
uv run dbt docs serve
```

### Docker Development
- Isolated environment
- Consistent across team
- Easy onboarding

### VS Code Dev Container
- Full IDE integration
- Extensions pre-configured
- One-click setup

## Monitoring and Observability

### dlt Monitoring
- Pipeline state in `.dlt/` directory
- Load info printed to console
- Row counts for validation

### dbt Monitoring
- `target/run_results.json`: Execution results
- `target/manifest.json`: Model metadata
- Logs in `dbt_project/logs/`

### Recommended Additions
- Add logging to dlt pipeline
- Implement dbt exposures for dashboards
- Add data freshness tests
- Set up alerts for test failures

## Security Considerations

### Current Implementation
- Local file-based database
- No network exposure
- Environment variables for configuration

### Production Recommendations
- Use secret management (e.g., AWS Secrets Manager)
- Implement row-level security if needed
- Set up database user roles and permissions
- Enable audit logging
- Encrypt database files

## Future Enhancements

1. **Incremental Loading**: Configure dlt for incremental updates
2. **Data Quality**: Add more dbt tests and custom checks
3. **Documentation**: Expand dbt model documentation
4. **CI/CD**: Add GitHub Actions for automated testing
5. **Visualization**: Connect BI tool (e.g., Metabase, Superset)
6. **Orchestration**: Add workflow scheduler (e.g., Airflow)
