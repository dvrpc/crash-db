drop view if exists nj.person cascade;
create view nj.person as
with occupant as (
	select casenumber,
	"year" as crash_year,
	ncic_code,
	dept_case_num,
	null as pedestrian_num,
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
	from nj.occupant),
pedestrian as (
	select casenumber,
	"year" as crash_year,
	ncic_code,
	dept_case_num,
	pedestrian_num,
	null as veh_num,
	null as occupant_num,
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
	from nj.pedestrian) 


select * from occupant 
union all 
select * from pedestrian;