with source as (
    select * from {{ source('jaffle_shop_api', 'raw_supplies') }}
),

deduped as (
    -- Deduplicate by keeping the most recent load for each supply_id
    select *,
        row_number() over (partition by id order by _dlt_load_id desc, _dlt_id desc) as row_num
    from source
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

    from deduped
    where row_num = 1
)

select * from renamed
