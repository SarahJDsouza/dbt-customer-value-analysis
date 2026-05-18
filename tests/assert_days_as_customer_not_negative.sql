-- days as customer should never be negative
-- first order can't come after most recent order

select
    customer_id,
    first_order_date,
    most_recent_order_date,
    days_as_customer

from {{ ref('customer_lifetime_value') }}

where days_as_customer < 0