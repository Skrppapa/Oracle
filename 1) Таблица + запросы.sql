-- Создание таблицы
create table CUSTOMERS
(customer_id NUMBER,
name_customer CHAR(200) NOT NULL,
email VARCHAR2(200),
phone VARCHAR2(100),
birthday DATE,
created_at TIMESTAMP, -- Дата создания и обновления берутся из системного времени
update_at TIMESTAMP)

select * from CUSTOMERS

truncate table CUSTOMERS -- Полная очистка таблицы (работает быстрее чем DELETE)

-- Запрос на поиск дубликатов по имени
select name_customer
from CUSTOMERS
GROUP BY name_customer
HAVING count(name_customer) > 1

-- Запрос на суммарный возраст birthday которых >= 50
-- trunc срезает лишние данные в виде секунд, минут и т.д.
select sum(round((trunc(sysdate) - birthday) / 365, 2))
from CUSTOMERS
where round((trunc(sysdate) - birthday) / 365, 2) >= 50


-- Запрос на вставку строки данных
insert into CUSTOMERS (customer_id, name_customer, email, phone, birthday, created_at, update_at)
VALUES (1, 'Paige Bennett', 'xxjohnson@example.@example.@example.@example.', '312.647.9810x44866', to_date('1957-04-30', 'yyyy-mm-dd'), sysdate, sysdate)

-- Запрос на удаление
DELETE from CUSTOMERS
WHERE customer_id = 1

-- Изменение самой таблицы (DDL)
ALTER TABLE CUSTOMERS
ADD constraint customer_id_pk
primary key (customer_id)


-- Создание SEQUENCE
create SEQUENCE CUSTOMERS_SEQ
start with 1
increment by 1
nocache
nocycle

-- Удаление SEQUENCE
drop SEQUENCE CUSTOMERS_SEQ
