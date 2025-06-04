do $body$
declare
	col_name text;
    dat_type text;
    db_tables text[] := '{crash, commveh, cycle, flag, person, roadway, trailveh, vehicle}';
    db_table text;
    user_data_dir text := (select value from tmp_vars where name = 'user_data_dir');
    postgres_data_dir text := (select value from tmp_vars where name = 'postgres_data_dir');
begin

    /*
        Define domains in order to get invalid data into temporary tables.
        The invalid data will then be cleaned, with the non-temp tables
        contain the domains/constraints for valid data.
    */
    create domain text24hhmm_9999 text check(value::int <= 2359 or value::int = 9999);
    create domain text00_23_99 text check(value::int between 0 and 23 or value::int = 99);

    -- This is most expansive text constraint that can be successfully and unambigously
    -- converted into boolean (after 9 and U converted to null). Try it first, and if the values
    -- in a field fail it, use the ones below, starting from most restrictive to least in order to
    -- identify bad/ambiguous values.
    create domain text019YNUspace_as_bool text check(value in ('0', '1', 'Y', 'N', 'U', '9', ' '));

    create domain text01_as_bool text check(value in ('0', '1'));
    create domain text012_as_bool text check(value in ('0', '1', '2'));
    create domain text0129_as_bool text check(value in ('0', '1', '2', '9'));
    create domain text0129U_as_bool text check(value in ('0', '1', '2', '9', 'U'));
    create domain text029U_as_bool text check(value in ('0', '2', '9', 'U'));
    create domain text12_as_bool text check(value in ('1', '2'));
    create domain text129_as_bool text check(value in ('1', '2', '9'));
    create domain text19_as_bool text check(value in ('1', '9'));
    create domain text9_as_bool text check(value = '9');
    create domain textYNR_as_bool text check(value in ('Y', 'N', 'R'));
    create domain textYNU_as_bool text check(value in ('Y', 'N', 'U'));
    create domain text_01_02_99_as_bool text check(value in ('01', '02', '99'));
    create domain text_0_1_01_02_99_as_bool text check(value in ('0', '1', '01', '02', '99'));

    -- Domain to allow years < 1900 through before being cleaned.
    create domain text_year_greater_than_0 text check(value::int > 0);

    -- Create temporary tables for cleaning data.
    foreach db_table in array db_tables loop
        execute format($$
            create temporary table temp_%I (like pa_2023.%I including all)
        $$, db_table, db_table);
    end loop;

    /*
      Change field types in the temp tables to text so they'll accept all data (to fix later).
      For those that will be booleans, use the domain above that can be unambigously converted
      to booleans in the << bool_conversion >> loop, which first converts 9 and U to null).
    */
    foreach db_table in array db_tables loop
    	for col_name, dat_type  in select column_name, data_type from information_schema.columns where table_name = 'temp_' || db_table and data_type not in ('text') loop
            if dat_type = 'boolean' then
                execute format($q$alter table temp_%I alter column %I type text019YNUspace_as_bool using %I::text019YNUspace_as_bool$q$, db_table, col_name, col_name);
            else
                execute format($q$alter table temp_%I alter column %I type text$q$, db_table, col_name);

            end if;
        end loop;
    end loop;

    /*
      If data population failed because of a bad value, alter the type to determine what it is,
      so it can be temporarily allowed and then cleaned later. Start with most restrictive domains
      and move to less restrictive until success.
    */

    -- text24hhmm FAILED (contain 9999). 
    alter table temp_crash alter arrival_tm type text24hhmm_9999 using arrival_tm::text24hhmm_9999;
    alter table temp_crash alter dispatch_tm type text24hhmm_9999 using dispatch_tm::text24hhmm_9999;
    alter table temp_crash alter roadway_cleared type text24hhmm_9999 using roadway_cleared::text24hhmm_9999;
    alter table temp_crash alter time_of_day type text24hhmm_9999 using time_of_day::text24hhmm_9999;

    -- text00_23 FAILED (contains 99).
    alter table temp_crash alter hour_of_day type text00_23_99 using hour_of_day::text00_23_99;

    -- lane_closed FAILED broad text_as_bool above (contains 2). 
    alter table temp_crash alter lane_closed type text01_as_bool using lane_closed::text01_as_bool;
    -- FAILED (contains 0).
    alter table temp_crash alter lane_closed type text12_as_bool using lane_closed::text12_as_bool;
    -- FAILED (contains 9).
    alter table temp_crash alter lane_closed type text012_as_bool using lane_closed::text012_as_bool;
    -- FAILED (contains U).
    alter table temp_crash alter lane_closed type text0129_as_bool using lane_closed::text0129_as_bool;
    -- FAILED (contains 1).
    alter table temp_crash alter lane_closed type text029U_as_bool using lane_closed::text029U_as_bool;
    -- Succeeded; this gets turned into bool in the << bool_conversion >> loop below. 
    alter table temp_crash alter lane_closed type text0129U_as_bool using lane_closed::text0129U_as_bool;

    -- hazmat_rel_ind1 FAILED broad text_as_bool above (contains 2). 
    alter table temp_commveh alter hazmat_rel_ind1 type textYNU_as_bool using hazmat_rel_ind1::textYNU_as_bool;
    -- FAILED (contains 9)
    alter table temp_commveh alter hazmat_rel_ind1 type text01_as_bool using hazmat_rel_ind1::text01_as_bool;
    -- FAILED (contains 2)
    alter table temp_commveh alter hazmat_rel_ind1 type text19_as_bool using hazmat_rel_ind1::text9_as_bool;
    -- SUCCESS; so field only contains 1,2,9. However, we'll need to change 2 to 0, so have to change again to include it. 
    alter table temp_commveh alter hazmat_rel_ind1 type text129_as_bool using hazmat_rel_ind1::text129_as_bool;
    -- Make that final change to this field so we can change 2 to 0 below. It then gets
    -- turned into bool in the <<bool_conversion>> loop.
    alter table temp_commveh alter hazmat_rel_ind1 type text0129_as_bool using hazmat_rel_ind1::text129_as_bool;

    -- Convert codes described in table to boolean. First one verifies they are what they are
    -- supposed to be, and the second then allows 0,1 for bool conversion below.
    alter table temp_commveh alter permitted type text_01_02_99_as_bool using permitted::text_01_02_99_as_bool;
    alter table temp_commveh alter permitted type text_0_1_01_02_99_as_bool using permitted::text_0_1_01_02_99_as_bool;

    -- transported FAILED broad text_as_bool above (contains R).
    alter table temp_person alter transported type textYNR_as_bool using transported::textYNR_as_bool;

    -- domain text_year failed, contained 999 as year.
    alter table temp_trailveh alter trl_veh_tag_yr type text_year_greater_than_0 using trl_veh_tag_yr::text_year_greater_than_0;

    /*
        Copy the data into those temporary tables.
    */
    foreach db_table in array db_tables loop
        execute format($q$copy temp_%I from '%s/pa/2023/%s_BUCKS_2023.csv' with (format csv, header, force_null *)$q$, db_table, user_data_dir, upper(db_table));
        execute format($q$copy temp_%I from '%s/pa/2023/%s_CHESTER_2023.csv' with (format csv, header, force_null *)$q$, db_table, user_data_dir, upper(db_table));
        execute format($q$copy temp_%I from '%s/pa/2023/%s_DELAWARE_2023.csv' with (format csv, header, force_null *)$q$, db_table, user_data_dir, upper(db_table));
        execute format($q$copy temp_%I from '%s/pa/2023/%s_MONTGOMERY_2023.csv' with (format csv, header, force_null *)$q$, db_table, user_data_dir, upper(db_table));
        execute format($q$copy temp_%I from '%s/pa/2023/%s_PHILADELPHIA_2023.csv' with (format csv, header, force_null *)$q$, db_table, user_data_dir, upper(db_table));
    end loop;

    -- Alter values supposed to be from lookup tables that aren't in lookup tables.
    execute format($q$update temp_cycle set mc_dvr_hlmt_type = null where mc_dvr_hlmt_type = ' '$q$);
    execute format($q$update temp_cycle set mc_pas_hlmt_type = null where mc_pas_hlmt_type = ' '$q$);
    execute format($q$update temp_person set extric_ind = null where extric_ind = '9'$q$);
    execute format($q$update temp_person set restraint_helmet = null where restraint_helmet in ('13', '14')$q$);
    execute format($q$update temp_person set seat_position = null where seat_position in ('16', '17', '18', '19', '20')$q$);
    execute format($q$update temp_roadway set rdwy_orient = null where rdwy_orient = 'B'$q$);
    execute format($q$update temp_trailveh set trl_veh_reg_state = null where trl_veh_reg_state = '0'$q$);
    execute format($q$update temp_vehicle set avoid_man_cd = null where avoid_man_cd = '9'$q$);
    execute format($q$update temp_vehicle set make_cd = null where make_cd in ('KALM', 'KNNW')$q$);
    execute format($q$update temp_vehicle set veh_position = null where veh_position = '00'$q$);
    execute format($q$update temp_vehicle set vina_body_type_cd = null where vina_body_type_cd in ('T', 'P4D', 'P', 'PSW', 'P4H', 'C', 'M', 'P3P', 'T2W', 'PC4')$q$);

    -- Change invalid values/codes used for null to null.
    execute format($q$update temp_crash set arrival_tm = null where arrival_tm::int > 2359$q$);
    execute format($q$update temp_crash set dispatch_tm = null where dispatch_tm::int > 2359$q$);
    execute format($q$update temp_crash set est_hrs_closed = null where est_hrs_closed::int > 2359$q$);
    execute format($q$update temp_crash set hour_of_day = null where hour_of_day::int > 23$q$);
    execute format($q$update temp_crash set roadway_cleared = null where roadway_cleared::int > 2359$q$);
    execute format($q$update temp_crash set time_of_day = null where time_of_day::int > 2359$q$);
    execute format($q$update temp_commveh set axle_cnt = null where axle_cnt = '99'$q$);
    execute format($q$update temp_commveh set gvwr = null where gvwr = 'UNKNOW'$q$);
    execute format($q$update temp_person set age = null where age = '99'$q$);

    -- Miscellaneous fixes.
    execute format($q$update temp_commveh set gvwr = replace(gvwr, ',', '')$q$);
    execute format($q$update temp_trailveh set trl_veh_tag_yr = null where trl_veh_tag_yr::int < 1900$q$);

    /* The data dictionary lists no lookup table but possible values "01 = non-permitted load, 02 =
    permitted load, 99 = unknown)" for the "permitted" column of the commveh table. Convert to
    values that can be used to interpret int to boolean (below). */
    execute format($q$update temp_commveh set permitted = '0' where permitted = '01'$q$);
    execute format($q$update temp_commveh set permitted = '1' where permitted = '02'$q$);
    execute format($q$update temp_commveh set permitted = null where permitted = '99'$q$);


    /* The data dictionary lists possible values 1=yes 0=No for hazmat_rel_ind1 through
    hazmat_rel_ind4, but the values in the CSVS are 1,2,9. Assuming 1=true, 2=false so they
    can be converted to booleans properly. (9 and U handled in << bool_conversion >> loop.) */
    execute format($q$update temp_commveh set hazmat_rel_ind1 = '0' where hazmat_rel_ind1 = '2'$q$);
    execute format($q$update temp_commveh set hazmat_rel_ind1 = null where hazmat_rel_ind1 = '09'$q$);
    
    -- Alter the values of the fields in the temp tables that will end up being booleans - e.g.
    -- set 'U' and ints higher than 1 to null.
    << bool_conversion >>
    foreach db_table in array db_tables loop
        for col_name in select column_name from information_schema.columns where table_name = db_table and table_schema = 'pa_2023' and data_type = 'boolean' loop
            execute format($q$update temp_%I set %I = null where %I = 'U'$q$, db_table, col_name, col_name);
            execute format($q$update temp_%I set %I = null where %I = ' '$q$, db_table, col_name, col_name);
            execute format($q$update temp_%I set %I = '1' where %I = '01'$q$, db_table, col_name, col_name);
            execute format($q$update temp_%I set %I = '0' where %I = '00'$q$, db_table, col_name, col_name);
            -- Must wrap in an exception since the cast could fail.
            begin
                execute format($q$update temp_%I set %I = null where %I::int > 1$q$, db_table, col_name, col_name);
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
    execute format($q$update temp_person set transported = null where transported = 'R'$q$);


    -- Copy the data from the temp tables into the non-temp tables, by exporting to file and then reimporting. Easiest way to go from text types in temp tables to types in non-temp tables.
    foreach db_table in array db_tables loop
        execute format($q$copy temp_%I to '%s/%I.csv' with (format csv, header)$q$, db_table, postgres_data_dir, db_table);
        execute format($q$copy pa_2023.%I from '%s/%I.csv' with (format csv, header, force_null *)$q$, db_table, postgres_data_dir, db_table); 
    end loop;
    
end; $body$
language plpgsql;
