-- customer rank should always be a positive number
select
    customer_id,
    customer_rank

from {{ ref('customer_lifetime_value') }}

where customer_rank <= 0