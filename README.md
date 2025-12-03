# Jaffle Shop Data Platform

A modern, production-ready data platform built with **dlt** (data load tool) and **dbt** (data build tool), following the **Medallion Architecture** pattern.

## 🏗️ Project Structure

```
fhh/
├── 0_storage/              # 💾 Centralized data storage
│   └── databases/
│       ├── edw_prod.duckdb  # Production database
│       └── edw_test.duckdb  # Test/dev database
│
├── 1_ingestion/            # 📥 Data extraction & loading (dlt)
│   └── jaffle_shop/
│       └── pipelines/
│           └── jaffle_shop_pipeline.py
│
├── 2_transformation/       # ⚙️ Data transformation (dbt)
│   ├── models/
│   │   ├── bronze/         # Raw data from API
│   │   ├── silver/         # Cleaned & conformed
│   │   └── gold/           # Business-ready
│   ├── profiles.yml
│   └── dbt_project.yml
│
├── 3_serving/              # 📊 Data delivery (future)
│   └── README.md
│
└── 4_orchestration/        # 🔄 Workflow management (future)
    └── README.md
```

## 📊 Data Architecture

### Medallion Architecture Layers

**Bronze → Silver → Gold**

#### Bronze Layer (3 models)
Raw data loaded from Jaffle Shop REST API:
- `brz_jaffle_shop_api__customers` - Customer data
- `brz_jaffle_shop_api__orders` - Order transactions
- `brz_jaffle_shop_api__payments` - Payment records

#### Silver Layer (1 model)
Cleaned and business-logic applied:
- `slv_payments__pivoted` - Payment data pivoted by payment method

#### Gold Layer (4 models)
Business-ready analytics models:
- `dim_customers` - Customer dimension with RFM segmentation
- `dim_dates` - Date dimension with fiscal calendar
- `dim_payment_methods` - Payment method reference
- `fct_orders` - Orders fact table with metrics

## 🚀 Quick Start

### 1. Run Data Ingestion (dlt)

```bash
# Load data from Jaffle Shop API into production database
python 1_ingestion/jaffle_shop/pipelines/jaffle_shop_pipeline.py
```

### 2. Run Data Transformation (dbt)

```bash
# Transform data in test environment (default)
cd 2_transformation
dbt run

# Run against production
dbt run --target prod

# Run tests
dbt test

# Generate documentation
dbt docs generate
dbt docs serve
```

## 🔧 Configuration

### Environment Targets

- **dev** (default): Uses `edw_test.duckdb` for development
- **prod**: Uses `edw_prod.duckdb` for production

Switch between environments:
```bash
dbt run --target prod
```

### dlt Pipeline Configuration

The ingestion pipeline supports environment selection:
```python
# In jaffle_shop_pipeline.py
run_pipeline(environment="prod")  # or "test"
```

## 📈 Data Flow

```
External Jaffle Shop API
    ↓
1_ingestion (dlt pipeline)
    ↓
0_storage/databases/edw_*.duckdb
    ↓
2_transformation (dbt models)
    Bronze → Silver → Gold
    ↓
3_serving (BI tools, APIs, apps)
```

## 🎯 Data Sources

- **Source**: [Jaffle Shop API](https://jaffle-shop.dlthub.com)
- **API Endpoints**:
  - `/api/v1/customers` - Customer data
  - `/api/v1/orders` - Order data
- **Loader**: dlt (data load tool)
- **Warehouse**: DuckDB

## 📦 Models Summary

| Layer  | Models | Materialization | Purpose |
|--------|--------|----------------|----------|
| Bronze | 3      | Views          | Raw API data |
| Silver | 1      | Ephemeral      | Business logic |
| Gold   | 4      | Tables         | Analytics |

**Total**: 8 models, 100 customers, 100 orders

## 🛠️ Technologies

- **dlt**: Data ingestion from REST APIs
- **dbt**: Data transformation and modeling
- **DuckDB**: Embedded analytical database
- **Python**: Pipeline orchestration

## 📝 Next Steps

1. ✅ Ingestion layer with dlt
2. ✅ Transformation layer with dbt (Medallion Architecture)
3. ✅ Storage layer with environment separation
4. ⏳ Serving layer (BI tools, APIs)
5. ⏳ Orchestration layer (Prefect/Airflow)
6. ⏳ Data quality tests
7. ⏳ CI/CD pipeline

## 🧹 Cleanup Notes

The following folders are duplicates and can be safely deleted:
- `dbt/` - Old folder (use `2_transformation/` instead)
- `transformation/` - Old folder (use `2_transformation/` instead)

## 📚 Documentation

- [0_storage/README.md](0_storage/README.md) - Storage layer docs
- [3_serving/README.md](3_serving/README.md) - Serving layer plans
- [4_orchestration/README.md](4_orchestration/README.md) - Orchestration plans
