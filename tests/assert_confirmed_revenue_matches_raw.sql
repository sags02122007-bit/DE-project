-- Подтверждённая выручка в факте сверяется с независимым расчётом по raw orders/payments.
-- В raw расчёте заказ подтверждается статусом paid и наличием успешной операции,
-- которая не является возвратом (сумма операции неотрицательна).
with mart_revenue as (
    select
        coalesce(sum(order_amount), 0)::numeric(18, 2) as revenue
    from {{ ref('fct_orders') }}
    where is_confirmed
),

raw_revenue as (
    select
        coalesce(sum(o.total_amount), 0)::numeric(18, 2) as revenue
    from {{ source('shop', 'orders') }} as o
    where o.status = 'paid'
      and exists (
          select 1
          from {{ source('shop', 'payments') }} as p
          where p.order_id = o.order_id
            and p.payment_status = 'success'
            and p.amount >= 0
      )
)

select
    m.revenue as mart_confirmed_revenue,
    r.revenue as raw_confirmed_revenue
from mart_revenue as m
cross join raw_revenue as r
where m.revenue <> r.revenue
