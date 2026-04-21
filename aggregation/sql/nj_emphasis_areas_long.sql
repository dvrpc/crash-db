drop view if exists nj.emphasis_areas;

create view nj.emphasis_areas as

select
    p.casenumber,
    crash_year,
    'ksi_event' as emphasis_area,
    max(case
            when physical_condition in ('01','02') then 1
            else 0
        end) as cnt
from nj.all_person p
group by p.casenumber, crash_year

union all

select p.casenumber, crash_year, 'ksi_person', count(*)
from nj.all_person p where physical_condition in ('01', '02')
group by p.casenumber, crash_year

union all 

select c.casenumber, c.year as crash_year, 'intersection', 1
from nj.all_crash c where "intersection" = 'I'

union all 

select c.casenumber, c.year as crash_year, 'lane_departure', 1 
from nj.all_crash c where crash_type in ('02', '04', '09', '10', '11')

union all 

select c.casenumber, c.year as crash_year, 'distracted_driving', 1 
from nj.all_crash c where first_harmful_event in ('02', '17', '18', '19', '20', '21')

union all 

select c.casenumber, c.year as crash_year, 'aggressive_driving', 1 
from nj.all_crash c where first_harmful_event in ('01', '03', '04', '05', '06', '09')

union all 

select v.casenumber, v.year as crash_year, 'hvy_truck_related', max(case
            when veh_type in ('20', '21', '22', '23', '24', '25', '26', '27', '29') then 1
            else 0
        end) 
from nj.all_vehicle v
group by v.casenumber, crash_year

union all 

select v.casenumber, v.year as crash_year, 'streetcar_trolley', max(case
            when veh_type = '12' then 1
            else 0
        end) 
from nj.all_vehicle v
group by v.casenumber, crash_year;