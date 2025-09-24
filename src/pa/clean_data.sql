create or replace procedure pa_clean_data(year text)
language plpgsql
as
$body$
declare
    lookup_table_names text[] := (select array_agg(name) from pa_lookup_table_names);
    col_name text;
    col_name2 text;
    tbl_schema text;
    tbl_name text;
    tbl_name2 text;
    cons_name text;
    max_hhmm integer = 2400;
    max_hh integer = 2400 / 100;
begin

    raise info '..Fix miscellaneous issues';
    -- Cleaning that applies to all years comes first; below that is year-specific cleaning.

    /* start lookup -> bool */
    -- Convert fields that use lookup tables to represent boolean values into booleans.
    -- First, alter domain to allow 0, then change values.
    
    -- hazmat_rel_ind fields
    execute format($q$alter table temp_commveh_%s alter hazmat_rel_ind1 type text0129_as_bool using hazmat_rel_ind1::text129_as_bool$q$, year);
    execute format($q$alter table temp_commveh_%s alter hazmat_rel_ind2 type text0129_as_bool using hazmat_rel_ind1::text129_as_bool$q$, year);
    execute format($q$alter table temp_commveh_%s alter hazmat_rel_ind3 type text0129_as_bool using hazmat_rel_ind1::text129_as_bool$q$, year);
    execute format($q$alter table temp_commveh_%s alter hazmat_rel_ind4 type text0129_as_bool using hazmat_rel_ind1::text129_as_bool$q$, year);
    -- Order is important: first 1 -> 0 and then 2 -> 1
    execute format($q$update temp_commveh_%s set hazmat_rel_ind1 = '0' where hazmat_rel_ind1 = '1'$q$, year);
    execute format($q$update temp_commveh_%s set hazmat_rel_ind2 = '0' where hazmat_rel_ind2 = '1'$q$, year);
    execute format($q$update temp_commveh_%s set hazmat_rel_ind3 = '0' where hazmat_rel_ind3 = '1'$q$, year);
    execute format($q$update temp_commveh_%s set hazmat_rel_ind4 = '0' where hazmat_rel_ind4 = '1'$q$, year);
    execute format($q$update temp_commveh_%s set hazmat_rel_ind1 = '1' where hazmat_rel_ind1 = '2'$q$, year);
    execute format($q$update temp_commveh_%s set hazmat_rel_ind2 = '1' where hazmat_rel_ind2 = '2'$q$, year);
    execute format($q$update temp_commveh_%s set hazmat_rel_ind3 = '1' where hazmat_rel_ind3 = '2'$q$, year);
    execute format($q$update temp_commveh_%s set hazmat_rel_ind4 = '1' where hazmat_rel_ind4 = '2'$q$, year);
    
    -- permitted   
    execute format($q$alter table temp_commveh_%s alter permitted type text_0_1_01_02_99_as_bool using permitted::text_0_1_01_02_99_as_bool$q$, year);
    execute format($q$update temp_commveh_%s set permitted = '0' where permitted = '01'$q$, year);
    execute format($q$update temp_commveh_%s set permitted = '1' where permitted = '02'$q$, year);
    execute format($q$update temp_commveh_%s set permitted = null where permitted = '99'$q$, year);

    /* end lookup -> bool */

    -- Make invalid HHMM values null.
    execute format($q$update temp_crash_%s set roadway_cleared = null where roadway_cleared > %s$q$, year, max_hhmm);
    execute format($q$update temp_crash_%s set arrival_tm = null where arrival_tm::int > %s$q$, year, max_hhmm);
    execute format($q$update temp_crash_%s set dispatch_tm = null where dispatch_tm::int > %s$q$, year, max_hhmm);
    execute format($q$update temp_crash_%s set time_of_day = null where time_of_day::int > %s$q$, year, max_hhmm);
    execute format($q$update temp_crash_%s set est_hrs_closed = null where est_hrs_closed::int > %s$q$, year, max_hhmm);

    -- Make invalid hours null.
    execute format($q$update temp_crash_%s set hour_of_day = null where hour_of_day::int > %s$q$, year, max_hh);
    execute format($q$update temp_crash_%s set est_hrs_closed = null where est_hrs_closed::int > %s$q$, year, max_hhmm);

    -- A boolean change, but which seems unique to this field and possibly meant to be something else.
    execute format($q$update temp_person_%s set transported = null where transported = 'R'$q$, year);

    -- Make invalid years null.
    execute format($q$update temp_vehicle_%s set model_yr = null where model_yr::int < 1900$q$, year);
    begin
        execute format($q$update temp_trailveh_%s set trl_veh_tag_yr = null where trl_veh_tag_yr::int < 1900$q$, year);
    exception 
        when invalid_text_representation then
            null;
    end;
    
    -- Make values not in lookup tables null.
    execute format($q$update temp_crash_%s set police_agcy = null where police_agcy in ('00000', '02336', '15601', '30601', '46601', '51601', '68000', '68K00', '68S01', '68S02', '68Z99')$q$, year);
    execute format($q$update temp_person_%s set airbag_pads = null where airbag_pads in ('10', '10.0', '12', '12.0')$q$, year);
    execute format($q$update temp_person_%s set dvr_lic_state = null where dvr_lic_state in ('GU', 'NT', 'QR', 'PQ', 'XN', '99')$q$, year);
    execute format($q$update temp_person_%s set extric_ind = null where extric_ind = '9'$q$, year);
    execute format($q$update temp_person_%s set restraint_helmet = null where restraint_helmet in ('13', '13.0', '14', '14.0')$q$, year);
    execute format($q$update temp_person_%s set seat_position = null where seat_position in ('16', '17', '18', '19', '20')$q$, year);
    execute format($q$update temp_person_%s set transported_by = null where transported_by = '03'$q$, year);
    execute format($q$update temp_roadway_%s set county = null where county = '68'$q$, year);
    execute format($q$update temp_roadway_%s set rdwy_orient = null where rdwy_orient = 'B'$q$, year);
    execute format($q$update temp_trailveh_%s set trl_veh_reg_state = null where trl_veh_reg_state in ('??', '0', '1', '99', 'A', 'AA', 'AD', 'B', 'BB', 'BG', 'BQ', 'DO', 'E', 'EB', 'EE', 'F', 'FI', 'G', 'GQ', 'H', 'HA', 'HW', 'HY', 'I', 'IC', 'II', 'IJ', 'PB', 'IU', 'J', 'JB', 'JJ', 'JI', 'JL', 'JO', 'JP', 'JY', 'K', 'KI', 'L', 'M', 'MZ', 'NG', 'NI', 'NT', 'O', 'OY', 'P', 'PM', 'PY', 'Q', 'QB', 'R', 'RA', 'RB', 'RE', 'T', 'TF', 'U', 'UN', 'VJ', 'VN', 'W', 'WL', 'WP', 'X', 'Y', 'YW', 'YX', 'Z', 'ZJ')$q$, year);
    execute format($q$update temp_vehicle_%s set avoid_man_cd = null where avoid_man_cd = '9'$q$, year);
    execute format($q$update temp_vehicle_%s set make_cd = null where make_cd in ('BLUI', 'DGEN', 'ENGF', 'FREF', 'ICBU', 'KALM', 'KNNW', 'TRIU')$q$, year);
    execute format($q$update temp_vehicle_%s set make_cd = 'BMW' where make_cd = 'BMW1'$q$, year);
    execute format($q$update temp_vehicle_%s set veh_position = null where veh_position = '00'$q$, year);
    execute format($q$update temp_vehicle_%s set veh_reg_state = null where veh_reg_state in ('04', '08', '09', '12', '99', 'A', 'AF', 'AP', 'FA', 'KA', 'NT', 'P', 'P-', 'PQ', 'PS', 'PZ', 'UK', 'UN', 'US', 'XN', 'XX', 'Z')$q$, year);
    execute format($q$update temp_vehicle_%s set vina_body_type_cd = null where vina_body_type_cd in ('''', '4C', 'C', 'M', 'P', 'P2C', 'P2W', 'P3D', 'P3P', 'P4C', 'P4D', 'P4H', 'P4L', 'P4P', 'P4T', 'PBU', 'PC4', 'PCC', 'PCG', 'PCU', 'PDS', 'PFW', 'PGS', 'PNX', 'PRS', 'PSD', 'PSV', 'PSW', 'PUT', 'PVN', 'PWC', 'PYY', 'T', 'T2W')$q$, year);
    
    /* Year-specific. */
    -- If anything here occurs in more than one year, move above to apply to all years.
    if year = '2007' or year = '2006' or year = '2005' then
        execute format($q$update temp_person_%s set dvr_ped_condition = null where dvr_ped_condition = '8.0'$q$, year);
    end if;
    
    if year = '2024' then
    elseif year = '2023' then
        -- Make values not in lookup tables null.
        execute format($q$update temp_cycle_%s set mc_dvr_hlmt_type = null where mc_dvr_hlmt_type = ' '$q$, year);
        execute format($q$update temp_cycle_%s set mc_pas_hlmt_type = null where mc_pas_hlmt_type = ' '$q$, year);
        -- Change invalid values/codes used for null to null.
        execute format($q$update temp_commveh_%s set axle_cnt = null where axle_cnt = '99'$q$, year);
        execute format($q$update temp_commveh_%s set gvwr = null where gvwr = 'UNKNOW'$q$, year);

        -- Miscellaneous fixes.
        execute format($q$update temp_commveh_%s set gvwr = replace(gvwr, ',', '')$q$, year);

    elseif year = '2022' then
    elseif year = '2021' then      
    elseif year = '2020' then
    elseif year = '2019' then
    elseif year = '2018' then
    elseif year = '2013' then
        execute format($q$update temp_vehicle_%s set body_type = null where body_type = '77'$q$, year);
    elseif year = '2008' then
        execute format($q$update temp_vehicle_%s set travel_spd = null where travel_spd = 'UNK'$q$, year);
    elseif year = '2007' then
    end if;

    -- Remove decimals from values in fields that reference lookup tables.'
    raise info '..Remove decimals from lookup table values';
    << rm_decimals_text_lookup >>
    for tbl_name, col_name in
        select kcu.table_name, kcu.column_name
            from information_schema.key_column_usage kcu
            join information_schema.constraint_column_usage ccu
                on kcu.constraint_name = ccu.constraint_name
                and kcu.constraint_schema = ccu.constraint_schema
            where ccu.table_schema = 'pa_lookup' and kcu.table_schema = 'pa_' || year
    loop
        begin
            execute format($q$update temp_%I_%s set %I = floor(%I::numeric)::text$q$, tbl_name, year, col_name, col_name);
        exception 
            when invalid_text_representation then
                null;
        end;
    end loop;

    -- Add zero padding for columns using it.'
    raise info '..Zeropad lookup values requiring it';
    << zero_pad_lookup_table_codes >>
    -- Get the lookup tables that use zero padding in their values.
    for tbl_name in select name from pa_lookup_table_names where zero_padded = true
    loop
        -- Use the table name to get name of the foreign key constraints referencing it.
        for cons_name in
            select constraint_name
            from information_schema.constraint_column_usage
            where constraint_schema = 'pa_' || year
                and table_schema = 'pa_lookup'
                and table_name = tbl_name
        loop
            -- Use the constraint name to get the table/column it is used in.
            for tbl_name2, col_name2 in
                select table_name, column_name
                    from information_schema.key_column_usage
                    where constraint_name = cons_name and constraint_schema = 'pa_' || year
            loop
                -- there's one special case we want to skip: "airbag" has numbers that need
                -- zero padded, but a 'M' value that should not be zeropadded.
                if tbl_name2 = 'person' and col_name2 in ('airbag1', 'airbag2', 'airbag3', 'airbag4') then
                    execute format($q$update temp_%I_%s set %I = lpad(%I, 2, '0') WHERE %I != 'M'$q$, tbl_name2, year, col_name2, col_name2, col_name2);
                else
                    execute format($q$update temp_%I_%s set %I = lpad(%I, 2, '0')$q$, tbl_name2, year, col_name2, col_name2);
                end if;
            end loop;
        end loop;
    end loop;

    -- Remove decimals from values in fields that will be integers.'
    raise info '..Remove decimals from values that will be integers';
    << rm_decimals_int >>
    for col_name, tbl_name in select column_name, table_name from information_schema.columns where table_schema = 'pa_' || year and data_type = 'integer' loop
        execute format($q$update temp_%I_%s set %I = floor(%I::numeric)::int$q$, tbl_name, year, col_name, col_name);
    end loop;

    -- Alter the values of the fields in the temp tables that will end up being booleans.
    raise info '..Convert values to booleans';
    << bool_conversion >>
    for col_name, tbl_name in
        select column_name, table_name
            from information_schema.columns
            where table_schema = 'pa_' || year and data_type = 'boolean'
    loop
        -- Change certain values to null.
        execute format($q$update temp_%I_%s set %I = null where %I in ('U', ' ', '9')$q$, tbl_name, year, col_name, col_name);
        -- Remove any decimals.
        begin
            execute format($q$update temp_%I_%s set %I = floor(%I::numeric)::int$q$, tbl_name, year, col_name, col_name);
        exception
            when invalid_text_representation then
                /* No need to do anything here - if it can't be cast as int, that's fine.
                   If the value is Y or N they will be accepted as booleans when data is copied
                   from temp tables, and if not, that step will raise an error. */
                null; 
            when others then
                -- If there are other errors, raise notice showing code.
                raise info '%', SQLSTATE;
        end;
    end loop;
end;
$body$
