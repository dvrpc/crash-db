drop  materialized view if exists nj.report_summary_long;

create materialized view nj.report_summary_long as

/* =========================================================
   COLLISION TYPE
   ========================================================= */
select c.casenumber, "year" AS crash_year, 'collision_type' as domain, 'unknown' as category, 1 as cnt
from nj.all_crash c where c.crash_type = '00' or c.crash_type is null

union all
select c.casenumber, "year" AS crash_year, 'collision_type', 'same_direction_rearend', 1
from nj.all_crash c where c.crash_type = '01'

union all
select c.casenumber, "year" AS crash_year, 'collision_type', 'same_direction_sideswipe', 1
from nj.all_crash c where c.crash_type = '02'

union all
select c.casenumber, "year" AS crash_year, 'collision_type', 'right_angle', 1
from nj.all_crash c where c.crash_type = '03'

union all
select c.casenumber, "year" AS crash_year, 'collision_type', 'opposite_direction_headon_angular', 1
from nj.all_crash c where c.crash_type = '04'

union all
select c.casenumber, "year" AS crash_year, 'collision_type', 'opposite_direction_sideswipe', 1
from nj.all_crash c where c.crash_type = '05'

union all
select c.casenumber, "year" AS crash_year, 'collision_type', 'struck_parked_vehicle', 1
from nj.all_crash c where c.crash_type = '06'

union all
select c.casenumber, "year" AS crash_year, 'collision_type', 'left_turn_u_turn', 1
from nj.all_crash c where c.crash_type = '07'

union all
select c.casenumber, "year" AS crash_year, 'collision_type', 'backing', 1
from nj.all_crash c where c.crash_type = '08'

union all
select c.casenumber, "year" AS crash_year, 'collision_type', 'encroachment', 1
from nj.all_crash c where c.crash_type = '09'

union all
select c.casenumber, "year" AS crash_year, 'collision_type', 'overturned', 1
from nj.all_crash c where c.crash_type = '10'

union all
select c.casenumber, "year" AS crash_year, 'collision_type', 'fixed_object', 1
from nj.all_crash c where c.crash_type = '11'

union all
select c.casenumber, "year" AS crash_year, 'collision_type', 'animal', 1
from nj.all_crash c where c.crash_type = '12'

union all
select c.casenumber, "year" AS crash_year, 'collision_type', 'pedestrian', 1
from nj.all_crash c where c.crash_type = '13'

union all
select c.casenumber, "year" AS crash_year, 'collision_type', 'pedalcyclist', 1
from nj.all_crash c where c.crash_type = '14'

union all
select c.casenumber, "year" AS crash_year, 'collision_type', 'non_fixed_object', 1
from nj.all_crash c where c.crash_type = '15'

union all
select c.casenumber, "year" AS crash_year, 'collision_type', 'railcar_vehicle', 1
from nj.all_crash c where c.crash_type = '16'


union all
select c.casenumber, "year" AS crash_year, 'collision_type', 'other', 1
from nj.all_crash c where c.crash_type = '99'


/* =========================================================
   MAX SEVERITY LEVEL
   ========================================================= */
union all
select c.casenumber, "year" AS crash_year, 'severity', 'no_injury', 1
from nj.all_crash c where c.severity = 'P'

union all
select c.casenumber, "year" AS crash_year, 'severity', 'fatal', 1
from nj.all_crash c where c.severity = 'F'

union all
select c.casenumber, "year" AS crash_year, 'severity', 'injury', 1
from nj.all_crash c where c.severity = 'I'


/* =========================================================
   ROAD CONDITION
   ========================================================= */
union all
select c.casenumber, "year" AS crash_year, 'road_condition', 'unknown', 1
from nj.all_crash c where c.road_surface_condition = '00' or c.road_surface_condition is null

union all
select c.casenumber, "year" AS crash_year, 'road_condition', 'dry', 1
from nj.all_crash c where c.road_surface_condition = '01'

union all
select c.casenumber, "year" AS crash_year, 'road_condition', 'wet', 1
from nj.all_crash c where c.road_surface_condition = '02'

union all
select c.casenumber, "year" AS crash_year, 'road_condition', 'snow', 1
from nj.all_crash c where c.road_surface_condition = '03'

union all
select c.casenumber, "year" AS crash_year, 'road_condition', 'icy', 1
from nj.all_crash c where c.road_surface_condition = '04'

union all
select c.casenumber, "year" AS crash_year, 'road_condition', 'other', 1
from nj.all_crash c where c.road_surface_condition in ('05', '06', '07', '08', '09', '99')


/* =========================================================
   WEATHER
   ========================================================= */
union all
select c.casenumber, "year" AS crash_year, 'weather', 'unknown', 1
from nj.all_crash c where c.environmental_condition = '00' or c.environmental_condition is null

union all
select c.casenumber, "year" AS crash_year, 'weather', 'clear', 1
from nj.all_crash c where c.environmental_condition = '01'

union all
select c.casenumber, "year" AS crash_year, 'weather', 'rain', 1
from nj.all_crash c where c.environmental_condition = '02'

union all
select c.casenumber, "year" AS crash_year, 'weather', 'snow', 1
from nj.all_crash c where c.environmental_condition = '03'

union all
select c.casenumber, "year" AS crash_year, 'weather', 'other', 1
from nj.all_crash c where c.environmental_condition in ('04', '05', '06', '07', '08', '09', '10', '99')



/* =========================================================
   ILLUMINATION
   ========================================================= */
union all
select c.casenumber, "year" AS crash_year, 'illumination', 'unknown', 1
from nj.all_crash c where c.light_condition = '00' or c.light_condition is null

union all
select c.casenumber, "year" AS crash_year, 'illumination', 'daylight', 1
from nj.all_crash c where c.light_condition = '01'

union all
select c.casenumber, "year" AS crash_year, 'illumination', 'dawn', 1
from nj.all_crash c where c.light_condition = '02'

union all
select c.casenumber, "year" AS crash_year, 'illumination', 'dusk', 1
from nj.all_crash c where c.light_condition = '03'

union all
select c.casenumber, "year" AS crash_year, 'illumination', 'dark_street_lights_off', 1
from nj.all_crash c where c.light_condition = '04'

union all
select c.casenumber, "year" AS crash_year, 'illumination', 'dark_no_street_lights', 1
from nj.all_crash c where c.light_condition = '05'

union all
select c.casenumber, "year" AS crash_year, 'illumination', 'dark_streetlight_continuous', 1
from nj.all_crash c where c.light_condition = '06'

union all
select c.casenumber, "year" AS crash_year, 'illumination', 'dark_streetlight_spot', 1
from nj.all_crash c where c.light_condition = '07'

union all
select c.casenumber, "year" AS crash_year, 'illumination', 'other', 1
from nj.all_crash c where c.light_condition = '99'

/* =========================================================
   MONTH / DAY / HOUR
   ========================================================= */
union all
select c.casenumber, "year" AS crash_year, 'month', cast(extract(month from c."date") as text), 1
from nj.all_crash c 


union all
select
	c.casenumber,
	"year" as crash_year,
	'day_of_week',
	case
		when c.day_of_week = 'MO' then 'Monday'
		when c.day_of_week = 'TU' then 'Tuesday'
		when c.day_of_week = 'WE' then 'Wednesday'
		when c.day_of_week = 'TH' then 'Thursday'
		when c.day_of_week = 'FR' then 'Friday'
		when c.day_of_week = 'SA' then 'Saturday'
		when c.day_of_week = 'SU' then 'Sunday'
		else null end,
		1
	from
		nj.all_crash c

union all
select c.casenumber, "year" AS crash_year, 'hour', left(c.time_of_day, 2), 1
from nj.all_crash c


/* =========================================================
   VEHICLE TYPE
   ========================================================= */
union all
select v.casenumber, "year" AS crash_year, 'vehicle', 'unknown', count(*)
from nj.all_vehicle v where v.veh_type = '00' or v.veh_type is null
group by v.casenumber, v."year"

union all
select v.casenumber, "year" AS crash_year, 'vehicle', 'car_stationwagon_minivan', count(*)
from nj.all_vehicle v where v.veh_type = '01'
group by v.casenumber, v."year"

union all
select v.casenumber, "year" AS crash_year, 'vehicle', 'motorcycle', count(*)
from nj.all_vehicle v where v.veh_type = '08'
group by v.casenumber, v."year"

union all
select v.casenumber, "year" AS crash_year, 'vehicle', 'small_truck', count(*)
from nj.all_vehicle v where v.veh_type = '05'
group by v.casenumber, v."year"

union all
select v.casenumber, "year" AS crash_year, 'vehicle', 'large_truck', count(*)
from nj.all_vehicle v where v.veh_type in ('20', '21', '22', '23', '24', '25', '26', '27', '29')
group by v.casenumber, v."year"

union all
select v.casenumber, "year" AS crash_year, 'vehicle', 'other_motor', count(*)
from nj.all_vehicle v
where v.veh_type in ('02', '03', '04', '06', '07', '10', '15', '16', '19', '30', '31', '40', '99')
group by v.casenumber, v."year"

union all
select v.casenumber, "year" AS crash_year, 'vehicle', 'other_nonmotor', count(*)
from nj.all_vehicle v
where v.veh_type in ('12', '14')
group by v.casenumber, v."year"

union all
select v.casenumber, "year" AS crash_year, 'vehicle', 'bicycle', count(*)
from nj.all_vehicle v where v.veh_type = '13'
group by v.casenumber, v."year"

/* =========================================================
   PERSON INJURY SEVERITY
   ========================================================= */
union all
select p.casenumber, p.crash_year, 'person_injury', 'unknown', count(*)
from nj.all_person p where p.physical_condition = '00' or p.physical_condition is null
group by p.casenumber, p.crash_year

union all
select p.casenumber, p.crash_year, 'person_injury', 'fatal', count(*)
from nj.all_person p where p.physical_condition = '01'
group by p.casenumber, p.crash_year

union all
select p.casenumber, p.crash_year, 'person_injury', 'serious', count(*)
from nj.all_person p where p.physical_condition = '02'
group by p.casenumber,  p.crash_year

union all
select p.casenumber, p.crash_year, 'person_injury', 'minor', count(*)
from nj.all_person p where p.physical_condition = '03'
group by p.casenumber,  p.crash_year

union all
select p.casenumber, p.crash_year, 'person_injury', 'possible', count(*)
from nj.all_person p where p.physical_condition = '04'
group by p.casenumber,  p.crash_year

union all
select p.casenumber, p.crash_year, 'person_injury', 'no_injury', count(*)
from nj.all_person p where p.physical_condition = '05'
group by p.casenumber,  p.crash_year

union all
select p.casenumber, p.crash_year, 'person_injury', 'other', count(*)
from nj.all_person p where p.physical_condition = '99'
group by p.casenumber,  p.crash_year


/* 
--CRASH YEAR (GROUPED SUMMARY)
 
union all
select
    null as casenumber,
    'year' as domain,
    c."year"::text as category,
    count(*) as cnt
from nj.all_crash c
where c."year"::int between 2017 and 2022
group by c."year";
*/
