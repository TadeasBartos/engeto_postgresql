----------------------------------------------------------------------------------------------------------------------------------

-- 2. ZADÁNÍ
-- Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

-- POSTUP:
-- a) Nalezení ceny maximální ceny chleba a mléka v letech 2017+2018, vytvoření tabulky.
create view v_tadeas_bartos_max_cena as
select
	cp.category_code,
	cpc.name,
    MAX(value) AS max_cena,
    date_part('year', date_from) as year
from czechia_price cp
join czechia_price_category cpc 
    on cp.category_code = cpc.code
where date_part('year', date_from) in (2017, 2018)
 and cpc.code in ('111301', '114201')
group by cp.category_code, cpc.name, year;

-- b) Nalezení roku, názvu odvětví a průměrné mzdy v letech 2017+2018.
create view v_tadeas_bartos_mzdy_20172018 as 
select 
	payroll_year as rok,  
	name as jmeno_odvetvi, 
	avg(value) as prumerna_mzda
from czechia_payroll cp
join czechia_payroll_industry_branch cpib 
	on cp.industry_branch_code = cpib.code
where payroll_year in ('2017', '2018')
and value_type_code = '5958'
and value is not null
group by payroll_year, cpib.name
order by payroll_year, cpib.name;

-- c) Spojení tabulek, výpočet možných artiklů za měsíc.
create table t_tadeas_bartos__project_SQL_primary_final as
select 
	rok, 
	jmeno_odvetvi,
	prumerna_mzda, 
	name as jmeno,
	max_cena,
	floor(prumerna_mzda / max_cena) as pocet_celych_artiklu_za_mesic
from v_tadeas_bartos_max_cena as tb_prac_ceny
join v_tadeas_bartos_mzdy_20172018 as tb_prac_mzdy
	on tb_prac_ceny.year = tb_prac_mzdy.rok
order by rok, jmeno_odvetvi, prumerna_mzda;

-- d) Výstupní tabulka.
select *
from t_tadeas_bartos__project_SQL_primary_final;

-- e) Úklid.
drop view v_tadeas_bartos_max_cena;
drop view v_tadeas_bartos_mzdy_20172018;
drop table if exists t_tadeas_bartos__project_SQL_primary_final;

----------------------------------------------------------------------------------------------------------------------------------