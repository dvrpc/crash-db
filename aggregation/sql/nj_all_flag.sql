drop materialized view if exists nj.all_flags;
create materialized view nj.all_flags as

--establish flags
select 
c.casenumber, 
max(case when (case 
            when p."age" ~ '^[0-9]+$' 
            then cast(p."age" as int)
            else 0
        end) >= 65 and p.position_in_veh = '01' then 1 else 0 end) as older_road_driver,
max(case when (case 
            when p."age" ~ '^[0-9]+$' 
            then cast(p."age" as int)
            else 0
        end) <= 20 and p.position_in_veh = '01' then 1 else 0 end) as younger_road_driver,
max(case when "intersection" = 'I' then 1 else 0 end) as "intersection",
max(case when crash_type in ('02', '04', '09', '10', '11') then 1 else 0 end) as lane_departure,
max(case when is_bicycle is true then 1 else 0 end) as bicycle,
max(case when pedestrian is true then 1 else 0 end) as pedestrian,
max(case when v.contrib_circ1 in ('02', '17', '18', '19', '20', '21') or v.contrib_circ2 in ('02', '17', '18', '19', '20', '21') then 1 else 0 end) as distracted_driving,
max(case when v.contrib_circ1 in ('01', '03', '04', '05', '06', '09') or v.contrib_circ2 in ('01', '03', '04', '05', '06', '09') then 1 else 0 end) as aggressive_driving,
max(case when alcohol_involved is true then 1 else 0 end) as impaired_driver,
max(case when temp_traffic_control_zone in ('02', '03', '04', '05') then 1 else 0 end) as work_zone,
max(case when crash_type = '16' or veh_type = '12' then 1 else 0 end) as train_trolley,
max(case when veh_type in ('20', '21', '22', '23', '24', '25', '26', '27', '29') then 1 else 0 end) as hvy_truck_related,
max(case when veh_type = '08' then 1 else 0 end) as motorcycle
from nj.all_crash c
left join nj.all_person p 
on c.casenumber = p.casenumber
left join nj.all_vehicle v 
on c.casenumber = v.casenumber
group by c.casenumber
        
	