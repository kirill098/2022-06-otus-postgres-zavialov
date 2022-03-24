Ссылка на GitHub: https://github.com/kirill098/otus_homework
Ссылка на Yandex Cloud: https://console.cloud.yandex.ru/folders/b1gcd9q9knvqpk0jmnm0/compute/instances
Права для пользователя ifti@yandex.ru выдал

Порядок выполнения: 

1. Создал ВМ в Yandex Cloud, установив на нее PostgreSQL 14 и прописав public key для доступа по ssh
2. Присоединился по ssh к ВМ (две разные сессии), затем в базе под пользователем postgres
Далее по пунктам из задания: 

- запустить везде psql из под пользователя postgres 
- выключить auto commit 
- сделать в первой сессии новую таблицу и наполнить ее данными 
create table persons(id serial, first_name text, second_name text); 
insert into persons(first_name, second_name) values('ivan', 'ivanov'); 
insert into persons(first_name, second_name) values('petr', 'petrov'); 
commit; 
- посмотреть текущий уровень изоляции: show transaction isolation level
> read committed;
- начать новую транзакцию в обоих сессиях с дефолтным (не меняя) уровнем изоляции 
- в первой сессии добавить новую запись 
insert into persons(first_name, second_name) values('sergey', 'sergeev');
- сделать select * from persons во второй сессии 
- видите ли вы новую запись и если да то почему? 
>  Запись не видна, т.к. на уровне READ COMMITED не допускается чтение не зафиксированной информации («Грязное чтение»).
- завершить первую транзакцию - commit; 
- сделать select * from persons во второй сессии 
- видите ли вы новую запись и если да то почему? 
>  Запись видна, т.к. изменения были зафиксированы.
- завершите транзакцию во второй сессии 
- начать новые но уже repeatable read транзакции 
- set transaction isolation level repeatable read; 
- в первой сессии добавить новую запись 
insert into persons(first_name, second_name) values('sveta', 'svetova'); 
- сделать select * from persons во второй сессии 
- видите ли вы новую запись и если да то почему? 
> Нет, т.к. транзакция остается не зафиксированной. 
- завершить первую транзакцию - commit; 
- сделать select * from persons во второй сессии 
- видите ли вы новую запись и если да то почему? 
>  Нет, потому что при уровне изоляции repeatable read для одинаковых запросов обращение к базе будет одно для одинаковых запросов (последующие запросы берут результат первой выборки)
- завершить вторую транзакцию 
- сделать select * from persons во второй сессии 
- видите ли вы новую запись и если да то почему?
> Транзакция с уровнем изоляции repeatable read была зафиксирована. Новая транзакция имеет уровень read committed и производит выборку в базе.
