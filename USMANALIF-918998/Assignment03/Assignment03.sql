---ASSIGNMENT 03
---ROLL NO 918998
---MCDE BATCH 07 

---Q1
USE BikeStores;
SELECT
first_name AS "FIRST NAME",
last_name AS "LAST NAME",
email AS "EMAIL",
city AS "CITY"
FROM sales.customers
WHERE state = 'NY'
AND phone IS NULL
ORDER BY last_name ASC, first_name ASC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

---Q2
SELECT
product_id,
product_name,
model_year,
list_price
FROM production.products
WHERE model_year IN (2017, 2018)
AND list_price BETWEEN 500 AND 1500
AND product_name LIKE '%Trek%'
AND product_name NOT LIKE '%Kids%'
ORDER BY list_price DESC;

---Q3
---PART A
SELECT DISTINCT order_status
FROM sales.orders;


---PART B
SELECT
order_id,
customer_id,
store_id,
order_date,
required_date
FROM sales.orders
WHERE shipped_date IS NULL
AND store_id IN (1, 3)
AND order_date >= '2018-01-01'
AND order_date < '2019-01-01'
ORDER BY order_date;


---Q4
SELECT
o.order_id,
o.order_date,
c.first_name + ' ' + c.last_name AS customer_full_name,
p.product_name,
b.brand_name,
cat.category_name,
oi.quantity,
oi.list_price,
oi.discount,
oi.quantity * oi.list_price * (1 - oi.discount) AS line_revenue
FROM sales.orders AS o
INNER JOIN sales.customers AS c
ON o.customer_id = c.customer_id
INNER JOIN sales.order_items AS oi
ON o.order_id = oi.order_id
INNER JOIN production.products AS p
ON oi.product_id = p.product_id
INNER JOIN production.brands AS b
ON p.brand_id = b.brand_id
INNER JOIN production.categories AS cat
ON p.category_id = cat.category_id
WHERE o.order_id = 1;


---Q5
SELECT
s.first_name + ' ' + s.last_name AS staff_full_name,
st.store_name,
COALESCE(m.first_name + ' ' + m.last_name, 'No Manager') AS manager_full_name
FROM sales.staffs AS s
LEFT JOIN sales.stores AS st
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
INNER JOIN production.brands AS b
ON p.brand_id = b.brand_id
LEFT JOIN sales.order_items AS oi
ON p.product_id = oi.product_id
WHERE oi.order_id IS NULL;


---Q7
---PART A
CREATE VIEW sales.vw_order_line_details AS
SELECT
o.order_id,
o.order_date,
c.first_name + ' ' + c.last_name AS customer_full_name,
p.product_name,
b.brand_name,
cat.category_name,
oi.quantity,
oi.list_price,
oi.discount,
oi.quantity * oi.list_price * (1 - oi.discount) AS line_revenue,
st.store_name,
o.order_status
FROM sales.orders AS o
INNER JOIN sales.customers AS c
ON o.customer_id = c.customer_id
INNER JOIN sales.order_items AS oi
ON o.order_id = oi.order_id
INNER JOIN production.products AS p
ON oi.product_id = p.product_id
INNER JOIN production.brands AS b
ON p.brand_id = b.brand_id
INNER JOIN production.categories AS cat
ON p.category_id = cat.category_id
INNER JOIN sales.stores AS st
ON o.store_id = st.store_id;

---PART B
SELECT *
FROM sales.vw_order_line_details
WHERE order_date >= '2018-01-01'
AND order_date < '2018-02-01'
ORDER BY order_date, order_id;

---Q8
---PART A
CREATE VIEW production.vw_product_catalog AS
SELECT
p.product_id,
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


---PART B 
SELECT *
FROM production.vw_product_catalog
WHERE category_name = 'Electric Bikes'
AND list_price > 3000
ORDER BY list_price DESC;



---Q9
SELECT
store_name,
YEAR(order_date) AS year,
COUNT(DISTINCT order_id) AS total_orders,
SUM(line_revenue) AS total_revenue
FROM sales.vw_order_line_details
GROUP BY store_name, YEAR(order_date)
ORDER BY store_name, year;


---Q10
SELECT
b.brand_name,
COUNT(p.product_id) AS product_count,
MIN(p.list_price) AS min_price,
AVG(p.list_price) AS avg_price,
MAX(p.list_price) AS max_price
FROM production.brands AS b
INNER JOIN production.products AS p
ON b.brand_id = p.brand_id
GROUP BY b.brand_name
HAVING COUNT(p.product_id) > 10
ORDER BY avg_price DESC;


---Q11
SELECT
p.product_name,
c.category_name,
p.list_price,
cat_avg.avg_price AS category_avg_price
FROM production.products AS p
INNER JOIN production.categories AS c
ON p.category_id = c.category_id
INNER JOIN (
SELECT category_id, AVG(list_price) AS avg_price
FROM production.products
GROUP BY category_id
) AS cat_avg
ON p.category_id = cat_avg.category_id
WHERE p.list_price > cat_avg.avg_price;


---Q12

----SIR ISME IN OR NOT IN USE KIYA HAI
SELECT
c.customer_id,
c.first_name + ' ' + c.last_name AS full_name,
c.email,
c.state
FROM sales.customers AS c
WHERE c.customer_id IN (
SELECT customer_id FROM sales.orders
WHERE order_date >= '2016-01-01' AND order_date < '2017-01-01'
)
AND c.customer_id NOT IN (
SELECT customer_id FROM sales.orders
WHERE order_date >= '2018-01-01' AND order_date < '2019-01-01'
);


----SIR YE EXIST NOT EXIST WALA HAI 
SELECT
c.customer_id,
c.first_name + ' ' + c.last_name AS full_name,
c.email,
c.state
FROM sales.customers AS c
WHERE EXISTS (
SELECT 1 FROM sales.orders AS o
WHERE o.customer_id = c.customer_id
AND o.order_date >= '2016-01-01' AND o.order_date < '2017-01-01'
)
AND NOT EXISTS (
SELECT 1 FROM sales.orders AS o
WHERE o.customer_id = c.customer_id
AND o.order_date >= '2018-01-01' 
AND o.order_date < '2019-01-01'
);


---Q13
WITH store_revenue AS (
SELECT
store_name,
SUM(line_revenue) AS total_revenue
FROM sales.vw_order_line_details
GROUP BY store_name
),
avg_revenue AS (
SELECT AVG(total_revenue) AS avg_rev
FROM store_revenue
)
SELECT
sr.store_name,
sr.total_revenue,
ar.avg_rev AS average,
sr.total_revenue - ar.avg_rev AS difference
FROM store_revenue AS sr
CROSS JOIN avg_revenue AS ar
WHERE sr.total_revenue > ar.avg_rev;


---Q14
WITH staff_hierarchy AS (
SELECT
staff_id,
first_name + ' ' + last_name AS staff_full_name,
manager_id,
1 AS level,
CAST(first_name + ' ' + last_name AS VARCHAR(500)) AS reporting_path
FROM sales.staffs
WHERE manager_id IS NULL
UNION ALL
SELECT
s.staff_id,
s.first_name + ' ' + s.last_name,
s.manager_id,
sh.level + 1,
CAST(sh.reporting_path + ' > ' + s.first_name + ' ' + s.last_name AS VARCHAR(500))
FROM sales.staffs AS s
INNER JOIN staff_hierarchy AS sh
ON s.manager_id = sh.staff_id
)
SELECT
staff_id,
staff_full_name,
manager_id,
level,
reporting_path
FROM staff_hierarchy
ORDER BY level, staff_id;

---Q15
---PART A
WITH product_revenue AS (
SELECT
cat.category_name,
p.product_name,
SUM(oi.quantity) AS total_quantity,
SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue,
RANK() OVER (
PARTITION BY cat.category_id
ORDER BY SUM(oi.quantity * oi.list_price * (1 - oi.discount)) DESC
) AS rnk
FROM sales.orders AS o
INNER JOIN sales.order_items AS oi
ON o.order_id = oi.order_id
INNER JOIN production.products AS p
ON oi.product_id = p.product_id
INNER JOIN production.categories AS cat
ON p.category_id = cat.category_id
WHERE o.order_date >= '2017-01-01'
AND o.order_date < '2018-01-01'
GROUP BY cat.category_id, cat.category_name, p.product_id, p.product_name
)
SELECT
category_name,
product_name,
total_quantity,
total_revenue,
rnk
FROM product_revenue
WHERE rnk <= 3
ORDER BY category_name, rnk;


---PART B
WITH months AS (
SELECT 1 AS month_num UNION ALL
SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL
SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL
SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL
SELECT 11 UNION ALL SELECT 12
),
monthly_sales AS (
SELECT
MONTH(o.order_date) AS month_num,
COUNT(DISTINCT o.order_id) AS total_orders,
SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue
FROM sales.orders AS o
INNER JOIN sales.order_items AS oi
ON o.order_id = oi.order_id
WHERE o.order_date >= '2017-01-01'
AND o.order_date < '2018-01-01'
GROUP BY MONTH(o.order_date)
)
SELECT
m.month_num,
DATENAME(MONTH, DATEFROMPARTS(2017, m.month_num, 1)) AS month_name,
COALESCE(ms.total_orders, 0) AS total_orders,
COALESCE(ms.total_revenue, 0) AS total_revenue
FROM months AS m
LEFT JOIN monthly_sales AS ms
ON m.month_num = ms.month_num
ORDER BY m.month_num;

