do $body$
declare
	col_name text;
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
            -- raise notice 'hi';
            execute format($query$alter table temp_%I alter column %I type text$query$, db_table, col_name);
        end loop;
    end loop;
    

    /*
        Copy the data into those tempoary tables.
    */
    -- crash
    copy temp_crash from '/tmp/crash-data/pa/2023/CRASH_BUCKS_2023.csv' with (format csv, header, force_null *);
    copy temp_crash from '/tmp/crash-data/pa/2023/CRASH_CHESTER_2023.csv' with (format csv, header, force_null *);
    copy temp_crash from '/tmp/crash-data/pa/2023/CRASH_DELAWARE_2023.csv' with (format csv, header, force_null *);
    copy temp_crash from '/tmp/crash-data/pa/2023/CRASH_MONTGOMERY_2023.csv' with (format csv, header, force_null *);
    copy temp_crash from '/tmp/crash-data/pa/2023/CRASH_PHILADELPHIA_2023.csv' with (format csv, header, force_null *);

    -- commveh
    -- copy temp_commveh from '/tmp/crash-data/pa/2023/COMMVEH_BUCKS_2023.csv' with (format csv, header, force_null *);
    -- copy temp_commveh from '/tmp/crash-data/pa/2023/COMMVEH_CHESTER_2023.csv' with (format csv, header, force_null *);
    -- copy temp_commveh from '/tmp/crash-data/pa/2023/COMMVEH_DELAWARE_2023.csv' with (format csv, header, force_null *);
    -- copy temp_commveh from '/tmp/crash-data/pa/2023/COMMVEH_MONTGOMERY_2023.csv' with (format csv, header, force_null *);
    -- copy temp_commveh from '/tmp/crash-data/pa/2023/COMMVEH_PHILADELPHIA_2023.csv' with (format csv, header, force_null *);

    -- cycle
    -- copy temp_cycle from '/tmp/crash-data/pa/2023/CYCLE_BUCKS_2023.csv' with (format csv, header, force_null *);
    -- copy temp_cycle from '/tmp/crash-data/pa/2023/CYCLE_CHESTER_2023.csv' with (format csv, header, force_null *);
    -- copy temp_cycle from '/tmp/crash-data/pa/2023/CYCLE_DELAWARE_2023.csv' with (format csv, header, force_null *);
    -- copy temp_cycle from '/tmp/crash-data/pa/2023/CYCLE_MONTGOMERY_2023.csv' with (format csv, header, force_null *);
    -- copy temp_cycle from '/tmp/crash-data/pa/2023/CYCLE_PHILADELPHIA_2023.csv' with (format csv, header, force_null *);


    -- flag
    -- copy temp_flag from '/tmp/crash-data/pa/2023/FLAG_BUCKS_2023.csv' with (format csv, header, force_null *);
    -- copy temp_flag from '/tmp/crash-data/pa/2023/FLAG_CHESTER_2023.csv' with (format csv, header, force_null *);
    -- copy temp_flag from '/tmp/crash-data/pa/2023/FLAG_DELAWARE_2023.csv' with (format csv, header, force_null *);
    -- copy temp_flag from '/tmp/crash-data/pa/2023/FLAG_MONTGOMERY_2023.csv' with (format csv, header, force_null *);
    -- copy temp_flag from '/tmp/crash-data/pa/2023/FLAG_PHILADELPHIA_2023.csv' with (format csv, header, force_null *);

    -- person
    -- copy temp_person from '/tmp/crash-data/pa/2023/PERSON_BUCKS_2023.csv' with (format csv, header, force_null *);
    -- copy temp_person from '/tmp/crash-data/pa/2023/PERSON_CHESTER_2023.csv' with (format csv, header, force_null *);
    -- copy temp_person from '/tmp/crash-data/pa/2023/PERSON_DELAWARE_2023.csv' with (format csv, header, force_null *);
    -- copy temp_person from '/tmp/crash-data/pa/2023/PERSON_MONTGOMERY_2023.csv' with (format csv, header, force_null *);
    -- copy temp_person from '/tmp/crash-data/pa/2023/PERSON_PHILADELPHIA_2023.csv' with (format csv, header, force_null *);

    -- roadway
    copy temp_roadway from '/tmp/crash-data/pa/2023/ROADWAY_BUCKS_2023.csv' with (format csv, header, force_null *);
    copy temp_roadway from '/tmp/crash-data/pa/2023/ROADWAY_CHESTER_2023.csv' with (format csv, header, force_null *);
    copy temp_roadway from '/tmp/crash-data/pa/2023/ROADWAY_DELAWARE_2023.csv' with (format csv, header, force_null *);
    copy temp_roadway from '/tmp/crash-data/pa/2023/ROADWAY_MONTGOMERY_2023.csv' with (format csv, header, force_null *);
    copy temp_roadway from '/tmp/crash-data/pa/2023/ROADWAY_PHILADELPHIA_2023.csv' with (format csv, header, force_null *);

    -- trailveh
    -- copy temp_trailveh from '/tmp/crash-data/pa/2023/TRAILVEH_BUCKS_2023.csv' with (format csv, header, force_null *);
    -- copy temp_trailveh from '/tmp/crash-data/pa/2023/TRAILVEH_CHESTER_2023.csv' with (format csv, header, force_null *);
    -- copy temp_trailveh from '/tmp/crash-data/pa/2023/TRAILVEH_DELAWARE_2023.csv' with (format csv, header, force_null *);
    -- copy temp_trailveh from '/tmp/crash-data/pa/2023/TRAILVEH_MONTGOMERY_2023.csv' with (format csv, header, force_null *);
    -- copy temp_trailveh from '/tmp/crash-data/pa/2023/TRAILVEH_PHILADELPHIA_2023.csv' with (format csv, header, force_null *);

    -- vehicle
    copy temp_vehicle from '/tmp/crash-data/pa/2023/VEHICLE_BUCKS_2023.csv' with (format csv, header, force_null *);
    copy temp_vehicle from '/tmp/crash-data/pa/2023/VEHICLE_CHESTER_2023.csv' with (format csv, header, force_null *);
    copy temp_vehicle from '/tmp/crash-data/pa/2023/VEHICLE_DELAWARE_2023.csv' with (format csv, header, force_null *);
    copy temp_vehicle from '/tmp/crash-data/pa/2023/VEHICLE_MONTGOMERY_2023.csv' with (format csv, header, force_null *);
    copy temp_vehicle from '/tmp/crash-data/pa/2023/VEHICLE_PHILADELPHIA_2023.csv' with (format csv, header, force_null *);
    
    -- Alter the values of the fields that are supposed to be booleans - e.g. set 'U' and
    -- ints higher than to null.
    foreach db_table in array db_tables loop
        for col_name in select column_name from information_schema.Columns where table_name = db_table and table_schema = 'pa_2023' and data_type = 'boolean' loop
            execute format($query$update temp_%I set %I = Null where %I = 'U'$query$, db_table, col_name, col_name);
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
    end loop;

    /*
        Convert the fields to correct types
        TODO: use an array for the types rather this manual method
    */
    foreach db_table in array db_tables loop
        for col_name in select column_name from information_schema.Columns where table_name = db_table and table_schema = 'pa_2023' and data_type = 'boolean' loop
            execute format($query$alter table temp_%I alter %I type boolean using %I::boolean$query$, db_table, col_name, col_name);
        end loop;

        for col_name in select column_name from information_schema.Columns where table_name = db_table and table_schema = 'pa_2023' and data_type = 'integer' loop
            execute format($query$alter table temp_%I alter %I type integer using %I::integer$query$, db_table, col_name, col_name);
        end loop;

        for col_name in select column_name from information_schema.Columns where table_name = db_table and table_schema = 'pa_2023' and data_type = 'numeric' loop
            execute format($query$alter table temp_%I alter %I type numeric using %I::numeric$query$, db_table, col_name, col_name);
        end loop;
    end loop;


    -- Copy the data from the temp tables into the non-temp tables.
    foreach db_table in array db_tables loop
        execute format($query$insert into pa_2023.%I select * from temp_%I$query$, db_table, db_table);
    end loop;
    

end; $body$
language plpgsql;
