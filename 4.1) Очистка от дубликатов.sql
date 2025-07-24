-- Последовательность
-- Создаю колонку ROW_ID
-- Создаю SEQ
-- Применяю триггер
-- Заливаю данные
--------------------------------------------EMPLOYEES
truncate table employees
DROP SEQUENCE EMPLOYEES_SEQ

-- Создаем SEQ
create SEQUENCE EMPLOYEES_SEQ
start with 1
increment by 1
nocache
nocycle

-- Добавляем колонку row_id
ALTER TABLE employees
ADD row_id number


-- Заполняем колонки создания и обновления записи
UPDATE employees
SET created_at = SYSDATE, update_at = SYSDATE


-- Триггер для заполнения колонки row_id согласно SEQ
CREATE OR REPLACE TRIGGER trg_employees_new_biud
BEFORE INSERT OR UPDATE ON EMPLOYEES
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    IF :NEW.row_id IS NULL THEN
      :NEW.row_id := EMPLOYEES_SEQ.NEXTVAL;
    END IF;
  END IF;
END;

-- Заполняем строки с значением null (Ненужно)
UPDATE EMPLOYEES
SET ROW_ID = EMPLOYEES_SEQ.NEXTVAL
WHERE ROW_ID IS NULL;

SELECT * FROM employees


-- Проверка на уникальность колонки row_id (Необязательно)
SELECT row_id
FROM employees
GROUP BY row_id
HAVING COUNT(row_id) > 1

-- Проверка на уникальность колонки с id
SELECT employee_id
FROM employees
GROUP BY employee_id
HAVING COUNT(employee_id) > 1

-- CTE Для employees
WITH dublicates_id AS (SELECT employee_id
                      FROM employees
                      GROUP BY employee_id
                      HAVING COUNT(employee_id) > 1), -- Выделение дубликатов

rangir AS (SELECT employee_id, row_id, ROW_NUMBER() OVER(partition by employee_id order by employee_id ) AS RN FROM employees first_table WHERE EXISTS(SELECT 1 FROM dublicates_id second_table WHERE first_table.employee_id = second_table.employee_id)),
-- Ранжируем колонку ID с ID конкретной строки, здесь видно дубли на фоне всех ID
deliting AS (SELECT row_id FROM rangir WHERE RN != 1) -- Удаление дубликатов
SELECT * FROM deliting

-- Полный запрос на очистку дубликатов
DELETE FROM employees
WHERE row_id IN (WITH dublicates_id AS (SELECT employee_id
                      FROM employees
                      GROUP BY employee_id
                      HAVING COUNT(employee_id) > 1),

rangir AS (SELECT employee_id, row_id, ROW_NUMBER() OVER(partition by employee_id order by employee_id ) AS RN FROM employees first_table WHERE EXISTS(SELECT 1 FROM dublicates_id second_table WHERE first_table.employee_id = second_table.employee_id)),
deliting AS (SELECT row_id FROM rangir WHERE RN != 1)
SELECT * FROM deliting)


ROLLBACK


---------------------------------------------------------------MENUS

-- Заполняем колонки создания и обновления записи
UPDATE menus
SET created_at = SYSDATE, update_at = SYSDATE

-- Добавляем колонку row_id
ALTER TABLE menus
ADD row_id number

-- Создаем SEQ
create SEQUENCE MENUS_SEQ
start with 1
increment by 1
nocache
nocycle


-- Триггер для заполнения колонки row_id согласно SEQ
CREATE OR REPLACE TRIGGER trg_menus_new_biud
BEFORE INSERT OR UPDATE ON MENUS
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    IF :NEW.row_id IS NULL THEN
      :NEW.row_id := MENUS_SEQ.NEXTVAL;
    END IF;
  END IF;
END;

SELECT * FROM menus


-- Проверка на уникальность колонки row_id (Необязательно)
SELECT row_id
FROM menus
GROUP BY row_id
HAVING COUNT(row_id) > 1

-- Проверка на уникальность колонки с id
SELECT menu_id
FROM menus
GROUP BY menu_id
HAVING COUNT(menu_id) > 1

-- CTE Для menus
DELETE FROM menus
WHERE row_id IN (WITH dublicates_id AS (SELECT menu_id
                      FROM menus
                      GROUP BY menu_id
                      HAVING COUNT(menu_id) > 1), -- Выделение дубликатов

rangir AS (SELECT menu_id, row_id, ROW_NUMBER() OVER(partition by menu_id order by menu_id ) AS RN FROM menus first_table WHERE EXISTS(SELECT 1 FROM dublicates_id second_table WHERE first_table.menu_id = second_table.menu_id)),
-- Ранжируем колонку ID с ID конкретной строки, здесь видно дубли на фоне всех ID
deliting AS (SELECT row_id FROM rangir WHERE RN != 1) -- Удаление дубликатов
SELECT * FROM deliting)

ROLLBACK



-------------------------------------------------ORDERS

-- Добавляем колонку row_id
ALTER TABLE orders
ADD row_id number

-- Создаем SEQ
create SEQUENCE ORDERS_SEQ
start with 1
increment by 1
nocache
nocycle


-- Триггер для заполнения колонки row_id согласно SEQ
CREATE OR REPLACE TRIGGER trg_orders_new_biud
BEFORE INSERT OR UPDATE ON ORDERS
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    IF :NEW.row_id IS NULL THEN
      :NEW.row_id := ORDERS_SEQ.NEXTVAL;
    END IF;
  END IF;
END;

-- Здесь заливаем данные

SELECT * FROM orders

-- Заполняем колонки создания и обновления записи
UPDATE orders
SET created_at = SYSDATE, update_at = SYSDATE


-- Проверка на уникальность колонки row_id - Должна быть пустой
SELECT row_id
FROM menus
GROUP BY row_id
HAVING COUNT(row_id) > 1

-- Проверка на уникальность колонки с id - Конкретно в этой таблице 50 дубликатов
SELECT menu_id
FROM menus
GROUP BY menu_id
HAVING COUNT(menu_id) > 1

-- CTE Для orders
DELETE FROM orders
WHERE row_id IN (WITH dublicates_id AS (SELECT order_id
                      FROM orders
                      GROUP BY order_id
                      HAVING COUNT(order_id) > 1), -- Выделение дубликатов

rangir AS (SELECT order_id, row_id, ROW_NUMBER() OVER(partition by order_id order by order_id ) AS RN FROM orders first_table WHERE EXISTS(SELECT 1 FROM dublicates_id second_table WHERE first_table.order_id = second_table.order_id)),
-- Ранжируем колонку ID с ID конкретной строки, здесь видно дубли на фоне всех ID
deliting AS (SELECT row_id FROM rangir WHERE RN != 1) -- Удаление дубликатов
SELECT * FROM deliting)

ROLLBACK


-------------------------------------------------RESTAURANTS

-- Добавляем колонку row_id
ALTER TABLE restaurants
ADD row_id number

-- Создаем SEQ
create SEQUENCE RESTAURANTS_SEQ
start with 1
increment by 1
nocache
nocycle


-- Триггер для заполнения колонки row_id согласно SEQ
CREATE OR REPLACE TRIGGER trg_restaurants_new_biud
BEFORE INSERT OR UPDATE ON RESTAURANTS
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    IF :NEW.row_id IS NULL THEN
      :NEW.row_id := RESTAURANTS_SEQ.NEXTVAL;
    END IF;
  END IF;
END;

-- Здесь заливаем данные

SELECT * FROM restaurants

-- Заполняем колонки создания и обновления записи
UPDATE restaurants
SET created_at = SYSDATE, update_at = SYSDATE


-- Проверка на уникальность колонки row_id - Должна быть пустой
SELECT row_id
FROM restaurants
GROUP BY row_id
HAVING COUNT(row_id) > 1

-- Проверка на уникальность колонки с id - Конкретно в этой таблице 50 дубликатов
SELECT restaurant_id
FROM restaurants
GROUP BY restaurant_id
HAVING COUNT(restaurant_id) > 1

-- CTE Для restaurants
DELETE FROM restaurants
WHERE row_id IN (WITH dublicates_id AS (SELECT restaurant_id
                      FROM restaurants
                      GROUP BY restaurant_id
                      HAVING COUNT(restaurant_id) > 1), -- Выделение дубликатов

rangir AS (SELECT restaurant_id, row_id, ROW_NUMBER() OVER(partition by restaurant_id order by restaurant_id ) AS RN FROM restaurants first_table WHERE EXISTS(SELECT 1 FROM dublicates_id second_table WHERE first_table.restaurant_id = second_table.restaurant_id)),
-- Ранжируем колонку ID с ID конкретной строки, здесь видно дубли на фоне всех ID
deliting AS (SELECT row_id FROM rangir WHERE RN != 1) -- Удаление дубликатов
SELECT * FROM deliting)

ROLLBACK


-------------------------------------------------REVIEWS

-- Добавляем колонку row_id
ALTER TABLE reviews
ADD row_id number

-- Создаем SEQ
create SEQUENCE REVIEWS_SEQ
start with 1
increment by 1
nocache
nocycle


-- Триггер для заполнения колонки row_id согласно SEQ
CREATE OR REPLACE TRIGGER trg_reviews_new_biud
BEFORE INSERT OR UPDATE ON REVIEWS
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    IF :NEW.row_id IS NULL THEN
      :NEW.row_id := REVIEWS_SEQ.NEXTVAL;
    END IF;
  END IF;
END;

-- Здесь заливаем данные

SELECT * FROM reviews

-- Заполняем колонки создания и обновления записи
UPDATE reviews
SET created_at = SYSDATE, update_at = SYSDATE


-- Проверка на уникальность колонки row_id - Должна быть пустой
SELECT row_id
FROM reviews
GROUP BY row_id
HAVING COUNT(row_id) > 1

-- Проверка на уникальность колонки с id - Конкретно в этой таблице 50 дубликатов
SELECT review_id
FROM reviews
GROUP BY review_id
HAVING COUNT(review_id) > 1

-- CTE Для reviews
DELETE FROM reviews
WHERE row_id IN (WITH dublicates_id AS (SELECT review_id
                      FROM reviews
                      GROUP BY review_id
                      HAVING COUNT(review_id) > 1), -- Выделение дубликатов

rangir AS (SELECT review_id, row_id, ROW_NUMBER() OVER(partition by review_id order by review_id ) AS RN FROM reviews first_table WHERE EXISTS(SELECT 1 FROM dublicates_id second_table WHERE first_table.review_id = second_table.review_id)),
-- Ранжируем колонку ID с ID конкретной строки, здесь видно дубли на фоне всех ID
deliting AS (SELECT row_id FROM rangir WHERE RN != 1) -- Удаление дубликатов
SELECT * FROM deliting)

ROLLBACK
