----------------------------------------------------------------------------------------------------------------------------------

-- 1. ZADÁNÍ
-- Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

-- POSTUP:
-- a) Zobrazení kódu odvětví, výplatního roku, průměru z hodnoty průměrných mezd. 
-- b) Vytvoření nového sloupce, který počítá rozdíl průměru mezd roku y s rokem y-1. Následně uloží hodnotu ROSTE/KLESÁ.
create view v_tadeas_bartos_project_SQL_prvni_uloha AS
select 
	cp1.industry_branch_code as kod_odvetvi, 
	cp1.payroll_year as rok,
	avg(cp1.value) as prumer_prumernych_mezd,
	case
		when avg(cp1.value) > avg(cp2.value) then 'ROSTE'
		when avg(cp1.value) < avg(cp2.value) then 'KLESÁ'
		else 'NEROSTE'
	end as TREND
from czechia_payroll cp1
left join czechia_payroll cp2 
	on cp1.industry_branch_code = cp2.industry_branch_code
	and cp1.payroll_year = cp2.payroll_year + 1
where cp1.value_type_code = 5958
	and cp1.payroll_year between 2001 and 2021
group by cp1.industry_branch_code, cp1.payroll_year
order by kod_odvetvi, rok;

-- c) Zobrazíme celý nově vytvořený view.
select *
from v_tadeas_bartos_project_SQL_prvni_uloha;

-- d) Vybereme všechny odvětví a roky kdy mzdy rostou.
select *
from v_tadeas_bartos_project_SQL_prvni_uloha
where TREND = 'ROSTE'
order by ROK; 

-- e) Vybereme všechny odvětví a roky kdy mzdy klesají.
select *
from v_tadeas_bartos_project_SQL_prvni_uloha
where TREND = 'KLESÁ'
order by ROK;

-- f) Vymazání view: 
drop view v_tadeas_bartos_project_SQL_prvni_uloha;

-- 1. ZÁVĚR
-- Na základě srovnání mezd z předchozích let lze říct, že až na pár výjimek (14 záznamů ze 420) mzdy meziročně rostou.

----------------------------------------------------------------------------------------------------------------------------------
