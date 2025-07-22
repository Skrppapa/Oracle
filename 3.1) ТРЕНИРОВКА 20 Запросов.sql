-- 0. Добавить поле зарплата, внести значения: уборщик 1000, шефповар 5000, официант - 2000, менеджер - 4000
-- 1. Все рестораны где город не указан, но месяц открытия это июнь
-- 2. Обновить город в ресторанах, там где поле не заполнено на "Неизвестно"
-- 3. Сотрудники с зарплатой выше 3500, количество
-- 4. Средний рейтинг ресторанов
-- 5. Заказы за последний месяц, вывести
-- 6. Меню с ценами выше среднего, отсортировать по этому значению
-- 7. Клиенты без email, количество
-- 8. Рестораны, открытые в 2022 году, но старше  7 мая 2022 года
-- 9. Самый дорогой пункт меню в каждом ресторане
-- 10. Общая сумма заказов по ресторанам
-- 11. Вывести средний рейтинг ресторана в котором работает наибольшее количество шефповаров*
-- 12. Вывести количество позиций в меню каждого ресторана
-- 13. Вывести клиентов, сделавших более 3 заказов
-- 14. Вывести всех сотрудников по должностям, у которых имя "Lori"*
-- 15. Вывести все рестораны без отзывов, отсортировать по алфавиту
-- 16. Повысить зарплату шеф-поварам на 10%
-- 17. Обновить email клиента для клиентов без email на "1@mail.com"
-- 18. Увеличить цены заказов на 5% для ресторанов в Москве
-- 19. Удалить рестораны где отзывы ниже 2
-- 20. Удалить отзывы старше 3 лет


--0. Добавить поле зарплата, внести значения: уборщик 1000, шефповар 5000, официант - 2000, менеджер - 4000
ALTER TABLE employees
ADD cash NUMBER(10)

ALTER TABLE employees
DROP COLUMN zp_personal

UPDATE employees
SET cash = CASE WHEN work_position = 'Chef' THEN 5000
                WHEN work_position = 'Cleaner' THEN 1000
                WHEN work_position = 'Manager' THEN 4000
                WHEN work_position = 'Waiter' THEN 2000
                ELSE NULL
END;

-- 1. Все рестораны где город не указан, но месяц открытия это июнь
SELECT name_restaraunt
FROM restaurants
WHERE city is null AND extract(month from opening_date) = 6

-- Или

SELECT name_restaraunt
FROM (SELECT name_restaraunt, city, opening_date
     FROM restaurants
     WHERE city IS null)
WHERE extract(month from opening_date) = 6


-- 2. Обновить город в ресторанах, там где поле не заполнено на "Неизвестно"

UPDATE restaurants
set city = 'Неизвестно'
WHERE city IS null

-- 3. Сотрудники с зарплатой выше 3500, количество

SELECT COUNT(personal_name)
FROM employees
WHERE cash > 3500 AND cash IS NOT NULL

-- 4. Средний рейтинг ресторанов

SELECT AVG(rating)
FROM reviews
WHERE rating IS NOT NULL

-- 5. Заказы за последний месяц, вывести

SELECT *
FROM orders
WHERE order_date > (SELECT SYSDATE - 30 FROM DUAL)

-- 6. Меню с ценами выше среднего, отсортировать по этому значению

SELECT *
FROM menus
WHERE price > (SELECT AVG(price) FROM menus)
ORDER BY price DESC

-- 7. Клиенты без email, количество

SELECT COUNT(name_customer)
FROM customers
WHERE email IS NULL

-- 8. Рестораны, открытые в 2022 году, но старше  7 мая 2022 года

SELECT  name_restaraunt, opening_date
FROM  restaurants
WHERE opening_date > '07.05.2022' AND EXTRACT(YEAR FROM opening_date) = 2022

-- 9. Самый дорогой пункт меню в каждом ресторане ДОДЕЛАТЬ!

-- Что бы вытащить название без группировки приджойнили эту же таблицу к самой себе
SELECT pa.*, item_name
FROM
    (SELECT r.name_restaraunt, MAX(m.price) AS max_price
    FROM menus m
    JOIN restaurants r ON m.restaurant_id = r.restaurant_id
    GROUP BY name_restaraunt) pa
JOIN menus men ON max_price = men.price


SELECT m.restaurant_id, m.price, m.item_name
FROM menus m
WHERE m.price = (
    SELECT MAX(price)
    FROM menus
    WHERE restaurant_id = m.restaurant_id
)
ORDER BY m.restaurant_id DESC;

-- Всего 629 уникальных restaurant_id
SELECT restaurant_id
FROM menus
GROUP BY restaurant_id


select *
from menus
WHERE restaurant_id = 584 -- Самое большое количество позиций - 5

-- ID с количеством позиций по убыванию
SELECT restaurant_id, COUNT(item_name) AS koll
FROM menus
GROUP BY restaurant_id
Order by koll DESC


-- 10. Общая сумма заказов по ресторанам

SELECT o.restaurant_id, r.name_restaraunt, SUM(o.total_amount)
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
GROUP BY o.restaurant_id, r.name_restaraunt

-- 11. Вывести средний рейтинг ресторана в котором работает наибольшее количество шефповаров*

-- Здесь видно ID ресторана с наибольшим количеством Chef
SELECT restaurant_id, COUNT(work_position) as kkk
FROM employees
WHERE work_position = 'Chef'
GROUP BY restaurant_id
ORDER BY kkk DESC

-- Тоже самое но еще с названием ресторана


-- Используем CTE
SELECT * FROM
TABLE (DBMS_XPLAN.display)

EXPLAIN PLAN FOR
WITH max_count_chef AS (
    SELECT e.restaurant_id, r.name_restaraunt, COUNT(e.work_position) as kkk
    FROM employees e
    JOIN restaurants r ON e.restaurant_id = r.restaurant_id
    WHERE e.work_position = 'Chef'
    GROUP BY e.restaurant_id, r.name_restaraunt
    ORDER BY kkk DESC), first_chef AS (
                            SELECT restaurant_id, name_restaraunt
                            FROM max_count_chef
                            WHERE rownum = 1),

avg_rating AS (SELECT restaurant_id, AVG(rating) AS avg_sred
    FROM reviews
    GROUP BY restaurant_id)

SELECT f.name_restaraunt, avg_sred
FROM avg_rating ar
JOIN first_chef f ON ar.restaurant_id = f.restaurant_id

-- 12. Вывести количество позиций в меню каждого ресторана

-- Уникальных ресторанов 629
SELECT COUNT(COUNT(restaurant_id))
FROM menus
GROUP BY restaurant_id

SELECT m.restaurant_id, r.name_restaraunt, COUNT(m.item_name)
FROM menus m
JOIN restaurants r ON m.restaurant_id = r.restaurant_id
GROUP BY m.restaurant_id, r.name_restaraunt

-- 13. Вывести клиентов, сделавших более 3 заказов

SELECT name_customer, COUNT(order_id)
FROM  (
       SELECT o.customer_id, c.name_customer, o.order_id
       FROM orders o
       JOIN customers c ON o.customer_id = c.customer_id
       )
GROUP BY name_customer
HAVING COUNT(order_id) > 3;

-- 14. Вывести всех сотрудников по должностям, у которых имя "Lori"*

SELECT employee_id, work_position, personal_name
FROM employees
WHERE personal_name LIKE 'Lori%'

SELECT employee_id, work_position, personal_name
FROM employees
WHERE REGEXP_SUBSTR(personal_name, '[^ ]+', 1) = 'Lori'

REGEXP_LIKE 'Lori%' -- Почитать

-- 15. Вывести все рестораны без отзывов, отсортировать по алфавиту

SELECT res.name_restaraunt, COUNT(review_id)
FROM reviews r
JOIN restaurants res ON r.restaurant_id = res.restaurant_id
WHERE comment_client is null
GROUP BY res.name_restaraunt
ORDER BY res.name_restaraunt

-- 16. Повысить зарплату шеф-поварам на 10%

UPDATE employees
SET cash = cash * 1.1
WHERE work_position = 'Chef'

-- 17. Обновить email клиента для клиентов без email на "1@mail.com"

UPDATE customers
SET email = '1@mail.com'
WHERE email IS NULL

-- Проверка
SELECT *
FROM customers
WHERE email IS NULL

-- 18. Увеличить цены заказов на 5% для ресторанов в Москве

UPDATE orders -- Как вписать Join  в UPDATE?
SET total_amount = total_amount * 1.05
WHERE r.city = 'Hillbury'

UPDATE orders o -- Работает
SET o.total_amount = o.total_amount * 1.05
WHERE o.restaurant_id = (SELECT r.restaurant_id
                         FROM restaurants r
                         WHERE r.city = 'Hillbury')

-- Проверим
SELECT o.restaurant_id, r.name_restaraunt, o.total_amount
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
WHERE city = 'Hillbury'

-- Москвы нет
SELECT *
FROM restaurants
WHERE city LIKE'Mos%'

-- 19. Удалить рестораны где отзывы ниже 2 ВОПРОС!

SELECT COUNT(restaurant_id)
FROM restaurants -- 1000 ресторанов

DELETE restaurants
WHERE name_restaraunt = (SELECT DISTINCT r.name_restaraunt
                         FROM restaurants r
                         JOIN reviews rev ON r.restaurant_id = rev.restaurant_id
                         WHERE rev.rating < 2
                         ) --Внутренний запрос 147
                         -- Беру именно наименование ресторанов, что бы сравнить во внешнем запросе
                         -- Запрос выдает ошибку

-- ГПТ Написал такой запрос, по сути отличается только IN
-- EXISTS
SELECT *
FROM restaurants res
WHERE EXISTS (
    SELECT 1
    FROM restaurants r
    JOIN reviews rev ON r.restaurant_id = rev.restaurant_id
    WHERE rev.rating < 2 AND res.restaurant_id = r.restaurant_id
)


-- 20. Удалить отзывы старше 3 лет

SELECT COUNT(review_id)
FROM reviews -- До запроса 1000
             -- После 989

SELECT restaurant_id, review_date, ADD_MONTHS(sysdate, -36) AS kkk
FROM reviews
WHERE ADD_MONTHS(sysdate, -24) > review_date -- Старше 3 лет нет
                                             -- Старше 2 лет 11 штук


DELETE FROM reviews
WHERE ADD_MONTHS(sysdate, -24) > review_date

-- Функция ADD_MONTHS прибавляет или вычитает указанное количество месяцев
-- Синтаксис ADD_MONTHS(date, 4) Прибавляет к date 4 месяца


SELECT 1 FROM DUAL
MINUS
SELECT 3 FROM DUAL
UNION All
SELECT 3 FROM DUAL


SELECT restaurant_id FROM restaurants
UNION ALL
SELECT review_id FROM reviews

