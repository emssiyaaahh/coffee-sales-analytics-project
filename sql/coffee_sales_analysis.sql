/*
===============================================================================
Coffee Sales Analytics Project
File: coffee_sales_analysis.sql
Tool: SQL Server Management Studio (SSMS)

Purpose:
This script supports the SQL analysis phase of the Coffee Sales Analytics project.
It includes:
1. Database setup
2. Table creation
3. Optional CSV import template
4. Data quality checks
5. KPI queries
6. Product, customer, payment, and time-based sales analysis
7. Dashboard-ready SQL views

Recommended folder placement:
coffee-sales-intelligence-dashboard/sql/coffee_sales_analysis.sql

Main dataset expected:
data/processed/coffee_sales_cleaned.csv

Important:
- Update the BULK INSERT file path before running the import section.
- If you already imported the CSV using SSMS Import Wizard, skip the BULK INSERT
  section and make sure your table is named dbo.coffee_sales_clean.
===============================================================================
*/


/*=============================================================================
  1. CREATE DATABASE
=============================================================================*/

-- Run this only once.
-- If the database already exists, you can skip this section.

IF DB_ID('CoffeeSalesAnalytics') IS NULL
BEGIN
    CREATE DATABASE CoffeeSalesAnalytics;
END;
GO

USE CoffeeSalesAnalytics;
GO


/*=============================================================================
  2. CREATE STAGING TABLE FOR CSV IMPORT
=============================================================================*/

-- This staging table stores all columns as text first.
-- This makes the CSV import safer because SQL Server can import before converting
-- values into correct data types.

IF OBJECT_ID('dbo.coffee_sales_raw_import', 'U') IS NOT NULL
    DROP TABLE dbo.coffee_sales_raw_import;
GO

CREATE TABLE dbo.coffee_sales_raw_import (
    [date] NVARCHAR(50),
    [datetime] NVARCHAR(100),
    cash_type NVARCHAR(50),
    card NVARCHAR(100),
    money NVARCHAR(50),
    coffee_name NVARCHAR(150),
    source_file NVARCHAR(150),
    transaction_id NVARCHAR(50),
    [year] NVARCHAR(50),
    [month] NVARCHAR(50),
    month_name NVARCHAR(50),
    year_month NVARCHAR(50),
    day_name NVARCHAR(50),
    day_number NVARCHAR(50),
    [hour] NVARCHAR(50),
    product_category NVARCHAR(150)
);
GO


/*=============================================================================
  3. OPTIONAL: IMPORT CLEANED CSV FILE
=============================================================================*/

-- Option A: Use SSMS Import Flat File Wizard
-- Recommended for beginners:
-- Right-click database > Tasks > Import Flat File > Choose coffee_sales_cleaned.csv

-- Option B: Use BULK INSERT below.
-- Before running, replace this file path with the actual Windows path of your CSV:
-- Example:
-- C:\Users\YourName\Documents\GitHub\coffee-sales-intelligence-dashboard\data\processed\coffee_sales_cleaned.csv

/*
BULK INSERT dbo.coffee_sales_raw_import
FROM 'C:\Users\YourName\Documents\GitHub\coffee-sales-intelligence-dashboard\data\processed\coffee_sales_cleaned.csv'
WITH (
    FIRSTROW = 2,
    FORMAT = 'CSV',
    FIELDQUOTE = '"',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);
GO
*/


/*=============================================================================
  4. CREATE CLEAN FINAL TABLE
=============================================================================*/

IF OBJECT_ID('dbo.coffee_sales_clean', 'U') IS NOT NULL
    DROP TABLE dbo.coffee_sales_clean;
GO

CREATE TABLE dbo.coffee_sales_clean (
    transaction_id INT NOT NULL PRIMARY KEY,
    sale_date DATE NULL,
    sale_datetime DATETIME2(3) NULL,
    cash_type VARCHAR(20) NULL,
    card VARCHAR(100) NULL,
    money DECIMAL(10,2) NULL,
    coffee_name VARCHAR(150) NULL,
    source_file VARCHAR(150) NULL,
    sales_year INT NULL,
    sales_month INT NULL,
    month_name VARCHAR(30) NULL,
    year_month VARCHAR(20) NULL,
    day_name VARCHAR(30) NULL,
    day_number INT NULL,
    sales_hour INT NULL,
    product_category VARCHAR(150) NULL
);
GO


/*=============================================================================
  5. LOAD DATA FROM STAGING TABLE INTO CLEAN TABLE
=============================================================================*/

-- Run this after importing data into dbo.coffee_sales_raw_import.

INSERT INTO dbo.coffee_sales_clean (
    transaction_id,
    sale_date,
    sale_datetime,
    cash_type,
    card,
    money,
    coffee_name,
    source_file,
    sales_year,
    sales_month,
    month_name,
    year_month,
    day_name,
    day_number,
    sales_hour,
    product_category
)
SELECT
    TRY_CONVERT(INT, transaction_id) AS transaction_id,
    TRY_CONVERT(DATE, [date]) AS sale_date,
    TRY_CONVERT(DATETIME2(3), [datetime]) AS sale_datetime,
    LOWER(LTRIM(RTRIM(cash_type))) AS cash_type,
    NULLIF(LTRIM(RTRIM(card)), '') AS card,
    TRY_CONVERT(DECIMAL(10,2), money) AS money,
    LTRIM(RTRIM(coffee_name)) AS coffee_name,
    LTRIM(RTRIM(source_file)) AS source_file,
    TRY_CONVERT(INT, [year]) AS sales_year,
    TRY_CONVERT(INT, [month]) AS sales_month,
    LTRIM(RTRIM(month_name)) AS month_name,
    LTRIM(RTRIM(year_month)) AS year_month,
    LTRIM(RTRIM(day_name)) AS day_name,
    TRY_CONVERT(INT, day_number) AS day_number,
    TRY_CONVERT(INT, [hour]) AS sales_hour,
    LTRIM(RTRIM(product_category)) AS product_category
FROM dbo.coffee_sales_raw_import
WHERE TRY_CONVERT(INT, transaction_id) IS NOT NULL;
GO


/*=============================================================================
  6. BASIC DATA QUALITY CHECKS
=============================================================================*/

-- Check total rows
SELECT COUNT(*) AS total_rows
FROM dbo.coffee_sales_clean;

-- Check date range
SELECT
    MIN(sale_datetime) AS start_datetime,
    MAX(sale_datetime) AS end_datetime
FROM dbo.coffee_sales_clean;

-- Check missing values
SELECT
    SUM(CASE WHEN sale_date IS NULL THEN 1 ELSE 0 END) AS missing_sale_date,
    SUM(CASE WHEN sale_datetime IS NULL THEN 1 ELSE 0 END) AS missing_sale_datetime,
    SUM(CASE WHEN cash_type IS NULL THEN 1 ELSE 0 END) AS missing_cash_type,
    SUM(CASE WHEN card IS NULL THEN 1 ELSE 0 END) AS missing_card,
    SUM(CASE WHEN money IS NULL THEN 1 ELSE 0 END) AS missing_money,
    SUM(CASE WHEN coffee_name IS NULL THEN 1 ELSE 0 END) AS missing_coffee_name
FROM dbo.coffee_sales_clean;

-- Check duplicate transaction IDs
SELECT
    transaction_id,
    COUNT(*) AS duplicate_count
FROM dbo.coffee_sales_clean
GROUP BY transaction_id
HAVING COUNT(*) > 1;

-- Check possible duplicate transactions based on transaction details
SELECT
    sale_date,
    sale_datetime,
    cash_type,
    card,
    money,
    coffee_name,
    COUNT(*) AS duplicate_count
FROM dbo.coffee_sales_clean
GROUP BY
    sale_date,
    sale_datetime,
    cash_type,
    card,
    money,
    coffee_name
HAVING COUNT(*) > 1;

-- Check revenue range for outliers
SELECT
    MIN(money) AS minimum_transaction_amount,
    MAX(money) AS maximum_transaction_amount,
    AVG(money) AS average_transaction_amount
FROM dbo.coffee_sales_clean;

-- Check product names
SELECT
    coffee_name,
    COUNT(*) AS total_orders
FROM dbo.coffee_sales_clean
GROUP BY coffee_name
ORDER BY coffee_name;


/*=============================================================================
  7. CORE KPI ANALYSIS
=============================================================================*/

-- Total revenue, total orders, and average order value
SELECT
    SUM(money) AS total_revenue,
    COUNT(*) AS total_orders,
    AVG(money) AS average_order_value
FROM dbo.coffee_sales_clean;

-- KPI summary in report-friendly format
SELECT 'Total Revenue' AS kpi_name, CAST(SUM(money) AS VARCHAR(50)) AS kpi_value
FROM dbo.coffee_sales_clean

UNION ALL

SELECT 'Total Orders', CAST(COUNT(*) AS VARCHAR(50))
FROM dbo.coffee_sales_clean

UNION ALL

SELECT 'Average Order Value', CAST(ROUND(AVG(money), 2) AS VARCHAR(50))
FROM dbo.coffee_sales_clean

UNION ALL

SELECT TOP 1 'Best-Selling Product', coffee_name
FROM dbo.coffee_sales_clean
GROUP BY coffee_name
ORDER BY COUNT(*) DESC

UNION ALL

SELECT TOP 1 'Highest-Revenue Product', coffee_name
FROM dbo.coffee_sales_clean
GROUP BY coffee_name
ORDER BY SUM(money) DESC;


/*=============================================================================
  8. MONTHLY SALES TREND
=============================================================================*/

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


/*=============================================================================
  9. PRODUCT PERFORMANCE ANALYSIS
=============================================================================*/

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


/*=============================================================================
  10. PRODUCT CATEGORY ANALYSIS
=============================================================================*/

SELECT
    product_category,
    SUM(money) AS total_revenue,
    COUNT(*) AS total_orders,
    AVG(money) AS average_order_value,
    ROUND(SUM(money) * 100.0 / SUM(SUM(money)) OVER (), 2) AS revenue_share_pct
FROM dbo.coffee_sales_clean
GROUP BY product_category
ORDER BY total_revenue DESC;


/*=============================================================================
  11. PAYMENT METHOD ANALYSIS
=============================================================================*/

SELECT
    cash_type,
    SUM(money) AS total_revenue,
    COUNT(*) AS total_orders,
    AVG(money) AS average_order_value,
    ROUND(SUM(money) * 100.0 / SUM(SUM(money)) OVER (), 2) AS revenue_share_pct,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS order_share_pct
FROM dbo.coffee_sales_clean
GROUP BY cash_type
ORDER BY total_revenue DESC;


/*=============================================================================
  12. DAY-OF-WEEK SALES ANALYSIS
=============================================================================*/

-- day_number follows Python logic:
-- Monday = 0, Tuesday = 1, Wednesday = 2, Thursday = 3, Friday = 4,
-- Saturday = 5, Sunday = 6

SELECT
    day_number,
    day_name,
    SUM(money) AS total_revenue,
    COUNT(*) AS total_orders,
    AVG(money) AS average_order_value
FROM dbo.coffee_sales_clean
GROUP BY
    day_number,
    day_name
ORDER BY day_number;

-- Best sales day by revenue
SELECT TOP 1
    day_name,
    SUM(money) AS total_revenue,
    COUNT(*) AS total_orders
FROM dbo.coffee_sales_clean
GROUP BY day_name
ORDER BY total_revenue DESC;


/*=============================================================================
  13. HOURLY SALES ANALYSIS
=============================================================================*/

SELECT
    sales_hour,
    SUM(money) AS total_revenue,
    COUNT(*) AS total_orders,
    AVG(money) AS average_order_value
FROM dbo.coffee_sales_clean
GROUP BY sales_hour
ORDER BY sales_hour;

-- Best sales hour by revenue
SELECT TOP 1
    sales_hour,
    SUM(money) AS total_revenue,
    COUNT(*) AS total_orders
FROM dbo.coffee_sales_clean
GROUP BY sales_hour
ORDER BY total_revenue DESC;


/*=============================================================================
  14. DAY AND HOUR HEATMAP DATA
=============================================================================*/

-- Use this result for a Power BI/Tableau heatmap.
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
    sales_hour
ORDER BY
    day_number,
    sales_hour;


/*=============================================================================
  15. CUSTOMER BEHAVIOR ANALYSIS
=============================================================================*/

-- Customer analysis uses card as an anonymized customer identifier.
-- Missing card values are excluded from customer-level analysis.

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
GROUP BY card
ORDER BY purchase_count DESC;

-- Repeat customer count and repeat customer rate
WITH customer_summary AS (
    SELECT
        card,
        COUNT(*) AS purchase_count,
        SUM(money) AS total_spent
    FROM dbo.coffee_sales_clean
    WHERE card IS NOT NULL
    GROUP BY card
)
SELECT
    COUNT(*) AS total_card_customers,
    SUM(CASE WHEN purchase_count > 1 THEN 1 ELSE 0 END) AS repeat_customers,
    ROUND(
        SUM(CASE WHEN purchase_count > 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS repeat_customer_rate_pct
FROM customer_summary;

-- Top 10 customers by total spend
SELECT TOP 10
    card,
    COUNT(*) AS purchase_count,
    SUM(money) AS total_spent,
    AVG(money) AS average_spend
FROM dbo.coffee_sales_clean
WHERE card IS NOT NULL
GROUP BY card
ORDER BY total_spent DESC;

-- Customer frequency segmentation
WITH customer_summary AS (
    SELECT
        card,
        COUNT(*) AS purchase_count,
        SUM(money) AS total_spent
    FROM dbo.coffee_sales_clean
    WHERE card IS NOT NULL
    GROUP BY card
)
SELECT
    CASE
        WHEN purchase_count = 1 THEN 'One-Time Customer'
        WHEN purchase_count BETWEEN 2 AND 3 THEN 'Low Repeat Customer'
        WHEN purchase_count BETWEEN 4 AND 7 THEN 'Moderate Repeat Customer'
        ELSE 'High Repeat Customer'
    END AS customer_segment,
    COUNT(*) AS total_customers,
    SUM(total_spent) AS segment_revenue,
    AVG(total_spent) AS average_customer_spend
FROM customer_summary
GROUP BY
    CASE
        WHEN purchase_count = 1 THEN 'One-Time Customer'
        WHEN purchase_count BETWEEN 2 AND 3 THEN 'Low Repeat Customer'
        WHEN purchase_count BETWEEN 4 AND 7 THEN 'Moderate Repeat Customer'
        ELSE 'High Repeat Customer'
    END
ORDER BY segment_revenue DESC;


/*=============================================================================
  16. ADDITIONAL BUSINESS ANALYSIS
=============================================================================*/

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


/*=============================================================================
  17. DASHBOARD-READY VIEWS
=============================================================================*/

-- These views can be connected directly to Power BI or Tableau.

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


/*=============================================================================
  18. INDEXES FOR PERFORMANCE
=============================================================================*/

-- These indexes are helpful for filtering and dashboard queries.

CREATE INDEX IX_coffee_sales_clean_sale_datetime
ON dbo.coffee_sales_clean (sale_datetime);

CREATE INDEX IX_coffee_sales_clean_year_month
ON dbo.coffee_sales_clean (year_month);

CREATE INDEX IX_coffee_sales_clean_coffee_name
ON dbo.coffee_sales_clean (coffee_name);

CREATE INDEX IX_coffee_sales_clean_cash_type
ON dbo.coffee_sales_clean (cash_type);

CREATE INDEX IX_coffee_sales_clean_card
ON dbo.coffee_sales_clean (card);
GO


/*=============================================================================
  19. FINAL VALIDATION QUERIES
=============================================================================*/

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
