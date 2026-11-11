{{ config(materialized='view') }}

with recursive category_tree as (
    -- Корневые категории: родителя нет, поэтому корень совпадает с текущей категорией.
    select
        category_id,
        category_name,
        parent_category_id,
        null::text as parent_category_name,
        category_id as root_category_id,
        category_name as root_category_name
    from {{ ref('stg_shop__product_categories') }}
    where parent_category_id is null

    union all

    -- Каждый уровень присоединяется к уже развёрнутому родителю.
    -- Фиксированное число JOIN здесь не используется, поэтому глубина дерева не ограничена.
    select
        child.category_id,
        child.category_name,
        child.parent_category_id,
        parent.category_name as parent_category_name,
        parent.root_category_id,
        parent.root_category_name
    from {{ ref('stg_shop__product_categories') }} as child
    inner join category_tree as parent
        on child.parent_category_id = parent.category_id
)

select
    category_id,
    category_name,
    parent_category_id,
    parent_category_name,
    root_category_id,
    root_category_name
from category_tree
