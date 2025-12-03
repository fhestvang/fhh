/*
    Date Dimension Table (Kimball-style)
    Generates a comprehensive date dimension with various date attributes
    for analytical queries and time-based filtering.

    Features:
    - Calendar and fiscal year support
    - ISO 8601 week numbering
    - US and European holidays
    - Business day calculations
    - Season attributes
*/

with date_spine as (
    -- Generate dates from config vars (date_dimension_start to date_dimension_end)
    select
        date_value::date as date_key
    from (
        select
            '{{ var("date_dimension_start") }}'::date + (row_number() over (order by 1) - 1) * interval '1 day' as date_value
        from range(0, datediff('day', '{{ var("date_dimension_start") }}'::date, '{{ var("date_dimension_end") }}'::date) + 1)
    )
),

holidays as (
    -- US Federal Holidays and major European holidays
    select date_key, holiday_name, holiday_type from (
        select unnest([
            -- US Federal Holidays (recurring)
            date '2018-01-01', date '2019-01-01', date '2020-01-01', date '2021-01-01',
            date '2022-01-01', date '2023-01-01', date '2024-01-01', date '2025-01-01',
            date '2026-01-01', date '2027-01-01', date '2028-01-01', date '2029-01-01', date '2030-01-01'
        ]) as date_key,
        'New Year''s Day' as holiday_name,
        'US Federal' as holiday_type

        union all

        -- Christmas
        select unnest([
            date '2018-12-25', date '2019-12-25', date '2020-12-25', date '2021-12-25',
            date '2022-12-25', date '2023-12-25', date '2024-12-25', date '2025-12-25',
            date '2026-12-25', date '2027-12-25', date '2028-12-25', date '2029-12-25', date '2030-12-25'
        ]) as date_key,
        'Christmas Day' as holiday_name,
        'US Federal' as holiday_type

        union all

        -- Independence Day
        select unnest([
            date '2018-07-04', date '2019-07-04', date '2020-07-04', date '2021-07-04',
            date '2022-07-04', date '2023-07-04', date '2024-07-04', date '2025-07-04',
            date '2026-07-04', date '2027-07-04', date '2028-07-04', date '2029-07-04', date '2030-07-04'
        ]) as date_key,
        'Independence Day' as holiday_name,
        'US Federal' as holiday_type

        union all

        -- Thanksgiving (4th Thursday of November)
        select unnest([
            date '2018-11-22', date '2019-11-28', date '2020-11-26', date '2021-11-25',
            date '2022-11-24', date '2023-11-23', date '2024-11-28', date '2025-11-27',
            date '2026-11-26', date '2027-11-25', date '2028-11-23', date '2029-11-22', date '2030-11-28'
        ]) as date_key,
        'Thanksgiving' as holiday_name,
        'US Federal' as holiday_type

        union all

        -- Labor Day (1st Monday of September)
        select unnest([
            date '2018-09-03', date '2019-09-02', date '2020-09-07', date '2021-09-06',
            date '2022-09-05', date '2023-09-04', date '2024-09-02', date '2025-09-01',
            date '2026-09-07', date '2027-09-06', date '2028-09-04', date '2029-09-03', date '2030-09-02'
        ]) as date_key,
        'Labor Day' as holiday_name,
        'US Federal' as holiday_type

        union all

        -- Memorial Day (Last Monday of May)
        select unnest([
            date '2018-05-28', date '2019-05-27', date '2020-05-25', date '2021-05-31',
            date '2022-05-30', date '2023-05-29', date '2024-05-27', date '2025-05-26',
            date '2026-05-25', date '2027-05-31', date '2028-05-29', date '2029-05-28', date '2030-05-27'
        ]) as date_key,
        'Memorial Day' as holiday_name,
        'US Federal' as holiday_type

        union all

        -- European Holidays - Easter Monday (varies)
        select unnest([
            date '2018-04-02', date '2019-04-22', date '2020-04-13', date '2021-04-05',
            date '2022-04-18', date '2023-04-10', date '2024-04-01', date '2025-04-21',
            date '2026-04-06', date '2027-03-29', date '2028-04-17', date '2029-04-02', date '2030-04-22'
        ]) as date_key,
        'Easter Monday' as holiday_name,
        'European' as holiday_type
    )
),

date_dimension as (
    select
        date_spine.date_key,

        -- Date identifiers
        strftime(date_spine.date_key, '%Y%m%d')::int as date_id,

        -- Year attributes
        year(date_spine.date_key) as year,
        strftime(date_spine.date_key, '%Y')::int as year_number,
        case
            when month(date_spine.date_key) <= 3 then year(date_spine.date_key) - 1
            else year(date_spine.date_key)
        end as fiscal_year,

        -- Quarter attributes
        quarter(date_spine.date_key) as quarter,
        'Q' || quarter(date_spine.date_key)::varchar as quarter_name,
        year(date_spine.date_key)::varchar || '-Q' || quarter(date_spine.date_key)::varchar as year_quarter,
        case
            when month(date_spine.date_key) in (1, 2, 3) then 4
            when month(date_spine.date_key) in (4, 5, 6) then 1
            when month(date_spine.date_key) in (7, 8, 9) then 2
            else 3
        end as fiscal_quarter,

        -- Month attributes
        month(date_spine.date_key) as month,
        strftime(date_spine.date_key, '%m')::int as month_number,
        strftime(date_spine.date_key, '%B')::varchar as month_name,
        strftime(date_spine.date_key, '%b')::varchar as month_name_short,
        strftime(date_spine.date_key, '%Y-%m')::varchar as year_month,

        -- Week attributes
        week(date_spine.date_key) as week_of_year,
        strftime(date_spine.date_key, 'W%W')::varchar as week_name,
        strftime(date_spine.date_key, '%Y-W%W')::varchar as year_week,

        -- ISO 8601 week attributes
        isoyear(date_spine.date_key) as iso_year,
        weekofyear(date_spine.date_key) as iso_week,
        isoyear(date_spine.date_key)::varchar || '-W' || lpad(weekofyear(date_spine.date_key)::varchar, 2, '0') as iso_year_week,

        -- Day attributes
        day(date_spine.date_key) as day_of_month,
        dayofweek(date_spine.date_key) as day_of_week,  -- 0 = Sunday, 6 = Saturday
        strftime(date_spine.date_key, '%A')::varchar as day_name,
        strftime(date_spine.date_key, '%a')::varchar as day_name_short,
        dayofyear(date_spine.date_key) as day_of_year,

        -- Business day flags
        case
            when dayofweek(date_spine.date_key) in (0, 6) then false
            else true
        end as is_weekday,
        case
            when dayofweek(date_spine.date_key) in (0, 6) then true
            else false
        end as is_weekend,

        -- Period flags
        case when day(date_spine.date_key) = 1 then true else false end as is_month_start,
        case when day(date_spine.date_key) = day(last_day(date_spine.date_key)) then true else false end as is_month_end,
        case
            when month(date_spine.date_key) = 1 and day(date_spine.date_key) = 1 then true
            else false
        end as is_year_start,
        case
            when month(date_spine.date_key) = 12 and day(date_spine.date_key) = 31 then true
            else false
        end as is_year_end,

        -- Relative date helpers
        date_spine.date_key = current_date as is_today,
        date_spine.date_key = current_date - interval '1 day' as is_yesterday,
        date_spine.date_key >= date_trunc('week', current_date) and
        date_spine.date_key < date_trunc('week', current_date) + interval '7 days' as is_current_week,
        date_spine.date_key >= date_trunc('month', current_date) and
        date_spine.date_key < date_trunc('month', current_date) + interval '1 month' as is_current_month,
        date_spine.date_key >= date_trunc('quarter', current_date) and
        date_spine.date_key < date_trunc('quarter', current_date) + interval '3 months' as is_current_quarter,
        date_spine.date_key >= date_trunc('year', current_date) and
        date_spine.date_key < date_trunc('year', current_date) + interval '1 year' as is_current_year,

        -- Date math helpers
        date_trunc('week', date_spine.date_key) as week_start_date,
        date_trunc('month', date_spine.date_key) as month_start_date,
        date_trunc('quarter', date_spine.date_key) as quarter_start_date,
        date_trunc('year', date_spine.date_key) as year_start_date,

        -- Season attributes (Northern Hemisphere)
        case
            when month(date_spine.date_key) in (12, 1, 2) then 'Winter'
            when month(date_spine.date_key) in (3, 4, 5) then 'Spring'
            when month(date_spine.date_key) in (6, 7, 8) then 'Summer'
            else 'Fall'
        end as season,
        case
            when month(date_spine.date_key) in (12, 1, 2) then 1
            when month(date_spine.date_key) in (3, 4, 5) then 2
            when month(date_spine.date_key) in (6, 7, 8) then 3
            else 4
        end as season_number,

        -- Holiday attributes
        h.holiday_name,
        h.holiday_type,
        case when h.holiday_name is not null then true else false end as is_holiday,

        -- Working day calculation (excludes weekends and holidays)
        case
            when dayofweek(date_spine.date_key) in (0, 6) then false
            when h.holiday_name is not null then false
            else true
        end as is_working_day,

        -- Business metrics
        case
            when dayofweek(date_spine.date_key) not in (0, 6) and h.holiday_name is null then 1
            else 0
        end as trading_day_flag,

        -- Human-readable formats
        strftime(date_spine.date_key, '%Y-%m-%d')::varchar as date_formatted,
        strftime(date_spine.date_key, '%m/%d/%Y')::varchar as date_us_format,
        strftime(date_spine.date_key, '%d/%m/%Y')::varchar as date_eu_format,
        strftime(date_spine.date_key, '%B %d, %Y')::varchar as date_long_format

    from date_spine
    left join holidays h on date_spine.date_key = h.date_key
)

select * from date_dimension
order by date_dimension.date_key
