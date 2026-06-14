/*=============================================================================
                           INDEXES FOR PERFORMANCE
=============================================================================*/

-- These indexes are helpful for filtering and dashboard queries.
USE CoffeeSalesAnalytics;
GO

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