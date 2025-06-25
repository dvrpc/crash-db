-- Set level of messages displayed.
set client_min_messages = error;

-- Set postgres vars from shell vars.
set myvars.user_data_dir = :'user_data_dir';
set myvars.postgres_data_dir = :'postgres_data_dir';
