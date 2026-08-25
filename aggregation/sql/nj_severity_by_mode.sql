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
		when veh_type in ('20', '21', '22', '23', '24', '25', '26', '27', '29') then 'Large Truck'
		when veh_type in ('02', '03', '06', '07', '10', '15', '16', '19', '30', '31', '40', '99') then 'Other Motor'
		when veh_type = '08' then 'Motorcycle'
		when veh_type in ('12', '14') then 'Other Nonmotor'
		when veh_type = '13' then 'Bicycle'
		when veh_type = '11' then 'Moped'
		when veh_type = '00' then 'Unknown'
		else null
	end as vehicle_type
from
	nj.all_vehicle),
vehicles_by_event as (
select
	casenumber,
	veh_num,
	vehicle_type
from
	vehicles
where
	vehicle_type is not null
group by
	casenumber,
	vehicle_type,
	veh_num
)
--state
select
	'vehicles' as resolution,
	'state' as geography_resolution,
	'NJ' as geography,
	ms.max_severity_level,
	vbe.vehicle_type,
	count(*) as total,
	round(count(*)/ sum(count(*)) over (partition by vbe.vehicle_type),
	3) as pct
from
	nj.all_crash c
left join nj_report.max_severity_level ms 
on
	c.casenumber = ms.casenumber
left join vehicles_by_event vbe
on
	c.casenumber = vbe.casenumber
group by
	resolution,
	geography_resolution,
	geography,
	vehicle_type,
	max_severity_level
union all 

select
	'events' as resolution,
	'state' as geography_resolution,
	'NJ' as geography,
	ms.max_severity_level,
	vbe.vehicle_type,
	count(*) as total,
	round(count(*)/ sum(count(*)) over (partition by vbe.vehicle_type),
	3) as pct
from
	nj.all_crash c
left join nj_report.max_severity_level ms 
on
	c.casenumber = ms.casenumber
left join vehicles_by_event vbe 
on
	c.casenumber = vbe.casenumber
group by
	resolution,
	geography_resolution,
	geography,
	vehicle_type,
	max_severity_level
union all
--county
select
	'vehicles' as resolution,
	'county' as geography_resolution,
	initcap(c.county) as geography,
	ms.max_severity_level,
	vbe.vehicle_type,
	count(*) as total,
	round(count(*)/ sum(count(*)) over (partition by vbe.vehicle_type, initcap(c.county)),
	3) as pct
from
	nj.all_crash c
left join nj_report.max_severity_level ms 
on
	c.casenumber = ms.casenumber
left join vehicles_by_event vbe
on
	c.casenumber = vbe.casenumber
group by
	resolution,
	geography_resolution,
	initcap(c.county),
	vehicle_type,
	max_severity_level
union all 

select
	'events' as resolution,
	'county' as geography_resolution,
	initcap(c.county) as geography,
	ms.max_severity_level,
	vbe.vehicle_type,
	count(*) as total,
	round(count(*)/ sum(count(*)) over (partition by vbe.vehicle_type, initcap(c.county)),
	3) as pct
from
	nj.all_crash c
left join nj_report.max_severity_level ms 
on
	c.casenumber = ms.casenumber
left join vehicles_by_event vbe 
on
	c.casenumber = vbe.casenumber
group by
	resolution,
	geography_resolution,
	initcap(c.county),
	vehicle_type,
	max_severity_level
union all
--municipality
	select
	'vehicles' as resolution,
	'municipality' as geography_resolution,
	initcap(c.municipality) as geography,
	ms.max_severity_level,
	vbe.vehicle_type,
	count(*) as total,
	round(count(*)/ sum(count(*)) over (partition by vbe.vehicle_type, initcap(c.municipality)),
	3) as pct
from
	nj.all_crash c
left join nj_report.max_severity_level ms 
on
	c.casenumber = ms.casenumber
left join vehicles_by_event vbe 
on
	c.casenumber = vbe.casenumber
group by
	resolution,
	geography_resolution,
	initcap(c.municipality),
	vehicle_type,
	max_severity_level
union all 

select
	'events' as resolution,
	'municipality' as geography_resolution,
	initcap(c.municipality) as geography,
	ms.max_severity_level,
	vbe.vehicle_type,
	count(*) as total,
	round(count(*)/ sum(count(*)) over (partition by vbe.vehicle_type, initcap(c.municipality)),
	3) as pct
from
	nj.all_crash c
left join nj_report.max_severity_level ms 
on
	c.casenumber = ms.casenumber
left join vehicles_by_event vbe 
on
	c.casenumber = vbe.casenumber
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
    max_severity_level
    ;