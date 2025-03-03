# PostgreSQL projekt - Engeto Akademie

## Autor
- **Jméno:** Tadeáš Bartoš
- **Email:** bartos.tadeas@live.com
- **GitHub:** @TadeasBartos

## Popis
Tento projekt je soušástí Engeto akademie.
Cílém je zodpovědět na 5 výzkumných dotazů analytického týmu. Jako podkladem je k dispozici několikt datových sad. 
Odpovědi na otázky jsou zodpovězené přímo v SQL skriptu a zde v README. Pokud je výstupem dotazu tabulku, je doplněna pouze o komentář sloupců.

## Datové sady
- **czechia_payroll:** Informace o mzdách za několikaleté období. 
- **czechia_payroll_calculation:** Číselník kalkulací v tabulce mezd.
- **czechia_payroll_industry_branch:** Číselník odvětví v tabulce mezd.
- **czechia_payroll_unit:** Číselník jednotek hodnot v tabulce mezd.
- **czechia_payroll_value_type:** Číselník typů hodnot v tabulce mezd.
- **czechia_price:** Informace o cenách vybraných potravin za několikaleté období. Datová sada pochází z Portálu otevřených dat ČR.
- **czechia_price_category:** Číselník kategorií potravin, které se vyskytují v našem přehledu.
- **economies:** HDP, GINI, daňová zátěž, atd. pro daný stát a rok.

## Výzkumné otázky
1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

## Postup 

### První otázka
- Do view *v_tadeas_bartos_project_SQL_prvni_uloha* načteny sloupce *industry_branch_code, payroll_year, avg(value)* z tabulky *czechia_payroll*.
- Pomocí *left join* a *lag* připojena stejná tabulka, ale s posunutím hodnot o jeden rok. To umožní vytvoření dalšího sloupce *TREND* s hodnotami *ROSTE/KLESÁ/NEROSTE*, který vyhodnocuje trend průměrných mezd. 
- Další sérií dotazů jsou vybrány pouze řádky kde *TREND=ROSTE* a *TREND=KLESA*. Pomocí *left join* doplněné o tabulku *czechia_payroll_industry_branch*, abychom se dozvěděli i název odvětví.

#### Odpověď
- Na základě srovnání mezd z předchozích let lze říct, že až na pár výjimek (14 záznamů ze 420) mzdy meziročně rostou.
- Výjimky:
ODVĚTVÍ ROK TREND
Profesní, vědecké a technické činnosti	2010	KLESÁ
Veřejná správa a obrana; povinné sociální zabezpečení	2010	KLESÁ
Kulturní, zábavní a rekreační činnosti	2011	KLESÁ
Peněžnictví a pojišťovnictví	2013	KLESÁ
Činnosti v oblasti nemovitostí	2013	KLESÁ
Profesní, vědecké a technické činnosti	2013	KLESÁ
Administrativní a podpůrné činnosti	2013	KLESÁ
Kulturní, zábavní a rekreační činnosti	2013	KLESÁ
Těžba a dobývání	2013	KLESÁ
Výroba a rozvod elektřiny, plynu, tepla a klimatiz. vzduchu	2013	KLESÁ
Výroba a rozvod elektřiny, plynu, tepla a klimatiz. vzduchu	2015	KLESÁ
Činnosti v oblasti nemovitostí	2020	KLESÁ
Veřejná správa a obrana; povinné sociální zabezpečení	2021	KLESÁ
Zemědělství, lesnictví, rybářství	2021	KLESÁ