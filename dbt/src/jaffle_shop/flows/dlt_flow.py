"""Prefect flow for running dlt pipeline."""

from prefect import flow, task
from jaffle_shop.pipelines.jaffle_shop_pipeline import run_pipeline


@task(name="Run dlt pipeline", retries=2)
def run_dlt_task():
    """Task to run the dlt pipeline."""
    return run_pipeline()


@flow(name="Jaffle Shop dlt Pipeline")
def dlt_flow():
    """Prefect flow to load data from API using dlt."""
    load_info = run_dlt_task()
    return load_info


if __name__ == "__main__":
    dlt_flow()
