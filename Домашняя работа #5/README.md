1. Запустил pgbench -c8 -P 60 -T 600 -U postgres postgres.   
Получил результат:   

![description1](https://github.com/kirill098/otus_homework/blob/main/%D0%94%D0%BE%D0%BC%D0%B0%D1%88%D0%BD%D1%8F%D1%8F%20%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D0%B0%20%235/data/after.png?raw=true)

2. Внес изменения в параметры работы avtovacuum:  
	•	log_autovacuum_min_duration = 0.     
	•	autovacuum_max_workers = 10.   
	•	autovacuum_naptime = 15.   
	•	autovacuum_vacuum_threshold = 25.   
	•	autovacuum_vacum_scale_factor = 0.05.   
	•	autovacuum_vacuum_cost_delay = 10.   
	•	autovacuum_vacuum_cost_limit = 1000.   

3. Запустил pgbench -c8 -P 60 -T 600 -U postgres postgres.   
Получил результат:   

![description2](https://github.com/kirill098/otus_homework/blob/main/%D0%94%D0%BE%D0%BC%D0%B0%D1%88%D0%BD%D1%8F%D1%8F%20%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D0%B0%20%235/data/before.png?raw=true)
