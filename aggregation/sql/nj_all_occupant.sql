drop view if exists nj.all_occupant;

create view nj.all_occupant as 

with occupant as(
select
	concat("year",
	ncic_code,
	dept_case_num) as casenumber,
	*
from
	nj_2017.occupant
union all
select
	concat("year",
	ncic_code,
	dept_case_num) as casenumber,
	*
from
	nj_2018.occupant
union all
select
	concat("year",
	ncic_code,
	dept_case_num) as casenumber,
	*
from
	nj_2019.occupant
union all
select
	concat("year",
	ncic_code,
	dept_case_num) as casenumber,
	*
from
	nj_2020.occupant
union all
select
	concat("year",
	ncic_code,
	dept_case_num) as casenumber,
	*
from
	nj_2021.occupant
union all
select
	concat("year",
	ncic_code,
	dept_case_num) as casenumber,
	*
from
	nj_2022.occupant
union all
select * 
from nj_2023.occupant)

select o.* from occupant o inner join nj.all_crash c on o.casenumber = c.casenumber;
