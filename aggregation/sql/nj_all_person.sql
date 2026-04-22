drop view if exists nj.all_person cascade;
create view nj.all_person as
with occupant as (
	select o.casenumber,
	o."year" as crash_year,
	o.ncic_code,
	o.dept_case_num,
	cast(null as int) as pedestrian_num,
	veh_num,
	occupant_num,
	physical_condition,
	position_in_veh,
	ejection,
	case when "age" like '%M%' then '0' else "age" end as "age",
	sex,
	location_of_most_severe_injury,
	type_of_most_severe_injury,
	false as is_bicycle,
	false as is_other,
	true as occupant, 
	false as pedestrian,
	null as contrib_circ1,
	null as contrib_circ2,
	safety_equipment_used
	from nj.all_occupant o
	left join nj.all_crash c 
	on o.casenumber = c.casenumber 
	where c.road_system <> '09'),
pedestrian as (
	select p.casenumber,
	p."year" as crash_year,
	p.ncic_code,
	p.dept_case_num,
	pedestrian_num,
	cast(null as int) as veh_num,
	cast(null as int) as occupant_num,
	physical_condition,
	null as position_in_veh,
	null as ejection,
	case when "age" like '%M%' then '0' else "age" end as "age",
	sex,
	location_of_most_severe_injury,
	type_of_most_severe_injury,
	is_bicycle,
	is_other,
	false as occupant, 
	true as pedestrian,
	contrib_circ1,
	contrib_circ2,
	safety_equipment_used
	from nj.all_pedestrian p 
	left join nj.all_crash c 
	on p.casenumber = c.casenumber 
	where c.road_system <> '09')


select * from occupant
union all 
select * from pedestrian 
