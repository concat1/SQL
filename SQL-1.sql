--======== �������� ����� ==============

--������� �1
--�������� ���������� �������� �������� �� ������� �������

select distinct district 
from address 



--������� �2
--����������� ������ �� ����������� �������, ����� ������ ������� ������ �� �������, 
--�������� ������� ���������� �� "K" � ������������� �� "a", � �������� �� �������� ��������

select district 
from address
where district :: text like 'K%a' 
and 
district  :: text not like '% %'


--������� �3
--�������� �� ������� �������� �� ������ ������� ���������� �� ��������, ������� ����������� 
--� ���������� � 17 ����� 2007 ���� �� 19 ����� 2007 ���� ������������, 
--� ��������� ������� ��������� 1.00.
--������� ����� ������������� �� ���� �������.

select payment_id , payment_date , amount 
from payment 
where payment_date >= '2007-03-17' and  payment_date <='2007-03-20' 
and amount >=1.00
order by payment_date asc 


--������� �4
-- �������� ���������� � 10-�� ��������� �������� �� ������ �������.

select payment_id , payment_date , amount 
from payment
order by payment_date desc 
limit 10




--������� �5
--�������� ��������� ���������� �� �����������:
--  1. ������� � ��� (� ����� ������� ����� ������)
--  2. ����������� �����
--  3. ����� �������� ���� email
--  4. ���� ���������� ���������� ������ � ���������� (��� �������)
--������ ������� ������� ������������ �� ������� �����.

select first_name ,last_name, email , last_update 
from customer 

select first_name ||' '|| last_name, email , last_update 
from customer


select character_length(email) 
from customer 

select last_update as  date
from customer


select (first_name ||' '|| last_name) as "��� �������" , email as "�����" , last_update as "���� ����������" 
from customer



select (first_name ||' '|| last_name) as "��� �������" , email as "�����", character_length(email) as "����� email" , 
(last_update :: date) as "���� ����������"  
from customer  


--������� �6
--�������� ����� �������� �������� �����������, ����� ������� Kelly ��� Willie.
--��� ����� � ������� � ����� �� ������� �������� ������ ���� ���������� � ������� �������.

select upper (last_name), upper (first_name) 
from customer 
where first_name :: text like 'Kelly' 
or 
first_name:: text like 'Willie' 