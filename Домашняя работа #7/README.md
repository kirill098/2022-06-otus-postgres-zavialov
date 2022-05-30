Ссылка на GitHub: https://github.com/kirill098/otus_homewor  
Ссылка на Yandex Cloud: https://console.cloud.yandex.ru/folders/b1gcd9q9knvqpk0jmnm0/compute/instances  
Права для пользователя ifti@yandex.ru выдал

Порядок выполнения: 

1. Заданы настройки в файле postgresql.conf
- checkpoint_timeout = 30s
- checkpoint_completion_targer = 0.6
- synchronous_commit on
2. Запущен нагрузочный тест: 
> pgbench -c10 -P 60 -T 600 -U postgres postgres
3. Получены результаты нагрузочного тестирование
> Общий объем: 443 928 kB   
> Средний объем: 22 196 kB
4. Контрольные точки выполнялись строго по расписанию.  
   Файл с данными checkpoints.rtf
5. Результаты tps в синхронном режиме:  
starting vacuum...end.  
progress: 60.0 s, 560.1 tps, lat 17.819 ms stddev 16.240.     
progress: 120.0 s, 347.0 tps, lat 28.833 ms stddev 31.040.   
progress: 180.0 s, 674.0 tps, lat 14.819 ms stddev 11.614.   
progress: 240.0 s, 530.9 tps, lat 18.825 ms stddev 17.885.   
progress: 300.0 s, 575.2 tps, lat 17.385 ms stddev 16.047.   
progress: 360.0 s, 651.1 tps, lat 15.349 ms stddev 12.085.     
progress: 420.0 s, 593.6 tps, lat 16.838 ms stddev 14.291.   
progress: 480.0 s, 544.5 tps, lat 18.357 ms stddev 16.907.   
progress: 540.0 s, 562.5 tps, lat 17.763 ms stddev 16.425.   
progress: 600.0 s, 613.5 tps, lat 16.287 ms stddev 14.312.     
transaction type: <builtin: TPC-B (sort of)>.   
scaling factor: 1.   
query mode: simple.   
number of clients: 10.   
number of threads: 1.   
duration: 600 s.     
number of transactions actually processed: 339161.   
latency average = 17.682 ms.   
latency stddev = 16.802 ms.   
initial connection time = 16.505 ms.   
tps = 565.230421 (without initial connection time).     
6. Результаты tps в асинхронном режиме:  
starting vacuum...end.    
progress: 60.0 s, 3485.2 tps, lat 2.859 ms stddev 1.554.   
progress: 120.0 s, 3523.1 tps, lat 2.827 ms stddev 1.570.   
progress: 180.0 s, 3534.4 tps, lat 2.818 ms stddev 1.569.   
progress: 240.0 s, 3584.6 tps, lat 2.780 ms stddev 1.541.   
progress: 300.0 s, 3524.4 tps, lat 2.827 ms stddev 1.577.   
progress: 360.0 s, 3528.6 tps, lat 2.824 ms stddev 1.572.   
progress: 420.0 s, 3579.0 tps, lat 2.784 ms stddev 1.579.   
progress: 480.0 s, 3548.6 tps, lat 2.809 ms stddev 1.558.   
progress: 540.0 s, 3541.3 tps, lat 2.814 ms stddev 1.546.   
progress: 600.0 s, 3525.7 tps, lat 2.826 ms stddev 1.554.   
transaction type: <builtin: TPC-B (sort of)>.   
scaling factor: 1.   
query mode: simple.   
number of clients: 10.   
number of threads: 1.   
duration: 600 s.   
number of transactions actually processed: 2122502.   
latency average = 2.817 ms.    
latency stddev = 1.562 ms.   
initial connection time = 16.697 ms.           
tps = 3537.481631 (without initial connection time).   
7. При асинхронном режиме записи tps выше более чем в 6 раз.     
Это связано с фоновым режимом записи буферов на диск.  
