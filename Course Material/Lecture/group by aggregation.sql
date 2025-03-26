select * from tickets;
select * from ports;
select * from passengers;

select sex, avg(age) from passengers group by sex;
select pclass, max(age) from passengers group by pclass order by pclass;
select pclass, min(age) from passengers group by pclass order by pclass;

select city,count(portid) from passengers join ports on portId = ports.id group by city having count(city)>=100;

select city,count(portid) from passengers join ports on portId = ports.id group by city having count(*)>=100;

select * from passengers order by -portid desc;

select * from passengers order by -portid desc limit 15;

select * from passengers order by portid limit 2, 15;

select pclass, name, age from passengers where age > (select max(age) from passengers where pclass = 2) order by age desc;