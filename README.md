# Gold Layer Reports – Product & Customer  

**Repository Description**:  
This repository contains SQL Server scripts for creating analytical **gold-layer views** that consolidate **product** and **customer** performance metrics. These reports are designed for **business intelligence, dashboards, and KPI tracking**, enabling data-driven decision-making.  

---

## 📌 Overview  

Two main reports are created:  

1. **`gold.report_products`**  
   Consolidates product-level metrics, revenue segments, and performance indicators.  

2. **`gold.report_customers`**  
   Consolidates customer-level metrics, segments, and behavioral insights.  

---

## 📊 Report: `gold.report_products`  

### Purpose  
- Provide a single view of product performance.  
- Highlight product segmentation and KPIs.  

### Key Features  
- Extracts **core product fields**: product name, category, subcategory, cost.  
- Aggregates product-level metrics:  
  - Total orders  
  - Total sales  
  - Total quantity sold  
  - Total customers (unique)  
  - Product lifespan (months active)  
- Defines **segments**:  
  - High_Performer (> 50,000 sales)  
  - Mid-Range (10,000–50,000 sales)  
  - Low_Performer (< 10,000 sales)  
- Computes KPIs:  
  - **Recency** (months since last sale)  
  - **Average Order Revenue (AOR)** = total sales / total orders  
  - **Average Monthly Revenue** = total sales / lifespan  
  - **Average Selling Price** = sales / quantity  

---

## 👥 Report: `gold.report_customers`  

### Purpose  
- Provide a consolidated customer-level view for segmentation and engagement analysis.  

### Key Features  
- Extracts **core customer fields**: customer number, name, age.  
- Aggregates customer-level metrics:  
  - Total orders  
  ￼- Total sales  
  - Total quantity purchased  
  - Total products (unique)  
  - Customer lifespan (months active)  
- Defines **age groups**:  
  - Under 20  
  - 20–29  
  - 30–39  
  - 40–49  
  - 50 and above  
- Defines **customer segments**:  
  - VIP (lifespan ≥ 12 months and sales > 5000)  
  - Regular (lifespan ≥ 12 months and sales ≤ 5000)  
  - New (lifespan < 12 months)  
- Computes KPIs:  
  - **Recency** (months since last order)  
  - **Average Order Value (AOV)** = total sales / total orders  
  - **Average Monthly Spend** = total sales / lifespan  

---

## ⚙️ Technical Notes  

- The reports use **CTEs (Common Table Expressions)** for clarity and modular design.  
- Views are created under the **gold schema**:  
  - `gold.report_products`  
  - `gold.report_customers`  
- Existing views are dropped before recreation (`IF OBJECT_ID ... DROP VIEW`).  
- All date-based metrics (recency, lifespan) use **SQL Server’s DATEDIFF()** and **GETDATE()** functions.  

---

## ✅ Usage  

Run the SQL scripts in **SQL Server Management Studio (SSMS)** to create the views. Once created, they can be queried directly:  

```sql
-- Example: Top 10 High Performing Products
SELECT *
FROM gold.report_products
WHERE product_segment = 'High_Performer'
ORDER BY total_sales DESC;

-- Example: Active VIP Customers
SELECT *
FROM gold.report_customers
WHERE customer_segment = 'VIP'
AND recency <= 3;
