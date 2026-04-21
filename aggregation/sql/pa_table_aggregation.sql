create schema if not exists pa;

create or replace procedure pa.table_aggregation_union(
    db_table text,
    start_year int,
    end_year int
)
language plpgsql
as $func$
declare
    sql  text := '';
    year int;
    schema_name text;
begin
    for year in start_year..end_year loop
        schema_name := 'pa_' || year;  -- compute schema_name for this year

        if sql = '' then
            sql := format('select * from %I.%I', schema_name, db_table);
        else
            sql := sql || ' UNION ALL ' || format('select * from %I.%I', schema_name, db_table);
        end if;
    end loop;

    -- Drop existing view if it exists
    execute format('drop view if exists pa.%I', 'all_' || db_table);

    -- Create the aggregated view
    execute format('create view pa.%I as %s', 'all_' || db_table, sql);
end;
$func$;

call pa.table_aggregation_union('commveh'::text, 2005, 2024);
call pa.table_aggregation_union('crash'::text, 2005, 2024);
call pa.table_aggregation_union('cycle'::text, 2005, 2024);
call pa.table_aggregation_union('flags', 2005, 2024);
call pa.table_aggregation_union('person', 2005, 2024);
call pa.table_aggregation_union('roadway', 2005, 2024);
call pa.table_aggregation_union('trailveh', 2005, 2024);
call pa.table_aggregation_union('vehicle', 2005, 2024);