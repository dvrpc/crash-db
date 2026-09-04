drop materialized view if exists nj_report.severity_by_mode;
create materialized view nj_report.severity_by_mode as 
with vehicles as (
    select
        casenumber,
        veh_num,
        case 
            when veh_type = '01' then 'Car/Stationwagon/Minivan'
            when veh_type = '05' then 'Pickup Truck'
            when veh_type = '04' then 'SUV'
            when veh_type in ('20', '21', '22', '23', '24', '25', '26', '27', '29')
                then 'Large Truck'
            when veh_type in ('02', '03', '06', '07', '10', '15', '16', '19', '30', '31', '40', '99')
                then 'Other Motor'
            when veh_type = '08' then 'Motorcycle'
            when veh_type in ('12', '14') then 'Other Nonmotor'
            when veh_type = '13' then 'Bicycle'
            when veh_type = '11' then 'Moped'
            when veh_type = '00' then 'Unknown'
            else null
        end as vehicle_type
    from nj.all_vehicle
),
events_by_mode as (
    select distinct
        casenumber,
        vehicle_type
    from vehicles
),
people as ( 
	select  
		casenumber, 
		veh_num,
		case 
			when physical_condition = '01' then 'Fatal'
			when physical_condition = '02' then 'Suspected Serious Injury'
			when physical_condition = '03' then 'Suspected Minor Injury'
			when physical_condition = '04' then 'Possible Injury'
			when physical_condition = '05' then 'No Apparent Injury'
			when physical_condition in ('00', '06') or physical_condition is null then 'Other or Unknown'
			else null end as physical_condition
	from nj.all_person
		)

-- state


select
    'vehicles' as resolution,
    'state' as geography_resolution,
    'NJ' as geography,
    ms.max_severity_level as severity,
    v.vehicle_type,
    count(*) as total,
    round(
        count(*)::numeric /
        sum(count(*)) over (
            partition by v.vehicle_type
        ),
        3
    ) as pct
from nj.all_crash c
left join nj_report.max_severity_level ms
    on c.casenumber = ms.casenumber
left join vehicles v
    on c.casenumber = v.casenumber
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
    p.physical_condition as severity,
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
left join nj.all_crash c 
on p.casenumber = c.casenumber
left join vehicles v
    on p.casenumber = v.casenumber and p.veh_num = v.veh_num
where v.vehicle_type is not null
group by
    resolution,
    geography_resolution,
    geography,
    vehicle_type,
    physical_condition 

union all


select
    'events' as resolution,
    'state' as geography_resolution,
    'NJ' as geography,
    ms.max_severity_level as severity,
    ebm.vehicle_type,
    count(*) as total,
    round(
        count(*)::numeric /
        sum(count(*)) over (
            partition by ebm.vehicle_type
        ),
        3
    ) as pct
from nj.all_crash c
left join nj_report.max_severity_level ms
    on c.casenumber = ms.casenumber
left join events_by_mode ebm
    on c.casenumber = ebm.casenumber
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
    ms.max_severity_level as severity,
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
from nj.all_crash c
left join nj_report.max_severity_level ms
    on c.casenumber = ms.casenumber
left join vehicles v
    on c.casenumber = v.casenumber
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
    p.physical_condition as severity,
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
left join nj.all_crash c 
on p.casenumber = c.casenumber
left join vehicles v
    on p.casenumber = v.casenumber and p.veh_num = v.veh_num
where v.vehicle_type is not null
group by
    resolution,
    geography_resolution,
    geography,
    vehicle_type,
    physical_condition 
    
union all


select
    'events' as resolution,
    'county' as geography_resolution,
    initcap(c.county) as geography,
    ms.max_severity_level as severity,
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
from nj.all_crash c
left join nj_report.max_severity_level ms
    on c.casenumber = ms.casenumber
left join events_by_mode ebm
    on c.casenumber = ebm.casenumber
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
    ms.max_severity_level as severity,
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
from nj.all_crash c
left join nj_report.max_severity_level ms
    on c.casenumber = ms.casenumber
left join vehicles v
    on c.casenumber = v.casenumber
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
    p.physical_condition as severity,
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
left join nj.all_crash c 
on p.casenumber = c.casenumber 
left join vehicles v
    on p.casenumber = v.casenumber and p.veh_num = v.veh_num
where v.vehicle_type is not null
group by
    resolution,
    geography_resolution,
    geography,
    vehicle_type,
    physical_condition 

union all

select
    'events' as resolution,
    'municipality' as geography_resolution,
    initcap(c.municipality) as geography,
    ms.max_severity_level as severity,
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
from nj.all_crash c
left join nj_report.max_severity_level ms
    on c.casenumber = ms.casenumber
left join events_by_mode ebm
    on c.casenumber = ebm.casenumber
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