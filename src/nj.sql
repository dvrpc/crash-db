-- Import functions.
\i src/nj/v2006_create_lookup_tables.sql
\i src/nj/v2017_create_lookup_tables.sql
\i src/nj/v2006_create_data_tables.sql
\i src/nj/v2017_create_data_tables.sql
\i src/nj/populate_data_tables.sql
\i src/nj/insert_data.sql
\i src/nj/clean_data.sql
\i src/nj/alter_temp_domains.sql

-- Create and populate lookup tables if they don't already exist/aren't populated.
create schema if not exists nj_2006_lookup; 
call nj_v2006_create_and_populate_lookup_tables();
create schema if not exists nj_2017_lookup; 
call nj_v2017_create_and_populate_lookup_tables();

-- Import NJ data.
do
$import$
declare
    start_year int = current_setting('myvars.nj_start_year');
    end_year int = current_setting('myvars.nj_end_year');
    years int[] := ARRAY(SELECT * FROM generate_series(start_year, end_year));
    year int;
begin
    foreach year in array years loop
        raise info 'NJ %', year;

        raise info 'Create schema';
        execute format($q$create schema if not exists nj_%s$q$, year);

        raise info 'Create and populate data tables';
        if year >= 2006 and year <= 2016 then
            call nj_v2006_create_data_tables(year::text);
        elseif year >= 2017 and year <= 2022 then 
            call nj_v2017_create_data_tables(year::text);
        end if;

        call nj_populate_data_tables(year::text);

        raise info 'Add indexes to tables';
        -- ?

        commit;
    end loop;

end;
$import$
language plpgsql;

vacuum analyze
