create or replace procedure pa_populate_data_tables(year text)
language plpgsql
as
$body$
declare
    col_name text;
    dat_type text;
    db_tables text[] := '{crash, commveh, cycle, flags, person, roadway, trailveh, vehicle}';
    db_table text;
    counties text[] := '{Bucks, Chester, Delaware, Montgomery, Philadelphia}';
    county text;
    user_data_dir text = current_setting('myvars.user_data_dir');
    postgres_data_dir text = current_setting('myvars.postgres_data_dir');
    
begin
    raise info '.Create temporary tables for cleaning data';
    foreach db_table in array db_tables loop
        execute format($tt$create temporary table temp_%I_%s (like pa_%s.%I including all) on commit drop$tt$, db_table, year, year, db_table);
    end loop;

    /*
        Change field types in the temp tables to text so they'll accept all data (to fix later).
        For those that will be booleans, use the broadest domain that can be unambiguously converted
        to booleans (in cleaning data fn).
    */
    raise info '.Change field types in temp tables';
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
      If data population into the temp tables failed (below) because of a bad value, alter the
      type to determine what it is, so it can be inserted and then cleaned later.
    */
    raise info '.Alter domains';
    call pa_alter_temp_domains(year);

    raise info '.Copy data into temporary tables';
    foreach db_table in array db_tables loop
        foreach county in array counties loop
            execute format($q$copy temp_%I_%s from '%s/pa/%s_%s_%s.csv' with (format csv, header, force_null *)$q$, db_table, year, user_data_dir, upper(db_table), upper(county), year);
        end loop;
    end loop;

    -- Run analyze on temporary tables, which should improve performance on queries on them.
    foreach db_table in array db_tables loop
        execute format($a$ analyze temp_%I_%s$a$, db_table, year);
    end loop;

    raise info '.Clean bad values';
    call pa_clean_data(year);

    raise info '.Copy from temp to non-temp tables';
    -- Copy the data from the temp tables into the non-temp tables, by exporting to file and then reimporting. Easiest way to go from text types in temp tables to types in non-temp tables.
    foreach db_table in array db_tables loop
        execute format($q$copy temp_%I_%s to '%s/%I.csv' with (format csv, header)$q$, db_table, year, postgres_data_dir, db_table);
        execute format($q$copy pa_%s.%I from '%s/%I.csv' with (format csv, header, force_null *)$q$, year, db_table, postgres_data_dir, db_table); 
    end loop;

end;
$body$
