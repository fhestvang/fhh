/*
    Orders Fact Table (Kimball-style)
    Grain: One row per order
    Contains foreign keys to dimensions and order-level metrics
*/

with orders as (
    select * from {{ ref('brz_jaffle_shop_api__orders') }}
),

payments as (
    select * from {{ ref('slv_payments__pivoted') }}
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
        coalesce(p.total_amount, 0) as order_amount,
        coalesce(p.credit_card_amount, 0) as credit_card_amount,
        coalesce(p.coupon_amount, 0) as coupon_amount,
        coalesce(p.bank_transfer_amount, 0) as bank_transfer_amount,
        coalesce(p.gift_card_amount, 0) as gift_card_amount,

        -- Semi-additive metrics
        coalesce(p.number_of_payment_methods, 0) as payment_method_count,
        coalesce(p.number_of_payments, 0) as payment_count,

        -- Derived metrics
        case
            when coalesce(p.number_of_payments, 0) > 0
            then p.total_amount / p.number_of_payments
            else 0
        end as average_payment_amount,

        -- Audit fields
        current_timestamp as created_at

    from orders as o
    left join payments as p on o.order_id = p.order_id
)

select * from final
order by order_key
