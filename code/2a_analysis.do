local cartels "aztecas blo barbie cdsaffiliatesfactions cida cjng ctng caballerostemplarios cartelnuevaplaza cartelnuevoimperio carteldecancun carteldecolima carteldeensenada carteldejuarez carteldeoaxaca carteldesantarosadelima carteldesinaloa carteldetepalcatepec carteldetlahuac carteldelasierra carteldelgolfo carteldelnoreste carteldelponiente comandosuicida cárteldetijuana cárteldelcentro elgallito familiamichoacana fresitasgolfosurrojostampico fuerzaantiunion grupobravo grupopantera gruposombra guardiaguerrerense guerrerosunidos josépineda labarredora lamanoconojos lanuevafamiliamichoacana laresistencia latercerahermandad launioninsurgentes launiondeleon lasmaras lasmoicas losardillos loschamorros losdamasos losdragones losepitacio loserres losgilos losgranados losmazos losmetros lospelones losrojos lostena losteos lostequileros losviagra loszetas mazatlecosmezaflores milenio nachocoronelfaction patronsanchezelh2 rojosciclonescardenas sangrenuevaguerrerense sangrenuevazeta talibanes uniontepito viejaescuela"

local big_cartels "carteldejuarez carteldelgolfo familiamichoacana cárteldetijuana carteldesinaloa blo cjng loszetas caballerostemplarios"

set scheme s1color
use "${data}products_prices_labeled.dta", clear
sum price, det

********************************
egen aux=tag(id_mun year)
keep if aux==1
collapse (sum) `cartels', by(year)
foreach variable in `cartels' {
		graph twoway line `variable' year, title(`variable''s presence) ytitle(Municipalities where the cartel is active) ylabel(0(50)100)
		graph export "${graph}presence_`variable'.png", replace
}

********************************
use "${data}products_prices_labeled.dta", clear
egen aux=tag(id_mun year)
keep if aux==1
drop aux
collapse (sum) presence presence_1 presence_2 presence_3plus, by(year)
foreach variable in presence presence_1 presence_2 presence_3plus {
	graph bar `variable', over(year) title(Municipalities with # cartels) ytitle(`variable')
	graph export "${graph}allcartels_`variable'.png", replace
}

********************************
use "${data}products_prices_labeled.dta", clear
egen aux=tag(id_mun year)
keep if aux==1
drop aux
collapse (sum) b_presence b_presence_1 b_presence_2 b_presence_3plus, by(year)
foreach variable in b_presence b_presence_1 b_presence_2 b_presence_3plus {
	graph bar `variable', over(year) title(Municipalities with # big cartels) ytitle(`variable')
	graph export "${graph}bigcartels_`variable'.png", replace
}


********************************
use "${data}products_prices_labeled.dta", clear

collapse (mean) st_price avg_price production valor_produccion presence presence_1 presence_2 presence_3plus b_presence b_presence_1 b_presence_2 b_presence_3plus number_cartels, by(year id_mun)
replace number_cartels=3 if number_cartels>4
twoway (scatter st_price year if presence==0) (scatter st_price year if presence==1)
twoway (lfit st_price year if presence==0) (lfit st_price year if presence==1), legend(order(1 "Sin presencia" 2 "Con presencia")) yti("Precio") xti("Año")
graph export "${graph}change_price_presence.png", replace
graph box st_price, over(number_cartels) noout
graph export "${graph}change_price_cartels.png", replace
foreach year of numlist 2003/2020 {
	graph box st_price if year==`year', over(number_cartels) noout
	graph export "${graph}change_price_cartels_`year'.png", replace
}

********************************
use "${data}products_prices_labeled.dta", clear
foreach year of numlist 2003(1)2020 {
	reg st_price presence if year==`year'
	reg st_price presence_1 presence_2 presence_3plus if year==`year'
	reg st_prod presence if year==`year'
	reg st_prod presence_1 presence_2 presence_3plus if year==`year'
}

reg st_price presence i.year
reg st_price movement i.year
reg st_price entry exit i.year
reg st_price presence_1 presence_2 presence_3plus i.year
reg st_prod presence i.year
reg st_prod presence_1 presence_2 presence_3plus i.year

reg st_price b_presence i.year
reg st_price bmovement i.year
reg st_price bentry bexit i.year
reg st_price b_presence_1 b_presence_2 b_presence_3plus i.year
reg st_prod b_presence i.year
reg st_prod b_presence_1 b_presence_2 b_presence_3plus i.year
********************************
use "${data}products_prices_labeled.dta", clear
hist st_price
graph export "${graph}st_price.png", replace



****
* Table 1
use "${data}products_prices_labeled.dta", clear
egen aux=tag(id_mun year)
keep if aux==1
drop aux
unique(id_mun)
unique(year)
preserve
collapse (mean) movement entry exit entry_number exit_number bmovement bentry bexit bentry_number bexit_number, by(year) 
br
restore
rename fresitasgolfosurrojostampico fresitas
local cartels "aztecas blo barbie cdsaffiliatesfactions cida cjng ctng caballerostemplarios cartelnuevaplaza cartelnuevoimperio carteldecancun carteldecolima carteldeensenada carteldejuarez carteldeoaxaca carteldesantarosadelima carteldesinaloa carteldetepalcatepec carteldetlahuac carteldelasierra carteldelgolfo carteldelnoreste carteldelponiente comandosuicida cárteldetijuana cárteldelcentro elgallito familiamichoacana fresitas fuerzaantiunion grupobravo grupopantera gruposombra guardiaguerrerense guerrerosunidos josépineda labarredora lamanoconojos lanuevafamiliamichoacana laresistencia latercerahermandad launioninsurgentes launiondeleon lasmaras lasmoicas losardillos loschamorros losdamasos losdragones losepitacio loserres losgilos losgranados losmazos losmetros lospelones losrojos lostena losteos lostequileros losviagra loszetas mazatlecosmezaflores milenio nachocoronelfaction patronsanchezelh2 rojosciclonescardenas sangrenuevaguerrerense sangrenuevazeta talibanes uniontepito viejaescuela"
foreach variable in `cartels' {
	bysort year: egen active_`variable'=max(`variable')
}
egen active=rowtotal(active_*)
drop active_*
tab year, sum(active)

gen shortened_number_cartels=number_cartels
replace shortened_number_cartels=3 if number_cartels>3
preserve
collapse (sum) presence presence_1 presence_2 presence_3plus, by(year)
foreach variable in presence presence_1 presence_2 presence_3plus {
	twoway bar presence year, ti(Municipalities with `variable') yti(Municipalities) xlab(2002(2)2020) xti(Year)
	graph export "${graph}allcartels_`variable'.png", replace
}
restore
destring Pob*, replace
tab shortened_number_cartels, sum(Pob_total)
* Number of cartels & number of big cartels


****
* Table 2
use "${data}products_prices_labeled.dta", clear
keep if superficie_sembrada!=.
unique(product)
unique(subproduct)
gen shortened_number_cartels=number_cartels
replace shortened_number_cartels=3 if number_cartels>3
tab shortened_number_cartels, sum(st_price)
tab shortened_number_cartels, sum(valor_produccion)
tab shortened_number_cartels, sum(superficie_sembrada)
reg st_price presence i.year
reg st_price presence_1 presence_2 presence_3plus i.year
reg valor_produccion presence i.year
reg valor_produccion presence_1 presence_2 presence_3plus i.year
reg superficie_sembrada presence i.year
reg superficie_sembrada presence_1 presence_2 presence_3plus i.year
preserve
qui sum valor_produccion, det
gen outliers=valor_produccion>r(p95)
drop if outliers==1
tab shortened_number_cartels, sum(st_price)
tab shortened_number_cartels, sum(valor_produccion)
tab shortened_number_cartels, sum(superficie_sembrada)
reg st_price presence i.year
reg st_price presence_1 presence_2 presence_3plus i.year
reg valor_produccion presence i.year
reg valor_produccion presence_1 presence_2 presence_3plus i.year
reg superficie_sembrada presence i.year
reg superficie_sembrada presence_1 presence_2 presence_3plus i.year
restore


****
* Table 3
use "${data}products_prices_labeled.dta", clear
drop if superficie_sembrada!=.
unique(product)
unique(subproduct)
gen shortened_number_cartels=number_cartels
replace shortened_number_cartels=3 if number_cartels>3
tab shortened_number_cartels, sum(st_price)
tab shortened_number_cartels, sum(valor_produccion)
tab shortened_number_cartels, sum(produccion_pie)
reg st_price presence i.year
reg st_price presence_1 presence_2 presence_3plus i.year
reg valor_produccion presence i.year
reg valor_produccion presence_1 presence_2 presence_3plus i.year
reg produccion_pie presence i.year
reg produccion_pie presence_1 presence_2 presence_3plus i.year
preserve
qui sum valor_produccion, det
gen outliers=valor_produccion>r(p95)
drop if outliers==1
tab shortened_number_cartels, sum(st_price)
tab shortened_number_cartels, sum(valor_produccion)
tab shortened_number_cartels, sum(produccion_pie)
reg st_price presence i.year
reg st_price presence_1 presence_2 presence_3plus i.year
reg valor_produccion presence i.year
reg valor_produccion presence_1 presence_2 presence_3plus i.year
reg produccion_pie presence i.year
reg produccion_pie presence_1 presence_2 presence_3plus i.year
restore

****
* Table 4
use "${data}products_prices_labeled.dta", clear
bysort presence: sum total_births pob_tot rate_pob_18plus rate_illiterate_8to14 rate_illiterate_15plus rate_avg_schooling_years rate_pea rate_health_none rate_civil_single hh_total rate_hh_dirt_floor rate_hh_electricity rate_hh_water rate_hh_sewage


