drop materialized view if exists pa_report.crash_emphasis_areas;
create materialized view pa_report.crash_emphasis_areas as

with var as (
select
	min(crash_year) as begin_year,
	max(crash_year) as end_year
from
	pa.all_crash), 
flag_base as (
select
	c.crn,
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
	c.crn
),

driver_flags as (
select
	crn,
	MAX(case 
            when (age >= 65 and seat_position = '01') or (age >= 65 and person_type in ('4', '7')) then 1 else 0 
        end) as older_road_user,
	MAX(case 
            when (age <= 20 and seat_position = '01') or (age <= 20 and person_type in ('4', '7')) then 1 else 0 
        end) as younger_road_user
from
	pa.all_person
group by
	crn
),

crash_flags as (
select
	f.*,
	coalesce(d.older_road_user,
	0) as older_road_user,
	coalesce(d.younger_road_user,
	0) as younger_road_user
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
	COUNT(distinct crn) as total_crashes
from
	pa.all_crash
),
emphasis_unpivot AS (
    SELECT
        cf.crn,
        e.emphasis_area
    FROM crash_flags cf
    CROSS JOIN LATERAL (
        VALUES
            ('older_road_user', cf.older_road_user = 1),
            ('younger_road_user', cf.younger_road_user = 1),
            ('intersection', cf.intersection),
            ('lane_departure', cf.lane_departure),
            ('bicycle', cf.bicycle),
            ('pedestrian', cf.pedestrian),
            ('distracted', cf.distracted),
            ('aggressive_driving', cf.aggressive_driving),
            ('impaired_driver', cf.impaired_driver),
            ('work_zone', cf.work_zone),
            ('train_trolley', cf.train_trolley),
            ('hvy_truck_related', cf.hvy_truck_related),
            ('motorcycle', cf.motorcycle),
            ('unbelted', cf.unbelted)
    ) AS e(emphasis_area, is_present)
    WHERE e.is_present IS TRUE
),

final as (
select
	e.emphasis_area,
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
	e.emphasis_area
)

select
	concat(begin_year, '-', end_year) as date_range,
	f.emphasis_area,
	f.total_crash_events,
	round(f.total_crash_events * 1.0 / t.total_crashes,
	3) as pct_crash_events,
	f.total_ksi_events,
	round(f.total_ksi_events * 1.0 / f.total_crash_events,
	3) as pct_ksi_event,
	f.total_people,
	f.total_ksi_people,
	round(f.total_ksi_people * 1.0 / f.total_people,
	3) as pct_ksi_people
from
	final f, var
cross join totals t
order by
	f.emphasis_area;