create or replace procedure nj_alter_temp_domains(year text)
language plpgsql
as
$body$
begin

    -- Alter domains of temporary tables so that data can be inserted and cleaned later. Start with
    -- most restrictive domains and move to less restrictive until success.

    execute format($q$alter table temp_pedestrian_%s alter dir_of_travel type text_00_04_direction using dir_of_travel::text_00_04_direction$q$, year);
    execute format($q$alter table temp_vehicle_%s alter dir_of_travel type text_00_04_direction using dir_of_travel::text_00_04_direction$q$, year);
end;
$body$
