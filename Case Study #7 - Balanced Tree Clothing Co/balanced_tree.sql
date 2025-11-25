USE balanced_tree;

SELECT * FROM sales;
-- A. High Level Sales Analysis
-- 1. What was the total quantity sold for all products?
SELECT 
    SUM(qty) AS total_quantity_sold
FROM sales;

-- 2. What is the total generated revenue for all products before discounts?
SELECT 
    SUM(qty * price)  AS total_revenue_generated
FROM sales;

-- 3. What was the total discount amount for all products?
SELECT 
    ROUND(SUM(qty * price * (discount / 100)),2) AS total_discount_amount
FROM sales;

-- B. Transaction Analysis
-- 1. How many unique transactions were there?
SELECT 
    COUNT(DISTINCT txn_id) AS unique_transactions
FROM sales;

-- 2. What is the average unique products purchased in each transaction?
SELECT 
    ROUND(AVG(unique_products_purchased), 2) AS average_unique_products_purchased_per_transaction
FROM (
    SELECT 
        txn_id,
        COUNT(DISTINCT prod_id) AS unique_products_purchased
    FROM sales
    GROUP BY txn_id
) AS unique_products_purchased_per_txn;

-- 3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?
WITH ranked AS (
    SELECT 
        txn_id,
        SUM(qty * price * (1 - discount/100)) AS revenue_per_txn,
        ROW_NUMBER() OVER (ORDER BY SUM(qty * price * (1 - discount/100))) AS rn,
        COUNT(*) OVER () AS total_txns
    FROM sales
    GROUP BY txn_id
)
SELECT 
    '25th percentile' AS percentile, ROUND(revenue_per_txn,2) AS revenue_per_transaction
FROM ranked
WHERE rn = FLOOR(0.25 * total_txns)

UNION ALL

SELECT '50th percentile', ROUND(revenue_per_txn,2) AS revenue_per_transaction
FROM ranked
WHERE rn = FLOOR(0.50 * total_txns)

UNION ALL

SELECT '75th percentile', ROUND(revenue_per_txn,2) AS revenue_per_transaction
FROM ranked
WHERE rn = FLOOR(0.75 * total_txns);

-- 4. What is the average discount value per transaction?
SELECT 
    ROUND(AVG(total_discount), 2) AS average_discount_per_transaction
FROM (
    SELECT 
        txn_id,
        SUM(qty * price * (discount / 100)) AS total_discount
    FROM sales
    GROUP BY txn_id
) AS txn_discounts;

-- 5. What is the percentage split of all transactions for members vs non-members?
SELECT
	member,
	ROUND((COUNT(DISTINCT txn_id)/(SELECT COUNT(DISTINCT txn_id) AS total_transactions FROM sales) * 100),2) AS percentage_split
FROM sales
GROUP BY member;

-- 6. What is the average revenue for member transactions and non-member transactions?
SELECT
    member,
    ROUND(AVG(total_revenue), 2) AS average_revenue_per_transaction
FROM (
    SELECT 
        txn_id,
        member,
        SUM(qty * price * (1 - discount/100)) AS total_revenue
    FROM sales
    GROUP BY txn_id, member
) AS txn_revenue
GROUP BY member;

-- C. Product Analysis
-- 1. What are the top 3 products by total revenue before discount?
SELECT
	product_id,
	product_name,
    SUM(qty * s.price) AS total_revenue
FROM sales s
JOIN product_details pd
ON s.prod_id = pd.product_id
GROUP BY product_id, product_name
ORDER BY total_revenue DESC
LIMIT 3;

-- 2. What is the total quantity, revenue and discount for each segment?
SELECT
	segment_id,
    segment_name,
	SUM(qty) AS total_quantity,
    ROUND(SUM(qty * s.price), 2) AS total_revenue_before_discount,
    ROUND(SUM(qty * s.price * (1 - discount / 100)),2) AS total_revenue,
    ROUND(SUM(qty * s.price * discount / 100),2) AS total_discount
FROM sales s
JOIN product_details pd
ON s.prod_id = pd.product_id
GROUP BY segment_id,segment_name;

-- 3. What is the top selling product for each segment?
WITH Top_Selling_Product_CTE AS
(
	SELECT
		segment_id,
		segment_name,
		product_name,
		SUM(qty) AS total_quantity,
		DENSE_RANK() OVER(PARTITION BY segment_id ORDER BY SUM(qty) DESC) AS rk
	FROM sales s
	JOIN product_details pd
	ON s.prod_id = pd.product_id
	GROUP BY segment_id,segment_name, product_name
)

SELECT
	segment_id,
	segment_name,
	product_name,
	total_quantity
FROM Top_Selling_Product_CTE
WHERE rk = 1;

-- 4. What is the total quantity, revenue and discount for each category?
SELECT
	category_id,
    category_name,
	SUM(qty) AS total_quantity,
    ROUND(SUM(qty * s.price), 2) AS total_revenue_before_discount,
    ROUND(SUM(qty * s.price * (1 - discount / 100)),2) AS total_revenue,
    ROUND(SUM(qty * s.price * discount / 100),2) AS total_discount
FROM sales s
JOIN product_details pd
ON s.prod_id = pd.product_id
GROUP BY category_id,category_name;

-- 5. What is the top selling product for each category?
WITH Top_Selling_Product_CTE AS
(
	SELECT
		category_id,
		category_name,
		product_name,
		SUM(qty) AS total_quantity,
		DENSE_RANK() OVER(PARTITION BY category_id ORDER BY SUM(qty) DESC) AS rk
	FROM sales s
	JOIN product_details pd
	ON s.prod_id = pd.product_id
	GROUP BY category_id, category_name, product_name
)
SELECT
	category_id,
	category_name,
	product_name,
	total_quantity
FROM Top_Selling_Product_CTE
WHERE rk = 1;

-- 6. What is the percentage split of revenue by product for each segment?
SELECT
	segment_id,
    segment_name,
    product_name,
	CONCAT(
        ROUND(
            SUM(qty * s.price * (1 - discount / 100)) 
            / 
            SUM(SUM(qty * s.price * (1 - discount / 100))) OVER (PARTITION BY segment_id)
            * 100, 
        2),
        '%'
    ) AS revenue_percentage
FROM sales s
JOIN product_details pd
ON s.prod_id = pd.product_id
GROUP BY segment_id, segment_name, product_name
ORDER BY segment_id, revenue_percentage DESC;

-- 7. What is the percentage split of revenue by segment for each category?
SELECT
	category_id,
    category_name,
    segment_name,
	CONCAT(
        ROUND(
            SUM(qty * s.price * (1 - discount / 100)) 
            / 
            SUM(SUM(qty * s.price * (1 - discount / 100))) OVER (PARTITION BY category_id)
            * 100, 
        2),
        '%'
    ) AS revenue_percentage
FROM sales s
JOIN product_details pd
ON s.prod_id = pd.product_id
GROUP BY category_id, segment_name, category_name
ORDER BY category_id, revenue_percentage DESC;

-- 8. What is the percentage split of total revenue by category?
SELECT
    category_id,
    category_name,
    CONCAT(
        ROUND(
            SUM(qty * s.price * (1 - discount / 100)) /
            (
                SELECT SUM(qty * s2.price * (1 - discount / 100))
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
GROUP BY category_id, category_name
ORDER BY category_id;

-- 9. What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)
SELECT
	product_id,
    product_name,
	CONCAT(ROUND(COUNT(DISTINCT txn_id)
    /
    (SELECT COUNT(DISTINCT txn_id) FROM sales) * 100, 2), '%') AS penetration
FROM sales s
JOIN product_details pd
ON s.prod_id = pd.product_id
WHERE qty >= 1
GROUP BY product_id, product_name;

-- 10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?
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
GROUP BY s1.prod_id, s2.prod_id, s3.prod_id
ORDER BY combo_count DESC
LIMIT 1;


-- BONUS QUESTION
-- Use a single SQL query to transform the product_hierarchy and product_prices datasets to the product_details table.
-- Combine product_hierarchy and product_prices to recreate product_details
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
    CONCAT(style_name, ' ', segment_name, ' - ', category_name) AS product_name,
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
