# 1.查詢各性別乘客的總人數，請顯示在sex與gender_counts這兩個欄位
select sex, count(sex) gender_counts 
from full_passengers 
group by sex;

# 2.查詢第591至第883名乘客的id與姓名資料
select id, pname 
from full_passengers 
where id between 591 and 883;

# 3.請找出所有的Anders & Alfrida Andersson家成員以及存活狀態
select pname, survived 
from full_passengers 
where pname like 'Andersson%' 
and homedest like 'Sweden%';

# 4.承上題，已知Afrida還有一個已婚的妹妹叫做Anna，請找出Anna與其丈夫小孩一家三口的全部資料
select pname 
from full_passengers 
where pname like '%(alfrida%';

select * from full_passengers 
where pname like '%Brogren%';

select * from full_passengers 
where ticket = 347080;

# 5. 找出所有名字是Leonard的男性乘客，顯示id, pclass, pname
select id, pclass, pname from full_passengers 
where pname like '% leonard%' and sex = 'male';

# 6.查詢所有乘客持有的票券中，最多人持有的那一種ticket，回傳票券名稱(ticket)與持有人數(ticket_count)兩個欄位
select ticket, count(id) from full_passengers 
group by ticket 
order by count(id) 
desc limit 1;

/*with x (y, z) 
as (select ticket, count(ticket) from full_passengers group by ticket) 
select y ticket, z ticket_count from x where z = (select max(z) from x); */

# 7. 分開列出二等客艙以及三等客艙中所有男性乘客的平均年齡
select pclass, sex, avg(age) from full_passengers 
where sex = 'male' and pclass in (2,3) 
group by pclass;

# 8. 列出所有登船點的登船人數與百分比，僅列出有明確登船地點的資料即可
select embarked 登船點, count(id) 登船人數, 
round(count(id)/(select count(id) from full_passengers)*100, 2) 登船點占百分比 
from full_passengers 
where embarked != "" group by embarked;

# QUESTION 1
select firstName, lastName, city, state 
from Person 
left join Address 
on Person.personId = Address.personId;

# QUESTION 2
select class
from Courses 
group by class having count(class) > 3;

# QUESTION 3
select a.num as ConsecutiveNums
from Logs as a,
   Logs as b,
   Logs as c
where a.id = b.id - 1
   and b.id = c.id - 1
   and a.num = b.num
   and b.num = c.num;
   
# QUESTION 4
select product_id, year first_year, quantity, price 
from sales
where sale_id in (select min(sale_id) from sales group by product_id);