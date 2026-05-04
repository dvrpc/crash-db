drop view if exists nj.crash cascade; 
create view nj.crash as 

select concat("year", ncic_code, dept_case_num) as casenumber, * from nj_2023.crash where road_system <> '09';