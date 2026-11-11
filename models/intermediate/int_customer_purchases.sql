{{ config(materialized='view') }}

select
    customer_id,
    order_id,
    first_paid_at as paid_at,
    order_amount
from {{ ref('int_orders_with_payments') }}
where is_confirmed
  and not is_test_order
