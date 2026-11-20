---ASSIGNMENT 03
---ROLL NO 918998
---MCDE BATCH 07 

---Q1

SELECT  first_name AS First_Name,
last_name AS Last_Name,
email AS Email,
city AS City,
state AS State,
phone AS Phone_Number
FROM sales.customers
WHERE state = 'NY' AND phone IS NULL
ORDER BY Last_Name,First_Name;


---Q2

SELECT product_id,
product_name,
model_year,
list_price
FROM production.products
WHERE model_year = 2017 OR model_year = 2018 AND list_price BETWEEN 500 AND 1500 AND product_name LIKE '%Trek%' AND product_name NOT LIKE '%Kids%'
ORDER BY list_price DESC;


---Q3
---PART A

SELECT DISTINCT order_status 
FROM sales.orders;

---Q3
--PART B


SELECT order_id,
customer_id,
store_id,
shipped_date,
order_date,
required_date
FROM sales.orders
WHERE shipped_date IS NULL AND store_id IN (1,3) AND order_date LIKE '2018%'
ORDER BY order_date;

---Q4

SELECT oi.order_id,
o.order_date,
c.first_name + ' ' + last_name AS customer_name,
p.product_name,
b.brand_name,
ctg.category_name,
oi.quantity,
oi.list_price,
oi.discount,
oi.quantity * oi.list_price * (1 - oi.discount) AS line_revenue
FROM sales.order_items AS oi
INNER JOIN sales.orders AS o
ON oi.order_id = o.order_id
INNER JOIN sales.customers AS c
ON o.customer_id = c.customer_id
INNER JOIN production.products AS p
ON oi.product_id = p.product_id
INNER JOIN production.brands AS b
ON p.brand_id = b.brand_id
INNER JOIN production.categories AS ctg
ON p.category_id = ctg.category_id
WHERE oi.order_id = 1;




---Q5
SELECT s.staff_id,
s.first_name + ' ' + s.last_name AS staff_name,
st.store_id,
st.store_name,
ISNULL(m.first_name + ' ' + m.last_name,'No Manager') AS manager_name
FROM sales.staffs AS s
INNER JOIN sales.stores AS st
ON s.store_id = st.store_id
LEFT JOIN sales.staffs AS m
ON s.manager_id = m.staff_id;




---Q6

SELECT 
p.product_id,
p.product_name,
b.brand_name,
p.model_year
FROM production.products AS p
LEFT JOIN sales.order_items AS oi
ON p.product_id = oi.product_id
INNER JOIN production.brands AS b
ON p.brand_id = b.brand_id
WHERE oi.order_id IS NULL;

---Q7
---PART A

CREATE VIEW sales.vw_order_line_details AS 
SELECT oi.order_id,
o.order_date,
o.order_status,
s.store_name,
c.first_name + ' ' + last_name AS customer_name,
p.product_name,
b.brand_name,
ctg.category_name,
oi.quantity,
oi.list_price,
oi.discount,
oi.quantity * oi.list_price * (1 - oi.discount) AS line_revenue
FROM sales.order_items AS oi
INNER JOIN sales.orders AS o
ON oi.order_id = o.order_id
INNER JOIN sales.customers AS c
ON o.customer_id = c.customer_id
INNER JOIN production.products AS p
ON oi.product_id = p.product_id
INNER JOIN production.brands AS b
ON p.brand_id = b.brand_id
INNER JOIN production.categories AS ctg
ON p.category_id = ctg.category_id
INNER JOIN sales.stores AS s
ON o.store_id = s.store_id;


SELECT * FROM sales.vw_order_line_details;

---Q7
---PART B

SELECT * FROM sales.vw_order_line_details
WHERE order_date >= '2018-01-01' AND order_date < '2018-02-01'
ORDER BY order_date,order_id;

---Q8
---PART A
CREATE VIEW production.vw_product_catalog AS
SELECT p.product_id,
p.product_name,
b.brand_name,
c.category_name,
p.model_year,
p.list_price
FROM production.products AS p
INNER JOIN production.brands AS b
ON p.brand_id = b.brand_id
INNER JOIN production.categories AS c
ON p.category_id = c.category_id;

SELECT * FROM production.vw_product_catalog;

---PART B

SELECT * FROM production.vw_product_catalog
WHERE category_name = 'Electric Bikes' AND list_price > 3000 
ORDER BY list_price DESC;

---Q9

SELECT store_name,
COUNT(DISTINCT order_id) AS total_orders,
SUM(line_revenue) AS total_revenue,
YEAR(order_date) AS order_year
FROM sales.vw_order_line_details
GROUP BY store_name,YEAR(order_date)
ORDER BY store_name,YEAR(order_date);


---Q10

SELECT b.brand_name,
COUNT(*) AS product_count,
MIN(p.list_price) AS Min_price,
MAX(p.list_price) AS Max_price,
AVG(p.list_price) AS Avg_price
FROM production.products AS p
INNER JOIN production.brands AS b
ON p.brand_id = b.brand_id
GROUP BY b.brand_name
HAVING COUNT(*) > 10
ORDER BY AVG(p.list_price) DESC;


---Q11

SELECT p.product_name,
c.category_name,
p.list_price,
a.avg_price AS category_avg_price
FROM production.products AS p
INNER JOIN production.categories AS c
on p.category_id = c.category_id
INNER JOIN (
SELECT category_id,
AVG(list_price) AS avg_price
FROM production.products 
GROUP BY category_id) AS a
ON a.category_id = p.category_id
WHERE p.list_price > a.avg_price;


---Q12

---WITH IN , NOT IN

SELECT customer_id,
first_name + ' ' + last_name AS full_name,
email,
state
FROM sales.customers 
WHERE customer_id IN (
SELECT customer_id
FROM sales.orders
WHERE order_date >= '2016-01-01' AND order_date < '2017-01-01')
AND customer_id NOT IN (
SELECT customer_id 
FROM sales.orders 
WHERE order_date >= '2018-01-01' AND order_date < '2019-01-01'
AND customer_id IS NOT NULL);

---EXITS , NOT EXIST


SELECT c.customer_id,
c.first_name + ' ' + c.last_name AS full_name,
c.email,
c.state
FROM sales.customers AS c
WHERE EXISTS (
SELECT 1
FROM sales.orders AS o
WHERE c.customer_id = o.customer_id AND order_date >= '2016-01-01' AND order_date < '2017-01-01')
AND NOT EXISTS (
SELECT 1
FROM sales.orders AS o
WHERE c.customer_id = o.customer_id AND order_date >= '2018-01-01' AND order_date < '2019-01-01');


---Q13

WITH store_revenue AS (
SELECT store_name,
SUM(line_revenue) AS total_revenue
FROM sales.vw_order_line_details 
GROUP BY store_name),

average_store_revenue AS (
SELECT AVG(total_revenue) AS avg_revenue
FROM store_revenue)

SELECT s.store_name,
s.total_revenue,
a.avg_revenue,
s.total_revenue - a.avg_revenue AS difference
FROM store_revenue AS s
CROSS JOIN average_store_revenue AS a
WHERE s.total_revenue > a.avg_revenue 
ORDER BY difference DESC;


---Q14


WITH hierarchy AS (
SELECT staff_id,
first_name + ' ' + last_name AS full_name,
manager_id,
1 AS level,
CAST(first_name + ' ' + last_name AS VARCHAR(300)) AS reporting_path
FROM sales.staffs
WHERE manager_id is NULL

UNION ALL 

SELECT s.staff_id,
s.first_name + ' ' + s.last_name AS full_name,
s.manager_id,
h.level + 1,
CAST(h.reporting_path + '>' + s.first_name + ' ' + s.last_name AS VARCHAR(300))
FROM sales.staffs AS s
INNER JOIN hierarchy AS h
ON s.manager_id = h.staff_id
)
SELECT staff_id,
full_name,
manager_id,
level,
reporting_path
FROM hierarchy 
ORDER BY level,staff_id;



---Q15
---PART A
WITH ranked AS (
SELECT category_name,
product_name,
SUM(quantity) AS total_quantity,
SUM(line_revenue) AS total_revenue,
RANK() OVER (PARTITION BY category_name ORDER BY SUM(line_revenue) DESC) AS revenue_rank
FROM sales.vw_order_line_details 
WHERE order_date >= '2017-01-01' AND order_date < '2018-01-01'
GROUP BY category_name,product_name)

SELECT * FROM ranked
WHERE revenue_rank <= 3
ORDER BY category_name, revenue_rank;




---Q15 
---PART B
WITH months AS (
SELECT 1 as month_no
UNION ALL 
SELECT month_no + 1
FROM months 
WHERE month_no > 12)

SELECT 
m.month_no,
DATENAME(MONTH ,DATEFROMPARTS(2017, m.month_no, 1)) AS month_name,
COUNT(DISTINCT v.order_id) AS total_orders,
ISNULL(SUM(v.line_revenue), 0) AS total_revenue
FROM months AS m
LEFT JOIN sales.vw_order_line_details AS v
ON MONTH(v.order_date) = m.month_no AND YEAR(order_date) = 2017
GROUP BY m.month_no
ORDER BY m.month_no;