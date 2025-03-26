create table player(
player_id int not null primary key auto_increment,
player_name varchar(50),
player_position varchar(50),
player_age int
);

insert into player(player_name, player_position, player_age)
values
('Bobby', 'INF', 23),
('Luis', 'P', 30),
('Jonah', 'C', 28),
('Framber', 'P', 30),
('Pete', 'P', 27),
('Matt', 'INF', 29),
('Corbin', 'OF', 23),
('Juan', 'OF', 28);

select * from player;

select player_id, player_name, player_age from player;

select player_name, player_age, player_position from player;

select * from player where player_age <= 28;

select * from player where player_name = 'Pete' or player_name = 'Juan';

select player_name 姓名, player_age 年紀, player_position 守備位置 from player;
select player_name as 姓名, player_age as 年紀, player_position as 守備位置 from player;

select * from player;

select player_name,player_age from player where player_name = 'Bobby';

update player set player_age = 26 where player_name = 'Bobby';

select player_name,player_age from player where player_name = 'Jonah';

update player set player_name = 'Jonathan' where player_name = 'Jonah';

select player_name,player_age from player where player_name = 'Bobby' or player_name = 'Jonathan';

delete from player where player_name = 'Jonathan';

insert into player(player_id,player_name, player_position, player_age)
values
(3,'Jonah', 'C', 28);

show warnings;

use my_database;


create table grocery(
grocery_id int primary key auto_increment,
grocery_name varchar(50),
grocery_category varchar(50),
grocery_reserves int
);


insert into grocery(grocery_name, grocery_category, grocery_reserves)
values
('Beef', 'Meat', 13),
('Milk', 'Dairy', 15),
('Spinach', 'Vegetables', 20),
('Cheese', 'Dairy', 5),
('Pork', 'Meat', 8),
('Beer', 'Beverage', 60),
('Cabbage', 'Vegetables', 21),
('Lamb', 'Meat', 16);

select grocery_name,grocery_category,grocery_reserves from grocery;

select grocery_id,grocery_name from grocery where grocery_id between 3 and 7;

select grocery_id,grocery_name,grocery_category from grocery where grocery_category='Meat'; 

