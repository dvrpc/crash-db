drop materialized view if exists pa_report.report_summary_long;
create materialized view pa_report.report_summary_long as 
WITH counties AS (

    /*
     * One row per crash with municipality and county.
     */

    SELECT
        c.crn,

        INITCAP(
            CASE c.county
                WHEN '09' THEN 'Bucks'
                WHEN '15' THEN 'Chester'
                WHEN '23' THEN 'Delaware'
                WHEN '46' THEN 'Montgomery'
                WHEN '67' THEN 'Philadelphia'
                ELSE NULL
            END
        ) AS county,

        l.description AS municipality

    FROM pa.all_crash c

    LEFT JOIN pa_lookup.municipalities l
        ON c.municipality = l.code

),


crashes AS (

    /*
     * One row per crash.
     */

    SELECT
        c.crn,
        c.crash_year,
        cnt.municipality,
        cnt.county,
        case 
        	when c.bicycle_count > 0 
        	then true else false
        end as bicycle,
        case 
        	when c.ped_count > 0 
        	then true else false
        end as pedestrian,
        c.max_severity_level,
        c.collision_type,
        c.road_condition,
        c.weather1,
        c.illumination,
        c.crash_month,
        c.day_of_week,
        c.hour_of_day

    FROM pa.all_crash c

    LEFT JOIN counties cnt
        ON c.crn = cnt.crn

),


persons AS (

    /*
     * One row per crash/person injury category.
     * cnt = number of people.
     */

    SELECT
        p.crn,
        c.crash_year,
        c.municipality,
        c.county,

        CASE
            WHEN p.inj_severity = '0'
                THEN 'Property Damage Only'
            WHEN p.inj_severity = '1'
                THEN 'Fatal'
            WHEN p.inj_severity = '2'
                THEN 'Suspected Serious Injury'
            WHEN p.inj_severity = '3'
                THEN 'Suspected Minor Injury'
            WHEN p.inj_severity = '4'
                THEN 'Possible Injury'
            when p.inj_severity = '8'
            	then 'Injury - Unknown Severity'
            WHEN p.inj_severity = '9'
                 OR p.inj_severity IS NULL
                THEN 'Other/Unknown'
            ELSE 'Other/Unknown'
        END AS category,

        COUNT(*) AS cnt

    FROM pa.all_person p

    INNER JOIN crashes c
        ON p.crn = c.crn

    GROUP BY
        p.crn,
        c.crash_year,
        c.municipality,
        c.county,

        CASE
            WHEN p.inj_severity = '0'
                THEN 'Property Damage Only'
            WHEN p.inj_severity = '1'
                THEN 'Fatal'
            WHEN p.inj_severity = '2'
                THEN 'Suspected Serious Injury'
            WHEN p.inj_severity = '3'
                THEN 'Suspected Minor Injury'
            WHEN p.inj_severity = '4'
                THEN 'Possible Injury'
            WHEN p.inj_severity = '8'
            	then 'Injury - Unknown Severity'
            when p.inj_severity = '9' or p.inj_severity IS NULL
                THEN 'Other/Unknown'
            ELSE 'Other/Unknown'
        END

),


vehicle_categories AS (

    /*
     * Assign one reporting category to each vehicle.
     */

    SELECT
        v.crn,

        CASE
            WHEN v.veh_type = '01'
                THEN 'Automobile'

            WHEN v.veh_type = '02'
                THEN 'Motorcycle'

            WHEN v.veh_type = '03'
                THEN 'Bus'

            WHEN v.veh_type = '04'
                THEN 'Small Truck'

            WHEN v.veh_type = '05'
                THEN 'Large Truck'

            WHEN v.veh_type IN
                ('06','07','08','09','10','11','12',
                 '13','14','15','16','17','18','19')
                THEN 'Other Motor'

            WHEN v.veh_type = '20'
                THEN 'Bicycle'

            WHEN v.veh_type = '31'
                THEN 'Pedestrian'

            WHEN v.veh_type IN
                ('21','22','23','24','25','32','33',
                 '34','35','36','98')
                THEN 'Other Nonmotor'

            WHEN v.veh_type = '99'
                 OR v.veh_type IS NULL
                THEN 'Other/Unknown'

            ELSE 'Other/Unknown'
        END AS category

    FROM pa.all_vehicle v

),


vehicles AS (

    /*
     * One row per crash/vehicle category.
     * cnt = number of vehicles.
     */

    SELECT
        v.crn,
        c.crash_year,
        c.municipality,
        c.county,
        v.category,

        COUNT(*) AS cnt

    FROM vehicle_categories v

    INNER JOIN crashes c
        ON v.crn = c.crn

    GROUP BY
        v.crn,
        c.crash_year,
        c.municipality,
        c.county,
        v.category

)


/*
 * =========================================================
 * CRASH-LEVEL DOMAINS
 * =========================================================
 */

SELECT
    'event' as resolution,
    c.crn,
    c.crash_year,
    c.municipality,
    c.county,
    c.bicycle,
    c.pedestrian,
    x.domain,
    x.category,
    1 AS cnt

FROM crashes c

CROSS JOIN LATERAL (

    VALUES

        /*
         * MAX SEVERITY
         */

        (
            'max_severity_level',
            CASE c.max_severity_level
                WHEN '0' THEN 'Property Damage Only'
                WHEN '1' THEN 'Fatal'
                WHEN '2' THEN 'Suspected Serious Injury'
                WHEN '3' THEN 'Suspected Minor Injury'
                WHEN '4' THEN 'Possible Injury'
                WHEN '8' THEN 'Injury - Unknown Severity'
                WHEN '9' THEN 'Other/Unknown'
                ELSE 'Other/Unknown'
            END
        ),


        /*
         * COLLISION TYPE
         */

        (
            'collision_type',
            CASE
                WHEN c.collision_type = '0'
                    THEN 'Noncollision'

                WHEN c.collision_type = '1'
                    THEN 'Rearend'

                WHEN c.collision_type = '2'
                    THEN 'Headon'

                WHEN c.collision_type = '3'
                    THEN 'Backing'

                WHEN c.collision_type = '4'
                    THEN 'Angle'

                WHEN c.collision_type = '5'
                    THEN 'Sideswipe (same dir.)'

                WHEN c.collision_type = '6'
                    THEN 'Sideswipe (Opposite dir.)'

                WHEN c.collision_type = '7'
                    THEN 'Hit Fixed Object'

                WHEN c.collision_type = '8'
                    THEN 'Hit Non-Motorist'

                WHEN c.collision_type IN ('9','98','99') or c.collision_type is null
                    THEN 'Other/Unknown'

                ELSE 'Other/Unknown'
            END
        ),


        /*
         * ROAD CONDITION
         */

        (
            'road_condition',
            CASE
                WHEN c.road_condition = '01'
                    THEN 'Dry'

                WHEN c.road_condition = '02'
                    THEN 'Ice'

                WHEN c.road_condition = '07'
                    THEN 'Snow'

                WHEN c.road_condition = '08'
                    THEN 'Water'

                WHEN c.road_condition = '09'
                    THEN 'Wet'

                WHEN c.road_condition IN
                    ('03','04','05','06','22','98')
                    THEN 'Other'

                WHEN c.road_condition = '99'
                     OR c.road_condition IS NULL
                    THEN 'Unknown'

                ELSE 'Unknown'
            END
        ),


        /*
         * WEATHER
         */

        (
            'weather',
            CASE
                WHEN c.weather1 = '03'
                    THEN 'Clear'

                WHEN c.weather1 = '04'
                    THEN 'Cloudy'

                WHEN c.weather1 = '05'
                    THEN 'Fog/Smog/Smoke'

                WHEN c.weather1 = '07'
                    THEN 'Rain'

                WHEN c.weather1 = '10'
                    THEN 'Snow'

                WHEN c.weather1 IN
                    ('01','02','06','08','09','98')
                    THEN 'Other'

                WHEN c.weather1 = '99'
                     OR c.weather1 IS NULL
                    THEN 'Unknown'

                ELSE 'Unknown'
            END
        ),


        /*
         * ILLUMINATION
         */

        (
            'illumination',
            CASE
                WHEN c.illumination = '1'
                    THEN 'Daylight'

                WHEN c.illumination = '2'
                    THEN 'Dark - no streetlights'

                WHEN c.illumination = '3'
                    THEN 'Dark - streetlights'

                WHEN c.illumination = '4'
                    THEN 'Dusk'
                   
                WHEN c.illumination = '5'
                    THEN 'Dawn'

                WHEN c.illumination IN ('6','8','9')
                     OR c.illumination IS NULL
                    THEN 'Other/Unknown'

                ELSE 'Other/Unknown'
            END
        ),


        /*
         * MONTH
         */

        (
            'month',
            CASE c.crash_month
                WHEN '01' THEN 'January'
                WHEN '02' THEN 'February'
                WHEN '03' THEN 'March'
                WHEN '04' THEN 'April'
                WHEN '05' THEN 'May'
                WHEN '06' THEN 'June'
                WHEN '07' THEN 'July'
                WHEN '08' THEN 'August'
                WHEN '09' THEN 'September'
                WHEN '10' THEN 'October'
                WHEN '11' THEN 'November'
                WHEN '12' THEN 'December'
                ELSE 'Unknown'
            END
        ),


        /*
         * DAY OF WEEK
         */

        (
            'day_of_week',
            CASE c.day_of_week
                WHEN '1' THEN 'Sunday'
                WHEN '2' THEN 'Monday'
                WHEN '3' THEN 'Tuesday'
                WHEN '4' THEN 'Wednesday'
                WHEN '5' THEN 'Thursday'
                WHEN '6' THEN 'Friday'
                WHEN '7' THEN 'Saturday'
                ELSE 'Unknown'
            END
        ),


        /*
         * HOUR
         */

        (
            'hour',
            c.hour_of_day
        )

) x(domain, category)


UNION ALL


/*
 * =========================================================
 * PERSON INJURY
 * =========================================================
 */

SELECT
    'person' as resolution,
    p.crn,
    p.crash_year,
    p.municipality,
    p.county,
    null as bicycle,
    null as pedestrian,
    'person_injury' AS domain,
    p.category,
    p.cnt

FROM persons p


UNION ALL


/*
 * =========================================================
 * VEHICLE
 * =========================================================
 */

SELECT
    'vehicle' as resolution,
    v.crn,
    v.crash_year,
    v.municipality,
    v.county,
    null as bicycle,
    null as pedestrian,
    'vehicle' AS domain,
    v.category,
    v.cnt

FROM vehicles v
;