/*=============================================================================
                        PRODUCT PERFORMANCE ANALYSIS
=============================================================================*/

USE CoffeeSalesAnalytics;
GO

-- Product performance summary
SELECT
    coffee_name,
    SUM(money) AS total_revenue,
    COUNT(*) AS total_orders,
    AVG(money) AS average_order_value
FROM dbo.coffee_sales_clean
GROUP BY coffee_name
ORDER BY total_revenue DESC;

-- Top 10 products by revenue
SELECT TOP 10
    coffee_name,
    SUM(money) AS total_revenue,
    COUNT(*) AS total_orders,
    AVG(money) AS average_order_value
FROM dbo.coffee_sales_clean
GROUP BY coffee_name
ORDER BY total_revenue DESC;

-- Top 10 products by order volume
SELECT TOP 10
    coffee_name,
    COUNT(*) AS total_orders,
    SUM(money) AS total_revenue,
    AVG(money) AS average_order_value
FROM dbo.coffee_sales_clean
GROUP BY coffee_name
ORDER BY total_orders DESC;

-- Low-performing products by order volume
SELECT TOP 10
    coffee_name,
    COUNT(*) AS total_orders,
    SUM(money) AS total_revenue,
    AVG(money) AS average_order_value
FROM dbo.coffee_sales_clean
GROUP BY coffee_name
ORDER BY total_orders ASC;

-- Product revenue contribution percentage
WITH product_sales AS (
    SELECT
        coffee_name,
        SUM(money) AS total_revenue,
        COUNT(*) AS total_orders
    FROM dbo.coffee_sales_clean
    GROUP BY coffee_name
)
SELECT
    coffee_name,
    total_revenue,
    total_orders,
    ROUND(total_revenue * 100.0 / SUM(total_revenue) OVER (), 2) AS revenue_share_pct
FROM product_sales
ORDER BY total_revenue DESC;