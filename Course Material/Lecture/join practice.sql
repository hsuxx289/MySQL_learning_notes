create table teams(
id int not null primary key auto_increment,
team_name varchar(50),
team_nickname varchar(50)
);

create table result(
id int not null primary key auto_increment,
result_name varchar(50),
result_description varchar(100)
);

create table matches(
fk_result_id int,
fk_team_id int,
foreign key (fk_result_id) references result(id),
foreign key (fk_team_id) references teams(id)
);

insert into teams(team_name, team_nickname)
values
('Brother Elephants', '爪爪'),
('Rakuten Monkeys', '吱吱'),
('Uni Lions', '喵喵'),
('Fubon Guardians', '邦邦'),
('WeiChuan Dragons', '油龍');

insert into result(result_name, result_description)
values
('贏球', '得分比對方多'),
('輸球', '得分比對方少'),
('平手', '雙方得分一樣多');

insert into matches(fk_result_id, fk_team_id)
values
(1, 2),
(1, 3),
(1, 5),
(1, 4),
(2, 1),
(2, 2),
(2, 4),
(2, 5),
(3, 1),
(3, 3);

select * from teams;
select * from result;
select * from matches;

select team_nickname
from matches
join teams
on  fk_team_id = teams.id;

select result_name
from matches
join result
on  fk_result_id = result.id;

use my_database;


select team_nickname,result_name
from (matches
join teams
on  fk_team_id = teams.id)
join result
on  fk_result_id = result.id;

select team_nickname,result_name
from (teams
join matches
on  teams.id = fk_team_id)
left join result
on fk_result_id = result.id;