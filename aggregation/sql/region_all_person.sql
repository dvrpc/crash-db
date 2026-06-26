--drop materialized view if exists region.all_person;
--create materialized view region.all_person as 

select
	p.casenumber as crn,
	c."year" as crash_year,
	initcap(county),
	veh_num::int,
	case 
		when physical_condition in ('00', '99') then 'other or unknown'
		when physical_condition = '01' then 'fatal'
		when physical_condition = '02' then 'suspected serious injury'
		when physical_condition = '03' then 'suspected minor injury'
		when physical_condition = '04' then 'possible injury'
		when physical_condition = '05' then 'no apparent injury'
	end
	
from
	nj.all_person p
left join nj.all_crash c 
on
	p.casenumber = c.casenumber
union all 

select
	p.crn::text,
	c.crash_year,
	case
		when c.county = '09' then 'Bucks'
		when c.county = '15' then 'Chester'
		when c.county = '23' then 'Delaware'
		when c.county = '46' then 'Montgomery'
		when c.county = '67' then 'Philadelphia'
		else null
	end as county,
	unit_num as veh_num,
	case 
		when inj_severity = '1' then 'fatal'
		when inj_severity = '2' then 'suspected serious injury'
		when inj_severity = '3' then 'suspected minor injury'
		when inj_severity = '4' then 'possible injury'
		when inj_severity = '0' then 'no apparent injury'
		when inj_severity in ('8', '9') then 'other or unknown'
	end as
	inj_severity
from
	pa.all_person p
left join pa.all_crash c  
on
	p.crn = c.crn
