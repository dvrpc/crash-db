create schema if not exists nj_test;
drop view if exists nj_test.missing_driver_veh; 
create view nj_test.missing_driver_veh as 
with person_drivers as (
select
	casenumber,
	veh_num
from
	nj.all_person
where
	position_in_veh = '01') 



select a.casenumber, a.driver_veh_num from (select 
	d.casenumber,
	d.veh_num as driver_veh_num,
	p.veh_num as person_veh_num 
from nj.all_driver d 
left join person_drivers p 
on d.casenumber = p.casenumber and d.veh_num = p.veh_num) as a
where a.person_veh_num is null