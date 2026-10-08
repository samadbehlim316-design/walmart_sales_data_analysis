# Walmart Project Queries — MySQL

## 1. View the Complete Dataset

```sql
SELECT *
FROM walmart;
```

---

## 2. Count Total Records

```sql
SELECT COUNT(*) AS total_records
FROM walmart;
```

---

## 3. Count Transactions by Payment Method

```sql
SELECT
    payment_method,
    COUNT(*) AS no_payments
FROM walmart
GROUP BY payment_method
ORDER BY no_payments DESC;
```

---

## 4. Count Distinct Branches

```sql
SELECT COUNT(DISTINCT branch) AS total_branches
FROM walmart;
```

---

## 5. Find the Minimum Quantity Sold

```sql
SELECT MIN(quantity) AS minimum_quantity
FROM walmart;
```

---

# Business Analysis Questions

## Q1. Find Different Payment Methods, Number of Transactions, and Quantity Sold

```sql
SELECT
    payment_method,
    COUNT(*) AS no_payments,
    SUM(quantity) AS no_qty_sold
FROM walmart
GROUP BY payment_method
ORDER BY no_payments DESC;
```

### What this tells us

This query shows:

* Each payment method
* Number of transactions
* Total quantity of products sold

---

# Q2. Identify the Highest-Rated Category in Each Branch

```sql
WITH category_ratings AS (
    SELECT
        branch,
        category,
        AVG(rating) AS avg_rating
    FROM walmart
    GROUP BY branch, category
),
ranked_categories AS (
    SELECT
        branch,
        category,
        avg_rating,
        RANK() OVER (
            PARTITION BY branch
            ORDER BY avg_rating DESC
        ) AS rank_no
    FROM category_ratings
)
SELECT
    branch,
    category,
    ROUND(avg_rating, 2) AS avg_rating
FROM ranked_categories
WHERE rank_no = 1
ORDER BY branch;
```

### What this tells us

For every branch, this identifies the category with the highest average customer rating.

Using a separate CTE for `AVG(rating)` makes the query cleaner and easier to understand.

---

# Q3. Identify the Busiest Day for Each Branch

Your dataset contains dates such as:

```text
05/01/19
08/03/19
27/01/19
```

Therefore, the correct date format is:

```text
%d/%m/%y
```

Use:

```sql
WITH daily_transactions AS (
    SELECT
        branch,
        DAYNAME(STR_TO_DATE(`date`, '%d/%m/%y')) AS day_name,
        COUNT(*) AS no_transactions
    FROM walmart
    GROUP BY
        branch,
        DAYNAME(STR_TO_DATE(`date`, '%d/%m/%y'))
),
ranked_days AS (
    SELECT
        branch,
        day_name,
        no_transactions,
        RANK() OVER (
            PARTITION BY branch
            ORDER BY no_transactions DESC
        ) AS rank_no
    FROM daily_transactions
)
SELECT
    branch,
    day_name,
    no_transactions
FROM ranked_days
WHERE rank_no = 1
ORDER BY branch;
```

### What this tells us

This identifies the weekday with the highest number of transactions for each branch.

---

# Q4. Calculate Total Quantity Sold by Payment Method

```sql
SELECT
    payment_method,
    SUM(quantity) AS total_quantity_sold
FROM walmart
GROUP BY payment_method
ORDER BY total_quantity_sold DESC;
```

---

# Q5. Calculate Minimum, Maximum, and Average Rating by City and Category

```sql
SELECT
    city,
    category,
    ROUND(MIN(rating), 2) AS min_rating,
    ROUND(MAX(rating), 2) AS max_rating,
    ROUND(AVG(rating), 2) AS avg_rating
FROM walmart
GROUP BY city, category
ORDER BY city, category;
```

### What this tells us

This provides customer-rating statistics for every product category within each city.

---

# Q6. Calculate Total Profit for Each Category

Since profit is calculated using:

```text
Profit = Unit Price × Quantity × Profit Margin
```

Use:

```sql
SELECT
    category,
    ROUND(
        SUM(unit_price * quantity * profit_margin),
        2
    ) AS total_profit
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;
```

This version does not depend on the `total` column and therefore works even if `total` was not uploaded to MySQL.

---

# Q7. Determine the Most Common Payment Method for Each Branch

```sql
WITH payment_counts AS (
    SELECT
        branch,
        payment_method,
        COUNT(*) AS total_transactions
    FROM walmart
    GROUP BY branch, payment_method
),
ranked_payments AS (
    SELECT
        branch,
        payment_method,
        total_transactions,
        RANK() OVER (
            PARTITION BY branch
            ORDER BY total_transactions DESC
        ) AS rank_no
    FROM payment_counts
)
SELECT
    branch,
    payment_method AS preferred_payment_method,
    total_transactions
FROM ranked_payments
WHERE rank_no = 1
ORDER BY branch;
```

### What this tells us

This identifies the most frequently used payment method at each Walmart branch.

If two payment methods have the same highest number of transactions, both will be returned because `RANK()` is being used.

---

# Q8. Categorize Sales into Morning, Afternoon, and Evening

```sql
SELECT
    branch,
    CASE
        WHEN HOUR(`time`) < 12 THEN 'Morning'
        WHEN HOUR(`time`) < 18 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS num_invoices
FROM walmart
GROUP BY
    branch,
    CASE
        WHEN HOUR(`time`) < 12 THEN 'Morning'
        WHEN HOUR(`time`) < 18 THEN 'Afternoon'
        ELSE 'Evening'
    END
ORDER BY
    branch,
    num_invoices DESC;
```

### Shift Definition

| Time          | Shift     |
| ------------- | --------- |
| Before 12:00  | Morning   |
| 12:00–17:59   | Afternoon |
| 18:00 onwards | Evening   |

---

# Q9. Compare Revenue Between Years

## Important Dataset Correction

Your original query compares:

```text
2022 → 2023
```

However, your Walmart dataset contains dates such as:

```text
05/01/19
08/03/19
27/01/19
```

Therefore, the dataset appears to represent **2019**, not 2022–2023.

First, verify the available year:

```sql
SELECT DISTINCT
    YEAR(STR_TO_DATE(`date`, '%d/%m/%y')) AS year
FROM walmart
ORDER BY year;
```

If the result is:

```text
2019
```

then a 2022 vs 2023 comparison is not possible with this dataset.

---

# Q9 Alternative — Compare Revenue by Branch Within the Available Year

```sql
SELECT
    branch,
    ROUND(SUM(unit_price * quantity), 2) AS total_revenue
FROM walmart
GROUP BY branch
ORDER BY total_revenue DESC;
```

This identifies the branches with the highest revenue.

---

# Additional Useful Queries

## 10. Highest Revenue Branch

```sql
SELECT
    branch,
    ROUND(SUM(unit_price * quantity), 2) AS total_revenue
FROM walmart
GROUP BY branch
ORDER BY total_revenue DESC
LIMIT 1;
```

---

## 11. Highest Revenue Category

```sql
SELECT
    category,
    ROUND(SUM(unit_price * quantity), 2) AS total_revenue
FROM walmart
GROUP BY category
ORDER BY total_revenue DESC
LIMIT 1;
```

---

## 12. Most Sold Product Category

```sql
SELECT
    category,
    SUM(quantity) AS total_quantity_sold
FROM walmart
GROUP BY category
ORDER BY total_quantity_sold DESC
LIMIT 1;
```

---

## 13. Average Customer Rating by Branch

```sql
SELECT
    branch,
    ROUND(AVG(rating), 2) AS average_rating
FROM walmart
GROUP BY branch
ORDER BY average_rating DESC;
```

---

## 14. Total Revenue

```sql
SELECT
    ROUND(SUM(unit_price * quantity), 2) AS total_revenue
FROM walmart;
```

---

## 15. Total Profit

```sql
SELECT
    ROUND(
        SUM(unit_price * quantity * profit_margin),
        2
    ) AS total_profit
FROM walmart;
```

---

## 16. Revenue by City

```sql
SELECT
    city,
    ROUND(SUM(unit_price * quantity), 2) AS total_revenue
FROM walmart
GROUP BY city
ORDER BY total_revenue DESC;
```

---

## 17. Revenue by Payment Method

```sql
SELECT
    payment_method,
    ROUND(SUM(unit_price * quantity), 2) AS total_revenue
FROM walmart
GROUP BY payment_method
ORDER BY total_revenue DESC;
```

---

## 18. Profit by Branch

```sql
SELECT
    branch,
    ROUND(
        SUM(unit_price * quantity * profit_margin),
        2
    ) AS total_profit
FROM walmart
GROUP BY branch
ORDER BY total_profit DESC;
```

---

## 19. Monthly Revenue

```sql
SELECT
    MONTH(STR_TO_DATE(`date`, '%d/%m/%y')) AS month_number,
    MONTHNAME(STR_TO_DATE(`date`, '%d/%m/%y')) AS month_name,
    ROUND(SUM(unit_price * quantity), 2) AS total_revenue
FROM walmart
GROUP BY
    MONTH(STR_TO_DATE(`date`, '%d/%m/%y')),
    MONTHNAME(STR_TO_DATE(`date`, '%d/%m/%y'))
ORDER BY month_number;
```

---

## 20. Daily Revenue

```sql
SELECT
    STR_TO_DATE(`date`, '%d/%m/%y') AS transaction_date,
    ROUND(SUM(unit_price * quantity), 2) AS total_revenue
FROM walmart
GROUP BY STR_TO_DATE(`date`, '%d/%m/%y')
ORDER BY transaction_date;
```

---

# Data Validation Queries

## Check for NULL Values

```sql
SELECT
    SUM(invoice_id IS NULL) AS null_invoice_id,
    SUM(branch IS NULL) AS null_branch,
    SUM(city IS NULL) AS null_city,
    SUM(category IS NULL) AS null_category,
    SUM(unit_price IS NULL) AS null_unit_price,
    SUM(quantity IS NULL) AS null_quantity,
    SUM(`date` IS NULL) AS null_date,
    SUM(`time` IS NULL) AS null_time,
    SUM(payment_method IS NULL) AS null_payment_method,
    SUM(rating IS NULL) AS null_rating,
    SUM(profit_margin IS NULL) AS null_profit_margin
FROM walmart;
```

---

## Check Duplicate Invoice IDs

```sql
SELECT
    invoice_id,
    COUNT(*) AS duplicate_count
FROM walmart
GROUP BY invoice_id
HAVING COUNT(*) > 1;
```

---

## Check Negative or Zero Values

```sql
SELECT *
FROM walmart
WHERE unit_price <= 0
   OR quantity <= 0
   OR rating < 0
   OR profit_margin < 0;
```

---

# Important MySQL Notes

The following column names are enclosed in backticks:

```sql
`date`
`time`
```

This is done because `date` and `time` are MySQL data-type/function-related keywords and using backticks makes the queries safer and clearer.

---

# Final Analysis Workflow

The recommended order for running this project is:

```text
1. SELECT * FROM walmart;

2. Check row count

3. Check NULL values

4. Check duplicate invoice IDs

5. Check available years

6. Analyze payment methods

7. Analyze branches

8. Analyze categories

9. Analyze customer ratings

10. Analyze revenue

11. Analyze profit

12. Analyze sales by day

13. Analyze sales by shift

14. Analyze monthly revenue
```

## Project Outcome

The SQL analysis provides insights into:

* Payment-method usage
* Branch performance
* Category performance
* Customer ratings
* Quantity sold
* Revenue
* Profit
* Sales by city
* Sales by time of day
* Monthly sales trends


