CREATE TABLE sales(
    index_id INT,
    order_id TEXT,
    cust_id INT,
    gender TEXT,
    age INT,
    age_group TEXT,
    date DATE,
    month TEXT,
    status TEXT,
    channel TEXT,
    sku TEXT,
    category TEXT,
    size TEXT,
    qty INT,
    currency TEXT,
    amount NUMERIC,
    ship_city TEXT,
    ship_state TEXT,
    ship_postal_code TEXT,
    ship_country TEXT,
    b2b BOOLEAN
);
select * from sales;
select count(*) from sales;

/*
here used  ROW_NUMBER() with PARTITION BY to group rows having the same values.
Within each group, rows are numbered.
The first row is considered original, and rows with row_num > 1 are duplicates."
*/


WITH cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY index_id, order_id, cust_id, gender, age, age_group,
                            date, month, status, channel, sku, category,
                            size, qty, currency, amount, ship_city, ship_state,
                            ship_postal_code, ship_country, b2b
               ORDER BY index_id
           ) AS row_num
    FROM sales
)
SELECT *
FROM cte
WHERE row_num > 1;

-- 1. WHICH MONTH GOT THE HIGHEST SALES AND ORDERS?	

SELECT month,
sum(amount) as total_sales,
count(order_id) as total_orders
FROM sales
GROUP BY month
ORDER  BY total_sales desc, total_orders desc;

-- march month got the highest sales and orders.

-- 2.WHICH GENDER PURCHASED MORE IN 2022?
SELECT gender,
sum(amount) as total_amount,
round(
		(sum(amount)/
		(SELECT sum(amount) FROM sales) * 100), 2) as percentage_sales_ByGender
		FROM sales
		GROUP BY gender;
-- women has highest % of sales 64.05% whereas men 35.95%

-- 3  DIFFERENT ORDER STATUS IN 2022?	

SELECT 
    status,
    COUNT(order_id) AS total_orders,
    ROUND(
        (COUNT(order_id)::NUMERIC /
         (SELECT COUNT(order_id)::NUMERIC FROM sales)) * 100,
        2
    ) AS percentage_of_orderstatus
FROM sales
GROUP BY status
ORDER BY percentage_of_orderstatus DESC;	

-- Around 93% of orders are delivered which is positive sign for store.

-- 4. LIST TOP 10 STATES CONTRIBUTING TO THE SALES?	

SELECT 
    ship_state,
    SUM(amount) AS total_sales,
    ROUND(
        (SUM(amount)::NUMERIC /
         (SELECT SUM(amount)::NUMERIC FROM sales)) * 100,
        2
    ) AS states_per_sales
FROM sales
GROUP BY ship_state
ORDER BY total_sales DESC
LIMIT 10;

--  Round 50% sales comes from 5 states: Maharashtra, Karnataka, Uttar Pradesh, Telangana & Tamil Nadu


-- 5. RELATION BETWEEN AGE AND GENDER BASED ON NUMBER OF ORDERS.

	SELECT 
    age_group,
    gender,
    COUNT(order_id) AS total_orders,
    ROUND(
        (COUNT(order_id)::NUMERIC /
         (SELECT COUNT(order_id)::NUMERIC FROM sales)) * 100,
        2
    ) AS percentage_of_orderstatus
FROM sales
GROUP BY age_group , gender;

	
/*  Adult Women age between 30-50 contributed most in sales (~35%), followed by Young Women age between 18-29 by ~22%.
Top Buyer in term of Age_Group & Gender: Adult  Women, Young Women & Adult Men(~16%)			*/


-- 6. WHICH CHANNEL IS CONTIRBUTING TO MAXIMUM SALES?
  
	SELECT Channel,
			SUM(Amount) as total_Sales_Channel,
			Round((sum(Amount) /
						(SELECT sum(Amount) FROM sales) *100),2) as total_per_channel
	FROM sales
	GROUP BY Channel
	ORDER BY total_per_Channel DESC;
-- Around 80% sales comes from Amazon, Myntra & Flipkart.

-- 7. HIGHEST SELLING CATEGORY?	

		SELECT Category,
			sum(Amount) as total_Sales_Category,
			Round((sum(Amount) /
					(SELECT sum(Amount) FROM sales) *100),2) as total_per_Category,
			Count(Order_ID) as total_Order_Category
		FROM sales
		GROUP BY Category
		ORDER BY total_Sales_Category DESC;
--  50% sales comes from Set, followed by kurta ~24%.


-- 8. FILTERS THE TOP 2 RANKED CATEGORY FOR EACH CHANNEL AND SORTS THEM BY TOTAL SALES.
	With top_channel_category As(
	SELECT *,
		Rank() over(Partition By Channel Order by total_Sales DESC) as channel_rank
		FROM (
			SELECT Channel, Category,
					SUM(Amount) as total_Sales,
					Round((sum(Amount) /
						(SELECT sum(Amount) sales) *100),2) as total_per_Category
			FROM sales
			GROUP BY Channel, Category) as a
			
	--Order by Channel, total_sales DESC;
	)
	SELECT Channel, Category, total_sales
	FROM top_channel_category
	WHERE channel_rank <3;
	
-- Set and Kurta are top ranked category for each channel.

-- 9) REPEAT VS NEW CUSTOMERS
SELECT
    COUNT(*) FILTER (WHERE order_count > 1) AS repeat_customers, -- filter here works like an case 
    COUNT(*) FILTER (WHERE order_count = 1) AS one_time_customers
FROM (
    SELECT cust_id, COUNT(order_id) AS order_count
    FROM sales
    GROUP BY cust_id
) a;
--2093 repeat customers and 26344 are one time customers.

--10) AVERAGE ORDER VALUE (AOV) BY CHANNEL
SELECT channel,
       ROUND(SUM(amount) / COUNT(DISTINCT order_id), 2) AS avg_order_value
FROM sales
GROUP BY channel
ORDER BY avg_order_value DESC;

-- amazon AOV -> 708 and myntra contributing AOV -> 698 similarly flipkart do 697 AOV

-- 11. TOP 5 CITIES BY REVENUE
SELECT ship_city,
       SUM(amount) AS total_sales
FROM sales
GROUP BY ship_city
ORDER BY total_sales DESC
LIMIT 5;

-- BENGALURU, HYDERABAD, DELHI, MUMBAI, CHENNAI  are the top 5 cities

-- 12. SIZE PREFERENCE BY CATEGORY
SELECT category, size, COUNT(*) AS orders
FROM sales
GROUP BY category, size
ORDER BY category, orders DESC;

















































