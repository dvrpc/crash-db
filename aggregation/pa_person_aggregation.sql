drop view if exists pa_all.person;
create view pa_all.person as

select * from pa_2005.person 

union all

select * from pa_2006.person 

union all

select * from pa_2007.person 

union all

select * from pa_2008.person 

union all

select * from pa_2009.person 

union all

select * from pa_2010.person 

union all 

select * from pa_2011.person 

union all

select * from pa_2012.person 

union all 

select * from pa_2013.person 

union all

select * from pa_2014.person 

union all 

select * from pa_2015.person 

union all 

select * from pa_2016.person 

union all 

select * from pa_2017.person 

union all 

select * from pa_2018.person 

union all 

select * from pa_2019.person 

union all 

select * from pa_2020.person 

union all 

select * from pa_2021.person 

union all 

select * from pa_2022.person 

union all 

select * from pa_2023.person 

union all 

select * from pa_2024.person;