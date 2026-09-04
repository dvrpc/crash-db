--drop materialized view if exists nj_report.report_summary_long_test;
--create materialized view as nj_report.report_summary_long_test as 

WITH person_summary AS (

    /*
     * One row per crash.
     * Calculates:
     *   - maximum crash severity
     *   - whether the crash involved a pedestrian
     *   - whether the crash involved a bicycle
     */

    SELECT
        p.casenumber,

        MIN(
            CASE p.physical_condition
                WHEN '01' THEN 1   -- Fatal
                WHEN '02' THEN 2   -- Suspected Serious Injury
                WHEN '03' THEN 3   -- Suspected Minor Injury
                WHEN '04' THEN 4   -- Possible Injury
                WHEN '05' THEN 5   -- No Apparent Injury
                WHEN '00' THEN 6   -- Other / Unknown
                WHEN '99' THEN 6   -- Other / Unknown
                ELSE 6
            END
        ) AS severity_rank,

        BOOL_OR(p.pedestrian IS TRUE) AS pedestrian_event,
        BOOL_OR(p.is_bicycle IS TRUE) AS bike_event

    FROM nj.all_person p

    GROUP BY
        p.casenumber

),


crashes AS (

    /*
     * One row per crash.
     * Everything in this CTE is crash-level information.
     */

    SELECT
        c.casenumber,
        c."year" AS crash_year,
        INITCAP(c.municipality) AS municipality,
        INITCAP(c.county) AS county,
        c.crash_type,
        c.road_surface_condition,
        c.environmental_condition,
        c.light_condition,
        c."date",
        c.day_of_week,
        c.time_of_day,

        CASE COALESCE(ps.severity_rank, 6)
            WHEN 1 THEN 'Fatal'
            WHEN 2 THEN 'Suspected Serious Injury'
            WHEN 3 THEN 'Suspected Minor Injury'
            WHEN 4 THEN 'Possible Injury'
            WHEN 5 THEN 'No Apparent Injury'
            WHEN 6 THEN 'Other or Unknown'
        END AS max_severity_level,

        ps.pedestrian_event,
        ps.bike_event

    FROM nj.all_crash c

    LEFT JOIN person_summary ps
        ON c.casenumber = ps.casenumber

),


persons AS (

    /*
     * Person-level counts.
     * One row per crash/category.
     * cnt represents PEOPLE, not crashes.
     */

    SELECT
        p.casenumber,
        p.crash_year,
        INITCAP(c.municipality) AS municipality,
        INITCAP(c.county) AS county,
        'person_injury' AS domain,

        CASE
            WHEN p.physical_condition = '01'
                THEN 'Fatal'
            WHEN p.physical_condition = '02'
                THEN 'Suspected Serious Injury'
            WHEN p.physical_condition = '03'
                THEN 'Suspected Minor Injury'
            WHEN p.physical_condition = '04'
                THEN 'Possible Injury'
            WHEN p.physical_condition = '05'
                THEN 'No Injury'
            WHEN p.physical_condition IN ('00', '99')
                 OR p.physical_condition IS NULL
                THEN 'Other or Unknown'
            ELSE 'Other or Unknown'
        END AS category,

        cr.max_severity_level,
        cr.pedestrian_event,
        cr.bike_event,

        COUNT(*) AS cnt

    FROM nj.all_person p

    LEFT JOIN nj.all_crash c
        ON p.casenumber = c.casenumber

    LEFT JOIN crashes cr
        ON p.casenumber = cr.casenumber

    GROUP BY
        p.casenumber,
        p.crash_year,
        c.municipality,
        c.county,

        CASE
            WHEN p.physical_condition = '01'
                THEN 'Fatal'
            WHEN p.physical_condition = '02'
                THEN 'Suspected Serious Injury'
            WHEN p.physical_condition = '03'
                THEN 'Suspected Minor Injury'
            WHEN p.physical_condition = '04'
                THEN 'Possible Injury'
            WHEN p.physical_condition = '05'
                THEN 'No Injury'
            WHEN p.physical_condition IN ('00', '99')
                 OR p.physical_condition IS NULL
                THEN 'Other or Unknown'
            ELSE 'Other or Unknown'
        END,

        cr.max_severity_level,
        cr.pedestrian_event,
        cr.bike_event

),


vehicle_categories AS (

    /*
     * Assign one reporting category to each vehicle.
     * The raw veh_type is retained here but is not needed
     * in the downstream grouping.
     */

    SELECT
        v.casenumber,
        v.veh_type,

        CASE
            WHEN v.veh_type IN ('00', '99')
                 OR v.veh_type IS NULL
                THEN 'Unknown'

            WHEN v.veh_type = '01'
                THEN 'Car/Stationwagon/Minivan'

            WHEN v.veh_type = '04'
                THEN 'SUV'

            WHEN v.veh_type = '05'
                THEN 'Pick up'

            WHEN v.veh_type = '08'
                THEN 'Motorcycle'

            WHEN v.veh_type IN
                ('20','21','22','23','24','25','26','27','29')
                THEN 'Large Truck'

            WHEN v.veh_type IN
                ('02','03','06','07','10','15','16','19','30','31','40')
                THEN 'Other Motor'

            WHEN v.veh_type IN ('12','14')
                THEN 'Other Nonmotor'

            WHEN v.veh_type = '13'
                THEN 'Bicycle'

            ELSE NULL
        END AS category

    FROM nj.all_vehicle v

),


vehicles AS (

    /*
     * Vehicle-level counts.
     * One row per crash/category.
     * cnt represents VEHICLES, not crashes.
     */

    SELECT
        v.casenumber,
        c."year" AS crash_year,
        INITCAP(c.municipality) AS municipality,
        INITCAP(c.county) AS county,
        'vehicle' AS domain,
        v.category,
        cr.max_severity_level,
        cr.pedestrian_event,
        cr.bike_event,

        COUNT(*) AS cnt

    FROM vehicle_categories v

    LEFT JOIN nj.all_crash c
        ON v.casenumber = c.casenumber

    LEFT JOIN crashes cr
        ON v.casenumber = cr.casenumber

    GROUP BY
        v.casenumber,
        c."year",
        c.municipality,
        c.county,
        v.category,
        cr.max_severity_level,
        cr.pedestrian_event,
        cr.bike_event

)


/*
 * =========================================================
 * CRASH-LEVEL DOMAINS
 * =========================================================
 */

SELECT
    c.casenumber,
    c.crash_year,
    c.municipality,
    c.county,
    x.domain,
    x.category,
    c.max_severity_level,
    c.pedestrian_event,
    c.bike_event,
    1 AS cnt

FROM crashes c

CROSS JOIN LATERAL (

    VALUES

        /*
         * MAX SEVERITY
         */

        (
            'max severity',
            c.max_severity_level
        ),

        /*
         * COLLISION TYPE
         */

        (
            'collision_type',

            CASE
                WHEN c.crash_type = '00'
                     OR c.crash_type IS NULL
                    THEN 'Unknown'

                WHEN c.crash_type = '01'
                    THEN 'Same Direction (Rear End)'

                WHEN c.crash_type = '02'
                    THEN 'Same Direction (Sideswipe)'

                WHEN c.crash_type = '03'
                    THEN 'Right Angle'

                WHEN c.crash_type = '04'
                    THEN 'Opposite Direction (Head On, Angular)'

                WHEN c.crash_type = '05'
                    THEN 'Opposite Direction (Sideswipe)'

                WHEN c.crash_type = '06'
                    THEN 'Struck Parked Vehicle'

                WHEN c.crash_type = '07'
                    THEN 'Left Turn/U Turn'

                WHEN c.crash_type = '08'
                    THEN 'Backing'

                WHEN c.crash_type = '09'
                    THEN 'Encroachment'

                WHEN c.crash_type = '10'
                    THEN 'Overturned'

                WHEN c.crash_type = '11'
                    THEN 'Fixed Object'

                WHEN c.crash_type = '12'
                    THEN 'Animal'

                WHEN c.crash_type = '13'
                    THEN 'Pedestrian'

                WHEN c.crash_type = '14'
                    THEN 'Pedalcyclist'

                WHEN c.crash_type = '15'
                    THEN 'Non-Fixed Object'

                WHEN c.crash_type = '16'
                    THEN 'Railcar - Vehicle'

                WHEN c.crash_type = '99'
                    THEN 'Other'

                ELSE 'Other'
            END
        ),

        /*
         * MAX SEVERITY LEVEL
         */

        (
            'max_severity_level',
            c.max_severity_level
        ),

        /*
         * ROAD CONDITION
         */

        (
            'road_condition',

            CASE
                WHEN c.road_surface_condition = '00'
                     OR c.road_surface_condition IS NULL
                    THEN 'Unknown'

                WHEN c.road_surface_condition = '01'
                    THEN 'Dry'

                WHEN c.road_surface_condition = '02'
                    THEN 'Wet'

                WHEN c.road_surface_condition = '03'
                    THEN 'Snow'

                WHEN c.road_surface_condition = '04'
                    THEN 'Icy'

                WHEN c.road_surface_condition IN
                    ('05','06','07','08','09','99')
                    THEN 'Other'

                ELSE 'Other'
            END
        ),

        /*
         * WEATHER
         */

        (
            'weather',

            CASE
                WHEN c.environmental_condition = '00'
                     OR c.environmental_condition IS NULL
                    THEN 'Unknown'

                WHEN c.environmental_condition = '01'
                    THEN 'Clear'

                WHEN c.environmental_condition = '02'
                    THEN 'Rain'

                WHEN c.environmental_condition = '03'
                    THEN 'Snow'

                WHEN c.environmental_condition IN
                    ('04','05','06','07','08','09','10','99')
                    THEN 'Other'

                ELSE 'Other'
            END
        ),

        /*
         * ILLUMINATION
         */

        (
            'illumination',

            CASE
                WHEN c.light_condition = '00'
                     OR c.light_condition IS NULL
                    THEN 'Unknown'

                WHEN c.light_condition = '01'
                    THEN 'Daylight'

                WHEN c.light_condition = '02'
                    THEN 'Dawn'

                WHEN c.light_condition = '03'
                    THEN 'Dusk'

                WHEN c.light_condition = '04'
                    THEN 'Dark (street lights off)'

                WHEN c.light_condition = '05'
                    THEN 'Dark (no street lights)'

                WHEN c.light_condition = '06'
                    THEN 'Dark (streetlights on, continuous)'

                WHEN c.light_condition = '07'
                    THEN 'Dark (streetlights on, spot)'

                WHEN c.light_condition = '99'
                    THEN 'Other'

                ELSE 'Other'
            END
        ),

        /*
         * MONTH
         */

        (
            'month',
            TO_CHAR(c."date", 'FMMonth')
        ),

        /*
         * DAY OF WEEK
         */

        (
            'day_of_week',

            CASE c.day_of_week
                WHEN 'MO' THEN 'Monday'
                WHEN 'TU' THEN 'Tuesday'
                WHEN 'WE' THEN 'Wednesday'
                WHEN 'TH' THEN 'Thursday'
                WHEN 'FR' THEN 'Friday'
                WHEN 'SA' THEN 'Saturday'
                WHEN 'SU' THEN 'Sunday'
                ELSE NULL
            END
        ),

        /*
         * HOUR
         */

        (
            'hour',
            LEFT(c.time_of_day, 2)
        )

) x(domain, category)


/*
 * =========================================================
 * PERSON INJURY
 * =========================================================
 */

UNION ALL

SELECT
    p.casenumber,
    p.crash_year,
    p.municipality,
    p.county,
    p.domain,
    p.category,
    p.max_severity_level,
    p.pedestrian_event,
    p.bike_event,
    p.cnt

FROM persons p


/*
 * =========================================================
 * VEHICLE
 * =========================================================
 */

UNION ALL

SELECT
    v.casenumber,
    v.crash_year,
    v.municipality,
    v.county,
    v.domain,
    v.category,
    v.max_severity_level,
    v.pedestrian_event,
    v.bike_event,
    v.cnt

FROM vehicles v
;