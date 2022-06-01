1. Включим запись логов и изменим время ожидания блокировки, превышение которого приводит к записи в лог:    
В файле настроек postgresql.conf изменим два параметра:  
> 1) log_lock_waits on. 
> 2) deadlock_timeout 200 (без указания единицы измерения, по дефолту - миллисекунды). 
2. Рестартуем кластер     
> sudo pg_ctlcluster 14 main restart      
3. Ситуация возникновения логов:    
3.1 Подготавливаем окружение   
Создаем б/д: create database locks;  
Создаем таблицу: create table accounts(acc_no integer PRIMARY KEY, amount numeric);  
Вставляем строки: insert into accounts VALUES (1,1000.00), (2,2000.00), (3,3000.00);  
3.2 Набор команд     
<I>В первой сессии:</I>   
begin;       
lock table accounts;  
<I>Во второй сессии:</I>   
begin;  
update accounts set amount = 777 where acc_no = 1;  
Затем закрываем транзакцию в первой сессии, после - во второй.    
Первая сессия блокирует доступ к таблице accounts. Вторая сессия ожидает снятия блокировки. При ожидании более 200 мс происходит запись в лог.     

3.3 Логи      
> 2022-05-31 18:27:26.778 UTC [1090] postgres@locks LOG:  process 1090 still waiting for RowExclusiveLock on relation 16385 of database 16384 after 200.118 ms at character 8   
> 2022-05-31 18:27:26.778 UTC [1090] postgres@locks DETAIL:  Process holding the lock: 1089. Wait queue: 1090.    
> 2022-05-31 18:27:26.778 UTC [1090] postgres@locks STATEMENT:  update accounts set amount = 777 where acc_no = 1;     
> 2022-05-31 18:27:48.257 UTC [1090] postgres@locks LOG:  process 1090 acquired RowExclusiveLock on relation 16385 of database 16384 after 21679.927 ms at character 8   
> 2022-05-31 18:27:48.257 UTC [1090] postgres@locks STATEMENT:  update accounts set amount = 777 where acc_no = 1;

Процесс 1090 ждет исключительной блокировки над объектом c id=16385, расположеной в базе данных с id=16384, спустя 200.118 мс.    
Процесс ожидает разблокировки процессом 1089.     
Процесс 1090 получил исключительну блокировку над оъектом с id=16385, расположеной в базе данных с id=16384, спустя 21679.927 мс.    

4. Ситуация с тремя апдейтами  
> Лог:  
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
 Так как образовался список ожидающих разблокировки строки, то появился tuple.  
   
Первая транзакция:    
   locktype    |   relation    | virtxid | xid |       mode       | granted     
---------------+---------------+---------+-----+------------------+---------    
 relation      | pg_locks      |         |     | AccessShareLock  | t   
 relation      | accounts_pkey |         |     | RowExclusiveLock | t   
 relation      | accounts      |         |     | RowExclusiveLock | t   
 virtualxid    |               | 7/4     |     | ExclusiveLock    | t   
 transactionid |               |         | 743 | ExclusiveLock    | t   
 Исключительная блокировка таблицы accounts и ее primary key.  
    
 Вторая транзакция:   
   locktype    |   relation    | virtxid | xid |       mode       | granted       
---------------+---------------+---------+-----+------------------+---------    
 relation      | accounts_pkey |         |     | RowExclusiveLock | t   
 relation      | accounts      |         |     | RowExclusiveLock | t   
 virtualxid    |               | 8/13    |     | ExclusiveLock    | t  
 tuple         | accounts      |         |     | ExclusiveLock    | t     
 transactionid |               |         | 744 | ExclusiveLock    | t   
 transactionid |               |         | 743 | ShareLock        | f   
 Ожидание снятия блокировки на таблицу accounts, первый в очередни.  
   
 Третья транзакция       
    locktype    |   relation    | virtxid | xid |       mode       | granted   
---------------+---------------+---------+-----+------------------+---------  
 relation      | accounts_pkey |         |     | RowExclusiveLock | t   
 relation      | accounts      |         |     | RowExclusiveLock | t    
 virtualxid    |               | 4/9     |     | ExclusiveLock    | t   
 tuple         | accounts      |         |     | ExclusiveLock    | f     
 transactionid |               |         | 745 | ExclusiveLock    | t  
Ожидание в очереди снятия блокировки, доступа к таблице нет.     

5. 
