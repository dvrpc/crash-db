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
		when max_severity_calc = '1' then 'fatal'
		when max_severity_calc = '2' then 'suspected serious injury'
		when max_severity_calc = '3' then 'suspected minor injury'
		when max_severity_calc = '4' then 'possible injury'
		when max_severity_calc = '9' then 'no apparent injury'
		when max_severity_calc = '0' then 'other or unknown'
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
   COLLISION TYPE
   ========================================================= */
	select
	c.casenumber,
	c."year" as crash_year,
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
		'collision_type' as domain,
		'unknown' as category,
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
	c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'collision_type',
	'same_direction_rearend',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
		c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'collision_type',
	'same_direction_sideswipe',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
		c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'collision_type',
	'right_angle',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
		c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'collision_type',
	'opposite_direction_headon_angular',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
		c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'collision_type',
	'opposite_direction_sideswipe',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
		c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'collision_type',
	'struck_parked_vehicle',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
		c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'collision_type',
	'left_turn_u_turn',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
		c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'collision_type',
	'backing',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
		c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'collision_type',
	'encroachment',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
		c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'collision_type',
	'overturned',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
		c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'collision_type',
	'fixed_object',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
		c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'collision_type',
	'animal',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
		c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'collision_type',
	'pedestrian',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
		c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'collision_type',
	'pedalcyclist',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
		c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'collision_type',
	'non_fixed_object',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
		c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'collision_type',
	'railcar_vehicle',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
		c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'collision_type',
	'other',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
		c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'max_severity_level',
	'fatal',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
		c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'max_severity_level',
	'suspected serious injury',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
		c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'max_severity_level',
	'suspected minor injury',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
		c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'max_severity_level',
	'possible injury',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
		c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'max_severity_level',
	'no apparent injury',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
		c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'max_severity_level',
	'other or unknown',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
		c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'road_condition',
	'unknown',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
		c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'road_condition',
	'dry',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
		c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'road_condition',
	'wet',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
		c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'road_condition',
	'snow',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
		c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'road_condition',
	'icy',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
		c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'road_condition',
	'other',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
		c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'weather',
	'unknown',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
		c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'weather',
	'clear',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
		c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'weather',
	'rain',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
		c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'weather',
	'snow',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
		c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'weather',
	'other',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
		c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'illumination',
	'unknown',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
		c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'illumination',
	'daylight',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
		c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'illumination',
	'dawn',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
		c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'illumination',
	'dusk',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
		c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'illumination',
	'dark_street_lights_off',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
		c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'illumination',
	'dark_no_street_lights',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
		c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'illumination',
	'dark_streetlight_continuous',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
		c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'illumination',
	'dark_streetlight_spot',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
		c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'illumination',
	'other',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
		c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'month',
	cast(extract(month
from
	c."date") as text),
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
		c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
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
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,		
	c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'hour',
	left(c.time_of_day,
	2),
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
	c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
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
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'vehicle',
	'unknown',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
	c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
	b.pedestrian_event,
	b.bike_event,
	count(*)
from
	nj.all_vehicle v
left join nj.all_crash c 
on
	v.casenumber = c.casenumber
left join max_severity m 
on v.casenumber = m.casenumber
left join bike_ped b 
on v.casenumber = b.casenumber
where
	v.veh_type = '00'
	or v.veh_type is null
group by
	v.casenumber,
	crash_year,
	c.county,
	facility_type,
	c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
	b.pedestrian_event,
	b.bike_event
union all
select
	v.casenumber,
	c."year" as crash_year,
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'vehicle',
	'car_stationwagon_minivan',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
	c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
	b.pedestrian_event,
	b.bike_event,
	count(*)
from
	nj.all_vehicle v
left join nj.all_crash c 
on
	v.casenumber = c.casenumber
left join max_severity m 
on v.casenumber = m.casenumber
left join bike_ped b 
on v.casenumber = b.casenumber
where
	v.veh_type = '01'
group by
	v.casenumber,
	crash_year,
	c.county,
	facility_type,
	c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
	b.pedestrian_event,
	b.bike_event
union all
select
	v.casenumber,
	c."year" as crash_year,
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'vehicle',
	'motorcycle',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
	c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
	b.pedestrian_event,
	b.bike_event,
	count(*)
from
	nj.all_vehicle v
left join nj.all_crash c 
on
	v.casenumber = c.casenumber
left join max_severity m 
on v.casenumber = m.casenumber
left join bike_ped b 
on v.casenumber = b.casenumber
where
	v.veh_type = '08'
group by
	v.casenumber,
	crash_year,
	c.county,
	facility_type,
	c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
	b.pedestrian_event,
	b.bike_event
union all
select
	v.casenumber,
	c."year" as crash_year,
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'vehicle',
	'small_truck',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
	c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
	b.pedestrian_event,
	b.bike_event,
	count(*)
from
	nj.all_vehicle v
left join nj.all_crash c 
on
	v.casenumber = c.casenumber
left join max_severity m 
on v.casenumber = m.casenumber
left join bike_ped b 
on v.casenumber = b.casenumber
where
	v.veh_type = '05'
group by
	v.casenumber,
	crash_year,
	c.county,
	facility_type,
	c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
	b.pedestrian_event,
	b.bike_event
union all
select
	v.casenumber,
	c."year" as crash_year,
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'vehicle',
	'large_truck',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
	c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
	b.pedestrian_event,
	b.bike_event,
	count(*)
from
	nj.all_vehicle v
left join nj.all_crash c 
on
	v.casenumber = c.casenumber
left join max_severity m 
on v.casenumber = m.casenumber
left join bike_ped b 
on v.casenumber = b.casenumber
where
	v.veh_type in ('20', '21', '22', '23', '24', '25', '26', '27', '29')
group by
	v.casenumber,
	crash_year,
	c.county,
	facility_type,
	c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
	b.pedestrian_event,
	b.bike_event
union all
select
	v.casenumber,
	c."year" as crash_year,
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'vehicle',
	'other_motor',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
	c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
	b.pedestrian_event,
	b.bike_event,
	count(*)
from
	nj.all_vehicle v
left join nj.all_crash c 
on
	v.casenumber = c.casenumber
left join max_severity m 
on v.casenumber = m.casenumber
left join bike_ped b 
on v.casenumber = b.casenumber
where
	v.veh_type in ('02', '03', '04', '06', '07', '10', '15', '16', '19', '30', '31', '40', '99')
group by
	v.casenumber,
	crash_year,
	c.county,
	facility_type,
	c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
	b.pedestrian_event,
	b.bike_event
union all
select
	v.casenumber,
	c."year" as crash_year,
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'vehicle',
	'other_nonmotor',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
	c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
	b.pedestrian_event,
	b.bike_event,
	count(*)
from
	nj.all_vehicle v
left join nj.all_crash c 
on
	v.casenumber = c.casenumber
left join max_severity m 
on v.casenumber = m.casenumber
left join bike_ped b 
on v.casenumber = b.casenumber
where
	v.veh_type in ('12', '14')
group by
	v.casenumber,
	crash_year,
	c.county,
	facility_type,
	c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
	b.pedestrian_event,
	b.bike_event
union all
select
	v.casenumber,
	c."year" as crash_year,
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'vehicle',
	'bicycle',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
	c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
	b.pedestrian_event,
	b.bike_event,
	count(*)
from
	nj.all_vehicle v
left join nj.all_crash c 
on
	v.casenumber = c.casenumber
left join max_severity m 
on v.casenumber = m.casenumber
left join bike_ped b 
on v.casenumber = b.casenumber
where
	v.veh_type = '13'
group by
	v.casenumber,
	crash_year,
	c.county,
	facility_type,
	c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
	b.pedestrian_event,
	b.bike_event

/* =========================================================
   PERSON INJURY SEVERITY
   ========================================================= */
union all
select
	p.casenumber,
	p.crash_year,
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'person_injury',
	'unknown',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
	c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
	b.pedestrian_event,
	b.bike_event,
	count(*)
from
	nj.all_person p
left join nj.all_crash c 
on
	p.casenumber = c.casenumber
left join max_severity m 
on p.casenumber = m.casenumber 
left join bike_ped b 
on p.casenumber = b.casenumber
where
	p.physical_condition = '00'
	or p.physical_condition is null
group by
	p.casenumber,
	crash_year,
	c.county,
	facility_type,
	c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
	b.pedestrian_event,
	b.bike_event
union all
select
	p.casenumber,
	p.crash_year,
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'person_injury',
	'fatal',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
	c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
	b.pedestrian_event,
	b.bike_event,
	count(*)
from
	nj.all_person p
left join nj.all_crash c 
on
	p.casenumber = c.casenumber
left join max_severity m 
on p.casenumber = m.casenumber 
left join bike_ped b 
on p.casenumber = b.casenumber
where
	p.physical_condition = '01'
group by
	p.casenumber,
	crash_year,
	c.county,
	facility_type,
	c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
	b.pedestrian_event,
	b.bike_event
union all
select
	p.casenumber,
	p.crash_year,
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'person_injury',
	'serious',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
	c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
	b.pedestrian_event,
	b.bike_event,
	count(*)
from
	nj.all_person p
left join nj.all_crash c 
on
	p.casenumber = c.casenumber
left join max_severity m 
on p.casenumber = m.casenumber 
left join bike_ped b 
on p.casenumber = b.casenumber
where
	p.physical_condition = '02'
group by
	p.casenumber,
	crash_year,
	c.county,
	facility_type,
	c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
	b.pedestrian_event,
	b.bike_event
union all
select
	p.casenumber,
	p.crash_year,
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'person_injury',
	'minor',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
	c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
	b.pedestrian_event,
	b.bike_event,
	count(*)
from
	nj.all_person p
left join nj.all_crash c 
on
	p.casenumber = c.casenumber
left join max_severity m 
on p.casenumber = m.casenumber 
left join bike_ped b 
on p.casenumber = b.casenumber
where
	p.physical_condition = '03'
group by
	p.casenumber,
	crash_year,
	c.county,
	facility_type,
	c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
	b.pedestrian_event,
	b.bike_event
union all
select
	p.casenumber,
	p.crash_year,
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'person_injury',
	'possible',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
	c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
	b.pedestrian_event,
	b.bike_event,
	count(*)
from
	nj.all_person p
left join nj.all_crash c 
on
	p.casenumber = c.casenumber
left join max_severity m 
on p.casenumber = m.casenumber 
left join bike_ped b 
on p.casenumber = b.casenumber
where
	p.physical_condition = '04'
group by
	p.casenumber,
	crash_year,
	c.county,
	facility_type,
	c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
	b.pedestrian_event,
	b.bike_event
union all
select
	p.casenumber,
	p.crash_year,
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'person_injury',
	'no_injury',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
	c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
	b.pedestrian_event,
	b.bike_event,
	count(*)
from
	nj.all_person p
left join nj.all_crash c 
on
	p.casenumber = c.casenumber
left join max_severity m 
on p.casenumber = m.casenumber 
left join bike_ped b 
on p.casenumber = b.casenumber
where
	p.physical_condition = '05'
group by
	p.casenumber,
	crash_year,
	c.county,
	facility_type,
	c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
	b.pedestrian_event,
	b.bike_event
union all
select
	p.casenumber,
	p.crash_year,
	case
		when c.county in ('Burlington', 'BURLINGTON') then 'BURLINGTON'
		when c.county in ('Camden', 'CAMDEN') then 'CAMDEN'
		when c.county in ('Gloucester', 'GLOUCESTER') then 'GLOUCESTER'
		when c.county in ('Mercer', 'MERCER') then 'MERCER'
		else null
	end as county,
	'person_injury',
	'other',
	case 
		when road_system in ('01', '02', '03') then 'highway/interstate'
		when road_system in ('05', '06', '07') then 'local'
		else 'other'
	end as facility_type,
	c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
	b.pedestrian_event,
	b.bike_event,
	count(*)
from
	nj.all_person p
left join nj.all_crash c 
on
	p.casenumber = c.casenumber
left join max_severity m 
on p.casenumber = m.casenumber 
left join bike_ped b 
on p.casenumber = b.casenumber
where
	p.physical_condition = '99'
group by
	p.casenumber,
	crash_year,
	c.county,
	facility_type,
	c.route,
	c.sri,
	m.max_severity_level,
	c.milepost,
	b.pedestrian_event,
	b.bike_event
	
/*
=========================================================
   --CRASH YEAR (GROUPED SUMMARY)
========================================================= 
union all
select
    null as casenumber,
    'year' as domain,
    c."year"::text as category,
    count(*) as cnt
from nj.all_crash c
where c."year"::int between 2017 and 2022
group by c."year";*/
