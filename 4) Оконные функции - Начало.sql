CREATE TABLE my_schema_connection.restaurants AS
SELECT * FROM restaurants
WHERE 1 != 1

Select *
from customers


INSERT INTO customers
SELECT 999, 'aaa', 'kjsksnv@mail.ru', '8465161', DATE '99-06-01', SYSDATE, SYSDATE FROM DUAL

UPDATE customers
SET created_at = SYSDATE, update_at = SYSDATE

ALTER TABLE customers
ADD row_id number



CREATE TABLE CUSTOMERS_NEW (
  row_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  customer_id NUMBER,
  name_customer VARCHAR2(200) NOT NULL,
  email VARCHAR2(200),
  phone VARCHAR2(100),
  birthday DATE,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

CREATE OR REPLACE TRIGGER trg_customers_new_biud
BEFORE INSERT OR UPDATE ON CUSTOMERS
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    IF :NEW.row_id IS NULL THEN
      :NEW.row_id := customers_seq.NEXTVAL;
    END IF;
  END IF;
END;

DELETE
FROM customers

SELECT * FROM v$version

SELECT *
FROM customers

-- Проверки


DELETE FROM customers
WHERE row_id IN (WITH dublicates_id AS (SELECT customer_id
                      FROM customers
                      GROUP BY customer_id
                      HAVING COUNT(customer_id) > 1), -- Выделение дубликатов

rangir AS (SELECT customer_id, row_id, ROW_NUMBER() OVER(partition by customer_id order by customer_id ) AS RN FROM customers first_table WHERE EXISTS(SELECT 1 FROM dublicates_id second_table WHERE first_table.customer_id = second_table.customer_id)),

deliting AS (SELECT row_id FROM rangir WHERE RN != 1) -- Удаление дубликатов
SELECT * FROM deliting)

-- Скопировать схемы таблиц
-- Обязательно добавить ROW_ID (SEQ + Trigger)
-- Залить данные
-- CTE ДЗ






