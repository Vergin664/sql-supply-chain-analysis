
create database supply_chain;
use supply_chain;


select * from customer ;
select * from orderitem;
select * from orders;
select * from product;
select * from supplier;


# BASIC SELECT + FILTERING + SORTING

-- 1.List all customers from USA sorted by their City.
select * from customer where Country ='USA' order by City;

-- 2.Retrieve the details of all orders placed in 2014-01-05.
select * from orders where date_format(orderdate,'%Y-%m-%d') = '2014-01-05';

-- 3.Show the top 10 most recent orders with customer names and total amount.
select concat(firstname,' ',lastname) as customer_name,
totalamount, orderdate 
from customer c join orders o
on c.id=o.customerid
order by orderdate desc
limit 10;

-- 4.Find all discontinued products.
select * from product where IsDiscontinued is not null and IsDiscontinued > 0;


# AGGREGATIONS + GROUP BY

-- 5.Calculate the total sales (sum of TotalAmount) for each country.
select country,
sum(totalamount) as total_amount 
from customer c join orders o 
on c.id=o.CustomerId
group by 1;


-- 6.Show total number of orders placed by each customer.
select concat(firstname,' ',lastname) as customer_name,
count(customerid) as total_orders
from customer c join orders o
on c.id=o.CustomerId  
group by 1
order by 2 ;


-- 7.Find the top 5 customers based on the total purchase amount.
select concat(firstname,' ',lastname) as customer_name, 
sum(totalamount) as total_purchase_amount 
from customer c join orders o 
on c.id=o.customerid
group by 1 
order by 2 desc 
limit 5;

-- 8.Display monthly total sales from the orders table.
select date_format(orderdate,'%Y-%m') as month,
sum(totalamount) as total_amount 
from orders 
group by 1 ;



# JOINs (INNER, LEFT, RIGHT)

-- 9.List order details with product names and customer names.
select o.id, 
        concat(c.firstname,' ',c.lastname) as customer_name, 
		p.productname, 
		o.orderdate,
		o.ordernumber, 
        o.customerid,
		o.totalamount
from customer c join orders o 
on c.id=o.customerid 
join orderitem oi 
on o.id = oi.OrderId 
join product p 
on oi.ProductId = p.id;

-- 10.Show all products and their supplier names, even if some suppliers didn’t supply anything (LEFT JOIN)
 select productname, 
        s.companyname,
        s.contactname 
from product p left join supplier s 
on p.SupplierId = s.Id;


-- 11.List customers who placed orders
select distinct concat(c.firstname,' ',c.lastname) as customer_name
from customer c inner join orders o 
on c.id=o.customerid;


-- 12.List all customers, they haven’t placed any orders
select  concat(c.firstname,' ',c.lastname) as customer_name, 
        o.id 
from customer c left join orders o 
on c.id=o.customerid 
where o.id is null;


# SUBQUERIES

-- 13.Find customers who ordered more than 3 times.
select concat(firstname,' ',lastname) as customer_name
from customer 
where id in 
(select customerid from orders group by customerid having count(*) > 3 );

-- 14.List products that have been ordered more than 100 times total.
Select p.ProductName
from product p
join orderitem oi on p.Id = oi.ProductId
group by p.Id, p.ProductName
having SUM(oi.Quantity) > 100;


-- 15.Find the highest spending customer.
select concat(firstname,' ',lastname) as customer_name ,
sum(totalamount) as total_amount_spent 
from customer c join orders o 
on c.id=o.CustomerId
group by 1 
order by 2 desc 
limit 1;

-- 16.Retrieve all orders that had a total amount above the average order amount.
select * from orders where TotalAmount >
(select avg(TotalAmount) from orders);


# AGGREGATE FUNCTIONS

-- 17.What is the average quantity per order item?
select avg(quantity) as average_quantity  from orderitem;

-- 18.What’s the maximum unit price of any product?
select max(unitprice) as maximum_unit_price from orderitem;

-- 19.Find the total revenue generated per product.
select productid,sum(quantity*unitprice) as total_revenue from orderitem 
group by 1;

-- 20.Show the number of distinct products ordered
select count(distinct productid) as Distinct_Products_Ordered from orderitem;



# CREATING VIEWS

-- 21.Create a view showing monthly sales per country.
create view monthly_country_sales as 
select date_format(orderdate,'%Y-%m') as month,
		  c.country,
          sum(totalamount) as total_sales
from customer c join orders o
on c.id=o.CustomerId
group by 1,2;

-- 22.Create a view with customer name, total orders, and total amount spent.
create view customer_summary as
select firstname,
        lastname,
        count(o.id) as total_orders,
        sum(totalamount) as total_amount
from customer c join orders o
on c.id=o.CustomerId
group by 1,2;
        

-- 23.Create a view listing top 10 products by revenue.
create view TopProductsByRevenue as
select p.productname,
       sum(oi.quantity*oi.unitprice) as revenue
from product p join orderitem oi
on p.id= oi.ProductId
group by 1
order by 2 desc
limit 10;



# Index Optimization

-- 24.Create an index on the OrderDate column of the orders table.
create index ind_orderdate on orders(orderdate);

-- 25.Create a composite index on ProductId and Quantity in orderitem to speed up product-related queries.
create  INDEX idx_product_quantity on orderitem(ProductId, Quantity);



# SOME MORE QUESTIONS

-- Which supplier provides the most products?
Select SupplierId, COUNT(*) as ProductCount
from product
group by SupplierId
order by ProductCount desc
limit 1;

-- List the least ordered product(s).s
Select ProductId, SUM(Quantity) as TotalOrdered
from orderitem
group by ProductId
order by TotalOrdered asc
limit 1;

-- Show customers from each country with the highest total spending.
select Country, FirstName, LastName, TotalSpent 
from(select c.Country, c.FirstName, c.LastName, SUM(o.TotalAmount) as TotalSpent,
            RANK() OVER (PARTITION BY c.Country ORDER BY SUM(o.TotalAmount) DESC) as rnk
from customer c join orders o on c.Id = o.CustomerId
group by c.Id) as ranked_customers
where rnk = 1;

-- Find products that have never been ordered.
select * from product
where Id not in
(select distinct ProductId 
from orderitem);

-- Identify suppliers located in the same city as customers (use a subquery or join with DISTINCT cities).
select distinct s.CompanyName, s.City
from supplier s
where s.City in 
(select distinct City 
from customer);












