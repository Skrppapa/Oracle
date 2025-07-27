SELECT * FROM customers
SELECT * FROM employees
SELECT * FROM menus
SELECT * FROM orders
SELECT * FROM restaurants


SELECT customer_id, LEAD(order_date, 1) OVER (partition BY customer_id ORDER BY order_date DESC)
FROM orders

-- LEAD и LAG смещение

SELECT customer_id, ROW_NUMBER() OVER (partition BY customer_id ORDER BY order_date DESC), RANK() OVER (partition BY customer_id ORDER BY order_date DESC), DENSE_RANK() OVER (partition BY customer_id ORDER BY order_date DESC)
FROM orders

-- ROW_NUMBER, RANK, DENSE_RANK (FIRST_VALUE, LAST_VALUE)
-- Синтаксис OVER (ROWS BETWEEN)

-- Фамилию каждого польз посчитать total amount
SELECT *
FROM
(SELECT c.name_customer, SUM(CASE WHEN (trunc(SYSDATE) - birthday) > 30 THEN 1 ELSE 0 END) OVER (partition BY c.name_customer) AS total_amount
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id)
GROUP BY name_customer, total_amount




SELECT *
FROM
(SELECT c.name_customer, CASE WHEN (trunc(SYSDATE) - birthday) > 30 THEN SUM(total_amount) OVER (partition BY c.name_customer) ELSE AVG (total_amount) OVER (partition BY c.name_customer) END AS total_amount
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id)
GROUP BY name_customer, total_amount





