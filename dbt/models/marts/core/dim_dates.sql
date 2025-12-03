/*
    Date Dimension Table (Kimball-style)
    Generates a comprehensive date dimension with various date attributes
    for analytical queries and time-based filtering.
*/

with date_spine as (
    -- Generate dates from 2018-01-01 to 2030-12-31
    -- Adjust range based on your data needs
    select
        date_value::date as date_key
    from (
        select
            '2018-01-01'::date + (row_number() over (order by 1) - 1) * interval '1 day' as date_value
        from range(0, 4748)  -- Generates ~13 years of dates
    )
),

date_dimension as (
    select
        date_key,

        -- Date identifiers
        strftime(date_key, '%Y%m%d')::int as date_id,

        -- Year attributes
        year(date_key) as year,
        strftime(date_key, '%Y')::int as year_number,
        case
            when month(date_key) <= 3 then year(date_key) - 1
            else year(date_key)
        end as fiscal_year,

        -- Quarter attributes
        quarter(date_key) as quarter,
        'Q' || quarter(date_key)::varchar as quarter_name,
        year(date_key)::varchar || '-Q' || quarter(date_key)::varchar as year_quarter,
        case
            when month(date_key) in (1, 2, 3) then 4
            when month(date_key) in (4, 5, 6) then 1
            when month(date_key) in (7, 8, 9) then 2
            else 3
        end as fiscal_quarter,

        -- Month attributes
        month(date_key) as month,
        strftime(date_key, '%m')::int as month_number,
        strftime(date_key, '%B')::varchar as month_name,
        strftime(date_key, '%b')::varchar as month_name_short,
        strftime(date_key, '%Y-%m')::varchar as year_month,

        -- Week attributes
        week(date_key) as week_of_year,
        strftime(date_key, 'W%W')::varchar as week_name,
        strftime(date_key, '%Y-W%W')::varchar as year_week,

        -- Day attributes
        day(date_key) as day_of_month,
        dayofweek(date_key) as day_of_week,  -- 0 = Sunday, 6 = Saturday
        strftime(date_key, '%A')::varchar as day_name,
        strftime(date_key, '%a')::varchar as day_name_short,
        dayofyear(date_key) as day_of_year,

        -- Business day flags
        case
            when dayofweek(date_key) in (0, 6) then false
            else true
        end as is_weekday,
        case
            when dayofweek(date_key) in (0, 6) then true
            else false
        end as is_weekend,

        -- Period flags
        case when day(date_key) = 1 then true else false end as is_month_start,
        case when day(date_key) = day(last_day(date_key)) then true else false end as is_month_end,
        case
            when month(date_key) = 1 and day(date_key) = 1 then true
            else false
        end as is_year_start,
        case
            when month(date_key) = 12 and day(date_key) = 31 then true
            else false
        end as is_year_end,

        -- Relative date helpers
        date_key = current_date as is_today,
        date_key = current_date - interval '1 day' as is_yesterday,
        date_key >= date_trunc('week', current_date) and
        date_key < date_trunc('week', current_date) + interval '7 days' as is_current_week,
        date_key >= date_trunc('month', current_date) and
        date_key < date_trunc('month', current_date) + interval '1 month' as is_current_month,
        date_key >= date_trunc('quarter', current_date) and
        date_key < date_trunc('quarter', current_date) + interval '3 months' as is_current_quarter,
        date_key >= date_trunc('year', current_date) and
        date_key < date_trunc('year', current_date) + interval '1 year' as is_current_year,

        -- Date math helpers
        date_trunc('week', date_key) as week_start_date,
        date_trunc('month', date_key) as month_start_date,
        date_trunc('quarter', date_key) as quarter_start_date,
        date_trunc('year', date_key) as year_start_date,

        -- Human-readable formats
        strftime(date_key, '%Y-%m-%d')::varchar as date_formatted,
        strftime(date_key, '%m/%d/%Y')::varchar as date_us_format,
        strftime(date_key, '%d/%m/%Y')::varchar as date_eu_format,
        strftime(date_key, '%B %d, %Y')::varchar as date_long_format

    from date_spine
)

select * from date_dimension
order by date_key
