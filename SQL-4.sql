--=============== ������ 5. ������ � POSTGRESQL =======================================
--= �������, ��� ���������� ���������� ������ ���������� � ������� ����� PUBLIC===========
SET search_path TO public;

--======== �������� ����� ==============

--������� �1
--�������� ������ � ������� payment � � ������� ������� ������� �������� ����������� ������� �������� ��������:
--+������������ ��� ������� �� 1 �� N �� ���� 
--+������������ ������� ��� ������� ����������, ���������� �������� ������ ���� �� ����
--���������� ����������� ������ ����� ���� �������� ��� ������� ����������, ���������� ������ 
--���� ������ �� ���� �������, � ����� �� ����� ������� �� ���������� � �������
--������������ ������� ��� ������� ���������� �� ��������� ������� �� ���������� � ������� 
--���, ����� ������� � ���������� ��������� ����� ���������� �������� ������.
--����� ��������� �� ������ ����� ��������� SQL-������, � ����� ���������� ��� ������� � ����� �������.

select customer_id ,payment_id , payment_date, rank () over (partition by customer_id order by payment_date)
from payment 

select customer_id ,payment_id , payment_date, row_number () over (partition by customer_id order by payment_date)
from payment 


select p.customer_id, p.payment_id , p.payment_date,
		sum (amount) over (partition by p.customer_id, p.payment_date ::date order by p.payment_date)
from payment p 

select customer_id, payment_id, payment_date , sum (amount) over (partition by customer_id order by payment_date desc), rank () over (partition by customer_id order by payment_date)
from payment 


--������� �2
--� ������� ������� ������� �������� ��� ������� ���������� ��������� ������� � ��������� 
--������� �� ���������� ������ �� ��������� �� ��������� 0.0 � ����������� �� ����.
select customer_id, payment_id, payment_date, amount,
   lag (amount, 1, 0.0) over ( partition by customer_id order by payment_date)
from payment 




--������� �3
--� ������� ������� ������� ����������, �� ������� ������ ��������� ������ ���������� ������ ��� ������ ��������.
select customer_id, payment_id, payment_date, amount,
   (lead (amount) over (partition by customer_id order by payment_date) - 
   lag (amount) over (partition by customer_id order by payment_date))
from payment 





--������� �4
--� ������� ������� ������� ��� ������� ���������� �������� ������ � ��� ��������� ������ ������.
select t.customer_id , t.payment_id , t.payment_date
from (
	select customer_id, payment_id, payment_date, row_number () over (partition by customer_id order by payment_date desc) 
	from  payment ) t
where row_number =1