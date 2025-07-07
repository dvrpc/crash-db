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
                execute format($q$copy temp_crash_%s_one_column from '%s/nj/%s%sAccidents.txt' with (format text, encoding 'SQL-ASCII')$q$, year, user_data_dir, county, year);
            end loop;
        else
            foreach county in array counties loop
                execute format($q$copy temp_%s_%s_one_column from '%s/nj/%s%s%ss.txt' with (format text, encoding 'SQL-ASCII')$q$, db_table, year, user_data_dir, county, year, initcap(db_table));
            end loop;
        end if;
    end loop;


    raise info '.Create temporary tables for cleaning data';
    foreach db_table in array db_tables loop
        execute format($tt$create temporary table temp_%s_%s (like nj_%s.%I including all) on commit drop$tt$, db_table, year, year, db_table);
        -- execute format($tt$create table temp_%s_%s (like nj_%s.%I including all)$tt$, db_table, year, year, db_table);
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
    -- call nj_alter_temp_domains(year);

    raise info '.Parse columns from spec & insert into second set of temporary tables';
    foreach db_table in array db_tables loop
        for line in execute format($q$select one_column from temp_%s_%s_one_column$q$, db_table, year) loop
            if db_table = 'crash' then
                execute format($q1$
                    insert into temp_%s_%s values (
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s
                    )
                $q1$,
                    db_table,
                    year,
                    quote_nullable(trim(substring(line,1,4))),
                    quote_nullable(trim(substring(line,5,2))),
                    quote_nullable(trim(substring(line,7,2))),
                    quote_nullable(trim(substring(line,9,23))),
                    quote_nullable(trim(substring(line,33,12))),
                    quote_nullable(trim(substring(line,46,24))),
                    quote_nullable(trim(substring(line,71,10))),
                    quote_nullable(trim(substring(line,82,2))),
                    quote_nullable(trim(substring(line,85,4))),
                    quote_nullable(trim(substring(line,90,2))),
                    quote_nullable(trim(substring(line,93,25))),
                    quote_nullable(trim(substring(line,119,15))),
                    quote_nullable(trim(substring(line,135,2))),
                    quote_nullable(trim(substring(line,138,2))),
                    quote_nullable(trim(substring(line,141,2))),
                    quote_nullable(trim(substring(line,144,2))),
                    quote_nullable(trim(substring(line,147,1))),
                    quote_nullable(trim(substring(line,149,1))),
                    quote_nullable(trim(substring(line,151,1))),
                    quote_nullable(trim(substring(line,153,1))),
                    quote_nullable(trim(substring(line,155,2))),
                    quote_nullable(trim(substring(line,158,2))),
                    quote_nullable(trim(substring(line,161,50))),
                    quote_nullable(trim(substring(line,212,1))),
                    quote_nullable(trim(substring(line,214,4))),
                    quote_nullable(trim(substring(line,219,1))),
                    quote_nullable(trim(substring(line,221,16))),
                    quote_nullable(trim(substring(line,238,7))),
                    quote_nullable(trim(substring(line,246,2))),
                    quote_nullable(trim(substring(line,249,2))),
                    quote_nullable(trim(substring(line,252,2))),
                    quote_nullable(trim(substring(line,255,2))),
                    quote_nullable(trim(substring(line,258,2))),
                    quote_nullable(trim(substring(line,261,2))),
                    quote_nullable(trim(substring(line,264,2))),
                    quote_nullable(trim(substring(line,267,2))),
                    quote_nullable(trim(substring(line,270,2))),
                    quote_nullable(trim(substring(line,273,2))),
                    quote_nullable(trim(substring(line,276,4))),
                    quote_nullable(trim(substring(line,281,2))),
                    quote_nullable(trim(substring(line,284,1))),
                    quote_nullable(trim(substring(line,286,35))),
                    quote_nullable(trim(substring(line,322,1))),
                    quote_nullable(trim(substring(line,324,25))),
                    quote_nullable(trim(substring(line,350,2))),
                    quote_nullable(trim(substring(line,353,2))),
                    quote_nullable(trim(substring(line,356,2))),
                    quote_nullable(trim(substring(line,359,2))),
                    quote_nullable(trim(substring(line,362,9))),
                    quote_nullable(trim(substring(line,372,9))),
                    quote_nullable(trim(substring(line,382,1))),
                    quote_nullable(trim(substring(line,384,80))),
                    quote_nullable(trim(substring(line,465,5)))
                );
            end if;
            -- raise info '%', substring(line, 33, 12);
        end loop;
    end loop;


    -- Run analyze on temporary tables, which should improve performance on queries on them.
    foreach db_table in array db_tables loop
        execute format($a$ analyze temp_%I_%s$a$, db_table, year);
    end loop;

    -- raise info '.Clean bad values';
    -- call nj_clean_data(year);

    raise info '.Copy from temp to non-temp tables';
    -- Copy the data from the temp tables into the non-temp tables, by exporting to file and then reimporting. Easiest way to go from text types in temp tables to types in non-temp tables.
    foreach db_table in array db_tables loop
        execute format($q$copy temp_%I_%s to '%s/%I.csv' with (format csv, header)$q$, db_table, year, postgres_data_dir, db_table);
        execute format($q$copy nj_%s.%I from '%s/%I.csv' with (format csv, header, force_null *)$q$, year, db_table, postgres_data_dir, db_table); 
    end loop;
end;
$body$
