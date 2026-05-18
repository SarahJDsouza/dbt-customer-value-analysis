--import CTE
with source as (
    select
       *
    from {{ ref('raw_items') }}
)

--renamed CTE

renamed as (

    select
        id as item_id,
        order_id,
        sku

    from source

)

--select statement
select * from renamed
