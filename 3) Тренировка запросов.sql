-- Все рестораны в городе New Juan
select name_restaraunt
from restaurants
where city = 'New Juan'

-- Наибольшее количество ресторанов в городе по убыванию
select max(koll), city
from (select count(*) AS koll, city -- В под запросе очищаем от null в колонке city
     from restaurants
     WHERE city is NOT null
     GROUP BY city
     )
GROUP BY city, koll
ORDER BY koll DESC -- Группируем и сортируем по убыванию

-- Вся информация о ресторанах из города New Juan
select * from restaurants
where city in (select city from restaurants
              where city = 'New Juan')

-- Имена сотрудников которые приняты на работу после 13.04.2021
-- extract выделяет нужный элемент (год/месяц/день) из DATA
-- формат extract(day from hire_date) | На месте day - year или month или day затем from затем колонка из которой извлекаем
select PERSONAL_NAME from employees
where extract(year from hire_date) > 2021 AND extract(month from hire_date) > 4 AND extract(day from hire_date) > 13

-- Средний рейтинг
select avg(rating)
from (select rating, comment_client -- В подзапросе очищаем от null именно rating
     from reviews
     where rating is not null)
WHERE comment_client is not null -- В основном запросе очищаем от null комментарии

-- НИКОГДА так не делаем, в условии выдает True и сносит всю базу!
delete reviews
where 1 = 1

rollback -- Откатывает крайнюю транзакцию

-- Средний рейтинг напротив строки где comment null с группировкой
-- Конструкция как условный оператор
-- case when ...(условие)
-- then (тогда) - можно использовать агрегирующие функции
-- end
select case when comment_client is null
then avg(rating)
else 0
end as fff
from reviews
group by comment_client

-- Запрос на обновление колонки total_amount
update orders
set total_amount = total_amount * 1.1




select personal_name, name_restaraunt, r.update_at
from employees e join restaurants r on e.restaurant_id = r.restaurant_id
