/*=============================================================================
                             DASHBOARD-READY VIEWS
=============================================================================*/

-- These views can be connected directly to Power BI or Tableau.

USE CoffeeSalesAnalytics;
GO

CREATE OR ALTER VIEW dbo.vw_kpi_summary AS
SELECT
    SUM(money) AS total_revenue,
    COUNT(*) AS total_orders,
    AVG(money) AS average_order_value,
    COUNT(DISTINCT coffee_name) AS total_products,
    COUNT(DISTINCT CASE WHEN card IS NOT NULL THEN card END) AS unique_card_customers
FROM dbo.coffee_sales_clean;
GO

CREATE OR ALTER VIEW dbo.vw_monthly_sales_summary AS
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
    sales_month;
GO

CREATE OR ALTER VIEW dbo.vw_product_performance_summary AS
SELECT
    coffee_name,
    SUM(money) AS total_revenue,
    COUNT(*) AS total_orders,
    AVG(money) AS average_order_value
FROM dbo.coffee_sales_clean
GROUP BY coffee_name;
GO

CREATE OR ALTER VIEW dbo.vw_category_performance_summary AS
SELECT
    product_category,
    SUM(money) AS total_revenue,
    COUNT(*) AS total_orders,
    AVG(money) AS average_order_value
FROM dbo.coffee_sales_clean
GROUP BY product_category;
GO

CREATE OR ALTER VIEW dbo.vw_payment_analysis_summary AS
SELECT
    cash_type,
    SUM(money) AS total_revenue,
    COUNT(*) AS total_orders,
    AVG(money) AS average_order_value,
    ROUND(SUM(money) * 100.0 / SUM(SUM(money)) OVER (), 2) AS revenue_share_pct,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS order_share_pct
FROM dbo.coffee_sales_clean
GROUP BY cash_type;
GO

CREATE OR ALTER VIEW dbo.vw_daily_sales_summary AS
SELECT
    day_number,
    day_name,
    SUM(money) AS total_revenue,
    COUNT(*) AS total_orders,
    AVG(money) AS average_order_value
FROM dbo.coffee_sales_clean
GROUP BY
    day_number,
    day_name;
GO

CREATE OR ALTER VIEW dbo.vw_hourly_sales_summary AS
SELECT
    sales_hour,
    SUM(money) AS total_revenue,
    COUNT(*) AS total_orders,
    AVG(money) AS average_order_value
FROM dbo.coffee_sales_clean
GROUP BY sales_hour;
GO

CREATE OR ALTER VIEW dbo.vw_day_hour_heatmap AS
SELECT
    day_number,
    day_name,
    sales_hour,
    SUM(money) AS total_revenue,
    COUNT(*) AS total_orders,
    AVG(money) AS average_order_value
FROM dbo.coffee_sales_clean
GROUP BY
    day_number,
    day_name,
    sales_hour;
GO

CREATE OR ALTER VIEW dbo.vw_customer_summary AS
SELECT
    card,
    COUNT(*) AS purchase_count,
    SUM(money) AS total_spent,
    AVG(money) AS average_spend,
    MIN(sale_datetime) AS first_purchase,
    MAX(sale_datetime) AS last_purchase,
    DATEDIFF(DAY, MIN(sale_datetime), MAX(sale_datetime)) AS customer_lifespan_days
FROM dbo.coffee_sales_clean
WHERE card IS NOT NULL
GROUP BY card;
GO