drop materialized view if exists nj_report.crash_emphasis_areas; 
create materialized view nj_report.crash_emphasis_areas as

with var as (
select
	min("year") as begin_year,
	max("year") as end_year
from
	nj.all_crash), 
flag_base as (
select
	c.casenumber,
	bool_or(case
		when c."intersection" = 'I' then true
		else false
	end) as "intersection",
	bool_or(case 
		when c.crash_type in ('02', '04', '09', '10', '11') then true
		else false
	end) as lane_departure,
	bool_or(case 
		when p.is_bicycle is true then true
		else false
	end
	) as bicycle,
	bool_or(case 
		when p.pedestrian is true then true
		else false
	end
	) as pedestrian,
	bool_or(case 
		when v.contrib_circ1 in ('02', '17', '18', '19', '20', '21')
		or v.contrib_circ2 in ('02', '17', '18', '19', '20', '21') then true
		else false
	end) as distracted,
	bool_or(case 
		when v.contrib_circ1 in ('01', '03', '04', '05', '06', '09')
		or v.contrib_circ2 in ('01', '03', '04', '05', '06', '09') then true
		else false
	end) as aggressive_driving,
	bool_or(case  
		when c.alcohol_involved is true then true
		else false
	end
	) as impaired_driver,
	bool_or(case 
		when c.temp_traffic_control_zone in ('02', '03', '04', '05') then true
		else false
	end
	) as work_zone,
	bool_or( case 
		when c.crash_type = '16'
		or v.veh_type = '12' then true
		else false
	end
	) as train_trolley,
	bool_or ( case 
		when v.veh_type in ('20', '21', '22', '23', '24', '25', '26', '27', '29') then true
		else false
	end
	) as hvy_truck_related, 
	bool_or( case 
		when v.veh_type = '08' then true
		else false
	end
	 ) as motorcycle, 
	 bool_or( case
		when p.safety_equipment_used = '01' then true
		else false
	end
	 ) as unbelted
from
	nj.all_crash c
left join nj.all_person p 
on
	c.casenumber = p.casenumber
left join nj.all_vehicle v 
on
	p.casenumber = v.casenumber
	and p.veh_num = v.veh_num
group by
	c.casenumber),
driver_flags as (
select 
	casenumber,
	bool_or(case 
		when ("age"::int >= 65
			and position_in_veh = '01') or (age::int >= 65 and pedestrian is True) or (age::int >= 65 and is_bicycle is True) then true
			else false
		end
	) as older_road_user,
	bool_or(case 
		when ("age"::int <= 20
			and position_in_veh = '01') or (age::int <= 20 and pedestrian is True) or (age::int <= 20 and is_bicycle is True) then true
			else false
		end
	) as younger_road_user
from
	nj.all_person
group by
	casenumber),
crash_flags as (
select 
		f.*,
		d.older_road_user,
		d.younger_road_user
from
	flag_base f
left join driver_flags d 
	on
	f.casenumber = d.casenumber
),
ksi_crashes as (
select 
		distinct(casenumber)
from
	nj.all_person
where
	physical_condition in ('01', '02')
		
),
person_counts as (
select 
		casenumber, 
		count(*) as total_people,
		count(*) filter (
	where physical_condition in ('01', '02')) as ksi_people
from
	nj.all_person
group by
	casenumber
		
),
totals as (
select
	count(distinct(casenumber)) as total_crashes
from
	nj.all_crash
),
emphasis_unpivot AS (
    SELECT
        cf.casenumber,
        e.emphasis_area
    FROM crash_flags cf
    CROSS JOIN LATERAL (
        VALUES
            ('older_road_user', cf.older_road_user),
            ('younger_road_user', cf.younger_road_user),
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
	COUNT(distinct e.casenumber) as total_crash_events,
	COUNT(distinct k.casenumber) as total_ksi_events,
	SUM(pc.total_people) as total_people,
	SUM(pc.ksi_people) as total_ksi_people
from
	emphasis_unpivot e
left join ksi_crashes k on
	e.casenumber = k.casenumber
left join person_counts pc on
	e.casenumber = pc.casenumber
group by
	e.emphasis_area
)


select
	concat(var.begin_year,
	'-',
	var.end_year) as date_range,
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
	final f,
	var
cross join totals t
order by
	f.emphasis_area;