create database social_media_app;
use social_media_app;

create table users(
id int not null primary key auto_increment,
user_name varchar(200)
);

-- insert data
insert into users(user_name)
values
('Amanda'), ('Brian'), ('Cally'), ('Daniel'), ('Edward');

select * from users;

create table photos(
id int not null primary key auto_increment,
photo_url varchar(200),
user_id int,
foreign key (user_id) references users(id)
);

-- check table settings
desc photos;

-- insert data
insert into photos(photo_url, user_id)
values('https://123456.png', 1);

select * from photos;


create table photos_02(
id int primary key auto_increment,
photo_url varchar(200),
user_id int,
foreign key(user_id) references users(id) on delete cascade
);

insert into photos_02(photo_url, user_id)
values
('https://50vO5C2qYeQBPfvV.png', 1), ('https://9939P61ncLk0zT7l.png', 1),
('https://IDiRYiItNd5TC2h9.png', 2), ('https://LsrdCdC0dhjrjteg.png', 2),
('https://TKHN7Fnmeoepeahw.png', 3), ('https://ajG9183iiGYHoReq.png', 3),
('https://edJKy1VdLkZ8wv5W.png', 4), ('https://nbiLUDgfCwI4ubWE.png', 4),
('https://pfhednPD67rDnreQ.png', 5), ('https://uxlInX2oBS6YtBiG.png', 5);

select * from photos_02;

delete from users where id = 3;

create table photos_03(
id int primary key auto_increment,
photo_url varchar(200),
user_id int,
foreign key(user_id) references users(id) on delete set null
);

delete from users where id = 1;

select * from photos_03;

insert into photos_03(photo_url, user_id)
values
('https://50vO5C2qYeQBPfvV.png', 1), ('https://9939P61ncLk0zT7l.png', 1),
('https://IDiRYiItNd5TC2h9.png', 2), ('https://LsrdCdC0dhjrjteg.png', 2),
('https://pfhednPD67rDnreQ.png', 5), ('https://uxlInX2oBS6YtBiG.png', 5);
