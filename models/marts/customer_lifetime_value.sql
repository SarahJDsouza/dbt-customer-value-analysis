with customers as (
    select * from {{ ref('stg_customers') }}
),

orders as (
    select * from {{ ref('stg_orders') }}
),

customer_orders as (
    select
        customer_id,
        count(order_id) as total_orders,
        round(sum(order_total) / count(order_id), 2) as average_order_value,
        round(sum(order_total) / count(order_id) * count(order_id), 2) as customer_value,
        date_diff(max(ordered_at), min(ordered_at), day) / 365.0 as customer_lifespan_years,
        date_diff(max(ordered_at), min(ordered_at), day) as customer_lifespan_days,
        min(ordered_at) as first_order_date,
        max(ordered_at) as most_recent_order_date

    from orders
    group by customer_id
),

final as (
    select
        customers.customer_id,
        customers.customer_name,
        customer_orders.total_orders,
        customer_orders.average_order_value,
        customer_orders.customer_value,
        round(customer_orders.customer_value * customer_orders.customer_lifespan_years, 2) as customer_lifetime_value,
        case
            when customer_orders.customer_lifespan_days between 0 and 4 then 'occasional'
            when customer_orders.customer_lifespan_days between 5 and 10 then 'returning'
            else 'loyal'
        end as customer_segment,
        round(customer_orders.customer_value * customer_orders.customer_lifespan_days, 2) as weighted_score,
        rank() over (
            partition by case
                when customer_orders.customer_lifespan_days between 0 and 4 then 'occasional'
                when customer_orders.customer_lifespan_days between 5 and 10 then 'returning'
                else 'loyal'
            end
            order by customer_orders.customer_value * customer_orders.customer_lifespan_days desc
        ) as customer_rank,
        customer_orders.first_order_date,
        customer_orders.most_recent_order_date,
        date_diff(max(customer_orders.most_recent_order_date) over(), customer_orders.first_order_date, day) as days_as_customer

    from customers
    left join customer_orders using (customer_id)
)

select * from final