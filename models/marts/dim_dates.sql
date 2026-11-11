{{ config(
    materialized='table',
    distributed_replicated=true
) }}

{% set orders_relation = ref('stg_shop__orders') %}

with date_spine as (
    {{ dbt_utils.date_spine(
        datepart='day',
        start_date="(select min(order_date)::timestamp from " ~ orders_relation ~ ")",
        end_date="(select (max(order_date) + interval '1 day')::timestamp from " ~ orders_relation ~ ")"
    ) }}
)

select
    date_day::date as date_day,
    extract(year from date_day)::integer as year,
    extract(quarter from date_day)::integer as quarter,
    extract(month from date_day)::integer as month,
    extract(isodow from date_day)::integer as day_of_week,
    extract(isodow from date_day) in (6, 7) as is_weekend
from date_spine
