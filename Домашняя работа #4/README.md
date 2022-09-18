### Общая информация ###
* Ссылка на GitHub: https://github.com/kirill098/otus_homewor  
* Ссылка на Yandex Cloud: https://console.cloud.yandex.ru/folders/b1gehjktlatslseel5bh/compute/instances  
* Права для пользователя ifti@yandex.ru выдал

### Порядок выполнения: ###

1. cоздайте новый кластер PostgresSQL 13 (на выбор - GCE, CloudSQL). 
Создал PostgreSQL 14 (Yandex cloud) 
2. зайдите в созданный кластер под пользователем postgres.   
Зашел по пользователем postgres   
3. создайте новую базу данных testdb. 
create database testdb;  
4. зайдите в созданную базу данных под пользователем postgres. 
\c testdb 
You are now connected to database "testdb" as user "postgres".    
5. создайте новую схему testnm. 
create schema testnm;  
6. создайте новую таблицу t1 с одной колонкой c1 типа integer. 
create table testnm.t1(c1 int);  
7. вставьте строку со значением c1=1. 
insert into testnm.t1 values(1);
INSERT 0 1
8. создайте новую роль readonly
create user readonly;
9. дайте новой роли право на подключение к базе данных testdb
grant connect on database testdb to readonly;
10. дайте новой роли право на использование схемы testnm
grant usage on schema testnm to readonly;
11. дайте новой роли право на select для всех таблиц схемы testnm
grant select on all tables in schema testnm to readonly;
12. создайте пользователя testread с паролем test123
create user testread password 'test123';
13. дайте роль readonly пользователю testread
grant readonly to testread;
14. зайдите под пользователем testread в базу данных testdb.     
Не получается, так как у пользователя нет прав на вход: "login".   
ALTER USER testread LOGIN;      
sudo -u postgres psql -U testread -h 127.0.0.1 -p 5433 -W -d testdb
15. сделайте select * from t1;
1
16. получилось? (могло если вы делали сами не по шпаргалке и не упустили один существенный момент про
который позже)
Нет, т.к. у пользователя testread есть права только на схему testnm базы tesdb. 
При создании таблица располагается в схеме по умолчанию (задается в search_path), если не указано иное.
17. напишите что именно произошло в тексте домашнего задания
18. у вас есть идеи почему? ведь права то дали?
19. посмотрите на список таблиц
\dt.   
Schema | Name | Type  |  Owner      
--------+------+-------+----------     
  public | t1   | table | postgres.   
20. подсказка в шпаргалке под пунктом 20
21. а почему так получилось с таблицей (если делали сами и без шпаргалки то может у вас все нормально)
Под пользователем postgres команда show search_path выдает список "$user", public. 
т.к. схема с именем postgres не создана, то все создаваемые таблицы будут сохраняться в public.
Кроме случаев когда при создании указана схема.
22. вернитесь в базу данных testdb под пользователем postgres
\c testdb postgres
23. удалите таблицу t1
drop table t1;
24. создайте ее заново но уже с явным указанием имени схемы testnm
create table testnm.t1(c1 int);
25. вставьте строку со значением c1=1
insert into testnm.t1 values(1);
26. зайдите под пользователем testread в базу данных testdb
\c testdb testread
27. сделайте select * from testnm.t1;
select * from testnm.t1;
28. получилось?
Нет, ERROR:  permission denied for table t1
29. есть идеи почему? если нет - смотрите шпаргалку
Права выдавались на таблицы, существовавшие на время выдачи прав. Таблица t1 пересоздавалась, на нее прав нет.
30. как сделать так чтобы такое больше не повторялось? если нет идей - смотрите шпаргалку
\c testdb postgres; 
ALTER default privileges in SCHEMA testnm grant SELECT on TABLEs to readonly; 
\c testdb testread;
31. сделайте select * from testnm.t1;
select * from testnm.t1;
32. получилось?
Да, т.к. права выдавались на схему с разрешением чтения всех таблиц в этой схеме на момент выдачи.
Необходимо заново дать права на SELECT;
32. получилось?
Да, получилось, т.к. права от readonly распростанились на пользвоателя testread.
33. ура!
34. теперь попробуйте выполнить команду create table t2(c1 integer); insert into t2 values (2)
выполнил
35. а как так? нам же никто прав на создание таблиц и insert в них под ролью readonly?
Это все потому что search_path указывает в первую очередь на схему public. А схема public создается в каждой базе данных по умолчанию. И grant на все действия в этой схеме дается роли public. А роль public добавляется всем новым пользователям. Соответсвенно каждый пользователь может по умолчанию создавать объекты в схеме public любой базы данных, ес-но если у него есть право на подключение к этой базе данных. Чтобы раз и навсегда забыть про роль public - а в продакшн базе данных про нее лучше забыть - выполните следующие действия 
37. есть идеи как убрать эти права? если нет - смотрите шпаргалку. 
\c testdb postgres;    
revoke CREATE on SCHEMA public FROM public;      
revoke all on DATABASE testdb FROM public;      
\c testdb testread;   
38. если вы справились сами то расскажите что сделали и почему, если смотрели шпаргалку - объясните что
сделали и почему выполнив указанные в ней команды
38. теперь попробуйте выполнить команду create table t3(c1 integer); insert into t2 values (2);
create table t3(c1 integer);  
Удалось создать и вставить данные, т.к. владелец таблицы пользователь testread.
