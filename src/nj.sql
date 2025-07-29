-- Import functions.
\i src/nj/lookup_tables.sql
\i src/nj/create_data_tables.sql
\i src/nj/populate_data_tables.sql
\i src/nj/clean_data.sql
\i src/nj/alter_temp_domains.sql

-- Create and populate lookup tables if they don't already exist/aren't populated.
create schema if not exists nj_2017_lookup; 
call nj_create_and_populate_2017_lookup_tables();
-- commit;

-- Import NJ data.
do
$import$
declare
    start_year int = current_setting('myvars.nj_start_year');
    end_year int = current_setting('myvars.nj_end_year');
    years int[] := ARRAY(SELECT * FROM generate_series(start_year, end_year));
    year int;
begin
    raise info 'In NJ script';
    foreach year in array years loop
        raise info 'NJ %', year;

        raise info 'Create schema';
        execute format($q$create schema if not exists nj_%s$q$, year);

        raise info 'Create and populate data tables';
        call nj_create_data_tables(year::text);
        call nj_populate_data_tables(year::text);

        raise info 'Add indexes to tables';
        -- ?

        commit;
    end loop;

end;
$import$
language plpgsql;

vacuum analyze
