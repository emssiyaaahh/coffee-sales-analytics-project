/*=============================================================================
                       ADDITIONAL BUSINESS ANALYSIS
=============================================================================*/

USE CoffeeSalesAnalytics;
GO

-- Weekend vs weekday performance
SELECT
    CASE
        WHEN day_number IN (5, 6) THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    SUM(money) AS total_revenue,
    COUNT(*) AS total_orders,
    AVG(money) AS average_order_value
FROM dbo.coffee_sales_clean
GROUP BY
    CASE
        WHEN day_number IN (5, 6) THEN 'Weekend'
        ELSE 'Weekday'
    END
ORDER BY total_revenue DESC;

-- Product performance by payment method
SELECT
    coffee_name,
    cash_type,
    SUM(money) AS total_revenue,
    COUNT(*) AS total_orders,
    AVG(money) AS average_order_value
FROM dbo.coffee_sales_clean
GROUP BY
    coffee_name,
    cash_type
ORDER BY
    coffee_name,
    total_revenue DESC;

-- Product demand by hour
SELECT
    sales_hour,
    coffee_name,
    COUNT(*) AS total_orders,
    SUM(money) AS total_revenue
FROM dbo.coffee_sales_clean
GROUP BY
    sales_hour,
    coffee_name
ORDER BY
    sales_hour,
    total_orders DESC;

-- Top product per month by revenue
WITH product_monthly_sales AS (
    SELECT
        year_month,
        sales_year,
        sales_month,
        coffee_name,
        SUM(money) AS total_revenue,
        COUNT(*) AS total_orders,
        ROW_NUMBER() OVER (
            PARTITION BY year_month
            ORDER BY SUM(money) DESC
        ) AS product_rank
    FROM dbo.coffee_sales_clean
    GROUP BY
        year_month,
        sales_year,
        sales_month,
        coffee_name
)
SELECT
    year_month,
    coffee_name,
    total_revenue,
    total_orders
FROM product_monthly_sales
WHERE product_rank = 1
ORDER BY
    sales_year,
    sales_month;