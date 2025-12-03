"""Prefect flow for running dbt models."""

from prefect import flow, task
from pathlib import Path
import subprocess
import os


@task(name="Run dbt models", retries=1)
def run_dbt_task(project_dir: Path, profiles_dir: Path):
    """Task to run dbt models."""
    result = subprocess.run(
        ["dbt", "run", "--project-dir", str(project_dir), "--profiles-dir", str(profiles_dir)],
        capture_output=True,
        text=True,
    )

    if result.returncode != 0:
        print(f"dbt run stderr: {result.stderr}")
        raise Exception(f"dbt run failed: {result.stderr}")

    print(result.stdout)
    return result.stdout


@task(name="Run dbt tests", retries=1)
def run_dbt_tests_task(project_dir: Path, profiles_dir: Path):
    """Task to run dbt tests."""
    result = subprocess.run(
        ["dbt", "test", "--project-dir", str(project_dir), "--profiles-dir", str(profiles_dir)],
        capture_output=True,
        text=True,
    )

    if result.returncode != 0:
        print(f"dbt test stderr: {result.stderr}")
        raise Exception(f"dbt test failed: {result.stderr}")

    print(result.stdout)
    return result.stdout


@flow(name="Jaffle Shop dbt Pipeline")
def dbt_flow(run_tests: bool = True):
    """Prefect flow to run dbt models and optionally tests."""
    project_root = Path(__file__).parent.parent.parent.parent
    project_dir = project_root / "dbt_project"
    profiles_dir = project_dir

    # Run dbt models
    run_result = run_dbt_task(project_dir, profiles_dir)

    # Optionally run tests
    if run_tests:
        test_result = run_dbt_tests_task(project_dir, profiles_dir)
        return {"run": run_result, "test": test_result}

    return {"run": run_result}


if __name__ == "__main__":
    dbt_flow()
