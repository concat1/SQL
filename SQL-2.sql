
--ЗАДАНИЕ №1
--Выведите для каждого покупателя его адрес проживания, 
--город и страну проживания.

select concat (c.first_name,' ', c.last_name), a.address, c2.city , c3.country 
from customer c 
join address a on c.address_id = a.address_id 
join city c2 on a.city_id  = c2.city_id 
join country c3 on c2.country_id = c3.country_id 


--ЗАДАНИЕ №2
--С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.

select c.store_id ,count(c.email)
from customer c 
group by c.store_id 


--	Доработайте запрос и выведите только те магазины, 
--у которых количество покупателей больше 300-от.
--Для решения используйте фильтрацию по сгруппированным строкам 
--с использованием функции агрегации.

--исправлено

select c.store_id ,count(1)
from customer c 
group by c.store_id 
having count(1) > 300 


-- Доработайте запрос, добавив в него информацию о городе магазина, 
--а также фамилию и имя продавца, который работает в этом магазине.

--исправлено

select s.store_id , concat (s2.last_name, ' ' , s2.first_name) , c.city , count(c2.email) 
from city c 
join address a on c.city_id =a.city_id 
join store s on a.address_id = s.address_id 
join staff s2 on s.store_id  = s2.store_id 
join customer c2 on s2.store_id = c2.store_id 
group by s.store_id , concat (s2.last_name, ' ' , s2.first_name) , c.city 
having count(c2.email) > 300

--ЗАДАНИЕ №3
--Выведите ТОП-5 покупателей, 
--которые взяли в аренду за всё время наибольшее количество фильмов


select concat(c.last_name, ' ', c.first_name) , count (r.inventory_id) 
from customer c 
join rental r on c.customer_id = r.customer_id 
group by concat(c.last_name, ' ', c.first_name) 
order by count(r.return_date)  desc
limit 5


--ЗАДАНИЕ №4
--Посчитайте для каждого покупателя 4 аналитических показателя:
--  1. количество фильмов, которые он взял в аренду
--  2. общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа)
--  3. минимальное значение платежа за аренду фильма
--  4. максимальное значение платежа за аренду фильма

select concat(c.last_name, ' ', c.first_name) ,count(r.inventory_id) , sum (p.amount), min (p.amount), max(p.amount) 
from customer c 
join rental r on c.customer_id = r.customer_id 
join payment p on r.rental_id =p.rental_id 
group by concat(c.last_name, ' ', c.first_name), p.amount 



--ЗАДАНИЕ №5
--Используя данные из таблицы городов составьте одним запросом всевозможные пары городов таким образом,
 --чтобы в результате не было пар с одинаковыми названиями городов. 
 --Для решения необходимо использовать декартово произведение.
 
select c.city, c1.city 
from city c 
cross join city c1
where c.city != c1.city 




--ЗАДАНИЕ №6
--Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date)
--и дате возврата фильма (поле return_date), 
--вычислите для каждого покупателя среднее количество дней, за которые покупатель возвращает фильмы.

-- исправлено

select r.customer_id , avg (r.return_date :: date  - r.rental_date :: date)
from rental r
group by r.customer_id 
