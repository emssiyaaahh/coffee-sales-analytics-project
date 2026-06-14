/*=============================================================================
                          BASIC DATA QUALITY CHECKS
=============================================================================*/

USE CoffeeSalesAnalytics;
GO

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
