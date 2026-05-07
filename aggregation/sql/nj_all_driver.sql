drop view if exists nj.all_driver;

create view nj.all_driver as 

with driver as(
select
	concat("year",
	ncic_code,
	dept_case_num) as casenumber,
	*
from
	nj_2017.driver
union all
select
	concat("year",
	ncic_code,
	dept_case_num) as casenumber,
	*
from
	nj_2018.driver
union all
select
	concat("year",
	ncic_code,
	dept_case_num) as casenumber,
	*
from
	nj_2019.driver
union all
select
	concat("year",
	ncic_code,
	dept_case_num) as casenumber,
	*
from
	nj_2020.driver
union all
select
	concat("year",
	ncic_code,
	dept_case_num) as casenumber,
	*
from
	nj_2021.driver
union all
select
	concat("year",
	ncic_code,
	dept_case_num) as casenumber,
	*
from
	nj_2022.driver
)

select d.* from driver d inner join nj.all_crash c on d.casenumber = c.casenumber;
