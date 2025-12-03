with source as (
    select * from {{ source('jaffle_shop_api', 'raw_customers') }}
),

renamed as (
    select
        id as customer_id,
        name as customer_name,
        _dlt_load_id,
        _dlt_id

    from source
)

select * from renamed
