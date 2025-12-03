"""Prefect flow for running the full dlt + dbt pipeline."""

from prefect import flow
from jaffle_shop.flows.dlt_flow import dlt_flow
from jaffle_shop.flows.dbt_flow import dbt_flow


@flow(name="Jaffle Shop Full Pipeline")
def full_pipeline_flow(run_dbt_tests: bool = True):
    """Run the complete data pipeline: dlt -> dbt."""

    # Step 1: Load raw data via dlt
    print("Starting dlt pipeline...")
    dlt_result = dlt_flow()
    print(f"dlt pipeline completed: {dlt_result}")

    # Step 2: Transform data via dbt
    print("Starting dbt pipeline...")
    dbt_result = dbt_flow(run_tests=run_dbt_tests)
    print(f"dbt pipeline completed")

    return {"dlt": dlt_result, "dbt": dbt_result}


if __name__ == "__main__":
    full_pipeline_flow()
