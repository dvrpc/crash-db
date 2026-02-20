drop view if exists nj.emphasis_areas_wide;

create view nj.emphasis_areas_wide as

select
    c.casenumber,
    c."year",
    count(*) filter (where p.physical_condition in ('01', '02')) as ksi_person,
    max(case
            when p.physical_condition in ('01', '02') then 1
            else 0
        end) as ksi_event,
    count(*) filter (
    where
        case 
            when p."age" ~ '^[0-9]+$' 
            then cast(p."age" as int)
            else 0
        end >= 65
    and p.position_in_veh = '01'
	) as older_driver,
	count(*) filter (
    where
        case 
            when p."age" ~ '^[0-9]+$' 
            then cast(p."age" as int)
            else 0
        end >= 65
	) as older_road_user,
	count(*) filter (
    where
        case 
            when p."age" ~ '^[0-9]+$' 
            then cast(p."age" as int)
            else 0
        end <= 20
    and p.position_in_veh = '01'
	) as younger_driver,
	count(*) filter (
    where
        case 
            when p."age" ~ '^[0-9]+$' 
            then cast(p."age" as int)
            else 0
        end <= 20
	) as younger_road_user
from nj.all_person p
inner join nj.all_crash c 
    on p.casenumber = c.casenumber 
left join nj.all_vehicle v 
    on p.casenumber = v.casenumber 
   and p.veh_num = v.veh_num
group by c.casenumber, c."year";
