/* =====================================================
   Balanced Tree Clothing Co. - SQL Case Study
   ===================================================== */

/* =====================================================
   A. High-Level Sales Analysis
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

--Output:
+----------------------+
| total_quantity_sold  |
+----------------------+
| 45216                |
+----------------------+

/* -----------------------------------------------------
   Q2: What is the total generated revenue for all products before discounts?
   ----------------------------------------------------- */
SELECT 
    CONCAT("$", SUM(qty * price)) AS total_revenue_generated
FROM sales;

-- Explanation:
-- Revenue is calculated by multiplying quantity and price
-- for each sale before applying any discounts.

-- Output:
+---------------------------+
| total_revenue_generated   |
+---------------------------+
| $1289453                   |
+---------------------------+

/* -----------------------------------------------------
   Q3: What was the total discount amount for all products?
   ----------------------------------------------------- */
SELECT 
    CONCAT("$", ROUND(SUM(qty * price * (discount / 100)),2)) AS total_discount_amount
FROM sales;

-- Explanation:
-- This query calculates total discounts by applying the
-- discount percentage to the gross revenue.

-- Output:
+------------------------+
| total_discount_amount  |
+------------------------+
| $156229.14              |
+------------------------+

/* =====================================================
   B. Transaction Analysis
   ===================================================== */

/* -----------------------------------------------------
   Q1: How many unique transactions were there?
   ----------------------------------------------------- */
SELECT 
    COUNT(DISTINCT txn_id) AS unique_transactions
FROM sales;

-- Explanation:
-- Counts distinct transaction IDs to find the total
-- number of unique transactions.

-- Output:
+----------------------+
| unique_transactions  |
+----------------------+
| 2500                 |
+----------------------+
   
/* -----------------------------------------------------
   Q2: What is the average number of unique products purchased per transaction?
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

-- Output:
+-----------------------------------------------+
| avg_unique_products_per_transaction            |
+-----------------------------------------------+
| 6.04                                          |
+-----------------------------------------------+

/* -----------------------------------------------------
   Q3: What are the 25th, 50th, and 75th percentile values for revenue per transaction?
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

-- Output:
+------------------+-----------------------+
| percentile       | revenue_per_transaction |
+------------------+-----------------------+
| 25th percentile  | 326.18                |
| 50th percentile  | 441.00                |
| 75th percentile  | 572.75                |
+------------------+-----------------------+

/* -----------------------------------------------------
   Q4: What is the average discount value per transaction?
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

-- Output: 
+-------------------------------+
| avg_discount_per_transaction  |
+-------------------------------+
| 62.49                         |
+-------------------------------+

/* -----------------------------------------------------
Q5: What is the percentage split of all transactions for members vs non-members?
----------------------------------------------------- */
SELECT
	member,
	ROUND(
        (COUNT(DISTINCT txn_id) / 
        (SELECT COUNT(DISTINCT txn_id) AS total_transactions FROM sales) * 100), 2
    ) AS percentage_split
FROM sales
GROUP BY member;

-- Explanation:
-- This query calculates the percentage of transactions made by members (member = 1) versus non-members (member = 0).
-- It counts the distinct transaction IDs per member type, divides by the total transactions, and multiplies by 100.

-- Output: 
   +--------+-----------------+
| member | percentage_split|
+--------+-----------------+
| 0      | 39.80           |
| 1      | 60.20           |
+--------+-----------------+

/* -----------------------------------------------------      
Q6: What is the average revenue for member transactions and non-member transactions?
----------------------------------------------------- */
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

-- Explanation:
-- First, total revenue is calculated for each transaction by summing qty * price * (1 - discount/100).
-- Then the average revenue is calculated separately for member and non-member transactions.

-- Output:
+--------+---------------------------+
| member | average_revenue_per_transaction |
+--------+---------------------------+
| 1      | 454.14                    |
| 0      | 452.01                    |
+--------+---------------------------+

/* =====================================================
   C. Product & Category Analysis
   ===================================================== */
   
   /* -----------------------------------------------------
Q1: What are the top 3 products by total revenue before discount?
----------------------------------------------------- */

SELECT
	product_id,
	product_name,
   CONCAT("$",SUM(qty * s.price)) AS total_revenue
FROM sales s
JOIN product_details pd
    ON s.prod_id = pd.product_id
GROUP BY product_id, product_name
ORDER BY total_revenue DESC
LIMIT 3;

-- Explanation:
-- Total revenue per product is calculated without considering discounts.
-- The top 3 products are selected by ordering total revenue in descending order.

-- Output:
+------------+----------------------------+--------------+
| product_id | product_name               | total_revenue|
+------------+----------------------------+--------------+
| 2a2353     | Blue Polo Shirt - Mens     | $435366       |
| 9ec847     | Grey Fashion Jacket - Womens| $418608      |
| 5d267b     | White Tee Shirt - Mens     | $304000       |
+------------+----------------------------+--------------+

/* -----------------------------------------------------
Q2: What is the total quantity, revenue, and discount for each segment?
----------------------------------------------------- */
SELECT
	segment_id,
   segment_name,
	SUM(qty) AS total_quantity,
   CONCAT("$",ROUND(SUM(qty * s.price), 2)) AS total_revenue_before_discount,
   CONCAT("$",ROUND(SUM(qty * s.price * (1 - discount / 100)), 2)) AS total_revenue,
   CONCAT("$",ROUND(SUM(qty * s.price * discount / 100), 2)) AS total_discount
FROM sales s
JOIN product_details pd
    ON s.prod_id = pd.product_id
GROUP BY segment_id, segment_name;

-- Explanation:
-- This query aggregates sales data by segment.
-- For each segment, it calculates:
-- 1. Total quantity sold (SUM(qty))
-- 2. Total revenue before discount (SUM(qty * price))
-- 3. Total revenue after discount (SUM(qty * price * (1 - discount/100)))
-- 4. Total discount amount (SUM(qty * price * discount/100))

-- Output:
+------------+------------+---------------+------------------------+----------------+--------------+
| segment_id | segment_name | total_quantity | total_revenue_before_discount | total_revenue | total_discount |
+------------+------------+---------------+------------------------+----------------+--------------+
| 3          | Jeans       | 22698         | $416700                 | $366012.06      | $50687.94      |
| 5          | Shirt       | 22530         | $812286                 | $713097.46      | $99188.54      |
| 6          | Socks       | 22434         | $615954                 | $541927.12      | $74026.88      |
| 4          | Jacket      | 22770         | $733966                 | $645411.08      | $88554.92      |
+------------+------------+---------------+------------------------+----------------+--------------+

/* -----------------------------------------------------
Q3: What is the top-selling product for each segment?
----------------------------------------------------- */
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
	GROUP BY segment_id, segment_name, product_name
)
SELECT
	segment_id,
	segment_name,
	product_name,
	total_quantity
FROM Top_Selling_Product_CTE
WHERE rk = 1;

-- Explanation:
-- This query identifies the top-selling product for each segment.
-- Steps:
-- 1. Aggregate the total quantity sold per product in each segment.
-- 2. Rank products within each segment using DENSE_RANK().
-- 3. Select the product with rank 1 for each segment.

-- Output:
+------------+------------+-------------------------------+---------------+
| segment_id | segment_name | product_name                 | total_quantity|
+------------+------------+-------------------------------+---------------+
| 3          | Jeans       | Navy Oversized Jeans - Womens| 7712          |
| 4          | Jacket      | Grey Fashion Jacket - Womens | 7752          |
| 5          | Shirt       | Blue Polo Shirt - Mens       | 7638          |
| 6          | Socks       | Navy Solid Socks - Mens      | 7584          |
+------------+------------+-------------------------------+---------------+

/* -----------------------------------------------------
Q4: What is the total quantity, revenue, and discount for each category?
----------------------------------------------------- */
SELECT
	category_id,
   category_name,
	SUM(qty) AS total_quantity,
   CONCAT("$",ROUND(SUM(qty * s.price), 2)) AS total_revenue_before_discount,
   CONCAT("$",ROUND(SUM(qty * s.price * (1 - discount / 100)),2)) AS total_revenue,
   CONCAT("$",ROUND(SUM(qty * s.price * discount / 100),2)) AS total_discount
FROM sales s
JOIN product_details pd
    ON s.prod_id = pd.product_id
GROUP BY category_id, category_name;

-- Explanation:
-- 1. Aggregate sales data for each category.
-- 2. Calculates the total quantity sold, revenue before and after discount, and the total discount.

-- Output:
+-------------+-----------+----------------+------------------------+-------------------+---------------+
| category_id | category_name | total_quantity | total_revenue_before_discount | total_revenue | total_discount |
+-------------+-----------+----------------+------------------------+-------------------+---------------+
| 1           | Womens    | 45468          | $1150666                | $1011423.14        | $139242.86     |
| 2           | Mens      | 44964          | $1428240                | $1255024.58        | $173215.42     |
+-------------+-----------+----------------+------------------------+-------------------+---------------+

/* -----------------------------------------------------
Q5: What is the top-selling product for each category?
----------------------------------------------------- */
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

-- Explanation:
-- 1. Calculates the total quantity sold for each product in every category.
-- 2. Ranks products within each category using DENSE_RANK() based on total quantity.
-- 3. Retrieves the top-ranked (highest quantity) product for each category.

-- Output:
+-------------+-----------+------------------------+----------------+
| category_id | category_name | product_name         | total_quantity |
+-------------+-----------+------------------------+----------------+
| 1           | Womens    | Grey Fashion Jacket - Womens | 7752       |
| 2           | Mens      | Blue Polo Shirt - Mens       | 7638       |
+-------------+-----------+------------------------+----------------+

/* -----------------------------------------------------
Q6: What is the percentage split of revenue by product for each segment?
----------------------------------------------------- */
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

-- Explanation:
-- 1. Calculates the total revenue per product after discount.
-- 2. Uses a window function to find the total revenue for each segment.
-- 3. Computes each product's contribution as a percentage of its segment’s revenue.
-- 4. Orders results by segment, with revenue percentage descending.

-- Output:
+------------+-----------+-------------------------------+------------------+
| segment_id | segment_name | product_name               | revenue_percentage |
+------------+-----------+-------------------------------+------------------+
| 3          | Jeans     | Black Straight Jeans - Womens | 58.14%           |
| 3          | Jeans     | Navy Oversized Jeans - Womens | 24.04%           |
| 3          | Jeans     | Cream Relaxed Jeans - Womens  | 17.82%           |
| 4          | Jacket    | Grey Fashion Jacket - Womens  | 56.99%           |
| 4          | Jacket    | Khaki Suit Jacket - Womens    | 23.57%           |
| 4          | Jacket    | Indigo Rain Jacket - Womens   | 19.44%           |
| 5          | Shirt     | Teal Button Up Shirt - Mens   | 8.99%            |
| 5          | Shirt     | Blue Polo Shirt - Mens        | 53.53%           |
| 5          | Shirt     | White Tee Shirt - Mens        | 37.48%           |
| 6          | Socks     | Navy Solid Socks - Mens       | 44.24%           |
| 6          | Socks     | Pink Fluro Polkadot Socks - Mens | 35.57%        |
| 6          | Socks     | White Striped Socks - Mens    | 20.20%           |
+------------+-----------+-------------------------------+------------------+

/* -----------------------------------------------------
Q7: What is the percentage split of revenue by segment for each category?
----------------------------------------------------- */
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
GROUP BY category_id, category_name, segment_name
ORDER BY category_id, revenue_percentage DESC;

-- Explanation:
-- 1. Calculates revenue after discount per segment within each category.
-- 2. Uses a window function to calculate total revenue per category.
-- 3. Computes each segment's contribution as a percentage of its category’s revenue.
-- 4. Orders results by category, with revenue percentage descending.

-- Output:
+------------+---------------+-----------+------------------+
| category_id | category_name | segment_name | revenue_percentage |
+------------+---------------+-----------+------------------+
| 1          | Womens        | Jacket    | 63.81%           |
| 1          | Womens        | Jeans     | 36.19%           |
| 2          | Mens          | Shirt     | 56.82%           |
| 2          | Mens          | Socks     | 43.18%           |
+------------+---------------+-----------+------------------+

/* -----------------------------------------------------
Q8: What is the percentage split of total revenue by category?
----------------------------------------------------- */
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

-- Explanation:
-- 1. Calculates total revenue after discount for each category.
-- 2. Divides each category's revenue by the total revenue across all categories.
-- 3. Converts the result into a percentage.
-- 4. Orders the results by category ID.

-- Output:
+------------+---------------+------------------+
| category_id | category_name | revenue_percentage |
+------------+---------------+------------------+
| 1          | Womens        | 44.63%           |
| 2          | Mens          | 55.37%           |
+------------+---------------+------------------+

/* -----------------------------------------------------
Q9: What is the total transaction “penetration” for each product? 
   (Hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)
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
GROUP BY product_id, product_name;

-- Explanation:
-- 1. Counts the number of transactions that included each product.
-- 2. Divide this count by the total number of transactions to get penetration.
-- 3. Converts the result into a percentage.

-- Output:
+------------+--------------------------------------+------------+
| product_id | product_name                          | penetration|
+------------+--------------------------------------+------------+
| 2a2353     | Blue Polo Shirt - Mens                | 50.72%     |
| 2feb6b     | Pink Fluro Polkadot Socks - Mens      | 50.32%     |
| 5d267b     | White Tee Shirt - Mens                | 50.72%     |
| 72f5d4     | Indigo Rain Jacket - Womens           | 50.00%     |
| 9ec847     | Grey Fashion Jacket - Womens          | 51.00%     |
| b9a74d     | White Striped Socks - Mens            | 49.72%     |
| c4a632     | Navy Oversized Jeans - Womens         | 50.96%     |
| c8d436     | Teal Button Up Shirt - Mens           | 49.68%     |
| d5e9a6     | Khaki Suit Jacket - Womens            | 49.88%     |
| e31d39     | Cream Relaxed Jeans - Womens          | 49.72%     |
| e83aa3     | Black Straight Jeans - Womens         | 49.84%     |
| f084eb     | Navy Solid Socks - Mens               | 51.24%     |
+------------+--------------------------------------+------------+

/* -----------------------------------------------------
Q10: What is the most common combination of any 3 products in a single transaction?
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
-- 1. Self-joins the sales table three times to identify all 3-product combinations within the same transaction.
-- 2. Ensures distinct combinations using the condition s1.prod_id < s2.prod_id < s3.prod_id.
-- 3. Counts how many transactions contain each 3-product combination.
-- 4. Orders by count in descending order and selects the top combination.

-- Output:
+------------+------------+------------+------------+
| product_1  | product_2  | product_3  | combo_count|
+------------+------------+------------+------------+
| 5d267b     | 9ec847     | c8d436     | 352        |
+------------+------------+------------+------------+

/* =====================================================
   BONUS QUESTION: 
   Use a single SQL query to transform the product_hierarchy and product_prices datasets into the product_details table. 
   Combine product_hierarchy and product_prices to recreate product_details
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
