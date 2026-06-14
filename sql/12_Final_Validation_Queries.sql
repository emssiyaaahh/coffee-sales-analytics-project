/*=============================================================================
                        FINAL VALIDATION QUERIES
=============================================================================*/

USE CoffeeSalesAnalytics;
GO

SELECT TOP 10 *
FROM dbo.coffee_sales_clean
ORDER BY transaction_id;

SELECT *
FROM dbo.vw_kpi_summary;

SELECT *
FROM dbo.vw_monthly_sales_summary
ORDER BY sales_year, sales_month;

SELECT TOP 10 *
FROM dbo.vw_product_performance_summary
ORDER BY total_revenue DESC;

SELECT *
FROM dbo.vw_payment_analysis_summary
ORDER BY total_revenue DESC;