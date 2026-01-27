drop view if exists nj.report_summary_long;

create view nj.report_summary_long as

/* =========================================================
   COLLISION TYPE
   ========================================================= */
select c.casenumber, 'collision_type' as domain, 'noncollision' as category, 1 as cnt
from nj.all_crash c where c.collision_type = '0'

union all
select c.casenumber, 'collision_type', 'rearend', 1
from nj.all_crash c where c.collision_type = '1'

union all
select c.casenumber, 'collision_type', 'headon', 1
from nj.all_crash c where c.collision_type = '2'

union all
select c.casenumber, 'collision_type', 'backing', 1
from nj.all_crash c where c.collision_type = '3'

union all
select c.casenumber, 'collision_type', 'angle', 1
from nj.all_crash c where c.collision_type = '4'

union all
select c.casenumber, 'collision_type', 'sideswipe_same', 1
from nj.all_crash c where c.collision_type = '5'

union all
select c.casenumber, 'collision_type', 'sideswipe_opposite', 1
from nj.all_crash c where c.collision_type = '6'

union all
select c.casenumber, 'collision_type', 'hit_fixed_object', 1
from nj.all_crash c where c.collision_type = '7'

union all
select c.casenumber, 'collision_type', 'hit_nonmotorist', 1
from nj.all_crash c where c.collision_type = '8'

union all
select c.casenumber, 'collision_type', 'other_unknown', 1
from nj.all_crash c where c.collision_type in ('9','98','99')


/* =========================================================
   MAX SEVERITY LEVEL
   ========================================================= */
union all
select c.casenumber, 'severity', 'no_injury', 1
from nj.all_crash c where c.max_severity_level = '0'

union all
select c.casenumber, 'severity', 'fatal', 1
from nj.all_crash c where c.max_severity_level = '1'

union all
select c.casenumber, 'severity', 'serious', 1
from nj.all_crash c where c.max_severity_level = '2'

union all
select c.casenumber, 'severity', 'minor', 1
from nj.all_crash c where c.max_severity_level = '3'

union all
select c.casenumber, 'severity', 'possible', 1
from nj.all_crash c where c.max_severity_level = '4'

union all
select c.casenumber, 'severity', 'injury_unknown', 1
from nj.all_crash c where c.max_severity_level in ('8','9')


/* =========================================================
   ROAD CONDITION
   ========================================================= */
union all
select c.casenumber, 'road_condition', 'dry', 1
from nj.all_crash c where c.road_condition = '01'

union all
select c.casenumber, 'road_condition', 'ice', 1
from nj.all_crash c where c.road_condition = '02'

union all
select c.casenumber, 'road_condition', 'snow', 1
from nj.all_crash c where c.road_condition = '07'

union all
select c.casenumber, 'road_condition', 'water', 1
from nj.all_crash c where c.road_condition = '08'

union all
select c.casenumber, 'road_condition', 'wet', 1
from nj.all_crash c where c.road_condition = '09'

union all
select c.casenumber, 'road_condition', 'other', 1
from nj.all_crash c
where c.road_condition in ('03','04','05','06','22','98')

union all
select c.casenumber, 'road_condition', 'unknown', 1
from nj.all_crash c where c.road_condition = '99'


/* =========================================================
   WEATHER
   ========================================================= */
union all
select c.casenumber, 'weather', 'clear', 1
from nj.all_crash c where c.weather1 = '03'

union all
select c.casenumber, 'weather', 'cloudy', 1
from nj.all_crash c where c.weather1 = '04'

union all
select c.casenumber, 'weather', 'fog_smog_smoke', 1
from nj.all_crash c where c.weather1 = '05'

union all
select c.casenumber, 'weather', 'rain', 1
from nj.all_crash c where c.weather1 = '07'

union all
select c.casenumber, 'weather', 'snow', 1
from nj.all_crash c where c.weather1 = '10'

union all
select c.casenumber, 'weather', 'other', 1
from nj.all_crash c
where c.weather1 in ('01','02','06','08','09','98')

union all
select c.casenumber, 'weather', 'unknown', 1
from nj.all_crash c where c.weather1 = '99'


/* =========================================================
   ILLUMINATION
   ========================================================= */
union all
select c.casenumber, 'illumination', 'daylight', 1
from nj.all_crash c where c.illumination = '1'

union all
select c.casenumber, 'illumination', 'dark_no_street', 1
from nj.all_crash c where c.illumination = '2'

union all
select c.casenumber, 'illumination', 'dark_street', 1
from nj.all_crash c where c.illumination = '3'

union all
select c.casenumber, 'illumination', 'dawn_dusk', 1
from nj.all_crash c where c.illumination in ('4','5')

union all
select c.casenumber, 'illumination', 'other_unknown', 1
from nj.all_crash c where c.illumination in ('6','8','9')


/* =========================================================
   MONTH / DAY / HOUR
   ========================================================= */
union all
select c.casenumber, 'month', c.crash_month, 1
from nj.all_crash c

union all
select c.casenumber, 'day_of_week', c.day_of_week, 1
from nj.all_crash c

union all
select c.casenumber, 'hour', c.hour_of_day, 1
from nj.all_crash c


/* =========================================================
   VEHICLE TYPE (COUNTS PER CRASH)
   ========================================================= */
union all
select v.casenumber, 'vehicle', 'automobile', count(*)
from nj.all_vehicle v where v.veh_type = '01'
group by v.casenumber

union all
select v.casenumber, 'vehicle', 'motorcycle', count(*)
from nj.all_vehicle v where v.veh_type = '02'
group by v.casenumber

union all
select v.casenumber, 'vehicle', 'bus', count(*)
from nj.all_vehicle v where v.veh_type = '03'
group by v.casenumber

union all
select v.casenumber, 'vehicle', 'small_truck', count(*)
from nj.all_vehicle v where v.veh_type = '04'
group by v.casenumber

union all
select v.casenumber, 'vehicle', 'large_truck', count(*)
from nj.all_vehicle v where v.veh_type = '05'
group by v.casenumber

union all
select v.casenumber, 'vehicle', 'other_motor', count(*)
from nj.all_vehicle v
where v.veh_type in ('06','07','08','09','10','11','12','13','14','15','16','17','18','19')
group by v.casenumber

union all
select v.casenumber, 'vehicle', 'bicycle', count(*)
from nj.all_vehicle v where v.veh_type = '20'
group by v.casenumber

union all
select v.casenumber, 'vehicle', 'pedestrian', count(*)
from nj.all_vehicle v where v.veh_type = '31'
group by v.casenumber

union all
select v.casenumber, 'vehicle', 'other_nonmotor', count(*)
from nj.all_vehicle v
where v.veh_type in ('21','22','23','24','25','32','33','34','35','36','98')
group by v.casenumber

union all
select v.casenumber, 'vehicle', 'unknown', count(*)
from nj.all_vehicle v where v.veh_type = '99'
group by v.casenumber


/* =========================================================
   PERSON INJURY SEVERITY (COUNTS PER CRASH)
   ========================================================= */
union all
select p.casenumber, 'person_injury', 'not_injured', count(*)
from nj.all_person p where p.inj_severity = '0'
group by p.casenumber

union all
select p.casenumber, 'person_injury', 'fatal', count(*)
from nj.all_person p where p.inj_severity = '1'
group by p.casenumber

union all
select p.casenumber, 'person_injury', 'serious', count(*)
from nj.all_person p where p.inj_severity = '2'
group by p.casenumber

union all
select p.casenumber, 'person_injury', 'minor', count(*)
from nj.all_person p where p.inj_severity = '3'
group by p.casenumber

union all
select p.casenumber, 'person_injury', 'possible', count(*)
from nj.all_person p where p.inj_severity = '4'
group by p.casenumber

union all
select p.casenumber, 'person_injury', 'injury_unknown', count(*)
from nj.all_person p where p.inj_severity in ('8','9')
group by p.casenumber


/* =========================================================
   CRASH YEAR (GROUPED SUMMARY)
   ========================================================= */
union all
select
    null::bigint as casenumber,
    'year' as domain,
    c.crash_year::text as category,
    count(*) as cnt
from nj.all_crash c
where c.crash_year::int between 2019 and 2023
group by c.crash_year;
