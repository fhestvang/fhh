/*
    Orders Fact Table (Kimball-style)
    Grain: One row per order
    Contains foreign keys to dimensions and order-level metrics
*/

with orders as (
    select * from {{ ref('brz_jaffle_shop_api__orders') }}
),

final as (
    select
        -- Fact table primary key
        o.order_id as order_key,

        -- Foreign keys to dimensions
        o.customer_id as customer_key,
        o.order_date::date as order_date_key,

        -- Degenerate dimensions (attributes stored in fact table)
        o.order_id,
        o.store_id,

        -- Metrics (additive)
        o.subtotal,
        o.tax_paid,
        o.order_total,

        -- Audit fields
        current_timestamp as created_at

    from orders as o
)

select * from final
order by order_key
