-- This test checks that a customer's customer_value is always
-- greater than or equal to their average order value.
-- If this fails, something is wrong with our business logic.

select
    customer_id,
    customer_rank,
    customer_value,
    average_order_value,
    days_as_customer

from {{ ref('customer_lifetime_value') }}

where customer_value < average_order_value