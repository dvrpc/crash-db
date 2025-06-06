create or replace procedure pa_populate_data_tables(year text)
language plpgsql
as
$body$
declare
    col_name text;
    dat_type text;
    db_tables text[] := '{crash, commveh, cycle, flag, person, roadway, trailveh, vehicle}';
    db_table text;
    user_data_dir text := (select value from tmp_vars where name = 'user_data_dir');
    postgres_data_dir text := (select value from tmp_vars where name = 'postgres_data_dir');
begin
    -- Create temporary tables for cleaning data.
    foreach db_table in array db_tables loop
        execute format($tt$create temporary table temp_%I_%s (like pa_%s.%I including all)$tt$, db_table, year, year, db_table);
    end loop;

    /*
        Change field types in the temp tables to text so they'll accept all data (to fix later).
        For those that will be booleans, use the domain above that can be unambiguously converted
        to booleans in the << bool_conversion >> loop, which first converts 9 and U to null).
    */
    foreach db_table in array db_tables loop
    	for col_name, dat_type in select column_name, data_type from information_schema.columns where table_name = 'temp_' || db_table || '_' || year and data_type != 'text' loop
            if dat_type = 'boolean' then
                execute format($q$alter table temp_%I_%s alter column %I type text019YNUspace_as_bool using %I::text019YNUspace_as_bool$q$, db_table, year, col_name, col_name);
            else
                execute format($q$alter table temp_%I_%s alter column %I type text$q$, db_table, year, col_name);
            end if;
        end loop;
    end loop;

    /*
      If data population failed because of a bad value, alter the type to determine what it is,
      so it can be temporarily allowed and then cleaned later. Start with most restrictive domains
      and move to less restrictive until success.
    */

    -- text24hhmm FAILED (contains 9999). 
    execute format($q$alter table temp_crash_%s alter arrival_tm type text24hhmm_9999 using arrival_tm::text24hhmm_9999$q$, year);
    execute format($q$alter table temp_crash_%s alter dispatch_tm type text24hhmm_9999 using dispatch_tm::text24hhmm_9999$q$, year);
    execute format($q$alter table temp_crash_%s alter roadway_cleared type text24hhmm_9999 using roadway_cleared::text24hhmm_9999$q$, year);
    execute format($q$alter table temp_crash_%s alter time_of_day type text24hhmm_9999 using time_of_day::text24hhmm_9999$q$, year);

    -- text00_23 FAILED (contains 99).
    execute format($q$alter table temp_crash_%s alter hour_of_day type text00_23_99 using hour_of_day::text00_23_99$q$, year);

    -- lane_closed FAILED broad text_as_bool above (contains 2). 
    execute format($q$alter table temp_crash_%s alter lane_closed type text01_as_bool using lane_closed::text01_as_bool$q$, year);
    -- FAILED (contains 0).
    execute format($q$alter table temp_crash_%s alter lane_closed type text12_as_bool using lane_closed::text12_as_bool$q$, year);
    -- FAILED (contains 9).
    execute format($q$alter table temp_crash_%s alter lane_closed type text012_as_bool using lane_closed::text012_as_bool$q$, year);
    -- FAILED (contains U).
    execute format($q$alter table temp_crash_%s alter lane_closed type text0129_as_bool using lane_closed::text0129_as_bool$q$, year);
    -- FAILED (contains 1).
    execute format($q$alter table temp_crash_%s alter lane_closed type text029U_as_bool using lane_closed::text029U_as_bool$q$, year);
    -- Succeeded; this gets turned into bool in the << bool_conversion >> loop below. 
    execute format($q$alter table temp_crash_%s alter lane_closed type text0129U_as_bool using lane_closed::text0129U_as_bool$q$, year);

    -- hazmat_rel_ind1 FAILED broad text_as_bool above (contains 2). 
    execute format($q$alter table temp_commveh_%s alter hazmat_rel_ind1 type textYNU_as_bool using hazmat_rel_ind1::textYNU_as_bool$q$, year);
    -- FAILED (contains 9)
    execute format($q$alter table temp_commveh_%s alter hazmat_rel_ind1 type text01_as_bool using hazmat_rel_ind1::text01_as_bool$q$, year);
    -- FAILED (contains 2)
    execute format($q$alter table temp_commveh_%s alter hazmat_rel_ind1 type text19_as_bool using hazmat_rel_ind1::text9_as_bool$q$, year);
    -- SUCCESS; so field only contains 1,2,9. However, we'll need to change 2 to 0, so have to change again to include it. 
    execute format($q$alter table temp_commveh_%s alter hazmat_rel_ind1 type text129_as_bool using hazmat_rel_ind1::text129_as_bool$q$, year);
    -- Make that final change to this field so we can change 2 to 0 below. It then gets
    -- turned into bool in the <<bool_conversion>> loop.
    execute format($q$alter table temp_commveh_%s alter hazmat_rel_ind1 type text0129_as_bool using hazmat_rel_ind1::text129_as_bool$q$, year);

    -- Convert codes described in table to boolean. First one verifies they are what they are
    -- supposed to be, and the second then allows 0,1 for bool conversion below.
    execute format($q$alter table temp_commveh_%s alter permitted type text_01_02_99_as_bool using permitted::text_01_02_99_as_bool$q$, year);
    execute format($q$alter table temp_commveh_%s alter permitted type text_0_1_01_02_99_as_bool using permitted::text_0_1_01_02_99_as_bool$q$, year);

    -- transported FAILED broad text_as_bool above (contains R).
    execute format($q$alter table temp_person_%s alter transported type textYNR_as_bool using transported::textYNR_as_bool$q$, year);

    -- domain text_year failed, contained 999 as year.
    execute format($q$alter table temp_trailveh_%s alter trl_veh_tag_yr type text_year_greater_than_0 using trl_veh_tag_yr::text_year_greater_than_0$q$, year);

    /*
        Copy the data into those temporary tables.
    */
    foreach db_table in array db_tables loop
        execute format($q$copy temp_%I_%s from '%s/pa/%s/%s_BUCKS_%s.csv' with (format csv, header, force_null *)$q$, db_table, year, user_data_dir, year, upper(db_table), year);
        execute format($q$copy temp_%I_%s from '%s/pa/%s/%s_CHESTER_%s.csv' with (format csv, header, force_null *)$q$, db_table, year, user_data_dir, year, upper(db_table), year);
        execute format($q$copy temp_%I_%s from '%s/pa/%s/%s_DELAWARE_%s.csv' with (format csv, header, force_null *)$q$, db_table, year, user_data_dir, year, upper(db_table), year);
        execute format($q$copy temp_%I_%s from '%s/pa/%s/%s_MONTGOMERY_%s.csv' with (format csv, header, force_null *)$q$, db_table, year, user_data_dir, year, upper(db_table), year);
        execute format($q$copy temp_%I_%s from '%s/pa/%s/%s_PHILADELPHIA_%s.csv' with (format csv, header, force_null *)$q$, db_table, year, user_data_dir, year, upper(db_table), year);
    end loop;

    -- Alter values supposed to be from lookup tables that aren't in lookup tables.
    execute format($q$update temp_cycle_%s set mc_dvr_hlmt_type = null where mc_dvr_hlmt_type = ' '$q$, year);
    execute format($q$update temp_cycle_%s set mc_pas_hlmt_type = null where mc_pas_hlmt_type = ' '$q$, year);
    execute format($q$update temp_person_%s set extric_ind = null where extric_ind = '9'$q$, year);
    execute format($q$update temp_person_%s set restraint_helmet = null where restraint_helmet in ('13', '14')$q$, year);
    execute format($q$update temp_person_%s set seat_position = null where seat_position in ('16', '17', '18', '19', '20')$q$, year);
    execute format($q$update temp_roadway_%s set rdwy_orient = null where rdwy_orient = 'B'$q$, year);
    execute format($q$update temp_trailveh_%s set trl_veh_reg_state = null where trl_veh_reg_state = '0'$q$, year);
    execute format($q$update temp_vehicle_%s set avoid_man_cd = null where avoid_man_cd = '9'$q$, year);
    execute format($q$update temp_vehicle_%s set make_cd = null where make_cd in ('KALM', 'KNNW')$q$, year);
    execute format($q$update temp_vehicle_%s set veh_position = null where veh_position = '00'$q$, year);
    execute format($q$update temp_vehicle_%s set vina_body_type_cd = null where vina_body_type_cd in ('T', 'P4D', 'P', 'PSW', 'P4H', 'C', 'M', 'P3P', 'T2W', 'PC4')$q$, year);

    -- Change invalid values/codes used for null to null.
    execute format($q$update temp_crash_%s set arrival_tm = null where arrival_tm::int > 2359$q$, year);
    execute format($q$update temp_crash_%s set dispatch_tm = null where dispatch_tm::int > 2359$q$, year);
    execute format($q$update temp_crash_%s set est_hrs_closed = null where est_hrs_closed::int > 2359$q$, year);
    execute format($q$update temp_crash_%s set hour_of_day = null where hour_of_day::int > 23$q$, year);
    execute format($q$update temp_crash_%s set roadway_cleared = null where roadway_cleared::int > 2359$q$, year);
    execute format($q$update temp_crash_%s set time_of_day = null where time_of_day::int > 2359$q$, year);
    execute format($q$update temp_commveh_%s set axle_cnt = null where axle_cnt = '99'$q$, year);
    execute format($q$update temp_commveh_%s set gvwr = null where gvwr = 'UNKNOW'$q$, year);
    execute format($q$update temp_person_%s set age = null where age = '99'$q$, year);

    -- Miscellaneous fixes.
    execute format($q$update temp_commveh_%s set gvwr = replace(gvwr, ',', '')$q$, year);
    execute format($q$update temp_trailveh_%s set trl_veh_tag_yr = null where trl_veh_tag_yr::int < 1900$q$, year);

    /* The data dictionary lists no lookup table but possible values "01 = non-permitted load, 02 =
    permitted load, 99 = unknown)" for the "permitted" column of the commveh table. Convert to
    values that can be used to interpret int to boolean (below). */
    execute format($q$update temp_commveh_%s set permitted = '0' where permitted = '01'$q$, year);
    execute format($q$update temp_commveh_%s set permitted = '1' where permitted = '02'$q$, year);
    execute format($q$update temp_commveh_%s set permitted = null where permitted = '99'$q$, year);


    /* The data dictionary lists possible values 1=yes 0=No for hazmat_rel_ind1 through
    hazmat_rel_ind4, but the values in the CSVS are 1,2,9. Assuming 1=true, 2=false so they
    can be converted to booleans properly. (9 and U handled in << bool_conversion >> loop.) */
    execute format($q$update temp_commveh_%s set hazmat_rel_ind1 = '0' where hazmat_rel_ind1 = '2'$q$, year);
    execute format($q$update temp_commveh_%s set hazmat_rel_ind1 = null where hazmat_rel_ind1 = '09'$q$, year);
    
    -- Alter the values of the fields in the temp tables that will end up being booleans - e.g.
    -- set 'U' and ints higher than 1 to null.
    << bool_conversion >>
    foreach db_table in array db_tables loop
        for col_name in select column_name from information_schema.columns where table_name = db_table and table_schema = 'pa_' || year and data_type = 'boolean' loop
            execute format($q$update temp_%I_%s set %I = null where %I = 'U'$q$, db_table, year, col_name, col_name);
            execute format($q$update temp_%I_%s set %I = null where %I = ' '$q$, db_table, year, col_name, col_name);
            execute format($q$update temp_%I_%s set %I = '1' where %I = '01'$q$, db_table, year, col_name, col_name);
            execute format($q$update temp_%I_%s set %I = '0' where %I = '00'$q$, db_table, year, col_name, col_name);
            -- Must wrap in an exception since the cast could fail.
            begin
                execute format($q$update temp_%I_%s set %I = null where %I::int > 1$q$, db_table, year, col_name, col_name);
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
    execute format($q$update temp_person_%s set transported = null where transported = 'R'$q$, year);

    -- Copy the data from the temp tables into the non-temp tables, by exporting to file and then reimporting. Easiest way to go from text types in temp tables to types in non-temp tables.
    foreach db_table in array db_tables loop
        execute format($q$copy temp_%I_%s to '%s/%I.csv' with (format csv, header)$q$, db_table, year, postgres_data_dir, db_table);
        execute format($q$copy pa_%s.%I from '%s/%I.csv' with (format csv, header, force_null *)$q$, year, db_table, postgres_data_dir, db_table); 
    end loop;

end;
$body$
