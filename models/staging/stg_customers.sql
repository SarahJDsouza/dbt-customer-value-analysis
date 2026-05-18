--import CTE
with source as (
    select
       *
    from {{ ref('raw_customers') }}
),

--renamed CTE
renamed as (

    select
        id as customer_id,
        name as customer_name

    from source

)

--select statement
select * from renamed