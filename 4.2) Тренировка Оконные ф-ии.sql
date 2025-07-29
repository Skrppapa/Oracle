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




------------------------------------------ДЗ

-- 1. Для каждого города определить ресторан с максимальной ежемесячной выручкой, указав его позицию в рейтинге города.
-- 2. Посчитать разницу в выручке между текущим рестораном и предыдущим в том же городе по дате открытия.
-- V 3. Пронумеровать рестораны в каждом городе по дате открытия с помощью оконной функции ROW\_NUMBER.
-- 4. Определить долю выручки каждого ресторана в общем объёме выручки его города.
-- 5. Вывести рестораны, у которых выручка выше среднего значения по городу, используя оконную функцию AVG.
-- 6. Найти рестораны, открытые последними в каждом городе, но с выручкой ниже медианы по городу.
-- 7. Посчитать накопленную сумму выручки в каждом городе, отсортированную по дате открытия ресторанов.
-- 1. Для каждого города определить ресторан с максимальной ежемесячной выручкой, указав его позицию в рейтинге города.
-- 2. Посчитать разницу в выручке между текущим рестораном и предыдущим в том же городе по дате открытия.
-- V 3. Пронумеровать рестораны в каждом городе по дате открытия с помощью оконной функции ROW\_NUMBER.
-- 4. Определить долю выручки каждого ресторана в общем объёме выручки его города.
-- 5. Вывести рестораны, у которых выручка выше среднего значения по городу, используя оконную функцию AVG.
-- 6. Найти рестораны, открытые последними в каждом городе, но с выручкой ниже медианы по городу.
-- 7. Посчитать накопленную сумму выручки в каждом городе, отсортированную по дате открытия ресторанов.
-- 8. Для каждого ресторана вывести количество ресторанов в его городе, открытых раньше.
-- 9. Найти рестораны, чья выручка меньше, чем у следующего ресторана в том же городе по дате открытия.
-- 10. Определить разницу между максимальной и минимальной выручкой по каждому городу и вывести её в каждой строке.

SELECT * FROM customers
SELECT * FROM employees
SELECT * FROM menus
SELECT * FROM orders
SELECT * FROM restaurants


-- 3. Пронумеровать рестораны в каждом городе по дате открытия с помощью оконной функции ROW\_NUMBER.

SELECT ROW_NUMBER() OVER (PARTITION BY name_restaraunt ORDER BY opening_date DESC), name_restaraunt, restaurant_id
FROM restaurants


-- 7. Посчитать накопленную сумму выручки в каждом городе, отсортированную по дате открытия ресторанов.

WITH tot_amount_restaurant AS (

SELECT r.restaurant_id, r.name_restaraunt, r.city, r.opening_date, SUM(o.total_amount) AS tot_amount
FROM restaurants r
LEFT JOIN orders o ON r.restaurant_id = o.restaurant_id
GROUP BY r.restaurant_id, r.name_restaraunt, r.city, r.opening_date), -- Вычисляем сумму по городам

cumulative_amount AS (

SELECT restaurant_id, name_restaraunt, city, opening_date, tot_amount,
SUM(tot_amount) OVER (PARTITION BY city ORDER BY opening_date) AS cumulative_revenue_city
FROM tot_amount_restaurant) -- Оконка по городам с сортировкой по открытию

SELECT restaurant_id, name_restaraunt, city, opening_date, tot_amount, cumulative_revenue_city
FROM cumulative_amount
ORDER BY city, opening_date; --  2 таблица + группировка



-- 5. Вывести рестораны, у которых выручка выше среднего значения по городу, используя оконную функцию AVG. НЕЗАКОНЧИЛ
WITH total_amount_rest (SELECT restaurant_id, SUM(total_amount) AS total_sum
                        FROM orders
                        GROUP BY restaurant_id),

avg_amount_by_city AS (SELECT r.name_restaraunt, AVG(o.total_sum) OVER (PARTITION BY r.city) AS avg_amount
FROM restaurants r
JOIN orders o ON o.restaurant_id = r.restaurant_id)

SELECT avg_amount_by_city.name_restaraunt
FROM total_amount_rest,
WHERE total_sum > avg_amount

-- 8. Для каждого ресторана вывести количество ресторанов в его городе, открытых раньше.
-- 9. Найти рестораны, чья выручка меньше, чем у следующего ресторана в том же городе по дате открытия.
-- 10. Определить разницу между максимальной и минимальной выручкой по каждому городу и вывести её в каждой строке.


-- 5. Вывести рестораны, у которых выручка выше среднего значения по городу, используя оконную функцию AVG. НЕЗАКОНЧИЛ
WITH total_amount_rest (SELECT restaurant_id, SUM(total_amount) AS total_sum
                        FROM orders
                        GROUP BY restaurant_id),

avg_amount_by_city AS (SELECT r.name_restaraunt, AVG(o.total_sum) OVER (PARTITION BY r.city) AS avg_amount
FROM restaurants r
JOIN orders o ON o.restaurant_id = r.restaurant_id)

SELECT avg_amount_by_city.name_restaraunt
FROM total_amount_rest,
WHERE total_sum > avg_amount




