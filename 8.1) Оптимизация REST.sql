SELECT * FROM customers
SELECT * FROM employees
SELECT * FROM menus
SELECT * FROM orders
SELECT * FROM restaurants

city -- Город
total_restaurants -- Количество ресторанов

open_restaurants -- Открытые рестораны
closed_restaurants -- Закрытые
first_opened_date -- Первый открытый ресторан в рамках города
last_opened_date -- Последний
percent_open -- % открытых

avg_revenue -- Средний заработок
max_revenue -- Макс
min_revenue -- Мин

-- Открытй ресторан - это год октрытия > 2.02.2022

SELECT
    restaurant_id,
    name_restaraunt,
    city,
    opening_date,
    created_at,
    update_at,
    row_id
FROM
    restaurants;

SELECT
    order_id,
    customer_id,
    restaurant_id,
    order_date,
    total_amount,
    created_at,
    update_at,
    row_id
FROM
    orders;


WITH my_amount AS(

SELECT r.city,
    ROUND(AVG(total_amount), 2) AS avg_amount,
    ROUND(MAX(total_amount), 2) AS max_amount,
    ROUND(MIN(total_amount), 2) AS min_amount,
    MAX(opening_date) AS last_open,
    MIN(opening_date) AS first_open

FROM restaurants r
JOIN orders o ON o.restaurant_id = r.restaurant_id
GROUP BY r.city
),


open_close_and_persent AS (

SELECT city,
    COUNT (*) AS count_all_rest,
    COUNT(CASE WHEN opening_date > TO_DATE('2022-02-02', 'YYYY-MM-DD') THEN 1 END) AS count_open_rest,
    COUNT(CASE WHEN opening_date <= TO_DATE('2022-02-02', 'YYYY-MM-DD') THEN 1 END) AS count_close_rest,
    ROUND(COUNT(CASE WHEN opening_date > TO_DATE('2022-02-02', 'YYYY-MM-DD') THEN 1 END) /
    (COUNT(CASE WHEN opening_date > TO_DATE('2022-02-02', 'YYYY-MM-DD') THEN 1 END) + COUNT(CASE WHEN opening_date <= TO_DATE('2022-02-02', 'YYYY-MM-DD') THEN 1 END)) * 100, 2) AS persent_open_rest

FROM restaurants
GROUP BY city),

-- Перекинул Первый и последний открытый рестораны в первый запрос
/*my_date AS (

SELECT city, MAX(opening_date) AS last_open, MIN(opening_date) AS first_open
FROM restaurants
GROUP BY city),*/

-- Объеденил 3 запроса в один через CASE
/*open_rest AS (
SELECT COUNT(name_restaraunt) AS opening, city
FROM restaurants
WHERE opening_date > TO_DATE('2022-02-02', 'YYYY-MM-DD')
GROUP BY city
),

close_rest AS (
SELECT city, COUNT(name_restaraunt) AS closing
FROM restaurants
WHERE opening_date < TO_DATE('2022-02-02', 'YYYY-MM-DD')
GROUP BY city
),

my_prosent AS (
SELECT ROUND((o.opening / (o.opening + c.closing)) * 100, 2) AS persent_rest, o.city
FROM open_rest o
JOIN close_rest c ON c.city = o.city
),*/

my_city AS (
SELECT DISTINCT city
FROM restaurants
)

SELECT myp.city,
    count_all_rest,
    --(COUNT(CASE WHEN ocap.opening_date > TO_DATE('2022-02-02', 'YYYY-MM-DD') THEN 1 END) + COUNT(CASE WHEN ocap.opening_date <= TO_DATE('2022-02-02', 'YYYY-MM-DD') THEN 1 END)) AS total_count_rest,
    count_open_rest,
    count_close_rest,
    first_open,
    last_open,
    persent_open_rest,
    avg_amount,
    max_amount,
    min_amount

FROM my_city myp
-- LEFT JOIN my_prosent mypros ON mypros.city = myp.city
LEFT JOIN my_amount myam ON myam.city = myp.city
LEFT JOIN open_close_and_persent ocap ON ocap.city = myp.city
-- LEFT JOIN open_rest myopen ON myopen.city = myp.city
-- LEFT JOIN close_rest myclose ON myclose.city = myp.city
-- LEFT JOIN my_date myd ON myd.city = myp.city



----------------------ИТОГО


WITH my_amount AS(

SELECT r.city,
    ROUND(AVG(total_amount), 2) AS avg_amount,
    ROUND(MAX(total_amount), 2) AS max_amount,
    ROUND(MIN(total_amount), 2) AS min_amount,
    MAX(opening_date) AS last_open,
    MIN(opening_date) AS first_open

FROM restaurants r
JOIN orders o ON o.restaurant_id = r.restaurant_id
GROUP BY r.city
),


open_close_and_persent AS (

SELECT city,
    COUNT (*) AS count_all_rest,
    COUNT(CASE WHEN opening_date > TO_DATE('2022-02-02', 'YYYY-MM-DD') THEN 1 END) AS count_open_rest,
    COUNT(CASE WHEN opening_date <= TO_DATE('2022-02-02', 'YYYY-MM-DD') THEN 1 END) AS count_close_rest,
    ROUND(COUNT(CASE WHEN opening_date > TO_DATE('2022-02-02', 'YYYY-MM-DD') THEN 1 END) / COUNT(*) * 100, 2) AS persent_open_rest
    --(COUNT(CASE WHEN opening_date > TO_DATE('2022-02-02', 'YYYY-MM-DD') THEN 1 END) + COUNT(CASE WHEN opening_date <= TO_DATE('2022-02-02', 'YYYY-MM-DD') THEN 1 END)) * 100, 2) AS persent_open_rest

FROM restaurants
GROUP BY city),

my_city AS (
SELECT DISTINCT city
FROM restaurants
)

SELECT myp.city,
    count_all_rest,
    count_open_rest,
    count_close_rest,
    first_open,
    last_open,
    persent_open_rest,
    avg_amount,
    max_amount,
    min_amount

FROM my_city myp
LEFT JOIN my_amount myam ON myam.city = myp.city
LEFT JOIN open_close_and_persent ocap ON ocap.city = myp.city



-----------------------------ИЛИ все в 1 запросе

WITH my_amount AS(

SELECT r.city,
    ROUND(AVG(total_amount), 2) AS avg_amount,
    ROUND(MAX(total_amount), 2) AS max_amount,
    ROUND(MIN(total_amount), 2) AS min_amount,
    MAX(opening_date) AS last_open,
    MIN(opening_date) AS first_open,
    COUNT (*) AS count_all_rest,
    COUNT(CASE WHEN opening_date > TO_DATE('2022-02-02', 'YYYY-MM-DD') THEN 1 END) AS count_open_rest,
    COUNT(CASE WHEN opening_date <= TO_DATE('2022-02-02', 'YYYY-MM-DD') THEN 1 END) AS count_close_rest,
    ROUND(COUNT(CASE WHEN opening_date > TO_DATE('2022-02-02', 'YYYY-MM-DD') THEN 1 END) /
    (COUNT(CASE WHEN opening_date > TO_DATE('2022-02-02', 'YYYY-MM-DD') THEN 1 END) + COUNT(CASE WHEN opening_date <= TO_DATE('2022-02-02', 'YYYY-MM-DD') THEN 1 END)) * 100, 2) AS persent_open_rest

FROM restaurants r
JOIN orders o ON o.restaurant_id = r.restaurant_id
GROUP BY r.city
)

SELECT city,
    count_all_rest,
    count_open_rest,
    count_close_rest,
    first_open,
    last_open,
    persent_open_rest,
    avg_amount,
    max_amount,
    min_amount

FROM my_amount


SELECT /* +materialize*/ city, -- hint materialize (подсказки для оптимизатора) + виды физических JOIN
    COUNT (*) AS count_all_rest,
    COUNT(CASE WHEN opening_date > TO_DATE('2022-02-02', 'YYYY-MM-DD') THEN 1 END) AS count_open_rest,
    COUNT(CASE WHEN opening_date <= TO_DATE('2022-02-02', 'YYYY-MM-DD') THEN 1 END) AS count_close_rest,
    ROUND(COUNT(CASE WHEN opening_date > TO_DATE('2022-02-02', 'YYYY-MM-DD') THEN 1 END) / COUNT(*) * 100, 2) AS persent_open_rest
