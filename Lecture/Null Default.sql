create table cars(
car_brand varchar(50) not null,
car_color varchar(50) not null,
car_sale_price int
);

drop table cars;

desc cars;

insert into cars(car_brand, car_color, car_sale_price)
values
('Luxgen', 'blue', 200000),
('Ford', 'white', null);

select * from cars;

create table cars_02(
car_brand varchar(50) not null default 'unknown',
car_color varchar(50) not null default 'unknown',
car_sale_price int default 50000
);

desc cars_02;

insert into cars_02(car_color,car_sale_price)
value(
'black',
null
);

select * from cars_02;

insert into cars_02()
value(
);

create table cars_03(
car_brand varchar(50) default 'unknown',
car_color varchar(50) default 'unknown',
car_sale_price int default 50000
);

desc cars_03;

insert into cars_03(car_brand,car_color,car_sale_price)
value(
null,
'black',
null
);

insert into cars_03(car_color)
value(
'black'
);

insert into cars_03(car_brand,car_color)
value
('Toyota',null),
('Honda',null);

select * from cars_03;