create or replace procedure nj_clean_data(year text)
language plpgsql
as
$body$
declare
    col_name text;
    col_name2 text;
    tbl_schema text;
    tbl_name text;
    tbl_name2 text;
    cons_name text;
begin

    raise info '..Fix miscellaneous issues';

    -- Cleaning that applies to all years comes first; below that is year-specific cleaning.
    /* All years. */

    -- "dir_of_travel" in the pedestrian & vehicle tables is the only one that uses a lookup code
    -- rather than first letter of cardinal direction. Make it consistent with the others.
    -- codes are on p. 79 of 2017 Crash Report Manual and on NJTR_1 forms.
    execute format($q$update temp_pedestrian_%s set dir_of_travel = null where dir_of_travel not in ('01', '02', '03', '04')$q$, year);
    execute format($q$update temp_vehicle_%s set dir_of_travel = null where dir_of_travel not in ('01', '02', '03', '04')$q$, year);
    execute format($q$update temp_pedestrian_%s set dir_of_travel = 'N' where dir_of_travel = '01'$q$, year);    
    execute format($q$update temp_pedestrian_%s set dir_of_travel = 'E' where dir_of_travel = '02'$q$, year);    
    execute format($q$update temp_pedestrian_%s set dir_of_travel = 'S' where dir_of_travel = '03'$q$, year);    
    execute format($q$update temp_pedestrian_%s set dir_of_travel = 'W' where dir_of_travel = '04'$q$, year);    
    execute format($q$update temp_vehicle_%s set dir_of_travel = 'N' where dir_of_travel = '01'$q$, year);    
    execute format($q$update temp_vehicle_%s set dir_of_travel = 'E' where dir_of_travel = '02'$q$, year);    
    execute format($q$update temp_vehicle_%s set dir_of_travel = 'S' where dir_of_travel = '03'$q$, year);    
    execute format($q$update temp_vehicle_%s set dir_of_travel = 'W' where dir_of_travel = '04'$q$, year);
    
    /* Year-specific. */
    if year = '2022' then
        execute format($q$update temp_occupant_%s set airbag_deployment = null where airbag_deployment in ('05', '06')$q$, year);
    elseif year = '2017' then
        execute format($q$update temp_vehicle_%s set veh_color = 'WT' where veh_color = 'WHI'$q$, year);
    elseif year = '2016' then
        -- safety_equipment lookup: 07 is reserved
        execute format($q$update temp_occupant_%s set safety_equipment_used = null where safety_equipment_used = '07'$q$, year);
        execute format($q$update temp_occupant_%s set safety_equipment_available = null where safety_equipment_available = '07'$q$, year);
        -- pre_crash_action lookup: 42 is reserved
        execute format($q$update temp_vehicle_%s set pre_crash_action = null where pre_crash_action = '42'$q$, year);
        execute format($q$update temp_pedestrian_%s set pre_crash_action = null where pre_crash_action = '42'$q$, year);
        -- veh_type lookup: 09 is reserved
        execute format($q$update temp_vehicle_%s set veh_type = null where veh_type = '09'$q$, year);
    elseif year = '2015' then
        -- safety_equipment lookup: 07 is reserved
        execute format($q$update temp_occupant_%s set safety_equipment_used = null where safety_equipment_used = '07'$q$, year);
        execute format($q$update temp_occupant_%s set safety_equipment_available = null where safety_equipment_available = '07'$q$, year);
        -- veh_type lookup: 09 is reserved
        execute format($q$update temp_vehicle_%s set veh_type = null where veh_type = '09'$q$, year);
    elseif year = '2014' then
        -- safety_equipment lookup: 07 is reserved
        execute format($q$update temp_occupant_%s set safety_equipment_used = null where safety_equipment_used = '07'$q$, year);
        execute format($q$update temp_occupant_%s set safety_equipment_available = null where safety_equipment_available = '07'$q$, year);
        -- veh_type lookup: 09 is reserved
        execute format($q$update temp_vehicle_%s set veh_type = null where veh_type = '09'$q$, year);
    end if;

end;
$body$
