----------------------------------------------------------------------------------------------------------------------------------

-- 4. ZADÁNÍ
-- Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

-- POSTUP:
-- a) Spojení tabulek czechia_price/czechia_price_category do jednoho view.
-- b) Vytvoření sloupců ceny v aktuálním a předchozím roce v jedné tabulce.
create view v_ceny_zbozi_tento_minuly_rok as 
select 
	date_part('year', cp.date_from) as rok,
	category_code as kod_zbozi,
	name as nazev_zbozi, 
	round(avg(value)::numeric, 2) as cena_aktu_rok,
	lag(round(avg(cp.value)::numeric, 2)) over (
		partition by cp.category_code order by date_part('year', cp.date_from)
	) as cena_minuly_rok
from czechia_price cp
left join czechia_price_category cpc
	on cp.category_code = cpc.code
group by rok, kod_zbozi, nazev_zbozi
order by kod_zbozi asc, rok asc;

-- c) Výpočet procentuální změny všech položek v jednom roce.
create view v_pct_zmena_cen_zbozi as
select
    rok,
    round(avg(cena_aktu_rok)::numeric, 2) AS prumerna_cena_tento_rok,
    lag(round(avg(cena_aktu_rok)::numeric, 2)) over (
        order by rok
    ) as prumerna_cena_minuly_rok,
    round(
        case 
            when lag(avg(cena_aktu_rok)) over (order by rok) is not null 
            then ((avg(cena_aktu_rok) - lag(avg(cena_aktu_rok)) over (order by rok)) / 
                  lag(avg(cena_aktu_rok)) over (order by rok)) * 100
            else null
        end, 2
    ) as pct_zmena_cen
from v_ceny_zbozi_tento_minuly_rok
group by rok
order by rok;

-- d) Vytvoření view s rokem výplaty, výplatou daný rok a výplatou rok předchozí.
create view v_vyplaty_tento_minuly_rok as
select 
    payroll_year as rok_vyplaty,
    round(avg(value)::numeric, 2) as vyplata,
    lag(round(avg(value)::numeric, 2)) over (
        order by payroll_year
    ) as vyplata_predchozi_rok
from czechia_payroll
where value_type_code = 5958 
    and value is not null
    and payroll_year between 2006 and 2018
group by payroll_year
order by payroll_year;

-- e) Vytvoření view a výpočet procentuální změny výplaty.
create view v_pct_zmena_vyplat as
select *,
	round(((vyplata / vyplata_predchozi_rok *100) - 100), 2) as pct_zmena_platu
from v_vyplaty_tento_minuly_rok;

-- f) Spojení tabulek a porovnání hodnot.
create view v_zaver as 
select pctzbz.rok, 
	pctzbz.pct_zmena_cen, 
	pctvpt.pct_zmena_platu,
	pctzbz.pct_zmena_cen - pctvpt.pct_zmena_platu as rozdil,
	case
		when pct_zmena_cen > pct_zmena_platu then 'zboží'
		when pct_zmena_cen < pct_zmena_platu then 'platy'
	end as co_rostlo_vice
from v_pct_zmena_vyplat as pctvpt
join v_pct_zmena_cen_zbozi as pctzbz
	on pctvpt.rok_vyplaty = pctzbz.rok
where rok <> 2006;

-- g) Dodatečný výpočet pro závěřečnou odpověď.
select sum(pct_zmena_cen) as suma_pct_zmen_cen, 
 		sum(pct_zmena_platu) as suma_pct_zmen_platu
from v_zaver;

-- h) Úklid.
drop view v_ceny_zbozi_tento_minuly_rok;
drop view v_pct_zmena_cen_zbozi;
drop view v_vyplaty_tento_minuly_rok;
drop view v_pct_zmena_vyplat;
drop view v_zaver;

-- 4. ZÁVĚR
--   a) V dostupných datech neexistuje rok, kde by meziroční nárůst cen potravin byl vyšší než meziroční růst mezd. 
--   b) Výraznější rozdíly přinesl rok 2009, kde došlo k vyššímu poklesu cen potravin a průměrnému růstu mezd.
--   c) Ojedinělý případ, kdy je absolutní rozdíl mezi růstem platů a cen zboží je rok 2013. Zde došlo k poklesu platů a běžnému růstu cen.
--      Obecně lze hovořit o výjimce, protože za celé dostupné období platy narostly o 46.45%, kdežto mzdy o 34.46%. 
--   d) V žádném z případů nedošlo k růstu cen/mez vyššímu než 10%. Nejblíže této hodnotě byl tok 2017, kde byl ale i růst platů vysoký a rozdíl je pouze +3.32%.

----------------------------------------------------------------------------------------------------------------------------------