# Quick Start

## Prerequisites

- Python 3.11+
- uv package manager

## Installation

### Local Development

```bash
# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh  # macOS/Linux
# OR
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"  # Windows

# Setup
make install setup download-data full-pipeline

# OR manually:
uv sync
cp config/.env.example .env
cp src/dbt_project/profiles.yml.example src/dbt_project/profiles.yml
uv run python scripts/download_jaffle_data.py
uv run python scripts/run_full_pipeline.py
```

### Docker

```bash
docker-compose -f config/docker-compose.yml up -d
docker-compose -f config/docker-compose.yml exec dlt-dbt-workspace bash

# Inside container:
cp config/.env.example .env
cp src/dbt_project/profiles.yml.example src/dbt_project/profiles.yml
uv run python scripts/download_jaffle_data.py
uv run python scripts/run_full_pipeline.py
```

## Verify

After running the pipeline:
- Database: `data/jaffle_shop.duckdb`
- Demo data: `data/raw_*.csv`

## 📊 Explore Your Data

### View dbt Documentation

```bash
cd dbt_project
uv run dbt docs serve
# Opens browser at http://localhost:8080
```

### Query with Python

```python
import duckdb

conn = duckdb.connect('data/jaffle_shop.duckdb')

# View customer summary
print(conn.execute("SELECT * FROM marts.customers LIMIT 5").fetchdf())

# View order summary
print(conn.execute("SELECT * FROM marts.orders LIMIT 5").fetchdf())

conn.close()
```

### Query with DuckDB CLI

```bash
# Install DuckDB CLI
# macOS: brew install duckdb
# Or download from https://duckdb.org

# Query your database
duckdb data/jaffle_shop.duckdb

# Example queries:
SELECT COUNT(*) FROM marts.customers;
SELECT * FROM marts.orders WHERE total_amount > 100;
```

## 🔄 Common Commands

### Using Makefile (Linux/macOS/WSL)

```bash
make download-data    # Download demo data
make run-dlt         # Run dlt pipeline
make run-dbt         # Run dbt models
make test-dbt        # Run dbt tests
make full-pipeline   # Run everything
make reset           # Reset database
make docs            # View dbt docs
```

### Using Commands Directly

```bash
# Download data
uv run python scripts/download_jaffle_data.py

# Run dlt pipeline
uv run python dlt_pipelines/jaffle_shop_pipeline.py

# Run dbt models
cd dbt_project
uv run dbt run

# Run dbt tests
uv run dbt test

# Full pipeline
uv run python scripts/run_full_pipeline.py

# Reset and start fresh
uv run python scripts/reset_database.py
```

## 🎯 Next Steps

1. **Explore the data**
   - Open `data/jaffle_shop.duckdb` in DuckDB
   - Run queries on `marts.customers` and `marts.orders`

2. **Modify dbt models**
   - Edit files in `dbt_project/models/`
   - Run `dbt run --select your_model`
   - Add tests in `schema.yml`

3. **Add new data sources**
   - Add resources to `dlt_pipelines/jaffle_shop_pipeline.py`
   - Create staging models in dbt

4. **Connect to BI tools**
   - Point Metabase, Tableau, or other tools to the DuckDB file
   - Query `marts.*` tables

5. **Read the docs**
   - [README.md](README.md) - Project overview
   - [docs/SETUP.md](docs/SETUP.md) - Detailed setup
   - [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) - Architecture details

## 🐛 Troubleshooting

### "uv command not found"
```bash
# Reinstall uv or add to PATH
# Windows: Check PowerShell installation
# macOS/Linux: source ~/.bashrc or ~/.zshrc
```

### "No module named 'dlt'"
```bash
# Ensure using uv run
uv run python dlt_pipelines/jaffle_shop_pipeline.py

# Or activate virtual environment
source .venv/bin/activate  # Linux/macOS
.venv\Scripts\activate     # Windows
```

### "DuckDB file locked"
```bash
# Close all connections and remove lock
rm data/jaffle_shop.duckdb.wal

# Or full reset
uv run python scripts/reset_database.py
```

### "CSV files not found"
```bash
# Re-download data
uv run python scripts/download_jaffle_data.py
```

## 📚 Resources

- **dlt**: https://dlthub.com/docs
- **dbt**: https://docs.getdbt.com/
- **DuckDB**: https://duckdb.org/docs/
- **uv**: https://github.com/astral-sh/uv

## 🆘 Getting Help

- Check [docs/SETUP.md](docs/SETUP.md) for detailed setup
- Review [CONTRIBUTING.md](CONTRIBUTING.md) for development guide
- Open an issue on GitHub for bugs or questions

---

**Happy Data Engineering! 🎉**
