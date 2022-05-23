 ������ 4. ���������� � SQL =======================================
--= �������, ��� ���������� ���������� ������ ���������� � ������� ����� PUBLIC===========
SET search_path TO public;

--======== �������� ����� ==============

--������� �1
--���� ������: ���� ����������� � �������� ����, �� �������� ����� ������� � �������:
--�������_�������, 
--���� ����������� � ���������� ��� ���������� �������, �� �������� ����� ����� � � ��� �������� �������.

create schema dz_get

set search_path to dz_get


-- ������������� ���� ������ ��� ��������� ���������:
-- 1. ���� (� ������ ����������, ����������� � ��)
-- 2. ���������� (� ������ �������, ���������� � ��)
-- 3. ������ (� ������ ������, �������� � ��)


--������� ���������:
-- �� ����� ����� ����� �������� ��������� �����������
-- ���� ���������� ����� ������� � ��������� �����
-- ������ ������ ����� �������� �� ���������� �����������

 
--���������� � ��������-������������:
-- ������������� �������� ������ ������������� ���������������
-- ������������ ��������� �� ������ ��������� null �������� � �� ������ ����������� ��������� � ��������� ���������
 
--�������� ������� �����
create table language  (
language_id serial  primary key,
language varchar(150) not null unique 
)



--�������� ������ � ������� �����
insert into language (language)
values ('����������') , ('�����������')

--�������� ������� ����������

create table nationalities ( 
nationalities_id serial  primary key,
nationalities varchar(150) not null unique 
)




--�������� ������ � ������� ����������
insert into nationalities (nationalities)
values ('�������') , ('����������')

--�������� ������� ������
create table country ( 
country_id serial  primary key,
country varchar (150) not null unique
)



--�������� ������ � ������� ������
insert into country (country)
values ('������') , ('��������')

--�������� ������ ������� �� �������
create table languages_in_countries (
language_id int not null references language (language_id),
country_id int not null references country(country_id),
primary key (language_id, country_id) 
)



--�������� ������ � ������� �� �������
insert into languages_in_countries (language_id , country_id)
values 
(1, 1),
(1 , 2)



--�������� ������ ������� �� �������
create table nationalities_in_countries (
nationalities_id int not null references nationalities (nationalities_id),
country_id int not null references country (country_id),
primary key (nationalities_id, country_id )
)


--�������� ������ � ������� �� �������
insert into nationalities_in_countries (nationalities_id , country_id)
values 
(1, 1),
(1, 2)
