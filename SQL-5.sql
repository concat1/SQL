--=============== МОДУЛЬ 6. POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Напишите SQL-запрос, который выводит всю информацию о фильмах 
--со специальным атрибутом "Behind the Scenes".
explain analyze --66.50
select film_id, title, special_features 
from film 
where special_features && array ['Behind the Scenes']




--ЗАДАНИЕ №2
--Напишите еще 2 варианта поиска фильмов с атрибутом "Behind the Scenes",
--используя другие функции или операторы языка SQL для поиска значения в массиве.
explain analyze --71.50
select film_id, title, special_features 
from film 
where special_features :: text ilike '%Behind the Scenes%'

explain analyze--1831.50
select film_id, title, array_agg (unnest)
from(
	select film_id, title, unnest (special_features)
	from film) t 
where unnest = 'Behind the Scenes'
group by film_id, title 

--ЗАДАНИЕ №3
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов 
--со специальным атрибутом "Behind the Scenes.

--Обязательное условие для выполнения задания: используйте запрос из задания 1, 
--помещенный в CTE. CTE необходимо использовать для решения задания.

explain analyze --718.71
with c1 as (
	select film_id, title, special_features 
	from film 
	where special_features && array ['Behind the Scenes'])
select r2.customer_id , count (r2.rental_id)
from c1
join inventory i on c1.film_id =  i.film_id
join rental r2  on r2.inventory_id = i.inventory_id
group by  r2.customer_id  

--ЗАДАНИЕ №4
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов
-- со специальным атрибутом "Behind the Scenes".

--Обязательное условие для выполнения задания: используйте запрос из задания 1,
--помещенный в подзапрос, который необходимо использовать для решения задания.

explain analyze -- 645.35
select r2.customer_id , count (r2.rental_id)
from (
	select film_id, title, special_features 
	from film 
	where special_features && array ['Behind the Scenes']) t
join inventory i on t.film_id =  i.film_id
join rental r2  on r2.inventory_id = i.inventory_id
group by  r2.customer_id 



--ЗАДАНИЕ №5
--Создайте материализованное представление с запросом из предыдущего задания
--и напишите запрос для обновления материализованного представления

create materialized view mt as 
	select r2.customer_id , count (r2.rental_id)
	from (
		select film_id, title, special_features 
		from film 
		where special_features && array ['Behind the Scenes']) t
	join inventory i on t.film_id =  i.film_id
	join rental r2  on r2.inventory_id = i.inventory_id
	group by  r2.customer_id
	
refresh materialized view mt


--ЗАДАНИЕ №6
--С помощью explain analyze проведите анализ скорости выполнения запросов
-- из предыдущих заданий и ответьте на вопросы:

--1. Каким оператором или функцией языка SQL, используемых при выполнении домашнего задания, 
--   поиск значения в массиве происходит быстрее

-- ОТВЕТ Самым быстрым по стоимости запрос оказался с задания №1 поскольку поиск осуществлялся непосредственно напрямую по массиву. 
-- К тому же данный запрос имеет  максимально простую конструкцию.

--2. какой вариант вычислений работает быстрее: 
--   с использованием CTE или с использованием подзапроса

--ОТВЕТ Самым быстрым вычеслительным запросом является запрос из задания №4.
