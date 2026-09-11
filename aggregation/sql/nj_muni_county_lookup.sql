drop materialized view if exists nj_report.muni_county_lookup;
create materialized view nj_report.muni_county_lookup as 

select
	distinct initcap(municipality) as municipality,
	initcap(county) as county
from
	nj.all_crash
order by
	initcap(county),
	initcap(municipality);