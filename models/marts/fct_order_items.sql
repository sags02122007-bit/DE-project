{{ config(
    materialized='table',
    distributed_by='order_id',
    orientation='column'
) }}

select
    order_item_id,
    order_id,
    product_id,
    customer_id,
    order_date,
    quantity,
    unit_price,
    discount_amount,
    line_amount,
    is_confirmed
from {{ ref('int_order_items_enriched') }}
where not is_test_order
