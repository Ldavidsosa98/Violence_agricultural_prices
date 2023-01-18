/*
1a_import: This do files imports data from several formats and saves them as .dta databases.

Imports:
	"${raw}CartelPresence_wide.csv"
	"${raw}agricola.txt"
	"${raw}pecuario.txt"
	"${raw}pesca.txt"
	"${raw}municipalities.xlsx"
	"${raw}ena17.xlsx"
	

Outputs:
	"${temp}cartels.dta"
	"${temp}agriculture.dta"
	"${temp}livestock.dta"
	"${temp}fish.dta"
	"${temp}municipalities.dta"
	"${temp}ena17.dta"
	

*/

*Cartel's presence by municipality from 1990 to 2020.
clear
import delimited "${raw}CartelPresence_wide.csv", varnames(1)
save "${temp}cartels.dta", replace

*Agricultural production and prices by municipality-product from 2003 to 2021.
import delimited "${raw}agricola.txt", clear
save "${temp}agriculture.dta", replace

*Livestock production and prices by municipality-product from 2003 to 2021.
import delimited "${raw}pecuario.txt", clear
save "${temp}livestock.dta", replace

*Fishery production and prices by state-product from 2003 to 2021.
import delimited "${raw}pesca.txt", clear
save "${temp}fish.dta", replace

*Municipality codes and population per municipality.
clear
import excel "${raw}municipalities.xlsx", firstrow
save "${temp}municipalities.dta", replace

*Agricultural National Survey 2017. Production by municipality-product from 2017.
clear
import excel "${raw}ena17.xlsx", sheet("ena17_mun_agri13") firstrow
save "${temp}ena17.dta", replace

*Import birth data by municipality
foreach year of numlist 1999(1)2021 {
	clear
	import excel "${raw}nacimientos_`year'.xls", firstrow
	save "${temp}births_`year'.dta", replace
}

*Import census data by locality
import delimited "${raw}ITER_NALCSV20.csv", clear
save "${temp}census.dta", replace


* Import electoral databases
foreach year of numlist 1997(1)2022 {
	foreach state in ags bc bcs campeche cdmx chiapas chihuahua coahuila colima durango edomex gro gto hidalgo jalisco michoacan morelos nayarit puebla qro qroo sinaloa slp sonora tabasco tamaulipas tlaxcala veracruz yucatan zacatecas {
		foreach subyear in "" _01 _02 _03 _04 _05 _06 _07 _08 _09 _10 _11 _12 _13 _14 _15 _16 _17 _18 _19 _20 _21 _22 _23 _24 _25 _26 _27 _28 _29 _30 _31 _32 _33 _34 _35 _36 _37 _38 _39 {
			clear
			cap import excel "${raw}resultados electorales/`state'_`year'`subyear'.xlsx", firstrow
			cap save "${temp}resultados electorales/`state'_`year'`subyear'.dta", replace
		}
	}
}