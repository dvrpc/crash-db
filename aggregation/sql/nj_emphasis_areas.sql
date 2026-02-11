drop view if exists nj.emphasis_areas;

create view nj.emphasis_areas as

select c.casenumber, c."year" as crash_year, 'test' as area, 1 as cnt 
from nj.all_crash c


union all


select p.casenumber, crash_year, 'ksi_person' as "area", count(*)
from nj.all_person p where physical_condition in ('01', '02')
group by p.casenumber, crash_year;