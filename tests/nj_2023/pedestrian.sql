drop view if exists nj.pedestrian cascade; 
create view nj.pedestrian as 

with pedestrian as (select concat("year", ncic_code, dept_case_num) as casenumber, * from nj_2023.pedestrian) 

select p.* from pedestrian p inner join nj.crash c on p.casenumber = c.casenumber;