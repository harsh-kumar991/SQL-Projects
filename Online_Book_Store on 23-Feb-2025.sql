Create database if not exists Online_Book_Store;
Use Online_Book_Store;

Create Table Orders(
Order_ID int primary key,
Customer_ID int not null,
Book_ID int not null,
Order_Date Date not null,
Quantity int not null,
Total_Amount double not null
);
					
Create Table customers(
Customer_ID int not null,
Name varchar(20) not null,
Email varchar(25) not null,
Phone int not null,
City varchar(15) not null,
Country varchar(15) not null
);
						
Create Table Books(
Book_ID int not null,
Title varchar(50) not null,
Author varchar(50) not null,
Genre varchar(15) not null,
Published_Year Year not null,
Price double not null,
Stock int not null
);

Select * from books;
Select * from customers;
Select * from orders;

# Basic Queries
-- 1) Retrieve all books in the "Fiction" genre
Select * 
from books
where genre="Fiction";

-- 2) Find books published after the year 1950
Select *
from books
where Published_Year > 1950;

-- 3) List all customers from the Canada
Select *
from customers
where country = "Canada";

-- 4) Show orders placed in November 2023
Select * 
from orders
where Year(Order_Date)=2023 and Month(Order_Date)=11;

-- 5) Retrieve the total stock of books available
Select sum(Stock) as Total_Stock_of_Books
from books;

-- 6) Find the details of the most expensive book
Select * 
from books
order by Price Desc
limit 1;

-- 7) Show all customers who ordered more than 1 quantity of a book
Select C.Name, O.Quantity
from Customers as C
join Orders as O
on C.Customer_id = O.customer_ID
where quantity >1;

-- 8) Retrieve all orders where the total amount exceeds $20
Select *
from Books as B
join Orders as O
on B.Book_ID = O.Book_ID
where Total_Amount > 20;

-- 9) List all genres available in the Books table
Select distinct(Genre) 
from Books;

-- 10) Find the book with the lowest stock
Select  * 
from Books
order by stock asc
limit 1;

-- 11) Calculate the total revenue generated from all orders
Select round(sum(total_amount), 2) as Total_Revenue
from orders;

# Advance Queries
-- 1) Retrieve the total number of books sold for each genre
Select b.Genre, Count(o.Book_id) as No_of_Books_Sold
from books as b
join orders as o
on b.book_id = o.book_id
group by b.genre;

-- 2) Find the average price of books in the "Fantasy" genre
Select Genre, Round(Avg(Price), 2) as Average_Price
from books
where Genre = "Fantasy";

-- 3) List customers who have placed at least 2 orders
Select o.Customer_id, c.Name, count(o.order_id) as order_count 
from Customers as C
join Orders as O
on C.Customer_id = O.customer_ID;


-- 4) Find the most frequently ordered book


-- 5) Show the top 3 most expensive books of 'Fantasy' Genre
Select *
from books
where genre = "Fantasy"
order by price desc
limit 3;

-- 6) Retrieve the total quantity of books sold by each author
Select b.author, sum(o.quantity) as Total_Quantity_Sold
from books as b
join orders as o
on b.book_id = o.book_id
group by Author;

-- 7) List the cities where customers who spent over $30 are located
Select distinct(c.city) as City, c.name, o.total_amount
from Customers as C
join Orders as O
on C.Customer_id = O.customer_ID
where o.total_amount > 30;
 
-- 8) Find the customer who spent the most on orders
Select c.Name, o.total_amount
from Customers as C
join Orders as O
on C.Customer_id = O.customer_ID
order by o.total_amount desc
limit 1;

-- 9) Calculate the stock remaining after fulfilling all orders

