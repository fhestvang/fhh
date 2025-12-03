# Enterprise dbt Project Structure Guide
## For Large-Scale Projects (80+ Sources, 180+ Models)

---

## Executive Summary

At enterprise scale (80 sources, 180 models), your dbt project needs:
- **Clear organization patterns** that scale beyond individual knowledge
- **Modular architecture** that allows parallel development
- **Governance frameworks** for quality and consistency
- **Performance optimization** strategies
- **Team collaboration** structures

This guide provides battle-tested patterns for organizations running production dbt at scale.

---

## Table of Contents

1. [Project Structure Philosophy](#project-structure-philosophy)
2. [Folder Organization](#folder-organization)
3. [Naming Conventions](#naming-conventions)
4. [Layered Architecture](#layered-architecture)
5. [Source Management](#source-management)
6. [Model Organization Strategies](#model-organization-strategies)
7. [Testing & Documentation](#testing--documentation)
8. [Performance Optimization](#performance-optimization)
9. [Team Collaboration](#team-collaboration)
10. [Deployment & CI/CD](#deployment--cicd)
11. [Real-World Example](#real-world-example)

---

## Project Structure Philosophy

### Core Principles

**1. Separation of Concerns**
- Each layer has a single, clear responsibility
- Models should do one thing well
- Clear boundaries between raw data, business logic, and presentation

**2. Discoverability**
- Anyone should be able to find what they need in < 2 minutes
- Consistent patterns across the entire project
- Self-documenting structure

**3. Scalability**
- Structure should work with 10 or 1000 models
- Easy to add new sources/domains without restructuring
- Parallel development without conflicts

**4. Modularity**
- Domain-based organization for large teams
- Reusable components via packages
- Clear interfaces between modules

---

## Folder Organization

### Recommended Enterprise Structure

```
dbt_project/
├── dbt_project.yml
├── packages.yml
├── profiles.yml (local only, gitignored)
│
├── models/
│   ├── staging/              # Layer 1: Source conformed
│   │   ├── erp/              # Source system grouping
│   │   │   ├── _erp__sources.yml
│   │   │   ├── _erp__models.yml
│   │   │   ├── stg_erp__customers.sql
│   │   │   ├── stg_erp__orders.sql
│   │   │   └── stg_erp__products.sql
│   │   │
│   │   ├── crm/              # Another source system
│   │   │   ├── _crm__sources.yml
│   │   │   ├── _crm__models.yml
│   │   │   ├── stg_crm__accounts.sql
│   │   │   └── stg_crm__contacts.sql
│   │   │
│   │   ├── marketing/
│   │   │   ├── google_ads/
│   │   │   ├── facebook_ads/
│   │   │   └── mailchimp/
│   │   │
│   │   └── finance/
│   │       ├── stripe/
│   │       └── quickbooks/
│   │
│   ├── intermediate/         # Layer 2: Business logic
│   │   ├── finance/          # Domain grouping
│   │   │   ├── _int_finance__models.yml
│   │   │   ├── int_payments_pivoted.sql
│   │   │   └── int_revenue_daily.sql
│   │   │
│   │   ├── marketing/
│   │   │   ├── int_campaign_performance.sql
│   │   │   └── int_customer_acquisition.sql
│   │   │
│   │   └── product/
│   │       ├── int_user_sessions.sql
│   │       └── int_feature_usage.sql
│   │
│   └── marts/                # Layer 3: Business presentation
│       ├── finance/          # Business domain
│       │   ├── _finance__models.yml
│       │   ├── fct_payments.sql
│       │   ├── fct_invoices.sql
│       │   └── dim_payment_methods.sql
│       │
│       ├── marketing/
│       │   ├── _marketing__models.yml
│       │   ├── fct_campaigns.sql
│       │   ├── fct_ad_performance.sql
│       │   └── dim_channels.sql
│       │
│       ├── product/
│       │   ├── fct_user_events.sql
│       │   ├── fct_feature_adoption.sql
│       │   └── dim_features.sql
│       │
│       └── core/             # Cross-domain entities
│           ├── dim_customers.sql
│           ├── dim_dates.sql
│           └── dim_organizations.sql
│
├── macros/
│   ├── _macros.yml
│   ├── business_logic/
│   │   ├── calculate_ltv.sql
│   │   └── segment_customers.sql
│   ├── utilities/
│   │   ├── generate_schema_name.sql
│   │   ├── star.sql
│   │   └── pivot.sql
│   └── tests/
│       ├── test_valid_email.sql
│       └── test_positive_values.sql
│
├── analyses/                 # Ad-hoc queries (not built)
│   ├── revenue_analysis.sql
│   └── user_cohorts.sql
│
├── tests/                    # Singular tests
│   ├── assert_revenue_match.sql
│   └── assert_customer_uniqueness.sql
│
├── seeds/                    # Static reference data
│   ├── country_codes.csv
│   ├── product_categories.csv
│   └── _seeds.yml
│
├── snapshots/                # Type 2 SCD
│   ├── snap_customers.sql
│   └── snap_products.sql
│
├── docs/
│   ├── overview.md
│   ├── data_dictionary.md
│   └── dashboards.md
│
└── metrics/                  # dbt metrics (if using)
    └── revenue_metrics.yml
```

---

## Naming Conventions

### Model Naming Pattern

**Format:** `<type>_<source/domain>__<entity>__<verb/modifier>.sql`

**Examples:**
```sql
-- Staging models (source conformed)
stg_salesforce__accounts.sql
stg_salesforce__opportunities.sql
stg_stripe__payments.sql

-- Intermediate models (business logic)
int_customers__unioned.sql
int_orders__pivoted_by_status.sql
int_revenue__daily_aggregated.sql

-- Mart fact tables
fct_orders.sql
fct_customer_sessions.sql
fct_subscription_events.sql

-- Mart dimension tables
dim_customers.sql
dim_products.sql
dim_dates.sql

-- Bridge tables
bridge_customer_products.sql
```

### Naming Conventions by Layer

| Layer | Prefix | Example | Purpose |
|-------|--------|---------|---------|
| Staging | `stg_` | `stg_salesforce__accounts` | Source system → warehouse |
| Intermediate | `int_` | `int_customers__enriched` | Business logic |
| Marts - Facts | `fct_` | `fct_orders` | Event/transaction tables |
| Marts - Dimensions | `dim_` | `dim_customers` | Entity attributes |
| Ephemeral | `eph_` | `eph_temp_calculation` | Not materialized |
| Utility | `util_` | `util_date_spine` | Helper models |

### File Naming Best Practices

**DO:**
- ✅ Use snake_case for all files
- ✅ Use double underscore `__` to separate source from entity
- ✅ Keep names descriptive but concise
- ✅ Use consistent verb tenses (past tense for events)

**DON'T:**
- ❌ Use camelCase or PascalCase
- ❌ Abbreviate unnecessarily (`cust` vs `customers`)
- ❌ Use spaces or special characters
- ❌ Make names too long (>50 characters)

---

## Layered Architecture

### The Three-Layer Approach

#### **Layer 1: Staging (`staging/`)**

**Purpose:** Light transformation from source → analytics-ready format

**Characteristics:**
- 1:1 relationship with source tables
- Only renaming, recasting, basic cleaning
- No business logic
- No joins (except self-joins for deduplication)
- Grouped by source system

**Example:**
```sql
-- models/staging/salesforce/stg_salesforce__accounts.sql

with source as (
    select * from {{ source('salesforce', 'accounts') }}
),

renamed as (
    select
        id as account_id,
        name as account_name,
        type as account_type,
        industry,
        annual_revenue,
        created_date::timestamp as created_at,
        modified_date::timestamp as updated_at,
        is_deleted as is_deleted_flag
        
    from source
    where not is_deleted  -- Filter out soft deletes
)

select * from renamed
```

**When to use staging:**
- Every source table should have a staging model
- This is your "source of truth" for downstream models
- Changes to source schemas only affect staging layer

#### **Layer 2: Intermediate (`intermediate/`)**

**Purpose:** Business logic, complex transformations, joins

**Characteristics:**
- Can join multiple staging models
- Contains business logic (calculations, categorizations)
- Often ephemeral (not materialized)
- Grouped by business domain or use case
- Usually not exposed to end users

**Example:**
```sql
-- models/intermediate/customers/int_customer_orders__aggregated.sql

with orders as (
    select * from {{ ref('stg_erp__orders') }}
),

payments as (
    select * from {{ ref('stg_stripe__payments') }}
),

order_payments as (
    select
        orders.order_id,
        orders.customer_id,
        orders.order_date,
        orders.order_total,
        payments.payment_status,
        payments.payment_method
        
    from orders
    left join payments 
        on orders.order_id = payments.order_id
),

customer_aggregates as (
    select
        customer_id,
        count(distinct order_id) as total_orders,
        sum(order_total) as lifetime_value,
        min(order_date) as first_order_date,
        max(order_date) as last_order_date,
        count(distinct case 
            when payment_status = 'succeeded' 
            then order_id 
        end) as successful_orders
        
    from order_payments
    group by 1
)

select * from customer_aggregates
```

**When to use intermediate:**
- Complex joins across multiple sources
- Business calculations
- Data quality fixes
- Preparing data for final marts
- Often `{{ config(materialized='ephemeral') }}`

#### **Layer 3: Marts (`marts/`)**

**Purpose:** Final, business-ready data models

**Characteristics:**
- Exposed to BI tools and end users
- Organized by business domain (finance, marketing, product)
- Fact and dimension tables
- Well-documented and tested
- Optimized for query performance

**Fact Table Example:**
```sql
-- models/marts/finance/fct_orders.sql

{{
    config(
        materialized='incremental',
        unique_key='order_id',
        on_schema_change='sync_all_columns'
    )
}}

with orders as (
    select * from {{ ref('stg_erp__orders') }}
    
    {% if is_incremental() %}
    where order_date >= (select max(order_date) from {{ this }})
    {% endif %}
),

customers as (
    select * from {{ ref('dim_customers') }}
),

products as (
    select * from {{ ref('dim_products') }}
),

final as (
    select
        -- Primary key
        orders.order_id,
        
        -- Foreign keys (dimension references)
        orders.customer_id,
        orders.product_id,
        orders.order_date as order_date_id,
        
        -- Degenerate dimensions (attributes on fact)
        orders.order_number,
        orders.order_status,
        
        -- Measures
        orders.quantity,
        orders.unit_price,
        orders.discount_amount,
        orders.tax_amount,
        orders.total_amount,
        
        -- Calculated measures
        (orders.total_amount - orders.discount_amount) as net_amount,
        
        -- Audit columns
        orders.created_at,
        orders.updated_at
        
    from orders
    left join customers 
        on orders.customer_id = customers.customer_id
    left join products 
        on orders.product_id = products.product_id
)

select * from final
```

**Dimension Table Example:**
```sql
-- models/marts/core/dim_customers.sql

{{
    config(
        materialized='table'
    )
}}

with customers as (
    select * from {{ ref('stg_crm__customers') }}
),

orders as (
    select * from {{ ref('int_customer_orders__aggregated') }}
),

final as (
    select
        -- Primary key
        customers.customer_id,
        
        -- Attributes
        customers.customer_name,
        customers.customer_email,
        customers.customer_type,
        customers.industry,
        customers.country,
        customers.state,
        customers.city,
        
        -- Derived attributes
        case 
            when orders.lifetime_value >= 10000 then 'High Value'
            when orders.lifetime_value >= 1000 then 'Medium Value'
            else 'Low Value'
        end as customer_segment,
        
        -- Metrics (from orders)
        coalesce(orders.total_orders, 0) as total_orders,
        coalesce(orders.lifetime_value, 0) as lifetime_value,
        orders.first_order_date,
        orders.last_order_date,
        
        -- SCD Type 2 columns (if needed)
        customers.valid_from,
        customers.valid_to,
        customers.is_current,
        
        -- Audit
        customers.created_at,
        customers.updated_at
        
    from customers
    left join orders 
        on customers.customer_id = orders.customer_id
)

select * from final
```

---

## Source Management

### Organizing 80 Sources

**Group by Source System:**

```yaml
# models/staging/salesforce/_salesforce__sources.yml

version: 2

sources:
  - name: salesforce
    description: "Salesforce CRM data synced via Fivetran"
    database: raw
    schema: salesforce
    
    # Source-level metadata
    meta:
      owner: "sales-engineering@company.com"
      contains_pii: true
      sync_frequency: "hourly"
    
    # Source-level tests
    freshness:
      warn_after: {count: 12, period: hour}
      error_after: {count: 24, period: hour}
    
    # Source-level config
    loader: fivetran
    loaded_at_field: _fivetran_synced
    
    tables:
      - name: accounts
        description: "Salesforce account records"
        columns:
          - name: id
            description: "Primary key"
            tests:
              - unique
              - not_null
          
          - name: name
            description: "Account name"
            tests:
              - not_null
          
          - name: industry
            description: "Industry classification"
          
          - name: annual_revenue
            description: "Annual revenue in USD"
            tests:
              - dbt_expectations.expect_column_values_to_be_between:
                  min_value: 0
                  max_value: 1000000000000
      
      - name: opportunities
        description: "Sales opportunities"
        # ... more columns
      
      - name: contacts
        description: "Contact records"
        # ... more columns
```

### Source Organization Patterns

**Pattern 1: By System (Recommended for 80 sources)**
```
staging/
├── salesforce/
├── netsuite/
├── stripe/
├── google_analytics/
├── facebook_ads/
├── hubspot/
└── zendesk/
```

**Pattern 2: By Department (Alternative)**
```
staging/
├── sales/
│   ├── salesforce/
│   └── outreach/
├── finance/
│   ├── netsuite/
│   └── stripe/
└── marketing/
    ├── google_ads/
    └── facebook_ads/
```

**Pattern 3: Hybrid (Best for Very Large Projects)**
```
staging/
├── saas_applications/
│   ├── salesforce/
│   ├── hubspot/
│   └── zendesk/
├── databases/
│   ├── mysql_prod/
│   └── postgres_analytics/
├── advertising/
│   ├── google_ads/
│   ├── facebook_ads/
│   └── linkedin_ads/
└── finance/
    ├── stripe/
    └── quickbooks/
```

---

## Model Organization Strategies

### Strategy 1: Domain-Driven Design (Recommended for Large Teams)

Organize marts by business domain:

```
marts/
├── finance/              # Revenue, payments, invoices
├── marketing/            # Campaigns, leads, attribution
├── product/              # Features, usage, adoption
├── sales/                # Opportunities, pipeline, quota
├── customer_success/     # Support, health scores, churn
└── core/                 # Shared dimensions (customers, dates, etc.)
```

**Benefits:**
- Clear ownership by team
- Easy to find domain-specific models
- Reduced merge conflicts
- Parallel development

**Example ownership:**
```yaml
# dbt_project.yml

models:
  my_project:
    marts:
      finance:
        +meta:
          owner: "finance-team@company.com"
          slack: "#finance-analytics"
      
      marketing:
        +meta:
          owner: "marketing-ops@company.com"
          slack: "#marketing-analytics"
```

### Strategy 2: Functional Grouping

For smaller teams or single-domain companies:

```
marts/
├── metrics/              # Aggregated metrics
├── entities/             # Core business entities
├── events/               # Event/transaction tables
└── reporting/            # BI-ready denormalized tables
```

### Strategy 3: Data Mesh Approach

For very large organizations with multiple data teams:

```
marts/
├── sales_domain/         # Owned by sales data team
│   ├── public/          # Exposed to other domains
│   └── internal/        # Internal to sales domain
│
├── finance_domain/       # Owned by finance data team
│   ├── public/
│   └── internal/
│
└── shared/              # Cross-domain entities
    └── core/
```

---

## Testing & Documentation

### Testing Strategy

**Test Coverage Levels:**

1. **Critical models** (used in dashboards, reports): 100% test coverage
2. **Important models** (intermediate transformations): 80% coverage
3. **Staging models**: Basic coverage (unique, not_null on keys)

**Testing Pyramid:**

```
                    /\
                   /  \     10% - Data validation tests
                  /    \    (Custom singular tests)
                 /------\
                /        \  30% - Business logic tests
               /          \ (Schema tests, relationships)
              /------------\
             /              \ 60% - Source data quality
            /________________\ (Not null, unique, accepted values)
```

### Comprehensive Testing Example

```yaml
# models/marts/finance/_finance__models.yml

version: 2

models:
  - name: fct_orders
    description: "Order fact table with grain of one row per order"
    
    meta:
      owner: "finance-team@company.com"
      contains_pii: false
      
    config:
      materialized: incremental
      unique_key: order_id
      
    # Model-level tests
    tests:
      - dbt_utils.expression_is_true:
          expression: "total_amount >= 0"
      
      - dbt_expectations.expect_table_row_count_to_be_between:
          min_value: 1000
          max_value: 10000000
    
    columns:
      - name: order_id
        description: "Unique identifier for each order"
        tests:
          - unique
          - not_null
          - relationships:
              to: ref('stg_erp__orders')
              field: order_id
      
      - name: customer_id
        description: "Foreign key to dim_customers"
        tests:
          - not_null
          - relationships:
              to: ref('dim_customers')
              field: customer_id
      
      - name: order_date
        description: "Date of order placement"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: "'2020-01-01'"
              max_value: "current_date + interval '1 day'"
      
      - name: order_status
        description: "Current status of the order"
        tests:
          - not_null
          - accepted_values:
              values: ['pending', 'processing', 'shipped', 'delivered', 'cancelled', 'returned']
      
      - name: total_amount
        description: "Total order amount in USD"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1000000
      
      - name: discount_amount
        description: "Discount applied to order"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: "total_amount"
```

### Documentation Best Practices

**1. Model-Level Documentation:**
```yaml
models:
  - name: fct_orders
    description: |
      # Order Fact Table
      
      ## Grain
      One row per order
      
      ## Business Logic
      - Includes all orders regardless of status
      - Amounts in USD
      - Excludes test orders (customer_email not like '%@test.com')
      
      ## Refresh Cadence
      - Incremental updates every 1 hour
      - Full refresh weekly on Sundays
      
      ## Known Issues
      - Refunds are recorded as separate rows, not updates to original order
      - International orders may have currency conversion delays
      
      ## Downstream Usage
      - Tableau: Revenue Dashboard
      - Looker: Sales Analytics
      - Python: ML churn model
```

**2. Column-Level Documentation:**
```yaml
columns:
  - name: customer_lifetime_value
    description: |
      Sum of all order totals for this customer.
      
      **Calculation:** 
      `SUM(total_amount) OVER (PARTITION BY customer_id)`
      
      **Updated:** On each order
      
      **Null values:** Possible for customers with no completed orders
```

**3. Use dbt docs generate:**
```bash
# Generate documentation site
dbt docs generate

# Serve locally
dbt docs serve
```

---

## Performance Optimization

### Materialization Strategy

**Decision Matrix:**

| Model Type | Row Count | Query Frequency | Complexity | Materialization |
|------------|-----------|-----------------|------------|-----------------|
| Staging | Any | Low | Low | View |
| Intermediate | < 100k | Low | Medium | Ephemeral |
| Intermediate | > 100k | Medium | High | Table |
| Marts - Dimension | < 1M | High | Any | Table |
| Marts - Fact | < 10M | High | Low | Table |
| Marts - Fact | > 10M | High | Any | Incremental |
| Metrics | Any | Very High | Any | Materialized View* |

*If your warehouse supports it

### Incremental Model Pattern

```sql
-- models/marts/events/fct_user_events.sql

{{
    config(
        materialized='incremental',
        unique_key='event_id',
        on_schema_change='sync_all_columns',
        partition_by={
            'field': 'event_date',
            'data_type': 'date',
            'granularity': 'day'
        },
        cluster_by=['user_id', 'event_type']
    )
}}

with events as (
    select * from {{ ref('stg_analytics__events') }}
    
    {% if is_incremental() %}
    -- Only process new events
    where event_timestamp >= (
        select max(event_timestamp)
        from {{ this }}
    )
    {% endif %}
),

enriched as (
    select
        events.event_id,
        events.user_id,
        events.event_type,
        events.event_timestamp,
        date(events.event_timestamp) as event_date,
        events.properties,
        
        -- Enrich with user data
        users.user_segment,
        users.signup_date,
        
        -- Calculate session
        {{ generate_session_id('user_id', 'event_timestamp', minutes=30) }} as session_id
        
    from events
    left join {{ ref('dim_users') }} as users
        on events.user_id = users.user_id
)

select * from enriched
```

### Query Optimization Tips

**1. Use CTEs Effectively:**
```sql
-- ✅ GOOD: Clear, readable, optimized by modern query engines
with orders as (
    select * from {{ ref('stg_orders') }}
),

order_items as (
    select * from {{ ref('stg_order_items') }}
),

joined as (
    select
        orders.order_id,
        orders.customer_id,
        sum(order_items.quantity) as total_items
    from orders
    left join order_items using (order_id)
    group by 1, 2
)

select * from joined
```

**2. Filter Early:**
```sql
-- ✅ GOOD: Filter in CTE
with recent_orders as (
    select *
    from {{ ref('stg_orders') }}
    where order_date >= current_date - 90  -- Filter early
),

-- ❌ BAD: Filter at the end
with all_orders as (
    select *
    from {{ ref('stg_orders') }}  -- Processes all data
),

final as (
    select *
    from all_orders
    where order_date >= current_date - 90  -- Filter late
)
```

**3. Use Incremental Strategically:**
```sql
-- Only for large, append-only tables
-- Not for tables that need updates/deletes

{% if is_incremental() %}
    -- Merge strategy for updates
    merge into {{ this }} as target
    using new_data as source
    on target.id = source.id
    when matched then update set ...
    when not matched then insert ...
{% endif %}
```

**4. Partition and Cluster:**
```sql
{{
    config(
        materialized='table',
        partition_by={
            'field': 'order_date',
            'data_type': 'date'
        },
        cluster_by=['customer_id', 'product_category']
    )
}}
```

### dbt Project Configuration

```yaml
# dbt_project.yml

name: 'my_enterprise_project'
version: '1.0.0'
config-version: 2

# Global configs
models:
  my_enterprise_project:
    
    # Staging: lightweight views
    staging:
      +materialized: view
      +schema: staging
      +docs:
        node_color: "#8BC34A"  # Green in dbt docs
    
    # Intermediate: ephemeral by default
    intermediate:
      +materialized: ephemeral
      +schema: intermediate
      +docs:
        node_color: "#FFC107"  # Yellow
    
    # Marts: tables and incremental
    marts:
      +materialized: table
      +schema: marts
      +docs:
        node_color: "#2196F3"  # Blue
      
      # Domain-specific configs
      finance:
        +schema: finance
        +tags: ["finance", "pii"]
      
      marketing:
        +schema: marketing
        +tags: ["marketing"]
      
      # Large fact tables: incremental
      +fct_*:
        +materialized: incremental
        +on_schema_change: sync_all_columns

# Seeds config
seeds:
  my_enterprise_project:
    +schema: seeds
    +quote_columns: false

# Snapshot config
snapshots:
  my_enterprise_project:
    +target_schema: snapshots
    +strategy: timestamp
    +updated_at: updated_at

# Test config
tests:
  my_enterprise_project:
    +severity: warn  # Don't fail builds on test failures
    
    marts:
      +severity: error  # But fail on mart tests
```

---

## Team Collaboration

### Git Workflow

**Branch Strategy:**
```
main (production)
├── develop (integration)
    ├── feature/add-customer-segmentation
    ├── feature/new-revenue-model
    └── hotfix/fix-date-logic
```

**Development Flow:**
1. Create feature branch from `develop`
2. Make changes
3. Run locally: `dbt run --select +my_new_model`
4. Test: `dbt test --select +my_new_model`
5. Commit and push
6. Open PR to `develop`
7. CI runs tests
8. Review and merge
9. Deploy `develop` to staging
10. Merge `develop` to `main` for production

### Code Review Checklist

```markdown
## dbt Model Review Checklist

### Code Quality
- [ ] Model follows naming conventions
- [ ] Proper use of CTEs (no subqueries)
- [ ] SQL is readable and well-formatted
- [ ] Complex logic has comments
- [ ] No hardcoded values (use variables/macros)

### Testing
- [ ] Primary key has unique + not_null tests
- [ ] Foreign keys have relationship tests
- [ ] Business logic has validation tests
- [ ] Model compiles without errors
- [ ] Tests pass in dev environment

### Documentation
- [ ] Model has description
- [ ] All columns have descriptions
- [ ] Complex calculations are explained
- [ ] Downstream usage is documented

### Performance
- [ ] Appropriate materialization strategy
- [ ] Incremental logic is correct (if applicable)
- [ ] No unnecessary full table scans
- [ ] Partitioning/clustering configured (if needed)

### Dependencies
- [ ] References are correct (ref/source)
- [ ] Circular dependencies avoided
- [ ] DAG makes logical sense
- [ ] No dependencies on deprecated models
```

### CODEOWNERS File

```
# .github/CODEOWNERS

# Global owners
* @data-engineering-team

# Domain-specific ownership
/models/marts/finance/ @finance-analytics-team
/models/marts/marketing/ @marketing-analytics-team
/models/marts/product/ @product-analytics-team

# Source-specific ownership
/models/staging/salesforce/ @sales-engineering-team
/models/staging/stripe/ @finance-data-team

# Infrastructure
/macros/ @data-engineering-leads
/dbt_project.yml @data-engineering-leads
/.github/ @data-engineering-leads
```

### Development Environment Standards

**profiles.yml Template:**
```yaml
# ~/.dbt/profiles.yml

my_enterprise_project:
  target: dev
  
  outputs:
    # Personal dev environment
    dev:
      type: duckdb
      path: "dev_{{ env_var('DBT_USER') }}.duckdb"
      schema: "dev_{{ env_var('DBT_USER') }}"
      threads: 4
    
    # Shared CI environment
    ci:
      type: snowflake
      account: "{{ env_var('SNOWFLAKE_ACCOUNT') }}"
      user: "{{ env_var('SNOWFLAKE_USER') }}"
      password: "{{ env_var('SNOWFLAKE_PASSWORD') }}"
      role: DBT_CI_ROLE
      database: ANALYTICS_CI
      warehouse: DBT_CI_WH
      schema: CI_{{ env_var('CI_BRANCH_NAME') }}
      threads: 8
    
    # Production
    prod:
      type: snowflake
      account: "{{ env_var('SNOWFLAKE_ACCOUNT') }}"
      user: "{{ env_var('SNOWFLAKE_PROD_USER') }}"
      password: "{{ env_var('SNOWFLAKE_PROD_PASSWORD') }}"
      role: DBT_PROD_ROLE
      database: ANALYTICS_PROD
      warehouse: DBT_PROD_WH
      schema: PROD
      threads: 16
```

---

## Deployment & CI/CD

### GitHub Actions Workflow

```yaml
# .github/workflows/dbt_ci.yml

name: dbt CI

on:
  pull_request:
    branches: [develop, main]
  push:
    branches: [main]

jobs:
  dbt-test:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.10'
      
      - name: Install dependencies
        run: |
          pip install dbt-core dbt-snowflake
          dbt deps
      
      - name: Run dbt debug
        run: dbt debug
        env:
          SNOWFLAKE_ACCOUNT: ${{ secrets.SNOWFLAKE_ACCOUNT }}
          SNOWFLAKE_USER: ${{ secrets.SNOWFLAKE_USER }}
          SNOWFLAKE_PASSWORD: ${{ secrets.SNOWFLAKE_PASSWORD }}
      
      - name: Run dbt build (changed models)
        run: |
          dbt build --select state:modified+ --state ./prod_manifest
        env:
          SNOWFLAKE_ACCOUNT: ${{ secrets.SNOWFLAKE_ACCOUNT }}
          SNOWFLAKE_USER: ${{ secrets.SNOWFLAKE_USER }}
          SNOWFLAKE_PASSWORD: ${{ secrets.SNOWFLAKE_PASSWORD }}
      
      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: dbt-artifacts
          path: target/

  dbt-docs:
    needs: dbt-test
    runs-on: ubuntu-latest
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    
    steps:
      - name: Generate dbt docs
        run: dbt docs generate
      
      - name: Deploy to S3
        run: |
          aws s3 sync target/ s3://dbt-docs-bucket/
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

### Slim CI (Only Test Changed Models)

```bash
# In CI, only build models that changed

# 1. Download production manifest
aws s3 cp s3://dbt-artifacts/manifest.json ./prod_manifest/

# 2. Run only changed models and their downstream dependencies
dbt build \
  --select state:modified+ \
  --state ./prod_manifest \
  --defer \
  --exclude tag:nightly
```

### Production Deployment

```yaml
# .github/workflows/dbt_deploy.yml

name: dbt Production Deploy

on:
  push:
    branches: [main]
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout
        uses: actions/checkout@v3
      
      - name: Run dbt
        run: |
          dbt seed --target prod
          dbt run --target prod
          dbt test --target prod
          dbt snapshot --target prod
      
      - name: Upload manifest
        run: |
          aws s3 cp target/manifest.json s3://dbt-artifacts/
      
      - name: Notify on failure
        if: failure()
        uses: slackapi/slack-github-action@v1
        with:
          payload: |
            {
              "text": "❌ dbt production deploy FAILED"
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```

---

## Real-World Example

### Complete Mart Model with All Best Practices

```sql
-- models/marts/finance/fct_revenue.sql

{{
    config(
        materialized='incremental',
        unique_key='revenue_id',
        on_schema_change='sync_all_columns',
        partition_by={
            'field': 'transaction_date',
            'data_type': 'date',
            'granularity': 'day'
        },
        cluster_by=['customer_id', 'product_category'],
        tags=['finance', 'revenue', 'critical'],
        meta={
            'owner': 'finance-team@company.com',
            'contains_pii': false,
            'sla_hours': 4
        }
    )
}}

/*
    Revenue Fact Table
    
    Grain: One row per revenue transaction
    
    Business Logic:
    - Revenue is recognized on payment completion
    - Refunds are recorded as negative revenue
    - Excludes test transactions
    - Multi-currency amounts converted to USD
    
    Refresh: Incremental every hour
    Full refresh: Weekly on Sundays
*/

with payments as (
    select * from {{ ref('stg_stripe__payments') }}
    
    {% if is_incremental() %}
    where payment_timestamp >= (
        select dateadd(hour, -2, max(transaction_timestamp))
        from {{ this }}
    )
    {% endif %}
),

customers as (
    select * from {{ ref('dim_customers') }}
),

products as (
    select * from {{ ref('dim_products') }}
),

exchange_rates as (
    select * from {{ ref('seed_exchange_rates') }}
),

revenue_base as (
    select
        -- Primary key
        {{ dbt_utils.generate_surrogate_key([
            'payments.payment_id',
            'payments.line_item_id'
        ]) }} as revenue_id,
        
        -- Foreign keys
        payments.payment_id,
        payments.customer_id,
        payments.product_id,
        date(payments.payment_timestamp) as transaction_date_id,
        
        -- Degenerate dimensions
        payments.payment_method,
        payments.payment_status,
        payments.currency,
        
        -- Measures (original currency)
        payments.amount as amount_original,
        payments.fee_amount as fee_amount_original,
        
        -- Convert to USD
        payments.amount * coalesce(exchange_rates.rate_to_usd, 1) as amount_usd,
        payments.fee_amount * coalesce(exchange_rates.rate_to_usd, 1) as fee_amount_usd,
        
        -- Calculated measures
        (payments.amount - payments.fee_amount) * coalesce(exchange_rates.rate_to_usd, 1) as net_revenue_usd,
        
        -- Timestamps
        payments.payment_timestamp as transaction_timestamp,
        payments.created_at,
        payments.updated_at
        
    from payments
    left join exchange_rates
        on payments.currency = exchange_rates.currency
        and date(payments.payment_timestamp) = exchange_rates.rate_date
    
    -- Exclude test data
    where payments.customer_email not like '%@test.com'
        and payments.customer_email not like '%+test%'
),

enriched as (
    select
        revenue_base.*,
        
        -- Customer attributes
        customers.customer_segment,
        customers.customer_cohort,
        customers.acquisition_channel,
        
        -- Product attributes
        products.product_category,
        products.product_line,
        products.product_type,
        
        -- Business calculations
        case
            when revenue_base.amount_usd < 0 then 'Refund'
            when revenue_base.payment_status = 'succeeded' then 'Revenue'
            when revenue_base.payment_status = 'pending' then 'Pending'
            else 'Other'
        end as revenue_type,
        
        -- Data quality flag
        case
            when revenue_base.customer_id is null then 'Missing Customer'
            when revenue_base.product_id is null then 'Missing Product'
            when revenue_base.amount_usd is null then 'Missing Amount'
            else 'Valid'
        end as data_quality_flag
        
    from revenue_base
    left join customers
        on revenue_base.customer_id = customers.customer_id
    left join products
        on revenue_base.product_id = products.product_id
)

select * from enriched

-- Log data quality issues
{% if is_incremental() %}
    {{ log_data_quality_metrics('fct_revenue', 'data_quality_flag') }}
{% endif %}
```

### Corresponding YAML Documentation

```yaml
# models/marts/finance/_finance__models.yml

version: 2

models:
  - name: fct_revenue
    description: |
      # Revenue Fact Table
      
      ## Overview
      Central fact table for all revenue transactions. Used as source of truth
      for revenue reporting, financial analytics, and board reporting.
      
      ## Grain
      One row per revenue transaction (payment line item)
      
      ## Business Rules
      1. Revenue recognized on payment completion (status = 'succeeded')
      2. Refunds recorded as negative revenue in same table
      3. All amounts converted to USD using daily exchange rates
      4. Test transactions excluded (emails containing '@test.com' or '+test')
      
      ## Refresh Schedule
      - **Incremental**: Hourly (processes last 2 hours of data)
      - **Full Refresh**: Weekly on Sundays at 2 AM UTC
      - **Backfill**: Available via dbt run --full-refresh
      
      ## Data Quality
      - Primary key uniqueness enforced
      - Relationships validated to dimension tables
      - Null checks on critical fields
      - Data quality flags for monitoring
      
      ## Downstream Usage
      - **Tableau**: Executive Revenue Dashboard
      - **Looker**: Finance Analytics
      - **Python**: Revenue forecasting model
      - **Airflow**: Daily revenue reports
      
      ## Performance
      - **Rows**: ~50M (incremental)
      - **Query Time**: < 5 seconds (typical)
      - **Storage**: 15 GB compressed
      - **Partitioned by**: transaction_date (daily)
      - **Clustered by**: customer_id, product_category
      
      ## Known Issues
      - Exchange rates may be delayed by 1 day for some currencies
      - International refunds may appear in wrong fiscal period
      
      ## Change Log
      - 2024-01-15: Added product_line dimension
      - 2024-01-01: Switched to incremental materialization
      - 2023-12-01: Initial creation
    
    meta:
      owner: "finance-analytics@company.com"
      slack_channel: "#finance-data"
      contains_pii: false
      criticality: "high"
      sla_hours: 4
    
    config:
      materialized: incremental
      unique_key: revenue_id
      tags: ['finance', 'revenue', 'critical', 'daily']
    
    tests:
      - dbt_expectations.expect_table_row_count_to_be_between:
          min_value: 1000000
          max_value: 100000000
          config:
            severity: error
      
      - dbt_utils.expression_is_true:
          expression: "net_revenue_usd = amount_usd - fee_amount_usd"
          config:
            severity: error
    
    columns:
      - name: revenue_id
        description: "Surrogate key: hash of payment_id + line_item_id"
        tests:
          - unique:
              config:
                severity: error
          - not_null:
              config:
                severity: error
      
      - name: payment_id
        description: "Foreign key to payment system"
        tests:
          - not_null
          - relationships:
              to: ref('stg_stripe__payments')
              field: payment_id
      
      - name: customer_id
        description: "Foreign key to dim_customers"
        tests:
          - not_null:
              config:
                severity: warn
          - relationships:
              to: ref('dim_customers')
              field: customer_id
              config:
                severity: warn
      
      - name: product_id
        description: "Foreign key to dim_products"
        tests:
          - relationships:
              to: ref('dim_products')
              field: product_id
      
      - name: transaction_date_id
        description: "Date of transaction (partition key)"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: "'2020-01-01'"
              max_value: "current_date + interval '1 day'"
      
      - name: amount_usd
        description: |
          Transaction amount in USD.
          
          Converted from original currency using daily exchange rates.
          Null values indicate missing exchange rate data.
        tests:
          - not_null:
              config:
                severity: warn
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: -1000000
              max_value: 1000000
      
      - name: net_revenue_usd
        description: |
          Net revenue after fees (amount_usd - fee_amount_usd).
          
          This is the primary metric for revenue reporting.
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: -1000000
              max_value: 1000000
      
      - name: revenue_type
        description: "Classification of transaction type"
        tests:
          - accepted_values:
              values: ['Revenue', 'Refund', 'Pending', 'Other']
      
      - name: data_quality_flag
        description: "Data quality indicator for monitoring"
        tests:
          - accepted_values:
              values: ['Valid', 'Missing Customer', 'Missing Product', 'Missing Amount']
```

---

## Summary & Quick Reference

### Project Setup Checklist

```
✅ Folder structure defined by layer (staging/intermediate/marts)
✅ Naming conventions documented and enforced
✅ Source systems organized and documented
✅ Domain boundaries established
✅ Materialization strategy defined
✅ Testing standards set
✅ Documentation requirements clear
✅ CI/CD pipeline configured
✅ Code review process established
✅ Ownership defined (CODEOWNERS)
✅ Development environment standardized
✅ Performance monitoring in place
```

### Command Reference

```bash
# Development
dbt run --select staging.salesforce  # Run specific source
dbt run --select marts.finance+      # Run domain and downstream
dbt run --select +fct_revenue        # Run model and upstream
dbt test --select fct_revenue        # Test specific model

# Testing
dbt test                             # Run all tests
dbt test --select source:*           # Test source freshness
dbt test --select tag:critical       # Test tagged models

# Documentation
dbt docs generate                    # Generate documentation
dbt docs serve                       # Serve documentation locally

# Production
dbt build --select state:modified+   # Build changed models (CI)
dbt run --full-refresh              # Full refresh (weekly)
dbt snapshot                         # Run snapshots

# Debugging
dbt compile --select model_name      # Compile without running
dbt show --select model_name         # Preview query results
dbt run-operation macro_name         # Run macro
```

### Key Metrics to Track

**Development Velocity:**
- Time to add new source
- Time to build new mart
- PR review time
- Mean time to fix broken model

**Data Quality:**
- Test pass rate
- Data freshness
- Row count anomalies
- Null rate trends

**Performance:**
- Model run times
- Incremental efficiency
- Query costs
- Build duration

**Adoption:**
- Models in production use
- Dashboard/report dependencies
- API/tool integrations
- Team coverage

---

## Additional Resources

### Recommended Packages

```yaml
# packages.yml

packages:
  # Utilities
  - package: dbt-labs/dbt_utils
    version: 1.1.1
  
  # Testing
  - package: calogica/dbt_expectations
    version: 0.10.0
  
  # Date utilities
  - package: calogica/dbt_date
    version: 0.9.0
  
  # Audit columns
  - package: dbt-labs/audit_helper
    version: 0.9.0
  
  # Code generation
  - package: dbt-labs/codegen
    version: 0.11.0
  
  # Metrics
  - package: dbt-labs/metrics
    version: 1.6.0
```

### Learning Resources

- [dbt Documentation](https://docs.getdbt.com)
- [dbt Discourse Community](https://discourse.getdbt.com)
- [dbt Best Practices Guide](https://docs.getdbt.com/guides/best-practices)
- [Analytics Engineering Roundup](https://roundup.getdbt.com)
- [dbt Learn (Free Courses)](https://courses.getdbt.com)

### Tools & Integrations

- **Orchestration**: Dagster, Airflow, Prefect
- **BI Tools**: Tableau, Looker, PowerBI, Metabase
- **Data Quality**: Great Expectations, Monte Carlo, Datafold
- **Observability**: Elementary, dbt Cloud, re_data
- **Version Control**: GitHub, GitLab, Bitbucket
- **CI/CD**: GitHub Actions, GitLab CI, CircleCI

---

## Conclusion

With 80 sources and 180 models, you're building an enterprise-scale data platform. Success requires:

1. **Clear Structure**: Consistent organization that scales
2. **Strong Standards**: Naming, testing, documentation conventions
3. **Team Collaboration**: Ownership, code review, CI/CD
4. **Performance Focus**: Right materialization, incremental strategies
5. **Quality Assurance**: Comprehensive testing at all layers

Remember: The best structure is one your team actually follows. Start with these patterns, adapt to your needs, and iterate based on feedback.

Good luck building! 🚀