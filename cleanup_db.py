import duckdb

# Connect to test database
conn = duckdb.connect('0_storage/databases/edw_test.duckdb')

print("Current schemas:")
schemas = conn.execute("SELECT schema_name FROM information_schema.schemata ORDER BY schema_name").fetchall()
for schema in schemas:
    print(f"  - {schema[0]}")

print("\nTables in main schema:")
tables = conn.execute("""
    SELECT table_name
    FROM information_schema.tables
    WHERE table_schema = 'main'
    ORDER BY table_name
""").fetchall()
for table in tables:
    print(f"  - {table[0]}")

# Drop all tables in main schema
print("\nDropping tables from main schema...")
for table in tables:
    table_name = table[0]
    try:
        conn.execute(f"DROP TABLE IF EXISTS main.{table_name} CASCADE")
        print(f"  Dropped: {table_name}")
    except Exception as e:
        print(f"  Error dropping {table_name}: {e}")

# Note: We cannot drop the 'main' schema itself as it's a default DuckDB schema
print("\nNote: The 'main' schema is a default DuckDB schema and cannot be dropped,")
print("but all tables within it have been removed.")

print("\nFinal schemas:")
schemas = conn.execute("SELECT schema_name FROM information_schema.schemata ORDER BY schema_name").fetchall()
for schema in schemas:
    print(f"  - {schema[0]}")

conn.close()
print("\nCleanup complete!")
