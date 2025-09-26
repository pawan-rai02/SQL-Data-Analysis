/*
=====================================================================
Customer Report
=====================================================================
Purpose :
	- This report consolidates key customer metrics and behaviours

Highlights :
	1. Gathers essential fields such as names, ages, and transaction details
	2. Segments customers into categories (VIP, REGULAR, NEW) and age groups
	3. Aggregates customer-level metrices:
		- total orders
		- total sales
		- total quantity purchased
		- total products
		- lifespan (in months)
	4. Calculates valuable KPIs:
		- recency (months since last order)
		- average order value
		- average monthly spend 
=======================================================================


-----------------------------------------------------------------------*/

create view gold.report_customers as 

with base_query as(
/*-------------------------------------------------
1) Base Query : Retrives core columns from tables
---------------------------------------------------*/
select
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
concat(c.first_name, ' ', c.last_name) as customer_name,
datediff(year, c.birthdate, getdate()) as age
from gold.fact_saless as f
left join gold.dim_customers as c
on c.customer_key = f.customer_key
)

, customer_agg as (

/*---------------------------------------------------------------
2) Customer Aggregation : Summarizes key metrics at customer level
-----------------------------------------------------------------*/

select 
customer_key,
customer_number,
customer_name,
age,
count(distinct order_number) as total_orders,
sum(sales_amount) as total_sales,
sum(quantity) as total_quantity,
count(distinct product_key) as total_products,
max(order_date) as last_order_date,
min(order_date) as first_order,
datediff(mm, min(order_date), max(order_date)) as lifespan

from base_query
group by customer_key,
		 customer_number,
		 customer_name,
		 age
)



select customer_key,
customer_number,
customer_name,
age,

case when age < 20 then 'Under 20'
when age between 20 and 29 then '20 - 29'
when age between 30 and 39 then '30 - 39'
when age between 40 and 49 then '30 - 49'
else 'Above 50'
end as age_group,

case when lifespan >= 12 and total_sales >= 5000 then 'Vip'
when lifespan >= 12 and total_sales < 5000 then 'Regular' 
else 'New'
end as customer_segment,

total_orders,
total_sales,
total_quantity,
total_products,
last_order_date,
datediff(mm, last_order_date, GETDATE()) as recency,
lifespan,

--compute avg order value
case when total_orders = 0 then 0
else total_sales / total_orders  
end as avg_order_values,

--compute avg monthly spend
case when lifespan = 0 then total_sales
else total_sales / lifespan
end as avg_monthly_spend
from customer_agg

