-- Creates geometry for PA crash data using latitude/longitude fields
-- Converts coordinates from dd mm:ss.ddd format to decimal degrees

CREATE OR REPLACE FUNCTION pa_generate_crash_geometry(schema_name text)
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
    latlon_updates integer := 0;
BEGIN
    --lat/lon conversion from dd mm:ss.ddd to decimal degrees
    EXECUTE format($sql$
        UPDATE %1$s.crash
        SET geom = ST_SetSRID(ST_Point((
            CAST(SUBSTRING(longitude FROM 1 FOR POSITION(' ' IN longitude) - 1) AS NUMERIC) + 
            CAST(SUBSTRING(longitude FROM POSITION(' ' IN longitude) + 1 FOR POSITION(':' IN longitude) - POSITION(' ' IN longitude) - 1) AS NUMERIC) / 60 + 
            CAST(SUBSTRING(longitude FROM POSITION(':' IN longitude) + 1) AS NUMERIC) / 3600) * -1,
            (CAST(SUBSTRING(latitude FROM 1 FOR POSITION(' ' IN latitude) - 1) AS NUMERIC) + 
            CAST(SUBSTRING(latitude FROM POSITION(' ' IN latitude) + 1 FOR POSITION(':' IN latitude) - POSITION(' ' IN latitude) - 1) AS NUMERIC) / 60 + 
            CAST(SUBSTRING(latitude FROM POSITION(':' IN latitude) + 1) AS NUMERIC) / 3600)
        ), 4326)
        WHERE geom IS NULL
          AND latitude IS NOT NULL 
          AND longitude IS NOT NULL
          AND latitude != ''
          AND longitude != ''
          AND latitude ~ '^\d+ \d+:\d+\.\d+$'
          AND longitude ~ '^\d+ \d+:\d+\.\d+$'
    $sql$, schema_name);
    
    GET DIAGNOSTICS latlon_updates = ROW_COUNT;
    
    RAISE NOTICE 'Geometry generation complete for %:', schema_name;
    RAISE NOTICE '  - Lat/Lon conversions: % crashes', latlon_updates;
    
    RETURN format('Updated %s crashes via lat/lon conversion in %s', 
                  latlon_updates, schema_name);
END;
$$;

-- make geometry for all PA crash tables in the configured year range
DO $$
DECLARE
    year_var integer;
    start_year integer;
    end_year integer;
    result_text text;
BEGIN
    -- variables set by setup_db.sh
    start_year := coalesce(current_setting('myvars.pa_start_year', true)::integer, 2022);
    end_year := coalesce(current_setting('myvars.pa_end_year', true)::integer, 2022);
    
    RAISE NOTICE 'Generating geometry for PA crash data from % to %', start_year, end_year;
    
    -- do each year
    FOR year_var IN start_year..end_year LOOP
        IF EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'pa_' || year_var) THEN
            RAISE NOTICE 'Processing year %...', year_var;
            
            -- add geom column
            EXECUTE format($sql$
                ALTER TABLE pa_%1$s.crash 
                ADD COLUMN IF NOT EXISTS geom geometry(POINT, 4326)
            $sql$, year_var);
            
            -- make geometry for each year
            SELECT pa_generate_crash_geometry('pa_' || year_var) INTO result_text;
            RAISE NOTICE '%', result_text;
        ELSE
            RAISE NOTICE 'Schema pa_% does not exist, skipping', year_var;
        END IF;
    END LOOP;
    
    RAISE NOTICE 'Geometry generation complete for all years';
END;
$$;

-- Example manual usage:
-- SELECT pa_generate_crash_geometry('pa_2022');