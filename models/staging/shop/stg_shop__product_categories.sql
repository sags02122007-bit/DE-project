{{ config(materialized='view') }}

select
    category_id,
    parent_category_id,
    category_name
from {{ source('shop', 'product_categories') }}
