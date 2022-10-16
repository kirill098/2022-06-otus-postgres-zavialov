### Общая информация ###
* Ссылка на GitHub: https://github.com/kirill098/otus_homewor  
* Ссылка на Yandex Cloud: https://console.cloud.yandex.ru/folders/b1gehjktlatslseel5bh/compute/instances  
* Права для пользователя ifti@yandex.ru выдал

### Порядок выполнения: ###

#### 1. Выбор темы домашнего задания: применение на практике различных вариантов соединений таблиц ####
#### 2. Выполнение ####
0. Подготовка тестовых данных:
- создание таблицы student   
  - create table student(id int, name text, course text);
- наполнение таблицы student тестовыми данными     
  - insert into student(id, name, course)   
    select id, ‘student_’ || id, (random()*10)::int % 4 + 1    
    from generate_series(1, 100) id;   
- создание таблицы exam   
  - create table exam(id int, student_id int, mark int, subject text);
- наполнение таблицы exam тестовыми данными        
  - insert into exam(id, student_id, mark, subject)    
    select id, 101-id, (random()*10)::int % 4 +1,     
    case (id % 5 +1)     
      when 1 then 'math'     
      when 2 then 'physics'    
      when 3 then 'geography'   
      when 4 then 'chemistry'   
      when 5 then 'biology'   
    end    
    from generate_series(1, 100) id;      
    
1. Реализовать прямое соединение двух или более таблиц (inner join)   
- запрос на соединение двух таблица student и exam по условию student.id = exam.student_id
  - select student_id, name, course, subject, course from student s    
    join exam e     
    on s.id = e.student_id; 
2. Реализовать левостороннее соединение двух или более таблиц 
- для иллюстрации примера необходимо дополнить таблицу student данными студентов, отсутствующих в таблице exam
  - insert into student(id, name, course) 
    select id, 'student_' || id, (random()*10)::int % 4 +1 
    from generate_series(101, 120) id;   
- запрос на левостороннее соединение таблицы student с exam по условию student.id = exam.student_id
  - select s.id, name, course, subject, course from student s    
    left join exam e     
    on s.id = e.student_id;    
3.     
    
    


