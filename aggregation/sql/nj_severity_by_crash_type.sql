drop materialized view if exists nj_report.severity_by_crash_type;
create materialized view nj_report.severity_by_crash_type as
--Event-level
select 
'event' as resolution,
ct.description as crash_type,
ms.max_severity_level as physical_condition,
'state' as geography_resolution,
'NJ' as geography,
count(*) as total,
round(count(*)/sum(count(*)) over (partition by ct.description), 3) as pct
from nj.all_crash c 
left join nj_report.max_severity_level ms
on c.casenumber = ms.casenumber
left join nj_2017_lookup.crash_type ct 
on c.crash_type = ct.code 
group by ct.description, ms.max_severity_level


union all


select 
'event',
ct.description as crash_type,
ms.max_severity_level as physical_condition,
'county' as geography_resolution,
initcap(county) as geography,
count(*) as total,
round(count(*)/sum(count(*)) over (partition by initcap(county), ct.description), 3) as pct
from nj.all_crash c 
left join nj_report.max_severity_level ms
on c.casenumber = ms.casenumber
left join nj_2017_lookup.crash_type ct 
on c.crash_type = ct.code 
group by initcap(county), ct.description, ms.max_severity_level


union all


select 
'event',
ct.description as crash_type,
ms.max_severity_level as physical_condition,
'municipality' as geography_resolution,
initcap(municipality) as geography,
count(*) as total,
round(count(*)/sum(count(*)) over (partition by initcap(municipality), ct.description), 3) as pct
from nj.all_crash c 
left join nj_report.max_severity_level ms
on c.casenumber = ms.casenumber
left join nj_2017_lookup.crash_type ct 
on c.crash_type = ct.code 
group by initcap(municipality), ct.description, ms.max_severity_level


--Person level
union all 


select 
'person' as resolution,
ct.description as crash_type,
pc.description as physical_condition,
'state' as geographic_resolution,
'NJ' as geography,
count(*) as total,
round(count(*)/sum(count(*)) over (partition by ct.description), 3) as pct
from nj.all_crash c 
left join nj.all_person p
on c.casenumber = p.casenumber
left join nj_2017_lookup.physical_condition pc 
on p.physical_condition = pc.code
left join nj_2017_lookup.crash_type ct 
on c.crash_type = ct.code 
group by ct.description, pc.description


union all


select 
'person',
ct.description as crash_type,
pc.description as physical_condition,
'county' as geographic_resolution,
initcap(county) as geography,
count(*) as total,
round(count(*)/sum(count(*)) over (partition by initcap(county), ct.description), 3) as pct
from nj.all_crash c 
left join nj.all_person p  
on c.casenumber = p.casenumber
left join nj_2017_lookup.physical_condition pc 
on p.physical_condition = pc.code
left join nj_2017_lookup.crash_type ct 
on c.crash_type = ct.code 
group by initcap(county), ct.description, pc.description

union all


select 
'person',
ct.description as crash_type,
pc.description as physical_condition,
'municipality' as geographic_resolution,
initcap(municipality) as geography,
count(*) as total,
round(count(*)/sum(count(*)) over (partition by initcap(municipality), ct.description), 3) as pct
from nj.all_crash c 
left join nj.all_person p  
on c.casenumber = p.casenumber
left join nj_2017_lookup.physical_condition pc 
on p.physical_condition = pc.code
left join nj_2017_lookup.crash_type ct 
on c.crash_type = ct.code 
group by initcap(municipality), ct.description, pc.description