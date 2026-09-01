drop materialized view if exists nj_report.severity_by_crash_type;
create materialized view nj_report.severity_by_crash_type as
with people as  ( 
	select  
		casenumber, 
		veh_num,
		case 
			when physical_condition = '01' then 'Fatal'
			when physical_condition = '02' then 'Suspected Serious Injury'
			when physical_condition = '03' then 'Suspected Minor Injury'
			when physical_condition = '04' then 'Possible Injury'
			when physical_condition = '05' then 'No Apparent Injury'
			when physical_condition in ('00', '06') then 'Other or Unknown'
			else null end as physical_condition
	from nj.all_person
		)
		
--Event-level
select 
'event' as resolution,
ct.description as crash_type,
ms.max_severity_level as severity,
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
ms.max_severity_level as severity,
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
ms.max_severity_level as severity,
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


--People level
union all 


select 
'people' as resolution,
ct.description as crash_type,
p.physical_condition as severity,
'state' as geographic_resolution,
'NJ' as geography,
count(*) as total,
round(count(*)/sum(count(*)) over (partition by ct.description), 3) as pct
from nj.all_crash c 
left join people p 
on c.casenumber = p.casenumber
left join nj_2017_lookup.physical_condition pc 
on p.physical_condition = pc.code
left join nj_2017_lookup.crash_type ct 
on c.crash_type = ct.code 
group by ct.description, p.physical_condition


union all


select 
'people',
ct.description as crash_type,
p.physical_condition as severity,
'county' as geographic_resolution,
initcap(county) as geography,
count(*) as total,
round(count(*)/sum(count(*)) over (partition by initcap(county), ct.description), 3) as pct
from nj.all_crash c 
left join people p 
on c.casenumber = p.casenumber
left join nj_2017_lookup.physical_condition pc 
on p.physical_condition = pc.code
left join nj_2017_lookup.crash_type ct 
on c.crash_type = ct.code 
group by initcap(county), ct.description, p.physical_condition

union all


select 
'people',
ct.description as crash_type,
p.physical_condition as severity,
'municipality' as geographic_resolution,
initcap(municipality) as geography,
count(*) as total,
round(count(*)/sum(count(*)) over (partition by initcap(municipality), ct.description), 3) as pct
from nj.all_crash c 
left join people p 
on c.casenumber = p.casenumber
left join nj_2017_lookup.physical_condition pc 
on p.physical_condition = pc.code
left join nj_2017_lookup.crash_type ct 
on c.crash_type = ct.code 
group by initcap(municipality), ct.description, p.physical_condition