-- Create and populate a table to pass through variables from shell to sql scripts.
create temporary table tmp_vars( 
    name text,
    value text
);
insert into tmp_vars (name, value) values ('user_data_dir', :'user_data_dir');
insert into tmp_vars (name, value) values ('postgres_data_dir', :'postgres_data_dir');


-- Domains that data should ulimately conform to.
create domain text24hhmm text check(value::int <= 2359);
create domain text00_23 text check(value::int between 0 and 23);
create domain text_year text check(value::int >= 1900);
create domain text_month text check(value::int between 1 and 12);

/*
    Temporary domains - used in order to get invalid data into temporary tables, which will
    then be cleaned before going into the non-temp tables.
*/
create domain text24hhmm_9999 text check(value::int <= 2359 or value::int = 9999);
create domain text00_23_99 text check(value::int between 0 and 23 or value::int = 99);

-- Domain to allow years < 1900 through before being cleaned.
create domain text_year_greater_than_0 text check(value::int > 0);

/*
    Boolean domains, using text as the base.
    The first one is the broadest that can be successfully and unambigously
    converted into boolean (after 9 and U converted to null). In the attempt to validate the
    data in the tempoary tables, it should be used first. If the values in a field fail it, the
    ones below, starting from most restrictive to least, should then be used.
*/
create domain text019YNUspace_as_bool text check(value in ('0', '1', 'Y', 'N', 'U', '9', ' '));
create domain text01_as_bool text check(value in ('0', '1'));
create domain text012_as_bool text check(value in ('0', '1', '2'));
create domain text0129_as_bool text check(value in ('0', '1', '2', '9'));
create domain text0129U_as_bool text check(value in ('0', '1', '2', '9', 'U'));
create domain text029U_as_bool text check(value in ('0', '2', '9', 'U'));
create domain text12_as_bool text check(value in ('1', '2'));
create domain text129_as_bool text check(value in ('1', '2', '9'));
create domain text19_as_bool text check(value in ('1', '9'));
create domain text9_as_bool text check(value = '9');
create domain textYNR_as_bool text check(value in ('Y', 'N', 'R'));
create domain textYNU_as_bool text check(value in ('Y', 'N', 'U'));
create domain text_01_02_99_as_bool text check(value in ('01', '02', '99'));
create domain text_0_1_01_02_99_as_bool text check(value in ('0', '1', '01', '02', '99'));
create domain text_0_1_2_11_as_bool text check(value in ('0', '1', '2', '11'));
create domain text_0_1_2_3_11_as_bool text check(value in ('0', '1', '2', '3', '11'));
create domain text_0_1_2_3_7_11_as_bool text check(value in ('0', '1', '2', '3', '7', '11'));

-- Create schemas.
\i src/create_schemas.sql

-- Load functions.
\i src/pa/lookup_tables.sql
\i src/pa/create_data_tables.sql
\i src/pa/populate_data_tables.sql
\i src/pa/clean_data.sql
\i src/pa/alter_temp_domains.sql

-- Create and populate PA 2023 tables.
call pa_create_and_populate_lookup_tables('2023');
call pa_create_data_tables('2023');
call pa_populate_data_tables('2023');

-- Create and populate PA 2022 tables.
call pa_create_and_populate_lookup_tables('2022');
call pa_create_data_tables('2022');
call pa_populate_data_tables('2022');

