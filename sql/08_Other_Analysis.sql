/*=============================================================================
                          OTHER COFFEE SALES ANALYSIS
=============================================================================*/



/*=============================================================================
                           PRODUCT CATEGORY ANALYSIS
=============================================================================*/

USE CoffeeSalesAnalytics;
GO

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
                         PAYMENT METHOD ANALYSIS
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
                          DAY-OF-WEEK SALES ANALYSIS
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
                            HOURLY SALES ANALYSIS
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
                        DAY AND HOUR HEATMAP DATA
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