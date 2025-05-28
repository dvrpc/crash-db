do $body$
declare
	col_name text;
    db_tables text[] := '{crash, commveh, cycle, flag, person, roadway, trailveh, vehicle}';
    db_table text;
    user_data_dir text := (select value from tmp_vars where name = 'user_data_dir');
    postgres_data_dir text := (select value from tmp_vars where name = 'postgres_data_dir');
begin

    -- Define domains for data validation.
    create domain int24hhmm integer check(value <= 2359);
    create domain int24hhmm_9999 integer check(value <= 2359 or value = 9999);
    create domain int0_23 integer check(value between 0 and 23);
    create domain int0_23_99 integer check(value between 0 and 23 or value = 99);
    create domain int01_as_bool integer check(value = 0 or value = 1);
    create domain int12_as_bool integer check(value = 1 or value = 2);
    create domain int012_as_bool integer check(value between 0 and 2);
    create domain int0129_as_bool integer check(value between 0 and 2 or value = 9);
    create domain text0129U_as_bool text check(value in ('0', '1', '2', '9', 'U'));
    create domain textYN_as_bool text check(value in ('Y', 'N'));
    create domain textYNU_as_bool text check(value in ('Y', 'N', 'U'));
  
    -- Create intermediate temporary tables for cleaning data.
    foreach db_table in array db_tables loop
        execute format($query$create temporary table temp_%I (like pa_2023.%I including all)$query$, db_table, db_table);
    end loop;

    -- Change some field types in the temp tables to text so they'll accept all data (to fix later).
    foreach db_table in array db_tables loop
    	for col_name in select column_name from information_schema.Columns where table_name = 'temp_' || db_table and data_type not in ('text') loop
            execute format($query$alter table temp_%I alter column %I type text$query$, db_table, col_name);
        end loop;
    end loop;


    /*
      Add constraints (or use domains created above) on the temporary tables to identify any
      mismatch between data and data dictionary, so correct cleaning can be applied later. If one
      fails, try less restrictive contraints until success.
    */

    -- FAILED (contains 9999).
    alter table temp_crash alter arrival_tm type int24hhmm using arrival_tm::int24hhmm;
    -- Succcess, cleaning query added below to convert 9999 to null.
    alter table temp_crash alter arrival_tm type int24hhmm_9999 using arrival_tm::int24hhmm_9999;

    -- FAILED (contains 9999).
    alter table temp_crash alter dispatch_tm type int24hhmm using dispatch_tm::int24hhmm;
    -- Succcess, cleaning query added below to convert 9999 to null.
    alter table temp_crash alter dispatch_tm type int24hhmm_9999 using dispatch_tm::int24hhmm_9999;

    -- FAILED (contains 99).
    alter table temp_crash alter hour_of_day type int0_23 using hour_of_day::int0_23;

    -- Succeeded; cleaning query added below to convert 99 to null
    alter table temp_crash alter hour_of_day type int0_23_99 using hour_of_day::int0_23_99;

    -- FAILED (contains N)
    alter table temp_crash alter intersection_related type int01_as_bool using intersection_related::int01_as_bool;
    -- Succeeded. Nothing to do; y/n accepted as bool by postgres.
    alter table temp_crash alter intersection_related type textYN_as_bool using intersection_related::textYN_as_bool;

    -- FAILED (contains 2).
    alter table temp_crash alter lane_closed type int01_as_bool using lane_closed::int01_as_bool;
    -- FAILED (contains 0).
    alter table temp_crash alter lane_closed type int12_as_bool using lane_closed::int12_as_bool;
    -- FAILED (contains 9).
    alter table temp_crash alter lane_closed type int012_as_bool using lane_closed::int012_as_bool;
    -- FAILED (contains 'U').
    alter table temp_crash alter lane_closed type int0129_as_bool using lane_closed::int0129_as_bool;
    -- Succeeded; this gets turned into bool in the << bool_conversion >> loop below. 
    alter table temp_crash alter lane_closed type text0129U_as_bool using lane_closed::text0129U_as_bool;

    -- FAILED (contains N).
    alter table temp_crash alter ntfy_hiwy_maint type int01_as_bool using ntfy_hiwy_maint::int01_as_bool;
    -- Succeeded; this gets turned into bool in the << bool_conversion >> loop below. 
    alter table temp_crash alter ntfy_hiwy_maint type textYN_as_bool using ntfy_hiwy_maint::textYN_as_bool;

    -- FAILED (contains N).
    alter table temp_crash alter sch_bus_ind type int01_as_bool using sch_bus_ind::int01_as_bool;
    -- Succeeded; this gets turned into bool in the << bool_conversion >> loop below. 
    alter table temp_crash alter sch_bus_ind type textYN_as_bool using sch_bus_ind::textYN_as_bool;
    
    -- FAILED (contains N).
    alter table temp_crash alter sch_zone_ind type int01_as_bool using sch_zone_ind::int01_as_bool;
    -- Succeeded; this gets turned into bool in the << bool_conversion >> loop below. 
    alter table temp_crash alter sch_zone_ind type textYN_as_bool using sch_zone_ind::textYN_as_bool;

    -- FAILED (contains N).
    alter table temp_crash alter secondary_crash type int01_as_bool using secondary_crash::int01_as_bool;
    -- Succeeded; this gets turned into bool in the << bool_conversion >> loop below. 
    alter table temp_crash alter secondary_crash type textYN_as_bool using secondary_crash::textYN_as_bool;

    -- FAILED (contains N).
    alter table temp_crash alter tfc_detour_ind type int01_as_bool using tfc_detour_ind::int01_as_bool;
    -- FAILED (contains U).
    alter table temp_crash alter tfc_detour_ind type textYN_as_bool using tfc_detour_ind::textYN_as_bool;
    -- Succeeded; this gets turned into bool in the << bool_conversion >> loop below. 
    alter table temp_crash alter tfc_detour_ind type textYNU_as_bool using tfc_detour_ind::textYNU_as_bool;

    -- Succeeded; this gets turned into bool in the << bool_conversion >> loop below. 
    alter table temp_crash alter work_zone_ind type textYN_as_bool using work_zone_ind::textYN_as_bool;

    -- Succeeded; this gets turned into bool in the << bool_conversion >> loop below. 
    alter table temp_crash alter workers_pres type textYNU_as_bool using workers_pres::textYNU_as_bool;

    -- Succeeded; this gets turned into bool in the << bool_conversion >> loop below. 
    alter table temp_crash alter wz_close_detour type textYNU_as_bool using wz_close_detour::textYNU_as_bool;
    
    -- Succeeded; this gets turned into bool in the << bool_conversion >> loop below. 
    alter table temp_crash alter wz_flagger type textYNU_as_bool using wz_flagger::textYNU_as_bool;

    -- Succeeded; this gets turned into bool in the << bool_conversion >> loop below. 
    alter table temp_crash alter wz_law_offcr_ind type textYNU_as_bool using wz_law_offcr_ind::textYNU_as_bool;
    
    -- Succeeded; this gets turned into bool in the << bool_conversion >> loop below. 
    alter table temp_crash alter wz_ln_closure type textYNU_as_bool using wz_ln_closure::textYNU_as_bool;

    -- Succeeded; this gets turned into bool in the << bool_conversion >> loop below. 
    alter table temp_crash alter wz_moving type textYNU_as_bool using wz_moving::textYNU_as_bool;

    -- Succeeded; this gets turned into bool in the << bool_conversion >> loop below. 
    alter table temp_crash alter wz_other type textYNU_as_bool using wz_other::textYNU_as_bool;

    -- Succeeded; this gets turned into bool in the << bool_conversion >> loop below. 
    alter table temp_crash alter wz_shlder_mdn type textYNU_as_bool using wz_shlder_mdn::textYNU_as_bool;

    -- Succeeded; this gets turned into bool in the << bool_conversion >> loop below. 
    alter table temp_crash alter wz_workers_inj_killed type textYNU_as_bool using wz_workers_inj_killed::textYNU_as_bool;

    /*
        Copy the data into those temporary tables.
    */
    foreach db_table in array db_tables loop
        execute format($query$copy temp_%I from '%s/pa/2023/%s_BUCKS_2023.csv' with (format csv, header, force_null *)$query$, db_table, user_data_dir, upper(db_table));
        execute format($query$copy temp_%I from '%s/pa/2023/%s_CHESTER_2023.csv' with (format csv, header, force_null *)$query$, db_table, user_data_dir, upper(db_table));
        execute format($query$copy temp_%I from '%s/pa/2023/%s_DELAWARE_2023.csv' with (format csv, header, force_null *)$query$, db_table, user_data_dir, upper(db_table));
        execute format($query$copy temp_%I from '%s/pa/2023/%s_MONTGOMERY_2023.csv' with (format csv, header, force_null *)$query$, db_table, user_data_dir, upper(db_table));
        execute format($query$copy temp_%I from '%s/pa/2023/%s_PHILADELPHIA_2023.csv' with (format csv, header, force_null *)$query$, db_table, user_data_dir, upper(db_table));
    end loop;

    -- Alter values supposed to be from lookup tables that aren't in lookup tables.
    execute format($query$update temp_cycle set mc_dvr_hlmt_type = null where mc_dvr_hlmt_type = ' '$query$);
    execute format($query$update temp_cycle set mc_pas_hlmt_type = null where mc_pas_hlmt_type = ' '$query$);
    execute format($query$update temp_person set extric_ind = null where extric_ind = '9'$query$);
    execute format($query$update temp_person set restraint_helmet = null where restraint_helmet in ('13', '14')$query$);
    execute format($query$update temp_person set seat_position = null where seat_position in ('16', '17', '18', '19', '20')$query$);
    execute format($query$update temp_roadway set rdwy_orient = null where rdwy_orient = 'B'$query$);
    execute format($query$update temp_trailveh set trl_veh_reg_state = null where trl_veh_reg_state = '0'$query$);
    execute format($query$update temp_vehicle set avoid_man_cd = null where avoid_man_cd = '9'$query$);
    execute format($query$update temp_vehicle set make_cd = null where make_cd in ('KALM', 'KNNW')$query$);
    execute format($query$update temp_vehicle set veh_position = null where veh_position = '00'$query$);
    execute format($query$update temp_vehicle set vina_body_type_cd = null where vina_body_type_cd in ('T', 'P4D', 'P', 'PSW', 'P4H', 'C', 'M', 'P3P', 'T2W', 'PC4')$query$);

    -- Change invalid values/codes used for null to null.
    execute format($query$update temp_crash set arrival_tm = null where arrival_tm::int > 2359$query$);
    execute format($query$update temp_crash set dispatch_tm = null where dispatch_tm::int > 2359$query$);
    execute format($query$update temp_crash set est_hrs_closed = null where dispatch_tm::int > 2359$query$);
    execute format($query$update temp_crash set hour_of_day = null where hour_of_day::int > 23$query$);
    execute format($query$update temp_crash set roadway_cleared = null where roadway_cleared::int > 2359$query$);
    execute format($query$update temp_crash set time_of_day = null where time_of_day::int > 2359$query$);

    -- Make values that are used to represent nulls null.
    execute format($query$update temp_commveh set axle_cnt = null where axle_cnt = '99'$query$);
    execute format($query$update temp_commveh set gvwr = null where gvwr = 'UNKNOW'$query$);

    -- Miscellaneous fixes.
    execute format($query$update temp_commveh set gvwr = replace(gvwr, ',', '')$query$);

    /* The data dictionary lists no lookup table but possible values "01 = non-permitted load, 02 =
    permitted load, 99 = unknown)" for the "permitted" column of the commveh table. Convert to
    values that can be used to interpret int to boolean (below). */
    execute format($query$update temp_commveh set permitted = '0' where permitted = '01'$query$);
    execute format($query$update temp_commveh set permitted = '1' where permitted = '02'$query$);
    execute format($query$update temp_commveh set permitted = null where permitted = '99'$query$);


    /* The data dictionary lists possible values 1=yes 0=No for hazmat_rel_ind1 through
    hazmat_rel_ind4, but the values in the CSVS are 1,2,9. Assuming 1=yes, 2=no, 9=unknown so they
    can be converted to booleans properly. */
    execute format($query$update temp_commveh set hazmat_rel_ind1 = 0 where hazmat_rel_ind1 = '2'$query$);
    execute format($query$update temp_commveh set hazmat_rel_ind1 = null where hazmat_rel_ind1 = '09'$query$);
    execute format($query$update temp_commveh set hazmat_rel_ind2 = 0 where hazmat_rel_ind2 = '2'$query$);
    execute format($query$update temp_commveh set hazmat_rel_ind2 = null where hazmat_rel_ind2 = '09'$query$);
    execute format($query$update temp_commveh set hazmat_rel_ind3 = 0 where hazmat_rel_ind3 = '2'$query$);
    execute format($query$update temp_commveh set hazmat_rel_ind3 = null where hazmat_rel_ind3 = '09'$query$);
    execute format($query$update temp_commveh set hazmat_rel_ind4 = 0 where hazmat_rel_ind4 = '2'$query$);
    execute format($query$update temp_commveh set hazmat_rel_ind4 = null where hazmat_rel_ind4 = '09'$query$);
    
   
    -- Alter the values of the fields in the temp tables that will end up being booleans - e.g.
    -- set 'U' and ints higher than 1 to null.
    << bool_conversion >>
    foreach db_table in array db_tables loop
        for col_name in select column_name from information_schema.Columns where table_name = db_table and table_schema = 'pa_2023' and data_type = 'boolean' loop
            execute format($query$update temp_%I set %I = null where %I = 'U'$query$, db_table, col_name, col_name);
            execute format($query$update temp_%I set %I = null where %I = ' '$query$, db_table, col_name, col_name);
            execute format($query$update temp_%I set %I = '1' where %I = '01'$query$, db_table, col_name, col_name);
            execute format($query$update temp_%I set %I = '0' where %I = '00'$query$, db_table, col_name, col_name);
            -- Must wrap in an exception since the cast could fail.
            begin
                execute format($query$update temp_%I set %I = null where %I::int > 1$query$, db_table, col_name, col_name);
            exception
                when invalid_text_representation then
                    null; -- No need to do anything here - if it can't be cast as int, that's fine. 
                when others then
                    -- If there are other errors, raise notice showing code.
                    raise notice '%', SQLSTATE;
            end;
        end loop;
    end loop;

    -- Another boolean change, but which seems unique to this field and possibly meant to be something else.
    execute format($query$update temp_person set transported = null where transported = 'R'$query$);


    -- Copy the data from the temp tables into the non-temp tables, by exporting to file and then reimporting. Easiest way to go from text types in temp tables to types in non-temp tables.
    foreach db_table in array db_tables loop
        execute format($query$copy temp_%I to '%s/%I.csv' with (format csv, header)$query$, db_table, postgres_data_dir, db_table);
        execute format($query$copy pa_2023.%I from '%s/%I.csv' with (format csv, header, force_null *)$query$, db_table, postgres_data_dir, db_table); 
    end loop;
    
end; $body$
language plpgsql;
