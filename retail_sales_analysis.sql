use `retail_sales_analysis`;

SELECT *
FROM retail_sales_analysis.dsretail_sales_analysis;

-- first thing we want to do is create a rsa. This is the one we will work with. We want a table with the raw data in case something happens
CREATE TABLE retail_sales_analysis.rsa
LIKE retail_sales_analysis.dsretail_sales_analysis;

select *
from retail_sales_analysis.rsa;

INSERT retail_sales_analysis.rsa 
SELECT * FROM retail_sales_analysis.dsretail_sales_analysis;


SELECT * FROM retail_sales_analysis.rsa 
LIMIT 10;

SELECT 
    COUNT(*) 
FROM retail_sales_analysis.rsa;

SELECT COUNT(DISTINCT customer_id) 
FROM retail_sales_analysis.rsa;

SELECT DISTINCT category 
FROM retail_sales_analysis.rsa;

-- Data Cleaning

-- check for duplicates

SELECT *
FROM retail_sales_analysis.rsa;

SELECT sale_date, sale_time, customer_id ,gender, age, category, quantiy, price_per_unit, cogs,
		ROW_NUMBER() OVER (
			PARTITION BY sale_date, sale_time, customer_id ,gender, age, category, quantiy, price_per_unit, cogs) AS row_num
	FROM 
		retail_sales_analysis.rsa;



SELECT *
FROM (
	SELECT sale_date, sale_time, customer_id ,gender, age, category, quantiy, price_per_unit, cogs,
		ROW_NUMBER() OVER (
			PARTITION BY sale_date, sale_time, customer_id ,gender, age, category, quantiy, price_per_unit, cogs) AS row_num
	FROM 
		retail_sales_analysis.rsa
) duplicates
WHERE 
	row_num > 1;
    
-- no duplicates!

-- ckeck null values

SELECT * FROM retail_sales_analysis.rsa
WHERE transactions_id IS NULL;

SELECT * FROM retail_sales_analysis.rsa
WHERE sale_date IS NULL;

SELECT * FROM retail_sales_analysis.rsa
WHERE sale_time IS NULL;

SELECT * FROM retail_sales_analysis.rsa
WHERE 
    transactions_id IS NULL
    OR
    sale_date IS NULL
    OR 
    sale_time IS NULL
    OR
    gender IS NULL
    OR
    category IS NULL
    OR
    quantiy IS NULL
    OR
    cogs IS NULL
    OR
    total_sale IS NULL;
    
-- no null values!
    


    
-- Data Exploration

-- How many sales we have?

SELECT COUNT(*) as total_sale 
FROM retail_sales_analysis.rsa;

-- How many uniuque customers we have ?

SELECT COUNT(DISTINCT customer_id) as total_sale 
FROM retail_sales_analysis.rsa;



SELECT DISTINCT category 
FROM retail_sales_analysis.rsa;


-- Data Analysis & Business Key Problems & Answers

-- My Analysis & Findings
-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 10 in the month of Nov-2022
-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)



 -- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05

SELECT *
FROM retail_sales_analysis.rsa
WHERE sale_date = '2022-11-05';


-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022


SELECT 
  *
FROM retail_sales_analysis.rsa
WHERE 
    category = 'Clothing'
    AND 
    year(sale_date)= '2022'
    AND
    month(sale_date)= '11'
    AND
    quantiy >= 4;


-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.

SELECT 
    category,
    COUNT(*) as total_orders,
    SUM(total_sale) as total_sales
FROM retail_sales_analysis.rsa
GROUP BY 1;

-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.

SELECT
    ROUND(AVG(age), 2) as avg_age
FROM retail_sales_analysis.rsa
WHERE category = 'Beauty';


-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.

SELECT * FROM retail_sales_analysis.rsa
WHERE total_sale > 1000;


-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.

WITH monthly_sales AS (
    SELECT 
        EXTRACT(YEAR FROM sale_date) AS year,
        EXTRACT(MONTH FROM sale_date) AS month,
        AVG(total_sale) AS avg_monthly_sale
    FROM retail_sales_analysis.rsa
    GROUP BY EXTRACT(YEAR FROM sale_date), EXTRACT(MONTH FROM sale_date)
),
ranked_sales AS (
    SELECT 
        year,
        month,
        avg_monthly_sale,
        RANK() OVER (PARTITION BY year ORDER BY avg_monthly_sale DESC) AS ran_k
    FROM monthly_sales
)
SELECT 
    year,
    month,
    avg_monthly_sale
FROM ranked_sales
WHERE ran_k = 1;

-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 

SELECT 
    customer_id,
    SUM(total_sale) AS total_sales
FROM retail_sales_analysis.rsa
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;

-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.


SELECT 
    category,     
    COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales_analysis.rsa
GROUP BY category
ORDER BY unique_customers DESC;



-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)

WITH hourly_sale AS
(
SELECT *,
    CASE
        WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END as shift
FROM retail_sales_analysis.rsa
)
SELECT 
    shift,
    COUNT(*) as total_orders    
FROM hourly_sale
GROUP BY shift
order by 
    CASE shift
        WHEN 'Morning' THEN 1
        WHEN 'Afternoon' THEN 2
        WHEN 'Evening' THEN 3
    END;
;
