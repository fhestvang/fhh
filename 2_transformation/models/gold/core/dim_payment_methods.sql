/*
    Payment Method Dimension Table
    Reference dimension for payment methods
*/

select
    row_number() over (order by payment_method) as payment_method_key,
    payment_method as payment_method_id,
    payment_method as payment_method_name,
    case payment_method
        when 'credit_card' then 'Credit Card'
        when 'coupon' then 'Coupon'
        when 'bank_transfer' then 'Bank Transfer'
        when 'gift_card' then 'Gift Card'
        else 'Unknown'
    end as payment_method_display_name,
    case payment_method
        when 'credit_card' then 'Electronic'
        when 'bank_transfer' then 'Electronic'
        when 'coupon' then 'Promotional'
        when 'gift_card' then 'Prepaid'
        else 'Other'
    end as payment_category
from (
    select distinct payment_method
    from {{ ref('brz_jaffle_shop_api__payments') }}
)
order by payment_method_key
