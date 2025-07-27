-- Создаем таблицу для логов
CREATE TABLE logs
(log_id NUMBER,
log_date TIMESTAMP,
log_checks INTEGER,
log_data VARCHAR2(4000))

SELECT *
FROM logs

-- Процедура с проверкой на дубликаты
CREATE OR REPLACE PROCEDURE data_quality IS
    ve_date TIMESTAMP;
    log_id INTEGER;
    row_count INTEGER;
    log_checks INTEGER;
    after_select INTEGER;
    test_name VARCHAR2(200);

BEGIN

    SELECT COUNT(*) INTO row_count FROM reviews; -- Присваиваем количество записей в переменную ДО ПРОВЕРОК

    -- Проверка на дубликаты (Если CTE увидит дубликат - он удалит строку следовательно общее количесвто строк измениться

    DELETE FROM reviews
    WHERE row_id IN (WITH dublicates_id AS

    (SELECT review_id
    FROM reviews
    GROUP BY review_id
    HAVING COUNT(review_id) > 1), -- Выделение дубликатов

    rangir AS
    (SELECT review_id, row_id, ROW_NUMBER() OVER(partition by review_id order by review_id ) AS RN FROM reviews first_table WHERE EXISTS(SELECT 1 FROM dublicates_id second_table WHERE first_table.review_id = second_table.review_id)),

    -- Ранжируем колонку ID с ID конкретной строки, здесь видно дубли на фоне всех ID
    deliting AS
    (SELECT row_id FROM rangir WHERE RN != 1) -- Удаление дубликатов
    SELECT * FROM deliting);


    test_name := 'delete_reviews'; -- Присваиваем имя именно проверке на дубликаты. Далее внесем ее в таблицу логов

    SELECT COUNT(*) INTO after_select FROM reviews; -- Записываем количество строк уде после проверки

    -- Проверяем количество записей до и после проверки. В зависимости от результата присваиваем 0 или 1 в переменную log_checks  НЕКОРРЕКТНО!!! ПОМЕНЯТЬ НА >
    IF row_count < after_select THEN
    log_checks := 1;
    ELSE
    log_checks := 0;
    END IF;

    SELECT MAX(log_id) INTO log_id FROM logs; -- Присвоим log_id наибольший номер log_id

    IF log_id IS NULL THEN -- Если логов в таблице еще нет (В таком случае строкой выше мы присвоили NULL в log_id), присвоем log_id единицу
    log_id := 1;
    END IF;

    ve_date := SYSDATE; -- Берем текущее время для таблицы logs

    -- Делаем записи в таблицу logs
    INSERT INTO logs(log_id, log_date, log_checks, log_data)
    VALUES(log_id + 1, ve_date, log_checks, test_name);

COMMIT; -- COMMIT обязателен. Процедура это транзакция. Фиксируем изменения
END;

-- Команда запускает процедуру
BEGIN data_quality;
END;


-- Процедура с избавлением от NULL в колонке rating
CREATE OR REPLACE PROCEDURE data_rating
IS
    ve_date TIMESTAMP;
    log_id INTEGER;
    row_count integer;
    log_checks INTEGER;
    test_name VARCHAR2(200);

BEGIN

    UPDATE reviews
    SET rating = 0 WHERE rating IS NULL;

    test_name := 'check rating';

    row_count := SQL%ROWCOUNT;
    -- SQL%ROWCOUNT - это спеуиальная системная переменная. Показывает количество строк затронутое проверкой на NULL выше
    -- Более подробно - она показывает количество строк, затронутых последним SQL-оператором DML (то есть INSERT, UPDATE, DELETE, MERGE).

    IF row_count != 0 THEN
    log_checks := 1;
    ELSE
    log_checks := 0;
    END IF;

    ve_date := SYSDATE;

    SELECT MAX(log_id) INTO log_id FROM logs;

    IF log_id IS NULL THEN
    log_id := 1;
    END IF;

    INSERT INTO logs(log_id, log_date, log_checks, log_data)
    VALUES(log_id + 1, ve_date, log_checks, test_name);


 COMMIT;
END;

BEGIN data_rating;
END;


create or replace PROCEDURE data_comment
IS
    ve_date TIMESTAMP;
    log_id INTEGER;
    row_count integer;
    log_checks INTEGER;
    test_name VARCHAR2(200);

BEGIN

    UPDATE reviews
    SET comment_client = 'No comment' WHERE comment_client IS NULL;

    test_name := 'check comment';

    row_count := SQL%ROWCOUNT;

    IF row_count != 0 THEN
    log_checks := 1;
    ELSE
    log_checks := 0;
    END IF;

    ve_date := SYSDATE;

    SELECT MAX(log_id) INTO log_id FROM logs;

    IF log_id IS NULL THEN
    log_id := 1;
    END IF;

    INSERT INTO logs(log_id, log_date, log_checks, log_data)
    VALUES(log_id + 1, ve_date, log_checks, test_name);


COMMIT;
END;

BEGIN data_comment;
END;


-- Процедура с заменой даты комментария на 01.01.2025 в строках с датой старше
CREATE OR REPLACE PROCEDURE data_correct_date
IS
    ve_date TIMESTAMP;
    log_id INTEGER;
    row_count integer;
    log_checks INTEGER;
    test_name VARCHAR2(200);

BEGIN

    UPDATE reviews
    SET review_date = DATE '25-01-01' WHERE EXTRACT(YEAR FROM review_date) = 2025;

    test_name := 'check date';

    row_count := SQL%ROWCOUNT;

    IF row_count != 0 THEN
    log_checks := 1;
    ELSE
    log_checks := 0;
    END IF;

    ve_date := SYSDATE;

    SELECT MAX(log_id) INTO log_id FROM logs;

    IF log_id IS NULL THEN
    log_id := 1;
    END IF;

    INSERT INTO logs(log_id, log_date, log_checks, log_data)
    VALUES(log_id + 1, ve_date, log_checks, test_name);


COMMIT;
END;

BEGIN data_correct_date;
END;


SELECT *
FROM reviews
