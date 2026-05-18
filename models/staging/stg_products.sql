--import CTE
with source as (

    select * from {{ source('jaffle_shop', 'raw_products') }}

),
--renamed CTE
renamed as (

    select
        sku,
        name,
        type,
        price,
        description

    from source

)
--select statement
select * from renamed