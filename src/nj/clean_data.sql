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
    
    /* Year-specific. */
    if year = '2022' then
        execute format($q$update temp_occupant_%s set airbag_deployment = null where airbag_deployment in ('05', '06')$q$, year);
    end if;

end;
$body$
