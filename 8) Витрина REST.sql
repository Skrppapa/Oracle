SELECT * FROM customers
SELECT * FROM employees
SELECT * FROM menus
SELECT * FROM orders
SELECT * FROM restaurants



CREATE OR REPLACE FUNCTION vozr
(birthday DATE
)

RETURN NUMBER IS
itog NUMBER;

BEGIN
itog := ROUND((SYSDATE - birthday) / 365, 2);
RETURN itog;
END;

SELECT vozr(birthday), birthday -- Вызов функции
FROM customers

--Обший
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

SELECT r.city, ROUND(AVG(total_amount), 2) AS avg_amount, ROUND(MAX(total_amount), 2) AS max_amount, ROUND(MIN(total_amount), 2) AS min_amount
FROM restaurants r
JOIN orders o ON o.restaurant_id = r.restaurant_id
GROUP BY r.city
),

my_date AS (

SELECT city, MAX(opening_date) AS last_open, MIN(opening_date) AS first_open
FROM restaurants
GROUP BY city),

my_open AS (
SELECT city, COUNT(name_restaraunt) AS opening
FROM restaurants
WHERE opening_date > TO_DATE('2022-02-02', 'YYYY-MM-DD')
GROUP BY city
),


my_close AS (
SELECT city, COUNT(name_restaraunt) AS closing
FROM restaurants
WHERE opening_date < TO_DATE('2022-02-02', 'YYYY-MM-DD')
GROUP BY city
),

my_prosent AS (
SELECT ROUND((o.opening / (o.opening + c.closing)) * 100, 2) AS my_pers, o.city
FROM my_open o
JOIN my_close c ON c.city = o.city
),

my_city AS (
SELECT DISTINct city
FROM restaurants
)

SELECT myp.city, (myopen.opening + myclose.closing), opening, closing, first_open, last_open, my_pers, avg_amount, max_amount, min_amount
FROM my_city myp
LEFT JOIN my_prosent mypros ON mypros.city = myp.city
LEFT JOIN my_amount myam ON myam.city = myp.city
LEFT JOIN my_date myd ON myd.city = myp.city
LEFT JOIN my_open myopen ON myopen.city = myp.city
LEFT JOIN my_close myclose ON myclose.city = myp.city





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






-- SELECT city, fir_open, lst_open
-- FROM (SELECT city, FIRST_VALUE(opening_date) OVER (PARTITION BY(city) ORDER BY opening_date) AS fir_open, LAST_VALUE(opening_date) OVER (PARTITION BY(city) ORDER BY opening_date) AS lst_open
--FROM restaurants
--)
--WHERE city = 'South Michaelmouth'
--GROUP BY city, fir_open, lst_open


--JOIN orders o ON o.restaurant_id = r.restaurant_id
-- WHERE opening_date < TO_DATE('2022-02-02', 'YYYY-MM-DD')
-- WHERE city = 'South Michaelmouth'




SELECT city, COUNT(*) OVER (PARTITION BY(city))
FROM restaurants
GROUP BY city

SELECT count(restaurant_id), city
FROM restaurants
GROUP BY city



SELECT *
FROM restaurants
WHERE city = 'South Michaelmouth'


open_restaurants -- Открытые рестораны
closed_restaurants -- Закрытые
first_opened_date -- Первый открытый ресторан в рамках города
last_opened_date -- Последний
percent_open -- % открытых

