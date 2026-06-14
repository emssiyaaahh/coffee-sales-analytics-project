/*=============================================================================
                        OPTIONAL: IMPORT CLEANED CSV FILE
=============================================================================*/

-- Option A: Use SSMS Import Flat File Wizard
-- Recommended for beginners:
-- Right-click database > Tasks > Import Flat File > Choose coffee_sales_cleaned.csv

-- Option B: Use BULK INSERT below.
-- Before running, replace this file path with the actual Windows path of your CSV:
-- Example:
-- C:\Users\YourName\Documents\GitHub\coffee-sales-intelligence-dashboard\data\processed\coffee_sales_cleaned.csv

/*
USE CoffeeSalesAnalytics;
GO

BULK INSERT dbo.coffee_sales_raw_import
FROM 'C:\Users\YourName\Documents\GitHub\coffee-sales-analytics-prroject\data\processed\coffee_sales_cleaned.csv'
WITH (
    FIRSTROW = 2,
    FORMAT = 'CSV',
    FIELDQUOTE = '"',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);
GO
*/

USE CoffeeSalesAnalytics;
GO

IF OBJECT_ID('dbo.coffee_sales_clean', 'U') IS NOT NULL
    DROP TABLE dbo.coffee_sales_clean;
GO

SELECT
    TRY_CONVERT(INT, transaction_id) AS transaction_id,
    TRY_CONVERT(DATE, [date]) AS sale_date,
    TRY_CONVERT(DATETIME2(3), [datetime]) AS sale_datetime,
    LOWER(TRIM(cash_type)) AS cash_type,
    NULLIF(TRIM(card), '') AS card,
    TRY_CONVERT(DECIMAL(10,2), money) AS money,
    TRIM(coffee_name) AS coffee_name,
    TRIM(source_file) AS source_file,
    TRY_CONVERT(INT, [year]) AS sales_year,
    TRY_CONVERT(INT, [month]) AS sales_month,
    TRIM(month_name) AS month_name,
    TRIM(year_month) AS year_month,
    TRIM(day_name) AS day_name,
    TRY_CONVERT(INT, day_number) AS day_number,
    TRY_CONVERT(INT, [hour]) AS sales_hour,
    TRIM(product_category) AS product_category
INTO dbo.coffee_sales_clean
FROM dbo.coffee_sales_cleaned;
GO

SELECT TOP 10 *
FROM dbo.coffee_sales_clean
ORDER BY transaction_id;