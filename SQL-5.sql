--=============== ������ 6. POSTGRESQL =======================================
--= �������, ��� ���������� ���������� ������ ���������� � ������� ����� PUBLIC===========
SET search_path TO public;

--======== �������� ����� ==============

--������� �1
--�������� SQL-������, ������� ������� ��� ���������� � ������� 
--�� ����������� ��������� "Behind the Scenes".
explain analyze --66.50
select film_id, title, special_features 
from film 
where special_features && array ['Behind the Scenes']




--������� �2
--�������� ��� 2 �������� ������ ������� � ��������� "Behind the Scenes",
--��������� ������ ������� ��� ��������� ����� SQL ��� ������ �������� � �������.
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

--������� �3
--��� ������� ���������� ���������� ������� �� ���� � ������ ������� 
--�� ����������� ��������� "Behind the Scenes.

--������������ ������� ��� ���������� �������: ����������� ������ �� ������� 1, 
--���������� � CTE. CTE ���������� ������������ ��� ������� �������.

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

--������� �4
--��� ������� ���������� ���������� ������� �� ���� � ������ �������
-- �� ����������� ��������� "Behind the Scenes".

--������������ ������� ��� ���������� �������: ����������� ������ �� ������� 1,
--���������� � ���������, ������� ���������� ������������ ��� ������� �������.

explain analyze -- 645.35
select r2.customer_id , count (r2.rental_id)
from (
	select film_id, title, special_features 
	from film 
	where special_features && array ['Behind the Scenes']) t
join inventory i on t.film_id =  i.film_id
join rental r2  on r2.inventory_id = i.inventory_id
group by  r2.customer_id 



--������� �5
--�������� ����������������� ������������� � �������� �� ����������� �������
--� �������� ������ ��� ���������� ������������������ �������������

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


--������� �6
--� ������� explain analyze ��������� ������ �������� ���������� ��������
-- �� ���������� ������� � �������� �� �������:

--1. ����� ���������� ��� �������� ����� SQL, ������������ ��� ���������� ��������� �������, 
--   ����� �������� � ������� ���������� �������

-- ����� ����� ������� �� ��������� ������ �������� � ������� �1 ��������� ����� ������������� ��������������� �������� �� �������. 
-- � ���� �� ������ ������ �����  ����������� ������� �����������.

--2. ����� ������� ���������� �������� �������: 
--   � �������������� CTE ��� � �������������� ����������

--����� ����� ������� �������������� �������� �������� ������ �� ������� �4.
