
	-- Pizza Sales Queries --

	-- (1) Calculating the KPI Requirements -- 

SELECT *
FROM PizzaSales..pizza_sales

-- Total Revenue 

SELECT SUM(total_price) AS Total_Revenue
FROM PizzaSales..pizza_sales


-- Average Order Value

SELECT (SUM(total_price) / COUNT(DISTINCT order_id)) AS Avg_Order_Value
FROM PizzaSales..pizza_sales


-- Total Pizza's Sold

SELECT SUM(quantity) AS Total_Pizza_Sold
FROM PizzaSales..pizza_sales


-- Total Orders Received

SELECT COUNT(DISTINCT order_id) AS Total_Orders_Received
FROM PizzaSales..pizza_sales


-- Average Pizza's Per Order

SELECT CAST(
			(CAST(SUM(quantity) AS DECIMAL(10,2)))
			/ (CAST(COUNT(DISTINCT order_id) AS DECIMAL(10,2)))
			AS DECIMAL(10,2)) AS Avg_Pizzas_Per_Order
FROM PizzaSales..pizza_sales



	-- (2) Calculating the Charts Requirements -- 

-- Daily Trend for Total Orders

SELECT DATENAME(DW, order_date) AS Order_Day
		, COUNT(DISTINCT order_id) AS Total_Orders
FROM PizzaSales..pizza_sales
GROUP BY DATENAME(DW, order_date)


-- Hourly Trend for Total Orders (in AM) 

SELECT DATEPART(HOUR, order_time) AS Order_hours
		, COUNT(DISTINCT order_id) AS Total_Orders
FROM PizzaSales..pizza_sales
GROUP BY DATEPART(HOUR, order_time)
ORDER BY DATEPART(HOUR, order_time)

-- Percentage of Sales by Pizza Category

SELECT pizza_category, 	((SUM(total_price) * 100)
		/ ( SELECT SUM(total_price) 
			FROM PizzaSales..pizza_sales)) AS Total_Sales
FROM PizzaSales..pizza_sales
GROUP BY pizza_category

-- Percentage of Sales by Pizza Size
	-- PCT = "Percentage of total sales for each pizza size"

SELECT
    CASE
        WHEN pizza_size IS NULL THEN 'Total'
        ELSE pizza_size
    END AS pizza_size
    , CAST(SUM(total_price) AS DECIMAL(10,2)) AS Total_Sales
    , CONCAT(
        ROUND(((SUM(total_price) * 100) / (SELECT SUM(total_price) FROM PizzaSales..pizza_sales)), 2), 
        '% '
    ) AS PCT
FROM PizzaSales..pizza_sales
GROUP BY pizza_size
ORDER BY pizza_size;


-- Total Pizza's sold by Pizza Category

SELECT pizza_category, SUM(quantity) AS Total_Pizzas_Sold
FROM PizzaSales..pizza_sales
GROUP BY pizza_category
ORDER BY Total_Pizzas_Sold DESC;


-- Top 5 Best Sellers by Total Pizza's Sold

SELECT TOP 5 pizza_name, SUM(quantity) AS Total_Pizzas_Sold
FROM PizzaSales..pizza_sales
GROUP BY pizza_name
ORDER BY Total_Pizzas_Sold DESC;


-- Bottom 5 Worst Sellers by Total Pizza's Sold

SELECT TOP 5 pizza_name, SUM(quantity) AS Total_Pizzas_Sold
FROM PizzaSales..pizza_sales
GROUP BY pizza_name
ORDER BY Total_Pizzas_Sold ASC;