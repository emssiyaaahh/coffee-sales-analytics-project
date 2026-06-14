/*=============================================================================
                       CREATE STAGING TABLE FOR CSV IMPORT
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