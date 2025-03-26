use my_train_titanic;

select count(distinct pclass) from passengers;

select distinct pclass, sex from passengers;

select count(distinct pclass, sex) from passengers;

select * from passengers where name like 'williams,%';

select * from passengers where name like '% william %' and ticketid like '__' and sex = 'male';

select * from passengers where sex != 'female' and portid != 2 and portid != 3;
select * from passengers where sex != 'female' and portid not in (2, 3);

select id, name,
case
	when portid = 1 then 'Southampton'
    when portid = 2 then 'Cherbourg'
    when portid = 3 then 'Queenstown'
    else 'unkonwn'
    end boarding_place
from passengers;
