/*=============================================================================
                               CREATE DATABASE
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