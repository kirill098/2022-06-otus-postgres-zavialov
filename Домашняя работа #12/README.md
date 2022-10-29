### Общая информация ###
* Ссылка на GitHub: https://github.com/kirill098/otus_homewor  
* Ссылка на Yandex Cloud: https://console.cloud.yandex.ru/folders/b1gehjktlatslseel5bh/compute/instances  
* Права для пользователя ifti@yandex.ru выдал

### Порядок выполнения: ###

0) Подготовительный этап   
Накатываем скрипты из файла 
[hw_triggers.sql](https://github.com/kirill098/otus_homework/blob/main/%D0%94%D0%BE%D0%BC%D0%B0%D1%88%D0%BD%D1%8F%D1%8F%20%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D0%B0%20%2312/data/hw_triggers.sql)

1) Создаем функцию и триггер на таблицу sales на действие insert   
[insert.sql](https://github.com/kirill098/otus_homework/blob/main/%D0%94%D0%BE%D0%BC%D0%B0%D1%88%D0%BD%D1%8F%D1%8F%20%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D0%B0%20%2312/data/insert.sql)

1) Создаем функцию и триггер на таблицу sales на действие update   
[update.sql](https://github.com/kirill098/otus_homework/blob/main/%D0%94%D0%BE%D0%BC%D0%B0%D1%88%D0%BD%D1%8F%D1%8F%20%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D0%B0%20%2312/data/update.sql)

1) Создаем функцию и триггер на таблицу sales на действие delete   
[delete.sql](https://github.com/kirill098/otus_homework/blob/main/%D0%94%D0%BE%D0%BC%D0%B0%D1%88%D0%BD%D1%8F%D1%8F%20%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D0%B0%20%2312/data/delete.sql)

1) При изменении данных в таблице sales будут производиться соответствующие изменения в отчетной таблице good_sum_mart
