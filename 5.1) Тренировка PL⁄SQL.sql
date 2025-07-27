SELECT * FROM customers
SELECT * FROM employees
SELECT * FROM menus
SELECT * FROM orders
SELECT * FROM restaurants

-- Процедура очистки от лишних символов в колоке phone
CREATE OR REPLACE PROCEDURE data_space IS
    --ve_date TIMESTAMP;
    log_id INTEGER;
    row_count INTEGER;
    log_checks INTEGER;
    after_select INTEGER;
    test_name VARCHAR2(200);

BEGIN

    test_name := 'date_phone_number'; -- Имя проверки

    -- Удаляем все символы кроме цифр и + из колонки phone
    UPDATE customers
    SET phone = REGEXP_REPLACE(phone, '[^0-9+]', '')
    WHERE REGEXP_LIKE(phone, '[^0-9+]');

    -- REGEXP_REPLACE - Функция для выборочного удаления использующая регулярные выражения
    -- REGEXP_REPLACE(колонка с которой работаем, что нужно заменить, на что нужно заменить)
    -- Символ ^ - все кроме
    -- [] - набор символов, 0-9 диапазон, + просто там же

    -- Здесь обязательно нужна строка WHERE REGEXP_LIKE(phone, '[^0-9+]');
    -- Даже если в таблице нечего менять при выполнении UPDATE в котором есть REGEXP_REPLACE - он считается успешным и не будет = 0
    -- Через WHERE мы фильтруем - и применяем UPDATE только когда такие строки есть

    row_count := SQL%ROWCOUNT; -- Количество измененных строк

    IF row_count != 0 THEN
    log_checks := 1;
    ELSE
    log_checks := 0;
    END IF;

    SELECT MAX(log_id) INTO log_id FROM logs;

    IF log_id IS NULL THEN
    log_id := 1;
    END IF;

    -- ve_date := SYSDATE; -- Берем текущее время для таблицы logs

    INSERT INTO logs(log_id, log_date, log_checks, log_data)
    VALUES(log_id + 1, SYSDATE, log_checks, test_name);

COMMIT; -- COMMIT обязателен. Процедура это транзакция. Фиксируем изменения
END;

BEGIN data_space;
END;

SELECT * FROM logs;

INSERT INTO customers (customer_id, name_customer, email, phone, birthday)
VALUES(9999, 'test', 'test@mail.ru', '879-4564ddd78', to_date('1957-04-30', 'yyyy-mm-dd'))

SELECT * FROM customers
WHERE customer_id = 9999




-- Процедура очистки пробелов в начале и в конце mail
CREATE OR REPLACE PROCEDURE data_mail IS
    log_id INTEGER;
    row_count INTEGER;
    log_checks INTEGER;
    after_select INTEGER;
    test_name VARCHAR2(200);

BEGIN

    test_name := 'date_correct_mail'; -- Имя проверки

    -- Убираем пробелы в начале и в конце
    UPDATE customers
    SET email = TRIM(email)
    WHERE email LIKE ' %' OR email LIKE '% ';

    -- TRIM - функция для удвления пробелов. TRIM(колонка) - удалит все пробелы в начале и в конце
    -- Добавим WHERE. Даже если строка не содержит пробелов, TRIM все равно посчитает ее логически затронутой, следовательно SQL%ROWCOUNT не будет равен 0

    row_count := SQL%ROWCOUNT; -- Количество измененных строк

    IF row_count != 0 THEN
    log_checks := 1;
    ELSE
    log_checks := 0;
    END IF;

    SELECT MAX(log_id) INTO log_id FROM logs;

    IF log_id IS NULL THEN
    log_id := 1;
    END IF;

    INSERT INTO logs(log_id, log_date, log_checks, log_data)
    VALUES(log_id + 1, SYSDATE, log_checks, test_name);

COMMIT;
END;

BEGIN data_mail;
END;

SELECT * FROM logs;


insert into CUSTOMERS (customer_id, name_customer, email, phone, birthday)
VALUES (8888, 'Paige Bennett', '    hnson@example.com', '312.647.9810x44866', to_date('1957-04-30', 'yyyy-mm-dd'))

SELECT * FROM customers
WHERE customer_id = 8888





-- Процедура стандартизации неизвестных позиций
CREATE OR REPLACE PROCEDURE data_position IS
    log_id INTEGER;
    row_count INTEGER;
    log_checks INTEGER;
    after_select INTEGER;
    test_name VARCHAR2(200);

BEGIN

    test_name := 'date_position'; -- Имя проверки

    -- Проверяем на соответствие позициям
    UPDATE employees
    SET work_position = 'Позиция неопределена'
    WHERE (work_position NOT IN ('Manager', 'Cleaner', 'Waiter', 'Chef') OR work_position IS NULL) AND work_position != 'Позиция неопределена';

    -- Здесь помимо условия WHERE отдельно нужно просписать IS NULL, поскольку NULL не выдает True или False - это отдельная структура.
    -- Так же отдельно прописываем AND work_position != 'Позиция неопределена', что бы не влиять на row_count := SQL%ROWCOUNT;

    row_count := SQL%ROWCOUNT; -- Количество измененных строк

    IF row_count != 0 THEN
    log_checks := 1;
    ELSE
    log_checks := 0;
    END IF;

    SELECT MAX(log_id) INTO log_id FROM logs;

    IF log_id IS NULL THEN
    log_id := 1;
    END IF;

    INSERT INTO logs(log_id, log_date, log_checks, log_data)
    VALUES(log_id + 1, SYSDATE, log_checks, test_name);

COMMIT;
END;

BEGIN data_position;
END;

SELECT * FROM logs;
