/*
1b_clean: This do files cleans data so it can be merged

Inputs:
	"${data}cartels.dta"
	"${data}agriculture.dta"
	"${data}livestock.dta"
	"${data}municipalities.dta"
	

Outputs:
	"${temp}products_prices.dta"
	"${data}products_prices.dta"
	
*/

* Append agricultural and livestock data
use "${data}agriculture.dta", clear
append using "${data}livestock.dta"

* Merge with the municipalities data so we have an unique identifier for each municipality
merge m:1 muns using "${data}municipalities.dta"

* Drop municipalities for which we don't have neither agricultural nor livestock data
drop if _merge==2 // 32 municipalities
drop _merge

* Merge with the cartels presence data using the unique identifier
merge m:1 year id_mun using "${data}cartels.dta"

* Drop municipalities for which we don't have neither agricultural nor livestock data 
drop if _merge==2  // 56 municipalities
drop _merge

* Drop municipalities for which we don't have neither agricultural nor livestock data 
merge m:1 year id_mun using "${data}births.dta"
order year id_mun
drop if _merge==2 // 1,620 obs
drop _merge

* Drop municipalities for which we don't have neither agricultural nor livestock data 
merge m:1 id_mun using "${data}census.dta"
drop if _merge==2 // 26 obs
drop _merge

merge m:m muns using "${data}electoral.dta"
drop if _merge==1
drop _merge

* We are left with 2,443 municipalities out of 2,471. We have data on 98.9% of municipalities.
save "${data}1c_merge.dta", replace

