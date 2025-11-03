# Data Cleaning Steps – Pizza Runner

![Data Cleaning Badge](https://img.shields.io/badge/Data-Cleaning-blue)
![SQL Badge](https://img.shields.io/badge/SQL-Skill-green)
![Excel Badge](https://img.shields.io/badge/Excel-Advanced-orange)

---

## Introduction

Before performing any SQL analysis for the **Pizza Runner** dataset, it was crucial to **clean and standardize the data**.  

The dataset contained multiple tables:

- `customer_orders`  
- `runner_orders`  
- `pizza_recipes`  
- `pizza_names`  
- `pizza_toppings`  
- `runners`  

Common issues included:

- Multiple values in a single cell (violating SQL atomicity)  
- Blank or inconsistent entries  
- Textual `"null"` instead of SQL `NULL`  
- Incorrect data types for numeric columns (`distance`, `duration`)  

This document outlines the **detailed cleaning steps**, reasoning, methods used (Excel & SQL), and example code for each table.

---

## 1️⃣ Customer Orders Table (`pizza_runner.customer_orders`)

**Issues Identified:**

- `exclusions` and `extras` columns contained **multiple values in one cell**  
- Blank cells and textual `"null"` values  
- `order_time` column has **date & time together**  

**Reasoning for Cleaning:**

- SQL requires **atomic values per row**  
- Replacing blank or textual `"null"` with SQL `NULL` ensures **consistency**  
- Enables aggregation, joins, and analysis without errors  

**Steps Performed (Excel):**

1. **Split multi-value columns**:  
   `Data > Get & Transform > Split Column > By Delimiter (,) > Split into Rows`  
2. **Replace blank cells or "null" text** with `NULL`  
3. Save cleaned table for SQL import  

**SQL Cleaning Code:**

<details>
<summary><strong>Click to view SQL code</strong></summary>

```sql
-- Replace blank cells with SQL NULL
UPDATE customer_orders
SET exclusions = NULL
WHERE exclusions = '';

UPDATE customer_orders
SET extras = NULL
WHERE extras = '';

-- Replace textual 'null' with SQL NULL
UPDATE customer_orders
SET exclusions = NULL
WHERE exclusions = 'null';

UPDATE customer_orders
SET extras = NULL
WHERE extras = 'null';

-- Verify table structure
DESCRIBE customer_orders;

-- Preview rows with NULLs
SELECT *
FROM customer_orders
WHERE exclusions IS NULL OR extras IS NULL
LIMIT 10;
```

</details>

### Outcome

- All multi-value cells were split into atomic entries.  
- Blank cells and textual `"null"` values were converted to proper SQL `NULL`.  
- Data is standardized and ready for SQL analysis. 
