drop view if exists pa.all_crash cascade;

create view pa.all_crash as 

with all_crashes as (
select
		*
from
		pa_2019.crash
union all
select
		*
from
		pa_2020.crash
union all
select
		*
from
		pa_2021.crash
union all
select
		*
from
		pa_2022.crash
union all
select
		*
from
		pa_2023.crash
union all
select
		*
from
		pa_2024.crash ),
private_roads as ( 
select  
	crn,
	bool_or(case when road_owner = '7' then true else false end) as private_road from pa.all_roadway group by crn
)

select * from all_crashes;
