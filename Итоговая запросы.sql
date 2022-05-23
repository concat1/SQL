-- ������� �1 
--� ����� ������� ������ ������ ���������?

-- ��� ���� ���� ����� ����������� ������ ��� ���������� �������� �������� �� ������ ������� city. 
--��� ������ ���� json. ��� ���� ���� ������� ����������� ��� ������ � ������� text ���������� ->>.
-- ����������� ������� ���� �������� ���� ������ 1 .
select city  ->> 'en'
from airports_data  
group by city ->> 'en'
having count (airport_code) > 1


--������� �2
--� ����� ���������� ���� �����, ����������� ��������� � ������������ ���������� ��������?
--��� ���������� ����� ������� ����������� ������������ ������ �������. ����� ���� 
-- ���������� ��������� � ������� ����������� �� ��� ����. 
		
select distinct (ad2.airport_name ->> 'en') , ad.model ->> 'en' ,  ad.range 
from aircrafts_data ad 
join flights f on ad.aircraft_code = f.aircraft_code 
join airports_data ad2  on f.arrival_airport  = ad2.airport_code 
where ad.range  =  (select max (range)
					from aircrafts_data a)  
--������� �3
--������� 10 ������ � ������������ �������� �������� ������
-- ��� ���������� ������� ������� ����� ���������� ����� �������.
-- ����������� �������� ������������ ������ �� ���������������� �����
-- ����������� ������� ��� �� ������ ���� ������� �������� ���������
-- � ��������� ������� �� ���������. ���������� ������ � ����������� �����

select actual_departure - scheduled_departure , flight_id 
from flights 
	where actual_departure - scheduled_departure is not null 
	order by actual_departure - scheduled_departure
	desc limit 10

--������� �4
--���� �� �����, �� ������� �� ���� �������� ���������� ������?

--��� ���� ���� ���������� ����� ����������� ������� count. ��������� join ������� �������.
-- ���� �������� �������� �� � ����������� ������ ������� �� ���������� ������������� ���� right �� ������� ���� ��� ��� ����� ������ ������.
--����������� ������� ��� ���� ������ ������ ��������. 

SELECT count  (bp.seat_no)
FROM ticket_flights tf
 	join flights_v fv on tf.flight_id = fv.flight_id 
 	right join boarding_passes bp on tf.flight_id = bp.flight_id and tf.ticket_no = bp.ticket_no 
 	where bp.seat_no is null
 
-- ������� 5
-- ������� ��������� ����� ��� ������� �����, �� % ��������� � ������ ���������� ���� � ��������.
--�������� ������� � ������������� ������ - ��������� ���������� ���������� ���������� ���������� �� ������� ��������� �� ������ ����. 
--�.�. � ���� ������� ������ ���������� ������������� ����� - ������� ������� ��� �������� �� ������� ��������� 
--�� ���� ��� ����� ������ ������ �� ����.
 	
 -- ��� ���������� ������� ������� ���������� ������������� ��������� ���. ���� ������ ��������
 -- ����������� �������� ���������� ������� �� �����. ������ ����������� ���� � �������. 	
 -- � 2 ��� ������������ ������� � ��� �������� ���������� ������� �������.
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
	sum(b.boarded_count) over (partition by (b.departure_airport, b.actual_departure::date) order by b.actual_departure) "������������ ����������"
from  b 
join  m on m.aircraft_code = b.aircraft_code

--������� �6
--������� ���������� ����������� ��������� �� ����� ��������� �� ������ ����������.

--���������� ��������� � � �������� ������� ���������� �����������
select 
	a.model,
	count(f.flight_id),
	round(count(f.flight_id) /
		(select 
			count(f.flight_id)
		from flights f 
		where f.actual_departure is not null
		)::dec * 100, 4) "���������� �����������"
from aircrafts a 
join flights f on f.aircraft_code = a.aircraft_code 
where f.actual_departure is not null
group by a.model

--������� �7
-- ���� �� ������, � ������� �����  ��������� ������ - ������� �������, ��� ������-������� � ������ ��������?

--  � CTE prices ���������� ��������� ������� �� ����: ������������ ��� ������� � ����������� ��� �������.
--  ����� �� ���� ���������� ��� ��������� � ������������ � ���� ������ �� ������� ��������� - ��� �������
-- CTE eco_busi. ���������� ����������� �� ��������� ����� b_min_amount � e_max_amount
-- ����� ���� CTE ��������� � ��������� ������ � ����������, ����� ������� �� ��� ������ ����������� � ��������.
-- ���� �� ����, ��� ��������� ������, ����� ������ ���
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


--������� �8
--����� ������ �������� ��� ������ ������?
 -- ��� ���������� ������� ������� ���������� �������� ���������� ����� ������� �� ������. 
 -- �� ������ ������� �������� � �������� ������� �����������. 
 
   
 select a.city->> 'ru', b.city ->>'ru'
 from airports_data a
	cross join airports_data b 
	where a.city->> 'ru' <> b.city ->> 'ru'
		except 
select a.city ->> 'ru', b.city ->>'ru'
from airports_data a 
	inner join flights f on a.airport_code = f.departure_airport 
	inner join airports_data b on b.airport_code = f.arrival_airport
 
 
--������� �9
--��������� ���������� ����� �����������, 
--���������� ������� �������, �������� � ���������� ������������ ���������� ���������  � ���������, ������������� ��� ����� * --����������

-- ��� ���������� ����� ������� ���������� ���������� ������ � json � ���������� ������ CASE. ��� �� ��� ���������� �������� ���������� ���������
-- ������������ ������ �������. 


select distinct 
 	ad.airport_name ->> 'ru' "��",
 	ad2.airport_name ->> 'ru' "�",
 	ad3.range  "��������� �������",
 	round((acos(sind(ad.coordinates[0]) * sind (ad2.coordinates [0]) + cosd (ad.coordinates [0]) *
 	cosd (ad2.coordinates [0]) * cosd (ad.coordinates[1] - ad2.coordinates[1])) *6371) :: dec , 2) "����������",
case when  
	ad3.range < 
	acos(sind(ad.coordinates[0]) * sind (ad2.coordinates [0]) + cosd (ad.coordinates [0]) * 
	cosd (ad2.coordinates [0]) * cosd (ad.coordinates[1] - ad2.coordinates[1])) *6371
	then '���!'
	else '��!'
	end "�������?"
from flights f
	join airports_data ad2 on f.departure_airport = ad2.airport_code
	join airports_data ad  on f.arrival_airport = ad.airport_code
	join aircrafts_data ad3 on f.aircraft_code = ad3.aircraft_code 