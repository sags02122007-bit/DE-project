-- По каждому возвращённому заказу чистая сумма оплат и возвратов должна быть нулевой.
-- Проверяется net_paid_amount из факта заказов.
select
    order_id,
    order_amount,
    net_paid_amount
from {{ ref('fct_orders') }}
where order_status = 'returned'
  and net_paid_amount <> 0
