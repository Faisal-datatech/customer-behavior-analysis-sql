/*
=========================================================
PROJECT TITLE: Customer Behavior Analysis Using SQL
AUTHOR: Shah Faisal
TOOLS: MySQL Workbench
=========================================================

PROJECT DESCRIPTION:
This project analyzes customer purchasing behavior
to extract business insights such as revenue trends,
customer segmentation, subscription impact, discount
usage, and product performance.

SQL CONCEPTS USED:
- Aggregate Functions
- GROUP BY
- Subqueries
- CASE Statements
- CTE (Common Table Expressions)
- Window Functions (ROW_NUMBER)
=========================================================
*/

-- =====================================================
-- 1. VIEW SAMPLE DATA
-- =====================================================

SELECT *
FROM customer
LIMIT 20;


-- =====================================================
-- 2. TOTAL REVENUE BY GENDER
-- =====================================================

SELECT
    gender,
    SUM(purchase_amount) AS total_revenue
FROM customer
GROUP BY gender;


-- =====================================================
-- 3. HIGH VALUE CUSTOMERS USING DISCOUNTS
-- (Customers who used discount but spent above average)
-- =====================================================

SELECT
    customer_id,
    purchase_amount
FROM customer
WHERE discount_applied = 'Yes'
AND purchase_amount >= (
    SELECT AVG(purchase_amount)
    FROM customer
);



-- =====================================================
-- 4. TOP 5 HIGHEST RATED PRODUCTS
-- =====================================================
SELECT
    item_purchased,
    ROUND(AVG(review_rating), 2) AS avg_rating
FROM customer
GROUP BY item_purchased
ORDER BY avg_rating DESC
LIMIT 5;


-- =====================================================
-- 5. SHIPPING TYPE vs CUSTOMER SPENDING
-- =====================================================

SELECT
    shipping_type,
    ROUND(AVG(purchase_amount), 2) AS avg_purchase
FROM customer
WHERE shipping_type IN ('Standard', 'Express')
GROUP BY shipping_type;


-- =====================================================
-- 6. SUBSCRIBED vs NON-SUBSCRIBED CUSTOMERS
-- =====================================================

SELECT
    subscription_status,
    COUNT(customer_id) AS total_customers,
    ROUND(AVG(purchase_amount), 2) AS avg_spend,
    ROUND(SUM(purchase_amount), 2) AS total_revenue
FROM customer
GROUP BY subscription_status
ORDER BY total_revenue DESC;


-- =====================================================
-- 7. DISCOUNT USAGE PER PRODUCT
-- =====================================================

SELECT
    item_purchased,

    COUNT(CASE WHEN discount_applied = 'Yes' THEN 1 END) AS discounted_purchases,
    COUNT(*) AS total_purchases,

    ROUND(
        COUNT(CASE WHEN discount_applied = 'Yes' THEN 1 END) * 100.0 / COUNT(*),
        2
    ) AS discount_percentage

FROM customer
GROUP BY item_purchased
ORDER BY discount_percentage DESC
LIMIT 5;


-- =====================================================
-- 8. REVENUE BY AGE GROUP
-- =====================================================

SELECT
    age_group,
    SUM(purchase_amount) AS total_revenue
FROM customer
GROUP BY age_group
ORDER BY total_revenue DESC;


-- =====================================================
-- 9. CUSTOMER SEGMENTATION (CTE)
-- =====================================================

WITH customer_segments AS (
    SELECT
        customer_id,
        previous_purchases,

        CASE
            WHEN previous_purchases = 1 THEN 'New'
            WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
            ELSE 'Loyal'
        END AS segment

    FROM customer
)

SELECT
    segment,
    COUNT(*) AS total_customers
FROM customer_segments
GROUP BY segment;


-- =====================================================
-- 10. TOP 3 PRODUCTS PER CATEGORY (WINDOW FUNCTION)
-- =====================================================

WITH product_sales AS (
    SELECT
        category,
        item_purchased,
        SUM(purchase_amount) AS total_sales
    FROM customer
    GROUP BY category, item_purchased
),

ranked_products AS (
    SELECT
        category,
        item_purchased,
        total_sales,

        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY total_sales DESC
        ) AS rank_num

    FROM product_sales
)

SELECT
    category,
    item_purchased,
    total_sales,
    rank_num
FROM ranked_products
WHERE rank_num <= 3;


-- =====================================================
-- 11. REPEAT BUYERS vs SUBSCRIPTION STATUS
-- =====================================================

SELECT
    subscription_status,
    COUNT(customer_id) AS repeat_customers
FROM customer
WHERE previous_purchases > 5
GROUP BY subscription_status;


-- =====================================================
-- END OF PROJECT
-- =====================================================