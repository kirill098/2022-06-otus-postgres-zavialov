### Общая информация ###
* Ссылка на GitHub: https://github.com/kirill098/otus_homewor  
* Ссылка на Yandex Cloud: https://console.cloud.yandex.ru/folders/b1gehjktlatslseel5bh/compute/instances  
* Права для пользователя ifti@yandex.ru выдал

### Порядок выполнения: ###

0) Подготовительный этап
- скачиваем тестовую б/д:  wget https://edu.postgrespro.com/demo-small-en.zip
- распаковываем полученный файл: unzip demo-small-en.zip
- импортируем в PostgreSQL: psql -U postgres demo < demo-small-en-20170815.sql

1) Рассматриваем таблицу flights
<img src="https://github.com/kirill098/otus_homework/blob/main/%D0%94%D0%BE%D0%BC%D0%B0%D1%88%D0%BD%D1%8F%D1%8F%20%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D0%B0%20%2311/data/image1.png">

2) Создаем талицу flights_range, секционированную по полю scheduled_departure:  
- create table flights_range(      
  flight_id integer not null,    
  flight_no character(6) not null,      
	scheduled_departure timestamp not null,       
	scheduled_arrival timestamp not null,   
	departure_airport character(3) not null,  
	arrival_airport character(3) not null,  
	status character varying(20) not null,  
	aircraft_code character(3) not null,  
	actual_departure timestamp,  
	actual_arrival timestamp    
  ) PARTITION BY RANGE(scheduled_departure);   
  
3) Определяем минимальное и максимальное значение поля scheduled_departure.   
  max = 2017-09-14 17:55:00+00     
  min = 2017-07-15 22:50:00+00     
  Создаем три партиции:    
  - create table flights_range_2017_07 partition of flights_range
  for values from (to_timestamp('01.07.2017','DD.MM.YYYY')) TO (to_timestamp('01.08.2017','DD.MM.YYYY'));

  - create table flights_range_2017_08 partition of flights_range
  for values from (to_timestamp('01.08.2017','DD.MM.YYYY')) TO (to_timestamp('01.09.2017','DD.MM.YYYY'));

  - create table flights_range_2017_09 partition of flights_range
  for values from (to_timestamp('01.09.2017','DD.MM.YYYY')) TO (to_timestamp('01.10.2017','DD.MM.YYYY'));
  
  Полученный результат: 
  <img src="https://github.com/kirill098/otus_homework/blob/main/%D0%94%D0%BE%D0%BC%D0%B0%D1%88%D0%BD%D1%8F%D1%8F%20%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D0%B0%20%2311/data/image2.png">
  

4) Заполняем новую секционированную таблицу flights_range значениями из flights.    
  <img src="https://github.com/kirill098/otus_homework/blob/main/%D0%94%D0%BE%D0%BC%D0%B0%D1%88%D0%BD%D1%8F%D1%8F%20%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D0%B0%20%2311/data/image3.png">

5) Проверяем заполненность партиций
  <img src="https://github.com/kirill098/otus_homework/blob/main/%D0%94%D0%BE%D0%BC%D0%B0%D1%88%D0%BD%D1%8F%D1%8F%20%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D0%B0%20%2311/data/image6.png">
  
6) Навешиваем недостающие ограничения на таблицу flights_range основе таблицы flights   
  
  


