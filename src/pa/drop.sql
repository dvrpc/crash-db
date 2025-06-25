set client_min_messages = error;

do
$body$
declare
    schema_name text;
begin
    raise info 'Dropping all PA objects';
    for schema_name in select nspname from pg_catalog.pg_namespace where nspname like 'pa_%' loop
        execute format($q$drop schema %s cascade$q$, schema_name);
    end loop;
end;
$body$
language plpgsql;
