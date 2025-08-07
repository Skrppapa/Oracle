
DROP TABLE my_data_mart1

CREATE TABLE my_data_mart1 (CITY VARCHAR2(200), COUNT_ALL_REST INTEGER, COUNT_OPEN_REST INTEGER, COUNT_CLOSE_REST INTEGER, FIRST_OPEN DATE, LAST_OPEN DATE, PERSENT_OPEN_REST NUMBER(32, 8), AVG_AMOUNT NUMBER(32, 8), MAX_AMOUNT NUMBER(32, 8), MIN_AMOUNT NUMBER(32, 8))

SELECT * FROM my_data_mart1

INSERT INTO my_data_mart1 (CITY, COUNT_ALL_REST, COUNT_OPEN_REST, COUNT_CLOSE_REST, FIRST_OPEN, LAST_OPEN, PERSENT_OPEN_REST, AVG_AMOUNT, MAX_AMOUNT, MIN_AMOUNT)

 -- Дроп
 -- создание
 -- заполнение
 -- логирование

 -- JOB Каждый день в 9:00

 -- Создаем таблицу для логов
CREATE TABLE logs
(log_id NUMBER,
log_date TIMESTAMP,
log_checks INTEGER,
log_data VARCHAR2(4000))

SELECT *
FROM logs

 CREATE OR REPLACE PROCEDURE for_data_mart1 IS
    log_id INTEGER;
    row_count INTEGER;
    log_checks INTEGER;
    after_select INTEGER;
    test_name VARCHAR2(200);

BEGIN

    DROP TABLE my_data_mart1;

    CREATE TABLE my_data_mart1 (CITY VARCHAR2(200), COUNT_ALL_REST INTEGER, COUNT_OPEN_REST INTEGER, COUNT_CLOSE_REST INTEGER, FIRST_OPEN DATE, LAST_OPEN DATE, PERSENT_OPEN_REST NUMBER(32, 8), AVG_AMOUNT NUMBER(32, 8), MAX_AMOUNT NUMBER(32, 8), MIN_AMOUNT NUMBER(32, 8));

    INSERT INTO my_data_mart1 (CITY, COUNT_ALL_REST, COUNT_OPEN_REST, COUNT_CLOSE_REST, FIRST_OPEN, LAST_OPEN, PERSENT_OPEN_REST, AVG_AMOUNT, MAX_AMOUNT, MIN_AMOUNT)
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

my_city AS (
SELECT DISTINCT city
FROM restaurants
)

SELECT myp.city,
    count_all_rest,
    count_open_rest,
    count_close_rest,
    coalesce(first_open, TO_DATE('1992-01-01', 'YYYY-MM-DD')) AS first_open,
    coalesce(last_open, TO_DATE('1992-01-01', 'YYYY-MM-DD')) AS last_open,
    persent_open_rest,
    coalesce(avg_amount, 0) AS avg_amount,
    coalesce(max_amount, 0) AS max_amount,
    coalesce(min_amount, 0) AS min_amount

FROM my_city myp
LEFT JOIN my_amount myam ON myam.city = myp.city
LEFT JOIN open_close_and_persent ocap ON ocap.city = myp.city
WHERE myp.city IS NOT NULL

    test_name := 'date_mart1_insert'; -- Имя проверки
    row_count := SQL%ROWCOUNT; -- Количество измененных строк

    IF row_count != 0 THEN -- Если были изменения
    log_checks := 1;
    ELSE
    log_checks := 0;
    END IF;

    SELECT MAX(log_id) INTO log_id FROM logs; -- Задавание ID

    IF log_id IS NULL THEN
    log_id := 1;
    END IF;

    INSERT INTO logs(log_id, log_date, log_checks, log_data) -- Вставка в таблицу logs
    VALUES(log_id + 1, SYSDATE, log_checks, test_name);

COMMIT;
END;

BEGIN data_mail;
END;

SELECT * FROM logs;
