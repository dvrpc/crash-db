drop view if exists nj.driver cascade; 
create view nj.driver as 

with driver as (select concat("year", ncic_code, dept_case_num) as casenumber, * from nj_2023.driver) 

select d.* from driver d inner join nj.crash c on d.casenumber = c.casenumber;