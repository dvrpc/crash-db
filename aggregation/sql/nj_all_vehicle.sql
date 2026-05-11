drop view if exists nj.all_vehicle cascade;

create view nj.all_vehicle as 

with vehicle as(
select
	concat("year",
	ncic_code,
	dept_case_num) as casenumber,
	*
from
	nj_2017.vehicle
union all
select
	concat("year",
	ncic_code,
	dept_case_num) as casenumber,
	*
from
	nj_2018.vehicle
union all
select
	concat("year",
	ncic_code,
	dept_case_num) as casenumber,
	*
from
	nj_2019.vehicle
union all
select
	concat("year",
	ncic_code,
	dept_case_num) as casenumber,
	*
from
	nj_2020.vehicle
union all
select
	concat("year",
	ncic_code,
	dept_case_num) as casenumber,
	*
from
	nj_2021.vehicle
union all
select
	concat("year",
	ncic_code,
	dept_case_num) as casenumber,
	*
from
	nj_2022.vehicle
)

select v.* from vehicle v inner join nj.all_crash c on v.casenumber = c.casenumber;
