{{
    config(
        materialized='view'
    )
}}

/*
    Intermediate Payments Model

    Pivots payment data by payment method and aggregates to order grain.
    This avoids duplicating pivot logic across multiple fact tables.
*/

with payments as (
    select * from {{ ref('brz_jaffle_shop_api__payments') }}
),

pivoted as (
    select
        order_id,

        -- Aggregate metrics
        sum(amount) as total_amount,
        sum(case when payment_method = 'credit_card' then amount else 0 end) as credit_card_amount,
        sum(case when payment_method = 'coupon' then amount else 0 end) as coupon_amount,
        sum(case when payment_method = 'bank_transfer' then amount else 0 end) as bank_transfer_amount,
        sum(case when payment_method = 'gift_card' then amount else 0 end) as gift_card_amount,

        -- Counts
        count(distinct payment_method) as number_of_payment_methods,
        count(*) as number_of_payments

    from payments
    group by order_id
)

select * from pivoted
