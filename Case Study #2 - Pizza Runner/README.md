# Case Study #2 – Pizza Runner

<img src="https://github.com/user-attachments/assets/138b552c-2c11-4cc0-ab99-463cbaddcf98" alt="Pizza Runner Banner" width="500" height="500" />

---

[![SQL Skill](https://img.shields.io/badge/SQL-Skill-blue)](https://www.sqlcourse.com/)
[![Data Analysis Skill](https://img.shields.io/badge/Data%20Analysis-Skill-green)](https://www.coursera.org/learn/data-analysis)
[![Customer Insights](https://img.shields.io/badge/Customer-Insights-orange)](https://hbr.org/2015/05/the-science-of-customer-insights)
[![Business Insights](https://img.shields.io/badge/Business-Insights-red)](https://www.forbes.com/sites/insights)
[![Data-Driven](https://img.shields.io/badge/Data-Driven-purple)](https://www.datadrivenbusiness.com/)
[![Excel Skill](https://img.shields.io/badge/Excel-Skill-blueviolet)](https://support.microsoft.com/excel)
[![ETL Skill](https://img.shields.io/badge/ETL-Skill-yellowgreen)](https://www.talend.com/resources/what-is-etl/)
[![GitHub Repo](https://img.shields.io/badge/GitHub-Repo-lightgrey)](https://github.com/your-username/your-repo)


---

## Introduction

Pizza Runner, launched by entrepreneur Danny, combines 80s retro styling with pizza delivery. Inspired by a social media post, Danny recruited “runners” to deliver fresh pizzas from his own house and even maxed out his credit card to hire freelance developers to build a mobile app for taking orders.

Despite its creative concept, Danny initially struggled to manage orders and delivery operations efficiently.

This case study demonstrates how data-driven insights can optimize delivery processes, improve customer satisfaction, and support the growth of a startup in the competitive food delivery market.

---

## Business Problem

**Pizza Runner** lacked actionable insights from its operational and customer data, limiting its ability to streamline deliveries and optimize customer satisfaction. Key challenges included:

- Managing **order and delivery efficiency**, including runner assignment, delivery times, and route optimization.  
- Understanding **customer behavior**, such as pizza preferences, order frequency, and popular extras or exclusions.  
- Dealing with **data quality issues**, including missing or inconsistent values in orders, runner assignments, and cancellations.  
- Utilizing available datasets (`runners`, `customer_orders`, `runner_orders`, `pizza_names`, `pizza_recipes`, `pizza_toppings`) effectively for **decision-making and business growth**.
  
---

## Business Questions

1. **Revenue Analysis:** Which menu items generate the highest revenue?  
2. **Customer Behavior:** How frequently do customers visit, and what is their typical spending pattern?  
3. **Loyalty Program Impact:** How does spending and purchasing behavior differ between loyalty program members and non-members?  
4. **Item Popularity:** What is the most purchased menu item overall?
5. **Inventory Insights:** Which items are most popular for each customer?  
6. **Loyalty Journey Analysis:** Which item was the first purchased after joining the loyalty program?
7. **Pre-Membership Behavior:** Which item was purchased last before the customer became a loyalty member?

## Available Dataset

The analysis uses three tables:

### 1. Runners Table (`pizza_runner.runners`)
Contains `runner_id` and `registration_date` for each delivery runner.  

![Runners Dataset](<img width="314" height="249" alt="image" src="https://github.com/user-attachments/assets/cbafa7b5-b1ce-425d-b805-9c933d4ba7bd" />)

### 2. Customers Orders Table (`pizza_runner.customers_orders`)
Captures each pizza ordered, including `pizza_id`, `exclusions`, `extras`, and `order_time`. 

![Customers Orders Dataset](<img width="793" height="735" alt="image" src="https://github.com/user-attachments/assets/247f891a-0e41-4dfe-8e4c-7e6c139788e5" />)

### 3. Runner Orders Table (`pizza_runner.runner_orders`)
Tracks orders assigned to runners, including `pickup_time`, `distance`, `duration`, and `cancellation` status. Some data quality issues exist.  

![Runner Orders Dataset](https://github.com/user-attachments/assets/your-runner-orders-screenshot)

### 4. Pizza Names Table (`pizza_runner.pizza_names`)
Lists available pizzas (`Meat Lovers` and `Vegetarian`) with their corresponding `pizza_id`.  

![Pizza Names Dataset](https://github.com/user-attachments/assets/your-pizza-names-screenshot)

### 5. Pizza Recipes Table (`pizza_runner.pizza_recipes`)
Shows the standard toppings for each pizza type.  

![Pizza Recipes Dataset](https://github.com/user-attachments/assets/your-pizza-recipes-screenshot)

### 6. Pizza Toppings Table (`pizza_runner.pizza_toppings`)
Contains all topping names and their corresponding `topping_id`.  

![Pizza Toppings Dataset](https://github.com/user-attachments/assets/your-pizza-toppings-screenshot) 

---

## Entity Relationship Diagram (ERD)

![Pizza Runner Entity Relationship Diagram](https://github.com/user-attachments/assets/4e78f0e7-2c9c-4d8d-907f-d3afda2047fc)
