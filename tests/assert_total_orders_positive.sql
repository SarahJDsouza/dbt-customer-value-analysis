-- every customer must have at least 1 order
select
    customer_id,
    total_orders

from {{ ref('customer_lifetime_value') }}

where total_orders <= 0