{{ config(severity='warn') }}

-- У подтверждённого заказа сумма успешных положительных списаний
-- не должна превышать сумму заказа.
-- Заказ 113 намеренно содержит два списания по 200 при сумме заказа 200.
select
    o.order_id,
    o.order_amount,
    coalesce(sum(p.amount), 0)::numeric(18, 2) as successful_charges_amount
from {{ ref('fct_orders') }} as o
left join {{ ref('stg_shop__payments') }} as p
    on p.order_id = o.order_id
   and p.payment_status = 'success'
   and p.amount > 0
where o.is_confirmed
group by o.order_id, o.order_amount
having coalesce(sum(p.amount), 0) > o.order_amount
