* All cartels
local cartels "aztecas blo barbie cdsaffiliatesfactions cida cjng ctng caballerostemplarios cartelnuevaplaza cartelnuevoimperio carteldecancun carteldecolima carteldeensenada carteldejuarez carteldeoaxaca carteldesantarosadelima carteldesinaloa carteldetepalcatepec carteldetlahuac carteldelasierra carteldelgolfo carteldelnoreste carteldelponiente comandosuicida cárteldetijuana cárteldelcentro elgallito familiamichoacana fresitasgolfosurrojostampico fuerzaantiunion grupobravo grupopantera gruposombra guardiaguerrerense guerrerosunidos josépineda labarredora lamanoconojos lanuevafamiliamichoacana laresistencia latercerahermandad launioninsurgentes launiondeleon lasmaras lasmoicas losardillos loschamorros losdamasos losdragones losepitacio loserres losgilos losgranados losmazos losmetros lospelones losrojos lostena losteos lostequileros losviagra loszetas mazatlecosmezaflores milenio nachocoronelfaction patronsanchezelh2 rojosciclonescardenas sangrenuevaguerrerense sangrenuevazeta talibanes uniontepito viejaescuela"

*The nine biggest cartels
local big_cartels "carteldejuarez carteldelgolfo familiamichoacana cárteldetijuana carteldesinaloa blo cjng loszetas caballerostemplarios"


use "${data}1c_merge.dta", clear
sort year municipality

bysort product: gen aux=_N
tab aux
drop if aux<50 // 3,120 observations
drop aux


encode product, gen(idprod)
encode subproduct, gen(idsubprod)
gen price= precio_medio_rural
replace price=precio_promedio if price==.
drop if price==0
gen production= superficie_cosechada
replace production=produccion if production==.
drop if production==.


sort year municipality
gen round_prod=round(production)

preserve
collapse (mean) avg_price=price (sd) sd_price=price  [fw=round_prod], by(subproduct year)
save "${temp}avg_price.dta", replace
restore

preserve
collapse (mean) avg_prod=production (sd) sd_prod=production, by(subproduct year)
save "${temp}avg_prod.dta", replace
restore

merge m:1 subproduct year using "${temp}avg_price.dta" // 29 not matched obs
drop _merge
gen st_price=(price-avg_price)/sd_price
drop if st_price>10 | st_price<-10 // 1,367 obs (0.25%)

merge m:1 subproduct year using "${temp}avg_prod.dta"
drop _merge
gen st_prod=(price-avg_prod)/sd_prod
*drop if st_prod>10 | st_prod<-10 // 


sort year id_mun
egen number_cartels=rowtotal(`cartels')
gen presence=number_cartels>0
foreach number of numlist 1/4 {
	gen presence_`number'=number_cartels==`number'
}
gen presence_5plus=number_cartels>=5

sort year id_mun
egen bnumber_cartels=rowtotal(`big_cartels')
gen b_presence=bnumber_cartels>0
foreach number of numlist 1/4 {
	gen b_presence_`number'=bnumber_cartels==`number'
}
gen b_presence_5plus=bnumber_cartels>=5





order year id_mun state municipality product subproduct price avg_price production number_cartels presence presence_1 presence_2 presence_3 presence_4 presence_5plus
save "${data}products_prices.dta", replace

use "${data}products_prices.dta", clear
egen aux=tag(id_mun year)
keep if aux==1
drop aux
sort id_mun year
by id_mun: gen movement=number_cartels-number_cartels[_n-1]
gen entry_number=movement if movement>=0, after(movement)
gen exit_number=-movement if movement<=0, after(entry_number)
gen entry=entry_number>0 & !missing(entry_number), after(movement)
gen exit=exit_number>0 & !missing(exit_number), after(entry)


sort id_mun year
by id_mun: gen bmovement=bnumber_cartels-bnumber_cartels[_n-1]
gen bentry_number=bmovement if bmovement>=0, after(bmovement)
gen bexit_number=-bmovement if bmovement<=0, after(bentry_number)
gen bentry=bentry_number>0 & !missing(bentry_number), after(bmovement)
gen bexit=bexit_number>0 & !missing(bexit_number), after(bentry)

save "${temp}entry_exit.dta", replace


use "${data}products_prices.dta", clear
merge m:1 id_mun year using "${temp}entry_exit.dta"
drop _merge
drop if id_mun==.
save "${data}products_prices.dta", replace



use "${data}products_prices.dta", clear
collapse (mean) presence presence_1 presence_2 presence_3 presence_4 presence_5plus b_presence b_presence_1 b_presence_2 b_presence_3 b_presence_4 b_presence_5plus movement entry exit entry_number exit_number bmovement bentry bexit bentry_number, by(id_mun year)
foreach variable in presence presence_1 presence_2 presence_3 presence_4 presence_5plus b_presence b_presence_1 b_presence_2 b_presence_3 b_presence_4 b_presence_5plus movement entry exit entry_number exit_number bmovement bentry bexit bentry_number {
	bysort id_mun: gen `variable'_lag1=`variable'[_n-1]
	bysort id_mun: gen `variable'_lag2=`variable'[_n-2]
	bysort id_mun: gen `variable'_lag3=`variable'[_n-3]
}
save "${temp}entry_exit_lagged.dta", replace


use "${data}products_prices.dta", clear
merge m:1 id_mun year using "${temp}entry_exit_lagged.dta"
drop _merge
drop if id_mun==.
save "${data}products_prices.dta", replace
