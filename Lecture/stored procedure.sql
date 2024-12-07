delimiter //
create procedure select_ports()
begin
	select * from ports;
end //
delimiter ;

call select_ports();

select * from passengers;
select * from ports;
select * from tickets;

delimiter //
create procedure pname_ports(in pname varchar(50))
begin
	select name, portid from passengers where name like pname;
end //
delimiter ;

call pname_ports('% william %');

drop procedure pname_ports;