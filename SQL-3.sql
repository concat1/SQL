 МОДУЛЬ 4. УГЛУБЛЕНИЕ В SQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--База данных: если подключение к облачной базе, то создаете новые таблицы в формате:
--таблица_фамилия, 
--если подключение к контейнеру или локальному серверу, то создаете новую схему и в ней создаете таблицы.

create schema dz_get

set search_path to dz_get


-- Спроектируйте базу данных для следующих сущностей:
-- 1. язык (в смысле английский, французский и тп)
-- 2. народность (в смысле славяне, англосаксы и тп)
-- 3. страны (в смысле Россия, Германия и тп)


--Правила следующие:
-- на одном языке может говорить несколько народностей
-- одна народность может входить в несколько стран
-- каждая страна может состоять из нескольких народностей

 
--Требования к таблицам-справочникам:
-- идентификатор сущности должен присваиваться автоинкрементом
-- наименования сущностей не должны содержать null значения и не должны допускаться дубликаты в названиях сущностей
 
--СОЗДАНИЕ ТАБЛИЦЫ ЯЗЫКИ
create table language  (
language_id serial  primary key,
language varchar(150) not null unique 
)



--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ ЯЗЫКИ
insert into language (language)
values ('Английский') , ('Французский')

--СОЗДАНИЕ ТАБЛИЦЫ НАРОДНОСТИ

create table nationalities ( 
nationalities_id serial  primary key,
nationalities varchar(150) not null unique 
)




--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ НАРОДНОСТИ
insert into nationalities (nationalities)
values ('Славяне') , ('Англосаксы')

--СОЗДАНИЕ ТАБЛИЦЫ СТРАНЫ
create table country ( 
country_id serial  primary key,
country varchar (150) not null unique
)



--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СТРАНЫ
insert into country (country)
values ('Россия') , ('Германия')

--СОЗДАНИЕ ПЕРВОЙ ТАБЛИЦЫ СО СВЯЗЯМИ
create table languages_in_countries (
language_id int not null references language (language_id),
country_id int not null references country(country_id),
primary key (language_id, country_id) 
)



--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СО СВЯЗЯМИ
insert into languages_in_countries (language_id , country_id)
values 
(1, 1),
(1 , 2)



--СОЗДАНИЕ ВТОРОЙ ТАБЛИЦЫ СО СВЯЗЯМИ
create table nationalities_in_countries (
nationalities_id int not null references nationalities (nationalities_id),
country_id int not null references country (country_id),
primary key (nationalities_id, country_id )
)


--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СО СВЯЗЯМИ
insert into nationalities_in_countries (nationalities_id , country_id)
values 
(1, 1),
(1, 2)
