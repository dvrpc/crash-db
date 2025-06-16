-- Create and populate a table to pass through variables from shell to sql scripts.
create temporary table tmp_vars( 
    name text,
    value text
);
insert into tmp_vars (name, value) values ('user_data_dir', :'user_data_dir');
insert into tmp_vars (name, value) values ('postgres_data_dir', :'postgres_data_dir');

-- Create and populate a table for the names of lookup tables to be used in scripts.
create temporary table pa_lookup_table_names(
    name text not null, 
    zero_padded boolean -- Whether or not codes in the table are zero padded.
);
insert into pa_lookup_table_names (name, zero_padded) values
    ('access_ctrl', false),
    ('airbag', true),
    ('airbag_pads', true),
    ('avoid_man_cd', false),
    ('body_type', true),
    ('cargo_bd_type', false),
    ('clothing_type', false),
    ('collision_type', false),
    ('county', true),
    ('damage_ind', false),
    ('day_of_week', false),
    ('district', true),
    ('dvr_ped_condition', false),
    ('dvr_pres_ind', false),
    ('ejection_ind', false),
    ('eject_path_cd', false),
    ('emerg_veh_use_cd', false),
    ('extric_ind', false),
    ('grade', false),
    ('hazmat_code', false),
    ('helmet_type', false),
    ('illumination', false),
    ('inj_severity', false),
    ('intersect_type', true),
    ('impact_point', true),
    ('lane_closure_direction', false),
    ('location_type', false),
    ('max_severity_level', false),
    ('non_motorist_crossing_tcd', true),
    ('non_motorist_distraction', true),
    ('non_motorist_in_crosswalk', false),
    ('non_motorist_powered_conveyance', true),
    ('owner_driver', true),
    ('person_type', false),
    ('relation_to_road', false),
    ('restraint_helmet', true),
    ('rdwy_alignment', false),
    ('rdwy_orient', false),
    ('rdwy_surface_type', false),
    ('road_condition', true),
    ('road_owner', false),
    ('seat_position', true),
    ('sex', false),
    ('special_sizing', true),
    ('special_usage', true),
    ('spec_juris_cd', false),
    ('tcd_func_cd', false),
    ('tcd_type', false),
    ('transported_by', true),
    ('travel_direction', false),
    ('trl_veh_type_cd', false),
    ('type_of_carrier', false),
    ('under_ride_ind', false),
    ('unit_type', true),
    ('urban_rural', false),
    ('veh_color_cd', true),
    ('veh_config_cd', true),
    ('veh_or_non_motorist_movement', true),
    ('veh_or_non_motorist_position', true),
    ('veh_role', false),
    ('veh_or_non_motorist_type', true),
    ('vina_body_type_cd', false),
    ('weather1', true),
    ('weather2', true),
    ('work_zone_loc', false),
    ('work_zone_type', false),
    ('state_code', false),
    ('municipalities', false),
    ('police_agencies', false),
    ('veh_make', false);

-- Domains that data should ultimately conform to.
create domain text24hhmm text check(value::int <= 2359);
create domain text00_23 text check(value::int between 0 and 23);
create domain text_year text check(value::int >= 1900);
create domain text_month text check(value::int between 1 and 12);

/*
    Temporary domains - used in order to get invalid data into temporary tables', which will
    then be cleaned before going into the non-temp tables.
*/
create domain text24hhmm_9999 text check(value::int <= 2359 or value::int = 9999);
create domain text00_23_99 text check(value::int between 0 and 23 or value::int = 99);

-- Domain to allow years < 1900 through before being cleaned.
create domain text_year_greater_than_0 text check(value::int > 0);

/*
    Boolean domains, using text as the base.
    The first one is the broadest that can be successfully and unambiguously
    converted into boolean (after 9 and U converted to null). In the attempt to validate the
    data in the temporary tables, it should be used first. If the values in a field fail it, the
    ones below, starting from most restrictive to least, should then be used.
*/
create domain text019YNUspace_as_bool text check(value in ('0', '0.0', '1', '1.0', 'Y', 'N', 'U', '9', '9.0', ' '));
create domain text01_as_bool text check(value in ('0', '1'));
create domain text012_as_bool text check(value in ('0', '1', '2'));
create domain text0129_as_bool text check(value in ('0', '1', '2', '9'));
create domain text0129U_as_bool text check(value in ('0', '1', '2', '9', 'U'));
create domain text12_as_bool text check(value in ('1', '2'));
create domain text129_as_bool text check(value in ('1', '2', '9'));
create domain textYNR_as_bool text check(value in ('Y', 'N', 'R'));
create domain textYNU_as_bool text check(value in ('Y', 'N', 'U'));
create domain text_01_02_99_as_bool text check(value in ('01', '02', '99'));
create domain text_0_1_01_02_99_as_bool text check(value in ('0', '1', '01', '02', '99'));
create domain text_0_1_2_11_as_bool text check(value in ('0', '1', '2', '11'));
create domain text_0_1_2_3_11_as_bool text check(value in ('0', '1', '2', '3', '11'));
create domain text_0_1_2_3_7_11_as_bool text check(value in ('0', '1', '2', '3', '7', '11'));

-- Domains merely for figuring out what values are contained in a field.
create domain text029U text check(value in ('0', '2', '9', 'U'));

-- Create schemas.
\i src/create_schemas.sql

-- Load functions.
\i src/pa/lookup_tables.sql
\i src/pa/create_data_tables.sql
\i src/pa/populate_data_tables.sql
\i src/pa/clean_data.sql
\i src/pa/alter_temp_domains.sql

call pa_create_and_populate_lookup_tables();

-- Create and populate PA 2024 tables.
call pa_create_data_tables('2024');
call pa_populate_data_tables('2024');

-- Create and populate PA 2023 tables.
call pa_create_data_tables('2023');
call pa_populate_data_tables('2023');

-- Create and populate PA 2022 tables.
call pa_create_data_tables('2022');
call pa_populate_data_tables('2022');

vacuum analyze
