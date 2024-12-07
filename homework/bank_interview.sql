create database bank_interview;

use bank_interview;

create table Person(
personId int primary key,
lastName varchar(50),
firstName varchar(50)
);

create table Address(
addressId int primary key,
personId int,
city varchar(50),
state varchar(50)
);

# QUESTION 1
select firstName, lastName, city, state from Person left join Address on Person.personId = Address.personId;

create table course(
student varchar(10),
class varchar(10)
);

insert into course 
value 
('A','Math'),
('B','English'),
('C','Math'),
('D','Biology'),
('E','Math'),
('F','Computer'),
('G','Math'),
('H','Math'),
('I','Math');


# QUESTION 2
select class
from Courses 
group by class having count(class) > 3;

create table Logs(
id int,
num varchar(10)
);

insert into Logs 
value 
(1,'1'),
(2,'1'),
(3,'1'),
(4,'2'),
(5,'1'),
(6,'2'),
(7,'2');

select * from Logs;

# Question 3
select a.num as ConsecutiveNums
from Logs as a,
   Logs as b,
   Logs as c
where a.id = b.id - 1
   and b.id = c.id - 1
   and a.num = b.num
   and b.num = c.num;
   
CREATE TABLE Product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50)
);

CREATE TABLE Sales (
    sale_id INT PRIMARY KEY,
    product_id INT,
    year INT,
    quantity INT,
    price DECIMAL(10, 2),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

INSERT INTO Product (product_id, product_name) VALUES
(100, 'Nokia'),
(200, 'Apple'),
(300, 'Samsung');

INSERT INTO Sales (sale_id, product_id, year, quantity, price) VALUES
(1, 100, 2008, 10, 5000),
(2, 100, 2009, 12, 5000),
(7, 200, 2011, 15, 9000);

select * from product;

select * from Sales;

select product_id, year first_year, quantity, price 
from sales
where sale_id in (select min(sale_id) from sales group by product_id);