Ссылка на GitHub: https://github.com/kirill098/otus_homework  
Ссылка на Yandex Cloud: https://console.cloud.yandex.ru/folders/b1gcd9q9knvqpk0jmnm0/compute/instances  
Права для пользователя ifti@yandex.ru выдал

Порядок выполнения:   
1. Запустить кластер не получилось: "Error: /var/lib/postgresql/14/main is not accessible or does not exist".  
Предполагаю по причине переноса на предыдущем шаге папки с данными кластера.
2. В файле postgresql.conf изменил значение в поле data на "/mnt/data/14/main".
3. Кластер запустился, в б/д dbkirill таблица contacts выводятся данные, которые были занесены до переноса данных.
