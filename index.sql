with t_date as -- Создаёт таблицу с данными
	(select
		day::date
	from
		generate_series('2019-01-01 00:00'::timestamp,
		'2019-10-31 00:00','1 day') day),
t_comments as
	(select
		d.date::date as day,
		sum(d.comments) filter(where c.id = 11) hash,
		sum(d.comments) filter(where c.id = 12) weed,
		sum(d.comments) filter(where c.id = 15) amph,
		sum(d.comments) filter(where c.id in (19,84,85)) meph,
		sum(d.comments) filter(where c.id in (18,83,82)) alpha,
		sum(d.comments) filter(where c.id = 14) cocs
	from
		main_daydata d
			join main_product p on d.product_id = p.id
			join main_category c on p.category_id = c.id
			join main_region r on d.region_id = r.id
	where
		extract(year from d.date) = '2019'
		and extract(month from d.date) != '11'
		and d.region_id = 2
	group by 1
	order by 1),
t_comments_day as
	(select
		d1.day,
		round(coalesce(nullif(c1.hash,0), avg(hash) over wnd_1)) hash,
		round(coalesce(nullif(c1.weed,0), avg(weed) over wnd_1)) weed,
		round(coalesce(nullif(c1.amph,0), avg(amph) over wnd_1)) amph,
		round(coalesce(nullif(c1.meph,0), avg(meph) over wnd_1)) meph,
		round(coalesce(nullif(c1.alpha,0), avg(alpha) over wnd_1)) alpha,
		round(coalesce(nullif(c1.cocs,0), avg(cocs) over wnd_1)) cocs
	from
		t_date d1
			left join t_comments c1 on d1.day = c1.day
	window
		wnd_1 as (partition by extract(month from d1.day))
	order by 1),
t_comments_month as
	(select
		extract(month from cd.day)::integer mnth,
		sum(hash) hash,
		sum(weed) weed,
		sum(amph) amph,
		sum(meph) meph,
		sum(alpha) alpha,
		sum(cocs) cocs
	from
		t_comments_day cd
	group by 1
	order by 1)
select
	cm.mnth,
	round(hash/first_value(hash) over wnd_2 * 100)||'%' hash,
	round(weed/first_value(weed) over wnd_2 * 100)||'%' weed,
	round(amph/first_value(amph) over wnd_2 * 100)||'%' amph,
	round(meph/first_value(meph) over wnd_2 * 100)||'%' meph,
	round(alpha/first_value(alpha) over wnd_2 * 100)||'%' alpha,
	round(cocs/first_value(cocs) over wnd_2 * 100)||'%' cocs
from
	t_comments_month cm
window
	wnd_2 as (order by cm.mnth)
