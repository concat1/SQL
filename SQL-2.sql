
--������� �1
--�������� ��� ������� ���������� ��� ����� ����������, 
--����� � ������ ����������.

select concat (c.first_name,' ', c.last_name), a.address, c2.city , c3.country 
from customer c 
join address a on c.address_id = a.address_id 
join city c2 on a.city_id  = c2.city_id 
join country c3 on c2.country_id = c3.country_id 


--������� �2
--� ������� SQL-������� ���������� ��� ������� �������� ���������� ��� �����������.

select c.store_id ,count(c.email)
from customer c 
group by c.store_id 


--	����������� ������ � �������� ������ �� ��������, 
--� ������� ���������� ����������� ������ 300-��.
--��� ������� ����������� ���������� �� ��������������� ������� 
--� �������������� ������� ���������.

--����������

select c.store_id ,count(1)
from customer c 
group by c.store_id 
having count(1) > 300 


-- ����������� ������, ������� � ���� ���������� � ������ ��������, 
--� ����� ������� � ��� ��������, ������� �������� � ���� ��������.

--����������

select s.store_id , concat (s2.last_name, ' ' , s2.first_name) , c.city , count(c2.email) 
from city c 
join address a on c.city_id =a.city_id 
join store s on a.address_id = s.address_id 
join staff s2 on s.store_id  = s2.store_id 
join customer c2 on s2.store_id = c2.store_id 
group by s.store_id , concat (s2.last_name, ' ' , s2.first_name) , c.city 
having count(c2.email) > 300

--������� �3
--�������� ���-5 �����������, 
--������� ����� � ������ �� �� ����� ���������� ���������� �������


select concat(c.last_name, ' ', c.first_name) , count (r.inventory_id) 
from customer c 
join rental r on c.customer_id = r.customer_id 
group by concat(c.last_name, ' ', c.first_name) 
order by count(r.return_date)  desc
limit 5


--������� �4
--���������� ��� ������� ���������� 4 ������������� ����������:
--  1. ���������� �������, ������� �� ���� � ������
--  2. ����� ��������� �������� �� ������ ���� ������� (�������� ��������� �� ������ �����)
--  3. ����������� �������� ������� �� ������ ������
--  4. ������������ �������� ������� �� ������ ������

select concat(c.last_name, ' ', c.first_name) ,count(r.inventory_id) , sum (p.amount), min (p.amount), max(p.amount) 
from customer c 
join rental r on c.customer_id = r.customer_id 
join payment p on r.rental_id =p.rental_id 
group by concat(c.last_name, ' ', c.first_name), p.amount 



--������� �5
--��������� ������ �� ������� ������� ��������� ����� �������� ������������ ���� ������� ����� �������,
 --����� � ���������� �� ���� ��� � ����������� ���������� �������. 
 --��� ������� ���������� ������������ ��������� ������������.
 
select c.city, c1.city 
from city c 
cross join city c1
where c.city != c1.city 




--������� �6
--��������� ������ �� ������� rental � ���� ������ ������ � ������ (���� rental_date)
--� ���� �������� ������ (���� return_date), 
--��������� ��� ������� ���������� ������� ���������� ����, �� ������� ���������� ���������� ������.

-- ����������

select r.customer_id , avg (r.return_date :: date  - r.rental_date :: date)
from rental r
group by r.customer_id 
