create or replace procedure nj_create_data_tables(year text)
language plpgsql
as
$body$
declare
    schema_name text := 'nj_' || year;
begin
    execute format($t1$create unlogged table if not exists %1$s.crash (
        year text_year,
        ncic_code text references nj_2017_lookup.ncic (code),
        dept_case_num text,
        county text,
        municipality text,
        date date,
        day_of_week text,
        time_of_day text24hhmm,
        police_dept_code text references nj_2017_lookup.police_dept (code),
        police_dept text,
        police_station text,
        total_killed integer,
        total_injured integer,
        pedestrians_killed integer,
        pedestrians_injured integer,
        -- TODO: Ask about this.
        -- 2022 contains P,F,I; property damage, fatal, injury?
        severity text,
        -- TODO: Ask about this.
        -- 2022 contains B,R,I
        intersection text,
        alcohol_involved boolean,
        hazmat_involved boolean,
        crash_type text references nj_2017_lookup.crash_type (code),
        total_vehicles integer,
        crash_location text,
        location_dir text_direction,
        route text,
        -- TODO: Ask about this.
        -- Values in 2022 (1,2,3,A,C,T,S,Z) do not match route suffix codes (A,B,C,M,P,S,T,U,L,W)
        -- in 2017 Crash Report Manual (p.25).
        route_suffix text,
        sri text,
        milepost numeric(6,3),
        road_system text references nj_2017_lookup.road_system (code),
        road_character text,
        road_horizontal_alignment text references nj_2017_lookup.road_horizontal_alignment (code),
        road_grade text references nj_2017_lookup.road_grade (code),
        road_surface_type text references nj_2017_lookup.road_surface_type (code),
        road_surface_condition text references nj_2017_lookup.road_surface_condition (code),
        light_condition text references nj_2017_lookup.light_condition (code),
        environmental_condition text references nj_2017_lookup.environmental_condition (code),
        road_divided_by text references nj_2017_lookup.road_divided_by (code),
        temp_traffic_control_zone text references nj_2017_lookup.temp_traffic_control_zone (code),
        distance_to_cross_street integer,
        unit_of_measure text references nj_2017_lookup.unit_of_measure (code),
        dir_from_cross_street text_direction,
        cross_street_name text,
        is_ramp boolean,
        ramp_to_from_name text,
        ramp_to_from_route_dir text_direction_bound,
        posted_speed integer,
        posted_speed_cross_street integer,
        first_harmful_event text references nj_2017_lookup.sequence_of_events (code),
        latitude text,
        longitude text,
        cell_phone_in_use boolean,
        other_property_damage text,
        report_badge_num text
    )$t1$, schema_name, year);

    execute format($t1$create unlogged table if not exists %1$s.driver (
        year text_year,
        ncic_code text references nj_2017_lookup.ncic (code),
        dept_case_num text,
        veh_num integer,
        driver_city text,
        driver_state text,
        driver_zip_code text,
        driver_license_state text,
        driver_sex text,
        alcohol_test_given text references nj_2017_lookup.alcohol_test_given (code),
        alcohol_test_type text references nj_2017_lookup.alcohol_test_type (code),
        alcohol_test_results numeric(4,2),
        charge1 text,
        summons1 text,
        charge2 text,
        summons2 text,
        charge3 text,
        summons3 text,
        charge4 text,
        summons4 text,
        multi_charge boolean,
        driver_physical_status1 text references nj_2017_lookup.physical_status (code),
        driver_physical_status2 text references nj_2017_lookup.physical_status (code)
    )$t1$, schema_name, year);

    execute format($t1$create unlogged table if not exists %1$s.occupant (
        year text_year,
        ncic_code text references nj_2017_lookup.ncic (code),
        dept_case_num text,
        veh_num integer,
        occupant_num integer,
        physical_condition text references nj_2017_lookup.physical_condition (code),
        position_in_veh text references nj_2017_lookup.position_in_veh (code),
        ejection text references nj_2017_lookup.ejection (code),
        age text,
        sex text,
        location_of_most_severe_injury text references nj_2017_lookup.location_of_most_severe_injury (code),
        type_of_most_severe_injury text references nj_2017_lookup.type_of_most_severe_injury (code),
        refused_med_attn text references nj_2017_lookup.refused_med_attn (code),
        safety_equipment_available text references nj_2017_lookup.safety_equipment (code),
        safety_equipment_used text references nj_2017_lookup.safety_equipment (code),
        airbag_deployment text references nj_2017_lookup.airbag_deployment (code),
        -- 2017 Crash Report Manual (p. 58) points to
        -- <http://www.nj.gov/transportation/refdata/accident/policeres.shtm, which eventually>
        -- leads to
        -- <http://www.nj.gov/health/ems/documents/special_services/hospital_infomation.pdf>.
        hospital_code text
    )$t1$, schema_name, year);

    execute format($t1$create unlogged table if not exists %1$s.pedestrian (
        year text_year,
        ncic_code text references nj_2017_lookup.ncic (code),
        dept_case_num text,
        pedestrian_num integer,
        physical_condition text references nj_2017_lookup.physical_condition (code),
        address_city text,
        address_state text,
        address_zip text,
        age text,
        sex text,
        alcohol_test_given text references nj_2017_lookup.alcohol_test_given (code),
        alcohol_test_type text references nj_2017_lookup.alcohol_test_type (code),
        alcohol_test_results numeric(4,2),
        charge1 text,
        summons1 text,
        charge2 text,
        summons2 text,
        charge3 text,
        summons3 text,
        charge4 text,
        summons4 text,
        multi_charge boolean,
        traffic_controls text references nj_2017_lookup.traffic_controls (code),
        contrib_circ1 text references nj_2017_lookup.contrib_circ (code),
        contrib_circ2 text references nj_2017_lookup.contrib_circ (code),
        dir_of_travel text_direction,
        pre_cash_action text references nj_2017_lookup.pre_crash_action (code),
        location_of_most_severe_injury text references nj_2017_lookup.location_of_most_severe_injury (code),
        type_of_most_severe_injury text references nj_2017_lookup.type_of_most_severe_injury (code),
        refused_med_attn text references nj_2017_lookup.refused_med_attn (code),
        safety_equipment_used text references nj_2017_lookup.safety_equipment (code),
        -- See comment above in occupant table.
        hospital_code text,
        physical_status1 text references nj_2017_lookup.physical_status (code),
        physical_status2 text references nj_2017_lookup.physical_status (code),
        is_bicycle boolean,
        is_other boolean
    )$t1$, schema_name, year);

    execute format($t1$create unlogged table if not exists %1$s.vehicle (
        year text_year,
        ncic_code text references nj_2017_lookup.ncic (code),
        dept_case_num text,
        veh_num integer,
        insurance_co_code text,
        owner_state text,
        veh_make text,
        veh_model text,
        veh_color text references nj_2017_lookup.veh_color (code),
        veh_year text,
        license_plate_state text,
        veh_weight_rating text references nj_2017_lookup.veh_weight_rating (code),
        towed boolean,
        removed_by text references nj_2017_lookup.removed_by (code),
        driven_left_towed text references nj_2017_lookup.driven_left_towed (code),
        initial_impact_location text references nj_2017_lookup.veh_impact_area (code),
        principle_damage_location text references nj_2017_lookup.veh_impact_area (code),
        extent_of_damage text references nj_2017_lookup.extent_of_damage (code),
        traffic_controls_present text references nj_2017_lookup.traffic_controls (code),
        veh_type text references nj_2017_lookup.veh_type (code),
        veh_use text references nj_2017_lookup.veh_use (code),
        special_function_vehicles text references nj_2017_lookup.special_function_vehicles (code),
        cargo_body_type text references nj_2017_lookup.cargo_body_type (code),
        contrib_circ1 text references nj_2017_lookup.contrib_circ (code),
        contrib_circ2 text references nj_2017_lookup.contrib_circ (code),
        dir_of_travel text_direction,
        pre_crash_action text references nj_2017_lookup.pre_crash_action (code),
        first_seq_events text references nj_2017_lookup.sequence_of_events (code),
        second_seq_events text references nj_2017_lookup.sequence_of_events (code),
        third_seq_events text references nj_2017_lookup.sequence_of_events (code),
        fourth_seq_events text references nj_2017_lookup.sequence_of_events (code),
        most_harmful_event text references nj_2017_lookup.sequence_of_events (code),
        oversized_overweight_permit text references nj_2017_lookup.oversized_overweight_permit (code),
        hazmat_status text references nj_2017_lookup.hazmat_status (code),
        -- This comes from the number on the hazmat placard (NJ 2017 Crash Report Manual, p. 44).
        hazmat_class text,
        hazmat_placard text,
        usdot_num text,
        mc_mx_num text,
        usdot_other boolean,
        usdot_other_num text,
        carrier_name text,
        hit_run_driver boolean
    )$t1$, schema_name, year);

end;
$body$
