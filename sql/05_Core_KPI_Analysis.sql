/*=============================================================================
                              CORE KPI ANALYSIS
=============================================================================*/

USE CoffeeSalesAnalytics;
GO

-- Total revenue, total orders, and average order value
SELECT
    CAST(SUM(money) AS DECIMAL(12,2)) AS total_revenue,
    COUNT(*) AS total_orders,
    CAST(AVG(money) AS DECIMAL(12,2)) AS average_order_value
FROM dbo.coffee_sales_clean;
GO


-- KPI summary in report-friendly format
;WITH best_selling_product AS (
    SELECT TOP (1)
        coffee_name
    FROM dbo.coffee_sales_clean
    GROUP BY coffee_name
    ORDER BY COUNT(*) DESC, coffee_name ASC
),
highest_revenue_product AS (
    SELECT TOP (1)
        coffee_name
    FROM dbo.coffee_sales_clean
    GROUP BY coffee_name
    ORDER BY SUM(money) DESC, coffee_name ASC
)

SELECT 
    'Total Revenue' AS kpi_name,
    CONVERT(VARCHAR(50), CAST(SUM(money) AS DECIMAL(12,2))) AS kpi_value
FROM dbo.coffee_sales_clean

UNION ALL

SELECT 
    'Total Orders' AS kpi_name,
    CONVERT(VARCHAR(50), COUNT(*)) AS kpi_value
FROM dbo.coffee_sales_clean

UNION ALL

SELECT 
    'Average Order Value' AS kpi_name,
    CONVERT(VARCHAR(50), CAST(AVG(money) AS DECIMAL(12,2))) AS kpi_value
FROM dbo.coffee_sales_clean

UNION ALL

SELECT 
    'Best-Selling Product' AS kpi_name,
    coffee_name AS kpi_value
FROM best_selling_product

UNION ALL

SELECT 
    'Highest-Revenue Product' AS kpi_name,
    coffee_name AS kpi_value
FROM highest_revenue_product;