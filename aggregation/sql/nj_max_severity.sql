--create materialized view nj_report.max_severity_level as  
with severity_calc as (
select
	p.casenumber,
	c."year" as crash_year,
	case
		MIN(
        case nullif(TRIM(p.physical_condition), '')
            when '01' then 1
            when '02' then 2
            when '03' then 3
            when '04' then 4
            when '05' then 5
            when '00' then 6
            when '99' then 6
            else null
        end
    )
		when 1 then '1'
		when 2 then '2'
		when 3 then '3'
		when 4 then '4'
		when 5 then '9'
		when 6 then '0'
		else null
	end as max_severity_calc,
	initcap(county)
from
	nj.all_person p
left join nj.all_crash c on
	p.casenumber = c.casenumber
group by
	p.casenumber,
	"year",
	initcap(county)
), 
max_severity as (
select
	casenumber,
	case 
		when max_severity_calc = '1' then 'fatal'
		when max_severity_calc = '2' then 'suspected serious injury'
		when max_severity_calc = '3' then 'suspected minor injury'
		when max_severity_calc = '4' then 'possible injury'
		when max_severity_calc = '9' then 'no apparent injury'
		when max_severity_calc = '0' then 'other or unknown'
		else null
	end as max_severity_level
from
	severity_calc)
	
select * from max_severity