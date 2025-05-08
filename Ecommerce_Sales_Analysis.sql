
-- Creating Database:-
CREATE DATABASE Ecommerce_Data;
USE Ecommerce_Data;

-- Creating Table:--
CREATE TABLE Sales_Dataset (
	order_id VARCHAR(15) NOT NULL, 
	order_date DATE NOT NULL, 
	ship_date DATE NOT NULL, 
	ship_mode VARCHAR(14) NOT NULL, 
	customer_name VARCHAR(22) NOT NULL, 
	segment VARCHAR(11) NOT NULL, 
	state VARCHAR(36) NOT NULL, 
	country VARCHAR(32) NOT NULL, 
	market VARCHAR(6) NOT NULL, 
	region VARCHAR(14) NOT NULL, 
	product_id VARCHAR(16) NOT NULL, 
	category VARCHAR(15) NOT NULL, 
	sub_category VARCHAR(11) NOT NULL, 
	product_name VARCHAR(127) NOT NULL, 
	sales DECIMAL(38, 0) NOT NULL, 
	quantity DECIMAL(38, 0) NOT NULL, 
	discount DECIMAL(38, 3) NOT NULL, 
	profit DECIMAL(38, 5) NOT NULL, 
	shipping_cost DECIMAL(38, 2) NOT NULL, 
	order_priority VARCHAR(8) NOT NULL, 
	year DECIMAL(38, 0) NOT NULL
);

-- Load the data from local.
LOAD DATA INFILE "C:\Users\PRITAM DAS\Desktop\dd.csv"
INTO TABLE Sales_Dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM Sales_Dataset;





-- #Project Questions:-

-- we have to disable only_full_group_by to run this querry because SELECT list is not in GROUP BY clause
-- and contains nonaggregated column 'order_date' which is not functionally dependent on columns 
-- in GROUP BY clause;


-- Disable Code
    SET SESSION sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));


-- Q1. What is the sales over the time?

SELECT 
    YEAR(order_date) AS year,
    DATE_FORMAT(order_date, '%b') AS month_name,
    SUM(sales) AS total_sales
FROM 
    sales_dataset
GROUP BY 
    YEAR(order_date),
    MONTH(order_date)
ORDER BY 
    YEAR(order_date),
    MONTH(order_date);

-- Emable Code
    SET SESSION sql_mode = CONCAT(@@SESSION.sql_mode, ',ONLY_FULL_GROUP_BY');


-- 2.Which are the top 5 states with the highest shipping costs?

SELECT sum(shipping_cost) as total_cost,state
FROM sales_dataset
GROUP BY state
ORDER BY total_cost DESC
LIMIT 5;

-- Q3. Which products or categories are bestsellers and how have their sales


 SELECT category, product_name,SUM(sales*quantity) AS total_sale_amount,
 YEAR(order_date) AS order_year
 FROM sales_dataset
 GROUP BY category,product_name,order_year
 ORDER BY total_sale_amount DESC;


-- Q4. which customer groups spend the most money with us?

SELECT segment,sum(sales) AS total_sale_amount,
   COUNT(DISTINCT customer_name) AS customer_count
FROM sales_dataset
GROUP BY segment
ORDER BY total_sale_amount DESC;


-- Q5. How do discounts affect our sales and profits?

 SELECT discount, SUM(sales) As total_sales,
	ROUND(SUM(profit),2) AS total_profit_$
 FROM Sales_Dataset
 GROUP BY discount
 ORDER BY discount;

-- Q6. What are the shippping costs for different delivery methods and 
-- how do they affect our profits?

  SELECT sum(shipping_cost)  AS total_shiping_cost,
    ship_mode,sum(profit) AS total_profit
  FROM sales_dataset
 GROUP BY ship_mode ;


-- 7)  Which orders can be classified as high, medium, low margin or loss-making based on 
--     their profit-to-sales ratio?

 SELECT 
    order_id,
    sales,
    profit,
    ROUND(profit / sales, 2) AS profit_margin,
    CASE 
        WHEN profit / sales > 0.5 THEN 'High Margin'
        WHEN profit / sales BETWEEN 0.2 AND 0.5 THEN 'Medium Margin'
        WHEN profit / sales BETWEEN 0 AND 0.2 THEN 'Low Margin'
        ELSE 'Loss'
    END AS margin_category
FROM sales_dataset;

-- Q8. What is each region's contribution to the company's overall sales, in percentage terms?


SELECT 
    region,
    SUM(sales) AS region_sales,
    ROUND((SUM(sales) / (SELECT SUM(sales) FROM sales_dataset)) * 100, 2) AS percentage_contribution
FROM sales_dataset
GROUP BY region
ORDER BY region_sales DESC;



-- Q9. what are the top 3 most profitable state  overall, and
-- how does their monthly profit trend vary throughout the year?


 WITH TopStates AS (
    SELECT state
    FROM sales_dataset
    GROUP BY state
    ORDER BY SUM(profit) DESC
    LIMIT 3
 )
 SELECT s.state,
    MONTH(order_date) AS month,
   round(SUM(profit),2) AS monthly_profit
 FROM sales_dataset s
 JOIN TopStates t ON s.state = t.state
 GROUP BY s.state, MONTH(order_date)
ORDER BY s.state, month;

-- Q10. Which regions are generating the most sales and profits for us?

  select region,sum(sales) as total_sale,
   round(sum(profit),2) as total_profit
   from sales_dataset
   group by region
   order by total_profit desc;

-- Q11. Among high-priority orders, which ones incurred the highest shipping costs?

   select order_id,shipping_cost,order_priority
    from sales_dataset
    where order_priority = 'High'
	order by shipping_cost desc 
	limit 10;

-- Q12. What are our monthly sales trends?

SELECT date_format(order_date,'%Y-%m-01') as month,
     SUM(sales) as total_sale
FROM sales_dataset
GROUP BY month
ORDER BY month;

 -- Q13. What is each region's contribution to the company's overall sales, in percentage terms?

SELECT 
    region,
    SUM(sales) AS region_sales,
    ROUND((SUM(sales) / (SELECT SUM(sales) FROM sales_dataset)) * 100, 2) AS percentage_contribution
FROM sales_dataset
GROUP BY region
ORDER BY region_sales DESC;

 -- Q14. What is each region's contribution to the company's overall sales, in percentage terms?

SELECT order_priority, round(AVG(DATEDIFF(ship_date, order_date)),2)
   as avg_delivery_time_days
FROM Sales_Dataset
  GROUP by order_priority;

-- Q15.How much money will we likely make from each customer over their lifetime?


  SELECT customer_name, SUM(sales) AS total_sales, 
    COUNT(order_id) as total_orders,
   AVG(sales) as average_order_value
  FROM Sales_Dataset
  GROUP by customer_name
order by AVG(sales) desc;


-- Q16.Are there any signs that some customers might stop buying from us?


SELECT customer_name, 
  COUNT(order_id) as order_count,
  SUM(sales) as total_sales
FROM Sales_Dataset
WHERE order_date < DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR)
GROUP BY customer_name
HAVING SUM(sales) < 50;


-- Q17. which products are frequently bought together?

SELECT product_name,product_id, 
       COUNT(order_id) AS purchase_count
FROM Sales_Dataset
GROUP BY product_id, product_name
HAVING COUNT(order_id) > 1;


-------------------------------------------------------------------------------------------------------




