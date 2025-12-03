with source as (
    select * from {{ source('jaffle_shop_api', 'raw_stores') }}
),

renamed as (
    select
        id as store_id,
        name as store_name,
        tax_rate,
        opened_at,
        _dlt_load_id,
        _dlt_id

    from source
)

select * from renamed
