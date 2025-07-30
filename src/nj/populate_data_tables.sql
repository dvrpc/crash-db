create or replace procedure nj_populate_data_tables(year text)
language plpgsql
as
$body$
declare
    user_data_dir text = current_setting('myvars.user_data_dir');
    postgres_data_dir text = current_setting('myvars.postgres_data_dir');
    col_name text;
    dat_type text;
    db_tables text[] = '{crash, driver, occupant, pedestrian, vehicle}';
    db_table text;
    counties text[] = '{Burlington, Camden, Gloucester, Mercer}';
    county text;
    line text;

begin

    raise info '.Create temporary tables to insert all columns as one column';
    foreach db_table in array db_tables loop
        execute format($tt$create temporary table temp_%s_%s_one_column (one_column text) on commit drop$tt$, db_table, year, year, db_table);
    end loop;

    
    raise info '.Copy data into the one-column temporary tables';
    foreach db_table in array db_tables loop
        -- The data files use "Accident" but the table name is "crash".
        if db_table = 'crash' then
            foreach county in array counties loop
                execute format($q$copy temp_%s_%s_one_column from '%s/nj/%s%sAccidents.txt' with (format text)$q$, db_table, year, user_data_dir, county, year);
            end loop;
        else
            foreach county in array counties loop
                execute format($q$copy temp_%s_%s_one_column from '%s/nj/%s%s%ss.txt' with (format text)$q$, db_table, year, user_data_dir, county, year, initcap(db_table));
            end loop;
        end if;
    end loop;

    raise info '.Create temporary tables for cleaning data';
    foreach db_table in array db_tables loop
        execute format($tt$create temporary table temp_%s_%s (like nj_%s.%I including all) on commit drop$tt$, db_table, year, year, db_table);
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
                execute format($q$alter table temp_%I_%s alter column %I type text019YNTFUspace_as_bool using %I::text019YNTFUspace_as_bool$q$, db_table, year, col_name, col_name);
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
    call nj_alter_temp_domains(year);

    /* NOTE: The Drivers and Pedestrians tables in the 2021 and 2022 files do no match the 
    file specification: DOB has length of 0 rather than 10, so there is a condition for those
    tables to check the year and handle appropriately.
    */
    raise info '.Parse columns from spec & insert into second set of temporary tables';
    foreach db_table in array db_tables loop
        for line in execute format($q1$select one_column from temp_%s_%s_one_column$q1$, db_table, year) loop
            call insert_data(year, db_table, line);
        end loop;
    end loop;

    -- Run analyze on temporary tables, which should improve performance on queries on them.
    foreach db_table in array db_tables loop
        execute format($a$ analyze temp_%I_%s$a$, db_table, year);
    end loop;

    raise info '.Clean bad values';
    call nj_clean_data(year);
    
    raise info '.Copy from temp to non-temp tables';
    -- Copy the data from the temp tables into the non-temp tables, by exporting to file and then reimporting. Easiest way to go from text types in temp tables to types in non-temp tables.
    foreach db_table in array db_tables loop
        execute format($q$copy temp_%I_%s to '%s/%I.csv' with (format csv, header)$q$, db_table, year, postgres_data_dir, db_table);
        execute format($q$copy nj_%s.%I from '%s/%I.csv' with (format csv, header, force_null *)$q$, year, db_table, postgres_data_dir, db_table); 
    end loop;
end;
$body$
