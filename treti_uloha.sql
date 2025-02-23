----------------------------------------------------------------------------------------------------------------------------------

-- 3. ZADÁNÍ
-- Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

-- POSTUP:
-- a) Pomocí left join připojím tabulku czechia_price do czechia_price_category.
-- b) Pomocí LAG() uložím cenu z předchozího roku do nového sloupce.
create view v_tadeas_bartos_SQL_treti_uloha as
select
    cpc.code as kod_zbozi, 
    cpc.name as nazev, 
    date_part('year', cp.date_from) as rok,
    round(avg(cp.value)::numeric, 2) as prumerna_cena,
    lag(round(avg(cp.value)::numeric, 2)) over (
        partition by cpc.code order by date_part('year', cp.date_from)
    ) as prumerna_cena_minuly_rok
from czechia_price_category cpc
left join czechia_price cp 
    on cpc.code = cp.category_code
GROUP BY cpc.code, cpc.name, DATE_PART('year', cp.date_from)
ORDER BY cpc.code, rok ASC;

-- c) V tomto view spočítám procentuální rok mezi roky.
create view v_zmena_ceny as
select nazev,
	rok,
	prumerna_cena,
	prumerna_cena_minuly_rok,
	avg((tbtu.prumerna_cena / prumerna_cena_minuly_rok * 100)-100) as zmena_ceny_pct
from v_tadeas_bartos_SQL_treti_uloha as tbtu
where prumerna_cena_minuly_rok is not null
group by tbtu.nazev, tbtu.rok, tbtu.prumerna_cena, tbtu.prumerna_cena_minuly_rok
order by rok asc;

-- d) V tomto view spočítám průměrnou hodnotu změny ceny, zároveň odfiltruju položky které zlevňovaly a zobrazím pouze první položku.
create view v_polozka as
select 
	vzc.nazev,
	vzc.prumerna_cena,
	vzc.prumerna_cena_minuly_rok,
	round(avg(vzc.zmena_ceny_pct)::numeric, 2) as prumerna_zmena_ceny_pct
from v_zmena_ceny vzc
where vzc.zmena_ceny_pct > 0
group by vzc.nazev, vzc.prumerna_cena, vzc.prumerna_cena_minuly_rok
order by prumerna_zmena_ceny_pct asc
limit 1; 

-- e) Ukážu výsledek.
select *
from v_polozka;

-- f) Úklid.
drop view v_tadeas_bartos_SQL_treti_uloha;
drop view v_zmena_ceny;
drop view v_polozka;

----------------------------------------------------------------------------------------------------------------------------------