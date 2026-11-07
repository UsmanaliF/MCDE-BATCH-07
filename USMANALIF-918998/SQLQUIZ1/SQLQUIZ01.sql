--SQL QUIZ #01
--ROLL NO 918998
--MCDE BATCH 07

--CHAP 01
--Q1
SELECT 
first_name, last_name, email, state
FROM sales.customers 
WHERE state IN ('NY' , 'CA')
AND email LIKE '%.com'
AND last_name LIKE 'M%'
ORDER BY last_name, city ASC;

--CHAP 01
--Q2
SELECT product_name, list_price,
list_price * 0.10  AS "DISCOUNTED PRICE"
FROM production.products
WHERE list_price > 500
ORDER BY "DISCOUNTED PRICE" ASC
OFFSET 10 ROWS FETCH NEXT 10 ROWS ONLY;

--CHAP 01
--Q3
SELECT order_id, order_date, order_status, required_date, shipped_date
FROM sales.orders
WHERE order_id IS NULL
OR shipped_date IS NULL
AND order_date BETWEEN '2018-01-01' AND '2018-06-30';








--CHAP 02
--Q4
SELECT
c.first_name + ' ' + c.last_name AS "FULL NAME",
o.order_id, o.order_date, s.store_name, p.product_name, st.quantity
FROM sales.customers AS c
INNER JOIN sales.orders AS o
ON c.customer_id = o.customer_id
INNER JOIN sales.stores AS s
ON o.store_id = s.store_id
INNER JOIN production.stocks AS st
ON s.store_id = st.store_id
INNER JOIN production.products AS p
ON st.store_id = p.product_id
ORDER BY o.order_date DESC;


-- CHAP 02
--Q5
SELECT 
p.product_name, c.category_name, b.brand_name
FROM production.products AS p 
INNER JOIN production.categories AS c
ON p.category_id = c.category_id
INNER JOIN production.brands AS b
ON p.brand_id = b.brand_id; 


-- CHAP 02
-- Q6
SELECT
s.first_name + ' ' + s.last_name AS staff_name,
m.first_name + ' ' + m.last_name AS manager_name,
st.store_name
FROM sales.staffs AS s
LEFT JOIN sales.staffs AS m
ON s.manager_id = m.manager_id
INNER JOIN sales.stores AS st
ON s.store_id = st.store_id;


--CHAP 03
-- Q7
CREATE VIEW sales.vw_order_details AS
SELECT
o.order_id,
o.order_date,
o.order_status,
c.customer_id,
c.first_name + ' ' + c.last_name AS full_name,
p.product_name, 
st.quantity,
st.quantity * p.list_price *(1 - oi.discount) AS line_total
FROM sales.customers AS c
INNER JOIN sales.order_items AS o
ON c.customer_id = o.customer_id
INNER JOIN sales.order_items AS oi
ON o.order_id = oi.order_id
INNER JOIN production.products AS p
ON oi.product_id = p.product_id
INNER JOIN production.stocks AS st
ON p.product_id = st.product_id
INNER JOIN sales.stores AS s
ON st.store_id = s.store_id;

SELECT * FROM sales.vw_order_details;


--CHAP 04
-- Q8

SELECT *
FROM sales.vw_order_details
WHERE line_total > 10000
ORDER BY line_total DESC;






