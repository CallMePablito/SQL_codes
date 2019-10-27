with all_drugs_full as
	(select
		region, shop_id, product_id,
		type1, type2, subregion, product_name,
	 	case
	 		when category in ('Мефедрон','Кристаллическая пудра') then 'Мефедрон'
	 		when category in ('Кристалл','Мука') and
	 			(product_name ilike '%меф%' or product_name ilike '%meph%' or product_name ilike '%мяу%' or product_name ilike '%mef%' or product_name ilike '%мука%')
	 			then 'Мефедрон'
	 		when category in ('Альфа-ПВП ') then 'Альфа-ПВП'
			when category in ('Кристалл','Мука') and
	 			(product_name ilike '%пвп%' or product_name ilike '%pvp%' or product_name ilike '%ск%' or product_name ilike '%альфа%' or product_name ilike '%alpha%'  or product_name ilike 'кристаллы из китая. ')
	 			then 'Альфа-ПВП'
	 		when category in ('Кристалл','Мука') and not
	 			(product_name ilike '%пвп%' or product_name ilike '%pvp%' or product_name ilike '%ск%' or product_name ilike '%альфа%' or product_name ilike '%alpha%' or product_name ilike '%мука%'
				or product_name ilike '%меф%' or product_name ilike '%meph%' or product_name ilike '%мяу%'  or product_name ilike '%mef%' or product_name ilike 'кристаллы из китая. ')
	 			then 'Соли'
	 		else category
	 	end category,
		case
			when amount like '%г%' then 'Gr'
			when amount like '%мг%' then 'Mg'
			when amount like '%шт%' then 'Un'
			when amount like '%мл%' then 'Ml'
		end amount_type,
	 	case
	 		when amount like '% г%' then replace(amount, ' г','')
	 		when amount like '% мг%' then replace(amount, ' мг','')
	 		when amount like '%шт' then replace(amount, ' шт','')
	 		when amount like '%мл' then replace(amount, ' мл','')
	 	end::float amount,
	 	case
	 		when price like '%руб%' then replace(replace(price, ' руб', ''), ' ', '')::float
	 		when price like '%$%' then replace(replace(price, ' $', ''), ' ', '')::float*64
	 	end price
from public.all_drugs
where type1 = 'Моментальный')
select *
from all_drugs_full

