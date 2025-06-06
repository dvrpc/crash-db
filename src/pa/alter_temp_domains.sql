create or replace procedure pa_alter_temp_domains(year text)
language plpgsql
as
$body$
begin
    if year = '2023' then

        -- lane_closed FAILED broad text_as_bool above (contains 2). 
        execute format($q$alter table temp_crash_%s alter lane_closed type text01_as_bool using lane_closed::text01_as_bool$q$, year);
        -- FAILED (contains 0).
        execute format($q$alter table temp_crash_%s alter lane_closed type text12_as_bool using lane_closed::text12_as_bool$q$, year);
        -- FAILED (contains 9).
        execute format($q$alter table temp_crash_%s alter lane_closed type text012_as_bool using lane_closed::text012_as_bool$q$, year);
        -- FAILED (contains U).
        execute format($q$alter table temp_crash_%s alter lane_closed type text0129_as_bool using lane_closed::text0129_as_bool$q$, year);
        -- FAILED (contains 1).
        execute format($q$alter table temp_crash_%s alter lane_closed type text029U_as_bool using lane_closed::text029U_as_bool$q$, year);
        -- Succeeded; this gets turned into bool in the << bool_conversion >> loop below. 
        execute format($q$alter table temp_crash_%s alter lane_closed type text0129U_as_bool using lane_closed::text0129U_as_bool$q$, year);

        -- hazmat_rel_ind1 FAILED broad text_as_bool above (contains 2). 
        execute format($q$alter table temp_commveh_%s alter hazmat_rel_ind1 type textYNU_as_bool using hazmat_rel_ind1::textYNU_as_bool$q$, year);
        -- FAILED (contains 9)
        execute format($q$alter table temp_commveh_%s alter hazmat_rel_ind1 type text01_as_bool using hazmat_rel_ind1::text01_as_bool$q$, year);
        -- FAILED (contains 2)
        execute format($q$alter table temp_commveh_%s alter hazmat_rel_ind1 type text19_as_bool using hazmat_rel_ind1::text9_as_bool$q$, year);
        -- SUCCESS; so field only contains 1,2,9. However, we'll need to change 2 to 0, so have to change again to include it. 
        execute format($q$alter table temp_commveh_%s alter hazmat_rel_ind1 type text129_as_bool using hazmat_rel_ind1::text129_as_bool$q$, year);
        -- Make that final change to this field so we can change 2 to 0 below. It then gets
        -- turned into bool in the <<bool_conversion>> loop.
        execute format($q$alter table temp_commveh_%s alter hazmat_rel_ind1 type text0129_as_bool using hazmat_rel_ind1::text129_as_bool$q$, year);

        -- Convert codes described in table to boolean. First one verifies they are what they are
        -- supposed to be, and the second then allows 0,1 for bool conversion below.
        execute format($q$alter table temp_commveh_%s alter permitted type text_01_02_99_as_bool using permitted::text_01_02_99_as_bool$q$, year);
        execute format($q$alter table temp_commveh_%s alter permitted type text_0_1_01_02_99_as_bool using permitted::text_0_1_01_02_99_as_bool$q$, year);

        -- transported FAILED broad text_as_bool above (contains R).
        execute format($q$alter table temp_person_%s alter transported type textYNR_as_bool using transported::textYNR_as_bool$q$, year);

        -- domain text_year failed, contained 999 as year.
        execute format($q$alter table temp_trailveh_%s alter trl_veh_tag_yr type text_year_greater_than_0 using trl_veh_tag_yr::text_year_greater_than_0$q$, year);

    elseif year = '2022' then
        -- domain text019ynuspace_as_bool_check failed (contained 2). So:
        execute format($q$alter table temp_crash_%s alter intersection_related type text12_as_bool using intersection_related::text12_as_bool$q$, year);
        -- FAILED (contained 0).
        execute format($q$alter table temp_crash_%s alter intersection_related type text012_as_bool using intersection_related::text12_as_bool$q$, year);
        -- FAILED (contained 11).
        execute format($q$alter table temp_crash_%s alter intersection_related type text_0_1_2_11_as_bool using intersection_related::text_0_1_2_11_as_bool$q$, year);
        -- FAILED (contained 3).
        execute format($q$alter table temp_crash_%s alter intersection_related type text_0_1_2_3_11_as_bool using intersection_related::text_0_1_2_3_11_as_bool$q$, year);
        -- FAILED (contained 7).
        execute format($q$alter table temp_crash_%s alter intersection_related type text_0_1_2_3_7_11_as_bool using intersection_related::text_0_1_2_3_7_11_as_bool$q$, year);
        -- FAILED. Ok, at this point, just let everything through and the bool_conversion loop
        -- will convert U & any number > 1 to null.
        execute format($q$alter table temp_crash_%s alter intersection_related type text$q$, year);

        -- domain text019ynuspace_as_bool_check failed (contained 2). So:
        execute format($q$alter table temp_crash_%s alter workers_pres type text12_as_bool using workers_pres::text12_as_bool$q$, year);
        -- FAILED (contains 8). Let everything through and let the bool_conversion loop fix.
        execute format($q$alter table temp_crash_%s alter workers_pres type text$q$, year);

        -- extra column on commveh. It's "type_of_carrier", which is listed in the data dictionary
        -- but was not in the 2023 CSVS and so is - thus far - excluded from our database since
        -- we started with 2023. Have to decide what to do about this.

    end if;
end;
$body$
