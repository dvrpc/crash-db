create schema if not exists nj;

create or replace procedure nj.table_aggregation_union(
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
        schema_name := 'nj_' || year;  -- compute schema_name for this year

        if sql = '' then
            sql := format('select * from %I.%I', schema_name, db_table);
        else
            sql := sql || ' UNION ALL ' || format('select * from %I.%I', schema_name, db_table);
        end if;
    end loop;

    -- Drop existing view if it exists
    execute format('drop view if exists nj.%I', 'all_' || db_table);

    -- Create the aggregated view
    execute format('create view nj.%I as %s', 'all_' || db_table, sql);
end;
$func$;

call nj.table_aggregation_union('crash'::text, 2017, 2022);
call nj.table_aggregation_union('occupant'::text, 2017, 2022);
call nj.table_aggregation_union('pedestrian'::text, 2017, 2022);
call nj.table_aggregation_union('driver'::text, 2017, 2022);
