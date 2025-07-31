SELECT * FROM customers
SELECT * FROM employees
SELECT * FROM menus
SELECT * FROM orders
SELECT * FROM restaurants


-- Функция - определяет возраст в годах
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


CREATE OR REPLACE TYPE my_schema.item_array AS table OF VARCHAR2(2000) -- Новый тип данных

-- Функция выводит названия Меню по id
CREATE OR REPLACE FUNCTION id_corr
(menu_id_my NUMBER
)
RETURN item_array PIPELINED IS

BEGIN
FOR i IN (SELECT item_name FROM menus WHERE menu_id = menu_id_my) LOOP pipe ROW (i.item_name);
END LOOP;
RETURN;
END;

SELECT *
FROM TABLE
(id_corr(757))

INSERT INTO menus (MENU_ID, RESTAURANT_ID, ITEM_NAME, PRICE, CREATED_AT, UPDATE_AT)
VALUES (757, 125, 'MyRest', 57.25, NULL, NULL)


SELECT CAST(COLLECT(item_name) AS item_array) FROM menus WHERE menu_id = 757

-- COLLECT Почитать
-- ARRAY_AGG Почитать!!!
-- LISTAGG ПОЧИТАТЬ!!!

-- Функция выводит имя и должность в одной строке
CREATE OR REPLACE FUNCTION my_func111
(personal_name IN VARCHAR2,
work_position IN VARCHAR2
)

RETURN VARCHAR2 IS

BEGIN
RETURN personal_name || ' ' || work_position; -- Простая конкатенация
END;


SELECT my_func111(personal_name, work_position)
FROM employees




-- Добавили функции, Для них обязательно нужны алиасы! Алиасы нужны для всего кроме названия колонки!

SELECT o.ORDER_ID, o.CUSTOMER_ID, o.RESTAURANT_ID, m.MENU_ID, e.EMPLOYEE_ID, o.ORDER_DATE, o.TOTAL_AMOUNT,
r.NAME_RESTARAUNT, r.CITY, r.OPENING_DATE,
m.ITEM_NAME, m.PRICE,
c.NAME_CUSTOMER, c.EMAIL, c.PHONE, c.BIRTHDAY,
e.PERSONAL_NAME, e.HIRE_DATE, e.WORK_POSITION,
vozr(c.BIRTHDAY), my_func111(e.PERSONAL_NAME, e.WORK_POSITION)
FROM orders o
JOIN restaurants r ON r.RESTAURANT_ID = o.RESTAURANT_ID
JOIN menus m ON m.RESTAURANT_ID = o.RESTAURANT_ID
JOIN customers c ON c.customer_id = o.customer_id
JOIN employees e ON e.RESTAURANT_ID = o.RESTAURANT_ID

CREATE VIEW my_view AS -- Сделали view

SELECT o.ORDER_ID, o.CUSTOMER_ID, o.RESTAURANT_ID, m.MENU_ID, e.EMPLOYEE_ID, o.ORDER_DATE, o.TOTAL_AMOUNT,
r.NAME_RESTARAUNT, r.CITY, r.OPENING_DATE,
m.ITEM_NAME, m.PRICE,
c.NAME_CUSTOMER, c.EMAIL, c.PHONE, c.BIRTHDAY,
e.PERSONAL_NAME, e.HIRE_DATE, e.WORK_POSITION,
vozr(c.BIRTHDAY) AS func_vozr, my_func111(e.PERSONAL_NAME, e.WORK_POSITION) AS func_func111
FROM orders o
JOIN restaurants r ON r.RESTAURANT_ID = o.RESTAURANT_ID
JOIN menus m ON m.RESTAURANT_ID = o.RESTAURANT_ID
JOIN customers c ON c.customer_id = o.customer_id
JOIN employees e ON e.RESTAURANT_ID = o.RESTAURANT_ID

SELECT * -- veiw (в том числе есть функции) По сути название для таблицы
FROM my_view
