--create schema if not exists nj_report;
drop materialized view if exists nj_report.report_summary_long;
create materialized view nj_report.report_summary_long as

with severity_calc as (
select
	p.casenumber,
	c."year" as crash_year,
	case
		MIN(
        case nullif(TRIM(p.physical_condition), '')
            when '01' then 1
            when '02' then 2
            when '03' then 3
            when '04' then 4
            when '05' then 5
            when '00' then 6
            when '99' then 6
            else null
        end
    )
		when 1 then '1'
		when 2 then '2'
		when 3 then '3'
		when 4 then '4'
		when 5 then '9'
		when 6 then '0'
		else null
	end as max_severity_calc,
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as 
	county
from
	nj.all_person p
left join nj.all_crash c on
	p.casenumber = c.casenumber
group by
	p.casenumber,
	"year",
	county
), 
max_severity as (
select
	casenumber,
	case 
		when max_severity_calc = '1' then 'Fatal'
		when max_severity_calc = '2' then 'Suspected Serious Injury'
		when max_severity_calc = '3' then 'Suspected Minor Injury'
		when max_severity_calc = '4' then 'Possible Injury'
		when max_severity_calc = '9' then 'No Apparent Injury'
		when max_severity_calc = '0' then 'Other or Unknown'
		else null
	end as max_severity_level
from
	severity_calc),
bike_ped as (
select 
	casenumber,
	bool_or(case
		when pedestrian is true then true
		else false
	end) as pedestrian_event,
	bool_or(case
		when is_bicycle is true then true
		else false
	end) as bike_event
from 
	nj.all_person p
group by
	casenumber
)

/* =========================================================
   MAX SEVERITY
   ========================================================= */

select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'max severity' as domain,
	'Fatal' as category,
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
		m.max_severity_level = 'Fatal'
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'max severity' as domain,
	'Suspected Serious Injury' as category,
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
		m.max_severity_level = 'Suspected Serious Injury'
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'max severity' as domain,
	'Suspected Minor Injury' as category,
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
		m.max_severity_level = 'Suspected Minor Injury'
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'max severity' as domain,
	'Possible Injury' as category,
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
		m.max_severity_level = 'Possible Injury'
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'max severity' as domain,
	'No Apparent Injury' as category,
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
		m.max_severity_level = 'No Apparent Injury'
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'max severity' as domain,
	'Other or Unknown' as category,
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
		m.max_severity_level = 'Other or Unknown'
		
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'max severity' as domain,
	NULL as category,
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
		m.max_severity_level is null

/* =========================================================
   PERSON INJURY SEVERITY
   ========================================================= */
union all
select
	p.casenumber,
	p.crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'person_injury',
	'Fatal',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
	count(*)
from
	nj.all_person p
left join nj.all_crash c 
on
	p.casenumber = c.casenumber
left join max_severity m 
on
	p.casenumber = m.casenumber
left join bike_ped b 
on
	p.casenumber = b.casenumber
where
	p.physical_condition = '01'
group by
	p.casenumber,
	crash_year,
	municipality,
	c.county,
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event
union all
select
	p.casenumber,
	p.crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'person_injury',
	'Suspected Serious Injury',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
	count(*)
from
	nj.all_person p
left join nj.all_crash c 
on
	p.casenumber = c.casenumber
left join max_severity m 
on
	p.casenumber = m.casenumber
left join bike_ped b 
on
	p.casenumber = b.casenumber
where
	p.physical_condition = '02'
group by
	p.casenumber,
	crash_year,
	municipality,
	c.county,
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event
union all
select
	p.casenumber,
	p.crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'person_injury',
	'Suspected Minor Injury',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
	count(*)
from
	nj.all_person p
left join nj.all_crash c 
on
	p.casenumber = c.casenumber
left join max_severity m 
on
	p.casenumber = m.casenumber
left join bike_ped b 
on
	p.casenumber = b.casenumber
where
	p.physical_condition = '03'
group by
	p.casenumber,
	crash_year,
	municipality,
	c.county,
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event
union all
select
	p.casenumber,
	p.crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'person_injury',
	'Possible Injury',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
	count(*)
from
	nj.all_person p
left join nj.all_crash c 
on
	p.casenumber = c.casenumber
left join max_severity m 
on
	p.casenumber = m.casenumber
left join bike_ped b 
on
	p.casenumber = b.casenumber
where
	p.physical_condition = '04'
group by
	p.casenumber,
	crash_year,
	municipality,
	c.county,
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event
union all
select
	p.casenumber,
	p.crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'person_injury',
	'No Injury',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
	count(*)
from
	nj.all_person p
left join nj.all_crash c 
on
	p.casenumber = c.casenumber
left join max_severity m 
on
	p.casenumber = m.casenumber
left join bike_ped b 
on
	p.casenumber = b.casenumber
where
	p.physical_condition = '05'
group by
	p.casenumber,
	crash_year,
	municipality,
	c.county,
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event
union all
select
	p.casenumber,
	p.crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'person_injury',
	'Other or Unknown',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
	count(*)
from
	nj.all_person p
left join nj.all_crash c 
on
	p.casenumber = c.casenumber
left join max_severity m 
on
	p.casenumber = m.casenumber
left join bike_ped b 
on
	p.casenumber = b.casenumber
where
	p.physical_condition = '99' or p.physical_condition = '00' or p.physical_condition is null
group by
	p.casenumber,
	crash_year,
	municipality,
	c.county,
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event
union all

/* =========================================================
   COLLISION TYPE
   ========================================================= */
	select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'collision_type' as domain,
	'Unknown' as category,
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
		c.crash_type = '00'
	or c.crash_type is null
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'collision_type',
	'Same Direction (Rear End)',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
	c.crash_type = '01'
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'collision_type',
	'Same Direction (Sideswipe)',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
	c.crash_type = '02'
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'collision_type',
	'Right Angle',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
	c.crash_type = '03'
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'collision_type',
	'Opposite Direction (Head On, Angular)',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
	c.crash_type = '04'
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'collision_type',
	'Opposite Direction (Sideswipe)',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
	c.crash_type = '05'
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'collision_type',
	'Struck Parked Vehicle',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
	c.crash_type = '06'
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'collision_type',
	'Left Turn/U Turn',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
	c.crash_type = '07'
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'collision_type',
	'Backing',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
	c.crash_type = '08'
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'collision_type',
	'Encroachment',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
	c.crash_type = '09'
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'collision_type',
	'Overturned',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
	c.crash_type = '10'
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'collision_type',
	'Fixed Object',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
	c.crash_type = '11'
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'collision_type',
	'Animal',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
	c.crash_type = '12'
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'collision_type',
	'Pedestrian',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
	c.crash_type = '13'
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'collision_type',
	'Pedalcyclist',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
	c.crash_type = '14'
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'collision_type',
	'Non-Fixed Object',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
	c.crash_type = '15'
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'collision_type',
	'Railcar - Vehicle',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
	c.crash_type = '16'
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'collision_type',
	'Other',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
	c.crash_type = '99'


/* =========================================================
   MAX SEVERITY LEVEL
   ========================================================= */
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'max_severity_level',
	'Fatal',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
	max_severity_level = '1'
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'max_severity_level',
	'Suspected Serious Injury',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
	max_severity_level = '2'
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'max_severity_level',
	'Suspected Minor Injury',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
	max_severity_level = '3'
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'max_severity_level',
	'Possible Injury',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
	max_severity_level = '4'
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'max_severity_level',
	'No Apparent Injury',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
	max_severity_level = '9'
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'max_severity_level',
	'Other or Unknown',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
	max_severity_level = '0'
	
/* =========================================================
   ROAD CONDITION
   ========================================================= */
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'road_condition',
	'Unknown',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
	c.road_surface_condition = '00'
	or c.road_surface_condition is null
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'road_condition',
	'Dry',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
	c.road_surface_condition = '01'
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'road_condition',
	'Wet',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
	c.road_surface_condition = '02'
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'road_condition',
	'Snow',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
	c.road_surface_condition = '03'
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'road_condition',
	'Icy',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
	c.road_surface_condition = '04'
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'road_condition',
	'Other',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
	c.road_surface_condition in ('05', '06', '07', '08', '09', '99')


/* =========================================================
   WEATHER
   ========================================================= */
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'weather',
	'Unknown',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
	c.environmental_condition = '00'
	or c.environmental_condition is null
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'weather',
	'Clear',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
	c.environmental_condition = '01'
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'weather',
	'Rain',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
	c.environmental_condition = '02'
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'weather',
	'Snow',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
	c.environmental_condition = '03'
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'weather',
	'Other',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
	c.environmental_condition in ('04', '05', '06', '07', '08', '09', '10', '99')



/* =========================================================
   ILLUMINATION
   ========================================================= */
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'illumination',
	'Unknown',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
	c.light_condition = '00'
	or c.light_condition is null
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'illumination',
	'Daylight',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
	c.light_condition = '01'
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'illumination',
	'Dawn',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
	c.light_condition = '02'
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'illumination',
	'Dusk',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
	c.light_condition = '03'
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'illumination',
	'Dark (street lights off)',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
	c.light_condition = '04'
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'illumination',
	'Dark (no street lights)',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
	c.light_condition = '05'
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'illumination',
	'Dark (streetlights on, continuous)',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
	c.light_condition = '06'
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'illumination',
	'Dark (streetlights on, spot)',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
	c.light_condition = '07'
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'illumination',
	'Other',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
where
	c.light_condition = '99'

/* =========================================================
   MONTH / DAY / HOUR
   ========================================================= */
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'month',
	case 
when cast(extract(month from c."date") as text) = '1' then 'January'
when cast(extract(month from c."date") as text) = '2' then 'February'
when cast(extract(month from c."date") as text) = '3' then 'March'
when cast(extract(month from c."date") as text) = '4' then 'April'
when cast(extract(month from c."date") as text) = '5' then 'May'
when cast(extract(month from c."date") as text) = '6' then 'June'
when cast(extract(month from c."date") as text) = '7' then 'July'
when cast(extract(month from c."date") as text) = '8' then 'August'
when cast(extract(month from c."date") as text) = '9' then 'September'
when cast(extract(month from c."date") as text) = '10' then 'October'
when cast(extract(month from c."date") as text) = '11' then 'November'
when cast(extract(month from c."date") as text) = '12' then 'December'
	else null
end,
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'day_of_week',
	case
		when c.day_of_week = 'MO' then 'Monday'
		when c.day_of_week = 'TU' then 'Tuesday'
		when c.day_of_week = 'WE' then 'Wednesday'
		when c.day_of_week = 'TH' then 'Thursday'
		when c.day_of_week = 'FR' then 'Friday'
		when c.day_of_week = 'SA' then 'Saturday'
		when c.day_of_week = 'SU' then 'Sunday'
		else null
	end,
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber
union all
select
	c.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'hour',
	left(c.time_of_day,
	2),
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
		1 as cnt
from
		nj.all_crash c
left join max_severity m on
		c.casenumber = m.casenumber
left join bike_ped b on 
		c.casenumber = b.casenumber

/* =========================================================
   VEHICLE TYPE
   ========================================================= */
union all
select
	v.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'vehicle',
	'unknown',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
	count(*)
from
	nj.all_vehicle v
left join nj.all_crash c 
on
	v.casenumber = c.casenumber
left join max_severity m 
on
	v.casenumber = m.casenumber
left join bike_ped b 
on
	v.casenumber = b.casenumber
where
	v.veh_type = '00'
	or v.veh_type is null
group by
	v.casenumber,
	crash_year,
	municipality,
	c.county,
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event
union all
select
	v.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'vehicle',
	'Car/Stationwagon/Minivan',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
	count(*)
from
	nj.all_vehicle v
left join nj.all_crash c 
on
	v.casenumber = c.casenumber
left join max_severity m 
on
	v.casenumber = m.casenumber
left join bike_ped b 
on
	v.casenumber = b.casenumber
where
	v.veh_type = '01'
group by
	v.casenumber,
	crash_year,
	municipality,
	c.county,
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event
union all
select
	v.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'vehicle',
	'SUV',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
	count(*)
from
	nj.all_vehicle v
left join nj.all_crash c 
on
	v.casenumber = c.casenumber
left join max_severity m 
on
	v.casenumber = m.casenumber
left join bike_ped b 
on
	v.casenumber = b.casenumber
where
	v.veh_type = '04'
group by
	v.casenumber,
	crash_year,
	municipality,
	c.county,
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event
union all
select
	v.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'vehicle',
	'Motorcycle',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
	count(*)
from
	nj.all_vehicle v
left join nj.all_crash c 
on
	v.casenumber = c.casenumber
left join max_severity m 
on
	v.casenumber = m.casenumber
left join bike_ped b 
on
	v.casenumber = b.casenumber
where
	v.veh_type = '08'
group by
	v.casenumber,
	crash_year,
	municipality,
	c.county,
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event
union all
select
	v.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'vehicle',
	'Pick up',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
	count(*)
from
	nj.all_vehicle v
left join nj.all_crash c 
on
	v.casenumber = c.casenumber
left join max_severity m 
on
	v.casenumber = m.casenumber
left join bike_ped b 
on
	v.casenumber = b.casenumber
where
	v.veh_type = '05'
group by
	v.casenumber,
	crash_year,
	municipality,
	c.county,
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event
union all
select
	v.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'vehicle',
	'Large Truck',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
	count(*)
from
	nj.all_vehicle v
left join nj.all_crash c 
on
	v.casenumber = c.casenumber
left join max_severity m 
on
	v.casenumber = m.casenumber
left join bike_ped b 
on
	v.casenumber = b.casenumber
where
	v.veh_type in ('20', '21', '22', '23', '24', '25', '26', '27', '29')
group by
	v.casenumber,
	crash_year,
	municipality,
	c.county,
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event
union all
select
	v.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'vehicle',
	'Other Motor',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
	count(*)
from
	nj.all_vehicle v
left join nj.all_crash c 
on
	v.casenumber = c.casenumber
left join max_severity m 
on
	v.casenumber = m.casenumber
left join bike_ped b 
on
	v.casenumber = b.casenumber
where
	v.veh_type in ('02', '03', '06', '07', '10', '15', '16', '19', '30', '31', '40', '99')
group by
	v.casenumber,
	crash_year,
	municipality,
	c.county,
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event
union all
select
	v.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'vehicle',
	'Other Nonmotor',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
	count(*)
from
	nj.all_vehicle v
left join nj.all_crash c 
on
	v.casenumber = c.casenumber
left join max_severity m 
on
	v.casenumber = m.casenumber
left join bike_ped b 
on
	v.casenumber = b.casenumber
where
	v.veh_type in ('12', '14')
group by
	v.casenumber,
	crash_year,
	municipality,
	c.county,
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event
union all
select
	v.casenumber,
	c."year" as crash_year,
	initcap(c.municipality) as municipality,
	initcap(c.county) as county,
	'vehicle',
	'Bicycle',
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event,
	count(*)
from
	nj.all_vehicle v
left join nj.all_crash c 
on
	v.casenumber = c.casenumber
left join max_severity m 
on
	v.casenumber = m.casenumber
left join bike_ped b 
on
	v.casenumber = b.casenumber
where
	v.veh_type = '13'
group by
	v.casenumber,
	crash_year,
	municipality,
	c.county,
	m.max_severity_level,
	b.pedestrian_event,
	b.bike_event

