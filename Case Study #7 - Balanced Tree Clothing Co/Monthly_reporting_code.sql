/* -- Reporting Challenge
Write a single SQL script that combines all of the previous questions into a scheduled report that the Balanced Tree team can run at the beginning of each month to calculate the previous month’s values.

Imagine that the Chief Financial Officer (which is also Danny) has asked for all of these questions at the end of every month.

He first wants you to generate the data for January only - but then he also wants you to demonstrate that you can easily run the samne analysis for February without many changes (if at all).

Feel free to split up your final outputs into as many tables as you need - but be sure to explicitly reference which table outputs relate to which question for full marks  */

-- =============================================
-- 🎯 Balanced Tree Reporting Challenge
-- Monthly Report Template (MySQL)
-- =============================================
-- 🔹 Intialise the database to be used
USE balanced_tree;

-- 🔹 Step 1: Define month date range
SET @start_date = '2021-01-01';
SET @end_date   = '2021-01-31';

-- =============================================
-- 🔹 Step 2: Combine all analyses using CTEs
-- =============================================
WITH month_data AS (
    SELECT *
    FROM sales
    WHERE DATE(start_txn_time) BETWEEN @start_date AND @end_date
),

-- Q1: How many unique transactions occurred this month?
q1_transactions AS (
    SELECT COUNT(DISTINCT txn_id) AS unique_transactions
    FROM month_data
),

-- Q2: What is the total revenue for the month?
q2_total_revenue AS (
    SELECT ROUND(SUM(qty * price), 2) AS total_revenue
    FROM month_data
),

-- Q3: What was the average transaction value?
q3_avg_transaction AS (
    SELECT ROUND(AVG(txn_total), 2) AS avg_transaction_value
    FROM (
        SELECT txn_id, SUM(qty * price) AS txn_total
        FROM month_data
        GROUP BY txn_id
    ) t
),

-- Q4: Which product generated the most revenue?
q4_top_product AS (
    SELECT 
        p.product_name,
        ROUND(SUM(m.qty * m.price), 2) AS product_revenue
    FROM month_data m
    JOIN product_details p ON m.prod_id = p.product_id
    GROUP BY p.product_name
    ORDER BY product_revenue DESC
    LIMIT 1
),

-- Q5: Which category had the highest average spend per transaction?
q5_top_category AS (
    SELECT 
        p.category_name,
        ROUND(SUM(m.qty * m.price) / COUNT(DISTINCT m.txn_id), 2) AS avg_spend_per_txn
    FROM month_data m
    JOIN product_details p ON m.prod_id = p.product_id
    GROUP BY p.category_name
    ORDER BY avg_spend_per_txn DESC
    LIMIT 1
),

-- Q6: Which transaction had the highest total purchase value?
q6_top_transaction AS (
    SELECT 
        txn_id,
        ROUND(SUM(qty * price), 2) AS total_value
    FROM month_data
    GROUP BY txn_id
    ORDER BY total_value DESC
    LIMIT 1
),

-- Q7: Which day of the week had the highest sales?
q7_best_day AS (
    SELECT 
        DAYNAME(start_txn_time) AS day_name,
        ROUND(SUM(qty * price), 2) AS total_sales
    FROM month_data
    GROUP BY day_name
    ORDER BY total_sales DESC
    LIMIT 1
),

-- Q8: What percentage of transactions included discounts?
q8_discounted_txns AS (
    SELECT 
        ROUND(
            COUNT(DISTINCT CASE WHEN discount > 0 THEN txn_id END) / 
            COUNT(DISTINCT txn_id) * 100, 2
        ) AS discount_percentage
    FROM month_data
),

-- Q9: What is the average quantity of items sold per transaction?
q9_avg_items AS (
    SELECT ROUND(AVG(total_qty), 2) AS avg_items_per_txn
    FROM (
        SELECT txn_id, SUM(qty) AS total_qty
        FROM month_data
        GROUP BY txn_id
    ) t
),

-- Q10: Most common combination of any 3 products in a single transaction
q10_top_combo AS (
    SELECT 
        s1.prod_id AS product_1,
        s2.prod_id AS product_2,
        s3.prod_id AS product_3,
        COUNT(*) AS combo_count
    FROM month_data s1
    JOIN month_data s2 ON s1.txn_id = s2.txn_id AND s1.prod_id < s2.prod_id
    JOIN month_data s3 ON s1.txn_id = s3.txn_id AND s2.prod_id < s3.prod_id
    WHERE s1.qty >= 1 AND s2.qty >= 1 AND s3.qty >= 1
    GROUP BY s1.prod_id, s2.prod_id, s3.prod_id
    ORDER BY combo_count DESC
    LIMIT 1
)

-- =============================================
-- 🔹 Step 3: Final Combined Report
-- =============================================
SELECT 'Q1 - Unique Transactions' AS metric, unique_transactions AS value FROM q1_transactions
UNION ALL
SELECT 'Q2 - Total Revenue', total_revenue FROM q2_total_revenue
UNION ALL
SELECT 'Q3 - Avg Transaction Value', avg_transaction_value FROM q3_avg_transaction
UNION ALL
SELECT 'Q4 - Top Product Revenue', product_revenue FROM q4_top_product
UNION ALL
SELECT 'Q5 - Top Category Avg Spend', avg_spend_per_txn FROM q5_top_category
UNION ALL
SELECT 'Q6 - Top Transaction Value', total_value FROM q6_top_transaction
UNION ALL
SELECT 'Q7 - Best Day Sales', total_sales FROM q7_best_day
UNION ALL
SELECT 'Q8 - % Transactions w/ Discount', discount_percentage FROM q8_discounted_txns
UNION ALL
SELECT 'Q9 - Avg Items per Txn', avg_items_per_txn FROM q9_avg_items
UNION ALL
SELECT CONCAT('Q10 - Most Common 3-Product Combo (', product_1, ',', product_2, ',', product_3, ')') AS metric, combo_count AS value FROM q10_top_combo;
