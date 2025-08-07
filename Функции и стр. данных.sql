СОДЕРЖАНИЕ

- Ограничения CONSTRAINT (явное указание имени ограничения)
- TRUNC() — встроенная функция, которая усекает (обрезает) значения без округления.
- EXTRACT — SQL-функция, которая достаёт определённую часть даты/времени или интервала из значений
- TIMESTAMP — тип данных для хранения даты и времени с точностью до доли секунды.
- TO_DATE — функция преобразования строкового представления даты в значение типа DATE.
- ADD_MONTHS — функция, которая прибавляет или вычитает указанное количество месяцев к значению даты (DATE или TIMESTAMP).
- TRIM — функция для удаления символов (по умолчанию — пробелов) из начала, конца или обеих сторон строки.
- REGEXP_REPLACE — функция поиска и замены, которая использует регулярные выражения и позволяет заменять не просто точные строки, а любые совпадения по шаблону.
- COLLECT — агрегатная функция, которая собирает значения из нескольких строк в коллекцию (массив или множество).
- ARRAY_AGG — агрегатная функция, которая собирает значения из строк в SQL-массив (array value constructor) в одном выражении.
- LISTAGG — агрегатная функция, которая объединяет значения из нескольких строк в одну строку, вставляя между ними заданный разделитель.



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


-----------------------------------------

TRUNC() - это встроенная функция, которая усекает (обрезает) значения без округления.

TRUNC(date) - усекает дату до нужного уровня (год/месяц/день)
TRUNC(number) - обрезает дробную часть числа (аналог FLOOR)

Синтаксис: TRUNC(date [, format])

Примеры

SELECT TRUNC(SYSDATE, 'YYYY') FROM dual;  -- первый день года 00:00:00
SELECT TRUNC(SYSDATE, 'MM')   FROM dual;  -- первый день месяца 00:00:00

Важно знать!

- TRUNC() не округляет, а просто отбрасывает лишние части. Для округления нужно использовать ROUND().
- При работе с датами учитывается формат-маска — если не указать, обрежет до дня.
- При работе с TIMESTAMP результат — всё равно DATE (без фракций секунд), если не применять CAST() обратно.

-----------------------------------------

EXTRACT — это SQL-функция в Oracle, которая достаёт определённую часть даты/времени или интервала из значений

Синтаксис EXTRACT(part FROM {date | timestamp | interval})

- part — элемент, который нужно достать.
- date | timestamp | interval — выражение с датой, временем или интервалом.

Примеры:

SELECT EXTRACT(YEAR FROM DATE '2025-08-03') AS year_part FROM dual; -- 2025
SELECT EXTRACT(MONTH FROM SYSDATE) AS month_part FROM dual;         -- 8
SELECT EXTRACT(DAY FROM SYSTIMESTAMP) FROM dual;                    -- 3

SELECT EXTRACT(HOUR FROM SYSTIMESTAMP) AS hour_part FROM dual; -- 14
SELECT EXTRACT(MINUTE FROM SYSTIMESTAMP) FROM dual;            -- 35
SELECT EXTRACT(SECOND FROM SYSTIMESTAMP) FROM dual;            -- 45.123

-----------------------------------------

TIMESTAMP — это тип данных для хранения даты и времени с точностью до доли секунды.

DATE → хранит дату + время (точность до секунды)
TIMESTAMP → хранит дату + время (точность до 9 знаков в долях секунды)

Типы
TIMESTAMP - Дата и время с долями секунд, без часового пояса
TIMESTAMP WITH TIME ZONE - Дата и время с долями секунд и фиксированным часовым поясом (например, +03:00)
TIMESTAMP WITH LOCAL TIME ZONE - Хранит дату и время в базе в UTC, но при запросе конвертирует в локальный часовой пояс пользователя

Пример

CREATE TABLE events (
    id NUMBER,
    event_time TIMESTAMP(6)  -- точность до 6 знаков (микросекунды)
);

Важно знать!

- TIMESTAMP ≠ DATE. DATE автоматически конвертируется в TIMESTAMP при необходимости, но точность до долей секунды потеряется.
- Если сравнивать TIMESTAMP и DATE, Oracle приведёт DATE к TIMESTAMP(0) (обрежет доли секунд).

-----------------------------------------

TO_DATE — это функция преобразования строкового представления даты в значение типа DATE (или TIMESTAMP при явном приведении).

По сути нужен преобразовать текст → в дату (по указанной маске формата).

Примеры

SELECT TO_DATE('2025-08-03', 'YYYY-MM-DD') FROM dual;
SELECT TO_DATE('03-08-2025 14:35:45', 'DD-MM-YYYY HH24:MI:SS') FROM dual; -- Обязательно указывай маску!

-----------------------------------------

ADD_MONTHS — это функция Oracle, которая прибавляет или вычитает указанное количество месяцев к значению даты (DATE или TIMESTAMP).

Синтаксис

ADD_MONTHS(date, number_of_months)

- date — исходная дата (DATE или TIMESTAMP).
- number_of_months — целое или дробное число месяцев (дробная часть игнорируется).

Примеры:

SELECT ADD_MONTHS(DATE '2025-01-31', 1) FROM dual; -- 2025-02-28
SELECT ADD_MONTHS(DATE '2025-01-15', 2) FROM dual; -- 2025-03-15
SELECT ADD_MONTHS(DATE '2025-03-15', -1) FROM dual; -- 2025-02-15

Важно!

В Oracle нет встроенных функций вида ADD_HOURS, ADD_DAYS или ADD_YEARS по аналогии с ADD_MONTHS. Для этого используются арифметика с датами или интервалы.

-----------------------------------------

TRIM — это функция для удаления символов (по умолчанию — пробелов) из начала, конца или обеих сторон строки.

Синтаксис: TRIM( [ [LEADING | TRAILING | BOTH] [trim_character] FROM ] string )

- LEADING — удаляет символ(ы) с начала строки.
- TRAILING — удаляет символ(ы) с конца строки.
- BOTH (по умолчанию) — удаляет символ(ы) с обеих сторон.
- trim_character — символ, который нужно удалить (по умолчанию ' ' — пробел).
- string — исходная строка.

Если явно не указывать LEADING/TRAILING/BOTH и trim_character, то Oracle удаляет пробелы с обеих сторон строки:

SELECT TRIM('   Hello World   ') AS result FROM dual;
-- Результат: 'Hello World'

Удаление только вначале

SELECT TRIM(LEADING FROM '   Oracle') AS result FROM dual;
-- 'Oracle'

Удаление конкретного символа
SELECT TRIM(BOTH 'x' FROM 'xxxOraclexxx') AS result FROM dual;
-- 'Oracle'

Важно знать:

- Если string = NULL, то TRIM вернёт NULL.
- TRIM удаляет только символы, указанные в trim_character, и только с краёв строки. Если внутри строки есть такие символы, они не удаляются
- В trim_character можно указывать строку из нескольких символов, но они будут удаляться поштучно, а не как последовательность:

SELECT TRIM(BOTH 'ab' FROM 'aaabOraclebab') FROM dual;
-- 'Oracle'

-----------------------------------------

REGEXP_REPLACE — это функция поиска и замены в Oracle, которая использует регулярные выражения (POSIX и Perl-совместимый синтаксис).
Она позволяет заменять не просто точные строки, а любые совпадения по шаблону.

- REPLACE ищет буквальное совпадение.
- REGEXP_REPLACE ищет по регулярному выражению, что даёт гораздо больше возможностей.

Синтаксис:

REGEXP_REPLACE (
    source_string,
    pattern,
    replace_string [, position [, occurrence [, match_parameter ]]]
)

- source_string — исходная строка.
- pattern — регулярное выражение для поиска.
- replace_string — строка, на которую нужно заменить найденное.
- position (опционально) — с какой позиции в исходной строке начинать поиск (по умолчанию 1).
- occurrence (опционально) — какую по счёту найденную подстроку заменять:
  - 1 — только первое совпадение (по умолчанию).
  - 0 — все совпадения.
  - N — конкретное совпадение по счёту.
- match_parameter (опционально) — флаги модификации поиска:
  - 'i' — регистронезависимый поиск.
  - 'c' — учитывать регистр.
  - 'n' — . соответствует символу новой строки.
  - 'm' — многострочный режим (^ и $ действуют для каждой строки).
  - 'x' — игнорировать пробелы и комментарии в шаблоне.

Примеры:

Простая замена

SELECT REGEXP_REPLACE('Oracle Database', 'Database', 'DB') AS result
FROM dual;
-- 'Oracle DB'

Удаление всех цифр

SELECT REGEXP_REPLACE('User12345', '[0-9]', '') AS result
FROM dual;
-- 'User'

Работа с группами захвата
Можно использовать скобочные группы и ссылки на них (\1, \2 и т.д.) в replace_string.

SELECT REGEXP_REPLACE('2025-08-03', '([0-9]{4})-([0-9]{2})-([0-9]{2})', '\3.\2.\1') AS new_date
FROM dual;
-- '03.08.2025'

Важно знать:

- NULL → если любой аргумент (source_string, pattern, replace_string) равен NULL, результат будет NULL.
- Производительность — REGEXP_REPLACE тяжелее, чем REPLACE, особенно на больших объёмах.

-----------------------------------------

COLLECT — это агрегатная функция в Oracle, которая собирает значения из нескольких строк в коллекцию (массив или множество).

В отличие от обычных агрегатных функций (SUM, MAX и т.п.), COLLECT не выполняет арифметические операции, а просто аккумулирует все ненулевые значения в одну коллекцию.

Синтаксис: COLLECT([DISTINCT] expression) [WITHIN GROUP (ORDER BY ...)]

Особенности:

- Возвращает коллекцию — это не обычный скалярный результат, а объект коллекции (nested table).
- NULL-значения игнорируются.
- Чтобы использовать результат, часто применяют:
  - CAST(... AS collection_type) — для преобразования в конкретный тип коллекции.
  - TABLE() — для развертывания коллекции в строки.

Пример:

-- Создаём тип коллекции
CREATE TYPE num_list AS TABLE OF NUMBER;

-- Пример использования
SELECT deptno,
       CAST(COLLECT(empno) AS num_list) AS employees
FROM   emp
GROUP  BY deptno;

-----------------------------------------

ARRAY_AGG — это агрегатная функция, появившаяся в Oracle 21c, которая собирает значения из строк в SQL-массив (array value constructor) в одном выражении.

! В отличие от COLLECT, который возвращает объект коллекции (nested table, VARRAY), ARRAY_AGG возвращает SQL-массив, совместимый со стандартом SQL:2016, и не требует заранее создавать типы коллекций в схеме.

Синтаксис:

ARRAY_AGG([DISTINCT] expression [NULL ON NULL | ABSENT ON NULL])
   [WITHIN GROUP (ORDER BY ...)]

- expression — столбец или выражение для агрегирования.
- DISTINCT — убирает дубликаты.
- NULL ON NULL (по умолчанию) — сохраняет NULL в массиве.
- ABSENT ON NULL — пропускает NULL-значения.
- WITHIN GROUP (ORDER BY ...) — сортировка элементов внутри массива.

Примеры:

SELECT deptno,
       ARRAY_AGG(empno) AS employees
FROM   emp
GROUP  BY deptno;

Вернёт одну строку на отдел, где employees — это SQL-массив:
[7369, 7499, 7521, ...]

С сортировкой

SELECT deptno,
       ARRAY_AGG(empno WITHIN GROUP (ORDER BY empno DESC)) AS employees
FROM emp
GROUP BY deptno;

С игнорированием NULL

SELECT deptno,
       ARRAY_AGG(sal ABSENT ON NULL) AS salaries
FROM emp
GROUP BY deptno;

-----------------------------------------

LISTAGG — это агрегатная функция в Oracle, которая объединяет значения из нескольких строк в одну строку, вставляя между ними заданный разделитель.

Применяется, когда нужно сгруппировать данные в один текстовый список.

Синтаксис:

LISTAGG ( [DISTINCT] expression [, delimiter] )
   WITHIN GROUP (ORDER BY order_by_expr)
   [ON OVERFLOW {ERROR | TRUNCATE [delimiter] [WITHOUT COUNT]}]

-expression — выражение или столбец, значения которого нужно объединить.
-delimiter — разделитель (по умолчанию нет разделителя).
-WITHIN GROUP (ORDER BY …) — обязательный блок, задаёт порядок элементов в строке.
-DISTINCT (с Oracle 19c) — убирает дубликаты.
-ON OVERFLOW (с Oracle 12.2) — управление поведением при превышении лимита длины строки.

Лимиты:

- В SQL до Oracle 12.1 результат ограничен VARCHAR2(4000) (SQL-контекст) или VARCHAR2(32767) (PL/SQL).
- С Oracle 12.2 можно:
  - Выдать ошибку (ON OVERFLOW ERROR — поведение по умолчанию).
  - Обрезать (ON OVERFLOW TRUNCATE).


Примеры:

SELECT deptno,
       LISTAGG(ename, ', ')
         WITHIN GROUP (ORDER BY ename) AS employees
FROM emp
GROUP BY deptno;

Вывод:
DEPTNO | EMPLOYEES
-------+--------------------------
10     | CLARK, KING, MILLER
20     | ADAMS, FORD, JONES, ...

Без дубликатов

SELECT deptno,
       LISTAGG(DISTINCT job, ', ')
         WITHIN GROUP (ORDER BY job) AS jobs
FROM emp
GROUP BY deptno;

Контроль переполнения

SELECT deptno,
       LISTAGG(ename, ', ')
         WITHIN GROUP (ORDER BY ename)
         ON OVERFLOW TRUNCATE '...' AS employees
FROM emp
GROUP BY deptno;

Важно знать

- NULL значения игнорируются, то есть они не добавляются в итоговую строку.
- DISTINCT в LISTAGG появился только в Oracle 19c.
- При сортировке внутри WITHIN GROUP можно использовать несколько столбцов.
- LISTAGG может быть медленным на больших объёмах, иногда лучше использовать XMLAGG или JSON_ARRAYAGG для больших строк.

-----------------------------------------

