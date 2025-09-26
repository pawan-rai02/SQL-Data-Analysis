/*
===============================================================
Product Report
===============================================================
Purpose :
    - This report consolidates key product metrics and behaviours

Highlights :
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High_performers, Mid-Range, or Low_performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
===============================================================================
*/

-- =============================================================================
-- Create Report: gold.report_products
-- =============================================================================

IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
    DROP VIEW gold.report_products;
GO

CREATE VIEW gold.report_products AS


WITH base_query AS (
    /*--------------------------------------------------------------------------
    1) Base query :  retrieves core columns from fact_sales and dim_products
    --------------------------------------------------------------------------*/
    SELECT
        f.order_number,
        f.order_date,
        f.customer_key,
        f.sales_amount,
        f.quantity,
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost
    FROM gold.fact_saless AS f
    LEFT JOIN gold.dim_products AS p
        ON p.product_key = f.product_key
    WHERE f.order_date IS NOT NULL
),

product_aggregations AS (
    /*--------------------------------------------------------------------------
    2) Product Aggregations :  summarizes key metrics at product level
    --------------------------------------------------------------------------*/
    SELECT 
        product_key,
        product_name,
        category,
        subcategory,
        cost,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
        MAX(order_date) AS last_sale_date,
        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT customer_key) AS total_customers,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)), 1) AS avg_selling_price
    FROM base_query
    GROUP BY 
        product_key,
        product_name,
        category,
        subcategory,
        cost
)

/*--------------------------------------------------------------------------
3) Final Query : combines all product results into one output
--------------------------------------------------------------------------*/
SELECT 
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    last_sale_date,
    DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months,
    CASE 
        WHEN total_sales > 50000 THEN 'High_Performer'
        WHEN total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low_Performer'
    END AS product_segment,
    lifespan,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    avg_selling_price,

    -- Average Order Revenue (AOR)
    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE total_sales * 1.0 / total_orders
    END AS avg_order_revenue,

    -- Average Monthly Revenue
    CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales * 1.0 / lifespan
    END AS avg_monthly_revenue

FROM product_aggregations;
