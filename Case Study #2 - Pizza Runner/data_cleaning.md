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
- **Multi-value columns:** `exclusions` and `extras` had multiple values in a single cell, violating SQL atomicity.  
- **Blank or textual "null" values:** Needed to be standardized to SQL `NULL` for consistent analysis.  
- **Date-time formatting:** `order_time` was stored as text (`DD-MM-YYYY HH:MM`) and required conversion to `DATETIME` for time-based analysis.

**Reasoning for Cleaning:**
- **Multi-value columns:** Columns like `exclusions` and `extras` sometimes contained multiple values in a single cell, violating SQL atomicity. Splitting these ensures each change is captured as a separate entry.  

- **Blank or textual "null" values:** Some cells were blank (`''`) or contained the text `"null"`. Standardizing these as SQL `NULL` ensures consistency and avoids errors during SQL operations.  

- **Date-time formatting:** `order_time` was stored as text in the format `DD-MM-YYYY HH:MM`. Converting it to SQL `DATETIME` enables accurate time-based analyses (hourly trends, daily patterns, weekly reports).  

4. **Numeric conversions:** Columns `exclusions` and `extras` were converted to `INT` to allow aggregation and numeric computations, such as counting the number of changes per order. 

**Steps Performed (Excel):**
1. **Split multi-value columns**:  
   `Data > Get & Transform > Split Column > By Delimiter (,) > Advanced Settings > Split into Rows`  
2. **Replace blank cells or "null" text** with `NULL`  
3. Save cleaned table for SQL import  

**SQL Cleaning Code:**

<details>
<summary><strong>Click to view SQL code</strong></summary>

```sql
-- Replace blank or textual 'null' cells with SQL NULL in customer_orders
UPDATE customer_orders
SET exclusions = NULL
WHERE exclusions = '' OR exclusions = 'null';

UPDATE customer_orders
SET extras = NULL
WHERE extras = '' OR extras = 'null';

-- Verify table structure
DESCRIBE customer_orders;

-- Convert exclusions and extras table to INT
ALTER TABLE customer_orders
MODIFY COLUMN exclusions INT,
MODIFY COLUMN extras INT;

-- Convert text format to proper DATETIME
UPDATE runner_orders
SET pickup_time = STR_TO_DATE(pickup_time, '%d-%m-%Y %H:%i');

-- Modify the column data type
ALTER TABLE runner_orders
MODIFY COLUMN pickup_time DATETIME;

-- Preview rows with NULLs
SELECT *
FROM customer_orders
WHERE exclusions IS NULL OR extras IS NULL
LIMIT 10;
```

</details>

**Outcome**
- Multi-value ingredient columns (`exclusions`, `extras`) were split into atomic entries suitable for relational queries.  
- Blank and textual `"null"` values were standardized as SQL `NULL`, preventing errors in joins and filters.  
- `order_time` is now a `DATETIME` column, supporting analysis by hour, day, and week.  
- `exclusions` and `extras` columns are numeric (`INT`), enabling calculations like total changes per order.  
- The `customer_orders` table is now **cleaned, standardized, and fully ready for SQL analysis**.

  ---

### 2. Runner Orders Table (`pizza_runner.runner_orders`)

### **Issues Identified**
1. **Non-numeric values in numeric columns**
   - `distance` and `duration` sometimes contained text like "km" or "mins".
   - Prevented aggregation and calculation of totals, averages, and speeds.

2. **Missing values**
   - Blank cells or the text `'null'` in `distance`, `duration`, or `cancellation`.
   - Could cause inaccurate counts and analysis of successful deliveries.

3. **Inconsistent datetime format**
   - `pickup_time` was stored as text instead of proper `DATETIME`.
   - Could not perform time-based analysis like hourly or daily delivery trends.

4. **Cancellation text**
   - Mixed values like `'Customer Cancellation'` or `'Restaurant Cancellation'`.
   - Needed standardization to differentiate successful vs canceled orders.

**Reasoning:**  
1. **Handling numeric columns with unwanted metrics:**  
   - Columns `distance` and `duration` sometimes had text values like "km" or "mins" appended, which prevents numeric calculations.  
   - Removed these units to convert the columns to proper numeric types.

2. **Standardizing missing values:**  
   - Blank cells or the text `'null'` were replaced with SQL `NULL` to enable accurate filtering and aggregations.  

3. **Updating data types:**  
   - `distance` → `DECIMAL` to allow fractional values (e.g., 3.5 km).  
   - `duration` → `INT` to store delivery duration in minutes.  
   - `pickup_time` → `DATETIME` for proper time-based calculations.  

4. **Cancellation column standardization:**  
   - Ensured text entries like `'Customer Cancellation'` or `'Restaurant Cancellation'` are preserved for analysis.  
   - NULL represents successful deliveries.

**Steps Taken (SQL):**
- Removed metrics (`km`, `minutes`) to keep only numeric values.  
- Replaced blank and textual `"null"` values with SQL `NULL`.  
- Updated column data types: `distance` → `DECIMAL(5,2)`, `duration` → `INT`.

**SQL Cleaning Code:**
<details>
<summary><strong>Click to view SQL code</strong></summary>

```sql
-- Replace blank or textual 'null' cells with SQL NULL in runner_orders
UPDATE runner_orders
SET distance = NULL
WHERE distance = '' OR distance = 'null';

UPDATE runner_orders
SET duration = NULL
WHERE duration = '' OR duration = 'null';

UPDATE runner_orders
SET cancellation = NULL
WHERE cancellation = '' OR cancellation = 'null';

-- Update data types
ALTER TABLE runner_orders MODIFY distance DECIMAL(5,2);

ALTER TABLE runner_orders MODIFY duration INT;
MODIFY COLUMN duration INT;

ALTER TABLE runner_orders
MODIFY COLUMN pickup_time DATETIME;
```
</details>

**Outcome**
- `distance` and `duration` now contain **only numeric values** (`DECIMAL` and `INT` respectively), enabling calculations.  
- `pickup_time` is standardized to **DATETIME**, supporting time-based analysis.  
- Blank and textual `'null'` entries were replaced with **SQL NULL** for consistent handling of missing data.  
- `cancellation` column preserves meaningful cancellation reasons; successful deliveries are represented by `NULL`.  
- Table is now **ready for SQL queries and analysis** without data-type or missing-value issues.

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
