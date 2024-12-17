create database mysql_50;

use mysql_50;

create table student(
 sno varchar(10) primary key,
 sname varchar(20),
 sage int, 
 ssex varchar(5)
);

create table teacher(
 tno varchar(10) primary key, 
 tname varchar(20)
);

create table course(
 cno varchar(10),
 cname varchar(20), 
 tno varchar(20), 
 constraint pk_course primary key (cno,tno)
);

create table sc(
 sno varchar(10),
 cno varchar(10), 
 score float,
 constraint pk_sc primary key (sno,cno)
);

insert into student values ('s001','張三',23,'男');
insert into student values ('s002','李四',23,'男');
insert into student values ('s003','吳鵬',25,'男');
insert into student values ('s004','琴沁',20,'女');
insert into student values ('s005','王麗',20,'女');
insert into student values ('s006','李波',21,'男');
insert into student values ('s007','劉玉',21,'男');
insert into student values ('s008','蕭蓉',21,'女');
insert into student values ('s009','陳蕭曉',23,'女');
insert into student values ('s010','陳美',22,'女');
insert into student values ('s011','王麗',24,'女');
insert into student values ('s012','蕭蓉',20,'女');

insert into teacher values ('t001', '劉陽');
insert into teacher values ('t002', '諶燕');
insert into teacher values ('t003', '胡明星');

insert into course values ('c001','J2SE','t002');
insert into course values ('c002','Java Web','t002');
insert into course values ('c003','SSH','t001');
insert into course values ('c004','Oracle','t001');
insert into course values ('c005','SQL SERVER 2005','t003');
insert into course values ('c006','C#','t003');
insert into course values ('c007','JavaScript','t002');
insert into course values ('c008','DIV+CSS','t001');
insert into course values ('c009','PHP','t003');
insert into course values ('c010','EJB3.0','t002');

insert into sc values ('s001','c001',78.9);
insert into sc values ('s002','c001',80.9);
insert into sc values ('s003','c001',81.9);
insert into sc values ('s004','c001',50.9);
insert into sc values ('s005','c001',59.9);
insert into sc values ('s001','c002',82.9);
insert into sc values ('s002','c002',72.9);
insert into sc values ('s003','c002',82.9);
insert into sc values ('s001','c003',59);
insert into sc values ('s006','c003',99.8);
insert into sc values ('s002','c004',52.9);
insert into sc values ('s003','c004',20.9);
insert into sc values ('s004','c004',59.8);
insert into sc values ('s005','c004',50.8);
insert into sc values ('s002','c005',92.9);
insert into sc values ('s001','c007',78.9);
insert into sc values ('s001','c010',78.9);

select * from sc;
select * from course;
select * from teacher;
select * from student;

# 1. 查詢學生表的前10條資料
select * from student limit 10;

# 2. 查詢成績表所有成績的最低分,平均分,總分
select min(score), avg(score),sum(score) from sc;

# 3. 查詢老師 “諶燕” 所帶的課程數量
select count(*)
from teacher
left join course
using (tno) where tname = "諶燕";

# 4. 查詢所有老師所帶的課程數量
select tname, count(*)
from teacher
left join course
using (tno) group by tno;

# 5. 查詢姓”張”的學生名單
select * from student 
where sname like "張%";

# 6. 查詢課程名稱為'Oracle'且分數低於60 的學號和分數
select sno, score
from course
left join sc
using (cno) where score < 60 and cname = 'Oracle';

# 7. 查詢所有學生的選課 課程名稱
select sname, cname
from student
left join sc
using (sno)
left join course
using (cno);

# 8. 查詢任何一門課程成績在70 分以上的學生姓名.課程名稱和分數
select sname,cname,score
from sc
left join student
using (sno)
left join course
using (cno)
where score >= 70;

# 9. 查詢不及格的課程,並按課程號從大到小排列 學號,課程號,課程名,分數
select sno, cno, cname, score
from sc
left join course
using (cno)
where score < 60
order by cno desc;

# 10. 查詢沒學過”諶燕”老師講授的任一門課程的學號,學生姓名
select sno, sname
from student
where sno not in ( 
select distinct sno
from sc
left join student
using (sno)
left join course
using (cno)
left join teacher
using (tno)
where tname in ('諶燕'));

# 11. 查詢兩門以上不及格課程的同學的學號及其平均成績
select sno, avg(score) 
from student
join sc
using (sno)
where score < 60
group by sno
having count(score)>=2;

# 12. 檢索'c004'課程分數小於60,按分數降序排列的同學學號
select sno
from sc
where cno = 'c004' and score < 60 
order by score desc;

# 13. 查詢'c001'課程比'c002'課程成績高的所有學生的學號
select a.sno
from sc a, sc b
where a.sno = b.sno and a.cno = 'c001' and b.cno = 'c002' and a.score > b.score
;

# 14. 查詢平均成績大於60 分的同學的學號和平均成績
select sno, avg(score)
from student
left join sc
using (sno)
group by sno
having avg(score) > 60;

# 15. 查詢所有同學的學號.姓名.選課數.總成績
select sno, sname, count(cno), sum(score)
from student
left join sc
using (sno)
group by sno
;

# 16. 查詢姓”劉”的老師的個數
select count(*)
from teacher
where tname like "劉%";

# 17. 查詢只學”諶燕”老師所教的課的同學的學號:姓名
select distinct sno,sname
from sc
left join student
using (sno)
where sno not in
(select sno
from sc
where cno not in
(select cno
from course
left join teacher
using(tno)
where tname='諶燕'));

# 18. 查詢學過”c001″並且也學過編號”c002″課程的同學的學號.姓名
select sno, sname
from student
where sno in (select a.sno from sc a, sc b where a.sno = b.sno and a.cno = 'c001' and b.cno = 'c002');

# 19. 查詢學過”諶燕”老師所教的所有課的同學的學號:姓名
select sno,sname
from sc
left join student
using (sno)
left join course
using (cno)
left join teacher
using (tno)
where tname = '諶燕'
group by sno
having count(*) = 
(select count(*)
from course
left join teacher
using (tno)
where tname = '諶燕');

# 20. 查詢課程編號”c004″的成績比課程編號”c001″和”c002″課程低的所有同學的學號.姓名
select sno,sname
from student
where sno in
(select a.sno
from sc a, sc b, sc c
where a.sno = b.sno
and b.sno = c.sno
and a.cno = 'c004'
and b.cno = 'c001'
and c.cno = 'c002'
and a.score < b.score
and a.score < c.score);

# 21. 查詢所有課程成績小於60 分的同學的學號.姓名
select *
from sc
left join student
using (sno)
where score < 60;

# 22. 查詢沒有學課的同學的學號.姓名
select sno, sname
from student
left join sc
using (sno)
where cno is null;

# 23. 查詢與學號為”s001″一起上過課的同學的學號和姓名
select distinct sno, sname
from sc
left join student
using (sno)
where sno in (
select b.sno
from sc a, sc b
where a.sno = 's001' and b.sno != 's001'
and a.cno = b.cno);

select distinct sno, sname
from sc
left join student
using (sno)
where cno in
(select cno
from sc
where sno = 's001') and sno != 's001';

# 24. 查詢跟學號為”s005″所修課程完全一樣的同學的學號和姓名

# 25. 查詢各科成績最高和最低的分 顯示:課程ID,最高分,最低分

# 26. 按各科平均成績和及格率的百分數 照平均從低到高顯示

# 27. 查詢每個課程的老師及平均分從高到低顯示 老師名稱,課程名稱,平均分數

# 28. 統計列印各科成績,各分數段人數:課程ID,課程名稱,verygood[100-86], good[85-71], bad[<60]

# 29. 查詢各科成績前三名的記錄:(不考慮成績並列情況)

# 30. 查詢每門課程被選修的學生數

# 31. 查詢出只選修了兩門課程的全部學生的學號和姓名

# 32. 查詢男生.女生人數 32-1. 查詢每個課程的男生女生總數

# 33. 查詢同名同姓學生名單,並統計同名人數

# 34. 查詢年紀最小跟最大的學生名單(注:Student 表中Sage 列的型別是int)

# 35. 查詢每門課程的平均成績,結果按平均成績升序排列,平均成績相同時,按課程號降序排列

# 36. 查詢平均成績大於85 的所有學生的學號.姓名和平均成績

# 37. 查詢課程編號為c001 且課程成績在80 分以上的學生的學號和姓名

# 38. 檢索每課程第二高分的學號 分數(考慮成績並列)

# 39. 求選了課程的學生人數

# 40. 查詢選修”諶燕”老師所授課程的學生中,成績最高的學生姓名及其成績

# 41. 查詢不同課程成績有相同的學生的學號.課程號.學生成績

# 42. 所有課程排名成績(不考慮並列) 學號,課程號,排名,成績 照課程,排名排序

# 43. 所有課程排名成績(考慮並列) 學號,課程號,排名,成績 照課程,排名排序

# 44. 做所有學生顯示學生名稱,課程名稱,成績,老師名稱的視圖

# 45. 查詢上過所有老師教的課程的學生 學號,學生名

# 46. 查詢包含數字的課程名

# 47. 查詢只有英文的課程名

# 48. 查詢所有學生的平均成績 並排名 , 學號,學生名,排名,平均成績(不考慮並列) 對平均成績高到低及學號低到高排序

# 49. 查詢所有學生的平均成績 並排名 , 學號,學生名,排名,平均成績(考慮並列) 對平均成績高到低及學號低到高排序

# 50. 查詢課程有學生的成績是其他人成績兩倍的學號 學生名
