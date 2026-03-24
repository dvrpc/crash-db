create or replace procedure nj_clean_data(year text)
language plpgsql
as
$body$
declare
    db_tables text[] = '{crash, driver, occupant, pedestrian, vehicle}';
    tbl_name text;
    tbl_name2 text;
    col_name text;
    col_name2 text;
    cons_name text;
    -- It's possible these lookup tables that contain zero-padded values could change between
    -- each year of data, so define it within each year's section.
    zeropadded text[]; 
begin

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

        -- '98' is a value in many columns, but is undocumented. Probably used for unknown. (99 is sometimes Other.)
        foreach tbl_name in array db_tables loop
        	for col_name in select column_name from information_schema.columns where table_name = 'temp_' || tbl_name || '_' || year loop
                if col_name not in ('veh_num', 'occupant_num', 'pedestrian_num') then
                    execute format($q$update temp_%s_%s set %s = null where %s = '98'$q$, tbl_name, year, col_name, col_name);
                end if;
            end loop;
        end loop;

    
        -- Add zero padding for columns using it.'
        raise info '..Zeropad lookup values requiring it';
        zeropadded = '{airbag_deployment, cargo_body_type, contrib_circ, crash_type, ejection, environmental_condition, extent_of_damage, light_condition, location_of_most_severe_injury, oversized_overweight_permit, position_in_veh, police_dept, pre_crash_action, refused_med_attn, road_divided_by, road_grade, road_horizontal_alignment, road_surface_condition, road_surface_type, road_system, route_suffix, safety_equipment, sequence_of_events, physical_condition, physical_status, special_function_vehicles, temp_traffic_control_zone, traffic_controls, type_of_most_severe_injury, veh_impact_area, veh_type, veh_use}';

        -- Get the lookup tables that use zero padding in their values.
        foreach tbl_name in array zeropadded loop
            -- Use the table name to get name of the foreign key constraints referencing it.
            -- raise info '%s', tbl_name;
            for cons_name in
                select constraint_name
                from information_schema.constraint_column_usage
                where constraint_schema = 'nj_' || year
                    and table_schema = 'nj_' || year || '_lookup'
                    and table_name = tbl_name
            loop
                -- Use the constraint name to get the table/column it is used in.
                for tbl_name2, col_name2 in
                    select table_name, column_name
                        from information_schema.key_column_usage
                        where constraint_name = cons_name and constraint_schema = 'nj_' || year
                loop
                    execute format($q$update temp_%I_%s set %I = lpad(%I, 2, '0')$q$, tbl_name2, year, col_name2, col_name2);
                end loop;
            end loop;
        end loop;

        -- Some distance_to_cross_street values are floats or end with '.', trim them.
        execute format($q$update temp_crash_%s set distance_to_cross_street = rtrim(distance_to_cross_street, '.1234567890')$q$, year);


        execute format($q$update temp_occupant_%s set ejection = null where ejection = '10'$q$, year);

        execute format($q$update temp_vehicle_%s set initial_impact_location = null where initial_impact_location = '16'$q$, year);

        execute format($q$update temp_crash_%s set milepost = '25.90' where milepost = '2590.00'$q$, year);

        -- These do not appear to be valid ncic codes or are out of the four-county area.
        -- <https://dot.nj.gov/transportation/refdata/accident/pdf/CountyMunicipalCodes1-13-17.pdf>
        -- <https://www.nj.gov/treasury/taxation/pdf/lpt/cntycode.pdf>
        execute format($q$delete from temp_crash_%s where ncic_code in ('0800', '0826', '1216')$q$, year);
        execute format($q$delete from temp_driver_%s where ncic_code in ('0800', '0826', '1216')$q$, year);
        execute format($q$delete from temp_occupant_%s where ncic_code in ('0800', '0826', '1216')$q$, year);
        execute format($q$delete from temp_pedestrian_%s where ncic_code in ('0800', '0826', '1216')$q$, year);
        execute format($q$delete from temp_vehicle_%s where ncic_code in ('0800', '0826', '1216')$q$, year);

        -- "O" (oh) is no apparent injury, 05
        execute format($q$update temp_occupant_%s set physical_condition = '05' where physical_condition = 'O'$q$, year);

        execute format($q$update temp_occupant_%s set physical_condition = '00' where physical_condition = '0O'$q$, year);
        execute format($q$update temp_occupant_%s set physical_condition = null where physical_condition = '06'$q$, year);

        execute format($q$update temp_vehicle_%s set principle_damage_location = null where principle_damage_location = '16'$q$, year);

        execute format($q$update temp_crash_%s set road_system = null where road_system = '0'$q$, year);

        -- safety_equipment lookup: 10 and 11 are now reserved; 98 undocumented
        execute format($q$update temp_occupant_%s set safety_equipment_available = null where safety_equipment_available in ('10', '11')$q$, year);
        execute format($q$update temp_occupant_%s set safety_equipment_used = null where safety_equipment_used in ('10', '11')$q$, year);
        execute format($q$update temp_pedestrian_%s set safety_equipment_used = null where safety_equipment_used in ('10', '11')$q$, year);

        execute format($q$update temp_vehicle_%s set special_function_vehicles = null where special_function_vehicles in ('89', '1F')$q$, year);

        execute format($q$update temp_crash_%s set unit_of_measure = 'FE' where unit_of_measure = 'FT'$q$, year);

        execute format($q$update temp_vehicle_%s set veh_color = null where veh_color in ('99', 'AD', 'B/', 'Be', 'BE', 'Bl', 'BU', 'BZ', 'CA', 'CR', 'DB', 'DG', 'F', 'GL', 'Go', 'GO', 'GR', 'Gr', 'gr', 'LA', 'LB', 'LG', 'MA', 'Mr', 'MU', '.O', 'PN', 'TE', 'TP', 'UK', 'uk', 'un', 'Un')$q$, year);
        execute format($q$update temp_vehicle_%s set veh_color = 'BG' where veh_color = 'Bg'$q$, year);
        execute format($q$update temp_vehicle_%s set veh_color = 'BN' where veh_color in ('Br', 'BR')$q$, year);
        execute format($q$update temp_vehicle_%s set veh_color = 'OG' where veh_color in ('OR', 'ON', 'Sl')$q$, year);
        execute format($q$update temp_vehicle_%s set veh_color = 'RD' where veh_color in ('Re', 'RE', 'Sl')$q$, year);
        execute format($q$update temp_vehicle_%s set veh_color = 'SL' where veh_color in ('Si', 'SI', 'Sl')$q$, year);
        execute format($q$update temp_vehicle_%s set veh_color = 'TN' where veh_color in ('Ta', 'TA')$q$, year);
        execute format($q$update temp_vehicle_%s set veh_color = 'WT' where veh_color in ('Wh', 'WH')$q$, year);
        execute format($q$update temp_vehicle_%s set veh_color = 'YL' where veh_color in ('YE', 'YW')$q$, year);

        execute format($q$update temp_driver_%s set alcohol_test_type = null where alcohol_test_type = '?'$q$, year);

        -- drop V from v1,v2,v3
        execute format($q$update temp_driver_%s set veh_num = '1' where veh_num = 'V1'$q$, year);
        execute format($q$update temp_driver_%s set veh_num = '2' where veh_num = 'V2'$q$, year);
        execute format($q$update temp_driver_%s set veh_num = '3' where veh_num = 'V3'$q$, year);
        execute format($q$update temp_occupant_%s set veh_num = '1' where veh_num = 'V1'$q$, year);
        execute format($q$update temp_occupant_%s set veh_num = '2' where veh_num = 'V2'$q$, year);
        execute format($q$update temp_occupant_%s set veh_num = '3' where veh_num = 'V3'$q$, year);
        execute format($q$update temp_vehicle_%s set veh_num = '1' where veh_num = 'V1'$q$, year);
        execute format($q$update temp_vehicle_%s set veh_num = '2' where veh_num = 'V2'$q$, year);
        execute format($q$update temp_vehicle_%s set veh_num = '3' where veh_num = 'V3'$q$, year);
        
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
