--import CTE
with source as (

    select * from {{ source('jaffle_shop', 'raw_orders') }}

),

--renamed CTE
renamed as (

    select
        id as order_id,
        customer as customer_id,
        ordered_at,
        store_id,
        subtotal,
        tax_paid,
        order_total

    from source

)

--select statement
select * from renamed