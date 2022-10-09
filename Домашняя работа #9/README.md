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
+ после создания кластера #2 подписаться на таблицу db2.test2 из db1
  - CREATE SUBSCRIPTION sub_db1_test2_to_db2_test2     
CONNECTION 'host=localhost port=5433 user=postgres password=123 dbname=db2'     
PUBLICATION db2_test_pub WITH (copy_data = false);   
5) Манипуляции с кластером #2:    
Аналогичные симметричные действия как в п.4
6) Манипуляция с кластером #3:
+ Останавливаем кластер
  - sudo pg_ctlcluster 14 main3 stop
+ удаляем данные кластера
  - sudo rm -rf /var/lib/postgresql/14/main3
+ создаем бэкап кластера #1
  - sudo -u postgres pg_basebackup -p 5432 -R -D /var/lib/postgresql/14/main3
+ запускаем кластер
  - sudo pg_ctlcluster 14 main3 start
### Итог ###
1. Реализована логическая репликация между db1.test -> db2.test, db2.test2 -> db1.test2
2. Физическая репликация реализована только кластера #1, т.к. переносится весь кластер вместе с DDL
3. При записи в db1.test данные записываюся в db2.test и третий кластер db1.test
4. При записи в db2.test2 данные записываются в db1.test2


