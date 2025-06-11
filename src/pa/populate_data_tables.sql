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
        For those that will be booleans, use the broadest domain that can be unambiguously converted
        to booleans (in cleaning data fn).
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
      If data population into the temp tables failed because of a bad value, alter the type to
      determine what it is, so it can be inserted and then cleaned later.
    */
    call pa_alter_temp_domains(year);

    /*
        Copy the data into those temporary tables.
    */
    foreach db_table in array db_tables loop
        execute format($q$copy temp_%I_%s from '%s/pa/district/%s_D06_%s.csv' with (format csv, header, force_null *)$q$, db_table, year, user_data_dir, upper(db_table), year);
    end loop;

    -- Clean bad values.
    call pa_clean_data(year);

    -- Copy the data from the temp tables into the non-temp tables, by exporting to file and then reimporting. Easiest way to go from text types in temp tables to types in non-temp tables.
    foreach db_table in array db_tables loop
        execute format($q$copy temp_%I_%s to '%s/%I.csv' with (format csv, header)$q$, db_table, year, postgres_data_dir, db_table);
        execute format($q$copy pa_%s.%I from '%s/%I.csv' with (format csv, header, force_null *)$q$, year, db_table, postgres_data_dir, db_table); 
    end loop;

    -- -- Add indexes to tables.
    execute format($q$alter table pa_%s.crash add primary key(crn)$q$, year);
    execute format($q$alter table pa_%s.commveh add primary key (crn, unit_num)$q$, year);
    execute format($q$alter table pa_%s.cycle add primary key (crn, unit_num)$q$, year);
    execute format($q$alter table pa_%s.flag add primary key(crn)$q$, year);
    -- execute format($q$alter table pa_%s.person add primary key (crn, unit_num)$q$, year);
    execute format($q$alter table pa_%s.trailveh add primary key(crn, unit_num, trl_seq_num)$q$, year);
    execute format($q$alter table pa_%s.vehicle add primary key (crn, unit_num)$q$, year);
end;
$body$
