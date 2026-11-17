/*========================================================================================================================================
  PROJECT TITLE : End-to-End Supply chain & Logistics Analytics (mysql)
  DARASET: Dataco Smart Supply Cain Dataset ( 105,000+ Records)
  DATABASE : MYSQL ( supply_chain_db)
  DESCRIPTION : Complete Workflow Including Data Cleaning ,Normalization ( 6 Realational Tables),and Business KPI analysis
=========================================================================================================================================*/




CREATE DATABASE IF NOT EXISTS supply_chain_db;
USE supply_chain_db;

RENAME TABLES datacosupplychaindataset to supply_chain;

SHOW TABLES;

SELECT count(*) from supply_chain;

DESCRIBE supply_chain;


-- PHASE 1: DATA CLEANING & STANDARDIZATION--


-- 1.1 Disable safe update mode to allow bulk data cleaning updates
set sql_safe_updates=0;


ALTER TABLE supply_chain
ADD COLUMN order_datetime datetime,
ADD COLUMN shipping_datetime datetime;
 
 
update supply_chain
SET order_datetime=str_to_date('order date(dateorders)','%m/%d/%Y %H:%i'),
shipping_datetime=str_to_date('shipping_date(dateshipping)','%m/%d/%Y %H:%i');
    

alter table supply_chain
drop column `Customer Email`,
drop column `Customer password`,
drop column `Product Image`,
drop column `Product description`,
drop column `latitude`,
drop column `longitude`,
drop column `market`;

select distinct `Order city`
from supply_chain
where`Order city`like '%?%';

update supply_chain
SET`Order City`= CASE 
    WHEN`Order City`= 'Kahramanmara?' THEN 'Kahramanmaras'
    WHEN`Order City`= 'Klaip?da' THEN 'Klaipeda'
    WHEN`Order City`= 'Aew?l-li' THEN 'Aewol-li'
    WHEN`Order City`= 'Bra?ov' THEN 'Brasov'
    WHEN`Order City`= 'Gy?r' THEN 'Gyor'
    WHEN`Order City`LIKE 'Cox%B?z?r' THEN 'Cox''s Bazar'
    ELSE`Order City`
END
WHERE`Order City`LIKE '%?%';

select * from supply_chain
where `Order Item Quantity`<0;

select * from supply_chain
where `product price`<=0;

select * from supply_chain
where `Order zipcode` is null or `Order zipcode`='';

update supply_chain
set `Order zipcode`='00000'
where `Order zipcode`is null or `Order zipcode`='';

update supply_chain
set `Customer Lname`='UNKNOWN'
WHERE `Customer Lname` IS NULL OR `Customer Lname`='';

select `Order id`,order_datetime,shipping_datetime from supply_chain
where shipping_datetime<order_datetime;

select `Order Item Id`,count(*) from supply_chain
group by `Order Item Id`
having count(*)>1;


-- PHASE 2 : DATABASE NORMALIZATION--


CREATE TABLE departments as 
select distinct 
       `Department Id` as department_id ,
	   `Department Name` as department_name
from supply_chain
where `Department Id` is not null ;

alter table departments add primary key (department_id);

CREATE TABLE categorys as
select distinct 
      `Category Id` as category_id,
	  `Category Name`as category_name,
	  `Department Id` as department_id
from supply_chain 
where `Category Id`is not null;

alter table categorys add primary key (category_id);

CREATE TABLE products as 
select distinct 
      `Product Card Id` as product_id,
	  `Product Name` as product_name,
	  `Product Price` as product_price,
	  `Product status` as product_status,
	  `Category Id`as category_id
from supply_chain
where `product Card Id` is not null;

alter table products add primary key (product_id);

CREATE TABLE customers as
select distinct 
      `Customer Id` as customer_id,
	  `Customer Fname` as customer_firstname,
      `Customer Lname` as customer_lastname,
      `Customer Segment` as segment,
      `Customer City` as city,
      `Customer State`as state,
      `Customer Country` as country,
	  `Customer Zipcode` as zipcode
from supply_chain
where `Customer Id` is not null;

alter table customers add primary key (customer_id);

CREATE TABLE orders AS
SELECT 
    `Order Id` AS order_id,
    MAX(`Customer Id`) AS customer_id,
    MAX(`order date (DateOrders)`) AS order_date,
    MAX(`shipping date (DateOrders)`) AS shipping_date,
    MAX(`Days for shipping (real)`) AS days_shipping_real,
    MAX(`Days for shipment (scheduled)`) AS days_shipment_scheduled,
    MAX(`Delivery Status`) AS delivery_status,
    MAX(`Late_delivery_risk`) AS late_delivery_risk,
    MAX(`Shipping Mode`) AS shipping_mode,
    MAX(`Type`) AS payment_type,
    MAX(`Order City`) AS order_city,
    MAX(`Order Country`) AS order_country,
    MAX(`Order Region`) AS order_region,
    MAX(`Order Status`) AS order_status
FROM supply_chain
GROUP BY `Order Id`;

ALTER TABLE orders ADD PRIMARY KEY (order_id);

CREATE TABLE order_items AS
SELECT 
    `Order Item Id` AS order_item_id,
    `Order Id`AS order_id,
    `Product Card Id` AS product_id,
    `Order Item Quantity` AS quantity,
    `Order Item Discount` AS discount,
    `Order Item Discount Rate` AS discount_rate,
    Sales AS sales,
    `Order Profit Per Order` AS profit
FROM supply_chain;

ALTER TABLE order_items ADD PRIMARY KEY (order_item_id);


--  PHASE 3 : ADDING FOREIGN KEY--

-- 1.  link the categories to departments 
ALTER TABLE categories
ADD CONSTRAINT fk_cat_dept
FOREIGN KEY (department_id) REFERENCES departments(department_id);

-- 2.  link the products to categorie
ALTER TABLE products
ADD CONSTRAINT fk_prod_cat
FOREIGN KEY (category_id) REFERENCES categories(category_id);

-- 3.  link the orders to customers 
ALTER TABLE orders
ADD CONSTRAINT fk_ord_cust
FOREIGN KEY (customer_id) REFERENCES customers(customer_id);

-- 4. link the order_items to orders
ALTER TABLE order_items
ADD CONSTRAINT fk_item_ord
FOREIGN KEY (order_id) REFERENCES orders(order_id);

-- 5.  link the order_items to products
ALTER TABLE order_items
ADD CONSTRAINT fk_item_prod
FOREIGN KEY (product_id) REFERENCES products(product_id);


-- PHASE 4 : BUSINESS ANALYSIS & KPI QUERIES


-- Q1 Logistics Performance - Late Delivery Percentage By Shipping Mode
SELECT 
   shipping_mode,COUNT(order_id) as total_orders,
   sum(case when late_delivery_risk=1 then 1 else 0 end) as late_orders,
   round(sum(case when late_delivery_risk=1 then 1 else 0 end)*100.0/COUNT(order_id),2) as late_delivery_pct
from orders
group by shipping_mode
order by late_delivery_pct DESC;


-- Q2: Revenue & Profitability - Top 10 Categories across Departments (Multi-Table JOIN)
SELECT 
    d.department_name,
    c.category_name,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.sales), 2) AS total_revenue,
    ROUND(SUM(oi.profit), 2) AS total_profit
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN categorys c ON p.category_id = c.category_id
JOIN departments d ON c.department_id = d.department_id
GROUP BY d.department_name, c.category_name
ORDER BY total_revenue DESC
LIMIT 10;


-- Q3: Product Ranking - Top 2 Best-Selling Products per Department (CTE + Window Function)
WITH ProductRanking AS (
    SELECT 
        d.department_name,
        p.product_name,
        ROUND(SUM(oi.sales), 2) AS total_sales,
        DENSE_RANK() OVER(PARTITION BY d.department_name ORDER BY SUM(oi.sales) DESC) AS rnk
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    JOIN categorys c ON p.category_id = c.category_id
    JOIN departments d ON c.department_id = d.department_id
    GROUP BY d.department_name, p.product_name
)
SELECT 
    department_name, 
    product_name, 
    total_sales
FROM ProductRanking
WHERE rnk <= 2;


-- Q4: Risk Management - Regions & Payment Types with Highest Suspected Fraud
SELECT 
    order_region,
    payment_type,
    COUNT(order_id) AS fraud_orders_count
FROM orders
WHERE order_status = 'SUSPECTED_FRAUD'
GROUP BY order_region, payment_type
ORDER BY fraud_orders_count DESC
LIMIT 10;


-- Q5: Customer Segmentation - Average Order Value (AOV) by Customer Segment
SELECT 
    c.segment,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.sales), 2) AS total_sales,
    ROUND(SUM(oi.sales) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.segment
ORDER BY total_sales DESC;


-- Q6: Loss Identification - Top 10 Loss-Making Products (Negative Total Profit)
SELECT 
    p.product_name,
    COUNT(oi.order_item_id) AS times_ordered,
    ROUND(SUM(oi.sales), 2) AS total_sales,
    ROUND(SUM(oi.profit), 2) AS total_loss
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_name
HAVING SUM(oi.profit) < 0
ORDER BY total_loss ASC
LIMIT 10;



