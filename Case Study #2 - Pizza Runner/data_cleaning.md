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

### 1. Customer Orders Table (`pizza_runner.customer_orders`)

**Issues Identified:**

- `exclusions` and `extras` columns contained **multiple values in one cell**.
- Blank cells and textual `"null"` values.

**Reasoning for Cleaning:**

- SQL requires **atomic values per row**  
- Replacing blank or textual `"null"` with SQL `NULL` ensures **consistency**  
- Enables aggregation, joins, and analysis without errors  

**Steps Performed (Excel):**

1. **Split multi-value columns**:  
   `Data > Get & Transform > Split Column > By Delimiter (,) > Advanced Settings > Split into Rows`  
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

**Outcome**

- All multi-value cells were split into atomic entries.  
- Blank cells and textual `"null"` values were converted to proper SQL `NULL`.  
- Data is standardized and ready for SQL analysis.

  ---

### 2. Runner Orders Table (`pizza_runner.runner_orders`)

**Reasoning:**  
- Columns `distance` and `duration` were stored as `VARCHAR` and included metrics (`km`, `minutes`).  
- Some cells were blank or had textual `"null"`.  
- To perform calculations (speed, delivery times), numeric data types were necessary.

**Steps Taken (SQL):**

- Removed metrics (`km`, `minutes`) to keep only numeric values.  
- Replaced blank and textual `"null"` values with SQL `NULL`.  
- Updated column data types: `distance` → `DECIMAL(5,2)`, `duration` → `INT`.

**SQL Cleaning Code:**

<details>
<summary><strong>Click to view SQL code</strong></summary>

```sql
-- Replace blank cells with SQL NULL
UPDATE runner_orders
SET distance = NULL
WHERE distance = '';

UPDATE runner_orders
SET duration = NULL
WHERE duration = '';

-- Replace text 'null' with SQL NULL
UPDATE runner_orders
SET distance = NULL
WHERE distance = 'null';

UPDATE runner_orders
SET duration = NULL
WHERE duration = 'null';

-- Alter data types
ALTER TABLE runner_orders MODIFY distance DECIMAL(5,2);
ALTER TABLE runner_orders MODIFY duration INT;
```
</details>

**Outcome**

- Distance and duration standardized as numeric values.
- Blank and textual "null" replaced with SQL `NULL`.
- Table is ready for calculations like speed, average delivery times, and analytics.

---

### 3. Pizza Recipes Table (`pizza_runner.pizza_recipes`)

**Reasoning:**  
- Columns containing toppings had **multiple values in one cell**, violating SQL atomicity.    
- Cleaning ensures each topping is a separate atomic value and consistent with SQL relational structure.

**Steps Taken (Excel & SQL):**

- **Excel:**  
  - Used `Data > Get & Transform > Text to Columns > Comma` to split toppings into separate cells.  
  - Replaced blank values and textual `"null"` with `NULL`.  
- **SQL:**  
  - Imported cleaned table into SQL (or any SQL client).  

**Outcome**

- Each topping is now in a separate, atomic cell.  
- Dataset is consistent and ready for analysis and joins with other tables.

---

### 4. Pizza Names Table (`pizza_runner.pizza_names`)

**Reasoning:**  
- Verified that `pizza_id` and `pizza_name` columns have correct data types.  
- Ensures relational integrity when joining with `customer_orders` and `pizza_recipes`.

**Steps Taken (SQL):**

- Checked `pizza_id` is numeric (`INT`).  
- Checked `pizza_name` is text (`VARCHAR`).  
- No further changes required.

**Outcome**

- Table clean, consistent, and ready for analysis.  

---

### 5. Pizza Toppings Table (`pizza_runner.pizza_toppings`)

**Reasoning:**  
- Table already mostly clean; verified column data types.  
- Ensures toppings can be linked correctly to `pizza_recipes` and `customer_orders`.

**Steps Taken (SQL):**

- Confirmed `topping_id` is numeric (`INT`).  
- Confirmed `topping_name` is text (`VARCHAR`).  
- No changes required.

**Outcome**

- Table clean and consistent.  
- Ready for analysis and joins with other tables.

---

### 6. Runners Table (`pizza_runner.runners`)

**Reasoning:**  
- Table was clean but checked formats for consistency.  
- Ensures proper analysis of runner registrations, delivery efficiency, and performance.

**Steps Taken (SQL):**

- Verified `runner_id` is numeric (`INT`).  
- Verified `registration_date` is in proper date format (`DATE`).  
- No changes required.

**Outcome**

- Table clean and ready for analysis of runner metrics and operational insights.

---

#### Overall Notes

- Missing values standardized as SQL `NULL`.  
- Multi-value columns split into atomic rows for SQL.  
- Numeric columns cleaned and updated to correct data types.  
- Other tables validated and required no changes.
