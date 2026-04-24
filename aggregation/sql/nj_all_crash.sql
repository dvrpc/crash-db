drop view if exists nj.all_crash cascade;
create view nj.all_crash as 

select CONCAT("year", ncic_code, dept_case_num) as casenumber,* from nj_2017.crash where road_system <> '09'

union all 

select CONCAT("year", ncic_code, dept_case_num) as casenumber,* from nj_2018.crash where road_system <> '09'
 

union all 

select CONCAT("year", ncic_code, dept_case_num) as casenumber,* from nj_2019.crash where road_system <> '09'
 

union all 

select CONCAT("year", ncic_code, dept_case_num) as casenumber,* from nj_2020.crash where road_system <> '09'
 

union all 

select CONCAT("year", ncic_code, dept_case_num) as casenumber,* from nj_2021.crash where road_system <> '09'
 

union all 

select
	CONCAT("year", ncic_code, dept_case_num) as casenumber,*
from
	nj_2022.crash
where
	road_system <> '09'