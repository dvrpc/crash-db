--create schema if not exists pa_report;
drop materialized view if exists pa_report.report_summary_long;
create materialized view pa_report.report_summary_long as

with counties as (
select
	crn,
	initcap(case
		when c.county = '09' then 'BUCKS'
		when c.county = '15' then 'CHESTER'
		when c.county = '23' then 'DELAWARE'
		when c.county = '46' then 'MONTGOMERY'
		when c.county = '67' then 'PHILADELPHIA'
		else null
	end) as county,
	l.description as municipality
from
	pa.all_crash c
	left join pa_lookup.municipalities l 
	on c.municipality = l.code)
	
/* =========================================================
   MAX SEVERITY
   ========================================================= */	
select
	c.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'max severity' as domain,
	'fatal' as category,
	1 as cnt
from
		pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
		c.max_severity_level = '1'
union all	
select
	c.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'max severity' as domain,
	'supsected serious injury' as category,
	1 as cnt
from
		pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
		c.max_severity_level = '2'
union all	
select
	c.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'max severity' as domain,
	'suspected minor injury' as category,
	1 as cnt
from
		pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
		c.max_severity_level = '3'
union all	
select
	c.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'max severity' as domain,
	'possible injury' as category,
	1 as cnt
from
		pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
		c.max_severity_level = '4'
union all	
select
	c.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'max severity' as domain,
	'injury - unknown severity' as category,
	1 as cnt
from
		pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
		c.max_severity_level = '8'
union all	
select
	c.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'max severity' as domain,
	'unknown' as category,
	1 as cnt
from
		pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
		c.max_severity_level = '9'
union all
select
	c.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'max severity' as domain,
	'property damage only' as category,
	1 as cnt
from
		pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
		c.max_severity_level = '0'
		

/* =========================================================
   PERSON INJURY SEVERITY
   ========================================================= */
union all
select
	p.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'person_injury',
	'not_injured',
	1
from
	pa.all_person p
inner join pa.all_crash c 
on
	p.crn = c.crn
left join counties cnt
on
	cnt.crn = c.crn
where
	p.inj_severity = '0'
union all
select
	p.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'person_injury',
	'fatal',
	1
from
	pa.all_person p
inner join pa.all_crash c 
on
	p.crn = c.crn
left join counties cnt
on
	cnt.crn = c.crn
where
	p.inj_severity = '1'
union all
select
	p.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'person_injury',
	'serious',
	1
from
	pa.all_person p
inner join pa.all_crash c 
on
	p.crn = c.crn
left join counties cnt
on
	cnt.crn = c.crn
where
	p.inj_severity = '2'
union all
select
	p.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'person_injury',
	'minor',
	1
from
	pa.all_person p
inner join pa.all_crash c 
on
	p.crn = c.crn
left join counties cnt
on
	cnt.crn = c.crn
where
	p.inj_severity = '3'
union all
select
	p.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'person_injury',
	'possible',
	1
from
	pa.all_person p
inner join pa.all_crash c 
on
	p.crn = c.crn
left join counties cnt
on
	cnt.crn = c.crn
where
	p.inj_severity = '4'
union all
select
	p.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'person_injury',
	'injury_unknown',
	1
from
	pa.all_person p
inner join pa.all_crash c 
on
	p.crn = c.crn
left join counties cnt
on
	cnt.crn = c.crn
where
	p.inj_severity in ('8', '9')
	or p.inj_severity is null

	
/* =========================================================
   COLLISION TYPE
   ========================================================= */
union all
select
	c.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'collision_type' as domain,
	'noncollision' as category,
	1 as cnt
from
		pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
		c.collision_type = '0'
	or c.collision_type is null

union all
select
	c.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'collision_type',
	'rearend',
	1
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.collision_type = '1'
union all
select
	c.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'collision_type',
	'headon',
	1
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.collision_type = '2'
union all
select
	c.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'collision_type',
	'backing',
	1
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.collision_type = '3'
union all
select
	c.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'collision_type',
	'angle',
	1
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.collision_type = '4'
union all
select
	c.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'collision_type',
	'sideswipe_same',	
	1
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.collision_type = '5'
union all
select
	c.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'collision_type',
	'sideswipe_opposite',
	1
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.collision_type = '6'
union all
select
	c.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'collision_type',
	'hit_fixed_object',
	1
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.collision_type = '7'
union all
select
	c.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'collision_type',
	'hit_nonmotorist',
	1
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.collision_type = '8'
union all
select
	c.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'collision_type',
	'other_unknown',	
	1
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.collision_type in ('9', '98', '99')

/* =========================================================
   MAX SEVERITY LEVEL
   ========================================================= */
union all
select
	c.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'severity',
	'no_injury',	
	1
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.max_severity_level = '0'
union all
select
	c.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'severity',
	'fatal',
	1
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.max_severity_level = '1'
union all
select
	c.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'severity',
	'serious',	
	1
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.max_severity_level = '2'
union all
select
	c.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'severity',
	'minor',	
	1
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.max_severity_level = '3'
union all
select
	c.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'severity',
	'possible',	
	1
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.max_severity_level = '4'
union all
select
	c.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'severity',
	'injury_unknown',	
	1
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.max_severity_level in ('8', '9')
	or c.max_severity_level is null

/* =========================================================
   ROAD CONDITION
   ========================================================= */
union all
select
	c.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'road_condition',
	'dry',
	1
from
	pa.all_crash c

left join counties cnt
on
	cnt.crn = c.crn
where
	c.road_condition = '01'
union all
select
	c.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'road_condition',
	'ice',	
	1
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.road_condition = '02'
union all
select
	c.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'road_condition',
	'snow',
	1
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.road_condition = '07'
union all
select
	c.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'road_condition',
	'water',	
	1
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.road_condition = '08'
union all
select
	c.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'road_condition',
	'wet',
	1
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.road_condition = '09'
union all
select
	c.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'road_condition',
	'other',	
	1
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.road_condition in ('03', '04', '05', '06', '22', '98')
union all
select
	c.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'road_condition',
	'unknown',	
	1
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.road_condition = '99'
	or c.road_condition is null


/* =========================================================
   WEATHER
   ========================================================= */
union all
select
	c.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'weather',
	'clear',
	1
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.weather1 = '03'
union all
select
	c.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'weather',
	'cloudy',
	1
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.weather1 = '04'
union all
select
	c.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'weather',
	'fog_smog_smoke',	
	1
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.weather1 = '05'
union all
select
	c.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'weather',
	'rain',
	1
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.weather1 = '07'
union all
select
	c.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'weather',
	'snow',
	1
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.weather1 = '10'
union all
select
	c.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'weather',
	'other',
	1
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.weather1 in ('01', '02', '06', '08', '09', '98')
union all
select
	c.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'weather',
	'unknown',
	1
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.weather1 = '99'
	or c.weather1 is null


/* =========================================================
   ILLUMINATION
   ========================================================= */
union all
select
	c.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'illumination',
	'daylight',
	1
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.illumination = '1'
union all
select
	c.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'illumination',
	'dark_no_street',
	1
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.illumination = '2'
union all
select
	c.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'illumination',
	'dark_street',
	1
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.illumination = '3'
union all
select
	c.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'illumination',
	'dawn_dusk',
	1
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.illumination in ('4', '5')
union all
select
	c.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'illumination',
	'other_unknown',
	1
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.illumination in ('6', '8', '9')
	or c.illumination is null


/* =========================================================
   MONTH / DAY / HOUR
   ========================================================= */
union all
select
	c.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'month',
	case 
		when c.crash_month = '01' then 'January'
		when c.crash_month = '02' then 'February'
		when c.crash_month = '03' then 'March'
		when c.crash_month = '04' then 'April'
		when c.crash_month = '05' then 'May'
		when c.crash_month = '06' then 'June'
		when c.crash_month = '07' then 'July'
		when c.crash_month = '08' then 'August'
		when c.crash_month = '09' then 'September'
		when c.crash_month = '10' then 'October'
		when c.crash_month = '11' then 'November'
		when c.crash_month = '12' then 'December'
	end as crash_month
	,	
	1
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
union all
select
	c.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'day_of_week',
	case 
		when c.day_of_week = '1' then 'Sunday'
		when c.day_of_week = '2' then 'Monday'
		when c.day_of_week = '3' then 'Tuesday'
		when c.day_of_week = '4' then 'Wednesday'
		when c.day_of_week = '5' then 'Thursday'
		when c.day_of_week = '6' then 'Friday'
		when c.day_of_week = '7' then 'Saturday'
	end as day_of_week,
	1
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
union all
select
	c.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'hour',
	c.hour_of_day,
	1
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn


/* =========================================================
   VEHICLE TYPE (COUNTS PER CRASH)
   ========================================================= */
union all
select
	v.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'vehicle',
	'automobile',
	1
from
	pa.all_vehicle v
inner join pa.all_crash c 
on
	v.crn = c.crn
left join counties cnt
on
	cnt.crn = c.crn
where
	v.veh_type = '01'
union all
select
	v.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'vehicle',
	'motorcycle',
	1
from
	pa.all_vehicle v
inner join pa.all_crash c 
on
	v.crn = c.crn
left join counties cnt
on
	cnt.crn = c.crn
where
	v.veh_type = '02'
union all
select
	v.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'vehicle',
	'bus',
	1
from
	pa.all_vehicle v
inner join pa.all_crash c 
on
	v.crn = c.crn
left join counties cnt
on
	cnt.crn = c.crn
where
	v.veh_type = '03'
union all
select
	v.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'vehicle',
	'small_truck',
	1
from
	pa.all_vehicle v
inner join pa.all_crash c 
on
	v.crn = c.crn
left join counties cnt
on
	cnt.crn = c.crn
where
	v.veh_type = '04'
union all
select
	v.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'vehicle',
	'large_truck',
	1
from
	pa.all_vehicle v
inner join pa.all_crash c 
on
	v.crn = c.crn
left join counties cnt
on
	cnt.crn = c.crn
where
	v.veh_type = '05'
union all
select
	v.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'vehicle',
	'other_motor',
	1
from
	pa.all_vehicle v
inner join pa.all_crash c 
on
	v.crn = c.crn
left join counties cnt
on
	cnt.crn = c.crn
where
	v.veh_type in ('06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19')
union all
select
	v.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'vehicle',
	'bicycle',
	1
from
	pa.all_vehicle v
inner join pa.all_crash c 
on
	v.crn = c.crn
left join counties cnt
on
	cnt.crn = c.crn
where
	v.veh_type = '20'
union all
select
	v.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'vehicle',
	'pedestrian',
	1
from
	pa.all_vehicle v
inner join pa.all_crash c 
on
	v.crn = c.crn
left join counties cnt
on
	cnt.crn = c.crn
where
	v.veh_type = '31'
union all
select
	v.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'vehicle',
	'other_nonmotor',
	1
from
	pa.all_vehicle v
inner join pa.all_crash c 
on
	v.crn = c.crn
left join counties cnt
on
	cnt.crn = c.crn
where
	v.veh_type in ('21', '22', '23', '24', '25', '32', '33', '34', '35', '36', '98')
union all
select
	v.crn,
	c.crash_year,
	cnt.municipality,
	cnt.county,
	'vehicle',
	'unknown',
	1
from
	pa.all_vehicle v
inner join pa.all_crash c 
on
	v.crn = c.crn
left join counties cnt
on
	cnt.crn = c.crn
where
	v.veh_type = '99'
	or v.veh_type is null

