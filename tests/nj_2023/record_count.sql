select 'crash' as "table", count(*) as total_records, count(distinct(casenumber)) as total_events from nj.crash 

union all 

select 'person', count(*) as total_records, count(distinct(casenumber)) as total_events from nj.person

union all 

select 'driver', count(*) as total_records, count(distinct(casenumber)) as total_events from nj.driver

union all 

select 'vehicle', count(*) as total_records, count(distinct(casenumber)) as total_events from nj.vehicle

union all 

select 'occupant', count(*) as total_records, count(distinct(casenumber)) as total_events from nj.occupant

union all 

select 'pedestrian', count(*) as total_records, count(distinct(casenumber)) as total_events from nj.pedestrian