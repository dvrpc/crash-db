drop view if exists pa.emphasis_areas;

create view pa.emphasis_areas as

select
    p.crn,
    c.crash_year,
    'ksi_event' as emphasis_area,
    max(case
            when inj_severity  in ('1','2') then 1
            else 0
        end) as cnt
from pa.all_person p
inner join pa.all_crash c 
on p.crn = c.crn
group by p.crn, c.crash_year

union all 

select
    p.crn,
    c.crash_year,
    'ksi_person' as emphasis_area,
    count(*)
from pa.all_person p
inner join pa.all_crash c 
on p.crn = c.crn
where inj_severity in ('1', '2')
group by p.crn, c.crash_year

union all 

select
    crn,
    crash_year,
    'intersection' as emphasis_area,
    1
from pa.all_crash c
where intersection_related = True
group by crn, crash_year

union all 

select
    f.crn,
    c.crash_year,
    'lane_departure' as emphasis_area,
    1
from pa.all_flags f
inner join pa.all_crash c 
on f.crn = c.crn
where lane_departure is True
group by f.crn, c.crash_year

union all

select
    f.crn,
    c.crash_year,
    'distracted_driving' as emphasis_area,
    1
from pa.all_flags f
inner join pa.all_crash c 
on f.crn = c.crn
where distracted is True
group by f.crn, c.crash_year

union all 

select
    f.crn,
    c.crash_year,
    'aggressive_driving' as emphasis_area,
    1
from pa.all_flags f
inner join pa.all_crash c 
on f.crn = c.crn
where aggressive_driving is True
group by f.crn, c.crash_year

union all 

select
    f.crn,
    c.crash_year,
    'impaired_driving' as emphasis_area,
    1
from pa.all_flags f
inner join pa.all_crash c 
on f.crn = c.crn
where impaired_driver is True
group by f.crn, c.crash_year

union all 

select
    f.crn,
    c.crash_year,
    'work_zone' as emphasis_area,
    1
from pa.all_flags f
inner join pa.all_crash c 
on f.crn = c.crn
where work_zone is True
group by f.crn, c.crash_year

union all 

select
    f.crn,
    c.crash_year,
    'train_trolley' as emphasis_area,
    1
from pa.all_flags f
inner join pa.all_crash c 
on f.crn = c.crn
where train_trolley is True
group by f.crn, c.crash_year

union all 

select
    f.crn,
    c.crash_year,
    'hvy_truck_related' as emphasis_area,
    1
from pa.all_flags f
inner join pa.all_crash c 
on f.crn = c.crn
where hvy_truck_related is True
group by f.crn, c.crash_year


union all 

select
    f.crn,
    c.crash_year,
    'unbelted' as emphasis_area,
    1
from pa.all_flags f
inner join pa.all_crash c 
on f.crn = c.crn
where unbelted is True
group by f.crn, c.crash_year

union all 

select
    f.crn,
    c.crash_year,
    'motorcycle' as emphasis_area,
    1
from pa.all_flags f
inner join pa.all_crash c 
on f.crn = c.crn
where motorcycle is True
group by f.crn, c.crash_year

union all 

select
    f.crn,
    c.crash_year,
    'bicycle_event' as emphasis_area,
    1
from pa.all_flags f
inner join pa.all_crash c 
on f.crn = c.crn
where bicycle is True
group by f.crn, c.crash_year;