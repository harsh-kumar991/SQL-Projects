CREATE DATABASE IF NOT EXISTS pizza_sales;
USE pizza_sales;
CREATE TABLE orders(
order_id int not null primary key,
date date not null,
time time not null
);

CREATE TABLE order_details(
order_details_id int not null primary key,
order_id int not null,
pizza_id text not null,
quantity int not null
);

SELECT * FROM pizza_sales.pizzas;
SELECT * FROM pizza_sales.pizza_types;
SELECT * FROM pizza_sales.orders;
SELECT * FROM pizza_sales.order_details;

-- BASIC QUERIES
-- Q1. Retrieve the total number of orders placed. 
SELECT count(order_id) As total_orders 
FROM pizza_sales.orders;

-- Q2. Calculate the total revenue generated from pizza sales. 
SELECT round(sum(od.quantity*p.price),2) As total_revenue
FROM pizza_sales.pizzas As p
JOIN pizza_sales.order_details As od
ON p.pizza_id=od.pizza_id;

-- Q3. Identify the highest-priced pizza. 
SELECT pt.name, p.price
FROM pizza_types As pt
JOIN pizzas As p
ON pt.pizza_type_id=p.pizza_type_id
order by price desc
limit 1;

-- Q4. Identify the most common pizza size ordered. (by me)
SELECT p.size, count(p.size) As common_pizza_size
FROM pizza_types As pt
JOIN pizzas As p
ON pt.pizza_type_id=p.pizza_type_id
JOIN order_details As od
ON p.pizza_id=od.pizza_id
JOIN orders As o
ON od.order_id=o.order_id
group by size
order by common_pizza_size desc;

-- OR

SELECT p.size, count(od.order_details_id) As order_count
FROM pizzas As p
JOIN order_details As od
ON p.pizza_id=od.pizza_id
group by size
order by order_count desc;
 
-- Q5. List the top 5 most ordered pizza types along with their quantities. 
SELECT pt.name, sum(od.quantity) As quantity
FROM pizza_types As pt
JOIN pizzas As p
ON pt.pizza_type_id=p.pizza_type_id
JOIN order_details As od
ON p.pizza_id=od.pizza_id
GROUP BY pt.name
ORDER BY quantity desc
LIMIT 5;
 
-- INTERMEDIATE QUERIES
-- Q6. Join the necessary tables to find the total quantity of each pizza category ordered. 
SELECT PT.CATEGORY, SUM(QUANTITY) AS QUANTITY
FROM PIZZA_TYPES AS PT
JOIN PIZZAS AS P
ON PT.pizza_type_id=P.pizza_type_id
JOIN ORDER_DETAILS AS OD
ON P.pizza_id=OD.pizza_id
GROUP BY CATEGORY
ORDER BY QUANTITY DESC;

-- Q7. Determine the distribution of orders by hour of the day. 
SELECT HOUR(TIME) AS HOUR, COUNT(ORDER_ID) AS ORDER_COUNT
FROM ORDERS
GROUP BY HOUR(TIME)
ORDER BY ORDER_COUNT DESC;

-- Q8. Join relevant tables to find the category-wise distribution of pizzas. 
SELECT CATEGORY, COUNT(NAME) AS TYPE_OF_PIZZAS
FROM pizza_types
GROUP BY CATEGORY;

-- Q9. Group the orders by date and calculate the average number of pizzas ordered per day. 
SELECT ROUND(AVG(QUANTITY),1) AS AVERAGE_NO_OF_PIZZAS_ORDERED_PER_DAY
FROM
(SELECT O.DATE, SUM(OD.QUANTITY) AS QUANTITY
FROM ORDERS AS O
JOIN ORDER_DETAILS AS OD
ON O.ORDER_ID=OD.ORDER_ID
GROUP BY DATE) AS ORDER_QUANTITY;

-- Q10. Determine the top 3 most ordered pizza types based on revenue. 
SELECT PT.NAME, SUM(P.PRICE*OD.QUANTITY) AS TOTAL_REVENUE
FROM PIZZA_TYPES AS PT
JOIN PIZZAS AS P
ON PT.pizza_type_id=P.pizza_type_id
JOIN order_details AS OD
ON P.PIZZA_ID=OD.PIZZA_ID
GROUP BY NAME
ORDER BY TOTAL_REVENUE DESC
LIMIT 3;

-- ADVANCED QUERIES
-- Q11. Calculate the percentage contribution of each pizza type to total revenue. 
SELECT PT.CATEGORY, ROUND(SUM(P.PRICE*OD.QUANTITY)/(SELECT ROUND(SUM(OD.QUANTITY*P.PRICE),2) AS TOTAL_SALES
FROM ORDER_DETAILS AS OD
 JOIN PIZZAS AS P
 ON P.PIZZA_ID=OD.PIZZA_ID)*100,2) AS REVENUE
FROM PIZZA_TYPES AS PT
JOIN PIZZAS AS P
ON PT.pizza_type_id=P.pizza_type_id
JOIN order_details AS OD
ON P.PIZZA_ID=OD.PIZZA_ID
GROUP BY CATEGORY
ORDER BY REVENUE DESC;

-- Q12. Analize the cumulative revenue generated over time. 
SELECT DATE, SUM(SALES_PER_DAY) OVER(ORDER BY DATE) AS CUM_REVENUE
FROM
(SELECT O.DATE, ROUND(SUM(OD.QUANTITY*P.PRICE),2) AS SALES_PER_DAY
FROM ORDERS AS O
JOIN ORDER_DETAILS AS OD
ON O.ORDER_ID=OD.ORDER_ID
JOIN PIZZAS AS P
ON OD.PIZZA_ID=P.PIZZA_ID
GROUP BY DATE
ORDER BY DATE ASC) AS SALES;

-- Q13. Determine the top 3 most ordered pizza types based on revenue for each pizza category. 
WITH CTE AS(
 SELECT PT.CATEGORY, PT.NAME, SUM(OD.QUANTITY*P.PRICE) AS REVENUE,
 RANK() OVER(PARTITION BY CATEGORY ORDER BY SUM(OD.QUANTITY*P.PRICE) DESC) AS RNK
 FROM PIZZA_TYPES AS PT
 JOIN PIZZAS AS P
 ON PT.PIZZA_TYPE_ID=P.PIZZA_TYPE_ID
 JOIN ORDER_DETAILS AS OD
 ON P.PIZZA_ID=OD.PIZZA_ID
 GROUP BY CATEGORY, NAME
)
SELECT * FROM CTE
WHERE RNK<=3;
