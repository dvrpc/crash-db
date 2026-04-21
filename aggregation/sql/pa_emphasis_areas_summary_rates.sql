WITH flag_base AS (
      SELECT 
        c.crn,
		bool_or(case when "intersection" is true then true else false end) as "intersection",
		bool_or(case when lane_departure is true then true else false end) as lane_departure,
		bool_or(case when bicycle is true then true else false end) as bicycle,
		bool_or(case when pedestrian is true then true else false end) as pedestrian,
		bool_or(case when distracted is true then true else false end) as distracted,
		bool_or(case when aggressive_driving is true then true else false end) as aggressive_driving,
		bool_or(case when impaired_driver is true then true else false end) as impaired_driver,
		bool_or(case when work_zone is true then true else false end) as work_zone,
		bool_or(case when train_trolley is true then true else false end) as train_trolley,
		bool_or(case when hvy_truck_related is true then true else false end) as hvy_truck_related,
		bool_or(case when motorcycle is true then true else false end) as motorcycle,
		bool_or(case when unbelted is true then true else false end) as unbelted
    FROM pa.all_crash c
    LEFT JOIN pa.all_flags f ON c.crn = f.crn
    group by c.crn
    SELECT 
        c.crn,

        COALESCE(f.intersection, FALSE) AS intersection,
        COALESCE(f.lane_departure, FALSE) AS lane_departure,
        COALESCE(f.bicycle, FALSE) AS bicycle,
        COALESCE(f.pedestrian, FALSE) AS pedestrian,
        COALESCE(f.distracted, FALSE) AS distracted,
        COALESCE(f.aggressive_driving, FALSE) AS aggressive_driving,
        COALESCE(f.impaired_driver, FALSE) AS impaired_driver,
        COALESCE(f.work_zone, FALSE) AS work_zone,
        COALESCE(f.train_trolley, FALSE) AS train_trolley,
        COALESCE(f.hvy_truck_related, FALSE) AS hvy_truck_related,
        COALESCE(f.motorcycle, FALSE) AS motorcycle,
        COALESCE(f.unbelted, FALSE) AS unbelted

    FROM pa.all_crash c
    LEFT JOIN pa.all_flags f ON c.crn = f.crn
),

driver_flags AS (
    SELECT 
        crn,

        MAX(CASE 
            WHEN age >= 65 AND seat_position = '01' THEN 1 ELSE 0 
        END) AS older_road_driver,

        MAX(CASE 
            WHEN age <= 20 AND seat_position = '01' THEN 1 ELSE 0 
        END) AS younger_road_driver

    FROM pa.all_person
    GROUP BY crn
),

crash_flags AS (
    SELECT 
        f.*,
        COALESCE(d.older_road_driver, 0) AS older_road_driver,
        COALESCE(d.younger_road_driver, 0) AS younger_road_driver
    FROM flag_base f
    LEFT JOIN driver_flags d ON f.crn = d.crn
),

ksi_crashes AS (
    SELECT DISTINCT crn
    FROM pa.all_person
    WHERE inj_severity IN ('1','2')
),

person_counts AS (
    SELECT 
        crn,
        COUNT(*) AS total_people,
        SUM(CASE WHEN inj_severity IN ('1','2') THEN 1 ELSE 0 END) AS ksi_people
    FROM pa.all_person
    GROUP BY crn
),

totals AS (
    SELECT 
        COUNT(DISTINCT crn) AS total_crashes
    FROM pa.all_crash
),

emphasis_unpivot AS (
    SELECT crn, 'older_road_driver' as emphasis_area FROM crash_flags WHERE older_road_driver = 1
    UNION ALL
    SELECT crn, 'younger_road_driver' FROM crash_flags WHERE younger_road_driver = 1
    UNION ALL
    SELECT crn, 'intersection' FROM crash_flags WHERE intersection = TRUE
    UNION ALL
    SELECT crn, 'lane_departure' FROM crash_flags WHERE lane_departure = TRUE
    UNION ALL
    SELECT crn, 'bicycle' FROM crash_flags WHERE bicycle = TRUE
    UNION ALL
    SELECT crn, 'pedestrian' FROM crash_flags WHERE pedestrian = TRUE
    UNION ALL
    SELECT crn, 'distracted' FROM crash_flags WHERE distracted = TRUE
    UNION ALL
    SELECT crn, 'aggressive_driving' FROM crash_flags WHERE aggressive_driving = TRUE
    UNION ALL
    SELECT crn, 'impaired_driver' FROM crash_flags WHERE impaired_driver = TRUE
    UNION ALL
    SELECT crn, 'work_zone' FROM crash_flags WHERE work_zone = TRUE
    UNION ALL
    SELECT crn, 'train_trolley' FROM crash_flags WHERE train_trolley = TRUE
    UNION ALL
    SELECT crn, 'hvy_truck_related' FROM crash_flags WHERE hvy_truck_related = TRUE
    UNION ALL
    SELECT crn, 'motorcycle' FROM crash_flags WHERE motorcycle = TRUE
    UNION ALL
    SELECT crn, 'unbelted' FROM crash_flags WHERE unbelted = TRUE
),

final AS (
    SELECT 
        e.emphasis_area,
        COUNT(DISTINCT e.crn) AS total_crash_events,
        COUNT(DISTINCT k.crn) AS total_ksi_events,
        SUM(pc.total_people) AS total_people,
        SUM(pc.ksi_people) AS total_ksi_people
    FROM emphasis_unpivot e
    LEFT JOIN ksi_crashes k ON e.crn = k.crn
    LEFT JOIN person_counts pc ON e.crn = pc.crn
    GROUP BY e.emphasis_area
)

SELECT 
    f.emphasis_area,
    f.total_crash_events,
    round(f.total_crash_events * 1.0 / t.total_crashes, 3) AS pct_crash_events,
    f.total_ksi_events,
    round(f.total_ksi_events * 1.0 / f.total_crash_events, 3) AS pct_ksi_event,
    f.total_people,
    round(f.total_ksi_people * 1.0 / f.total_people, 3) AS pct_ksi_people
FROM final f
CROSS JOIN totals t
ORDER BY f.emphasis_area;