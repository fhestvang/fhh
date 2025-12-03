with source as (
    select * from {{ source('jaffle_shop_api', 'raw_products') }}
),

renamed as (
    select
        sku as product_sku,
        name as product_name,
        type as product_type,
        description,
        price,
        _dlt_load_id,
        _dlt_id

    from source
)

select * from renamed
