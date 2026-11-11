{{ config(
    materialized='table',
    distributed_replicated=true
) }}

with ranked_purchases as (
    select
        customer_id,
        order_id,
        paid_at,
        order_amount,
        row_number() over (
            partition by customer_id
            order by paid_at, order_id
        ) as purchase_rank
    from {{ ref('int_customer_purchases') }}
),

purchase_metrics as (
    select
        customer_id,
        count(*) as confirmed_orders_count,
        sum(order_amount) as confirmed_revenue
    from {{ ref('int_customer_purchases') }}
    group by customer_id
),

first_purchases as (
    select
        customer_id,
        order_id as first_confirmed_order_id,
        paid_at as first_confirmed_at
    from ranked_purchases
    where purchase_rank = 1
)

select
    c.customer_id,
    c.registered_at,
    c.registration_date,
    c.city,
    c.acquisition_channel,
    f.first_confirmed_order_id,
    f.first_confirmed_at,
    coalesce(m.confirmed_orders_count, 0) as confirmed_orders_count,
    coalesce(m.confirmed_revenue, 0)::numeric(18, 2) as confirmed_revenue,
    coalesce(m.confirmed_orders_count, 0) > 0 as is_buyer
from {{ ref('stg_shop__customers') }} as c
left join first_purchases as f
    on f.customer_id = c.customer_id
left join purchase_metrics as m
    on m.customer_id = c.customer_id
