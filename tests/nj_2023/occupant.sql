drop view if exists nj.occupant cascade; 
create view nj.occupant as 
with occupant as (select concat("year", ncic_code, dept_case_num) as casenumber, * from nj_2023.occupant)

select o.* from occupant o inner join nj.crash c on o.casenumber = c.casenumber where road_system <> '09';