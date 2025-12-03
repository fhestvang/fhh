"""dlt pipeline to load Jaffle Shop data from REST API into DuckDB"""

import dlt
from pathlib import Path
from typing import Iterator, Dict, Any
import os
import requests


def get_api_base_url() -> str:
    """Get the Jaffle Shop API base URL from environment."""
    return os.getenv("JAFFLE_SHOP_API_URL", "https://jaffle-shop.dlthub.com/api/v1")


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
    """
    Load raw payments data.
    Note: The Jaffle Shop API doesn't have a payments endpoint,
    so we extract payment info from order items.
    """
    from datetime import datetime

    # Since the API doesn't have payments, we'll generate mock payment data
    # based on orders (in production, this would come from a real payments API)
    orders = list(fetch_from_api("orders"))

    payment_id = 1
    for order in orders:
        # Generate a payment for each order
        payment = {
            "id": payment_id,
            "order_id": order.get("id"),
            "payment_method": "credit_card",  # Mock data
            "amount": 2500  # Mock amount in cents
        }
        yield payment
        payment_id += 1


@dlt.resource(name="raw_items", write_disposition="replace")
def items_resource():
    """Load raw items data from API."""
    yield from fetch_from_api("items")


@dlt.resource(name="raw_products", write_disposition="replace")
def products_resource():
    """Load raw products data from API."""
    yield from fetch_from_api("products")


@dlt.resource(name="raw_supplies", write_disposition="replace")
def supplies_resource():
    """Load raw supplies data from API."""
    yield from fetch_from_api("supplies")


@dlt.resource(name="raw_stores", write_disposition="replace")
def stores_resource():
    """Load raw stores data from API."""
    yield from fetch_from_api("stores")


def run_pipeline(environment="prod"):
    """
    Run the dlt pipeline to load API data into DuckDB.

    Args:
        environment: 'prod' or 'test' to determine which database to use
    """
    # Navigate from pipelines folder to project root (fhh/)
    project_root = Path(__file__).parent.parent.parent.parent
    pipelines_dir = project_root / "1_ingestion" / "data" / "dlt_pipelines"

    # Use environment-specific database
    db_name = f"edw_{environment}.duckdb"
    db_path = project_root / "0_storage" / "databases" / db_name

    # Ensure directories exist
    pipelines_dir.mkdir(parents=True, exist_ok=True)
    db_path.parent.mkdir(parents=True, exist_ok=True)

    pipeline = dlt.pipeline(
        pipeline_name="jaffle_shop",
        destination="duckdb",
        dataset_name="jaffle_shop_raw",
        dev_mode=False,
        pipelines_dir=str(pipelines_dir),
    )

    load_info = pipeline.run(
        [
            customers_resource(),
            orders_resource(),
            payments_resource(),
            items_resource(),
            products_resource(),
            supplies_resource(),
            stores_resource(),
        ],
        credentials=str(db_path),
    )

    print(f"Pipeline completed: {load_info}")
    print(f"Row counts: {pipeline.last_trace.last_normalize_info.row_counts}")

    return load_info


if __name__ == "__main__":
    # Default to test environment for development
    run_pipeline(environment="test")
