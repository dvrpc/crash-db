drop view if exists nj.all_pedestrian;

create view nj.all_pedestrian as 

with pedestrian as(
select
	concat("year",
	ncic_code,
	dept_case_num) as casenumber,
	*
from
	nj_2017.pedestrian
union all
select
	concat("year",
	ncic_code,
	dept_case_num) as casenumber,
	*
from
	nj_2018.pedestrian
union all
select
	concat("year",
	ncic_code,
	dept_case_num) as casenumber,
	*
from
	nj_2019.pedestrian
union all
select
	concat("year",
	ncic_code,
	dept_case_num) as casenumber,
	*
from
	nj_2020.pedestrian
union all
select
	concat("year",
	ncic_code,
	dept_case_num) as casenumber,
	*
from
	nj_2021.pedestrian
union all
select
	concat("year",
	ncic_code,
	dept_case_num) as casenumber,
	*
from
	nj_2022.pedestrian
union all
select 
* 
from nj_2023.pedestrian)

select p.* from pedestrian p inner join nj.all_crash c on p.casenumber = c.casenumber;
