SELECT * FROM customers
SELECT * FROM employees
SELECT * FROM menus
SELECT * FROM orders
SELECT * FROM restaurants
SELECT * FROM reviews


-- Задача 1. Составить запрос, который покажет рестораны, помеченные как закрытые, но имеющие положительную выручку.
-- Буду считать ресторан закрытым если в таблице restaurants колонка city = null
-- Выручка считается в таблице orders - это SUM(total_amount)

WITH rest_with_null_city AS (

SELECT restaurant_id, name_restaraunt FROM restaurants
WHERE city IS NULL
GROUP BY restaurant_id, name_restaraunt), -- Отобрали рестораны с city = null

total_cash AS(
SELECT restaurant_id, SUM(total_amount) AS total FROM orders
GROUP BY restaurant_id
HAVING SUM(total_amount) IS NOT NULL
) -- Вычислили суммарную выручку по всем ресторанам

SELECT rwnc.name_restaraunt, tot.total
FROM rest_with_null_city rwnc
JOIN total_cash tot ON tot.restaurant_id = rwnc.restaurant_id -- Подтянули из обеих таблиц наименование и вырочку ресторанов


-- Задача 2. Рассчитать среднюю выручку, количество ресторанов и минимальную дату открытия по каждому городу.

WITH cities AS(

SELECT city AS City, COUNT(name_restaraunt) AS Count_rest
FROM restaurants
WHERE city IS NOT NULL
GROUP BY city),-- Вытягиваем все уникальные города и количество ресторанов в них

middle_cash AS (

SELECT rest.city AS City2, ROUND(AVG(total_amount), 2) AS Mid_cash
FROM orders ord
JOIN restaurants rest ON rest.restaurant_id = ord.restaurant_id
WHERE city IS NOT NULL
GROUP BY rest.city
), -- Средняя выручка по городам

min_open_date AS (

SELECT city AS City3, MIN(opening_date) AS Min_date_open
FROM restaurants
WHERE city IS NOT NULL
GROUP BY city
)

SELECT cit.City, cit.Count_rest, mc.Mid_cash, modd.Min_date_open
FROM cities cit
JOIN middle_cash mc ON mc.City2 = cit.City
JOIN min_open_date modd ON modd.City3 = cit.City

-- Задача 3. Отобрать топ-5 ресторанов по выручке среди открытых заведений.

WITH open_rest AS (

SELECT restaurant_id, name_restaraunt FROM restaurants
WHERE city IS NOT NULL
GROUP BY restaurant_id, name_restaraunt), -- Отобрали все открыте рестораны

top_cash AS (
SELECT rest.restaurant_id, ROUND(SUM(total_amount), 2) AS Sum_cash
FROM orders ord
JOIN restaurants rest ON rest.restaurant_id = ord.restaurant_id
GROUP BY rest.restaurant_id) -- Суммарная выручка каждого ресторана

SELECT *
FROM(
SELECT orr.name_restaraunt, tcc.Sum_cash
FROM open_rest orr
JOIN top_cash tcc ON tcc.restaurant_id = orr.restaurant_id
WHERE tcc.Sum_cash IS NOT NULL
ORDER BY tcc.Sum_cash DESC)
WHERE ROWNUM <= 5

-- ROWNUM <= 5 Вместо LIMIT - КОМАНДЫ не ИДЕНТИЧНЫ!!!!
-- ROWNUM — это псевдоколонка, которую Oracle присваивает каждой строке, как только она извлекается из таблицы.
-- Номер присваивается сраузу после извлечение, поэтому применив к неотсортированным данным получим неожиданный результат
-- Выше я засунул основной селект в подзапрос, что бы применить ROWNUM к уже отсортированным данным

-- Задача 4. Выполнить анализ дубликатов по сочетанию restaurant_name, city и opened_date и вывести повторяющиеся группы.
-- Самое простое, отдельными запросами найти дубликаты по каждому пункту и свести в финалный вывод пересекающихся значений

WITH dubl_rest_name AS(

SELECT name_restaraunt
FROM restaurants
GROUP BY name_restaraunt
HAVING COUNT(name_restaraunt) > 1),

dubl_city AS(

SELECT city
FROM restaurants
GROUP BY city
HAVING COUNT(city) > 1),

dubl_open_date AS(

SELECT opening_date
FROM restaurants
GROUP BY opening_date
HAVING COUNT(opening_date) > 1)

SELECT name_restaraunt, city, opening_date
FROM restaurants r
WHERE
EXISTS
    (SELECT 1 FROM dubl_rest_name drn
    WHERE drn.name_restaraunt = r.name_restaraunt)

AND EXISTS
    (SELECT 1 FROM dubl_city dc
    WHERE dc.city = r.city)

AND EXISTS
   (SELECT 1 FROM dubl_open_date dod
    WHERE dod.opening_date = r.opening_date)

-- Задача 5. Вывести рестораны, у которых monthly_revenue превышает 1 миллион или меньше 100. Такие значения стоит проверить вручную.

SELECT r.restaurant_id, r.name_restaraunt, SUM(total_amount) AS dohod
FROM orders o
JOIN restaurants r ON r.restaurant_id = o.restaurant_id
GROUP BY r.restaurant_id, r.name_restaraunt
HAVING SUM(total_amount) < 100

-- Задача 6.Выбрать строки, где opened_date > SYSDATE. Это может быть ошибкой в данных.

SELECT *
FROM restaurants
WHERE opening_date > SYSDATE
