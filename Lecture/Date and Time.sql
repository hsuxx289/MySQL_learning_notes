use my_database;

show databases;

select database();

create table phone(phone_name varchar(50),phone_price int, stockin_time timestamp not null default now());

select * from phone;

insert into phone(phone_name, phone_price)
values('iphone 16 pro max 1TB', 58900);