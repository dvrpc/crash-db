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
        for line in execute format($q1$select one_column from temp_%s_%s_one_column$q1$, db_table, year) loop
            if db_table = 'crash' then
                execute format($q2$insert into temp_%1$s_%2$s values (
                    trim(substring(%3$s from 1 for 4)),
                    trim(substring(%3$s from 5 for 2)),
                    trim(substring(%3$s from 7 for 2)),
                    trim(substring(%3$s from 9 for 23)),
                    trim(substring(%3$s from 33 for 12)),
                    trim(substring(%3$s from 46 for 24)),
                    trim(substring(%3$s from 71 for 10)),
                    trim(substring(%3$s from 82 for 2)),
                    trim(substring(%3$s from 85 for 4)),
                    trim(substring(%3$s from 90 for 2)),
                    trim(substring(%3$s from 93 for 25)),
                    trim(substring(%3$s from 119 for 15)),
                    trim(substring(%3$s from 135 for 2)),
                    trim(substring(%3$s from 138 for 2)),
                    trim(substring(%3$s from 141 for 2)),
                    trim(substring(%3$s from 144 for 2)),
                    trim(substring(%3$s from 147 for 1)),
                    trim(substring(%3$s from 149 for 1)),
                    trim(substring(%3$s from 151 for 1)),
                    trim(substring(%3$s from 153 for 1)),
                    trim(substring(%3$s from 155 for 2)),
                    trim(substring(%3$s from 158 for 2)),
                    trim(substring(%3$s from 161 for 50)),
                    trim(substring(%3$s from 212 for 1)),
                    trim(substring(%3$s from 214 for 4)),
                    trim(substring(%3$s from 219 for 1)),
                    trim(substring(%3$s from 221 for 16)),
                    trim(substring(%3$s from 238 for 7)),
                    trim(substring(%3$s from 246 for 2)),
                    trim(substring(%3$s from 249 for 2)),
                    trim(substring(%3$s from 252 for 2)),
                    trim(substring(%3$s from 255 for 2)),
                    trim(substring(%3$s from 258 for 2)),
                    trim(substring(%3$s from 261 for 2)),
                    trim(substring(%3$s from 264 for 2)),
                    trim(substring(%3$s from 267 for 2)),
                    trim(substring(%3$s from 270 for 2)),
                    trim(substring(%3$s from 273 for 2)),
                    trim(substring(%3$s from 276 for 4)),
                    trim(substring(%3$s from 281 for 2)),
                    trim(substring(%3$s from 284 for 1)),
                    trim(substring(%3$s from 286 for 35)),
                    trim(substring(%3$s from 322 for 1)),
                    trim(substring(%3$s from 324 for 25)),
                    trim(substring(%3$s from 350 for 2)),
                    trim(substring(%3$s from 353 for 2)),
                    trim(substring(%3$s from 356 for 2)),
                    trim(substring(%3$s from 359 for 2)),
                    trim(substring(%3$s from 362 for 9)),
                    trim(substring(%3$s from 372 for 9)),
                    trim(substring(%3$s from 382 for 1)),
                    trim(substring(%3$s from 384 for 80)),
                    trim(substring(%3$s from 465 for 5))
                )$q2$, db_table, year, quote_nullable(line));
            end if;
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
