{{ config(
    materialized='table',
    distributed_by='order_id',
    orientation='column'
) }}

with orders as (
    select *
    from {{ ref('int_orders_with_payments') }}
),

order_item_counts as (
    select
        order_id,
        count(distinct product_id) as items_count
    from {{ ref('int_order_items_enriched') }}
    where not is_test_order
    group by order_id
)

select
    o.order_id,
    o.customer_id,
    o.order_date,
    o.ordered_at,
    o.order_status,
    o.order_amount,
    o.paid_amount,
    o.refunded_amount,
    o.net_paid_amount,
    o.successful_payments_count,
    o.first_paid_at,
    o.is_confirmed,
    coalesce(i.items_count, 0) as items_count
from orders as o
left join order_item_counts as i
    on i.order_id = o.order_id
where not o.is_test_order
