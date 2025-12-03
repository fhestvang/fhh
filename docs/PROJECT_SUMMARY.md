# Project Summary: dlt-dbt-jaffle-shop

## 📦 What Has Been Created

A complete, production-ready workspace for testing **dlt** (data load tool) and **dbt** (data build tool) with the **Jaffle Shop** demo dataset and **DuckDB**.

## 🏗️ Project Structure

```
dlt-dbt-jaffle-shop/
├── 📋 Configuration & Setup
│   ├── .env.example              # Environment variables template
│   ├── pyproject.toml            # Python dependencies (uv)
│   ├── Dockerfile                # Docker image configuration
│   ├── docker-compose.yml        # Docker Compose setup
│   └── .devcontainer/            # VS Code Dev Container config
│
├── 🔧 Claude Code Integration
│   └── .claude/
│       ├── claude.md             # Project documentation for Claude
│       └── mcp.json              # Git MCP server configuration
│
├── 📊 Data Pipeline
│   ├── dlt_pipelines/            # Data loading (Extract & Load)
│   │   ├── jaffle_shop_pipeline.py
│   │   └── .dlt/config.toml
│   │
│   └── dbt_project/              # Data transformation (Transform)
│       ├── dbt_project.yml
│       ├── profiles.yml.example
│       └── models/
│           ├── staging/          # Staging layer (views)
│           │   ├── stg_customers.sql
│           │   ├── stg_orders.sql
│           │   ├── stg_payments.sql
│           │   └── schema.yml
│           └── marts/            # Business logic (tables)
│               └── core/
│                   ├── customers.sql
│                   ├── orders.sql
│                   └── schema.yml
│
├── 🛠️ Utilities
│   ├── scripts/
│   │   ├── download_jaffle_data.py    # Download demo CSV files
│   │   ├── run_full_pipeline.py       # Run complete pipeline
│   │   └── reset_database.py          # Reset database state
│   └── Makefile                       # Make commands for common tasks
│
├── 📚 Documentation
│   ├── README.md                 # Main project documentation
│   ├── QUICKSTART.md            # 5-minute quick start guide
│   ├── CONTRIBUTING.md          # Contribution guidelines
│   ├── docs/
│   │   ├── ARCHITECTURE.md      # Technical architecture details
│   │   └── SETUP.md             # Detailed setup instructions
│   └── LICENSE                  # MIT License
│
└── 💾 Data
    └── data/                    # DuckDB database & CSV files
        └── .gitkeep
```

## 🎯 Key Features

### 1. **Modern Data Stack**
- **dlt**: Python-based data loading framework
- **dbt**: SQL-based data transformation framework
- **DuckDB**: Fast, embedded analytical database
- **uv**: Lightning-fast Python package manager

### 2. **Multiple Development Options**
- ✅ Local development with uv
- ✅ Docker containerization
- ✅ VS Code Dev Containers
- ✅ Cross-platform support (Windows, macOS, Linux)

### 3. **Best Practices Implementation**
- Layered data architecture (raw → staging → marts)
- Data quality tests with dbt
- Environment variable management
- Version control with Git
- Comprehensive documentation
- Helper scripts for common tasks

### 4. **Claude Code Integration**
- Git MCP server configured
- Project-specific Claude documentation
- Optimized for AI-assisted development

### 5. **Complete Documentation**
- Quick start guide (5 minutes to running pipeline)
- Detailed setup instructions
- Architecture documentation
- Contributing guidelines
- Troubleshooting guides

## 🚀 Getting Started

### Quick Start (3 commands)
```bash
cd dlt-dbt-jaffle-shop
uv sync && cp .env.example .env && cp dbt_project/profiles.yml.example dbt_project/profiles.yml
uv run python scripts/download_jaffle_data.py && uv run python scripts/run_full_pipeline.py
```

### With Makefile (Linux/macOS/WSL)
```bash
cd dlt-dbt-jaffle-shop
make install setup download-data full-pipeline
```

## 📊 Data Pipeline Flow

```
CSV Files (Jaffle Shop)
    ↓
dlt Pipeline (Extract & Load)
    ↓
DuckDB (jaffle_shop_raw schema)
    ↓
dbt Staging Models (Clean & Standardize)
    ↓
dbt Marts Models (Business Logic)
    ↓
Analytics-Ready Tables
```

### Pipeline Components

**Input Data (CSV)**:
- `raw_customers.csv` - Customer information
- `raw_orders.csv` - Order transactions
- `raw_payments.csv` - Payment details

**dlt Pipeline**:
- Loads CSVs into DuckDB
- Creates `jaffle_shop_raw` schema
- Handles schema inference and typing

**dbt Staging Layer** (Views):
- `stg_customers` - Cleaned customer data
- `stg_orders` - Cleaned order data
- `stg_payments` - Cleaned payment data with amount conversion

**dbt Marts Layer** (Tables):
- `customers` - Customer 360 view with metrics
- `orders` - Order details with payment breakdowns

## 🔧 Available Commands

### Using Helper Scripts
```bash
# Download demo data
uv run python scripts/download_jaffle_data.py

# Run complete pipeline
uv run python scripts/run_full_pipeline.py

# Reset database
uv run python scripts/reset_database.py
```

### Using Makefile
```bash
make install          # Install dependencies
make setup            # Set up environment files
make download-data    # Download demo data
make run-dlt         # Run dlt pipeline
make run-dbt         # Run dbt models
make test-dbt        # Run dbt tests
make full-pipeline   # Run complete pipeline
make reset           # Reset database
make docs            # View dbt documentation
```

### Manual Commands
```bash
# dlt pipeline
uv run python dlt_pipelines/jaffle_shop_pipeline.py

# dbt commands
cd dbt_project
uv run dbt run                    # Run all models
uv run dbt test                   # Run all tests
uv run dbt run --select staging.* # Run staging models
uv run dbt docs generate          # Generate docs
uv run dbt docs serve             # Serve docs
```

## 📁 Key Files

| File | Purpose |
|------|---------|
| [QUICKSTART.md](QUICKSTART.md) | 5-minute quick start guide |
| [README.md](README.md) | Main project documentation |
| [docs/SETUP.md](docs/SETUP.md) | Detailed setup instructions |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Architecture details |
| [pyproject.toml](pyproject.toml) | Python dependencies |
| [.claude/mcp.json](.claude/mcp.json) | MCP server configuration |
| [dlt_pipelines/jaffle_shop_pipeline.py](dlt_pipelines/jaffle_shop_pipeline.py) | dlt data loading |
| [dbt_project/models/](dbt_project/models/) | dbt transformation models |

## 🎓 Learning Resources

The project includes example implementations of:
- **dlt**: CSV ingestion, schema inference, DuckDB integration
- **dbt**: Staging models, marts, tests, documentation
- **DuckDB**: Embedded database for analytics
- **Docker**: Containerized development environment
- **uv**: Modern Python dependency management
- **MCP**: Model Context Protocol for Claude integration

## 🔍 What You Can Do Next

1. **Explore the data**:
   ```python
   import duckdb
   conn = duckdb.connect('data/jaffle_shop.duckdb')
   print(conn.execute("SELECT * FROM marts.customers LIMIT 5").fetchdf())
   ```

2. **Modify dbt models**:
   - Edit SQL files in `dbt_project/models/`
   - Run `cd dbt_project && uv run dbt run`
   - View changes in database

3. **Add new data sources**:
   - Add resources to `dlt_pipelines/jaffle_shop_pipeline.py`
   - Create corresponding dbt staging models
   - Build new mart models

4. **Connect BI tools**:
   - Point Metabase, Tableau, or Superset to `data/jaffle_shop.duckdb`
   - Query `marts.*` tables

5. **Extend the pipeline**:
   - Add incremental loading
   - Implement more complex transformations
   - Add data quality checks

## 🛡️ Best Practices Implemented

- ✅ **Separation of concerns**: Extract, Load, Transform separated
- ✅ **Layered architecture**: Raw → Staging → Marts
- ✅ **Data quality**: dbt tests for constraints
- ✅ **Documentation**: Inline docs, README, guides
- ✅ **Version control**: Git with proper .gitignore
- ✅ **Environment management**: .env files, profiles
- ✅ **Code quality**: Ruff for Python linting/formatting
- ✅ **Containerization**: Docker for reproducibility
- ✅ **Developer experience**: Multiple setup options, helper scripts

## 📈 Scalability Path

The project is designed to scale:

**Current**: Local development, demo data, single-file database
**Next**: PostgreSQL/MySQL, larger datasets, scheduled runs
**Future**: Cloud data warehouse (Snowflake/BigQuery), Airflow orchestration

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on:
- Code style
- Adding features
- Testing changes
- Submitting pull requests

## 📞 Support

- Read [QUICKSTART.md](QUICKSTART.md) for quick setup
- Check [docs/SETUP.md](docs/SETUP.md) for detailed instructions
- Review [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for technical details
- Check troubleshooting sections in documentation

## 📝 License

MIT License - See [LICENSE](LICENSE) file

---

**Project created with Claude Code**
**Ready for development, testing, and learning!**
