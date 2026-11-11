{{ config(materialized='view') }}

select
    product_id,
    category as category_name,
    brand,
    product_name
from {{ source('shop', 'products') }}
