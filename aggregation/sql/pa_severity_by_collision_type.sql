drop materialized view if exists pa_report.severity_by_collision_type;
create materialized view pa_report.severity_by_collision_type as
--Event-level

select 
'event' as resolution,
ct.description as crash_type,
ms.description as physical_condition,
'state' as geography_resolution,
'pa' as geography,
count(*) as total,
round(count(*)/sum(count(*)) over (partition by ct.description), 3) as pct
from pa.all_crash c 
left join pa_lookup.max_severity_level ms
on c.max_severity_level = ms.code
left join pa_lookup.collision_type ct 
on c.collision_type = ct.code
group by ct.description, ms.description


union all


select 
'event' as resolution,
ct.description as crash_type,
ms.description as physical_condition,
'county' as geography_resolution,
initcap(co.description) as geography,
count(*) as total,
round(count(*)/sum(count(*)) over (partition by initcap(co.description), ct.description), 3) as pct
from pa.all_crash c 
left join pa_lookup.max_severity_level ms
on c.max_severity_level = ms.code
left join pa_lookup.collision_type ct 
on c.collision_type = ct.code
left join pa_lookup.county co 
on c.county = co.code
group by initcap(co.description), ct.description, ms.description



union all


select 
'event' as resolution,
ct.description as crash_type,
ms.description as physical_condition,
'municipality' as geography_resolution,
initcap(mu.description) as geography,
count(*) as total,
round(count(*)/sum(count(*)) over (partition by initcap(mu.description), ct.description), 3) as pct
from pa.all_crash c 
left join pa_lookup.max_severity_level ms
on c.max_severity_level = ms.code
left join pa_lookup.collision_type ct 
on c.collision_type = ct.code
left join pa_lookup.municipalities mu
on c.municipality = mu.code
group by mu.description, ct.description, ms.description


--Person level
union all 


select 
'person' as resolution,
ct.description as collision_type,
p.inj_severity as physical_condition,
'state' as geographic_resolution,
'pa' as geography,
count(*) as total,
round(count(*)/sum(count(*)) over (partition by ct.description), 3) as pct
from pa.all_crash c 
left join pa.all_person p
on c.crn = p.crn
left join pa_lookup.collision_type ct 
on c.collision_type = ct.code 
group by ct.description, p.inj_severity



union all


select 
'person' as resolution,
ct.description as collision_type,
p.inj_severity as physical_condition,
'county' as geographic_resolution,
initcap(co.description) as geography,
count(*) as total,
round(count(*)/sum(count(*)) over (partition by initcap(co.description), ct.description), 3) as pct
from pa.all_crash c 
left join pa.all_person p
on c.crn = p.crn
left join pa_lookup.collision_type ct 
on c.collision_type = ct.code 
left join pa_lookup.county co
on c.county = co.code
group by initcap(co.description), ct.description, p.inj_severity

union all


select 
'person' as resolution,
ct.description as collision_type,
p.inj_severity as physical_condition,
'municipality' as geographic_resolution,
initcap(mu.description) as geography,
count(*) as total,
round(count(*)/sum(count(*)) over (partition by initcap(mu.description), ct.description), 3) as pct
from pa.all_crash c 
left join pa.all_person p
on c.crn = p.crn
left join pa_lookup.collision_type ct 
on c.collision_type = ct.code 
left join pa_lookup.municipalities mu
on c.municipality = mu.code
group by initcap(mu.description), ct.description, p.inj_severity


order by resolution, geography_resolution, geography, crash_type, physical_condition