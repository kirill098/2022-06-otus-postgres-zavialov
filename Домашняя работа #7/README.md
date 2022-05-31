1. Включим запись логов и изменим время ожидания блокировки, превышение которого приводит к записи в лог:    
В файле настроек postgresql.conf изменим два параметра:  
> 1) log_lock_waits on. 
> 2) deadlock_timeout 200 (без указания единицы измерения, по дефолту - миллисекунды). 
2. Рестартуем кластер     
> sudo pg_ctlcluster 14 main restart      
3. Ситуация возникновения логов:  
> 1) Создаем б/д: create database locks;
> 2) Создаем таблицу:   
> create table accounts(  
>  acc_no integer PRIMARY KEY,  
>  amount numeric);  
> 3) Вставляем строки   
> insert into accounts VALUES (1,1000.00), (2,2000.00), (3,3000.00);  
> 4) 
> В первой сессии:   
> begin;       
> lock table accounts;  
> Во второй сессии:   
> begin;  
> update accounts set amount = 777 where acc_no = 1;  
> Затем закрываем транзакцию в первой сессии, после. - во второй.  
> Лог:    
> 2022-05-31 18:27:26.778 UTC [1090] postgres@locks LOG:  process 1090 still waiting for RowExclusiveLock on relation 16385 of database 16384 after 200.118 ms at character 8   
> 2022-05-31 18:27:26.778 UTC [1090] postgres@locks DETAIL:  Process holding the lock: 1089. Wait queue: 1090.    
> 2022-05-31 18:27:26.778 UTC [1090] postgres@locks STATEMENT:  update accounts set amount = 777 where acc_no = 1;     
> 2022-05-31 18:27:48.257 UTC [1090] postgres@locks LOG:  process 1090 acquired RowExclusiveLock on relation 16385 of database 16384 after 21679.927 ms at character 8   
> 2022-05-31 18:27:48.257 UTC [1090] postgres@locks STATEMENT:  update accounts set amount = 777 where acc_no = 1;      
4. 
