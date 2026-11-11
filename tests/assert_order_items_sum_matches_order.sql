-- Сумма товарных позиций в факте должна совпадать с суммой соответствующего заказа.
-- Тест сравнивает именно две marts-витрины; возвращаются только расхождения.
with item_totals as (
    select
        order_id,
        sum(line_amount)::numeric(18, 2) as items_amount
    from {{ ref('fct_order_items') }}
    group by order_id
)

select
    o.order_id,
    o.order_amount,
    coalesce(i.items_amount, 0)::numeric(18, 2) as items_amount
from {{ ref('fct_orders') }} as o
left join item_totals as i
    on i.order_id = o.order_id
where coalesce(i.items_amount, 0)::numeric(18, 2)
      <> o.order_amount::numeric(18, 2)
