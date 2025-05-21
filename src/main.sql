-- Create and populate a table to pass through variables from shell to sql scripts.
create temporary table tmp_vars( 
    name text,
    value text
);
insert into tmp_vars (name, value) values ('user_data_dir', :'user_data_dir');
insert into tmp_vars (name, value) values ('postgres_data_dir', :'postgres_data_dir');

-- Create schemas.
\i src/create_schemas.sql

-- Create and populate PA 2023 tables.
\i src/pa/2023/create_populate_lookup_tables.sql
\i src/pa/2023/create_data_tables.sql
\i src/pa/2023/populate_data_tables.sql

