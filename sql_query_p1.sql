-- DATA CLEANING: Remove null or incomplete records
SELECT *
FROM retail_sales
WHERE transactions_id IS NULL
   OR sale_date IS NULL
   OR sale_time IS NULL
   OR customer_id IS NULL
   OR gender IS NULL
   OR category IS NULL
   OR quantiy IS NULL
   OR cogs IS NULL
   OR total_sale IS NULL;

DELETE FROM retail_sales
WHERE transactions_id IS NULL
   OR sale_date IS NULL
   OR sale_time IS NULL
   OR customer_id IS NULL
   OR gender IS NULL
   OR category IS NULL
   OR quantiy IS NULL
   OR cogs IS NULL
   OR total_sale IS NULL;

-- BASIC CHECKS
-- How many total sales we have?
SELECT COUNT(*) AS total_sales
FROM retail_sales;

-- How many unique customers we have?
SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM retail_sales;

-- What are the available categories?
SELECT DISTINCT category
FROM retail_sales;

-- ----------------------------------------------------------------------
-- DATA ANALYSIS & BUSINESS QUESTIONS
/* Q1. Write a SQL query to retrieve all columns for sales made on '2022-11-05'.

Q2. Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 10 in the month of Nov-2022.

Q3. Write a SQL query to calculate the total sales (total_sale) for each category.

Q4. Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.

Q5. Write a SQL query to find all transactions where the total_sale is greater than 1000.

Q6. Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.

Q7. Write a SQL query to calculate the average sale for each month. Find out the best-selling month in each year.

Q8. Write a SQL query to find the top 5 customers based on the highest total_sales.

Q9. Write a SQL query to find the number of unique customers who purchased items from each category.

Q10. Write a SQL query to create each shift and number of orders.
(Example: Morning <= 12, Afternoon Between 12 & 17, Evening > 17) */

-- ----------------------------------------------------------------------

-- Q1. Retrieve all columns for sales made on '2022-11-05'
SELECT
    *
FROM retail_sales
WHERE sale_date = '2022-11-05';

-- Q2. Retrieve all transactions where the category is 'Clothing'
--     and quantity sold is more than 4 in the month of Nov-2022
SELECT
    *
FROM retail_sales
WHERE category = 'Clothing'
  AND TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
  AND quantiy >= 4;

-- Q3. Calculate the total sales (total_sale) for each category
SELECT
    category,
    SUM(total_sale) AS net_sale,
    COUNT(*) AS total_orders
FROM retail_sales
GROUP BY category;

-- Q4. Find the average age of customers who purchased items
--     from the 'Beauty' category
SELECT
    ROUND(AVG(age), 2) AS avg_age
FROM retail_sales
WHERE category = 'Beauty';

-- Q5. Find all transactions where total_sale is greater than 1000
SELECT
    *
FROM retail_sales
WHERE total_sale > 1000;

-- Q6. Find the total number of transactions (transaction_id)
--     made by each gender in each category
SELECT
    category,
    gender,
    COUNT(*) AS total_transactions
FROM retail_sales
GROUP BY category, gender
ORDER BY category;

-- Q7. Calculate the average sale for each month and find out
--     the best-selling month in each year
SELECT
    year,
    month,
    avg_sale
FROM (
    SELECT
        EXTRACT(YEAR FROM sale_date) AS year,
        EXTRACT(MONTH FROM sale_date) AS month,
        AVG(total_sale) AS avg_sale,
        RANK() OVER (
            PARTITION BY EXTRACT(YEAR FROM sale_date)
            ORDER BY AVG(total_sale) DESC
        ) AS rank
    FROM retail_sales
    GROUP BY 1, 2
) AS ranked_sales
WHERE rank = 1;

-- Q8. Find the top 5 customers based on the highest total sales
SELECT
    customer_id,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;

-- Q9. Find the number of unique customers who purchased
--     items from each category
SELECT
    category,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales
GROUP BY category;

-- Q10. Create each shift and find the number of orders in each
--      (Morning <= 12, Afternoon between 12 & 17, Evening > 17)
WITH hourly_sale AS (
    SELECT
        *,
        CASE
            WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
            WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
            ELSE 'Evening'
        END AS shift
    FROM retail_sales
)
SELECT
    shift,
    COUNT(*) AS total_orders
FROM hourly_sale
GROUP BY shift;

-- END OF PROJECT
