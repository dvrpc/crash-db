create or replace procedure nj_clean_data(year text)
language plpgsql
as
$body$
declare
    col_name text;
    col_name2 text;
    tbl_schema text;
    tbl_name text;
    tbl_name2 text;
    cons_name text;
begin

    raise info '..Fix miscellaneous issues';

    -- Cleaning that applies to all years comes first; below that is year-specific cleaning.
    /* All years. */

    -- "dir_of_travel" in the pedestrian & vehicle tables is the only one that uses a lookup code
    -- rather than first letter of cardinal direction. Make it consistent with the others.
    -- codes are on p. 79 of 2017 Crash Report Manual and on NJTR_1 forms.
    execute format($q$update temp_pedestrian_%s set dir_of_travel = null where dir_of_travel not in ('01', '02', '03', '04')$q$, year);
    execute format($q$update temp_pedestrian_%s set dir_of_travel = 'N' where dir_of_travel = '01'$q$, year);    
    execute format($q$update temp_pedestrian_%s set dir_of_travel = 'E' where dir_of_travel = '02'$q$, year);    
    execute format($q$update temp_pedestrian_%s set dir_of_travel = 'S' where dir_of_travel = '03'$q$, year);    
    execute format($q$update temp_pedestrian_%s set dir_of_travel = 'W' where dir_of_travel = '04'$q$, year);    
    execute format($q$update temp_vehicle_%s set dir_of_travel = '03' where dir_of_travel in ('3 ', '3')$q$, year);
    execute format($q$update temp_vehicle_%s set dir_of_travel = null where dir_of_travel not in ('01', '02', '03', '04')$q$, year);
    execute format($q$update temp_vehicle_%s set dir_of_travel = 'N' where dir_of_travel = '01'$q$, year);    
    execute format($q$update temp_vehicle_%s set dir_of_travel = 'E' where dir_of_travel = '02'$q$, year);    
    execute format($q$update temp_vehicle_%s set dir_of_travel = 'S' where dir_of_travel = '03'$q$, year);    
    execute format($q$update temp_vehicle_%s set dir_of_travel = 'W' where dir_of_travel = '04'$q$, year);
    
    /* Year-specific. */
    if year = '2023' then
        /* these are alphabetical by field name, then table */
        -- execute format($q$update temp_<table>_%s set <field> = null where <field> = '98'$q$, year);
        
        execute format($q$update temp_occupant_%s set airbag_deployment = null where airbag_deployment = '98'$q$, year);

        execute format($q$update temp_pedestrian_%s set contrib_circ1 = null where contrib_circ1 = '98'$q$, year);
        execute format($q$update temp_pedestrian_%s set contrib_circ2 = null where contrib_circ2 = '98'$q$, year);

        -- Some distance_to_cross_street values are floats or end with '.', trim them.
        execute format($q$update temp_crash_%s set distance_to_cross_street = rtrim(distance_to_cross_street, '.1234567890')$q$, year);

        execute format($q$update temp_crash_%s set environmental_condition = null where environmental_condition = '98'$q$, year);
        execute format($q$update temp_crash_%s set environmental_condition = '01' where environmental_condition = '1'$q$, year);

        execute format($q$update temp_occupant_%s set ejection = null where ejection in ('10', '98')$q$, year);

        execute format($q$update temp_crash_%s set first_harmful_event = null where first_harmful_event = '98'$q$, year);

        execute format($q$update temp_crash_%s set light_condition = null where light_condition = '98'$q$, year);

        execute format($q$update temp_occupant_%s set location_of_most_severe_injury = null where location_of_most_severe_injury = '98'$q$, year);
        execute format($q$update temp_pedestrian_%s set location_of_most_severe_injury = null where location_of_most_severe_injury = '98'$q$, year);

        execute format($q$update temp_crash_%s set milepost = '25.90' where milepost = '2590.00'$q$, year);

        -- These do not appear to be valid ncic codes or are out of the four-county area.
        -- <https://dot.nj.gov/transportation/refdata/accident/pdf/CountyMunicipalCodes1-13-17.pdf>
        -- <https://www.nj.gov/treasury/taxation/pdf/lpt/cntycode.pdf>
        execute format($q$delete from temp_crash_%s where ncic_code in ('0800', '0826', '1216')$q$, year);
        execute format($q$delete from temp_occupant_%s where ncic_code in ('0800', '0826', '1216')$q$, year);

        -- "O" (oh) is no apparent injury, 05
        execute format($q$update temp_occupant_%s set physical_condition = '05' where physical_condition = 'O'$q$, year);

        execute format($q$update temp_occupant_%s set physical_condition = null where physical_condition in ('06', '98')$q$, year);

        execute format($q$update temp_pedestrian_%s set physical_condition = null where physical_condition in ('98')$q$, year);

        execute format($q$update temp_pedestrian_%s set physical_status1 = null where physical_status1 = '98'$q$, year);
        execute format($q$update temp_pedestrian_%s set physical_status2 = null where physical_status2 = '98'$q$, year);

        execute format($q$update temp_occupant_%s set position_in_veh = null where position_in_veh = '98'$q$, year);

        execute format($q$update temp_occupant_%s set refused_med_attn = '01' where refused_med_attn = '1'$q$, year);
        execute format($q$update temp_occupant_%s set refused_med_attn = '02' where refused_med_attn = '2'$q$, year);
        execute format($q$update temp_pedestrian_%s set refused_med_attn = '01' where refused_med_attn = '1'$q$, year);
        execute format($q$update temp_pedestrian_%s set refused_med_attn = '02' where refused_med_attn = '2'$q$, year);

        execute format($q$update temp_crash_%s set road_divided_by = null where road_divided_by = '98'$q$, year);

        execute format($q$update temp_crash_%s set road_grade = null where road_grade = '98'$q$, year);

        execute format($q$update temp_crash_%s set road_horizontal_alignment = null where road_horizontal_alignment = '98'$q$, year);

        execute format($q$update temp_crash_%s set road_surface_condition = '01' where road_surface_condition = '1'$q$, year);
        execute format($q$update temp_crash_%s set road_surface_condition = null where road_surface_condition = '98'$q$, year);

        execute format($q$update temp_crash_%s set road_surface_type = '02' where road_surface_type = '2'$q$, year);
        execute format($q$update temp_crash_%s set road_surface_type = null where road_surface_type = '98'$q$, year);

        execute format($q$update temp_crash_%s set road_system = null where road_system = '0'$q$, year);

        -- safety_equipment lookup: 10 and 11 are now reserved; 98 undocumented
        execute format($q$update temp_occupant_%s set safety_equipment_available = null where safety_equipment_available in ('10', '11', '98')$q$, year);
        execute format($q$update temp_occupant_%s set safety_equipment_used = null where safety_equipment_used in ('10', '11', '98')$q$, year);
        execute format($q$update temp_pedestrian_%s set safety_equipment_used = null where safety_equipment_used in ('10', '11', '98')$q$, year);

        execute format($q$update temp_pedestrian_%s set traffic_controls = null where traffic_controls = '98'$q$, year);

        execute format($q$update temp_crash_%s set temp_traffic_control_zone = null where temp_traffic_control_zone = '98'$q$, year);

        execute format($q$update temp_occupant_%s set type_of_most_severe_injury = null where type_of_most_severe_injury = '98'$q$, year);
        execute format($q$update temp_pedestrian_%s set type_of_most_severe_injury = null where type_of_most_severe_injury = '98'$q$, year);

        execute format($q$update temp_crash_%s set unit_of_measure = 'FE' where unit_of_measure = 'FT'$q$, year);
    elseif year = '2022' then
        execute format($q$update temp_occupant_%s set airbag_deployment = null where airbag_deployment in ('05', '06')$q$, year);
    elseif year = '2017' then
        execute format($q$update temp_vehicle_%s set veh_color = 'WT' where veh_color = 'WHI'$q$, year);
    elseif year = '2007' then
        execute format($q$update temp_vehicle_%s set veh_color = 'BL' where veh_color = 'BLE'$q$, year);
        execute format($q$update temp_vehicle_%s set veh_color = null where veh_color in ('?',  '1', '26', '4 D', '7', 'AL', 'B', 'B?', 'BC', 'BDY', 'BER', 'BLE', 'BLV', 'BND', 'BRG', 'BY', 'CA', 'CAB', 'CAM', 'CBK', 'CHR', 'CLK', 'DAR', 'EGG', 'FAW', 'FUS', 'GR', 'GR.', 'K', 'MAL', 'MER', 'MIT', 'MN.', 'N', 'OLI', 'OLV', 'OVA', 'PAT', 'PEA', 'PLA', 'PU', 'RES', 'RS', 'ROS', 'RUS', 'R/W', 'SLK', 'SPR', 'STE', 'TC', 'TEE', 'TER', 'TNA', 'TNG', 'TP', 'TU', 'W?', 'WOO')$q$, year);
    elseif year = '2006' then
        execute format($q$update temp_occupant_%s set ejection = '01' where ejection = '1'$q$, year);
        execute format($q$update temp_vehicle_%s set removed_by = null where removed_by = '?'$q$, year);
        execute format($q$update temp_vehicle_%s set veh_color = null where veh_color in ('?', '0', '0?', '00', '01', '02', '1', '28', '3G', '6', '96', 'A/E', 'ALB', 'ALE', 'ASH', 'AUB', 'B', 'B?', 'BB', 'BC', 'BD', 'BE', 'BEN', 'BER', 'BH', 'BL.', 'BL?', 'BLG', 'BNT', 'BOL', 'BON', 'BQ', 'BRG', 'BRU', 'BU', 'BUS', 'BW', 'BY', 'CA', 'CAL', 'CAR', 'CAS', 'CH', 'CHE', 'CHM', 'CHO', 'CHP', 'CHR', 'CK', 'CN', 'COA', 'CP', 'CRA', 'CUT', 'CY', 'DAR', 'DGR', 'DK?', 'DL', 'DRK', 'ELA', 'ELE', 'EME', 'EMR', 'FAW', 'FL', 'GB', 'GDB', 'GEE', 'GR', 'GR.', 'GW', 'ION', 'IRI', 'JAR', 'LK', 'LT.', 'MA', 'MAG', 'MAL', 'MAP', 'MCH', 'MD', 'MET', 'MGN', 'MIS', 'MND', 'MO', 'MON', 'MUR', 'OLI', 'OLV', 'OPA', 'OYS', 'PAT', 'PAU', 'PAW', 'PEA', 'PIA', 'PLA', 'PLT', 'PRW', 'PSG', 'PTR', 'PW', 'PWR', 'QUE', 'R', 'RAL', 'RAS', 'ROS', 'RS', 'RST', 'RSW', 'RUM', 'RUS', 'RWB', 'SAT', 'SC', 'SD', 'SDF', 'SDN', 'SEA', 'SEN', 'SGE', 'SHA', 'SIE', 'SK', 'SLA', 'SMO', 'SN', 'SSY', 'STE', 'STL', 'STO', 'SUN', 'SVR', 'SWT', 'TBZ', 'TD', 'TEL', 'TER', 'TG', 'THU', 'TI', 'TIL', 'TOA', 'TOP', 'TOU', 'TP', 'TUN', 'TW', 'W?', 'WC', 'WD', 'WN', 'WY')$q$, year);
    end if;

    if 2017 <= year::int AND year::int <= 2023 then
        -- 09 is reserved is veh_type
        execute format($q$update temp_vehicle_%s set veh_type = null where veh_type = '09'$q$, year);    
    end if;

    if 2006 <= year::int AND year::int <= 2016 then
        -- safety_equipment lookup: 07 is reserved
        execute format($q$update temp_occupant_%s set safety_equipment_used = null where safety_equipment_used = '07'$q$, year);
        execute format($q$update temp_occupant_%s set safety_equipment_available = null where safety_equipment_available = '07'$q$, year);

        -- pre_crash_action lookup: 42 is reserved
        execute format($q$update temp_vehicle_%s set pre_crash_action = null where pre_crash_action = '42'$q$, year);
        execute format($q$update temp_pedestrian_%s set pre_crash_action = null where pre_crash_action = '42'$q$, year);

        -- veh_type lookup: 09 is reserved
        execute format($q$update temp_vehicle_%s set veh_type = null where veh_type = '09'$q$, year);
    end if;

end;
$body$
