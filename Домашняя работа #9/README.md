### Общая информация ###
* Ссылка на GitHub: https://github.com/kirill098/otus_homewor  
* Ссылка на Yandex Cloud: https://console.cloud.yandex.ru/folders/b1gehjktlatslseel5bh/compute/instances  
* Права для пользователя ifti@yandex.ru выдал

### Порядок выполнения: ###

1) Создал кластер #1: имя main, port 5432, + б/д db1
2) Создал кластер #2: имя main2, port 5433, + б/д db2
3) Создал кластер #3: имя main3, port 5434, без дополнительной б/д
4) Манипуляции с кластером #1:    
+ установить параметр wal_level=logical 
  - alter system set wal_level=logical  
+ чтобы настройка применилась необходимо перезагрузить кластер 
  - sudo pg_ctlcluster 14 main restart       
+ т.к. взаимодействие происходит на одной ВМ между разными кластерами, то параметр listen_adresses=localhost (по умолчанию) оставляем без изменений  
+ задаем пароль для пользователя postgres(123)    
+ создаем таблицы: 
  - create table test(i int, name text);  
  - create table test2(i int, name text);
  - в обеих таблицах добавляем уникальный индекс на поле i
+ создаем публикацию на таблицу test
  - create publication db1_test_pub for table test;
+ после создания кластера #2 подписаться на таблицу test из db2
  - CREATE SUBSCRIPTION sub_db1_test2_to_db2_test2     
CONNECTION 'host=localhost port=5433 user=postgres password=123 dbname=db2'     
PUBLICATION db2_test_pub WITH (copy_data = false);   
5) Манипуляции с кластером #2:    
+ установить параметр wal_level=logical 
  - alter system set wal_level=logical  
+ чтобы настройка применилась необходимо перезагрузить кластер 
  - sudo pg_ctlcluster 14 main2 restart       
+ т.к. взаимодействие происходит на одной ВМ между разными кластерами, то параметр listen_adresses=localhost (по умолчанию) оставляем без изменений  
+ задаем пароль для пользователя postgres(123)    
+ создаем таблицы: 
  - create table test(i int, name text);  
  - create table test2(i int, name text);
  - в обеих таблицах добавляем уникальный индекс на поле i
+ создаем публикацию на таблицу test
  - create publication db2_test2_pub for table test2;
+ после создания кластера #1 подписаться на таблицу test из db1
  - CREATE SUBSCRIPTION sub_db2_test_to_db1_test     
CONNECTION 'host=localhost port=5433 user=postgres password=123 dbname=db2'     
PUBLICATION db2_test_pub WITH (copy_data = false);   
 
