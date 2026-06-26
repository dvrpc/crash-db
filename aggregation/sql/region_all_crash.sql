drop materialized view if exists region.all_crash;
create materialized view region.all_crash as 

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
		when max_severity_calc = '1' then 'fatal'
		when max_severity_calc = '2' then 'suspected serious injury'
		when max_severity_calc = '3' then 'suspected minor injury'
		when max_severity_calc = '4' then 'possible injury'
		when max_severity_calc = '9' then 'no apparent injury'
		when max_severity_calc = '0' then 'other or unknown'
		else null
	end as max_severity_level
from
	severity_calc)
,
crash_type_standard as 
(
--nj
select 
	c.casenumber as crn,
	'NJ' as state,
	INITCAP(c.county) as county,
	ms.max_severity_level,
	cast(extract(month
from
	c."date") as text) as crash_month,
	case
		when c.day_of_week = 'MO' then 'Monday'
		when c.day_of_week = 'TU' then 'Tuesday'
		when c.day_of_week = 'WE' then 'Wednesday'
		when c.day_of_week = 'TH' then 'Thursday'
		when c.day_of_week = 'FR' then 'Friday'
		when c.day_of_week = 'SA' then 'Saturday'
		when c.day_of_week = 'SU' then 'Sunday'
		else null
	end as day_of_week,
	time_of_day,
	case 
		when c.crash_type = '01' then 'rear-end'
		when c.crash_type in ('03', '07') then 'angle/intersection'
		when c.crash_type in ('02', '05') then 'sideswipe'
		when c.crash_type = '04' then 'head-on/opposing'
		when c.crash_type in ('06', '11') then 'fixed object'
		when c.crash_type in ('13', '14') then 'non-motorist'
		when c.crash_type = '08' then 'backing'
		else 'other/non-collision'
	end as crash_type,
	case 
		when c.light_condition = '00' then 'unknown'
		when c.light_condition = '01' then 'daylight'
		when c.light_condition = '02' then 'dawn'
		when c.light_condition = '03' then 'dusk'
		when c.light_condition in ('04', '05') then 'dark - no streetlights'
		when c.light_condition in ('06', '07') then 'dark -streetlights'
		when c.light_condition = '99' then 'other'
		else null
	end as illumination
from
	nj.all_crash c
left join max_severity ms
on c.casenumber = ms.casenumber
union all
--pa
select
		c.crn::text,
		'PA' as state,
		case
		when c.county = '09' then 'Bucks'
		when c.county = '15' then 'Chester'
		when c.county = '23' then 'Delaware'
		when c.county = '46' then 'Montgomery'
		when c.county = '67' then 'Philadelphia'
		else null
	end as county,
	case 
		when max_severity_level = '1' then 'fatal'
		when max_severity_level = '2' then 'suspected serious injury'
		when max_severity_level = '3' then 'suspected minor injury'
		when max_severity_level = '4' then 'possible injury'
		when max_severity_level = '0' then 'no apparent injury'
		when max_severity_level in ('8', '9') then 'other or unknown'
	end as
	max_severity_level,
		case 
		when c.crash_month = '01' then '1'
		when c.crash_month = '02' then '2'
		when c.crash_month = '03' then '3'
		when c.crash_month = '04' then '4'
		when c.crash_month = '05' then '5'
		when c.crash_month = '06' then '6'
		when c.crash_month = '07' then '7'
		when c.crash_month = '08' then '8'
		when c.crash_month = '09' then '9'
		when c.crash_month = '10' then '10'
		when c.crash_month = '11' then '11'
		when c.crash_month = '12' then '12'
	end as crash_month,
		case 
		when c.day_of_week = '1' then 'Sunday'
		when c.day_of_week = '2' then 'Monday'
		when c.day_of_week = '3' then 'Tuesday'
		when c.day_of_week = '4' then 'Wednesday'
		when c.day_of_week = '5' then 'Thursday'
		when c.day_of_week = '6' then 'Friday'
		when c.day_of_week = '7' then 'Saturday'
	end as day_of_week,
		time_of_day,
		case
		when c.collision_type = '1' then 'rear-end'
		when c.collision_type = '4' then 'angle/intersection'
		when c.collision_type in ('5', '6') then 'sideswipe'
		when c.collision_type = '2' then 'head-on/opposing'
		when c.collision_type = '7' then 'fixed object'
		when c.collision_type = '8' then 'non-motorist'
		when c.collision_type = '3' then 'backing'
		else 'other/non-collision'
	end as crash_type,
	case 
		when c.illumination = '9' then 'unknown'
		when c.illumination = '1' then 'daylight'
		when c.illumination = '2' then 'dark - no streetlights'
		when c.illumination = '3' then 'dark - streetlights'
		when c.illumination = '4' then 'dusk'
		when c.illumination = '5' then 'dawn'
		when c.illumination = '6' then 'dark - unknown lighting'
		when c.illumination = '8' then 'other'
		else null
	end as illumination
from
		pa.all_crash c
			)
			 
select
	*
from
	crash_type_standard;