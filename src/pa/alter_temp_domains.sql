create or replace procedure pa_alter_temp_domains(year text)
language plpgsql
as
$body$
begin

    -- Alter domains of temporary tables so that data can be inserted and cleaned later. Start with
    -- most restrictive domains and move to less restrictive until success.

    /* There are some fields that use lookup tables to reflect boolean values. Alter the domain
        to reflect these. In cleaning data function (after they data has been entered), we'll
        convert them to booleans.
    */
    execute format($q$alter table temp_commveh_%s alter permitted type text_01_02_99_as_bool using permitted::text_01_02_99_as_bool$q$, year);
    execute format($q$alter table temp_commveh_%s alter hazmat_rel_ind1 type text129_as_bool using hazmat_rel_ind1::text129_as_bool$q$, year);
    execute format($q$alter table temp_commveh_%s alter hazmat_rel_ind2 type text129_as_bool using hazmat_rel_ind2::text129_as_bool$q$, year);
    execute format($q$alter table temp_commveh_%s alter hazmat_rel_ind3 type text129_as_bool using hazmat_rel_ind3::text129_as_bool$q$, year);
    execute format($q$alter table temp_commveh_%s alter hazmat_rel_ind4 type text129_as_bool using hazmat_rel_ind4::text129_as_bool$q$, year);

    -- text24hhmm FAILED (contains 9999). 
    execute format($q$alter table temp_crash_%s alter arrival_tm type text24hhmm_9999 using arrival_tm::text24hhmm_9999$q$, year);
    execute format($q$alter table temp_crash_%s alter dispatch_tm type text24hhmm_9999 using dispatch_tm::text24hhmm_9999$q$, year);
    execute format($q$alter table temp_crash_%s alter roadway_cleared type text24hhmm_9999 using roadway_cleared::text24hhmm_9999$q$, year);
    execute format($q$alter table temp_crash_%s alter time_of_day type text24hhmm_9999 using time_of_day::text24hhmm_9999$q$, year);

    -- text00_23 FAILED (contains 99).
    execute format($q$alter table temp_crash_%s alter hour_of_day type text00_23_99 using hour_of_day::text00_23_99$q$, year);

    -- roadway_cleared FAILED (contains float).
    execute format($q$alter table temp_crash_%s alter roadway_cleared type numeric(4,0) using roadway_cleared::numeric(4,0)$q$, year);
   
    -- transported FAILED broad text_as_bool (contains R).
    execute format($q$alter table temp_person_%s alter transported type textYNR_as_bool using transported::textYNR_as_bool$q$, year);

    -- domain text_year FAILED (contains 999)
    execute format($q$alter table temp_trailveh_%s alter trl_veh_tag_yr type text_year_greater_than_0 using trl_veh_tag_yr::text_year_greater_than_0$q$, year);

end;
$body$
