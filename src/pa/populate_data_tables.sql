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

      The first ones here before the procedure call are common and thus applied to all years.
    */

    -- text24hhmm FAILED (contains 9999). 
    execute format($q$alter table temp_crash_%s alter arrival_tm type text24hhmm_9999 using arrival_tm::text24hhmm_9999$q$, year);
    execute format($q$alter table temp_crash_%s alter dispatch_tm type text24hhmm_9999 using dispatch_tm::text24hhmm_9999$q$, year);
    execute format($q$alter table temp_crash_%s alter roadway_cleared type text24hhmm_9999 using roadway_cleared::text24hhmm_9999$q$, year);
    execute format($q$alter table temp_crash_%s alter time_of_day type text24hhmm_9999 using time_of_day::text24hhmm_9999$q$, year);

    -- text00_23 FAILED (contains 99).
    execute format($q$alter table temp_crash_%s alter hour_of_day type text00_23_99 using hour_of_day::text00_23_99$q$, year);

    -- Now handle by year.
    call pa_alter_temp_domains(year);

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

    -- Clean data with year-specific handling.
    call pa_clean_data(year);
    
    -- Alter the values of the fields in the temp tables that will end up being booleans - e.g.
    -- set 'U' and ints higher than 1 to null. Applied to all years.
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


    -- Copy the data from the temp tables into the non-temp tables, by exporting to file and then reimporting. Easiest way to go from text types in temp tables to types in non-temp tables.
    foreach db_table in array db_tables loop
        execute format($q$copy temp_%I_%s to '%s/%I.csv' with (format csv, header)$q$, db_table, year, postgres_data_dir, db_table);
        execute format($q$copy pa_%s.%I from '%s/%I.csv' with (format csv, header, force_null *)$q$, year, db_table, postgres_data_dir, db_table); 
    end loop;

end;
$body$
