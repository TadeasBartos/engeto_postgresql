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
1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

#### Řešení
- Do view *v_tadeas_bartos_project_SQL_prvni_uloha* načteny sloupce *industry_branch_code, payroll_year, avg(value)* z tabulky *czechia_payroll*.
- Pomocí *left join* a *lag* připojena stejná tabulka, ale s posunutím hodnot o jeden rok. To umožní vytvoření dalšího sloupce *TREND* s hodnotami *ROSTE/KLESÁ/NEROSTE*, který vyhodnocuje trend průměrných mezd meziročně. 
- Další sérií dotazů jsou vybrány pouze řádky kde *TREND=ROSTE* a *TREND=KLESA*. Pomocí *left join* doplněné o tabulku *czechia_payroll_industry_branch*, abychom se dozvěděli i název odvětví.
- Do výstupní tabulky uloženy pouze názvy odvětví a roky, kde mzdy meziročně klesaly.

#### Odpověď
- Na základě srovnání mezd z předchozích let lze říct, že až na pár výjimek (14 záznamů ze 420) mzdy meziročně rostou.
- Opakujicí se odvětví vidíme pouze ojediněle. To znamená, že žádné odvětví nezasáhl negativní trend růstu mezd.
- Skript data ukládá do tabulky *t_tadeas_bartos_project_SQL_primary_final*.
- Kompletní seznam jednotlivých odvětví, kde mzdy meziročně klesaly je zde:

| ODVĚTVÍ | ROK | TREND |
|---------|-----|-------|
| Profesní, vědecké a technické činnosti | 2010 | KLESÁ |
| Veřejná správa a obrana; povinné sociální zabezpečení | 2010 | KLESÁ |
| Kulturní, zábavní a rekreační činnosti | 2011 | KLESÁ |
| Peněžnictví a pojišťovnictví | 2013 | KLESÁ |
| Činnosti v oblasti nemovitostí | 2013 | KLESÁ |
| Profesní, vědecké a technické činnosti | 2013 | KLESÁ |
| Administrativní a podpůrné činnosti | 2013 | KLESÁ |
| Kulturní, zábavní a rekreační činnosti | 2013 | KLESÁ |
| Těžba a dobývání | 2013 | KLESÁ |
| Výroba a rozvod elektřiny, plynu, tepla a klimatiz. vzduchu | 2013 | KLESÁ |
| Výroba a rozvod elektřiny, plynu, tepla a klimatiz. vzduchu | 2015 | KLESÁ |
| Činnosti v oblasti nemovitostí | 2020 | KLESÁ |
| Veřejná správa a obrana; povinné sociální zabezpečení | 2021 | KLESÁ |
| Zemědělství, lesnictví, rybářství | 2021 | KLESÁ |

### Druhá otázka
2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

#### Řešení
- Prohledání tabulek *czechia_price* + *czechia_price_category* pro nalezení kódu mléka a chleba.
- Do view *v_tadeas_bartos_max_cena* načteny maximální ceny chleba a mléka (*cpc.code in ('111301', '114201')*), doplněné o číslo kategorie a rok z tabulek *czechia_price* + *czechia_price_category*. 
- Do view *v_tadeas_bartos_mzdy_20172018* načteny pruměrné mzdy (*value_type_code = '5958'*) a odfiltrovány nulové hodnoty za všechny odvětví.
- Spojení tabulek přes join a výpočet, kolik artiklů si z průměrné mzdy mohou koupit. Vypočteno pro každý artikl zvlášť a zaokrouhleno směrem dolů na celé číslo.

#### Odpověď
- Hodnoty uloženy do výstupní tabulky *t_tadeas_bartos_project_SQL_primary_final*.
- Ukázka pro rok 2017 a oba artikly:

| rok | jmeno_odvetvi | prumerna_mzda | artikl | max_cena | pocet |
|-----|---------------|---------------|--------|----------|-------|
| 2017 | Administrativní a podpůrné činnosti | 19214.625000000000 | Chléb konzumní kmínový | 26.32 | 730.0
| 2017 | Administrativní a podpůrné činnosti | 19214.625000000000 | Mléko polotučné pasterované | 22.79 | 843.0

### Třetí otázka
3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

#### Řešení
- Do view *v_tadeas_bartos_SQL_treti_uloha* z tabulky *czechia_price_category, czechia_price* načteny hodnoty *zbozi, nazev, rok, prumerna cena* a pomocí *left join* + *lag* načteny na stejné řádky i pruměrná cena za minulý rok.
- Ve view *v_zmena_ceny* spočítána procentuální změna mezi jednotlivými roky. 
- Následně je spočítána průměrná procentuální hodnota změny cena napříč všemi roky do view *v_polozka*, odfiltrovány pouze kladné hodnoty, seřazeno vzestupně a ukázána pouze první hodnota - tedy ta položka, s nejnižším procentuálním růstem ceny napříč roky. 

#### Odpověď
Nejpomaleji zdražujícím artiklem napříč roky 2006-2018 je:

| nazev | procentualni_zmena_ceny_pct |
|-------|-----------------------------|
| Rostlinný roztíratelný tuk | 0.01 |

**Tato otázka nemá výstupní tabulku.**

### Čtvrtá otázka
4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

#### Řešení
- Spojení tabulek *czechia_price/czechia_price_category* do jednoho view.
- Vytvoření view *v_ceny_zbozi_tento_minuly_rok* se sloupci ceny v aktuálním a předchozím roce v jedné tabulce pomocí *left join* a *lag*. 
- Výpočet procentuální změny všech položek v jednom roce do view *v_pct_zmena_cen_zbozi*.

- Vytvoření view *v_vyplaty_tento_minuly_rok* s rokem výplaty, výplatou daný rok a výplatou rok předchozí.
- Vytvoření view *v_pct_zmena_vyplat* a výpočet procentuální změny výplaty.

- Vytvoření view *v_zaver* spojením tabulek *pct_zmena_vyplat/pct_zmena_cen* a porovnání hodnot. Vytvoření nového sloupce *co_rostlo_vice* s hodnotami *zboží/platy*. 

| rok   | pct_zmena_cen | pct_zmena_platu | rozdil | co_rostlo_vice |
|-------|---------|---------|--------|-----------|
| 2007  | 6.76    | 6.86    | -0.10  | platy     |
| 2008  | 6.19    | 7.87    | -1.68  | platy     |
| 2009  | -6.42   | 3.17    | -9.59  | platy     |
| 2010  | 1.95    | 1.96    | -0.01  | platy     |
| 2011  | 3.35    | 2.31    | 1.04   | zboží     |
| 2012  | 6.73    | 3.01    | 3.72   | zboží     |
| 2013  | 5.10    | -1.49   | 6.59   | zboží     |
| 2014  | 0.74    | 2.57    | -1.83  | platy     |
| 2015  | -0.55   | 2.54    | -3.09  | platy     |
| 2016  | -1.19   | 3.69    | -4.88  | platy     |
| 2017  | 9.63    | 6.31    | 3.32   | zboží     |
| 2018  | 2.17    | 7.65    | -5.48  | platy     |

- Dodatečný výpočet o kolik celkem rostly platy a ceny zboží:

| suma_pct_zmena_cen | suma_pct_zmen_platu |
|--------------------|---------------------|
| 34.46 | 46.45 |

#### Odpověď

a) V dostupných datech neexistuje rok, kde by meziroční nárůst cen potravin byl výrazně vyšší než meziroční růst mezd. 

b) Nejvýraznější rozdíly přinesl rok 2009, kde došlo k vyššímu poklesu cen potravin a průměrnému růstu mezd.

c) Ojedinělý případ, kdy je absolutně nejvyšší rozdíl mezi růstem platů a cen zboží je rok 2013. Zde došlo k poklesu platů a běžnému růstu cen. Obecně lze hovořit o výjimce, protože za celé dostupné období platy narostly o 46.45%, kdežto mzdy o 34.46%. 

d) V žádném z případů nedošlo k růstu cen/mez vyššímu než 10%. Nejblíže této hodnotě byl tok 2017, kde byl ale i růst platů vysoký a rozdíl je pouze +3.32%.

**Tato otázka nemá výstupní tabulku.**

### Pátá otázka
5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

#### Řešení
- Spojení tabulek *czechia_price/czechia_price_category* do jednoho view.
- Vytvoření view *v_ceny_zbozi_tento_minuly_rok* se sloupci ceny v aktuálním a předchozím roce v jedné tabulce pomocí *left join* a *lag*. 
- Výpočet procentuální změny všech položek v jednom roce do view *v_pct_zmena_cen_zbozi*.
- Vytvoření view *v_vyplaty_tento_minuly_rok* s rokem výplaty, výplatou daný rok a výplatou rok předchozí.
- Vytvoření view *v_pct_zmena_vyplat* a výpočet procentuální změny výplaty.
- Vytvoření view *v_zaver* spojením tabulek *pct_zmena_vyplat/pct_zmena_cen* a porovnání hodnot. Vytvoření nového sloupce *co_rostlo_vice* s hodnotami *zboží/platy*. 

- Vytažení dat z tabulky economics pro region euro zóny. 
- Výpočet pct_zmeny HDP.
- Připojení tabulky z v_zaver a uložení jako view.

Metriky vyhodnocení: 
- Korelace HDP a cen zboží.
- Korelace HDP a platů.
- Roky kdy rostlo HDP a klesaly mzdy. 

#### Odpověď 
View *v_hdp_ceny_platy*:
- Většinou platí, že růst HDP vede k růstu cen i mezd, ale existují výjimky, kde jiné faktory ovlivnily inflaci a mzdy (např. globální krize, změny daní, specifická ekonomická politika).

View v_korelace:
- Hodnota korelace HDP/ceny 0.43 označuje slabší korelaci - vztah je pozitivní, při růstu HDP lze předpokládat i růst cen.
- Hodnota korelace HDP/mzdy 0.19 označuje velmi slabý pozitivní vztah - mezi těmito dvěma veličinami není silná vazba a jejich souvislost může být náhodná nebo ovlivněná jinými faktory.
- Dle kapitoly f), která počítala roky, kdy rostlo HDP a mzdy nikoliv, lze říct že pokud rostlo HPD, tak rostly i mzdy. Což je dobrá zpráva.
- Pro úplny kontext by bylo důležité porovnání s hodnotami na trhu práce, úrokové sazby a jiné.

**Tato otázka nemá výstupní tabulku.**