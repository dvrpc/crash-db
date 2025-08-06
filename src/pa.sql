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


-- Import functions.
\i src/pa/lookup_tables.sql
\i src/pa/create_data_tables.sql
\i src/pa/populate_data_tables.sql
\i src/pa/clean_data.sql
\i src/pa/alter_temp_domains.sql

-- Create and populate lookup tables if they don't already exist/aren't populated.
create schema if not exists pa_lookup;
call pa_create_and_populate_lookup_tables();
commit;

-- Import PA data.
do
$import$
declare
    start_year int = current_setting('myvars.pa_start_year');
    end_year int = current_setting('myvars.pa_end_year');
    years int[] := ARRAY(SELECT * FROM generate_series(start_year, end_year));
    year int;
begin

    foreach year in array years loop
        raise info 'PA %', year;

        raise info 'Create schema';

        -- Drop any existing schema for the year.
        begin
            execute format($q$drop schema pa_%s cascade$q$, year);
        exception
            when others then
                null;
        end;

        execute format($q$create schema pa_%s$q$, year);

        raise info 'Create and populate data tables';
        call pa_create_data_tables(year::text);
        call pa_populate_data_tables(year::text);

        raise info 'Add indexes to tables';
        execute format($q$alter table pa_%s.crash add primary key(crn)$q$, year);
        execute format($q$alter table pa_%s.commveh add primary key (crn, unit_num)$q$, year);
        execute format($q$alter table pa_%s.cycle add primary key (crn, unit_num)$q$, year);
        execute format($q$alter table pa_%s.flag add primary key(crn)$q$, year);
        -- execute format($q$alter table pa_%s.person add primary key (crn, unit_num)$q$, year);
        execute format($q$alter table pa_%s.trailveh add primary key(crn, unit_num, trl_seq_num)$q$, year);
        execute format($q$alter table pa_%s.vehicle add primary key (crn, unit_num)$q$, year);

        commit;
    end loop;

end;
$import$
language plpgsql;

vacuum analyze
