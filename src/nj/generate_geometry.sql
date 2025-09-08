-- Creates geometry using ST_LocateAlong when SRI/milepost available,
-- otherwise uses latitude/longitude fields (with adding - to longitude).

CREATE OR REPLACE FUNCTION nj_generate_crash_geometry(schema_name text)
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
    lrs_updates integer := 0;
    latlon_updates integer := 0;
    total_updates integer := 0;
BEGIN
    -- First, update crashes that have SRI and milepost using LRS.
    EXECUTE format($sql$
        UPDATE %1$s.crash 
        SET geom = ST_Force2D(
    ST_GeometryN(
        ST_LocateAlong(st_transform(r.geom,4326), c.milepost), 
        1
    )
)
        FROM %1$s.crash c
        JOIN public.nj_roads r ON r.sri = c.sri 
            AND c.milepost BETWEEN r.mp_start AND r.mp_end
        WHERE %1$s.crash.ncic_code = c.ncic_code
          AND %1$s.crash.dept_case_num = c.dept_case_num
          AND %1$s.crash.year = c.year
          AND c.sri IS NOT NULL 
          AND c.milepost IS NOT NULL
          AND r.geom IS NOT NULL
    $sql$, schema_name);
    
    GET DIAGNOSTICS lrs_updates = ROW_COUNT;
    
    -- Update remaining crashes using lat/lon (with longitude negated).
    EXECUTE format($sql$
        UPDATE %1$s.crash
        SET geom = ST_SetSRID(ST_MakePoint(
            CASE 
                WHEN longitude::text ~ '^-?[0-9]*\.?[0-9]+$' 
                THEN -(longitude::numeric)  -- negative sign to longitude
                ELSE NULL 
            END,
            CASE 
                WHEN latitude::text ~ '^[0-9]*\.?[0-9]+$' 
                THEN latitude::numeric 
                ELSE NULL 
            END
        ), 4326)
        WHERE geom IS NULL
          AND latitude IS NOT NULL 
          AND longitude IS NOT NULL
          AND latitude != ''
          AND longitude != ''
          AND latitude::text ~ '^[0-9]*\.?[0-9]+$'
          AND longitude::text ~ '^-?[0-9]*\.?[0-9]+$'
    $sql$, schema_name);
    
    GET DIAGNOSTICS latlon_updates = ROW_COUNT;
    
    total_updates := lrs_updates + latlon_updates;
    
    RAISE NOTICE 'Geometry generation complete for %:', schema_name;
    RAISE NOTICE '  - LRS matches: % crashes', lrs_updates;
    RAISE NOTICE '  - Lat/Lon fallback: % crashes', latlon_updates;
    RAISE NOTICE '  - Total updated: % crashes', total_updates;
    
    RETURN format('Updated %s crashes (%s via LRS, %s via lat/lon) in %s', 
                  total_updates, lrs_updates, latlon_updates, schema_name);
END;
$$;

-- Generate geometry for all NJ crash tables in the configured year range.
DO $$
DECLARE
    year_var integer;
    start_year integer;
    end_year integer;
    result_text text;
BEGIN
    -- Get year range from session variables set by setup_db.sh.
    start_year := coalesce(current_setting('session.nj_start_year', true)::integer, 2022);
    end_year := coalesce(current_setting('session.nj_end_year', true)::integer, 2022);
    
    RAISE NOTICE 'Generating geometry for NJ crash data from % to %', start_year, end_year;
    
    -- Process each year in the range.
    FOR year_var IN start_year..end_year LOOP
        -- Check if schema exists.
        IF EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'nj_' || year_var) THEN
            RAISE NOTICE 'Processing year %...', year_var;
            
            -- Add geom column if it doesn't exist.
            EXECUTE format($sql$
                ALTER TABLE nj_%1$s.crash 
                ADD COLUMN IF NOT EXISTS geom geometry(POINT, 4326)
            $sql$, year_var);
            
            -- Generate geometry for this year.
            SELECT nj_generate_crash_geometry('nj_' || year_var) INTO result_text;
            RAISE NOTICE '%', result_text;
        ELSE
            RAISE NOTICE 'Schema nj_% does not exist, skipping', year_var;
        END IF;
    END LOOP;
    
    RAISE NOTICE 'Geometry generation complete for all years';
END;
$$;

-- Example manual usage:
-- SELECT nj_generate_crash_geometry('nj_2022');
