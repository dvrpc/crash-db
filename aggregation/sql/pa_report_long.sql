create schema if not exists pa_report;
drop materialized view if exists pa_report.report_summary_long;
create materialized view pa_report.report_summary_long as

with counties as (
select
	crn,
	case
		when c.county = '09' then 'BUCKS'
		when c.county = '15' then 'CHESTER'
		when c.county = '23' then 'DELAWARE'
		when c.county = '46' then 'MONTGOMERY'
		when c.county = '67' then 'PHILADELPHIA'
		else null
	end as county
from
	pa.all_crash c)

/* =========================================================
   COLLISION TYPE
   ========================================================= */
select
	c.crn,
	c.crash_year,
	cnt.county,
		'collision_type' as domain,
		'noncollision' as category,
		count(distinct(c.crn)) as cnt
from
		pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
		c.collision_type = '0'
	or c.collision_type is null
group by
	c.crn,
	c.crash_year,
	cnt.county
union all
select
	c.crn,
	c.crash_year,
	cnt.county,
	'collision_type',
	'rearend',
	count(distinct(c.crn)) as cnt
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.collision_type = '1'
group by
	c.crn,
	c.crash_year,
	cnt.county
union all
select
	c.crn,
	c.crash_year,
	cnt.county,
	'collision_type',
	'headon',
	count(distinct(c.crn)) as cnt
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.collision_type = '2'
group by
	c.crn,
	c.crash_year,
	cnt.county
union all
select
	c.crn,
	c.crash_year,
	cnt.county,
	'collision_type',
	'backing',
	count(distinct(c.crn)) as cnt
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.collision_type = '3'
group by
	c.crn,
	c.crash_year,
	cnt.county
union all
select
	c.crn,
	c.crash_year,
	cnt.county,
	'collision_type',
	'angle',
	count(distinct(c.crn)) as cnt
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.collision_type = '4'
group by
	c.crn,
	c.crash_year,
	cnt.county
union all
select
	c.crn,
	c.crash_year,
	cnt.county,
	'collision_type',
	'sideswipe_same',	
	count(distinct(c.crn)) as cnt
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.collision_type = '5'
group by
	c.crn,
	c.crash_year,
	cnt.county
union all
select
	c.crn,
	c.crash_year,
	cnt.county,
	'collision_type',
	'sideswipe_opposite',
	count(distinct(c.crn)) as cnt
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.collision_type = '6'
group by
	c.crn,
	c.crash_year,
	cnt.county
union all
select
	c.crn,
	c.crash_year,
	cnt.county,
	'collision_type',
	'hit_fixed_object',
	count(distinct(c.crn)) as cnt
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.collision_type = '7'
group by
	c.crn,
	c.crash_year,
	cnt.county
union all
select
	c.crn,
	c.crash_year,
	cnt.county,
	'collision_type',
	'hit_nonmotorist',
	count(distinct(c.crn)) as cnt
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.collision_type = '8'
group by
	c.crn,
	c.crash_year,
	cnt.county
union all
select
	c.crn,
	c.crash_year,
	cnt.county,
	'collision_type',
	'other_unknown',	
	count(distinct(c.crn)) as cnt
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.collision_type in ('9', '98', '99')
group by
	c.crn,
	c.crash_year,
	cnt.county

/* =========================================================
   MAX SEVERITY LEVEL
   ========================================================= */
union all
select
	c.crn,
	c.crash_year,
	cnt.county,
	'severity',
	'no_injury',	
	count(distinct(c.crn)) as cnt
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.max_severity_level = '0'
group by 
	c.crn,
	c.crash_year,
	cnt.county
union all
select
	c.crn,
	c.crash_year,
	cnt.county,
	'severity',
	'fatal',
	count(distinct(c.crn)) as cnt
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.max_severity_level = '1'
group by 
	c.crn,
	c.crash_year,
	cnt.county
union all
select
	c.crn,
	c.crash_year,
	cnt.county,
	'severity',
	'serious',	
	count(distinct(c.crn)) as cnt
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.max_severity_level = '2'
group by 
	c.crn,
	c.crash_year,
	cnt.county
union all
select
	c.crn,
	c.crash_year,
	cnt.county,
	'severity',
	'minor',	
	count(distinct(c.crn)) as cnt
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.max_severity_level = '3'
group by 
	c.crn,
	c.crash_year,
	cnt.county
union all
select
	c.crn,
	c.crash_year,
	cnt.county,
	'severity',
	'possible',	
	count(distinct(c.crn)) as cnt
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.max_severity_level = '4'
group by 
	c.crn,
	c.crash_year,
	cnt.county
union all
select
	c.crn,
	c.crash_year,
	cnt.county,
	'severity',
	'injury_unknown',	
	count(distinct(c.crn)) as cnt
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.max_severity_level in ('8', '9')
	or c.max_severity_level is null
group by 
	c.crn,
	c.crash_year,
	cnt.county

/* =========================================================
   ROAD CONDITION
   ========================================================= */
union all
select
	c.crn,
	c.crash_year,
	cnt.county,
	'road_condition',
	'dry',
	count(distinct(c.crn)) as cnt
from
	pa.all_crash c

left join counties cnt
on
	cnt.crn = c.crn
where
	c.road_condition = '01'
group by 
	c.crn,
	c.crash_year,
	cnt.county
union all
select
	c.crn,
	c.crash_year,
	cnt.county,
	'road_condition',
	'ice',	
	count(distinct(c.crn)) as cnt
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.road_condition = '02'
group by 
	c.crn,
	c.crash_year,
	cnt.county
union all
select
	c.crn,
	c.crash_year,
	cnt.county,
	'road_condition',
	'snow',
	count(distinct(c.crn)) as cnt
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.road_condition = '07'
group by 
	c.crn,
	c.crash_year,
	cnt.county
union all
select
	c.crn,
	c.crash_year,
	cnt.county,
	'road_condition',
	'water',	
	count(distinct(c.crn)) as cnt
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.road_condition = '08'
group by 
	c.crn,
	c.crash_year,
	cnt.county
union all
select
	c.crn,
	c.crash_year,
	cnt.county,
	'road_condition',
	'wet',
	count(distinct(c.crn)) as cnt
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.road_condition = '09'
group by 
	c.crn,
	c.crash_year,
	cnt.county
union all
select
	c.crn,
	c.crash_year,
	cnt.county,
	'road_condition',
	'other',	
	count(distinct(c.crn)) as cnt
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.road_condition in ('03', '04', '05', '06', '22', '98')
group by 
	c.crn,
	c.crash_year,
	cnt.county
union all
select
	c.crn,
	c.crash_year,
	cnt.county,
	'road_condition',
	'unknown',	
	count(distinct(c.crn)) as cnt
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.road_condition = '99'
	or c.road_condition is null
group by 
	c.crn,
	c.crash_year,
	cnt.county


/* =========================================================
   WEATHER
   ========================================================= */
union all
select
	c.crn,
	c.crash_year,
	cnt.county,
	'weather',
	'clear',
	count(distinct(c.crn)) as cnt
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.weather1 = '03'
group by 
	c.crn,
	c.crash_year,
	cnt.county
union all
select
	c.crn,
	c.crash_year,
	cnt.county,
	'weather',
	'cloudy',
	count(distinct(c.crn)) as cnt
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.weather1 = '04'
group by 
	c.crn,
	c.crash_year,
	cnt.county
union all
select
	c.crn,
	c.crash_year,
	cnt.county,
	'weather',
	'fog_smog_smoke',	
	count(distinct(c.crn)) as cnt
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.weather1 = '05'
group by 
	c.crn,
	c.crash_year,
	cnt.county
union all
select
	c.crn,
	c.crash_year,
	cnt.county,
	'weather',
	'rain',
	count(distinct(c.crn)) as cnt
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.weather1 = '07'
group by 
	c.crn,
	c.crash_year,
	cnt.county
union all
select
	c.crn,
	c.crash_year,
	cnt.county,
	'weather',
	'snow',
	count(distinct(c.crn)) as cnt
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.weather1 = '10'
group by 
	c.crn,
	c.crash_year,
	cnt.county
union all
select
	c.crn,
	c.crash_year,
	cnt.county,
	'weather',
	'other',
	count(distinct(c.crn)) as cnt
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.weather1 in ('01', '02', '06', '08', '09', '98')
group by 
	c.crn,
	c.crash_year,
	cnt.county
union all
select
	c.crn,
	c.crash_year,
	cnt.county,
	'weather',
	'unknown',
	count(distinct(c.crn)) as cnt
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.weather1 = '99'
	or c.weather1 is null
group by 
	c.crn,
	c.crash_year,
	cnt.county


/* =========================================================
   ILLUMINATION
   ========================================================= */
union all
select
	c.crn,
	c.crash_year,
	cnt.county,
	'illumination',
	'daylight',
	count(distinct(c.crn)) as cnt
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.illumination = '1'
group by 
	c.crn,
	c.crash_year,
	cnt.county
union all
select
	c.crn,
	c.crash_year,
	cnt.county,
	'illumination',
	'dark_no_street',
	count(distinct(c.crn)) as cnt
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.illumination = '2'
group by 
	c.crn,
	c.crash_year,
	cnt.county
union all
select
	c.crn,
	c.crash_year,
	cnt.county,
	'illumination',
	'dark_street',
	count(distinct(c.crn)) as cnt
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.illumination = '3'
group by 
	c.crn,
	c.crash_year,
	cnt.county
union all
select
	c.crn,
	c.crash_year,
	cnt.county,
	'illumination',
	'dawn_dusk',
	count(distinct(c.crn)) as cnt
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.illumination in ('4', '5')
group by 
	c.crn,
	c.crash_year,
	cnt.county
union all
select
	c.crn,
	c.crash_year,
	cnt.county,
	'illumination',
	'other_unknown',
	count(distinct(c.crn)) as cnt
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
where
	c.illumination in ('6', '8', '9')
	or c.illumination is null
group by 
	c.crn,
	c.crash_year,
	cnt.county


/* =========================================================
   MONTH / DAY / HOUR
   ========================================================= */
union all
select
	c.crn,
	c.crash_year,
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
	count(distinct(c.crn)) as cnt
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
group by 
	c.crn,
	c.crash_year,
	cnt.county,
	crash_month
union all
select
	c.crn,
	c.crash_year,
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
	count(distinct(c.crn)) as cnt
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
group by 
	c.crn,
	c.crash_year,
	cnt.county,
	day_of_week
union all
select
	c.crn,
	c.crash_year,
	cnt.county,
	'hour',
	c.hour_of_day,
	count(distinct(c.crn)) as cnt
from
	pa.all_crash c
left join counties cnt
on
	cnt.crn = c.crn
group by 
	c.crn,
	c.crash_year,
	cnt.county,
	c.hour_of_day


/* =========================================================
   VEHICLE TYPE (COUNTS PER CRASH)
   ========================================================= */
union all
select
	v.crn,
	c.crash_year,
	cnt.county,
	'vehicle',
	'automobile',
	count(distinct(c.crn, unit_num))
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
group by
	v.crn,
	c.crash_year,
	cnt.county
union all
select
	v.crn,
	c.crash_year,
	cnt.county,
	'vehicle',
	'motorcycle',
	count(distinct(c.crn, unit_num))
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
group by
	v.crn,
	c.crash_year,
	cnt.county
union all
select
	v.crn,
	c.crash_year,
	cnt.county,
	'vehicle',
	'bus',
	count(distinct(c.crn, unit_num))
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
group by
	v.crn,
	c.crash_year,
	cnt.county
union all
select
	v.crn,
	c.crash_year,
	cnt.county,
	'vehicle',
	'small_truck',
	count(distinct(c.crn, unit_num))
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
group by
	v.crn,
	c.crash_year,
	cnt.county
union all
select
	v.crn,
	c.crash_year,
	cnt.county,
	'vehicle',
	'large_truck',
	count(distinct(c.crn, unit_num))
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
group by
	v.crn,
	c.crash_year,
	cnt.county
union all
select
	v.crn,
	c.crash_year,
	cnt.county,
	'vehicle',
	'other_motor',
	count(distinct(c.crn, unit_num))
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
group by
	v.crn,
	c.crash_year,
	cnt.county
union all
select
	v.crn,
	c.crash_year,
	cnt.county,
	'vehicle',
	'bicycle',
	count(distinct(c.crn, unit_num))
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
group by
	v.crn,
	c.crash_year,
	cnt.county
union all
select
	v.crn,
	c.crash_year,
	cnt.county,
	'vehicle',
	'pedestrian',
	count(distinct(c.crn, unit_num))
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
group by
	v.crn,
	c.crash_year,
	cnt.county
union all
select
	v.crn,
	c.crash_year,
	cnt.county,
	'vehicle',
	'other_nonmotor',
	count(distinct(c.crn, unit_num))
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
group by
	v.crn,
	c.crash_year,
	cnt.county
union all
select
	v.crn,
	c.crash_year,
	cnt.county,
	'vehicle',
	'unknown',
	count(distinct(c.crn, unit_num))
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
group by
	v.crn,
	c.crash_year,
	cnt.county


/* =========================================================
   PERSON INJURY SEVERITY (COUNTS PER CRASH)
   ========================================================= */
union all
select
	p.crn,
	c.crash_year,
	cnt.county,
	'person_injury',
	'not_injured',
	count(distinct(p.crn, p.unit_num, p.person_num))
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
group by 
	p.crn,
	c.crash_year,
	cnt.county
union all
select
	p.crn,
	c.crash_year,
	cnt.county,
	'person_injury',
	'fatal',
	count(distinct(p.crn, p.person_num))
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
group by 
	p.crn,
	c.crash_year,
	cnt.county
union all
select
	p.crn,
	c.crash_year,
	cnt.county,
	'person_injury',
	'serious',
	count(distinct(p.crn, p.unit_num, p.person_num))
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
group by 
	p.crn,
	c.crash_year,
	cnt.county
union all
select
	p.crn,
	c.crash_year,
	cnt.county,
	'person_injury',
	'minor',
	count(distinct(p.crn, p.unit_num, p.person_num))
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
group by 
	p.crn,
	c.crash_year,
	cnt.county
union all
select
	p.crn,
	c.crash_year,
	cnt.county,
	'person_injury',
	'possible',
	count(distinct(p.crn, p.unit_num, p.person_num))
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
group by 
	p.crn,
	c.crash_year,
	cnt.county
union all
select
	p.crn,
	c.crash_year,
	cnt.county,
	'person_injury',
	'injury_unknown',
	count(distinct(p.crn, p.unit_num, p.person_num))
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
group by 
	p.crn,
	c.crash_year,
	cnt.county

/* =========================================================
   CRASH YEAR (GROUPED SUMMARY)
   ========================================================= 
union all
select
    null::bigint as crn,
    'year' as domain,
    c.crash_year::text as category,
    count(*) as cnt
from pa.all_crash c
where c.crash_year::int between 2019 and 2023
group by c.crash_year;
*/