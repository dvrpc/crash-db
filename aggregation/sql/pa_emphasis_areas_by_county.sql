drop materialized view if exists pa_report.crash_emphasis_areas_counties;

create materialized view pa_report.crash_emphasis_areas_counties as

with flag_base as (
select
	c.crn,
	case 
		when c.county = '09' then 'Bucks'
		when c.county = '15' then 'Chester'
		when c.county = '23' then 'Delaware'
		when c.county = '46' then 'Montgomery'
		when c.county = '67' then 'Philadelphia'
	end as county_name,
		bool_or(case
			when "intersection" is true then true
			else false
		end) as "intersection",
		bool_or(case
			when lane_departure is true then true
			else false
		end) as lane_departure,
		bool_or(case
			when bicycle is true then true
			else false
		end) as bicycle,
		bool_or(case
			when pedestrian is true then true
			else false
		end) as pedestrian,
		bool_or(case
			when distracted is true then true
			else false
		end) as distracted,
		bool_or(case
			when aggressive_driving is true then true
			else false
		end) as aggressive_driving,
		bool_or(case
			when impaired_driver is true then true
			else false
		end) as impaired_driver,
		bool_or(case
			when work_zone is true then true
			else false
		end) as work_zone,
		bool_or(case
			when train_trolley is true then true
			else false
		end) as train_trolley,
		bool_or(case
			when hvy_truck_related is true then true
			else false
		end) as hvy_truck_related,
		bool_or(case
			when motorcycle is true then true
			else false
		end) as motorcycle,
		bool_or(case
			when unbelted is true then true
			else false
		end) as unbelted
	from
		pa.all_crash c
	left join pa.all_flags f on
		c.crn = f.crn
	group by
		c.crn, county_name
),

driver_flags as (
select
	crn,
	MAX(case 
            when age >= 65 and seat_position = '01' then 1 else 0 
        end) as older_road_driver,
	MAX(case 
            when age <= 20 and seat_position = '01' then 1 else 0 
        end) as younger_road_driver
from
	pa.all_person
group by
	crn
),

crash_flags as (
select
	f.*,
	coalesce(d.older_road_driver,
	0) as older_road_driver,
	coalesce(d.younger_road_driver,
	0) as younger_road_driver
from
	flag_base f
left join driver_flags d on
	f.crn = d.crn
),

ksi_crashes as (
select
	distinct crn
from
	pa.all_person
where
	inj_severity in ('1', '2')
),

person_counts as (
select
	crn,
	COUNT(*) as total_people,
	SUM(case when inj_severity in ('1', '2') then 1 else 0 end) as ksi_people
from
	pa.all_person
group by
	crn
),

totals as (
select
	case 
		when c.county = '09' then 'Bucks'
		when c.county = '15' then 'Chester'
		when c.county = '23' then 'Delaware'
		when c.county = '46' then 'Montgomery'
		when c.county = '67' then 'Philadelphia'
	end as county_name,
	COUNT(distinct crn) as total_crashes
from
	pa.all_crash c
	group by county_name
),

emphasis_unpivot as (
select
	crn,
	county_name,
	'older_road_driver' as emphasis_area
from
	crash_flags
where
	older_road_driver = 1
union all
select
	crn,
	county_name,
	'younger_road_driver'
from
	crash_flags
where
	younger_road_driver = 1
union all
select
	crn,
	county_name,
	'intersection'
from
	crash_flags
where
	intersection = true
union all
select
	crn,
	county_name,
	'lane_departure'
from
	crash_flags
where
	lane_departure = true
union all
select
	crn,
	county_name,
	'bicycle'
from
	crash_flags
where
	bicycle = true
union all
select
	crn,
	county_name,
	'pedestrian'
from
	crash_flags
where
	pedestrian = true
union all
select
	crn,
	county_name,
	'distracted'
from
	crash_flags
where
	distracted = true
union all
select
	crn,
	county_name,
	'aggressive_driving'
from
	crash_flags
where
	aggressive_driving = true
union all
select
	crn,
	county_name,
	'impaired_driver'
from
	crash_flags
where
	impaired_driver = true
union all
select
	crn,
	county_name,
	'work_zone'
from
	crash_flags
where
	work_zone = true
union all
select
	crn,
	county_name,
	'train_trolley'
from
	crash_flags
where
	train_trolley = true
union all
select
	crn,
	county_name,
	'hvy_truck_related'
from
	crash_flags
where
	hvy_truck_related = true
union all
select
	crn,
	county_name,
	'motorcycle'
from
	crash_flags
where
	motorcycle = true
union all
select
	crn,
	county_name,
	'unbelted'
from
	crash_flags
where
	unbelted = true
),

final as (
select
	e.emphasis_area,
	e.county_name,
	COUNT(distinct e.crn) as total_crash_events,
	COUNT(distinct k.crn) as total_ksi_events,
	SUM(pc.total_people) as total_people,
	SUM(pc.ksi_people) as total_ksi_people
from
	emphasis_unpivot e
left join ksi_crashes k on
	e.crn = k.crn
left join person_counts pc on
	e.crn = pc.crn
group by
	e.county_name, e.emphasis_area
)

select
	f.emphasis_area,
	f.county_name,
	f.total_crash_events,
	round(f.total_crash_events * 1.0 / t.total_crashes,
	3) as pct_crash_events,
	f.total_ksi_events,
	round(f.total_ksi_events * 1.0 / f.total_crash_events,
	3) as pct_ksi_event,
	f.total_people,
	round(f.total_ksi_people * 1.0 / f.total_people,
	3) as pct_ksi_people
from
	final f
inner join totals t
on f.county_name = t.county_name
order by
	f.county_name, f.emphasis_area;