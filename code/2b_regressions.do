local cartels "aztecas blo barbie cdsaffiliatesfactions cida cjng ctng caballerostemplarios cartelnuevaplaza cartelnuevoimperio carteldecancun carteldecolima carteldeensenada carteldejuarez carteldeoaxaca carteldesantarosadelima carteldesinaloa carteldetepalcatepec carteldetlahuac carteldelasierra carteldelgolfo carteldelnoreste carteldelponiente comandosuicida cárteldetijuana cárteldelcentro elgallito familiamichoacana fresitasgolfosurrojostampico fuerzaantiunion grupobravo grupopantera gruposombra guardiaguerrerense guerrerosunidos josépineda labarredora lamanoconojos lanuevafamiliamichoacana laresistencia latercerahermandad launioninsurgentes launiondeleon lasmaras lasmoicas losardillos loschamorros losdamasos losdragones losepitacio loserres losgilos losgranados losmazos losmetros lospelones losrojos lostena losteos lostequileros losviagra loszetas mazatlecosmezaflores milenio nachocoronelfaction patronsanchezelh2 rojosciclonescardenas sangrenuevaguerrerense sangrenuevazeta talibanes uniontepito viejaescuela"

local big_cartels "carteldejuarez carteldelgolfo familiamichoacana cárteldetijuana carteldesinaloa blo cjng loszetas caballerostemplarios"


*1.
use "${data}products_prices_labeled.dta", clear
destring Pob_total, replace
keep if superficie_sembrada!=.
reghdfe st_price presence_1 presence_2 presence_3 presence_4 presence_5plus Pob_total total_births i.year, absorb(id_mun)
reghdfe valor_produccion presence_1 presence_2 presence_3 presence_4 presence_5plus Pob_total total_births i.year, absorb(id_mun)
reghdfe superficie_sembrada presence_1 presence_2 presence_3 presence_4 presence_5plus Pob_total total_births i.year, absorb(id_mun) 

qui sum valor_produccion, det
gen outliers=valor_produccion>r(p95)
drop if outliers==1
reghdfe st_price presence_1 presence_2 presence_3 presence_4 presence_5plus Pob_total total_births i.year, absorb(id_mun)
reghdfe st_price presence_1_lag1 presence_2_lag1 presence_3_lag1 presence_4_lag1 presence_5plus_lag1 Pob_total total_births i.year, absorb(id_mun)
reghdfe st_price presence_1_lag2 presence_2_lag2 presence_3_lag2 presence_4_lag2 presence_5plus_lag2 Pob_total total_births i.year, absorb(id_mun)
reghdfe st_price presence_1_lag3 presence_2_lag3 presence_3_lag3 presence_4_lag3 presence_5plus_lag3 Pob_total total_births i.year, absorb(id_mun)
reghdfe st_price presence presence_lag1 presence_lag2 presence_lag3 Pob_total total_births i.year, absorb(id_mun)

reghdfe valor_produccion presence_1 presence_2 presence_3 presence_4 presence_5plus Pob_total total_births i.year, absorb(id_mun)
reghdfe valor_produccion presence_1_lag1 presence_2_lag1 presence_3_lag1 presence_4_lag1 presence_5plus_lag1 Pob_total total_births i.year, absorb(id_mun)
reghdfe valor_produccion presence_1_lag2 presence_2_lag2 presence_3_lag2 presence_4_lag2 presence_5plus_lag2 Pob_total total_births i.year, absorb(id_mun)
reghdfe valor_produccion presence_1_lag3 presence_2_lag3 presence_3_lag3 presence_4_lag3 presence_5plus_lag3 Pob_total total_births i.year, absorb(id_mun)

reghdfe superficie_sembrada presence_1 presence_2 presence_3 presence_4 presence_5plus Pob_total total_births i.year, absorb(id_mun)
reghdfe superficie_sembrada presence_1_lag1 presence_2_lag1 presence_3_lag1 presence_4_lag1 presence_5plus_lag1 Pob_total total_births i.year, absorb(id_mun)
reghdfe superficie_sembrada presence_1_lag2 presence_2_lag2 presence_3_lag2 presence_4_lag2 presence_5plus_lag2 Pob_total total_births i.year, absorb(id_mun)
reghdfe superficie_sembrada presence_1_lag3 presence_2_lag3 presence_3_lag3 presence_4_lag3 presence_5plus_lag3 Pob_total total_births i.year, absorb(id_mun)




*2.
use "${data}products_prices_labeled.dta", clear
destring Pob_total, replace
drop if superficie_sembrada!=.
reghdfe st_price presence_1 presence_2 presence_3 presence_4 presence_5plus Pob_total total_births i.year, absorb(id_mun)
reghdfe valor_produccion presence_1 presence_2 presence_3 presence_4 presence_5plus Pob_total total_births i.year, absorb(id_mun)
reghdfe produccion_pie presence_1 presence_2 presence_3 presence_4 presence_5plus Pob_total total_births i.year, absorb(id_mun)


qui sum valor_produccion, det
gen outliers=valor_produccion>r(p95)
drop if outliers==1


reghdfe st_price presence_1 presence_2 presence_3 presence_4 presence_5plus Pob_total total_births i.year, absorb(id_mun)
reghdfe st_price presence_1_lag1 presence_2_lag1 presence_3_lag1 presence_4_lag1 presence_5plus_lag1 Pob_total total_births i.year, absorb(id_mun)
reghdfe st_price presence_1_lag2 presence_2_lag2 presence_3_lag2 presence_4_lag2 presence_5plus_lag2 Pob_total total_births i.year, absorb(id_mun)
reghdfe st_price presence_1_lag3 presence_2_lag3 presence_3_lag3 presence_4_lag3 presence_5plus_lag3 Pob_total total_births i.year, absorb(id_mun)
reghdfe st_price presence presence_lag1 presence_lag2 presence_lag3 Pob_total total_births i.year, absorb(id_mun)

reghdfe valor_produccion presence_1 presence_2 presence_3 presence_4 presence_5plus Pob_total total_births i.year, absorb(id_mun)
reghdfe valor_produccion presence_1_lag1 presence_2_lag1 presence_3_lag1 presence_4_lag1 presence_5plus_lag1 Pob_total total_births i.year, absorb(id_mun)
reghdfe valor_produccion presence_1_lag2 presence_2_lag2 presence_3_lag2 presence_4_lag2 presence_5plus_lag2 Pob_total total_births i.year, absorb(id_mun)
reghdfe valor_produccion presence_1_lag3 presence_2_lag3 presence_3_lag3 presence_4_lag3 presence_5plus_lag3 Pob_total total_births i.year, absorb(id_mun)


reghdfe produccion_pie presence_1 presence_2 presence_3 presence_4 presence_5plus Pob_total total_births i.year, absorb(id_mun)
reghdfe produccion_pie presence_1_lag1 presence_2_lag1 presence_3_lag1 presence_4_lag1 presence_5plus_lag1 Pob_total total_births i.year, absorb(id_mun)
reghdfe produccion_pie presence_1_lag2 presence_2_lag2 presence_3_lag2 presence_4_lag2 presence_5plus_lag2 Pob_total total_births i.year, absorb(id_mun)
reghdfe produccion_pie presence_1_lag3 presence_2_lag3 presence_3_lag3 presence_4_lag3 presence_5plus_lag3 Pob_total total_births i.year, absorb(id_mun)









/*
reghdfe st_price movement Pob_total total_births i.year, absorb(id_mun)
reghdfe st_price movement_lag1 Pob_total total_births i.year, absorb(id_mun)
reghdfe st_price movement_lag2 Pob_total total_births i.year, absorb(id_mun)
reghdfe st_price movement_lag3 Pob_total total_births i.year, absorb(id_mun)

drop if presence==1 & (year==2003 | year==2004 | year==2005 | year==2006 | year==2007)
gen entry_date=(entry==1 & entry_lag1==0 & entry_lag2==0 & entry_lag3==0 & (year==2008 | year==2009 | year==2010 | year==2011 | year==2012))
gen rel_time=year


