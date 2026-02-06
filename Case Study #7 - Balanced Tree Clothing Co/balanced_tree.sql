/* =====================================================
   Balanced Tree Clothing Co. - SQL Case Study
   ===================================================== */

/* =====================================================
   A. High Level Sales Analysis
   ===================================================== */

/* -----------------------------------------------------
   Q1: What was the total quantity sold for all products?
   ----------------------------------------------------- */
SELECT 
    SUM(qty) AS total_quantity_sold
FROM sales;

-- Explanation:
-- This query sums the quantity (qty) across all sales records
-- to calculate the total number of products sold.

/* -----------------------------------------------------
   Q2: What is the total generated revenue for all products
       before discounts?
   ----------------------------------------------------- */
SELECT 
    SUM(qty * price) AS total_revenue_generated
FROM sales;

-- Explanation:
-- Revenue is calculated by multiplying quantity and price
-- for each sale before applying any discounts.

/* -----------------------------------------------------
   Q3: What was the total discount amount for all products?
   ----------------------------------------------------- */
SELECT 
    ROUND(SUM(qty * price * (discount / 100)), 2) 
        AS total_discount_amount
FROM sales;

-- Explanation:
-- This query calculates total discounts by applying the
-- discount percentage to the gross revenue.


/* =====================================================
   B. Transaction Analysis
   ===================================================== */

/* -----------------------------------------------------
   Q4: How many unique transactions were there?
   ----------------------------------------------------- */
SELECT 
    COUNT(DISTINCT txn_id) AS unique_transactions
FROM sales;

-- Explanation:
-- Counts distinct transaction IDs to find the total
-- number of unique transactions.

/* -----------------------------------------------------
   Q5: What is the average number of unique products
       purchased per transaction?
   ----------------------------------------------------- */
SELECT 
    ROUND(AVG(unique_products_purchased), 2) 
        AS avg_unique_products_per_transaction
FROM (
    SELECT 
        txn_id,
        COUNT(DISTINCT prod_id) AS unique_products_purchased
    FROM sales
    GROUP BY txn_id
) sub;

-- Explanation:
-- First, the number of unique products is calculated
-- per transaction. Then the average is computed across
-- all transactions.

/* -----------------------------------------------------
   Q6: What are the 25th, 50th, and 75th percentile values
       for revenue per transaction?
   ----------------------------------------------------- */
WITH ranked_txns AS (
    SELECT 
        txn_id,
        SUM(qty * price * (1 - discount / 100)) 
            AS revenue_per_txn,
        ROW_NUMBER() OVER (
            ORDER BY SUM(qty * price * (1 - discount / 100))
        ) AS rn,
        COUNT(*) OVER () AS total_txns
    FROM sales
    GROUP BY txn_id
)
SELECT 
    '25th percentile' AS percentile,
    ROUND(revenue_per_txn, 2) AS revenue_per_transaction
FROM ranked_txns
WHERE rn = FLOOR(0.25 * total_txns)

UNION ALL

SELECT 
    '50th percentile',
    ROUND(revenue_per_txn, 2)
FROM ranked_txns
WHERE rn = FLOOR(0.50 * total_txns)

UNION ALL

SELECT 
    '75th percentile',
    ROUND(revenue_per_txn, 2)
FROM ranked_txns
WHERE rn = FLOOR(0.75 * total_txns);

-- Explanation:
-- Transactions are ranked by revenue, and percentile
-- values are extracted using row numbers.

/* -----------------------------------------------------
   Q7: What is the average discount value per transaction?
   ----------------------------------------------------- */
SELECT 
    ROUND(AVG(total_discount), 2) 
        AS avg_discount_per_transaction
FROM (
    SELECT 
        txn_id,
        SUM(qty * price * (discount / 100)) AS total_discount
    FROM sales
    GROUP BY txn_id
) txn_discounts;

-- Explanation:
-- Calculates total discount per transaction first,
-- then averages it across all transactions.


/* =====================================================
   C. Product & Category Analysis
   ===================================================== */

/* -----------------------------------------------------
   Q8: What is the percentage split of revenue by segment
       for each category?
   ----------------------------------------------------- */
SELECT
    category_id,
    category_name,
    segment_name,
    CONCAT(
        ROUND(
            SUM(qty * s.price * (1 - discount / 100))
            /
            SUM(SUM(qty * s.price * (1 - discount / 100)))
                OVER (PARTITION BY category_id)
            * 100,
        2),
        '%'
    ) AS revenue_percentage
FROM sales s
JOIN product_details pd
    ON s.prod_id = pd.product_id
GROUP BY 
    category_id,
    category_name,
    segment_name
ORDER BY 
    category_id,
    revenue_percentage DESC;

-- Explanation:
-- Uses a window function to calculate each segment’s
-- contribution to total category revenue.

/* -----------------------------------------------------
   Q9: What is the percentage split of total revenue
       by category?
   ----------------------------------------------------- */
SELECT
    category_id,
    category_name,
    CONCAT(
        ROUND(
            SUM(qty * s.price * (1 - discount / 100))
            /
            (
                SELECT 
                    SUM(qty * s2.price * (1 - discount / 100))
                FROM sales s2
                JOIN product_details pd2
                    ON s2.prod_id = pd2.product_id
            ) * 100,
        2),
        '%'
    ) AS revenue_percentage
FROM sales s
JOIN product_details pd
    ON s.prod_id = pd.product_id
GROUP BY 
    category_id,
    category_name
ORDER BY 
    category_id;

-- Explanation:
-- Calculates each category’s share of overall revenue.


/* -----------------------------------------------------
   Q10: What is the transaction penetration for each product?
   ----------------------------------------------------- */
SELECT
    product_id,
    product_name,
    CONCAT(
        ROUND(
            COUNT(DISTINCT txn_id)
            /
            (SELECT COUNT(DISTINCT txn_id) FROM sales)
            * 100,
        2),
        '%'
    ) AS penetration
FROM sales s
JOIN product_details pd
    ON s.prod_id = pd.product_id
WHERE qty >= 1
GROUP BY 
    product_id,
    product_name;

-- Explanation:
-- Penetration measures how often a product appears
-- across all transactions.


/* -----------------------------------------------------
   Q11: What is the most common combination of any
        3 products in a single transaction?
   ----------------------------------------------------- */
SELECT 
    s1.prod_id AS product_1,
    s2.prod_id AS product_2,
    s3.prod_id AS product_3,
    COUNT(DISTINCT s1.txn_id) AS combo_count
FROM sales s1
JOIN sales s2 
    ON s1.txn_id = s2.txn_id
   AND s1.prod_id < s2.prod_id
JOIN sales s3 
    ON s1.txn_id = s3.txn_id
   AND s2.prod_id < s3.prod_id
WHERE s1.qty >= 1
  AND s2.qty >= 1
  AND s3.qty >= 1
GROUP BY 
    s1.prod_id,
    s2.prod_id,
    s3.prod_id
ORDER BY 
    combo_count DESC
LIMIT 1;

-- Explanation:
-- Self-joins are used to find unique 3-product combinations
-- occurring within the same transaction.


/* =====================================================
   BONUS: Recreate product_details Table
   ===================================================== */
WITH hierarchy_cte AS (
    SELECT 
        style.id AS style_id,
        style.level_text AS style_name,
        segment.id AS segment_id,
        segment.level_text AS segment_name,
        category.id AS category_id,
        category.level_text AS category_name
    FROM product_hierarchy style
    JOIN product_hierarchy segment
        ON style.parent_id = segment.id
    JOIN product_hierarchy category
        ON segment.parent_id = category.id
    WHERE style.level_name = 'Style'
)
SELECT
    pp.product_id,
    pp.price,
    CONCAT(
        style_name, ' ', segment_name, ' - ', category_name
    ) AS product_name,
    h.category_id,
    h.segment_id,
    h.style_id,
    h.category_name,
    h.segment_name,
    h.style_name
FROM product_prices pp
JOIN hierarchy_cte h
    ON pp.id = h.style_id
ORDER BY pp.product_id;

-- Explanation:
-- This query reconstructs the product_details table
-- by joining hierarchical product data with pricing.
