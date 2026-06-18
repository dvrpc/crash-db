drop view if exists nj.vehicle cascade; 
create view nj.vehicle as 

with vehicle as (select concat("year", ncic_code, dept_case_num) as casenumber, * from nj_2023.vehicle) 

select v.* from vehicle v inner join nj.crash c on v.casenumber = c.casenumber;