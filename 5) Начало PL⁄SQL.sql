CREATE OR REPLACE PROCEDURE data_quality
IS
    ve_date TIMESTAMP;
    log_id INTEGER;
    row_count integer;
    log_checks INTEGER;
    after_select INTEGER;
    test_name VARCHAR2(200);
BEGIN

    SELECT COUNT(*) INTO row_count FROM reviews;

        DELETE FROM reviews
    WHERE row_id IN (WITH dublicates_id AS (SELECT review_id
                          FROM reviews
                          GROUP BY review_id
                          HAVING COUNT(review_id) > 1), -- Выделение дубликатов

    rangir AS (SELECT review_id, row_id, ROW_NUMBER() OVER(partition by review_id order by review_id ) AS RN FROM reviews first_table WHERE EXISTS(SELECT 1 FROM dublicates_id second_table WHERE first_table.review_id = second_table.review_id)),
    -- Ранжируем колонку ID с ID конкретной строки, здесь видно дубли на фоне всех ID
    deliting AS (SELECT row_id FROM rangir WHERE RN != 1) -- Удаление дубликатов
    SELECT * FROM deliting);



    test_name := 'delete_reviews';

    SELECT COUNT(*) INTO after_select FROM reviews;


    IF row_count < after_select THEN
    log_checks := 1;
    ELSE
    log_checks := 0;
    END IF;


    SELECT MAX(log_id) INTO log_id FROM logs;

    IF log_id IS NULL THEN
    log_id := 1;
    END IF;

    ve_date := SYSDATE;

    INSERT INTO logs(log_id, log_date, log_checks, log_data)
    VALUES(log_id + 1, ve_date, log_checks, test_name);



COMMIT;
END;


CREATE TABLE logs
(log_id NUMBER,
log_date TIMESTAMP,
log_checks INTEGER,
log_data VARCHAR2(4000))

SELECT *
FROM logs

BEGIN data_quality;
END;

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


UPDATE reviews
SET rating = 0 WHERE rating IS NULL

UPDATE reviews
SET comment_client = 'No comment' WHERE comment_client IS NULL

UPDATE reviews
SET review_date = DATE '25-01-01' WHERE EXTRACT(YEAR FROM review_date) = 2025


-- Рейтинг с null на 0
-- Комментарий с Null на  0
-- Дата > 01.01.2025 на 01.01.2025


SELECT *
FROM reviews

-- Подпись что делает процедура и внутренние блоки
-- Придумать процедуры к другим таблицам

