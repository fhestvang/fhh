with source as (
    select * from {{ source('jaffle_shop_api', 'raw_items') }}
),

renamed as (
    select
        id as item_id,
        order_id,
        sku as product_sku,
        _dlt_load_id,
        _dlt_id

    from source
)

select * from renamed
