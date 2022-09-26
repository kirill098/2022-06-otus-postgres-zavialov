### Общая информация ###
* Ссылка на GitHub: https://github.com/kirill098/otus_homewor  
* Ссылка на Yandex Cloud: https://console.cloud.yandex.ru/folders/b1gehjktlatslseel5bh/compute/instances  
* Права для пользователя ifti@yandex.ru выдал

### Порядок выполнения: ###

0) Включим запись логов и изменим время ожидания блокировки, превышение которого приводит к записи в лог:    
В файле настроек postgresql.conf изменим два параметра:  
- alter system set log_lock_waits=on   
- alter systems set log_min_duration_statement=200;   
Настройки сохраняются в файл postgresql.auto.conf и являются глобальными.  
Для того, чтобы они применились, необходимо перечитать конфигурационный файл.    
select pg_reload_conf();

1) Подготавливаем окружение   
Создаем б/д: create database locks;  
Создаем таблицу: create table accounts(acc_no integer PRIMARY KEY, amount numeric);  
Вставляем строки: insert into accounts VALUES (1,1000.00), (2,2000.00), (3,3000.00); 

<B>1. Ситуация возникновения логов</B>      
<I>В первой сессии:</I>   
begin;       
lock table accounts;  
<I>Во второй сессии:</I>   
begin;  
update accounts set amount = 777 where acc_no = 1;  
Затем закрываем транзакцию в первой сессии, после - во второй.    
Первая сессия блокирует доступ к таблице accounts. Вторая сессия ожидает снятия блокировки. При ожидании более 200 мс происходит запись в лог.     
Логи:      
> 2022-05-31 18:27:26.778 UTC [1090] postgres@locks LOG:  process 1090 still waiting for RowExclusiveLock on relation 16385 of database 16384 after 200.118 ms at character 8   
> 2022-05-31 18:27:26.778 UTC [1090] postgres@locks DETAIL:  Process holding the lock: 1089. Wait queue: 1090.    
> 2022-05-31 18:27:26.778 UTC [1090] postgres@locks STATEMENT:  update accounts set amount = 777 where acc_no = 1;     
> 2022-05-31 18:27:48.257 UTC [1090] postgres@locks LOG:  process 1090 acquired RowExclusiveLock on relation 16385 of database 16384 after 21679.927 ms at character 8   
> 2022-05-31 18:27:48.257 UTC [1090] postgres@locks STATEMENT:  update accounts set amount = 777 where acc_no = 1;

Процесс 1090 ждет исключительной блокировки над объектом c id=16385, расположеным в базе данных с id=16384, спустя уже 200.118 мс.    
Процесс ожидает разблокировки процессом 1089.     
Процесс 1090 получил исключительну блокировку над оъектом с id=16385, расположеным в базе данных с id=16384, спустя уже 21679.927 мс.    

<B>2. Ситуация с тремя апдейтами</B>  
> Логи:  
> 2022-05-31 19:54:19.245 UTC [2509] postgres@locks LOG:  process 2509 still waiting for ShareLock on transaction 743 after 200.103 ms.    
> 2022-05-31 19:54:19.245 UTC [2509] postgres@locks DETAIL:  Process holding the lock: 2462. Wait queue: 2509.  
> 2022-05-31 19:54:19.245 UTC [2509] postgres@locks CONTEXT:  while updating tuple (0,8) in relation "accounts". 
> 2022-05-31 19:54:19.245 UTC [2509] postgres@locks STATEMENT:  UPDATE accounts SET amount = amount + 100 WHERE acc_no = 1;  
> 2022-05-31 19:54:21.608 UTC [2586] postgres@locks LOG:  process 2586 still waiting for ExclusiveLock on tuple (0,8) of relation 16385 of database 16384 after 200.097 ms. 
> 2022-05-31 19:54:21.608 UTC [2586] postgres@locks DETAIL:  Process holding the lock: 2509. Wait queue: 2586.  
> 2022-05-31 19:54:21.608 UTC [2586] postgres@locks STATEMENT:  UPDATE accounts SET amount = amount + 100 WHERE acc_no = 1;        

Блокировки:     

<img src="https://github.com/kirill098/otus_homework/blob/main/%D0%94%D0%BE%D0%BC%D0%B0%D1%88%D0%BD%D1%8F%D1%8F%20%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D0%B0%20%237/data/photo1.png"> 
  
 RowExclusiveLock - исключительная блокировка   
 Транзакция 2462 владеет блокировкой, затем 2509 - ждет разбловкировки, а за ней 2586.   
 Так как образовался список ожидающих разблокировки таблицы, то появился tuple. 
 Tuple содержит транзакции, ожидающие разблокировку одного р
 
 <img src="https://github.com/kirill098/otus_homework/blob/main/%D0%94%D0%BE%D0%BC%D0%B0%D1%88%D0%BD%D1%8F%D1%8F%20%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D0%B0%20%237/data/photo2.png"> 
 
 <B>3. Ситуация взаимоблокировок трех транзакций</B>
 
 №1 сессия   
 begin;    
 update accounts set amount = 1 where acc_no = 1;  
 
 №2 сессия    
 begin;    
 update accounts set amount = 1 where acc_no = 2;  
 
 №3 сессия   
 begin;    
 update accounts set amount = 1 where acc_no = 3;  
 
 №1 сессия   
 update accounts set amount = 1 where acc_no = 2;  
 
 №2 сессия   
 update accounts set amount = 1 where acc_no = 3;  
 
 №3 сессия   
 update accounts set amount = 1 where acc_no = 1;  
 
ERROR:  deadlock detected 
DETAIL:  Process 1826 waits for ShareLock on transaction 755; blocked by process 1818.  
Process 1818 waits for ShareLock on transaction 756; blocked by process 1833.  
Process 1833 waits for ShareLock on transaction 757; blocked by process 1826.  
HINT:  See server log for query details.  
CONTEXT:  while updating tuple (0,8) in relation "accounts"   

Логи: 

2022-06-05 09:20:13.069 UTC [1818] postgres@locks LOG:  process 1818 still waiting for ShareLock on transaction 756 after 200.112 ms   
2022-06-05 09:20:13.069 UTC [1818] postgres@locks DETAIL:  Process holding the lock: 1833. Wait queue: 1818.  
2022-06-05 09:20:13.069 UTC [1818] postgres@locks CONTEXT:  while updating tuple (0,2) in relation "accounts". 
2022-06-05 09:20:13.069 UTC [1818] postgres@locks STATEMENT:  update accounts set amount = 1 where acc_no = 2;  
2022-06-05 09:20:21.486 UTC [1833] postgres@locks LOG:  process 1833 still waiting for ShareLock on transaction 757 after 200.124 ms    
2022-06-05 09:20:21.486 UTC [1833] postgres@locks DETAIL:  Process holding the lock: 1826. Wait queue: 1833.  
2022-06-05 09:20:21.486 UTC [1833] postgres@locks CONTEXT:  while updating tuple (0,3) in relation "accounts"   
2022-06-05 09:20:21.486 UTC [1833] postgres@locks STATEMENT:  update accounts set amount = 1 where acc_no = 3;  
2022-06-05 09:20:29.742 UTC [1826] postgres@locks LOG:  process 1826 detected deadlock while waiting for ShareLock on transaction 755 after 200.135 ms   
2022-06-05 09:20:29.742 UTC [1826] postgres@locks DETAIL:  Process holding the lock: 1818. Wait queue: .  
2022-06-05 09:20:29.742 UTC [1826] postgres@locks CONTEXT:  while updating tuple (0,8) in relation "accounts"   
2022-06-05 09:20:29.742 UTC [1826] postgres@locks STATEMENT:  update accounts set amount = 1 where acc_no = 1;   
2022-06-05 09:20:29.742 UTC [1826] postgres@locks ERROR:  deadlock detected   
2022-06-05 09:20:29.742 UTC [1826] postgres@locks DETAIL:  Process 1826 waits for ShareLock on transaction 755; blocked by process 1818.  
	Process 1818 waits for ShareLock on transaction 756; blocked by process 1833.  
	Process 1833 waits for ShareLock on transaction 757; blocked by process 1826.  
	Process 1826: update accounts set amount = 1 where acc_no = 1;  
	Process 1818: update accounts set amount = 1 where acc_no = 2;  
	Process 1833: update accounts set amount = 1 where acc_no = 3;  
2022-06-05 09:20:29.742 UTC [1826] postgres@locks HINT:  See server log for query details.  

 <B>4. Могут ли две транзакции, выполняющие единственную команду UPDATE одной
и той же таблицы (без where), заблокировать друг друга?</B>

Да, могут, если обновление таблицы будет происходить в одной транзакции в прямом порядке, а у другой - в обратном.
