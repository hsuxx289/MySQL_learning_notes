create table cars_04(
car_id int primary key,
car_brand varchar(50),
car_color varchar(50),
car_sale_price int 
);

create table cars_04(
car_id int,
car_brand varchar(50),
car_color varchar(50),
car_sale_price int, 
primary key(car_id)
);

select * from cars_04;

insert into cars_04(car_id, car_brand)
value(
1,'Luxgen'
);

insert into cars_04(car_brand)
value(
'Luxgen'
);

show warnings;

create table cars_05(
car_id int primary key auto_increment,
car_brand varchar(50),
car_color varchar(50),
car_sale_price int 
);

alter table cars_05 auto_increment = 101;

insert into cars_05(car_brand)
value(
'Luxgen'
);

drop table car_05;

desc table car_05;

select * from cars_05;

select database();

use my_database;

create table my_product(
product_id int primary key auto_increment,
product_name varchar(50),
product_price double
);

alter table my_product auto_increment = 20;

insert into my_product(product_name, product_price)
value ('apple',3.5),('apple',3.5),('apple',3.5),('apple',3.5),('apple',3.5);

select * from my_product;