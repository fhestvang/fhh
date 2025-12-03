/*
    Customer Dimension Table (Kimball Type 2 SCD Ready)
    Contains all customer attributes and history
*/

with customers as (
    select * from {{ ref('stg_jaffle_shop__customers') }}
),

customer_orders as (
    select * from {{ ref('stg_jaffle_shop__orders') }}
),

customer_payments as (
    select * from {{ ref('stg_jaffle_shop__payments') }}
),

-- Aggregate customer metrics
customer_metrics as (
    select
        o.customer_id,
        min(o.order_date) as first_order_date,
        max(o.order_date) as most_recent_order_date,
        count(distinct o.order_id) as number_of_orders,
        sum(p.amount) as lifetime_value

    from customer_orders as o
    left join customer_payments as p on o.order_id = p.order_id
    group by o.customer_id
),

final as (
    select
        -- Surrogate key
        c.customer_id as customer_key,

        -- Natural key
        c.customer_id,

        -- Customer attributes
        c.first_name,
        c.last_name,
        c.first_name || ' ' || c.last_name as full_name,

        -- Order metrics
        coalesce(cm.first_order_date, null) as first_order_date,
        coalesce(cm.most_recent_order_date, null) as most_recent_order_date,
        coalesce(cm.number_of_orders, 0) as total_orders,
        coalesce(cm.lifetime_value, 0) as lifetime_value,

        -- Customer segmentation
        case
            when coalesce(cm.lifetime_value, 0) = 0 then 'No Orders'
            when cm.lifetime_value < 20 then 'Low Value'
            when cm.lifetime_value < 50 then 'Medium Value'
            when cm.lifetime_value < 100 then 'High Value'
            else 'VIP'
        end as customer_segment,

        case
            when coalesce(cm.number_of_orders, 0) = 0 then 'New'
            when cm.number_of_orders = 1 then 'One-Time'
            when cm.number_of_orders <= 3 then 'Occasional'
            when cm.number_of_orders <= 10 then 'Regular'
            else 'Frequent'
        end as customer_frequency,

        -- Average order value
        case
            when coalesce(cm.number_of_orders, 0) = 0 then 0
            else cm.lifetime_value / cm.number_of_orders
        end as average_order_value,

        -- Recency (days since last order)
        case
            when cm.most_recent_order_date is not null
            then date_diff('day', cm.most_recent_order_date::date, current_date)
            else null
        end as days_since_last_order,

        -- Customer tenure (days since first order)
        case
            when cm.first_order_date is not null
            then date_diff('day', cm.first_order_date::date, current_date)
            else null
        end as customer_tenure_days,

        -- SCD Type 2 fields (for future use)
        current_date as effective_date,
        '9999-12-31'::date as expiration_date,
        true as is_current

    from customers as c
    left join customer_metrics as cm on c.customer_id = cm.customer_id
)

select * from final
order by customer_key
