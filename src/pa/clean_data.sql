create or replace procedure pa_clean_data(year text)
language plpgsql
as
$body$
begin

    if year = '2023' then
        -- Alter values supposed to be from lookup tables that aren't in lookup tables.
        execute format($q$update temp_cycle_%s set mc_dvr_hlmt_type = null where mc_dvr_hlmt_type = ' '$q$, year);
        execute format($q$update temp_cycle_%s set mc_pas_hlmt_type = null where mc_pas_hlmt_type = ' '$q$, year);
        execute format($q$update temp_person_%s set extric_ind = null where extric_ind = '9'$q$, year);
        execute format($q$update temp_person_%s set restraint_helmet = null where restraint_helmet in ('13', '14')$q$, year);
        execute format($q$update temp_person_%s set seat_position = null where seat_position in ('16', '17', '18', '19', '20')$q$, year);
        execute format($q$update temp_roadway_%s set rdwy_orient = null where rdwy_orient = 'B'$q$, year);
        execute format($q$update temp_trailveh_%s set trl_veh_reg_state = null where trl_veh_reg_state = '0'$q$, year);
        execute format($q$update temp_vehicle_%s set avoid_man_cd = null where avoid_man_cd = '9'$q$, year);
        execute format($q$update temp_vehicle_%s set make_cd = null where make_cd in ('KALM', 'KNNW')$q$, year);
        execute format($q$update temp_vehicle_%s set veh_position = null where veh_position = '00'$q$, year);
        execute format($q$update temp_vehicle_%s set vina_body_type_cd = null where vina_body_type_cd in ('T', 'P4D', 'P', 'PSW', 'P4H', 'C', 'M', 'P3P', 'T2W', 'PC4')$q$, year);

        -- Change invalid values/codes used for null to null.
        execute format($q$update temp_crash_%s set arrival_tm = null where arrival_tm::int > 2359$q$, year);
        execute format($q$update temp_crash_%s set dispatch_tm = null where dispatch_tm::int > 2359$q$, year);
        execute format($q$update temp_crash_%s set est_hrs_closed = null where est_hrs_closed::int > 2359$q$, year);
        execute format($q$update temp_crash_%s set hour_of_day = null where hour_of_day::int > 23$q$, year);
        execute format($q$update temp_crash_%s set roadway_cleared = null where roadway_cleared::int > 2359$q$, year);
        execute format($q$update temp_crash_%s set time_of_day = null where time_of_day::int > 2359$q$, year);
        execute format($q$update temp_commveh_%s set axle_cnt = null where axle_cnt = '99'$q$, year);
        execute format($q$update temp_commveh_%s set gvwr = null where gvwr = 'UNKNOW'$q$, year);
        execute format($q$update temp_person_%s set age = null where age = '99'$q$, year);

        -- Miscellaneous fixes.
        execute format($q$update temp_commveh_%s set gvwr = replace(gvwr, ',', '')$q$, year);
        execute format($q$update temp_trailveh_%s set trl_veh_tag_yr = null where trl_veh_tag_yr::int < 1900$q$, year);

        /* The data dictionary lists no lookup table but possible values "01 = non-permitted load, 02 =
        permitted load, 99 = unknown)" for the "permitted" column of the commveh table. Convert to
        values that can be used to interpret int to boolean (below). */
        execute format($q$update temp_commveh_%s set permitted = '0' where permitted = '01'$q$, year);
        execute format($q$update temp_commveh_%s set permitted = '1' where permitted = '02'$q$, year);
        execute format($q$update temp_commveh_%s set permitted = null where permitted = '99'$q$, year);


        /* The data dictionary lists possible values 1=yes 0=No for hazmat_rel_ind1 through
        hazmat_rel_ind4, but the values in the CSVS are 1,2,9. Assuming 1=true, 2=false so they
        can be converted to booleans properly. (9 and U handled in << bool_conversion >> loop.) */
        execute format($q$update temp_commveh_%s set hazmat_rel_ind1 = '0' where hazmat_rel_ind1 = '2'$q$, year);
        execute format($q$update temp_commveh_%s set hazmat_rel_ind1 = null where hazmat_rel_ind1 = '09'$q$, year);

        -- A boolean change, but which seems unique to this field and possibly meant to be something else.
        execute format($q$update temp_person_%s set transported = null where transported = 'R'$q$, year);
    end if;
end;
$body$
