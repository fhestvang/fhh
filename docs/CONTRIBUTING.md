# Contributing

## Setup

1. Fork and clone the repository
2. Install: `make install`
3. Setup: `make setup`
4. Download data: `make download-data`

## Workflow

1. Create branch: `git checkout -b feature/your-feature`
2. Make changes
3. Test changes
4. Commit with clear messages
5. Push and create PR

## Testing

### dlt changes
```bash
make reset
make run-dlt
```

### dbt changes
```bash
cd src/dbt_project
uv run dbt run --select your_model
uv run dbt test --select your_model
```

### Code Style

- Python: Follow PEP 8, use `ruff` for formatting
  ```bash
  make format
  make lint
  ```
- SQL: Use consistent formatting
  - Lowercase keywords
  - Indent nested queries with 4 spaces
  - Use CTEs for complex queries
  - Add comments for complex logic

### Commit Messages

Use clear, descriptive commit messages:

```
feat: Add new customer segmentation model
fix: Correct payment amount calculation
docs: Update setup instructions
refactor: Simplify order aggregation logic
```

### Adding New dlt Resources

1. Add resource function to `dlt_pipelines/jaffle_shop_pipeline.py`
2. Update pipeline run to include new resource
3. Test the pipeline
4. Update documentation

### Adding New dbt Models

1. Create model SQL file in appropriate directory:
   - Staging: `dbt_project/models/staging/`
   - Marts: `dbt_project/models/marts/core/`
2. Add model to `schema.yml` with:
   - Description
   - Column definitions
   - Tests
3. Run and test the model
4. Update documentation

## Project Structure Guidelines

### Directory Organization

- `dlt_pipelines/`: All dlt-related code
- `dbt_project/models/staging/`: Raw data cleaning (views)
- `dbt_project/models/marts/`: Business logic (tables)
- `scripts/`: Helper scripts
- `docs/`: Project documentation

### Naming Conventions

- **dlt resources**: `{source}_resource` (e.g., `customers_resource`)
- **dbt staging models**: `stg_{source}` (e.g., `stg_customers`)
- **dbt mart models**: `{entity}` (e.g., `customers`, `orders`)
- **Python files**: `snake_case.py`
- **SQL files**: `snake_case.sql`

## Documentation

- Update README.md for user-facing changes
- Update docs/ARCHITECTURE.md for architectural changes
- Add docstrings to Python functions
- Add descriptions to dbt models in schema.yml

## Pull Request Process

1. Ensure all tests pass
2. Update documentation
3. Add a clear description of changes
4. Link related issues
5. Request review

## Questions?

Feel free to open an issue for:
- Bug reports
- Feature requests
- Questions about the project
- Suggestions for improvements

## Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Focus on the code, not the person
- Help others learn and grow
