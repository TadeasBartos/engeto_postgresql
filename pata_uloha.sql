----------------------------------------------------------------------------------------------------------------------------------

-- 5. ZADÁNÍ
-- Má výška HDP vliv na změny ve mzdách a cenách potravin? 
-- Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

-- POSTUP PŘÍPRAVY (TOTOŽNÝ S 4. ÚLOHOU):
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

-- POSTUP:
-- a) Vytažení dat z tabulky economics pro region euro zóny. 
-- b) Výpočet pct_zmeny HDP.
-- c) Připojení tabulky z v_zaver a uložení jako view.
create view v_hdp_ceny_platy as
select 
	year,
    round(
        case 
            when lag(gdp) over (order by year) is not null 
            then ((gdp - lag(gdp) over (order by year)) / lag(gdp) over (order by year)) * 100 
            else null 
        end::numeric, 2
    ) as pct_zmena_hdp,
	pct_zmena_cen,
	pct_zmena_platu
from economies
join v_zaver
	on economies.year = v_zaver.rok
where country = 'Euro area'
order by year;

-- METRIKY:
-- d) Korelace HDP a cen zbozi	
-- e) Korelace HDP a platu
create view v_korelace as
select
	corr(pct_zmena_hdp, pct_zmena_cen) as hdp_ceny_korelace, 
	corr(pct_zmena_hdp, pct_zmena_platu) as hdp_platy_korelace
from v_hdp_ceny_platy;
-- +1: silná přímá vazba (roste HDP i platy)
-- -1: silná nepřímá vazba (roste HDP, klesají platy)
-- 0: žádná vazba

-- f) Počet let kdy rostlo HDP a klesaly mzdy:
select count(*) as pocet_let_rustu_hdp_poklesu_mezd
from v_hdp_ceny_platy
where pct_zmena_hdp > 0 and pct_zmena_platu < 0;
-- 0: mzdy rostou společně s HDP, dobrá zpráva
-- jiné: mzdy nekorelují s růstem země, špatná zpráva

-- g) Úklid.
drop view v_ceny_zbozi_tento_minuly_rok;
drop view v_pct_zmena_cen_zbozi;
drop view v_vyplaty_tento_minuly_rok;
drop view v_pct_zmena_vyplat;
drop view v_zaver;
drop view v_hdp_ceny_platy;
drop view v_korelace;

-- ZÁVĚR:
-- Tabulka v_hdp_ceny_platy:
-- Většinou platí, že růst HDP vede k růstu cen i mezd, ale existují výjimky, kde jiné faktory ovlivnily inflaci a mzdy (např. globální krize, změny daní, specifická ekonomická politika).
-- Tabulka v_korelace:
-- Hodnota korelace HDP/ceny 0.43 označuje slabší korelaci - vztah je pozitivní, při růstu HDP lze předpokládat i růst cen.
-- Hodnota korelace HDP/mzdy 0.19 označuje velmi slabý pozitivní vztah - mezi těmito dvěma veličinami není silná vazba a jejich souvislost může být náhodná nebo ovlivněná jinými faktory.
-- Dle kapitoly f), která počítala roky, kdy rostlo HDP a mzdy nikoliv, lze říct že pokud rostlo HPD, tak rostly i mzdy. Což je dobrá zpráva.
-- Pro úplny kontext by bylo důležité porovnání s hodnotami na trhu práce, úrokové sazby a jiné.

----------------------------------------------------------------------------------------------------------------------------------

