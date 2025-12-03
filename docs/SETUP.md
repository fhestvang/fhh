# Setup Guide

Complete step-by-step guide to set up the dlt-dbt-jaffle-shop project.

## Prerequisites

Choose one of the following options:

### Option A: Local Development
- Python 3.11 or higher
- uv package manager
- Git

### Option B: Docker Development
- Docker Desktop
- Docker Compose

### Option C: VS Code Dev Container
- VS Code
- Docker Desktop
- "Dev Containers" extension

## Installation

### Option A: Local Development with uv

#### 1. Install uv

**macOS/Linux**:
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

**Windows**:
```powershell
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"
```

Verify installation:
```bash
uv --version
```

#### 2. Clone or Navigate to Project
```bash
cd dlt-dbt-jaffle-shop
```

#### 3. Set Up Environment Variables
```bash
# Copy example environment file
cp .env.example .env

# Edit .env if needed (defaults should work)
```

#### 4. Set Up dbt Profile
```bash
# Copy example dbt profile
cp dbt_project/profiles.yml.example dbt_project/profiles.yml

# Edit if needed (defaults should work)
```

#### 5. Install Dependencies
```bash
# Create virtual environment and install dependencies
uv sync

# For development dependencies
uv sync --extra dev
```

#### 6. Verify Installation
```bash
# Check dlt installation
uv run python -c "import dlt; print(dlt.__version__)"

# Check dbt installation
cd dbt_project
uv run dbt --version
cd ..
```

### Option B: Docker Development

#### 1. Build Docker Image
```bash
docker-compose build
```

#### 2. Start Container
```bash
docker-compose up -d
```

#### 3. Enter Container
```bash
docker-compose exec dlt-dbt-workspace bash
```

#### 4. Set Up Inside Container
```bash
# Copy environment files
cp .env.example .env
cp dbt_project/profiles.yml.example dbt_project/profiles.yml

# Dependencies are already installed via Dockerfile
```

### Option C: VS Code Dev Container

#### 1. Open Project in VS Code
```bash
code dlt-dbt-jaffle-shop
```

#### 2. Reopen in Container
- Press `F1` or `Ctrl+Shift+P` (Windows/Linux) / `Cmd+Shift+P` (macOS)
- Type "Dev Containers: Reopen in Container"
- Select the command

#### 3. Wait for Container to Build
The container will automatically:
- Build the Docker image
- Install dependencies via `uv sync`
- Set up the development environment

#### 4. Set Up Inside Container
```bash
# In VS Code terminal
cp .env.example .env
cp dbt_project/profiles.yml.example dbt_project/profiles.yml
```

## Getting the Data

The Jaffle Shop dataset needs to be downloaded before running the pipeline.

### Option 1: Use Helper Script (Recommended)

Create the download script first:

```bash
# The download script should be created
uv run python scripts/download_jaffle_data.py
```

### Option 2: Manual Download

Download CSV files from the [dbt Jaffle Shop repository](https://github.com/dbt-labs/jaffle_shop):

```bash
# Create data directory if it doesn't exist
mkdir -p data

# Download files (example using curl)
curl -o data/raw_customers.csv https://raw.githubusercontent.com/dbt-labs/jaffle_shop/main/seeds/raw_customers.csv
curl -o data/raw_orders.csv https://raw.githubusercontent.com/dbt-labs/jaffle_shop/main/seeds/raw_orders.csv
curl -o data/raw_payments.csv https://raw.githubusercontent.com/dbt-labs/jaffle_shop/main/seeds/raw_payments.csv
```

### Verify Data Files
```bash
ls -lh data/
# Should show:
# raw_customers.csv
# raw_orders.csv
# raw_payments.csv
```

## Running the Pipeline

### 1. Run dlt Pipeline

Load raw data into DuckDB:

```bash
# From project root
uv run python dlt_pipelines/jaffle_shop_pipeline.py
```

Expected output:
```
Pipeline run completed: ...
Loaded tables: {'raw_customers': 100, 'raw_orders': 99, 'raw_payments': 113}
```

Verify DuckDB file created:
```bash
ls -lh data/jaffle_shop.duckdb
```

### 2. Run dbt Models

Transform the raw data:

```bash
# Navigate to dbt project
cd dbt_project

# Run all models
uv run dbt run

# Or run specific layers
uv run dbt run --select staging.*
uv run dbt run --select marts.*

# Return to project root
cd ..
```

Expected output:
```
Running with dbt=1.7.x
Found 5 models, 10 tests, ...

Completed successfully
```

### 3. Run dbt Tests

Validate data quality:

```bash
cd dbt_project

# Run all tests
uv run dbt test

# Or test specific models
uv run dbt test --select stg_customers

cd ..
```

All tests should pass.

### 4. Generate Documentation

```bash
cd dbt_project

# Generate documentation
uv run dbt docs generate

# Serve documentation (opens in browser)
uv run dbt docs serve

cd ..
```

## Verification

### Check DuckDB Tables

Install DuckDB CLI (optional):
```bash
# macOS
brew install duckdb

# Or use Python
uv run python
```

Query the database:
```python
import duckdb

conn = duckdb.connect('data/jaffle_shop.duckdb')

# Check raw tables
print(conn.execute("SHOW TABLES FROM jaffle_shop_raw").fetchall())

# Check staging views
print(conn.execute("SELECT * FROM staging.stg_customers LIMIT 5").fetchall())

# Check marts tables
print(conn.execute("SELECT * FROM marts.customers LIMIT 5").fetchall())

conn.close()
```

### Verify File Structure

Your project should now have:
```bash
tree -L 2 -I '__pycache__|*.pyc|target|dbt_packages|logs'
```

Expected structure:
- `data/jaffle_shop.duckdb` - DuckDB database file
- `dlt_data/` - dlt pipeline state
- `dbt_project/target/` - dbt compiled models

## Common Issues

### Issue: uv sync fails

**Solution**:
```bash
# Clear uv cache
uv cache clean

# Reinstall
uv sync --reinstall
```

### Issue: dlt pipeline fails with "No module named 'dlt'"

**Solution**:
```bash
# Ensure you're using uv run
uv run python dlt_pipelines/jaffle_shop_pipeline.py

# Or activate the virtual environment
source .venv/bin/activate  # Linux/macOS
.venv\Scripts\activate     # Windows
python dlt_pipelines/jaffle_shop_pipeline.py
```

### Issue: dbt can't find profiles.yml

**Solution**:
```bash
# Ensure profiles.yml exists
cp dbt_project/profiles.yml.example dbt_project/profiles.yml

# Verify path in profiles.yml points to correct database location
```

### Issue: DuckDB file locked

**Solution**:
```bash
# Close any open DuckDB connections
# Delete the .wal file
rm data/jaffle_shop.duckdb.wal

# Or delete and recreate database
rm data/jaffle_shop.duckdb
uv run python dlt_pipelines/jaffle_shop_pipeline.py
```

### Issue: CSV files not found

**Solution**:
```bash
# Ensure files are in data/ directory
ls -la data/

# Re-download if missing
uv run python scripts/download_jaffle_data.py
```

## Next Steps

1. **Explore the data**: Query DuckDB tables
2. **Modify models**: Edit dbt SQL files
3. **Add tests**: Extend schema.yml files
4. **Create new models**: Build on top of existing marts
5. **Set up CI/CD**: Add GitHub Actions (see docs/CI_CD.md)
6. **Connect BI tool**: Integrate with Metabase, Superset, etc.

## Development Tips

### Activate Virtual Environment (Optional)
```bash
# Instead of using `uv run` every time
source .venv/bin/activate  # Linux/macOS
.venv\Scripts\activate     # Windows

# Now you can run commands directly
python dlt_pipelines/jaffle_shop_pipeline.py
dbt run
```

### Quick Reset
```bash
# Delete database and start fresh
rm data/jaffle_shop.duckdb*
rm -rf dlt_data/

# Re-run pipeline
uv run python dlt_pipelines/jaffle_shop_pipeline.py
cd dbt_project && uv run dbt run && cd ..
```

### Watch for Changes
```bash
# Install development dependencies
uv sync --extra dev

# Use dbt watch mode (if available in your version)
cd dbt_project
dbt run --watch
```

## Additional Resources

- [uv Documentation](https://github.com/astral-sh/uv)
- [dlt Documentation](https://dlthub.com/docs)
- [dbt Documentation](https://docs.getdbt.com/)
- [DuckDB Documentation](https://duckdb.org/docs/)
