-- Задание №1 
--В каких городах больше одного аэропорта?

-- Для того чтоб найти необходимые данные нам необходимо обратить внимание на формат столбца city. 
--Это формат типа json. Для того чтоб извлечь необходимые нам данные в формате text используем ->>.
-- Прописываем условие чтоб значение было больше 1 .
select city  ->> 'en'
from airports_data  
group by city ->> 'en'
having count (airport_code) > 1


--Задание №2
--В каких аэропортах есть рейсы, выполняемые самолетом с максимальной дальностью перелета?
--Для выполнения этого задания потребуется присоединить нужные таблицы. После чего 
-- составляем подзапрос в котором прописываем то что ищем. 
		
select distinct (ad2.airport_name ->> 'en') , ad.model ->> 'en' ,  ad.range 
from aircrafts_data ad 
join flights f on ad.aircraft_code = f.aircraft_code 
join airports_data ad2  on f.arrival_airport  = ad2.airport_code 
where ad.range  =  (select max (range)
					from aircrafts_data a)  
--Задание №3
--Вывести 10 рейсов с максимальным временем задержки вылета
-- Для выполнения данного задания будет достаточно одной таблицы.
-- Прописываем разность фактического вылета от запланированного после
-- прописываем условие что не должно быть нулевых значений поскольку
-- в некоторые столбцы не заполнены. Группируем данные и прописываем лимит

select actual_departure - scheduled_departure , flight_id 
from flights 
	where actual_departure - scheduled_departure is not null 
	order by actual_departure - scheduled_departure
	desc limit 10

--Задание №4
--Были ли брони, по которым не были получены посадочные талоны?

--Для того чтоб подсчитать брони прописываем функцию count. Применяем join нужного формата.
-- Если обратить внимание то в присоединее второй таблицы мы используем присоединение типа right по причине того что нам нужны только данные.
--Прописываем условие что ищем только пустые значения. 

SELECT count  (bp.seat_no)
FROM ticket_flights tf
 	join flights_v fv on tf.flight_id = fv.flight_id 
 	right join boarding_passes bp on tf.flight_id = bp.flight_id and tf.ticket_no = bp.ticket_no 
 	where bp.seat_no is null
 
-- Задание 5
-- Найдите свободные места для каждого рейса, их % отношение к общему количеству мест в самолете.
--Добавьте столбец с накопительным итогом - суммарное накопление количества вывезенных пассажиров из каждого аэропорта на каждый день. 
--Т.е. в этом столбце должна отражаться накопительная сумма - сколько человек уже вылетело из данного аэропорта 
--на этом или более ранних рейсах за день.
 	
 -- Для выполнения данного задания необходимо искпользовать несколько СТЕ. Одно должно получать
 -- Колличество выданных посадочных талонов по месту. Другое колличество мест в самолёте. 	
 -- К 2 СТЕ присоединяем таблицу и для подсчёта используем оконную функцию.
with b as (
	select f.flight_id, f.flight_no, f.aircraft_code, f.departure_airport, f.scheduled_departure, f.actual_departure,
 			count(bp.boarding_no) boarded_count
	from flights f 
	join boarding_passes bp on bp.flight_id = f.flight_id 
	where f.actual_departure is not null
	group by f.flight_id ),
m as(
	select s.aircraft_code, count(s.seat_no) max_seats
	from seats s 
	group by s.aircraft_code)
select b.flight_no, b.departure_airport, b.scheduled_departure, b.actual_departure, b.boarded_count,
	m.max_seats - b.boarded_count free_seats, 
	round((m.max_seats - b.boarded_count) / m.max_seats :: dec, 2) * 100 free_seats_percent,
	sum(b.boarded_count) over (partition by (b.departure_airport, b.actual_departure::date) order by b.actual_departure) "Накопительно пассажиров"
from  b 
join  m on m.aircraft_code = b.aircraft_code

--Задание №6
--Найдите процентное соотношение перелетов по типам самолетов от общего количества.

--Используем подзапрос а в основном запросе используем группировку
select 
	a.model,
	count(f.flight_id),
	round(count(f.flight_id) /
		(select 
			count(f.flight_id)
		from flights f 
		where f.actual_departure is not null
		)::dec * 100, 4) "Процентное соотношение"
from aircrafts a 
join flights f on f.aircraft_code = a.aircraft_code 
where f.actual_departure is not null
group by a.model

--Задание №7
-- Были ли города, в которые можно  добраться бизнес - классом дешевле, чем эконом-классом в рамках перелета?

--  В CTE prices собираются стоимости билетов на рейс: максимальная для Эконома и минимальная для бизнеса.
--  Затем из него отбираются эти стоимости и группируются в одну строку по каждому аэропорту - это внешний
-- CTE eco_busi. Результаты фильтруются по сравнению полей b_min_amount и e_max_amount
-- Далее этот CTE джойнится с таблицами рейсов и аэропортов, чтобы достать из них города отправления и прибытия.
-- Судя по тому, что результат пустой, таких рейсов нет
 with eco_busi as (
	with s as(
		select  
			f.flight_id,
			case when tf.fare_conditions  = 'Business' then min(tf.amount) end b_min_amount,
			case when tf.fare_conditions  = 'Economy' then max(tf.amount) end e_max_amount
		from ticket_flights tf 
		join flights f on tf.flight_id = f.flight_id 
		group by 
			f.flight_id, tf.fare_conditions)
	select 
		s.flight_id,
		min(s.b_min_amount),
		max(s.e_max_amount)
	from s
		group by s.flight_id
	having min(s.b_min_amount) < max(s.e_max_amount)
	)
select 
	e.flight_id,
	a.city depatrure_city,
	a2.city arrival_city
from eco_busi e 
join flights f on e.flight_id = f.flight_id 
join airports a on f.departure_airport = a.airport_code
join airports a2 on f.arrival_airport = a2.airport_code


--Задание №8
--Между какими городами нет прямых рейсов?
 -- Для выполнения данного задания необходимо вычерсть результаты одной таблицы из другой. 
 -- Те данные которые остались и являются искомым результатом. 
 
   
 select a.city->> 'ru', b.city ->>'ru'
 from airports_data a
	cross join airports_data b 
	where a.city->> 'ru' <> b.city ->> 'ru'
		except 
select a.city ->> 'ru', b.city ->>'ru'
from airports_data a 
	inner join flights f on a.airport_code = f.departure_airport 
	inner join airports_data b on b.airport_code = f.arrival_airport
 
 
--Задание №9
--Вычислите расстояние между аэропортами, 
--связанными прямыми рейсами, сравните с допустимой максимальной дальностью перелетов  в самолетах, обслуживающих эти рейсы * --доработать

-- Для выполнения этого задания необходима правильная работа с json и корректная работа CASE. Так же для выполнения расчётов необходимо правильно
-- присоединить нужные таблицы. 


select distinct 
 	ad.airport_name ->> 'ru' "ИЗ",
 	ad2.airport_name ->> 'ru' "В",
 	ad3.range  "Дальность самолёта",
 	round((acos(sind(ad.coordinates[0]) * sind (ad2.coordinates [0]) + cosd (ad.coordinates [0]) *
 	cosd (ad2.coordinates [0]) * cosd (ad.coordinates[1] - ad2.coordinates[1])) *6371) :: dec , 2) "Расстояние",
case when  
	ad3.range < 
	acos(sind(ad.coordinates[0]) * sind (ad2.coordinates [0]) + cosd (ad.coordinates [0]) * 
	cosd (ad2.coordinates [0]) * cosd (ad.coordinates[1] - ad2.coordinates[1])) *6371
	then 'Нет!'
	else 'Да!'
	end "Долетит?"
from flights f
	join airports_data ad2 on f.departure_airport = ad2.airport_code
	join airports_data ad  on f.arrival_airport = ad.airport_code
	join aircrafts_data ad3 on f.aircraft_code = ad3.aircraft_code 