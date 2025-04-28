-- Set the directory where the data is accessible from. The setup_db.sh script cp'd it here.
\set data_dir '/tmp/crash-data'

-- Create schemas.
\i src/create_schemas.sql

-- Create and populate PA 2023 tables.
\i src/pa/2023/create_populate_lookup_tables.sql
\i src/pa/2023/create_data_tables.sql
\i src/pa/2023/populate_data_tables.sql

