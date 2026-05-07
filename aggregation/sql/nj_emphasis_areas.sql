drop materialized view if exists nj_report.crash_emphasis_areas; 
create materialized view nj_report.crash_emphasis_areas as

with flag_base as (
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
		when c.crash_type = '16' or v.veh_type = '12' then true else false 
	end
	) as train_trolley,
	bool_or ( case 
		when v.veh_type in ('20', '21', '22', '23', '24', '25', '26', '27', '29') then true else false
	end
	) as hvy_truck_related, 
	bool_or( case 
		when v.veh_type = '08' then true else false 
	end
	 ) as motorcycle, 
	 bool_or( case 
	 	when p.safety_equipment_used = '01' then true else false 
	 end
	 ) as unbelted
from
	nj.all_crash c
left join nj.all_person p 
on
	c.casenumber = p.casenumber
left join nj.all_vehicle v 
on p.casenumber = v.casenumber and p.veh_num = v.veh_num 
group by
	c.casenumber),
driver_flags as ( 
select 
	casenumber,
	bool_or(case 
		when "age"::int >= 65 and position_in_veh = '01' then true else false
	end
	) as older_road_driver,
	bool_or(case 
		when "age"::int <= 20 and position_in_veh = '01' then true else false
	end
	) as younger_road_driver
		from nj.all_person
		group by casenumber),
crash_flags as ( 
	select 
		f.*,
		d.older_road_driver,
		d.younger_road_driver
	from flag_base f 
	left join driver_flags d 
	on f.casenumber = d.casenumber
),
ksi_crashes as (  
	select 
		distinct(casenumber)
	from nj.all_person where physical_condition in ('01', '02')
		
),
person_counts as ( 
	select 
		casenumber, 
		count(*) as total_people,
		count(*) filter (where physical_condition in ('01', '02')) as ksi_people 
	from nj.all_person 
	group by casenumber
		
),
totals as ( 
	select count(distinct(casenumber)) as total_crashes from nj.all_crash
),
emphasis_unpivot AS (
    SELECT casenumber, 'older_road_driver' as emphasis_area FROM crash_flags WHERE older_road_driver = TRUE
    UNION ALL
    SELECT casenumber, 'younger_road_driver' FROM crash_flags WHERE younger_road_driver = TRUE
    UNION ALL
    SELECT casenumber, 'intersection' FROM crash_flags WHERE intersection = TRUE
    UNION ALL
    SELECT casenumber, 'lane_departure' FROM crash_flags WHERE lane_departure = TRUE
    UNION ALL
    SELECT casenumber, 'bicycle' FROM crash_flags WHERE bicycle = TRUE
    UNION ALL
    SELECT casenumber, 'pedestrian' FROM crash_flags WHERE pedestrian = TRUE
    UNION ALL
    SELECT casenumber, 'distracted' FROM crash_flags WHERE distracted = TRUE
    UNION ALL
    SELECT casenumber, 'aggressive_driving' FROM crash_flags WHERE aggressive_driving = TRUE
    UNION ALL
    SELECT casenumber, 'impaired_driver' FROM crash_flags WHERE impaired_driver = TRUE
    UNION ALL
    SELECT casenumber, 'work_zone' FROM crash_flags WHERE work_zone = TRUE
    UNION ALL
    SELECT casenumber, 'train_trolley' FROM crash_flags WHERE train_trolley = TRUE
    UNION ALL
    SELECT casenumber, 'hvy_truck_related' FROM crash_flags WHERE hvy_truck_related = TRUE
    UNION ALL
    SELECT casenumber, 'motorcycle' FROM crash_flags WHERE motorcycle = TRUE
    UNION ALL
    SELECT casenumber, 'unbelted' FROM crash_flags WHERE unbelted = TRUE
),
final AS (
    SELECT 
        e.emphasis_area,
        COUNT(DISTINCT e.casenumber) AS total_crash_events,
        COUNT(DISTINCT k.casenumber) AS total_ksi_events,
        SUM(pc.total_people) AS total_people,
        SUM(pc.ksi_people) AS total_ksi_people
    FROM emphasis_unpivot e
    LEFT JOIN ksi_crashes k ON e.casenumber = k.casenumber
    LEFT JOIN person_counts pc ON e.casenumber = pc.casenumber
    GROUP BY e.emphasis_area
)

SELECT 
    f.emphasis_area,
    f.total_crash_events,
    round(f.total_crash_events * 1.0 / t.total_crashes, 3) AS pct_crash_events,
    f.total_ksi_events,
    round(f.total_ksi_events * 1.0 / f.total_crash_events, 3) AS pct_ksi_event,
    f.total_people,
    round(f.total_ksi_people * 1.0 / f.total_people, 3) AS pct_ksi_people
FROM final f
CROSS JOIN totals t
ORDER BY f.emphasis_area;