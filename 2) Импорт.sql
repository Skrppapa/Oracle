Важное уточнение про ограничения!

Ограничения

есть 2 способа навесить ограничение на колонку (группу колонок):
- inline При создании таблицы прописать сразу за типом данных
- CONSTRAINT с явным указанием имени

CREATE TABLE employees (
  employee_id NUMBER PRIMARY KEY,
  name VARCHAR2(50) NOT NULL
);

Здесь employee_id — автоматически становится PRIMARY KEY, но имя ограничения генерируется Oracle автоматически (например: SYS_C0012345).

CREATE TABLE employees (
  employee_id NUMBER,
  name VARCHAR2(50) NOT NULL,
  CONSTRAINT emp_id_pk PRIMARY KEY (employee_id)
);

Здесь то же самое логически, но вы сами задаёте имя ограничения: emp_id_pk. Это удобно, если вы хотите в будущем ссылаться на это имя (например, чтобы удалить или отключить ограничение).



-- Создание таблицы EMPLOYEES

CREATE TABLE EMPLOYEES (
employee_id NUMBER,
CONSTRAINT employee_id_pk PRIMARY KEY (employee_id),
restaurant_id NUMBER(10),
personal_name VARCHAR2(200),
hire_date DATE,
work_position VARCHAR2(100),
created_at TIMESTAMP,
update_at TIMESTAMP)


SELECT * FROM EMPLOYEES

TRUNCATE TABLE EMPLOYEES

-- Тест добавления данных
INSERT INTO EMPLOYEES (employee_id, restaurant_id, personal_name, hire_date, work_position, created_at, update_at)
VALUES (1, 111, 'Igor', TO_DATE('2020-04-30', 'yyyy-mm-dd'), 'Chef', SYSDATE, SYSDATE)




-- Создание таблицы MENUS

CREATE TABLE MENUS (
menu_id	NUMBER,
CONSTRAINT menu_id_pk PRIMARY KEY (menu_id),
restaurant_id NUMBER(10),
item_name VARCHAR2(200),
price NUMBER(7, 2),
created_at TIMESTAMP,
update_at TIMESTAMP)

SELECT * FROM MENUS

TRUNCATE TABLE MENUS

-- Тест добавления данных
INSERT INTO MENUS (menu_id, restaurant_id, item_name, price, created_at, update_at)
VALUES (1, 111, 'Poor', 999.99, SYSDATE, SYSDATE)



-- Создание таблицы ORDERS

CREATE TABLE ORDERS (
order_id NUMBER,
CONSTRAINT order_id_pk PRIMARY KEY (order_id),
customer_id NUMBER(10),
restaurant_id NUMBER(10),
order_date DATE,
total_amount NUMBER(7, 2),
created_at TIMESTAMP,
update_at TIMESTAMP)


SELECT * FROM ORDERS

SELECT TO_CHAR(order_date, 'YYYY-MM-DD HH24:MI:SS') AS order_date FROM orders;

TRUNCATE TABLE ORDERS

-- Тест добавления данных
INSERT INTO ORDERS (order_id, customer_id, restaurant_id, order_date, total_amount, created_at, update_at)
VALUES (1, 111, 125, TO_DATE('2025-04-21 05:32:47', 'YYYY-MM-DD HH24:MI:SS'), 999.99, SYSDATE, SYSDATE)



-- Создание таблицы RESTAURANTS

CREATE TABLE RESTAURANTS (
restaurant_id NUMBER,
CONSTRAINT restaurant_id_pk PRIMARY KEY (restaurant_id),
name_restaraunt VARCHAR2(200),
city VARCHAR2(100),
opening_date DATE,
created_at TIMESTAMP,
update_at TIMESTAMP)

SELECT * FROM RESTAURANTS

TRUNCATE TABLE RESTAURANTS

-- Тест добавления данных
INSERT INTO RESTAURANTS (restaurant_id, name_restaraunt, city, opening_date, created_at, update_at)
VALUES (1, 'Mirazh', 'Moscow', TO_DATE('2025-04-21', 'YYYY-MM-DD'), SYSDATE, SYSDATE)




-- Создание таблицы REVIEWS

CREATE TABLE REVIEWS (
review_id NUMBER,
CONSTRAINT review_id_pk PRIMARY KEY (review_id),
customer_id NUMBER(10),
restaurant_id NUMBER(10),
rating NUMBER(1),
review_date	DATE,
comment_client VARCHAR2(1000),
created_at TIMESTAMP,
update_at TIMESTAMP)

SELECT * FROM REVIEWS

TRUNCATE TABLE REVIEWS

-- Изменение ограничения в типе данных NUMBER на 1
ALTER TABLE REVIEWS
MODIFY rating NUMBER(1)

-- Тест добавления данных
INSERT INTO REVIEWS (review_id, customer_id, restaurant_id, rating, review_date, comment_client, created_at, update_at)
VALUES (1, 777, 777, 4, TO_DATE('2025-04-21', 'YYYY-MM-DD'), 'Nice', SYSDATE, SYSDATE)
