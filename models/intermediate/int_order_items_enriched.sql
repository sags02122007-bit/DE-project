{{ config(materialized='view') }}

select
    i.order_item_id,
    i.order_id,
    i.product_id,
    o.customer_id,
    o.order_date,
    o.ordered_at,
    i.quantity,
    i.unit_price,
    i.discount_amount,
    i.gross_amount,
    i.line_amount,
    o.is_test_order,
    o.order_status,
    o.is_confirmed
from {{ ref('stg_shop__order_items') }} as i
inner join {{ ref('int_orders_with_payments') }} as o
    on o.order_id = i.order_id
