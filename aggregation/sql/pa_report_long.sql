drop materialized view if exists pa.report_summary_long;

create materialized view pa.report_summary_long as

/* =========================================================
   COLLISION TYPE
   ========================================================= */
select c.crn, c.crash_year, 'collision_type' as domain, 'noncollision' as category, 1 as cnt
from pa.all_crash c where c.collision_type = '0' or c.collision_type is null

union all
select c.crn, c.crash_year, 'collision_type', 'rearend', 1
from pa.all_crash c where c.collision_type = '1'

union all
select c.crn, c.crash_year, 'collision_type', 'headon', 1
from pa.all_crash c where c.collision_type = '2'

union all
select c.crn, c.crash_year, 'collision_type', 'backing', 1
from pa.all_crash c where c.collision_type = '3'

union all
select c.crn, c.crash_year, 'collision_type', 'angle', 1
from pa.all_crash c where c.collision_type = '4'

union all
select c.crn, c.crash_year, 'collision_type', 'sideswipe_same', 1
from pa.all_crash c where c.collision_type = '5'

union all
select c.crn, c.crash_year, 'collision_type', 'sideswipe_opposite', 1
from pa.all_crash c where c.collision_type = '6'

union all
select c.crn, c.crash_year, 'collision_type', 'hit_fixed_object', 1
from pa.all_crash c where c.collision_type = '7'

union all
select c.crn, c.crash_year, 'collision_type', 'hit_nonmotorist', 1
from pa.all_crash c where c.collision_type = '8'

union all
select c.crn, c.crash_year, 'collision_type', 'other_unknown', 1
from pa.all_crash c where c.collision_type in ('9','98','99')


/* =========================================================
   MAX SEVERITY LEVEL
   ========================================================= */
union all
select c.crn, c.crash_year, 'severity', 'no_injury', 1
from pa.all_crash c where c.max_severity_level = '0'

union all
select c.crn, c.crash_year, 'severity', 'fatal', 1
from pa.all_crash c where c.max_severity_level = '1'

union all
select c.crn, c.crash_year, 'severity', 'serious', 1
from pa.all_crash c where c.max_severity_level = '2'

union all
select c.crn, c.crash_year, 'severity', 'minor', 1
from pa.all_crash c where c.max_severity_level = '3'

union all
select c.crn, c.crash_year, 'severity', 'possible', 1
from pa.all_crash c where c.max_severity_level = '4'

union all
select c.crn, c.crash_year, 'severity', 'injury_unknown', 1
from pa.all_crash c where c.max_severity_level in ('8','9') or c.max_severity_level is null


/* =========================================================
   ROAD CONDITION
   ========================================================= */
union all
select c.crn, c.crash_year, 'road_condition', 'dry', 1
from pa.all_crash c where c.road_condition = '01'

union all
select c.crn, c.crash_year, 'road_condition', 'ice', 1
from pa.all_crash c where c.road_condition = '02'

union all
select c.crn, c.crash_year, 'road_condition', 'snow', 1
from pa.all_crash c where c.road_condition = '07'

union all
select c.crn, c.crash_year, 'road_condition', 'water', 1
from pa.all_crash c where c.road_condition = '08'

union all
select c.crn, c.crash_year, 'road_condition', 'wet', 1
from pa.all_crash c where c.road_condition = '09'

union all
select c.crn, c.crash_year, 'road_condition', 'other', 1
from pa.all_crash c
where c.road_condition in ('03','04','05','06','22','98')

union all
select c.crn, c.crash_year, 'road_condition', 'unknown', 1
from pa.all_crash c where c.road_condition = '99' or c.road_condition is null


/* =========================================================
   WEATHER
   ========================================================= */
union all
select c.crn, c.crash_year, 'weather', 'clear', 1
from pa.all_crash c where c.weather1 = '03'

union all
select c.crn, c.crash_year, 'weather', 'cloudy', 1
from pa.all_crash c where c.weather1 = '04'

union all
select c.crn, c.crash_year, 'weather', 'fog_smog_smoke', 1
from pa.all_crash c where c.weather1 = '05'

union all
select c.crn, c.crash_year, 'weather', 'rain', 1
from pa.all_crash c where c.weather1 = '07'

union all
select c.crn, c.crash_year, 'weather', 'snow', 1
from pa.all_crash c where c.weather1 = '10'

union all
select c.crn, c.crash_year, 'weather', 'other', 1
from pa.all_crash c
where c.weather1 in ('01','02','06','08','09','98')

union all
select c.crn, c.crash_year, 'weather', 'unknown', 1
from pa.all_crash c where c.weather1 = '99' or c.weather1 is null


/* =========================================================
   ILLUMINATION
   ========================================================= */
union all
select c.crn, c.crash_year, 'illumination', 'daylight', 1
from pa.all_crash c where c.illumination = '1'

union all
select c.crn, c.crash_year, 'illumination', 'dark_no_street', 1
from pa.all_crash c where c.illumination = '2'

union all
select c.crn, c.crash_year, 'illumination', 'dark_street', 1
from pa.all_crash c where c.illumination = '3'

union all
select c.crn, c.crash_year, 'illumination', 'dawn_dusk', 1
from pa.all_crash c where c.illumination in ('4','5')

union all
select c.crn, c.crash_year, 'illumination', 'other_unknown', 1
from pa.all_crash c where c.illumination in ('6','8','9') or c.illumination is null


/* =========================================================
   MONTH / DAY / HOUR
   ========================================================= */
union all
select c.crn, c.crash_year, 'month', c.crash_month, 1
from pa.all_crash c

union all
select c.crn, c.crash_year, 'day_of_week', c.day_of_week, 1
from pa.all_crash c

union all
select c.crn, c.crash_year, 'hour', c.hour_of_day, 1
from pa.all_crash c


/* =========================================================
   VEHICLE TYPE (COUNTS PER CRASH)
   ========================================================= */
union all
select v.crn, c.crash_year, 'vehicle', 'automobile', count(*)
from pa.all_vehicle v 
INNER JOIN pa.all_crash c 
ON v.crn = c.crn
where v.veh_type = '01'
group by v.crn, c.crash_year

union all
select v.crn, c.crash_year, 'vehicle', 'motorcycle', count(*)
from pa.all_vehicle v 
INNER JOIN pa.all_crash c 
ON v.crn = c.crn
where v.veh_type = '02'
group by v.crn, c.crash_year

union all
select v.crn, c.crash_year, 'vehicle', 'bus', count(*)
from pa.all_vehicle v 
INNER JOIN pa.all_crash c 
ON v.crn = c.crn
where v.veh_type = '03'
group by v.crn, c.crash_year

union all
select v.crn, c.crash_year, 'vehicle', 'small_truck', count(*)
from pa.all_vehicle v 
INNER JOIN pa.all_crash c 
ON v.crn = c.crn
where v.veh_type = '04'
group by v.crn, c.crash_year

union all
select v.crn, c.crash_year, 'vehicle', 'large_truck', count(*)
from pa.all_vehicle v 
INNER JOIN pa.all_crash c 
ON v.crn = c.crn
where v.veh_type = '05'
group by v.crn, c.crash_year

union all
select v.crn, c.crash_year, 'vehicle', 'other_motor', count(*)
from pa.all_vehicle v
INNER JOIN pa.all_crash c 
ON v.crn = c.crn
where v.veh_type in ('06','07','08','09','10','11','12','13','14','15','16','17','18','19')
group by v.crn, c.crash_year

union all
select v.crn, c.crash_year, 'vehicle', 'bicycle', count(*)
from pa.all_vehicle v 
INNER JOIN pa.all_crash c 
ON v.crn = c.crn
where v.veh_type = '20'
group by v.crn, c.crash_year

union all
select v.crn, c.crash_year, 'vehicle', 'pedestrian', count(*)
from pa.all_vehicle v 
INNER JOIN pa.all_crash c 
ON v.crn = c.crn
where v.veh_type = '31'
group by v.crn, c.crash_year

union all
select v.crn, c.crash_year, 'vehicle', 'other_nonmotor', count(*)
from pa.all_vehicle v
INNER JOIN pa.all_crash c 
ON v.crn = c.crn
where v.veh_type in ('21','22','23','24','25','32','33','34','35','36','98')
group by v.crn, c.crash_year

union all
select v.crn, c.crash_year, 'vehicle', 'unknown', count(*)
from pa.all_vehicle v 
INNER JOIN pa.all_crash c 
ON v.crn = c.crn
where v.veh_type = '99' or v.veh_type is null
group by v.crn, c.crash_year


/* =========================================================
   PERSON INJURY SEVERITY (COUNTS PER CRASH)
   ========================================================= */
union all
select p.crn, c.crash_year, 'person_injury', 'not_injured', count(*)
from pa.all_person p 
INNER JOIN pa.all_crash c 
ON p.crn = c.crn
where p.inj_severity = '0'
group by p.crn, c.crash_year

union all
select p.crn, c.crash_year, 'person_injury', 'fatal', count(*)
from pa.all_person p 
INNER JOIN pa.all_crash c 
ON p.crn = c.crn
where p.inj_severity = '1'
group by p.crn, c.crash_year

union all
select p.crn, c.crash_year, 'person_injury', 'serious', count(*)
from pa.all_person p 
INNER JOIN pa.all_crash c 
ON p.crn = c.crn
where p.inj_severity = '2'
group by p.crn, c.crash_year

union all
select p.crn, c.crash_year, 'person_injury', 'minor', count(*)
from pa.all_person p 
INNER JOIN pa.all_crash c 
ON p.crn = c.crn
where p.inj_severity = '3'
group by p.crn, c.crash_year

union all
select p.crn, c.crash_year, 'person_injury', 'possible', count(*)
from pa.all_person p 
INNER JOIN pa.all_crash c 
ON p.crn = c.crn
where p.inj_severity = '4'
group by p.crn, c.crash_year

union all
select p.crn, c.crash_year, 'person_injury', 'injury_unknown', count(*)
from pa.all_person p 
INNER JOIN pa.all_crash c 
ON p.crn = c.crn
where p.inj_severity in ('8','9') or p.inj_severity is null
group by p.crn, c.crash_year


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