create or replace procedure pa_clean_data(year text)
language plpgsql
as
$body$
declare
    lookup_table_names text[] := (select array_agg(name) from pa_lookup_table_names);
    col_name text;
    col_name2 text;
    tbl_schema text;
    tbl_name text;
    tbl_name2 text;
    cons_name text;
    db_tables text[] := '{crash, commveh, cycle, flag, person, roadway, trailveh, vehicle}';
    db_table text;
begin

    -- Cleaning that applies to all years comes first; below that is year-specific cleaning.

    /* start lookup -> bool */
    -- Convert fields that use lookup tables to represent boolean values into booleans.
    -- First, alter domain to allow 0, then change values.
    
    -- hazmat_rel_ind fields
    execute format($q$alter table temp_commveh_%s alter hazmat_rel_ind1 type text0129_as_bool using hazmat_rel_ind1::text129_as_bool$q$, year);
    execute format($q$alter table temp_commveh_%s alter hazmat_rel_ind2 type text0129_as_bool using hazmat_rel_ind1::text129_as_bool$q$, year);
    execute format($q$alter table temp_commveh_%s alter hazmat_rel_ind3 type text0129_as_bool using hazmat_rel_ind1::text129_as_bool$q$, year);
    execute format($q$alter table temp_commveh_%s alter hazmat_rel_ind4 type text0129_as_bool using hazmat_rel_ind1::text129_as_bool$q$, year);
    -- Order is important: first 1 -> 0 and then 2 -> 1
    execute format($q$update temp_commveh_%s set hazmat_rel_ind1 = '0' where hazmat_rel_ind1 = '1'$q$, year);
    execute format($q$update temp_commveh_%s set hazmat_rel_ind2 = '0' where hazmat_rel_ind2 = '1'$q$, year);
    execute format($q$update temp_commveh_%s set hazmat_rel_ind3 = '0' where hazmat_rel_ind3 = '1'$q$, year);
    execute format($q$update temp_commveh_%s set hazmat_rel_ind4 = '0' where hazmat_rel_ind4 = '1'$q$, year);
    execute format($q$update temp_commveh_%s set hazmat_rel_ind1 = '1' where hazmat_rel_ind1 = '2'$q$, year);
    execute format($q$update temp_commveh_%s set hazmat_rel_ind2 = '1' where hazmat_rel_ind2 = '2'$q$, year);
    execute format($q$update temp_commveh_%s set hazmat_rel_ind3 = '1' where hazmat_rel_ind3 = '2'$q$, year);
    execute format($q$update temp_commveh_%s set hazmat_rel_ind4 = '1' where hazmat_rel_ind4 = '2'$q$, year);
    
    -- permitted   
    execute format($q$alter table temp_commveh_%s alter permitted type text_0_1_01_02_99_as_bool using permitted::text_0_1_01_02_99_as_bool$q$, year);
    execute format($q$update temp_commveh_%s set permitted = '0' where permitted = '01'$q$, year);
    execute format($q$update temp_commveh_%s set permitted = '1' where permitted = '02'$q$, year);
    execute format($q$update temp_commveh_%s set permitted = null where permitted = '99'$q$, year);

    /* end lookup -> bool */
    
    -- Make invalid HHMM values null.
    execute format($q$ update temp_crash_%s set roadway_cleared = null where roadway_cleared > 2359$q$, year);
    execute format($q$ update temp_crash_%s set arrival_tm = null where arrival_tm::int > 2359$q$, year);
    execute format($q$ update temp_crash_%s set dispatch_tm = null where dispatch_tm::int > 2359$q$, year);
    execute format($q$ update temp_crash_%s set time_of_day = null where time_of_day::int > 2359$q$, year);
    execute format($q$ update temp_crash_%s set est_hrs_closed = null where est_hrs_closed::int > 2359$q$, year);

    -- Make invalid hours null.
    execute format($q$ update temp_crash_%s set hour_of_day = null where hour_of_day::int > 23$q$, year);
    execute format($q$update temp_crash_%s set est_hrs_closed = null where est_hrs_closed::int > 2359$q$, year);

    -- A boolean change, but which seems unique to this field and possibly meant to be something else.
    execute format($q$update temp_person_%s set transported = null where transported = 'R'$q$, year);

    -- Make invalid years null.
    execute format($q$update temp_trailveh_%s set trl_veh_tag_yr = null where trl_veh_tag_yr::int < 1900$q$, year);

    -- Make values not in lookup tables null.
    execute format($q$update temp_person_%s set transported_by = null where transported_by = '03'$q$, year);

    -- Alter the values of the fields in the temp tables that will end up being booleans - e.g.
    -- set 'U' and ints higher than 1 to null. Applied to all years.
    << bool_conversion >>
    foreach db_table in array db_tables loop
        for col_name in select column_name from information_schema.columns where table_name = db_table and table_schema = 'pa_' || year and data_type = 'boolean' loop
            execute format($q$update temp_%I_%s set %I = null where %I in ('U', ' ')$q$, db_table, year, col_name, col_name);
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
            begin
                execute format($q$update temp_%I_%s set %I = floor(%I::numeric)::int$q$, db_table, year, col_name, col_name);
            exception
                when invalid_text_representation then
                    null; -- No need to do anything here - if it can't be cast as int, that's fine. 
                when others then
                    -- If there are other errors, raise notice showing code.
                    raise notice '%', SQLSTATE;
            end;
        end loop;
    end loop;

    -- Alter the values of the fields in the temp tables that will end up being integers. Many
    -- values contains decimals, so remove them.
    << rm_decimals_int >>
    foreach db_table in array db_tables loop
        for col_name in select column_name from information_schema.columns where table_name = db_table and table_schema = 'pa_' || year and data_type = 'integer' loop
            execute format($q$update temp_%I_%s set %I = floor(%I::numeric)::int$q$, db_table, year, col_name, col_name);
        end loop;
    end loop;
    
    -- Remove decimals from values in fields that reference lookup tables.
    << rm_decimals_text_lookup >>
    for tbl_name, col_name in select table_name, column_name from information_schema.key_column_usage where constraint_name in (
        select ccu.constraint_name
            from information_schema.constraint_column_usage ccu
            join information_schema.table_constraints tc on tc.constraint_name = ccu.constraint_name
            where ccu.constraint_schema = 'pa_' || year and tc.constraint_type = 'FOREIGN KEY'
    ) loop
        begin
            execute format($q$update temp_%I_%s set %I = floor(%I::numeric)::text$q$, tbl_name, year, col_name, col_name);
        exception 
            when invalid_text_representation then
                null;
        end;
    end loop;

    -- Now add zero padding for columns using it.
    << zero_pad_lookup_table_codes >>
    -- Get the lookup tables that use zero padding in their values.
    for tbl_name in select name from pa_lookup_table_names where zero_padded = true loop
        -- Use the table name to get name of the foreign key constraints referencing it.
        for cons_name in select ccu.constraint_name from information_schema.constraint_column_usage ccu join information_schema.table_constraints tc on tc.constraint_name = ccu.constraint_name where ccu.table_schema = 'pa_lookup' and ccu.table_name = tbl_name and tc.constraint_type = 'FOREIGN KEY' loop
            -- Use the constraint name to get the table/column it is used in.
            for tbl_name2, col_name2 in select table_name, column_name from information_schema.key_column_usage where constraint_name = cons_name loop
                execute format($q$update temp_%I_%s set %I = lpad(%I, 2, '0')$q$, tbl_name2, year, col_name2, col_name2);
            end loop;
        end loop;
    end loop;

    -- Make values not in lookup tables null.
    execute format($q$update temp_person_%s set extric_ind = null where extric_ind = '9'$q$, year);
    execute format($q$update temp_person_%s set restraint_helmet = null where restraint_helmet in ('13', '14')$q$, year);
    execute format($q$update temp_person_%s set seat_position = null where seat_position in ('16', '17', '18', '19', '20')$q$, year);
    execute format($q$update temp_roadway_%s set rdwy_orient = null where rdwy_orient = 'B'$q$, year);
    execute format($q$update temp_vehicle_%s set vina_body_type_cd = null where vina_body_type_cd in ('P4D', 'T', 'P', 'T2W', 'P4H', 'PSW', 'PC4', 'P3P', 'C', 'M')$q$, year);
    execute format($q$update temp_vehicle_%s set veh_position = null where veh_position = '00'$q$, year);
    execute format($q$update temp_vehicle_%s set avoid_man_cd = null where avoid_man_cd = '9'$q$, year);
    execute format($q$update temp_vehicle_%s set make_cd = null where make_cd in ('KALM', 'KNNW', 'BLUI')$q$, year);
    execute format($q$update temp_crash_%s set police_agcy = null where police_agcy in ('00000', '15601', '68K00', '68Z99')$q$, year);
    
    /* Year-specific. */
    -- If anything here occurs in more than one year, move above to apply to all years.
    if year = '2024' then
        -- Make values not in lookup tables null.
        execute format($q$update temp_trailveh_%s set trl_veh_reg_state = null where trl_veh_reg_state = '1'$q$, year);

    elseif year = '2023' then
        -- Make values not in lookup tables null.
        execute format($q$update temp_cycle_%s set mc_dvr_hlmt_type = null where mc_dvr_hlmt_type = ' '$q$, year);
        execute format($q$update temp_cycle_%s set mc_pas_hlmt_type = null where mc_pas_hlmt_type = ' '$q$, year);
        execute format($q$update temp_trailveh_%s set trl_veh_reg_state = null where trl_veh_reg_state = '0'$q$, year);

        -- Change invalid values/codes used for null to null.
        execute format($q$update temp_commveh_%s set axle_cnt = null where axle_cnt = '99'$q$, year);
        execute format($q$update temp_commveh_%s set gvwr = null where gvwr = 'UNKNOW'$q$, year);

        -- Miscellaneous fixes.
        execute format($q$update temp_commveh_%s set gvwr = replace(gvwr, ',', '')$q$, year);

    elseif year = '2022' then
        -- Make values not in lookup tables null.
        execute format($q$update temp_roadway_%s set county = null where county = '68'$q$, year);

    end if;
end;
$body$
