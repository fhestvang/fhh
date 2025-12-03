with source as (
    select * from {{ source('jaffle_shop_api', 'raw_supplies') }}
),

renamed as (
    select
        id as supply_id,
        name as supply_name,
        sku as product_sku,
        cost,
        perishable,
        _dlt_load_id,
        _dlt_id

    from source
)

select * from renamed
