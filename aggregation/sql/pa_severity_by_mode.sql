drop materialized view if exists pa_report.severity_by_mode;
create materialized view pa_report.severity_by_mode as 
with vehicles as (
    select
        crn,
        unit_num,
        case 
	        WHEN v.veh_type = '01'
                THEN 'Automobile'

            WHEN v.veh_type = '02'
                THEN 'Motorcycle'

            WHEN v.veh_type = '03'
                THEN 'Bus'

            WHEN v.veh_type = '04'
                THEN 'Small Truck'

            WHEN v.veh_type = '05'
                THEN 'Large Truck'

            WHEN v.veh_type IN
                ('06','07','08','09','10','11','12',
                 '13','14','15','16','17','18','19')
                THEN 'Other Motor'

            WHEN v.veh_type = '20'
                THEN 'Bicycle'

            WHEN v.veh_type = '31'
                THEN 'Pedestrian'

            WHEN v.veh_type IN
                ('21','22','23','24','25','32','33',
                 '34','35','36','98')
                THEN 'Other Nonmotor'

            WHEN v.veh_type = '99'
                 OR v.veh_type IS NULL
                THEN 'Other/Unknown'

            ELSE 'Other/Unknown'
        END AS vehicle_type
    from pa.all_vehicle v
),
events_by_mode as (
    select distinct
        crn,
        vehicle_type
    from vehicles
),
people as ( 
	select  
		crn, 
		unit_num,
		case 
			when inj_severity = '01' then 'Fatal'
			when inj_severity = '02' then 'Suspected Serious Injury'
			when inj_severity = '03' then 'Suspected Minor Injury'
			when inj_severity = '04' then 'Possible Injury'
			when inj_severity = '05' then 'Died Prior to Crash'
			when inj_severity in ('00', '08', '06') or inj_severity is null then 'Other or Unknown'
			else null end as inj_severity
	from pa.all_person
		),
person_events as (  
select distinct(crn) from pa.all_person),
crashes as (  
select c.* 
from pa.all_crash c)

-- state


select
    'vehicles' as resolution,
    'state' as geography_resolution,
    'NJ' as geography,
    c.max_severity_level as severity,
    v.vehicle_type,
    count(*) as total,
    round(
        count(*)::numeric /
        sum(count(*)) over (
            partition by v.vehicle_type
        ),
        3
    ) as pct
from crashes c
left join vehicles v
    on c.crn = v.crn
where v.vehicle_type is not null
group by
    resolution,
    geography_resolution,
    geography,
    vehicle_type,
    max_severity_level
    
union all 

select
    'people' as resolution,
    'state' as geography_resolution,
    'NJ' as geography,
    p.inj_severity as severity,
    v.vehicle_type,
    count(*) as total,
    round(
        count(*)::numeric /
        sum(count(*)) over (
            partition by v.vehicle_type
        ),
        3
    ) as pct
from people p
left join crashes c 
on p.crn = c.crn
left join vehicles v
    on p.crn = v.crn and p.unit_num = v.unit_num
where v.vehicle_type is not null
group by
    resolution,
    geography_resolution,
    geography,
    vehicle_type,
    inj_severity 

union all


select
    'events' as resolution,
    'state' as geography_resolution,
    'NJ' as geography,
    c.max_severity_level as severity,
    ebm.vehicle_type,
    count(*) as total,
    round(
        count(*)::numeric /
        sum(count(*)) over (
            partition by ebm.vehicle_type
        ),
        3
    ) as pct
from crashes c
left join events_by_mode ebm
    on c.crn = ebm.crn
where ebm.vehicle_type is not null
group by
    resolution,
    geography_resolution,
    geography,
    vehicle_type,
    max_severity_level


union all

-- county

select
    'vehicles' as resolution,
    'county' as geography_resolution,
    initcap(c.county) as geography,
    c.max_severity_level as severity,
    v.vehicle_type,
    count(*) as total,
    round(
        count(*)::numeric /
        sum(count(*)) over (
            partition by
                v.vehicle_type,
                initcap(c.county)
        ),
        3
    ) as pct
from crashes c
left join vehicles v
    on c.crn = v.crn
where v.vehicle_type is not null
group by
    resolution,
    geography_resolution,
    initcap(c.county),
    vehicle_type,
    max_severity_level


union all 

select
    'people' as resolution,
    'county' as geography_resolution,
    initcap(c.county) as geography,
    p.inj_severity as severity,
    v.vehicle_type,
    count(*) as total,
    round(
        count(*)::numeric /
        sum(count(*)) over (
            partition by v.vehicle_type, initcap(c.county)
        ),
        3
    ) as pct
from people p
left join crashes c 
on p.crn = c.crn
left join vehicles v
    on p.crn = v.crn and p.unit_num = v.unit_num
where v.vehicle_type is not null
group by
    resolution,
    geography_resolution,
    geography,
    vehicle_type,
    inj_severity 
    
union all


select
    'events' as resolution,
    'county' as geography_resolution,
    initcap(c.county) as geography,
    c.max_severity_level as severity,
    ebm.vehicle_type,
    count(*) as total,
    round(
        count(*)::numeric /
        sum(count(*)) over (
            partition by
                ebm.vehicle_type,
                initcap(c.county)
        ),
        3
    ) as pct
from crashes c
left join events_by_mode ebm
    on c.crn = ebm.crn
where ebm.vehicle_type is not null
group by
    resolution,
    geography_resolution,
    initcap(c.county),
    vehicle_type,
    max_severity_level

union all

-- municipality

select
    'vehicles' as resolution,
    'municipality' as geography_resolution,
    initcap(c.municipality) as geography,
    c.max_severity_level as severity,
    v.vehicle_type,
    count(*) as total,
    round(
        count(*)::numeric /
        sum(count(*)) over (
            partition by
                v.vehicle_type,
                initcap(c.municipality)
        ),
        3
    ) as pct
from crashes c
left join vehicles v
    on c.crn = v.crn
where v.vehicle_type is not null
group by
    resolution,
    geography_resolution,
    initcap(c.municipality),
    vehicle_type,
    max_severity_level
    
union all 

select
    'people' as resolution,
    'municipality' as geography_resolution,
    initcap(c.municipality) as geography,
    p.inj_severity as severity,
    v.vehicle_type,
    count(*) as total,
    round(
        count(*)::numeric /
        sum(count(*)) over (
            partition by v.vehicle_type, initcap(c.municipality)
        ),
        3
    ) as pct
from people p 
left join crashes c 
on p.crn = c.crn 
left join vehicles v
    on p.crn = v.crn and p.unit_num = v.unit_num
where v.vehicle_type is not null
group by
    resolution,
    geography_resolution,
    geography,
    vehicle_type,
    inj_severity 

union all

select
    'events' as resolution,
    'municipality' as geography_resolution,
    initcap(c.municipality) as geography,
    c.max_severity_level as severity,
    ebm.vehicle_type,
    count(*) as total,
    round(
        count(*)::numeric /
        sum(count(*)) over (
            partition by
                ebm.vehicle_type,
                initcap(c.municipality)
        ),
        3
    ) as pct
from crashes c
left join events_by_mode ebm
    on c.crn = ebm.crn
where ebm.vehicle_type is not null
group by
    resolution,
    geography_resolution,
    initcap(c.municipality),
    vehicle_type,
    max_severity_level

order by
    resolution,
    geography_resolution,
    geography,
    vehicle_type,
    severity;