create table employee(
employee_id int,
employee_name varchar(50),
employee_age int,
employee_salary int,
employee_department varchar(50)
);

drop table members;

create table player_02(
player_id int,
player_name varchar(50),
player_age int,
player_salary int,
player_team varchar(50)
);

desc player_02;

drop table player_02;

insert into player_02(player_id,player_name,player_age,player_salary,player_team)
values (1,'Damian',33,42000000,'Milwaukee Bucks');

insert into player_02(player_id,player_name,player_age,player_salary,player_team)
values 
(2,'Devin',27,33000000,'Phoenix Suns'),
(3,'Paul',33,42000000,'Los Angeles Clippers'),
(4,'Anthony',22,10000000,'Minnesota Timberwolves');

select * from player_02;

insert into employee(employee_id,employee_name,employee_age,employee_salary,employee_department)
values
(1,'Tim',39,100000,'Sales'),
(2,'Danny',27,33000,'Accounting'),
(3,'Wilson',33,42000,'Adminstration'),
(4,'Elizabeth',22,29000,'Accounting');

select * from employee;

show columns from employee;

describe employee;