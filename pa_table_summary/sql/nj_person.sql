drop view if exists nj.all_person;
create view nj.all_person as
with occupant as (
	select casenumber,
	"year" as crash_year,
	ncic_code,
	dept_case_num,
	cast(null as int) as pedestrian_num,
	veh_num,
	occupant_num,
	physical_condition,
	position_in_veh,
	ejection,
	"age",
	sex,
	location_of_most_severe_injury,
	type_of_most_severe_injury,
	false as is_bicycle,
	false as is_other,
	true as occupant, 
	false as pedestrian
	from nj.all_occupant),
pedestrian as (
	select casenumber,
	"year" as crash_year,
	ncic_code,
	dept_case_num,
	pedestrian_num,
	cast(null as int) as veh_num,
	cast(null as int) as occupant_num,
	physical_condition,
	null as position_in_veh,
	null as ejection,
	"age",
	sex,
	location_of_most_severe_injury,
	type_of_most_severe_injury,
	is_bicycle,
	is_other,
	false as occupant, 
	true as pedestrian 
	from nj.all_pedestrian) 


select * from occupant 
union all 
select * from pedestrian;