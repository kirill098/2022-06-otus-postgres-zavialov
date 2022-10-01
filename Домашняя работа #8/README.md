### Общая информация ###
* Ссылка на GitHub: https://github.com/kirill098/otus_homewor  
* Ссылка на Yandex Cloud: https://console.cloud.yandex.ru/folders/b1gehjktlatslseel5bh/compute/instances  
* Права для пользователя ifti@yandex.ru выдал

### Порядок выполнения: ###

1) Настроить кластер PostgreSQL 14 на максимальную производительность не
обращая внимание на возможные проблемы с надежностью в случае
аварийной перезагрузки виртуальной машины
- используя утилиту pgtune получить список желательных настроек
<img src="https://github.com/kirill098/otus_homework/blob/main/%D0%94%D0%BE%D0%BC%D0%B0%D1%88%D0%BD%D1%8F%D1%8F%20%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D0%B0%20%238/data/image1.png" width="600" height="500">    

- добавить полученные настройки в новый файл conf.d/configuration_v1.conf
- в файле postgresql.conf в настройку 'include_dir' добавить папку conf.d
2) изменяем на уровне системы параметр synchronous_commit = false
3) чтобы все изменения вступили в силу, необходимо их перечитать: select pg_reload_conf();
4) используя утилиту pgbench, проводим тестирование нагрузки: pgbench -c 50 -j 2 -P 5 -T 30 -M extended
<img src="https://github.com/kirill098/otus_homework/blob/main/%D0%94%D0%BE%D0%BC%D0%B0%D1%88%D0%BD%D1%8F%D1%8F%20%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D0%B0%20%238/data/image2.png">  
5) максимальный показатель tps удалось достичь благодаря отключению автокомита и выставлению в утилите pgbench параметра, отвечающего за переиспользование конектов, а также конфигрурации кластера
