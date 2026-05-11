with domain_total as (
select
	"domain",
	sum(cnt) as domain_total
from
	nj_report.report_summary_long
group by
	"domain"),
report as (
select
	"domain",
	category,
	sum(cnt) as total
from
	nj_report.report_summary_long
group by
	"domain",
	category)


select
		r.*,
		round(r.total / d.domain_total,
		3) as pct
from
		report r
inner join domain_total d on
		r."domain" = d."domain"
group by r."domain", r.category, r.total, d.domain_total;