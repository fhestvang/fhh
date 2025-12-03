"""dlt pipeline to load Jaffle Shop data from REST API into DuckDB"""

import dlt
from pathlib import Path
from typing import Iterator, Dict, Any
import os
import requests


def get_api_base_url() -> str:
    """Get the Jaffle Shop API base URL from environment."""
    return os.getenv("JAFFLE_SHOP_API_URL", "http://localhost:8000/api")


def fetch_from_api(endpoint: str) -> Iterator[Dict[str, Any]]:
    """Fetch data from the Jaffle Shop REST API."""
    base_url = get_api_base_url()
    url = f"{base_url}/{endpoint}"

    try:
        response = requests.get(url, timeout=30)
        response.raise_for_status()
        data = response.json()

        # Handle both list and paginated responses
        if isinstance(data, list):
            yield from data
        elif isinstance(data, dict) and "results" in data:
            yield from data["results"]
        else:
            yield data

    except requests.exceptions.RequestException as e:
        print(f"Error fetching from API {url}: {e}")
        print("No data loaded for this resource")


@dlt.resource(name="raw_customers", write_disposition="replace")
def customers_resource():
    """Load raw customers data from API."""
    yield from fetch_from_api("customers")


@dlt.resource(name="raw_orders", write_disposition="replace")
def orders_resource():
    """Load raw orders data from API."""
    yield from fetch_from_api("orders")


@dlt.resource(name="raw_payments", write_disposition="replace")
def payments_resource():
    """Load raw payments data from API."""
    yield from fetch_from_api("payments")


def run_pipeline():
    """Run the dlt pipeline to load API data into DuckDB."""
    project_root = Path(__file__).parent.parent.parent.parent
    pipelines_dir = project_root / "data" / "dlt_pipelines"

    # Ensure pipelines directory exists
    pipelines_dir.mkdir(parents=True, exist_ok=True)

    pipeline = dlt.pipeline(
        pipeline_name="jaffle_shop",
        destination="duckdb",
        dataset_name="jaffle_shop_raw",
        dev_mode=False,
        pipelines_dir=str(pipelines_dir),
    )

    load_info = pipeline.run(
        [customers_resource(), orders_resource(), payments_resource()],
        credentials=str(project_root / "data" / "jaffle_shop.duckdb"),
    )

    print(f"Pipeline completed: {load_info}")
    print(f"Row counts: {pipeline.last_trace.last_normalize_info.row_counts}")

    return load_info


if __name__ == "__main__":
    run_pipeline()
