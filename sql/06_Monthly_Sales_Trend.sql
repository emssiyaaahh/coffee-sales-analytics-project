/*=============================================================================
                             MONTHLY SALES TREND
=============================================================================*/

USE CoffeeSalesAnalytics;
GO

-- Monthly revenue, orders, and AOV
SELECT
    year_month,
    sales_year,
    sales_month,
    SUM(money) AS total_revenue,
    COUNT(*) AS total_orders,
    AVG(money) AS average_order_value
FROM dbo.coffee_sales_clean
GROUP BY
    year_month,
    sales_year,
    sales_month
ORDER BY
    sales_year,
    sales_month;

-- Month-over-month revenue growth
WITH monthly_sales AS (
    SELECT
        year_month,
        sales_year,
        sales_month,
        SUM(money) AS total_revenue,
        COUNT(*) AS total_orders,
        AVG(money) AS average_order_value
    FROM dbo.coffee_sales_clean
    GROUP BY
        year_month,
        sales_year,
        sales_month
)
SELECT
    year_month,
    total_revenue,
    total_orders,
    average_order_value,
    LAG(total_revenue) OVER (ORDER BY sales_year, sales_month) AS previous_month_revenue,
    ROUND(
        (
            total_revenue - LAG(total_revenue) OVER (ORDER BY sales_year, sales_month)
        ) * 100.0 /
        NULLIF(LAG(total_revenue) OVER (ORDER BY sales_year, sales_month), 0),
        2
    ) AS mom_revenue_growth_pct
FROM monthly_sales
ORDER BY
    sales_year,
    sales_month;