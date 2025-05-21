do $body$
declare
	col_name text;
    col_type text;
    db_tables text[] := '{crash, commveh, cycle, flag, person, roadway, trailveh, vehicle}';
    db_table text;
begin
    
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
        Copy the data into those tempoary tables.
    */
    foreach db_table in array db_tables loop
        execute format($query$copy temp_%I from '/tmp/crash-data/pa/2023/%s_BUCKS_2023.csv' with (format csv, header, force_null *)$query$, db_table, upper(db_table));
        execute format($query$copy temp_%I from '/tmp/crash-data/pa/2023/%s_CHESTER_2023.csv' with (format csv, header, force_null *)$query$, db_table, upper(db_table));
        execute format($query$copy temp_%I from '/tmp/crash-data/pa/2023/%s_DELAWARE_2023.csv' with (format csv, header, force_null *)$query$, db_table, upper(db_table));
        execute format($query$copy temp_%I from '/tmp/crash-data/pa/2023/%s_MONTGOMERY_2023.csv' with (format csv, header, force_null *)$query$, db_table, upper(db_table));
        execute format($query$copy temp_%I from '/tmp/crash-data/pa/2023/%s_PHILADELPHIA_2023.csv' with (format csv, header, force_null *)$query$, db_table, upper(db_table));
    end loop;

    -- Alter some specific text field values, usually from lookup tables.
    execute format($query$update temp_cycle set mc_dvr_hlmt_type = Null where mc_dvr_hlmt_type = ' '$query$);
    execute format($query$update temp_cycle set mc_pas_hlmt_type = Null where mc_pas_hlmt_type = ' '$query$);
    execute format($query$update temp_person set extric_ind = Null where extric_ind = '9'$query$);
    execute format($query$update temp_person set restraint_helmet = Null where restraint_helmet in ('13', '14')$query$);
    execute format($query$update temp_person set seat_position = Null where seat_position in ('16', '17', '18', '19', '20')$query$);
    execute format($query$update temp_roadway set rdwy_orient = Null where rdwy_orient = 'B'$query$);
    execute format($query$update temp_trailveh set trl_veh_reg_state = Null where trl_veh_reg_state = '0'$query$);
    execute format($query$update temp_vehicle set avoid_man_cd = Null where avoid_man_cd = '9'$query$);
    execute format($query$update temp_vehicle set make_cd = Null where make_cd in ('KALM', 'KNNW')$query$);
    execute format($query$update temp_vehicle set veh_position = Null where veh_position = '00'$query$);
    execute format($query$update temp_vehicle set vina_body_type_cd = Null where vina_body_type_cd in ('T', 'P4D', 'P', 'PSW', 'P4H', 'C', 'M', 'P3P', 'T2W', 'PC4')$query$);
    
    -- Alter the values of the fields that are supposed to be booleans - e.g. set 'U' and
    -- ints higher than 1 to null.
    foreach db_table in array db_tables loop
        for col_name in select column_name from information_schema.Columns where table_name = db_table and table_schema = 'pa_2023' and data_type = 'boolean' loop
            execute format($query$update temp_%I set %I = Null where %I = 'U'$query$, db_table, col_name, col_name);
            execute format($query$update temp_%I set %I = Null where %I = ' '$query$, db_table, col_name, col_name);
            execute format($query$update temp_%I set %I = '1' where %I = '01'$query$, db_table, col_name, col_name);
            execute format($query$update temp_%I set %I = '0' where %I = '00'$query$, db_table, col_name, col_name);
            -- Must wrap in an exception since the cast could fail.
            begin
                execute format($query$update temp_%I set %I = Null where cast(%I as int) > 1$query$, db_table, col_name, col_name);
            exception
                when invalid_text_representation then
                    NULL; -- No need to do anything here - if it can't be cast as int, that's fine. 
                when others then
                    -- If there are other errors, raise notice showing code.
                    raise notice '%', SQLSTATE;
            end;
        end loop;

    -- Another boolean change, but which seems unique to this field and possibly meant to be something else.
    execute format($query$update temp_person set transported = Null where transported = 'R'$query$);

    end loop;


    -- Copy the data from the temp tables into the non-temp tables, by exporting to file and then reimporting. Easiest way to go from text types in temp tables to types in non-temp tables.
    foreach db_table in array db_tables loop
        execute format($query$copy temp_%I to '/var/lib/postgresql/%I.csv' with (format csv, header)$query$, db_table, db_table);
        execute format($query$copy pa_2023.%I from '/var/lib/postgresql/%I.csv' with (format csv, header, force_null *)$query$, db_table, db_table); 
    end loop;
    

end; $body$
language plpgsql;
