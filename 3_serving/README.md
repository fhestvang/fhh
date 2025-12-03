# 3ã Serving Layer

This folder contains configurations and code for serving the transformed data to end users and applications.

## Purpose

The serving layer provides access to the gold layer data through various interfaces:

- **BI Tools**: Connections for Tableau, Power BI, Looker, etc.
- **APIs**: REST/GraphQL endpoints for applications
- **Data Apps**: Streamlit, Dash, or other data applications
- **Exports**: Scheduled data exports and reports

## Planned Components

- `dashboards/` - BI dashboard configurations
- `apis/` - API endpoints for data access
- `apps/` - Data applications (Streamlit, etc.)
- `exports/` - Export configurations and scripts

## Data Sources

This layer consumes data from:
- **2_transformation/data/jaffle_shop.duckdb** (Gold schema)

## Next Steps

1. Set up BI tool connections
2. Create data APIs
3. Build interactive dashboards
4. Configure automated exports
