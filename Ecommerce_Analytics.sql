CREATE DATABASE IF NOT EXISTS ecommerce_analytics;
USE ecommerce_analytics;

CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    gender ENUM('Male','Female','Other'),
    signup_date DATE,
    country VARCHAR(50),
    city VARCHAR(50)
);

CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    cost DECIMAL(10,2)
);

CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATETIME,
    order_status ENUM('Completed','Cancelled','Returned'),
    payment_method ENUM('Credit Card','Debit Card','UPI','Cash'),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    price_at_purchase DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    payment_date DATETIME,
    amount DECIMAL(10,2),
    payment_status ENUM('Success','Failed'),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE returns (
    return_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    return_date DATE,
    reason VARCHAR(100),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

select*from customers;
select*from products;
select*from orders;
select*from order_items;
select*from payments;
select*from returns;

-- Insert Customers
INSERT INTO customers (full_name, email, gender, signup_date, country, city)
SELECT
    CONCAT('Customer_', n),
    CONCAT('customer', n, '@mail.com'),
    ELT(1 + MOD(n,3), 'Male','Female','Other'),
    DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND()*900) DAY),
    'India',
    ELT(1 + MOD(n,5), 'Delhi','Mumbai','Bangalore','Pune','Chennai')
FROM (
    SELECT @row := @row + 1 AS n
    FROM information_schema.tables t1,
         information_schema.tables t2,
         (SELECT @row := 0) r
    LIMIT 1000
) x;

-- Insert Products
INSERT INTO products (product_name, category, price, cost)
VALUES
('iPhone 15','Electronics',1200,900),
('Laptop','Electronics',800,600),
('Headphones','Accessories',150,90),
('Shoes','Fashion',120,70),
('Backpack','Fashion',90,50);

-- Insert Orders
INSERT INTO orders (customer_id, order_date, order_status, payment_method)
SELECT
    FLOOR(1 + RAND()*1000),
    DATE_SUB(NOW(), INTERVAL FLOOR(RAND()*365) DAY),
    ELT(1 + MOD(n,3),'Completed','Cancelled','Returned'),
    ELT(1 + MOD(n,4),'Credit Card','Debit Card','UPI','Cash')
FROM (
    SELECT @o := @o + 1 AS n
    FROM information_schema.tables, (SELECT @o := 0) r
    LIMIT 3000
) x;

-- Insert Order Items
INSERT INTO order_items (order_id, product_id, quantity, price_at_purchase)
SELECT
    FLOOR(1 + RAND() * (SELECT MAX(order_id) FROM orders))      AS order_id,
    FLOOR(1 + RAND() * (SELECT MAX(product_id) FROM products)) AS product_id,
    FLOOR(1 + RAND() * 3) + 1                                  AS quantity,
    ROUND(100 + RAND() * 1000, 2)                              AS price_at_purchase
FROM information_schema.tables t1
JOIN information_schema.tables t2
LIMIT 5000;

-- Insert Payments
INSERT INTO payments (order_id, payment_date, amount, payment_status)
SELECT
    order_id,
    order_date,
    ROUND(200 + RAND()*2000,2),
    'Success'
FROM orders
WHERE order_status = 'Completed';


#1 Retrieve all customers’ names and emails
select full_name, email from customers;

#2 List customers from India
select*from customers where country = "India"; 

#3 Count the number of female customers
select count(*)from customers where gender="Female";

#4 Find customers who signed up in the last 6 months
select*from customers where signup_date>=subdate(curdate(), interval 6 month);

#5 List customers from Mumbai
select*from customers where city="Mumbai";

#6 Get the 10 most recently signed-up customers
SELECT * FROM customers 
ORDER BY signup_date DESC 
LIMIT 10;

#7 Find the most expensive product
SELECT * FROM products 
ORDER BY price DESC 
LIMIT 1;

#8 Retrieve the 3 cheapest products
SELECT * FROM products 
ORDER BY price ASC 
LIMIT 3;

#9 Find the 5 earliest customers
SELECT * FROM customers 
ORDER BY signup_date ASC 
LIMIT 5;

#10 Total number of customers
SELECT COUNT(customer_id) FROM customers;

#11 Total number of orders
SELECT COUNT(order_id) FROM orders;

#12 Count of completed orders
SELECT COUNT(*) FROM orders 
WHERE order_status = 'Completed';

#133 Average product price
SELECT AVG(price) FROM products;

#14 Maximum and minimum product price
SELECT MAX(price), MIN(price) FROM products;

#15 Show each order with customer name
SELECT o.order_id, c.full_name 
FROM orders o 
JOIN customers c ON o.customer_id = c.customer_id;

#16 List order items with product details
SELECT oi.*, p.product_name, p.category 
FROM order_items oi 
JOIN products p ON oi.product_id = p.product_id;

#17 Show which customer bought which product
SELECT c.full_name, p.product_name 
FROM customers c 
JOIN orders o ON c.customer_id = o.customer_id 
JOIN order_items oi ON o.order_id = oi.order_id 
JOIN products p ON oi.product_id = p.product_id;

#18 Retrieve payment details for completed orders
SELECT py.* FROM payments py 
JOIN orders o ON py.order_id = o.order_id 
WHERE o.order_status = 'Completed';

#19 List returned orders with reasons
SELECT order_id, reason 
FROM returns;

#20 Customer → Order → Order Items → Product full join
SELECT 
    c.full_name, 
    o.order_id, 
    o.order_date, 
    oi.quantity, 
    p.product_name, 
    p.price
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id;

#21 Total spend per customer
SELECT c.full_name, SUM(p.amount) AS total_spend 
FROM customers c 
JOIN orders o ON c.customer_id = o.customer_id 
JOIN payments p ON o.order_id = p.order_id 
GROUP BY c.full_name;

#22 Total quantity sold per product
SELECT p.product_name, SUM(oi.quantity) AS total_sold 
FROM products p 
JOIN order_items oi ON p.product_id = oi.product_id 
GROUP BY p.product_name;

#23 Total revenue by city
SELECT c.city, SUM(p.amount) AS total_revenue 
FROM customers c 
JOIN orders o ON c.customer_id = o.customer_id 
JOIN payments p ON o.order_id = p.order_id 
GROUP BY c.city;

#24 Revenue by product category
SELECT p.category, SUM(oi.quantity * oi.price_at_purchase) AS total_revenue 
FROM products p 
JOIN order_items oi ON p.product_id = oi.product_id 
GROUP BY p.category;


