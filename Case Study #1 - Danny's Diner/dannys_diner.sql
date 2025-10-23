/* =====================================================
   Danny's Diner - SQL Case Study
   ===================================================== */

/* =====================================================
   Q1: What is the total amount each customer spent at the restaurant?
   ===================================================== */
SELECT 
    customer_id, 
    SUM(price) AS total_amount
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY customer_id;

Explaination: This query joins the sales and menu tables to calculate the total amount each customer spent by summing up the prices of all their purchased items, grouped by customer_id.

-- Output:
-- +-------------+--------------+
-- | customer_id | total_amount |
-- +-------------+--------------+
-- | C           | 36           |
-- | B           | 74           |
-- | A           | 76           |
-- +-------------+--------------+

/* =====================================================
   Q2: How many days has each customer visited the restaurant?
   ===================================================== */
SELECT 
    customer_id, 
    COUNT(DISTINCT order_date) AS customer_visit
FROM sales
GROUP BY customer_id;

Explaination: This query counts the distinct order_date values for each customer to determine how many different days they visited the restaurant.

-- Output:
-- +-------------+----------------+
-- | customer_id | customer_visit |
-- +-------------+----------------+
-- | A           | 4              |
-- | B           | 6              |
-- | C           | 2              |
-- +-------------+----------------+

/* =====================================================
   Q3: What was the first item from the menu purchased by each customer?
   ===================================================== */
WITH FirstPurchase AS
(
	SELECT 
		customer_id, 
		product_name,
        order_date,
		DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date) AS order_ranking
	FROM sales s
	JOIN menu m ON s.product_id = m.product_id
)
SELECT
	DISTINCT product_name,
	customer_id, 
    order_date
FROM FirstPurchase
WHERE order_ranking = 1;

Explaination: Using a Common Table Expression (CTE) and the DENSE_RANK() function, this query identifies the first item each customer purchased based on the earliest order_date.

-- Output:
-- +-------------+-------------+------------+
-- | product_name| customer_id | order_date |
-- +-------------+-------------+------------+
-- | sushi       | A           | 2021-01-01 |
-- | curry       | A           | 2021-01-01 |
-- | curry       | B           | 2021-01-01 |
-- | ramen       | C           | 2021-01-01 |
-- +-------------+-------------+------------+


/* =====================================================
   Q4: What is the most purchased item on the menu and how many times was it purchased by all customers?
   ===================================================== */
SELECT 
    product_name, 
    COUNT(s.product_id) AS most_purchased_item
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY product_name
ORDER BY most_purchased_item DESC
LIMIT 1;

Explaination: This query groups all sales by product_name and counts the total number of times each item was purchased to find the most frequently ordered dish across all customers.

-- Output:
-- +-------------+---------------------+
-- | product_name| most_purchased_item |
-- +-------------+---------------------+
-- | ramen       | 8                   |
-- +-------------+---------------------+

/* =====================================================
   Q5: Which item was the most popular for each customer?
   ===================================================== */
WITH MostPopularItem AS
(
	SELECT 
		customer_id,
        product_name,
        COUNT(product_name) AS Qty,
        DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY COUNT(product_name) DESC) AS product_count_ranking
	FROM sales s
	JOIN menu m
	ON s.product_id = m.product_id
    GROUP BY 1,2
)
SELECT 
	customer_id,
	product_name,
    Qty
FROM MostPopularItem
WHERE product_count_ranking = 1;

Explaination: This query uses a CTE and DENSE_RANK() to find the menu item each customer ordered most frequently by counting the number of times each product was purchased.

-- Output:
+-------------+-------------+-----+
| customer_id | product_name| Qty |
+-------------+-------------+-----+
| A           | ramen       | 3   |
| B           | curry       | 2   |
| B           | sushi       | 2   |
| B           | ramen       | 2   |
| C           | ramen       | 3   |
+-------------+-------------+-----+

/* =====================================================
   Q6:  Which item was purchased first by the customer after they became a member?
   ===================================================== */
WITH FirstPurAfterMember AS
(
	SELECT 
		s.customer_id, 
		product_name, 
        order_date,
        join_date,
		DENSE_RANK() OVER
        (
			PARTITION BY s.customer_id 
            ORDER BY join_date, order_date
		) AS purchase_ranking
	FROM sales s
	JOIN members m
	ON s.customer_id = m.customer_id
	JOIN menu mu
	ON s.product_id = mu.product_id
	WHERE order_date >= join_date
)
SELECT 
	customer_id,
    product_name,
    order_date,
    join_date
FROM FirstPurAfterMember
WHERE purchase_ranking = 1;

Explaination: The query determines the first item each customer purchased after joining the loyalty program by comparing order_date and join_date, ranking purchases, and selecting the first one made as a member.

-- Output:
-- +-------------+-------------+------------+------------+
-- | customer_id | product_name| order_date | join_date  |
-- +-------------+-------------+------------+------------+
-- | A           | curry       | 2021-01-07 | 2021-01-07 | 
-- | B           | sushi       | 2021-01-11 | 2021-01-09 |
-- +-------------+-------------+------------+------------+

/* =====================================================
   Q7: Which item was purchased just before the customer became a member?
   ===================================================== */
WITH LastPurBeforeMember AS
(
	SELECT 
		s.customer_id, 
		product_name, 
        order_date,
        join_date,
		RANK() OVER
        (
			PARTITION BY s.customer_id 
            ORDER BY order_date DESC
		) AS purchase_ranking
	FROM sales s
	JOIN members m
	ON s.customer_id = m.customer_id
	JOIN menu mu
	ON s.product_id = mu.product_id
    WHERE order_date < join_date
)
SELECT 
	customer_id, 
	product_name,
	order_date,
    join_date
FROM LastPurBeforeMember
WHERE purchase_ranking = 1;

Explaination: This query identifies the final item each customer bought before becoming a member by filtering orders made before the join date and using ranking to select the latest one.

-- Output:
+-------------+-------------+------------+------------+
| customer_id | product_name| order_date | join_date  |
+-------------+-------------+------------+------------+
| A           | sushi       | 2021-01-01 | 2021-01-07 |
| A           | curry       | 2021-01-01 | 2021-01-07 |
| B           | sushi       | 2021-01-04 | 2021-01-09 |
+-------------+-------------+------------+------------+

/* =====================================================
   Q8: What is the total items and amount spent for each member before they became a member?
   ===================================================== */
WITH TotalItemAmountBeforeMember AS
(
	SELECT 
		s.customer_id,
        COUNT(*) AS total_items, 
        SUM(price) AS total_amount
	FROM sales s
	JOIN members m ON s.customer_id = m.customer_id
	JOIN menu mu ON s.product_id = mu.product_id
    WHERE order_date < join_date
    GROUP BY s.customer_id
)
SELECT *
FROM TotalItemAmountBeforeMember;

Explaination: It calculates how many items each member bought and how much they spent in total before joining the loyalty program, grouping data by customer ID.

-- Output:
-- +-------------+------------+-------------+
-- | customer_id | total_items| total_amount|
-- +-------------+------------+-------------+
-- | B           | 3          | 40          |
-- | A           | 2          | 25          |
-- +-------------+------------+-------------+

/* =====================================================
   Q9: If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
   ===================================================== */
SELECT 
	customer_id,
    SUM(
		CASE
			WHEN product_name = 'Sushi' THEN price * 20 
            ELSE price * 10
		END
	) AS total_points
FROM Sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY customer_id;

Explaination: This query calculates loyalty points for each customer, giving 10 points per dollar spent on most items and 20 points for sushi by applying conditional logic using a CASE statement.

-- Output:
-- +-------------+-------------+
-- | customer_id | total_points|
-- +-------------+-------------+
-- | A           | 860         |
-- | B           | 940         |
-- | C           | 360         |
-- +-------------+-------------+

/* =====================================================
   Q10: In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
   ===================================================== */
SELECT 
	s.customer_id,
    SUM(
		CASE 
			WHEN order_date BETWEEN join_date AND DATE_ADD(join_date, INTERVAL 6 DAY) THEN price * 20
            WHEN product_name = 'Sushi' THEN price * 20
            ELSE price * 10
		END
	) AS total_points
FROM sales s
JOIN members m ON s.customer_id = m.customer_id
JOIN menu mu ON s.product_id = mu.product_id
WHERE DATE_FORMAT(order_date, '%Y-%m-%d') <= '2021-01-31'
GROUP BY s.customer_id
ORDER BY s.customer_id;

Explaination: This query extends the loyalty points logic to apply a 2x multiplier for all purchases made within the first week after membership (including the join date), combining date-based conditions and item-based multipliers.

-- Output:
-- +-------------+-------------+
-- | customer_id | total_points|
-- +-------------+-------------+
-- | A           | 1370        |
-- | B           | 820         |
-- +-------------+-------------+

/* =====================================================
   Bonus Q11: The following questions are related creating basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL.
   ===================================================== */
SELECT 
	s.customer_id,
    order_date,
    product_name,
    price,
    CASE 
		WHEN order_date >= join_date THEN 'Y'
        ELSE 'N'
	END AS member
FROM sales s
LEFT JOIN members m ON s.customer_id = m.customer_id
LEFT JOIN menu mu ON s.product_id = mu.product_id
ORDER BY s.customer_id;

Explaination: This query creates a detailed transaction table combining customer, order, and membership data. It uses a CASE statement to label each transaction as either a member (‘Y’) or non-member (‘N’) purchase.

-- Output:
- +-------------+------------+-------------+-------+--------+
-- | customer_id | order_date | product_name| price | member |
-- +-------------+------------+-------------+-------+--------+
-- | A           | 2021-01-01 | sushi       | 10    | N      |
-- | A           | 2021-01-01 | curry       | 15    | N      |
-- | A           | 2021-01-07 | curry       | 15    | Y      |
-- | A           | 2021-01-10 | ramen       | 12    | Y      |
-- | A           | 2021-01-11 | ramen       | 12    | Y      |
-- | A           | 2021-01-11 | ramen       | 12    | Y      |
-- | B           | 2021-01-01 | curry       | 15    | N      |
-- | B           | 2021-01-02 | curry       | 15    | N      |
-- | B           | 2021-01-04 | sushi       | 10    | N      |
-- | B           | 2021-01-11 | sushi       | 10    | Y      |
-- | B           | 2021-01-16 | ramen       | 12    | Y      |
-- | B           | 2021-02-01 | ramen       | 12    | Y      |
-- | C           | 2021-01-01 | ramen       | 12    | N      |
-- | C           | 2021-01-01 | ramen       | 12    | N      |
-- | C           | 2021-01-07 | ramen       | 12    | N      |
-- +-------------+------------+-------------+-------+--------+

/* =====================================================
   Bonus Q12: Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.
   ===================================================== */
WITH RankAllThings AS
(
	SELECT 
		s.customer_id,
		order_date,
		product_name,
		price,
		CASE 
			WHEN order_date >= join_date THEN 'Y'
				ELSE 'N'
		END AS member
	FROM sales s
	LEFT JOIN members m ON s.customer_id = m.customer_id
	LEFT JOIN menu mu ON s.product_id = mu.product_id
),
RankingAllItems AS
(
	SELECT *,
	CASE 
		WHEN member = 'Y' THEN DENSE_RANK() OVER(PARTITION BY customer_id, member ORDER BY order_date)
		ELSE NULL
	END AS ranking
	FROM RankAllThings
)
SELECT * FROM RankingAllItems;

Explaination: Using nested CTEs, this query assigns rankings to purchases made after becoming a member while leaving pre-membership transactions unranked, helping track order patterns among members.

-- Output:
+-------------+------------+-------------+-------+--------+---------+
-- | customer_id | order_date | product_name| price | member | ranking |
-- +-------------+------------+-------------+-------+--------+---------+
-- | A           | 2021-01-01 | sushi       | 10    | N      | NULL    |
-- | A           | 2021-01-01 | curry       | 15    | N      | NULL    |
-- | A           | 2021-01-07 | curry       | 15    | Y      | 1       |
-- | A           | 2021-01-10 | ramen       | 12    | Y      | 2       |
-- | A           | 2021-01-11 | ramen       | 12    | Y      | 3       |
-- | A           | 2021-01-11 | ramen       | 12    | Y      | 3       |
-- | B           | 2021-01-01 | curry       | 15    | N      | NULL    |
-- | B           | 2021-01-02 | curry       | 15    | N      | NULL    |
-- | B           | 2021-01-04 | sushi       | 10    | N      | NULL    |
-- | B           | 2021-01-11 | sushi       | 10    | Y      | 1       |
-- | B           | 2021-01-16 | ramen       | 12    | Y      | 2       |
-- | B           | 2021-02-01 | ramen       | 12    | Y      | 3       |
-- | C           | 2021-01-01 | ramen       | 12    | N      | NULL    |
-- | C           | 2021-01-01 | ramen       | 12    | N      | NULL    |
-- | C           | 2021-01-07 | ramen       | 12    | N      | NULL    |
-- +-------------+------------+-------------+-------+--------+---------+
