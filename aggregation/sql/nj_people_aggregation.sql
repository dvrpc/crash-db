drop view if exists nj.all_person;
create view nj.all_person as
with occupant as (select concat("year", ncic_code, dept_case_num) as casenumber, cast(null as int) as pedestrian_num, veh_num, occupant_num, physical_condition, position_in_veh, "age", true as occupant, false as pedestrian from nj.all_occupant),
pedestrian as (select concat("year", ncic_code, dept_case_num) as casenumber, pedestrian_num, cast(null as int) as veh_num, cast(null as int) as occupant_num, physical_condition, null as position_in_veh, "age", false as occupant, true as pedestrian from nj.all_pedestrian)
select *
from occupant

union all

select * 
from pedestrian;