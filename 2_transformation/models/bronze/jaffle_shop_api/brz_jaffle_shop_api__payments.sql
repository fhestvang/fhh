with source as (
    select * from {{ source('jaffle_shop_api', 'raw_payments') }}
),

renamed as (
    select
        id as payment_id,
        order_id,
        payment_method,

        -- amount is stored in cents, convert to dollars
        cast(amount as double) / 100.0 as amount,

        _dlt_load_id,
        _dlt_id

    from source
)

select * from renamed
