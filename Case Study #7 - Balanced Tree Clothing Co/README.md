# Case Study #7 – Balanced Tree Clothing Co.

<img src="https://github.com/user-attachments/assets/126a769a-52f9-4c39-88fc-deb80a1f6bb3" alt="Balanced Tree Clothing Co. Banner" width="500" height="500" />

---

[![SQL Skill](https://img.shields.io/badge/SQL-Skill-blue)](https://www.sqlcourse.com/) 
[![Data Analysis Skill](https://img.shields.io/badge/Data%20Analysis-Skill-green)](https://www.coursera.org/learn/data-analysis) 
[![Customer Insights](https://img.shields.io/badge/Customer-Insights-orange)](https://hbr.org/2015/05/the-science-of-customer-insights) 
[![Business Insights](https://img.shields.io/badge/Business-Insights-red)](https://www.forbes.com/sites/insights) 
[![Data-Driven](https://img.shields.io/badge/Data-Driven-purple)](https://www.datadrivenbusiness.com/) 
[![GitHub Repo](https://img.shields.io/badge/GitHub-Repo-lightgrey)](https://github.com/your-username/your-repo)

---

## Introduction

Balanced Tree Clothing Company provides an optimised range of clothing and lifestyle wear for the modern adventurer.  
The CEO, Danny Ma, has asked for an analysis of sales performance and a financial report to assist merchandising decisions.

---

## Business Problem

Key challenges the company faces:

- Understanding **overall sales performance** across products and categories.  
- Evaluating **product popularity** and **revenue contribution** by category and segment.  
- Analyzing **member vs non-member transactions**.  
- Identifying **top-performing products** to optimize inventory and marketing.

---

## Business Questions

1. **Total Sales Metrics:** Total quantity sold, revenue before discounts, and total discounts.  
2. **Transaction Analysis:** Number of unique transactions, average products per transaction, and member vs non-member split.  
3. **Top Products by Revenue:** Top 3 products by revenue before discounts.  
4. **Segment-Level Analysis:** Total quantity, revenue, and discount per segment; top-selling product per segment.  
5. **Category-Level Analysis:** Total quantity, revenue, and discount per category; top-selling product per category.  
6. **Product Penetration:** Transaction penetration per product (how many transactions included that product).

---

## Available Datasets

### 1. Product Details (`balanced_tree.product_details`)
Contains product information, categories, segments, and styles.  

| product_id | price | product_name                  | category_id | segment_id | style_id | category_name | segment_name | style_name           |
|------------|-------|-------------------------------|------------|-----------|---------|---------------|-------------|-------------------|
| c4a632     | 13    | Navy Oversized Jeans - Womens | 1          | 3         | 7       | Womens        | Jeans       | Navy Oversized     |
| e83aa3     | 32    | Black Straight Jeans - Womens | 1          | 3         | 8       | Womens        | Jeans       | Black Straight     |
| e31d39     | 10    | Cream Relaxed Jeans - Womens  | 1          | 3         | 9       | Womens        | Jeans       | Cream Relaxed      |
| d5e9a6     | 23    | Khaki Suit Jacket - Womens    | 1          | 4         | 10      | Womens        | Jacket      | Khaki Suit         |
| 72f5d4     | 19    | Indigo Rain Jacket - Womens   | 1          | 4         | 11      | Womens        | Jacket      | Indigo Rain        |
| 9ec847     | 54    | Grey Fashion Jacket - Womens  | 1          | 4         | 12      | Womens        | Jacket      | Grey Fashion       |
| 5d267b     | 40    | White Tee Shirt - Mens        | 2          | 5         | 13      | Mens          | Shirt       | White Tee          |
| c8d436     | 10    | Teal Button Up Shirt - Mens   | 2          | 5         | 14      | Mens          | Shirt       | Teal Button Up     |
| 2a2353     | 57    | Blue Polo Shirt - Mens        | 2          | 5         | 15      | Mens          | Shirt       | Blue Polo          |
| f084eb     | 36    | Navy Solid Socks - Mens       | 2          | 6         | 16      | Mens          | Socks       | Navy Solid         |
| b9a74d     | 17    | White Striped Socks - Mens    | 2          | 6         | 17      | Mens          | Socks       | White Striped      |
| 2feb6b     | 29    | Pink Fluro Polkadot Socks - Mens | 2      | 6         | 18      | Mens          | Socks       | Pink Fluro Polkadot|


### 2. Product Sales (`balanced_tree.sales`)
Contains transaction-level data: quantity, price, discount, member status, txn_id, timestamp.  

| prod_id | qty | price | discount | member | txn_id | start_txn_time         |
|---------|-----|-------|---------|--------|--------|-----------------------|
| c4a632  | 4   | 13    | 17      | t      | 54f307 | 2021-02-13 01:59:43   |
| 5d267b  | 4   | 40    | 17      | t      | 54f307 | 2021-02-13 01:59:43   |

> **Note:** Additional datasets (`product_hierarchy` and `product_prices`) are used only for the bonus challenge (recreate `product_details`).

---

## Solution / Approach

For each business question, **SQL queries** were used to extract actionable insights. Below are **sql queries, explanations, outputs and actionable insights**.  

All full queries and outputs are available in [`balanced_tree.sql`](balanced_tree.sql).

---

<details>
<summary><h3>Business Question 1: Total Quantity Sold & Revenue Analysis</h3></summary>

**SQL Query:**
```sql
SELECT 
    pd.product_name,
    SUM(s.qty) AS total_quantity_sold,
    SUM(s.price * s.qty) AS total_revenue_before_discount
FROM balanced_tree.sales s
JOIN balanced_tree.product_details pd
ON s.prod_id = pd.product_id
GROUP BY pd.product_name
ORDER BY total_revenue_before_discount DESC;
```

**Explanation:** This query calculates the total quantity sold and total revenue (before discounts) for each product. It joins the sales table with the product_details table to map product IDs to product names. Summing the quantity gives total units sold, and multiplying price by quantity gives total revenue. Ordering by revenue descending quickly identifies the top-performing products.

**Output:**
| product_name                  | total_quantity_sold | total_revenue_before_discount |
|-------------------------------|------------------|-------------------------------|
| Blue Polo Shirt - Mens        | 7,638            | 435,366                       |
| Grey Fashion Jacket - Womens  | 7,752            | 418,608                       |
| White Tee Shirt - Mens        | 7,600            | 304,000                       |
| Navy Solid Socks - Mens       | 7,584            | 273,024                       |
| Black Straight Jeans - Womens | 7,572            | 242,304                       |
| Pink Fluro Polkadot Socks - Mens | 7,540         | 218,660                       |
| Khaki Suit Jacket - Womens    | 7,504            | 172,592                       |
| Indigo Rain Jacket - Womens   | 7,514            | 142,766                       |
| White Striped Socks - Mens    | 7,310            | 124,270                       |
| Navy Oversized Jeans - Womens | 7,712            | 100,256                       |
| Cream Relaxed Jeans - Womens  | 7,414            | 74,140                        |
| Teal Button Up Shirt - Mens   | 7,292            | 72,920                        |

**Data Insight:**  
- Blue Polo Shirt - Mens generated the highest revenue (**435,366**), followed by Grey Fashion Jacket - Womens (**418,608**) and White Tee Shirt - Mens (**304,000**).  
- The top three products contribute **~45% of total revenue**, highlighting revenue concentration among a few key products.  
- Lower-revenue items like Teal Button Up Shirt and Cream Relaxed Jeans have less individual impact but still contribute to overall sales.

**Actionable Insights:**  
- Top-performing items like Blue Polo Shirt and Grey Fashion Jacket are main revenue drivers.  
- Mid-performing products such as White Tee Shirt and Navy Solid Socks show consistent demand.  
- Low-performing products like Teal Button Up Shirt and Cream Relaxed Jeans could benefit from marketing or bundling.

**Recommended Actions:**  
1. Promote top sellers: Feature Blue Polo Shirt and Grey Fashion Jacket in campaigns, bundle offers, and seasonal promotions.  
2. Boost mid-performers: Introduce targeted promotions, loyalty points, or limited-time deals for White Tee Shirt and Navy Solid Socks.  
3. Optimize low performers: Consider cross-selling, discounts, or repositioning Teal Button Up Shirt and Cream Relaxed Jeans to increase sales.

</details>


---

<details>
<summary><h3> Business Question 2: Customer visit frequency & spending patterns </h3></summary>

**SQL Query:**
```sql
SELECT 
    s.customer_id,
    SUM(m.price) AS total_amount,
    COUNT(DISTINCT s.order_date) AS customer_visits,
    ROUND(SUM(m.price) / COUNT(DISTINCT s.order_date),2) AS avg_spending
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;
```
**Explanation:** The query calculates each customer’s total spending, the number of visits, and the average spending per visit. It joins the sales and menu tables to get prices, sums total spending per customer, counts unique visit dates, and computes average spend per visit. This helps understand customer engagement and value.

**Output:**
| customer_id | total_amount | customer_visits | avg_spending |
|------------ |------------- |---------------- |------------- |
| A           | 76           | 4               | 19.00        |
| B           | 74           | 6               | 12.33        |
| C           | 36           | 2               | 18.00        |

**Actionable Insights:**  
- Customer A: High-value per visit – strong per-visit spending.  
- Customer B: Most frequent visitor but lower per-visit spend – opportunity to increase spend.  
- Customer C: Low frequency and lower total spend – engagement opportunity.

**Recommended Actions:**  
1. Offer **personalized promotions** to increase spending for frequent but lower-value customers (e.g., B).  
2. Implement **loyalty incentives** to increase visits for low-frequency customers (e.g., C).  
3. Provide **exclusive offers** to high-value customers (e.g., A) to retain them and increase lifetime value.

</details>

---

<details>
<summary><h3>Business Question 3: Top 3 Products by Revenue Before Discounts</h3></summary>

**SQL Query:**
```sql
-- Top 3 products by revenue before discounts
SELECT 
    pd.product_name,
    SUM(s.price * s.qty) AS total_revenue_before_discount
FROM balanced_tree.sales s
JOIN balanced_tree.product_details pd
ON s.prod_id = pd.product_id
GROUP BY pd.product_name
ORDER BY total_revenue_before_discount DESC
LIMIT 3;
```

**Explanation:** This query calculates total revenue per product before discounts by joining the `sales` table with `product_details`. By summing the product of quantity and price for each product, we identify which items generate the highest revenue, helping prioritize inventory, promotions, and merchandising.

**Output:**

| product_name                  | total_revenue_before_discount |
|-------------------------------|-------------------------------|
| Blue Polo Shirt - Mens        | 435,366                       |
| Grey Fashion Jacket - Womens  | 418,608                       |
| White Tee Shirt - Mens        | 304,000                       |

**Actionable Insights:**  
- **Blue Polo Shirt - Mens** is the top revenue-generating product, followed closely by **Grey Fashion Jacket - Womens** and **White Tee Shirt - Mens**.  
- Revenue is concentrated among a few products, showing which items drive the majority of sales.  
- Lower-selling products are not represented here, indicating areas that could benefit from promotions or repositioning.

**Recommended Actions:**  
1. **Promote top sellers** through marketing campaigns, bundle deals, or seasonal offers.  
2. **Ensure inventory levels** are sufficient for these high-demand products to avoid stockouts.  
3. **Boost lower-performing products** with targeted promotions, cross-selling, or discounts to increase overall revenue.

</details>

---

<details>
<summary><h3>Business Question 4: Segment-Level Analysis</h3></summary>

**SQL Query:**
```sql
-- Segment-level metrics including top-selling product
WITH segment_metrics AS (
    SELECT 
        pd.segment_name,
        SUM(s.qty) AS total_quantity,
        SUM(s.price * s.qty) AS total_revenue,
        ROUND(SUM((s.price * s.discount/100) * s.qty),2) AS total_discount
    FROM balanced_tree.sales s
    JOIN balanced_tree.product_details pd ON s.prod_id = pd.product_id
    GROUP BY pd.segment_name
),
top_products AS (
    SELECT 
        pd.segment_name,
        pd.product_name,
        SUM(s.price * s.qty) AS product_revenue,
        ROW_NUMBER() OVER(PARTITION BY pd.segment_name ORDER BY SUM(s.price * s.qty) DESC) AS rk
    FROM balanced_tree.sales s
    JOIN balanced_tree.product_details pd ON s.prod_id = pd.product_id
    GROUP BY pd.segment_name, pd.product_name
)
SELECT 
    sm.segment_name,
    sm.total_quantity,
    sm.total_revenue,
    sm.total_discount,
    tp.product_name AS top_selling_product,
    tp.product_revenue AS top_product_revenue
FROM segment_metrics sm
JOIN top_products tp 
    ON sm.segment_name = tp.segment_name AND tp.rk = 1;

```

**Explanation:** This query identifies which product segment contributed most to sales. It aggregates total quantity sold, total revenue, and total discount for each segment. It also determines the top-selling product within each segment based on revenue, helping merchandising and finance teams understand key revenue drivers and product importance within each segment.

**Output:**
| segment_name | total_quantity | total_revenue | total_discount | top_selling_product           | top_product_revenue |
| ------------ | -------------- | ------------- | -------------- | ----------------------------- | ------------------- |
| Jacket       | 22,770         | 733,966       | 88,554.92      | Grey Fashion Jacket - Womens  | 418,608             |
| Jeans        | 22,698         | 416,700       | 50,687.94      | Black Straight Jeans - Womens | 242,304             |
| Shirt        | 22,530         | 812,286       | 99,188.54      | Blue Polo Shirt - Mens        | 435,366             |
| Socks        | 22,434         | 615,954       | 74,026.88      | Navy Solid Socks - Mens       | 273,024             |

**Actionable Insights:**
- **Shirts and Jackets segments drive the highest revenue**, led by Blue Polo Shirt and Grey Fashion Jacket.  
- Jeans and Socks have high quantity but lower revenue, suggesting price or demand differences.  
- Top product in each segment contributes **~35–55% of segment revenue**, highlighting reliance on key items.

**Recommended Actions:**
1. **Promote top segment products:** Feature Blue Polo Shirt and Grey Fashion Jacket in campaigns or bundles.  
2. **Boost mid-performing segments:** Encourage Jeans and Socks purchases through cross-selling or limited-time promotions.  
3. **Optimize inventory planning:** Ensure sufficient stock of top-selling products to meet demand and prevent stockouts.

</details>

---

<details> 
<summary><h3> Business Question 5: Category Level Analysis </h3></summary>

## SQL Query:
```sql
-- Total quantity, revenue, discount per category, and top-selling product per category
WITH category_agg AS (
    SELECT 
        pd.category_name,
        SUM(s.qty) AS total_quantity,
        SUM(s.qty * s.price) AS total_revenue,
        SUM(s.qty * s.discount/100 * s.price) AS total_discount
    FROM balanced_tree.sales s
    JOIN balanced_tree.product_details pd
    ON s.prod_id = pd.product_id
    GROUP BY pd.category_name
),
top_product_per_category AS (
    SELECT 
        category_name,
        product_name,
        SUM(s.qty * s.price) AS revenue,
        ROW_NUMBER() OVER (PARTITION BY category_name ORDER BY SUM(s.qty * s.price) DESC) AS rn
    FROM balanced_tree.sales s
    JOIN balanced_tree.product_details pd
    ON s.prod_id = pd.product_id
    GROUP BY category_name, product_name
)
SELECT 
    c.category_name,
    c.total_quantity,
    c.total_revenue,
    c.total_discount,
    t.product_name AS top_selling_product,
    t.revenue AS top_product_revenue
FROM category_agg c
JOIN top_product_per_category t
ON c.category_name = t.category_name
WHERE t.rn = 1;

```

**Explanation:** This query calculates category-level performance by aggregating total quantity sold, total revenue, and total discount for each category. It also identifies the top-selling product per category using revenue ranking. This helps understand which categories and products are driving the most sales and profitability.

**Output:**
| category_name | total_quantity | total_revenue | total_discount | top_selling_product          | top_product_revenue |
| ------------- | -------------- | ------------- | -------------- | ---------------------------- | ------------------ |
| Mens          | 44,964         | 1,428,240     | 173,215.42     | Blue Polo Shirt - Mens       | 435,366            |
| Womens        | 45,468         | 1,150,666     | 139,242.86     | Grey Fashion Jacket - Womens | 418,608            |

**Actionable Insights:**
- **Mens category leads slightly in revenue**, driven by Blue Polo Shirt - Mens.  
- **Womens category performs strongly**, with Grey Fashion Jacket - Womens as the top revenue contributor.  
- Top products in each category contribute **~30% of category revenue**, indicating strong dependence on key items.  
- Discounts impact revenue proportionally across categories, requiring careful monitoring.

**Recommended Actions:**
1. **Promote top sellers:** Highlight Blue Polo Shirt and Grey Fashion Jacket in campaigns, promotions, and in-store displays.  
2. **Boost mid-performers:** Cross-sell or bundle other category products to increase overall revenue.  
3. **Optimize discount strategies:** Ensure discounts drive sales without eroding profit margins excessively.
   
</details>

---

<details>
<summary><h3>Business Question 6: Product Transaction Penetration</h3></summary>

**SQL Query:**
```sql
-- Calculate transaction penetration for each product
SELECT 
    pd.product_name,
    COUNT(DISTINCT s.txn_id) AS transaction_count,
   CONCAT(ROUND((COUNT(DISTINCT s.txn_id) * 100.0 / total_txns.total_transactions),2), '%') AS penetration_percentage
FROM balanced_tree.sales s
JOIN balanced_tree.product_details pd
ON s.prod_id = pd.product_id
GROUP BY pd.product_name
ORDER BY penetration_percentage DESC;

```
**Explanation:**  
This query calculates the transaction penetration for each product, i.e., the percentage of total transactions in which each product was purchased. It helps identify which products are consistently included in customer purchases and highlights the most popular items across all transactions.

**Output:**
| product_name                  | transaction_count | penetration_percentage |
|-------------------------------|-----------------|----------------------|
| Navy Solid Socks - Mens       | 1,281           | 51.24%               |
| Grey Fashion Jacket - Womens  | 1,275           | 51.00%               |
| Navy Oversized Jeans - Womens | 1,274           | 50.96%               |
| Blue Polo Shirt - Mens        | 1,268           | 50.72%               |
| White Tee Shirt - Mens        | 1,268           | 50.72%               |
| Pink Fluro Polkadot Socks - Mens | 1,258        | 50.32%               |
| Indigo Rain Jacket - Womens   | 1,250           | 50.00%               |
| Khaki Suit Jacket - Womens    | 1,247           | 49.88%               |
| Black Straight Jeans - Womens | 1,246           | 49.84%               |
| Cream Relaxed Jeans - Womens  | 1,243           | 49.72%               |
| White Striped Socks - Mens    | 1,243           | 49.72%               |
| Teal Button Up Shirt - Mens   | 1,242           | 49.68%               |

**Actionable Insights:**
- **Navy Solid Socks - Mens** and **Grey Fashion Jacket - Womens** are the most consistently purchased, showing they are staples in customer transactions.  
- Products with slightly lower penetration still appear in roughly half of all transactions, indicating balanced product assortment.  
- Consistent penetration across many items highlights opportunities for cross-selling and product bundling.

**Recommended Actions:**
1. **Maintain stock levels** for high-penetration products to meet consistent demand.  
2. **Bundle mid-penetration products** with top performers to increase exposure and sales.  
3. **Analyze common product combinations** to optimize promotions, store layout, and targeted marketing.
   
</details>

---

## Skills Demonstrated
| SQL Concept      | Description                               |
| ---------------- | ----------------------------------------- |
| JOIN             | Combined sales, menu, and member tables   |
| GROUP BY         | Aggregated revenue and frequency per item |
| ORDER BY         | Ranked items by revenue or popularity     |
| Window Functions | Calculated running totals and item ranks  |
| CASE Statements  | Conditional logic for member flags        |

---

## Optional Insights / Lessons Learned:

Data cleanliness and consistent ID formats are essential.

Structuring queries around business questions ensures insights are actionable.

Analysis can directly improve customer satisfaction, retention, and revenue.

---

## Resources

1. [8 Week SQL Challenge](https://8weeksqlchallenge.com/) - Official website with all case studies.
2. [Case Study #2 - Balanced Tree Clothing Co.](https://8weeksqlchallenge.com/case-study-7/) - Direct link to the case study details.





