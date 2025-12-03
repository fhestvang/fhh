with source as (
    select * from {{ source('jaffle_shop_api', 'raw_orders') }}
),

renamed as (
    select
        id as order_id,
        customer_id,
        store_id,
        ordered_at as order_date,
        subtotal,
        tax_paid,
        order_total,
        _dlt_load_id,
        _dlt_id

    from source
)

select * from renamed
