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

-- V 1. Для каждого города определить ресторан с максимальной ежемесячной выручкой, указав его позицию в рейтинге города.
-- V 2. Посчитать разницу в выручке между текущим рестораном и предыдущим в том же городе по дате открытия.
-- V 3. Пронумеровать рестораны в каждом городе по дате открытия с помощью оконной функции ROW\_NUMBER.
-- V 4. Определить долю выручки каждого ресторана в общем объёме выручки его города.
-- V 5. Вывести рестораны, у которых выручка выше среднего значения по городу, используя оконную функцию AVG.
-- 6. Найти рестораны, открытые последними в каждом городе, но с выручкой ниже медианы по городу.
-- V 7. Посчитать накопленную сумму выручки в каждом городе, отсортированную по дате открытия ресторанов.
-- 8. Для каждого ресторана вывести количество ресторанов в его городе, открытых раньше.
-- 9. Найти рестораны, чья выручка меньше, чем у следующего ресторана в том же городе по дате открытия.
-- 10. Определить разницу между максимальной и минимальной выручкой по каждому городу и вывести её в каждой строке.

SELECT * FROM customers
SELECT * FROM employees
SELECT * FROM menus
SELECT * FROM orders
SELECT * FROM restaurants

-- Ранжирование

-- ROW_NUMBER() — уникальный номер строки в рамках партиции.
-- RANK() — ранг с пропусками при совпадениях (1, 2, 2, 4).
-- DENSE_RANK() — ранг без пропусков (1, 2, 2, 3).
-- NTILE(N) — разбивает набор на N равных частей.

-- Смещение

-- LAG(expr, offset, default) — значение из предыдущей строки.
-- LEAD(expr, offset, default) — значение из следующей строки.
-- FIRST_VALUE(expr) — первое значение в окне.
-- LAST_VALUE(expr) — последнее значение в окне.


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



-- 1. Для каждого города определить ресторан с максимальной ежемесячной выручкой, указав его позицию в рейтинге города.
SELECT * FROM orders
SELECT * FROM restaurants
-- RANK() — функция ранжирования, которая присваивает каждой строке позицию в отсортированном наборе в пределах окна

WITH monthly_revenue AS (
    SELECT
        r.city,
        r.restaurant_id,
        r.name_restaraunt,
        TRUNC(o.order_date, 'MM') AS month_period,
        SUM(o.total_amount) AS monthly_sum
    FROM restaurants r
    JOIN orders o
        ON o.restaurant_id = r.restaurant_id
    GROUP BY
        r.city,
        r.restaurant_id,
        r.name_restaraunt,
        TRUNC(o.order_date, 'MM') -- Выясняем суммарную выручку по ресторанам в соответствии с месяцем
),

ranked AS (
    SELECT
        city,
        restaurant_id,
        name_restaraunt,
        month_period,
        monthly_sum,
        RANK() OVER (
            PARTITION BY city, month_period
            ORDER BY monthly_sum DESC
        ) AS rank_in_city
    FROM monthly_revenue -- Присваиваем соответствующий рейтинг по выручке
)

SELECT *
FROM ranked
WHERE rank_in_city = 1
ORDER BY city, month_period; -- Берем рестораны только с рейтингом 1



-- 2. Посчитать разницу в выручке между текущим рестораном и предыдущим в том же городе по дате открытия.

WITH revenue_by_restaurant AS (
    SELECT
        r.city,
        r.restaurant_id,
        r.name_restaraunt,
        r.opening_date,
        SUM(o.total_amount) AS total_revenue
    FROM restaurants r
    JOIN orders o
        ON o.restaurant_id = r.restaurant_id
    GROUP BY
        r.city,
        r.restaurant_id,
        r.name_restaraunt,
        r.opening_date -- Группируем по городу и сортируем по дате открытия
)
SELECT
    city,
    restaurant_id,
    name_restaraunt,
    opening_date,
    total_revenue,
    total_revenue - LAG(total_revenue) OVER (
        PARTITION BY city
        ORDER BY opening_date
    ) AS revenue_diff
FROM revenue_by_restaurant
ORDER BY city, opening_date; -- Вычитаем из выручки текущего ресторана выручку предыдущего (берем через LAG)


-- 4. Определить долю выручки каждого ресторана в общем объёме выручки его города.

WITH revenue_by_restaurant AS (
    SELECT
        r.city,
        r.restaurant_id,
        r.name_restaraunt,
        SUM(o.total_amount) AS total_revenue
    FROM restaurants r
    JOIN orders o
        ON o.restaurant_id = r.restaurant_id
    GROUP BY
        r.city,
        r.restaurant_id,
        r.name_restaraunt -- Вычисляем сумму на каждый ресторан за все время
)
SELECT
    city,
    restaurant_id,
    name_restaraunt,
    total_revenue,
    ROUND(
        total_revenue / SUM(total_revenue) OVER (PARTITION BY city) * 100, -- Делим общую выручку по ресторану, на суммарную выручку в рамках города и умножаем на 100 для получения %
        2
    ) AS revenue_share_percent
FROM revenue_by_restaurant
ORDER BY city, revenue_share_percent DESC;


-- 5. Вывести рестораны, у которых выручка выше среднего значения по городу, используя оконную функцию AVG.

WITH revenue_by_restaurant AS (
    SELECT
        r.city,
        r.restaurant_id,
        r.name_restaraunt,
        SUM(o.total_amount) AS total_revenue
    FROM restaurants r
    JOIN orders o
        ON o.restaurant_id = r.restaurant_id
    GROUP BY
        r.city,
        r.restaurant_id,
        r.name_restaraunt -- То же что и выше
),

with_avg AS (
    SELECT
        city,
        restaurant_id,
        name_restaraunt,
        total_revenue,
        AVG(total_revenue) OVER (PARTITION BY city) AS avg_city_revenue -- Считаем средунюю выручку в городе
    FROM revenue_by_restaurant
)
SELECT
    city,
    restaurant_id,
    name_restaraunt,
    total_revenue,
    avg_city_revenue
FROM with_avg
WHERE total_revenue > avg_city_revenue -- Выводим те у которых выручка выше средней выручки по городу
ORDER BY city, total_revenue DESC;





-- 10. Определить разницу между максимальной и минимальной выручкой по каждому городу и вывести её в каждой строке.


WITH revenue_by_restaurant AS (
    SELECT
        r.city,
        r.restaurant_id,
        r.name_restaraunt,
        SUM(o.total_amount) AS total_revenue
    FROM restaurants r
    JOIN orders o
        ON o.restaurant_id = r.restaurant_id
    GROUP BY
        r.city,
        r.restaurant_id,
        r.name_restaraunt -- То же что и выше
)
SELECT
    city,
    restaurant_id,
    name_restaraunt,
    total_revenue,
    MAX(total_revenue) OVER (PARTITION BY city)
      - MIN(total_revenue) OVER (PARTITION BY city) AS revenue_diff_city -- Максимальная выручка по городу - Минимальная
FROM revenue_by_restaurant
ORDER BY city, total_revenue DESC;





