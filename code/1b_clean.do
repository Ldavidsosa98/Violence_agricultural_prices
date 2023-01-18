/*
1b_clean: This do files cleans data so it can be merged

Imports:
	"${temp}cartels.dta"
	"${temp}agriculture.dta"
	"${temp}livestock.dta"
	"${temp}fish.dta"
	"${temp}municipalities.dta"
	"${temp}births_year.dta" (from 1999 to 2020)
	"${temp}census.dta"
	"${temp}ena17.dta"
	

Outputs:
	"${data}cartels.dta"
	"${data}agriculture.dta"
	"${data}livestock.dta"
	"${data}fish.dta"
	"${data}municipalities.dta"
	"${data}births.dta"
	"${data}census.dta"
	"${data}ena17.dta"
	

*/

*********************************
*** 1. Cartel's presence data ***
*********************************
use "${temp}cartels.dta", clear

*We will only use data for 2003 - 2020.
rename years year
drop if year<2003
rename muns id_mun
save "${data}cartels.dta", replace



****************************
*** 2. Agricultural data ***
****************************
use "${temp}agriculture.dta", clear

destring v2 v3 v4 v5 v6 v7 v8, gen(superficie_sembrada superficie_cosechada superficie_siniestrada produccion rendimiento precio_medio_rural valor_produccion) ignore(",") force

*This variable contains the year, state, muncipality, product and subproduct
encode v1, gen(aux) 
destring v1, gen(year) force

*From the v1 variable, gen 4 variables: product, subproduct, municipality, state. 
gen subproduct=v1
replace subproduct = subproduct[_n-1] if year!=. //This "fills in" all the rows with the desired value
foreach variable in product municipality state {
	gen `variable'=v1
	foreach j of numlist 2003(1)2021 {
		replace aux=. if year[_n+1]==`j'
	}
	drop if year==. & aux==.
	replace `variable' = `variable'[_n-1] if year!=.
}
drop aux
drop if year==. | year==2021

*Remove accents from municipalities that cause problems for merging the datasets
gen muni = lower(ustrto(ustrnormalize(municipality, "nfd"), "ascii", 2))

*Gen a string with the format: "state - municipality" that will serve for merging.
gen aux= state + " - " + muni
gen muns=lower(aux)

*Order and drop unused variables
drop aux muni v1 v2 v3 v4 v5 v6 v7 v8
order year muns state municipality product subproduct


save "${data}agriculture.dta", replace





*************************
*** 3. Livestock data ***
*************************
use "${temp}livestock.dta", clear

*Renaming variables
rename v2 produccion
rename v3 produccion_pie
rename v4 precio_promedio
rename v5 precio_promedio_pie
rename v6 valor_produccion
rename v7 valor_produccion_pie
rename v8 peso_promedio_canal
rename v9 peso_promedio_pie
rename v10 cabezas
destring produccion produccion_pie precio_promedio precio_promedio_pie valor_produccion valor_produccion_pie peso_promedio_canal peso_promedio_pie cabezas, ignore(",") force replace

*This variable contains the year, state, muncipality and subproduct
encode v1, gen(aux)

*Gen year variable
destring v1, gen(year) force

*Gen subproduct variable
gen subproduct=v1
replace subproduct = subproduct[_n-1] if year!=.

*Gen municipality and state variables
foreach variable in municipality state {
	gen `variable'=v1
	foreach j of numlist 2006(1)2021 {
		replace aux=. if year[_n+1]==`j'
	}
	drop if year==. & aux==.
	replace `variable' = `variable'[_n-1] if year!=.
}
drop aux v1
drop if year==. | year==2021

*Remove accents from municipalities that cause problems for merging the datasets
gen muni = lower(ustrto(ustrnormalize(municipality, "nfd"), "ascii", 2))

*Gen a string with the format: "state - municipality" that will serve for merging.
gen aux= state + " - " + muni
gen muns=lower(aux)
drop aux muni

*THIS NEEDS CHANGE
gen product=subproduct
*Order variables
order year muns state municipality product subproduct


save "${data}livestock.dta", replace






***********************
*** 4. Fishery data ***
***********************
use "${temp}fish.dta", clear

*Rename variables
rename v2 peso_vivo
rename v3 peso_desembarcado
rename v4 precio_pie_de_playa
rename v5 valor_produccion
destring peso_vivo peso_desembarcado precio_pie_de_playa valor_produccion, ignore(",") force replace

*This variable contains the year, state and product 
encode v1, gen(aux)

*Gen year variable
destring v1, gen(year) force

*Gen product variable
gen product=v1
replace product = product[_n-1] if year!=.

*Gen state variable
gen state=v1
foreach j of numlist 2011(1)2018 {
		replace aux=. if year[_n+1]==`j'
}
drop if year==. & aux==.
replace state = state[_n-1] if year!=.
drop aux v1
drop if year==. | year==2021

*Order variables
order year state product

save "${data}fish.dta", replace





*************************
*** 5. Municipalities ***
*************************
use "${temp}municipalities.dta", clear
destring cve_ent cve_mun Pob_*, replace
rename nom_ent state
rename nom_mun municipality

*Gen the unique identifier for every municipality (muns)
gen aux=cve_ent*1000
gen id_mun=aux+cve_mun
drop aux

*Rename multiple states and municipalities so they match with the names in the agricultural and livestock datasests
replace state="Michoacán" if state=="Michoacán de Ocampo"
replace state="Veracruz" if state=="Veracruz de Ignacio de la Llave"
replace state="Coahuila" if state=="Coahuila de Zaragoza"
replace municipality="Cintalapa" if municipality=="Cintalapa de Figueroa"
replace municipality="Batopilas" if municipality=="Batopilas de Manuel Gómez Morín"
replace municipality="Jonacatepec" if municipality=="Jonacatepec de Leandro Valle"
replace municipality="Zacualpan" if municipality=="Zacualpan de Amilpas"
replace municipality="Ahualulco" if municipality=="Ahualulco del Sonido 13"
replace municipality="H. V. Tezoatlán de Segura y Luna, C. de la I.de O." if municipality=="Heroica Villa Tezoatlán de Segura y Luna, Cuna de la Independencia de Oaxaca"
replace municipality="Heroica Ciudad de Juchitán de Zaragoza" if municipality=="Juchitán de Zaragoza"
replace municipality="Medellín" if municipality=="Medellín de Bravo"
replace municipality="San Juan Mixtepec - Dto. 26" if id_mun==20209
replace municipality="San Pedro Mixtepec - Dto. 22" if id_mun==20318
replace municipality="Santiago Chazumba" if municipality=="Villa de Santiago Chazumba"
replace municipality="Villa de Tututepec de Melchor Ocampo" if municipality=="Villa de Tututepec"

*Remove accents from municipalities that cause problems for merging the datasets
gen muni = lower(ustrto(ustrnormalize(municipality, "nfd"), "ascii", 2))

*Gen a string with the format: "state - municipality" that will serve for merging.
gen aux= state + " - " + muni
gen muns=lower(aux)


drop if cve_ent==. // 1 observation

*Order varables
keep muns state municipality id_mun Pob_total Pob_masculina Pob_femenina Totaldeviviendashabitadas
order muns state municipality id_mun


save "${data}municipalities.dta", replace

***********************
****** 6. Births ******
***********************

* Append births data for 1999 to 2021
use "${temp}births_1999.dta", clear
foreach year of numlist 2000(1)2020 {
	append using "${temp}births_`year'.dta"
}

* Destring several variables
destring Total Hospitaloclínica Hospitaloclínicaoficial Hospitaloclínicaprivada Domicilio Otro Noespecificado , replace ignore(",")
destring Clave, replace ignore(" ")

* Rename some variables
rename Año year
rename Clave id_mun
rename Estado state
rename Total total_births
rename Hospitaloclínica hospital_births
rename Hospitaloclínicaoficial public_hospital_births
rename Hospitaloclínicaprivada private_hospital_births
rename Domicilio home_births
rename Otro other_births
rename Noespecificado nonspecified_births

*Gen non-hospital births variable
gen unknown_place_births=other_births + nonspecified_births
gen nonhospital_births=home_births + unknown_place_births, after(hospital_births)
drop other_births nonspecified_births

* Gen municipality variable and fix state and municipality variables
gen municipality=state, after(state)
replace state="" if id_mun>=36
replace state=state[_n-1] if state==""

* Drop blank rows
drop if total_births==.

* Replace missing values with 0
foreach variable in hospital_births public_hospital_births private_hospital_births home_births unknown_place_births nonhospital_births {
	replace `variable'=0 if `variable'==.
}

keep if year>=2003

* Save dataset
save "${data}births.dta", replace


***********************
****** 7. Census ******
***********************
use "${temp}census.dta", clear

* Only keep data for municipalities (not states, nor regions)
keep if locality=="Total del Municipio"

*Gen muncipality identifier
gen id_mun=id_state*1000+id_municipality

* Destring variables
destring pob_fem pob_masc pob_0to2 pob_fem_0to2 pob_masc_0to2 pob_3plus pob_fem_3plus pob_masc_3plus pob_5plus pob_fem_5plus pob_masc_5plus pob_12plus pob_fem_12plus pob_masc_12plus pob_15plus pob_fem_15plus pob_masc_15plus pob_18plus pob_fem_18plus pob_masc_18plus pob_3to5 pob_fem_3to5 pob_masc_3to5 pob_6to11 pob_fem_6to11 pob_masc_6to11 pob_8to14 pob_fem_8to14 pob_masc_8to14 pob_12to14 pob_fem_12to14 pob_masc_12to14 pob_15to17 pob_fem_15to17 pob_masc_15to17 pob_18to24 pob_fem_18to24 pob_masc_18to24 pob_60plus pob_fem_60plus pob_masc_60plus ratio_masc_fem pob_0to14 pob_15to64 pob_65plus avg_kids pob_born_other_state pob_fem_born_other_state pob_masc_born_other_state v60 pob_ind_3plus pob_fem_ind_3plus pob_masc_ind_3plus pob_afro pob_fem_afro pob_masc_afro pob_disc pob_no_disc noschool_3to5 noschool_6to11 noschool_12to14 noschool_15to17 illiterate_8to14 illiterate_15plus avg_schooling_years avg_fem_schooling_years avg_masc_schooling_years pea pea_fem pea_masc health_none health_yes health_imss health_issste health_issste_state health_pemex health_insabi health_imss_bienestar health_private health_other civil_single civil_married civil_divorced religion_catholic religion_protestant religion_other religion_none hh_total hh_dirt_floor hh_electricity hh_no_electricity hh_water hh_sewage, replace

* Gen rates per 100k people
foreach variable in pob_18plus illiterate_8to14 illiterate_15plus avg_schooling_years pea health_none civil_single religion_catholic {
	gen rate_`variable'=`variable'/pob_tot*100000
}

* Gen rates per household
foreach variable in hh_dirt_floor hh_electricity hh_water hh_sewage {
	gen rate_`variable'=`variable'/hh_total
}

save "${data}census.dta", replace



*******************
*** 9. ENA 2017 ***
*******************
use "${temp}ena17.dta", clear

*Drop observations where production is missing
drop if Producciónobtenida==.

*Drop unused variables
drop N O P Q Cultivo

*Rename variables
rename Entidad state
rename Municipio municipality
rename Entidadfederativamunicipioy product
rename Producciónobtenida obtained_production
rename Producciónvendida sold_production
rename Directoalconsumidor buyer_consumer
rename Intermediariocoyote buyer_coyote
rename Centraldeabastos buyer_central_de_abastos
rename Centrocomercialosupermercado buyer_supermarket
rename Empacadoraoindustriaprocesado buyer_empacador
rename Directamenteaotropaís buyer_export
rename Otrotipodecomprador buyer_other


save "${data}ena17.dta", replace




**************************
*** 10. Electoral data ***
**************************

****** Ags *******
use "${temp}resultados electorales/ags_2015_01.dta", clear
foreach number in _02 _03 _04 _05 _06 _07 _08 _09 _10 _11 {
	append using "${temp}resultados electorales/ags_2015`number'.dta", force
}

save "${temp}clean/ags_2015.dta", replace

use "${temp}resultados electorales/ags_2018_01.dta", clear
foreach number in _02 _03 _04 _05 _06 _07 _08 _09 _10 _11 {
	append using "${temp}resultados electorales/ags_2018`number'.dta", force
}

save "${temp}clean/ags_2018.dta", replace

use "${temp}resultados electorales/ags_2020_01.dta", clear
foreach number in _02 _03 _04 _05 _06 _07 _08 _09 _10 _11 {
	append using "${temp}resultados electorales/ags_2020`number'.dta", force
}

save "${temp}clean/ags_2020.dta", replace

****** Bc *******
use "${temp}resultados electorales/bc_2001.dta", clear
rename PAN pan
rename PRI pri
rename PRD prd
rename TOTAL votos
rename Año year
rename DISTRITO mun
destring pan pri prd votos year prd, replace ignore(",")
keep pan pri prd votos year mun
save "${temp}clean/bc_2001.dta", replace

use "${temp}resultados electorales/bc_2004.dta", clear
drop if DistritoElectoral=="Estado"
rename PAN pan
rename PRI pri
rename PRD prd
rename Totaldevotos votos
rename Año year
rename DistritoElectoral mun
destring pan pri prd votos year, replace ignore(",")
keep pan pri prd votos year mun
save "${temp}clean/bc_2004.dta", replace

use "${temp}resultados electorales/bc_2007.dta", clear
rename PAN pan
rename PRI pri 
rename PRD prd
rename TotaldeVotos votos
rename Município mun
drop if mun=="  Totales"
gen year=2007
destring pan pri prd votos year, replace
keep pan pri prd votos year mun
save "${temp}clean/bc_2007.dta", replace

use "${temp}resultados electorales/bc_2010.dta", clear
keep if TOTALCASILLAS==1162 | TOTALCASILLAS==124 | TOTALCASILLAS==1934 | TOTALCASILLAS==109 | TOTALCASILLAS==559
drop if DISTRITO=="VII" | DISTRITO=="XVI"
rename PAN pan
rename PRIPVEM pri 
rename PRD prd
rename TOTALVOTOS votos
rename DISTRITO mun
gen year=2010
keep pan pri prd votos year mun
save "${temp}clean/bc_2010.dta", replace

use "${temp}resultados electorales/bc_2013.dta", clear
destring PANPRD, replace force
drop if TOTALVOTOS==.
collapse (sum) PANPRD PRIVERDE MC NOREGISTRADOS VOTONULO TOTALVOTOS LISTANOMINAL, by(MUNICIPIO)
gen year=2013, before(MUNICIPIO)
rename PANPRD pan
rename PRIVERDE pri 
rename TOTALVOTOS votos
rename MUNICIPIO mun
keep pan pri votos year mun
save "${temp}clean/bc_2013.dta", replace


use "${temp}resultados electorales/bc_2016.dta", clear
keep if MUNICIPIO=="TOTALES" | MUNICIPIO[_n+1]=="TOTALES"
replace MUNICIPIO=MUNICIPIO[_n-1] if DISTRITO==.
keep if DISTRITO==.
gen pri=PRI+R+S+T+U+V+W+X+Y+Z+AA+AB
rename PAN pan
rename PRD prd
rename TOTALVOTOS votos
rename Año year
rename MUNICIPIO mun
keep pan pri prd votos year mun
save "${temp}clean/bc_2016.dta", replace

use "${temp}resultados electorales/bc_2019.dta", clear
gen morena = MORENA + I + K + M + N + O + P + Q + R + S + T + U + V + W + X, before(MORENA)
rename PAN pan
rename PRI pri
rename PRD prd
rename TOTALVOTOS votos
rename MUNICIPIO mun
collapse (sum) pan pri prd morena votos, by(mun)
drop if mun=="TOTALES"
gen year=2019
keep year pan pri prd morena votos mun
save "${temp}clean/bc_2019.dta", replace

use "${temp}resultados electorales/bc_2021.dta", clear
gen alianza= PAN+ PRI+ PRD+ PANPRIPRD+ PANPRI+ PANPRD+ PRIPRD, before(PAN)
gen morena= MORENA+ PT+ PVEM+ PTPVEMMORENA+ PTPVEM+ PTMORENA+ PVEMMORENA, after(alianza)
rename TOTALVOTOS votos
rename MUNICIPIO mun
collapse (sum) alianza morena votos, by(mun)
gen year=2021
save "${temp}clean/bc_2021.dta", replace

****** Bcs *******
use "${temp}resultados electorales/bcs_2005.dta", clear

use "${temp}resultados electorales/bcs_2008.dta", clear

use "${temp}resultados electorales/bcs_2011.dta", clear

use "${temp}resultados electorales/bcs_2015.dta", clear

use "${temp}resultados electorales/bcs_2018_01.dta", clear
foreach number in _02 _03 _04 _05 {
	append using "${temp}resultados electorales/bcs_2018`number'.dta", force
}

****** Campeche *******
use "${temp}resultados electorales/campeche_2000.dta", clear

****** Cdmx *******
use "${temp}cdmx_2000.dta", clear
rename APC pan
rename PRI pri 
rename PRD prd
rename TOTV_CC votos
rename NOM_DEL mun
gen year=2000, before(mun)
collapse (mean) year (sum) pan pri prd votos, by(mun)
keep year mun pan pri prd votos
save "${temp}clean/cdmx_2000.dta", replace

use "${temp}cdmx_2003.dta", clear
rename PAN pan
rename PRI pri 
rename PRD prd
rename VT votos
rename DEL mun
gen year=2003, before(mun)
collapse (mean) year (sum) pan pri prd votos, by(mun)
tostring mun, replace
keep year mun pan pri prd votos
save "${temp}clean/cdmx_2003.dta", replace

use "${temp}cdmx_2006.dta", clear
rename PAN pan
rename PRIPVEM pri 
rename PRDPTCONV prd
rename VOTACIÓNTOTAL votos
rename DELEGACIÓN mun
gen year=2006, before(mun)
collapse (mean) year (sum) pan pri prd votos, by(mun)
keep year mun pan pri prd votos
save "${temp}clean/cdmx_2006.dta", replace

use "${temp}cdmx_2009.dta", clear
rename PAN pan
rename PRI pri 
rename PRD prd
rename VT votos
rename DEM mun
gen year=2009, before(mun)
tostring mun, replace
collapse (mean) year (sum) pan pri prd votos, by(mun)
keep year mun pan pri prd votos
save "${temp}clean/cdmx_2009.dta", replace

use "${temp}cdmx_2012.dta", clear
destring PRIPVEMCC1, replace force
gen pri=PRI+PRIPVEMCC1
gen prd=PRD+PRDPTMCCC2
rename PAN pan
rename VOTACIONTOTAL votos
rename DELEGACIÓN mun
gen year=2012, before(mun)
collapse (mean) year (sum) pan pri prd votos, by(mun)
keep year mun pan pri prd votos
save "${temp}clean/cdmx_2012.dta", replace

use "${temp}cdmx_2015.dta", clear
destring MORENA PRIPVEM PRDPT PRDPTNA Totaldevotos, replace ignore(" ")
gen pri=PRI+PRIPVEM
gen prd=PRD+PRDPTNA+PRDPT
rename PAN pan
rename MORENA morena
rename Totaldevotos votos
rename DELEGACIÓN mun
gen year=2015, before(mun)
drop if mun=="Total"
keep year mun pan pri prd morena votos
save "${temp}clean/cdmx_2015.dta", replace

use "${temp}cdmx_2018.dta", clear
rename VOTACION_TOTAL_PT_MOR_PES morena
rename VOTACION_TOTAL_PAN_PRD_MC alianza
rename PRI pri
rename VT votos
rename DEM mun
gen year=2018, before(mun)
collapse (mean) year (sum) alianza morena pri votos, by(mun)
keep year mun alianza morena pri votos
save "${temp}clean/cdmx_2018.dta", replace

****** Chiapas *******
use "${temp}resultados electorales/chiapas_2001.dta", clear

use "${temp}resultados electorales/chiapas_2004.dta", clear

use "${temp}resultados electorales/chiapas_2007.dta", clear

use "${temp}resultados electorales/chiapas_2010.dta", clear

use "${temp}resultados electorales/chiapas_2012.dta", clear

use "${temp}resultados electorales/chiapas_2015.dta", clear

use "${temp}resultados electorales/chiapas_2016.dta", clear

use "${temp}resultados electorales/chiapas_2021.dta", clear

****** Chihuahua *******
use "${temp}resultados electorales/chihuahua_2001.dta", clear

use "${temp}resultados electorales/chihuahua_2002.dta", clear

use "${temp}resultados electorales/chihuahua_2004.dta", clear

use "${temp}resultados electorales/chihuahua_2007.dta", clear

use "${temp}resultados electorales/chihuahua_2010.dta", clear

use "${temp}resultados electorales/chihuahua_2013_1.dta", clear

use "${temp}resultados electorales/chihuahua_2013_2.dta", clear

use "${temp}resultados electorales/chihuahua_2016.dta", clear

use "${temp}resultados electorales/chihuahua_2018.dta", clear

use "${temp}resultados electorales/chihuahua_2021.dta", clear

****** Coahuila *******
use "${temp}resultados electorales/coahuila_1999.dta", clear

use "${temp}resultados electorales/coahuila_2002.dta", clear

use "${temp}resultados electorales/coahuila_2005.dta", clear

use "${temp}resultados electorales/coahuila_2006.dta", clear

use "${temp}resultados electorales/coahuila_2009.dta", clear

use "${temp}resultados electorales/coahuila_2010.dta", clear

use "${temp}resultados electorales/coahuila_2013.dta", clear

use "${temp}resultados electorales/coahuila_2017.dta", clear

use "${temp}resultados electorales/coahuila_2018.dta", clear

use "${temp}resultados electorales/coahuila_2021.dta", clear

****** Colima *******
use "${temp}resultados electorales/colima_2000.dta", clear

use "${temp}resultados electorales/colima_2003.dta", clear

use "${temp}resultados electorales/colima_2006.dta", clear

use "${temp}resultados electorales/colima_2009.dta", clear

use "${temp}resultados electorales/colima_2012.dta", clear

use "${temp}resultados electorales/colima_2015.dta", clear

use "${temp}resultados electorales/colima_2018.dta", clear

use "${temp}resultados electorales/colima_2021.dta", clear

****** Durango *******
use "${temp}resultados electorales/durango_2004_01.dta", clear
foreach number in _02 _03 _04 _05 _06 _07 _08 _09 _10 _11 _12 _13 _14 _15 _16 _17 _18 _19 _20 _21 _22 _23 _24 _25 _26 _27 _28 _29 _30 _31 _32 _33 _34 _35 _36 _37 _38 _39 {
	append "${temp}resultados electorales/durango_2004`number'.dta", force
}

use "${temp}resultados electorales/durango_2007_01.dta", clear
foreach number in _02 _03 _04 _05 _06 _07 _08 _09 _10 _11 _12 _13 _14 _15 _16 _17 _18 _19 _20 _21 _22 _23 _24 _25 _26 _27 _28 _29 _30 _31 _32 _33 _34 _35 _36 _37 {
	append "${temp}resultados electorales/durango_2007`number'.dta", force
}

use "${temp}resultados electorales/durango_2010_01.dta", clear
foreach number in _02 _03 _04 _05 _06 _07 _08 _09 _10 _11 _12 _13 _14 _15 _16 _17 _18 _19 _20 _21 _22 _23 _24 _25 _26 _27 _28 _29 _30 _31 _32 _33 _34 _35 _36 _37 _38 _39 {
	append "${temp}resultados electorales/durango_2010`number'.dta", force
}
use "${temp}resultados electorales/durango_2013.dta", clear

use "${temp}resultados electorales/durango_2019.dta", clear

****** Edomex *******
use "${temp}resultados electorales/edomex_2000.dta", clear
rename PAN pan
rename PRI pri 
rename PRD prd
rename TOTAL votos
rename MUNICIPIO mun
gen year=2000, before(mun)
keep year mun pan pri prd votos
save "${temp}clean/edomex_2000.dta", replace

use "${temp}resultados electorales/edomex_2003.dta", clear
rename PAN pan
rename APTPRIPVEM pri 
rename PRD prd
rename TOTAL votos
rename B mun
gen year=2003, before(mun)
keep year mun pan pri prd votos
destring pan pri prd votos, replace
save "${temp}clean/edomex_2003.dta", replace

use "${temp}resultados electorales/edomex_2006.dta", clear
foreach variable in PAN PRI ALIANZAPORMEXICO PRD PT CONVERGENCIA {
	replace `variable'=0 if `variable'==.
}
rename PAN pan
gen pri=PRI+ALIANZAPORMEXICO 
gen prd=PRD+PT+CONVERGENCIA
rename VOTACIÓN votos
rename CABECERA mun
gen year=2006, before(mun)
keep year mun pan pri prd votos
save "${temp}clean/edomex_2006.dta", replace

use "${temp}resultados electorales/edomex_2009.dta", clear
rename MUNICIPIO mun
rename Votación votos
egen pri=rowmax(PRIPVEMNAPSDPFD PRI)
egen prd=rowmax(PRDPT PRD PT)
egen pan=rowmax(PANC PAN)
gen year=2009, before(mun)
keep year mun pan pri prd votos
save "${temp}clean/edomex_2009.dta", replace

use "${temp}resultados electorales/edomex_2012.dta", clear
rename MUNICIPIO mun
rename PAN pan
rename PRIPVEMNA pri
rename VotaciónTotal votos
egen prd=rowmax(PRD PT MC PRDPTMC PRDPT PRDMC PTMC)
gen year=2012, before(mun)
keep mun pan pri prd year votos
save "${temp}clean/edomex_2012.dta", replace

use "${temp}resultados electorales/edomex_2015.dta", clear
rename MUNICIPIO mun
rename TOTAL votos
rename MORENA morena
egen prd=rowmax(PRD PT)
egen pan=rowmax(PAN PANPT)
egen pri=rowmax(PRIPVEMNA PRI)
gen year=2015, before(mun)
keep mun pan pri prd morena year votos
save "${temp}clean/edomex_2015.dta", replace

use "${temp}resultados electorales/edomex_2018.dta", clear
destring PRD, replace
rename MUNICIPIO mun
rename TOTAL_VOTOS votos
rename PRI pri
egen morena=rowmax(PT_MORENA_ES PT MORENA ES)
egen alianza=rowmax(PAN PAN_PRD_MC PRD MC)
gen year=2018, before(mun)
keep mun alianza pri morena votos year
save "${temp}clean/edomex_2018.dta", replace

use "${temp}resultados electorales/edomex_2021.dta", clear
rename MUNICIPIO mun 
rename VOTACIÓN_TOTAL votos
egen alianza=rowmax(PAN PRI PRD COALICIÓNPANPRIPRD COALICIÓNPANPRI)
egen morena=rowmax(PT MORENA NAEM COALICIÓNPTMORENANAEM COALICIÓNPTMORENA CANDIDATURACOMÚNPTMORENANAEM)
gen year=2021, before(mun)
keep mun alianza morena year votos
save "${temp}clean/edomex_2021.dta", replace

****** Guerrero *******
use "${temp}resultados electorales/gro_2002.dta", clear

use "${temp}resultados electorales/gro_2005.dta", clear

use "${temp}resultados electorales/gro_2008.dta", clear

use "${temp}resultados electorales/gro_2009.dta", clear

use "${temp}resultados electorales/gro_2012.dta", clear

use "${temp}resultados electorales/gro_2015.dta", clear

use "${temp}resultados electorales/gro_2017.dta", clear

use "${temp}resultados electorales/gro_2021.dta", clear

****** Guanajuato *******
use "${temp}resultados electorales/gto_2000.dta", clear

use "${temp}resultados electorales/gto_2003.dta", clear

use "${temp}resultados electorales/gto_2006.dta", clear

use "${temp}resultados electorales/gto_2009.dta", clear

use "${temp}resultados electorales/gto_2012.dta", clear

use "${temp}resultados electorales/gto_2015.dta", clear

use "${temp}resultados electorales/gto_2018.dta", clear

use "${temp}resultados electorales/gto_2021.dta", clear

****** Hidalgo *******
use "${temp}resultados electorales/hidalgo_2008.dta", clear

use "${temp}resultados electorales/hidalgo_2011.dta", clear

use "${temp}resultados electorales/hidalgo_2012.dta", clear

use "${temp}resultados electorales/hidalgo_2016.dta", clear

use "${temp}resultados electorales/hidalgo_2020.dta", clear

****** Jalisco *******
use "${temp}resultados electorales/jalisco_2000.dta", clear

use "${temp}resultados electorales/jalisco_2003.dta", clear

use "${temp}resultados electorales/jalisco_2004.dta", clear

use "${temp}resultados electorales/jalisco_2006.dta", clear

use "${temp}resultados electorales/jalisco_2007.dta", clear

use "${temp}resultados electorales/jalisco_2009.dta", clear

use "${temp}resultados electorales/jalisco_2009_01.dta", clear

use "${temp}resultados electorales/jalisco_2012.dta", clear

use "${temp}resultados electorales/jalisco_2015.dta", clear

use "${temp}resultados electorales/jalisco_2018.dta", clear

use "${temp}resultados electorales/jalisco_2021.dta", clear

****** Michoacan *******
use "${temp}resultados electorales/michoacan_2001.dta", clear

use "${temp}resultados electorales/michoacan_2004.dta", clear

use "${temp}resultados electorales/michoacan_2005.dta", clear

use "${temp}resultados electorales/michoacan_2007.dta", clear

use "${temp}resultados electorales/michoacan_2008.dta", clear

use "${temp}resultados electorales/michoacan_2011.dta", clear

use "${temp}resultados electorales/michoacan_2012.dta", clear

use "${temp}resultados electorales/michoacan_2015.dta", clear

use "${temp}resultados electorales/michoacan_2016_01.dta", clear

use "${temp}resultados electorales/michoacan_2016_02.dta", clear

****** Morelos *******
use "${temp}resultados electorales/morelos_2000.dta", clear

use "${temp}resultados electorales/morelos_2001.dta", clear

use "${temp}resultados electorales/morelos_2003.dta", clear

use "${temp}resultados electorales/morelos_2006.dta", clear

use "${temp}resultados electorales/morelos_2009.dta", clear

use "${temp}resultados electorales/morelos_2012.dta", clear

use "${temp}resultados electorales/morelos_2015.dta", clear

use "${temp}resultados electorales/morelos_2018.dta", clear

use "${temp}resultados electorales/morelos_2021.dta", clear

****** Nayarit *******
use "${temp}resultados electorales/nayarit_1999.dta", clear

use "${temp}resultados electorales/nayarit_2002.dta", clear

use "${temp}resultados electorales/nayarit_2005.dta", clear

use "${temp}resultados electorales/nayarit_2008.dta", clear

use "${temp}resultados electorales/nayarit_2011.dta", clear

use "${temp}resultados electorales/nayarit_2014.dta", clear

use "${temp}resultados electorales/nayarit_2017.dta", clear

use "${temp}resultados electorales/nayarit_2021.dta", clear

****** Puebla *******
use "${temp}resultados electorales/puebla_2001.dta", clear

use "${temp}resultados electorales/puebla_2002.dta", clear

use "${temp}resultados electorales/puebla_2004.dta", clear

use "${temp}resultados electorales/puebla_2005.dta", clear

use "${temp}resultados electorales/puebla_2010.dta", clear

use "${temp}resultados electorales/puebla_2011.dta", clear

use "${temp}resultados electorales/puebla_2013.dta", clear

use "${temp}resultados electorales/puebla_2014.dta", clear

use "${temp}resultados electorales/puebla_2017.dta", clear

use "${temp}resultados electorales/puebla_2021.dta", clear

****** Queretaro *******
use "${temp}resultados electorales/qro_2000.dta", clear

use "${temp}resultados electorales/qro_2003.dta", clear

use "${temp}resultados electorales/qro_2006.dta", clear

use "${temp}resultados electorales/qro_2009.dta", clear

use "${temp}resultados electorales/qro_2012.dta", clear

use "${temp}resultados electorales/qro_2015.dta", clear

use "${temp}resultados electorales/qro_2018.dta", clear

use "${temp}resultados electorales/qro_2021.dta", clear

****** Quintana Roo *******
use "${temp}resultados electorales/qroo_1999.dta", clear

use "${temp}resultados electorales/qroo_2002.dta", clear

use "${temp}resultados electorales/qroo_2005.dta", clear

use "${temp}resultados electorales/qroo_2008.dta", clear

use "${temp}resultados electorales/qroo_2009.dta", clear

use "${temp}resultados electorales/qroo_2010.dta", clear

use "${temp}resultados electorales/qroo_2016.dta", clear

use "${temp}resultados electorales/qroo_2018.dta", clear

use "${temp}resultados electorales/qroo_2021.dta", clear

****** Sinaloa *******
use "${temp}resultados electorales/sinaloa_2001.dta", clear

use "${temp}resultados electorales/sinaloa_2010.dta", clear

use "${temp}resultados electorales/sinaloa_2013.dta", clear

use "${temp}resultados electorales/sinaloa_2016.dta", clear

use "${temp}resultados electorales/sinaloa_2018.dta", clear

use "${temp}resultados electorales/sinaloa_2021.dta", clear

****** SLP *******
use "${temp}resultados electorales/slp_2000.dta", clear

use "${temp}resultados electorales/slp_2003.dta", clear

use "${temp}resultados electorales/slp_2006.dta", clear

use "${temp}resultados electorales/slp_2009.dta", clear

use "${temp}resultados electorales/slp_2012.dta", clear

use "${temp}resultados electorales/slp_2018.dta", clear

****** Sonora *******
use "${temp}resultados electorales/sonora_2000.dta", clear

use "${temp}resultados electorales/sonora_2006.dta", clear

use "${temp}resultados electorales/sonora_2009.dta", clear

use "${temp}resultados electorales/sonora_2012.dta", clear

use "${temp}resultados electorales/sonora_2015.dta", clear

use "${temp}resultados electorales/sonora_2018.dta", clear

use "${temp}resultados electorales/sonora_2021.dta", clear

****** Tabasco *******
use "${temp}resultados electorales/tabasco_2006.dta", clear

use "${temp}resultados electorales/tabasco_2014.dta", clear

****** Tamaulipas *******
use "${temp}resultados electorales/tamaulipas_2001.dta", clear

use "${temp}resultados electorales/tamaulipas_2004.dta", clear

use "${temp}resultados electorales/tamaulipas_2007.dta", clear

use "${temp}resultados electorales/tamaulipas_2010.dta", clear

use "${temp}resultados electorales/tamaulipas_2013.dta", clear

use "${temp}resultados electorales/tamaulipas_2016.dta", clear

use "${temp}resultados electorales/tamaulipas_2021.dta", clear

****** Tlaxcala *******
use "${temp}resultados electorales/tlaxcala_2001.dta", clear

use "${temp}resultados electorales/tlaxcala_2002.dta", clear

use "${temp}resultados electorales/tlaxcala_2004.dta", clear

use "${temp}resultados electorales/tlaxcala_2007.dta", clear

use "${temp}resultados electorales/tlaxcala_2010.dta", clear

use "${temp}resultados electorales/tlaxcala_2013.dta", clear

use "${temp}resultados electorales/tlaxcala_2016.dta", clear

use "${temp}resultados electorales/tlaxcala_2017.dta", clear

use "${temp}resultados electorales/tlaxcala_2021.dta", clear

****** Veracruz *******
use "${temp}resultados electorales/veracruz_2003.dta", clear

use "${temp}resultados electorales/veracruz_2005.dta", clear

use "${temp}resultados electorales/veracruz_2010.dta", clear

use "${temp}resultados electorales/veracruz_2013.dta", clear

use "${temp}resultados electorales/veracruz_2018.dta", clear

use "${temp}resultados electorales/veracruz_2022.dta", clear

****** Yucatan *******
use "${temp}resultados electorales/yucatan_2001.dta", clear

use "${temp}resultados electorales/yucatan_2004.dta", clear

use "${temp}resultados electorales/yucatan_2007.dta", clear

use "${temp}resultados electorales/yucatan_2010.dta", clear

use "${temp}resultados electorales/yucatan_2015.dta", clear

use "${temp}resultados electorales/yucatan_2018.dta", clear

use "${temp}resultados electorales/yucatan_2021.dta", clear

****** Zacatecas *******
use "${temp}resultados electorales/zacatecas_2007.dta", clear

use "${temp}resultados electorales/zacatecas_2010.dta", clear

use "${temp}resultados electorales/zacatecas_2016.dta", clear

use "${temp}resultados electorales/zacatecas_2018.dta", clear

use "${temp}resultados electorales/zacatecas_2021.dta", clear

****** Nuevo Leon *******

****** Oaxaca *******









use "${temp}clean/cdmx_2000.dta", clear
append using "${temp}clean/cdmx_2003.dta", force
append using "${temp}clean/cdmx_2006.dta"
append using "${temp}clean/cdmx_2009.dta"
append using "${temp}clean/cdmx_2012.dta"
append using "${temp}clean/cdmx_2015.dta"
append using "${temp}clean/cdmx_2018.dta"
order year mun pan pri prd alianza morena votos

egen winner=rowmax(pan pri prd alianza morena)
foreach variable in pan pri prd alianza morena {
	replace `variable'=1 if `variable'==.
	replace `variable'=. if `variable'==winner
}
egen second=rowmax(pan pri prd alianza morena)
foreach variable in pan pri prd alianza morena {
		replace `variable'=winner if `variable'==.
		replace `variable'=. if `variable'==1
}
gen margin=abs(winner-second)/votos
gen close=margin<=0.05
gen federal_winner=0
if year<2012 {
	replace federal_winner=1 if pan==winner 
}
if year>=2012 & year<2018 {
	replace federal_winner=1 if pri==winner 
}
if year>=2018{
	replace federal_winner=1 if morena==winner 
}
gen state="Ciudad de México", before(mun)
save "${temp}cdmx.dta", replace


use "${temp}clean/bc_2001.dta", clear
append using "${temp}clean/bc_2004.dta"
append using "${temp}clean/bc_2007.dta"
append using "${temp}clean/bc_2010.dta"
append using "${temp}clean/bc_2013.dta"
append using "${temp}clean/bc_2016.dta"
append using "${temp}clean/bc_2019.dta"
append using "${temp}clean/bc_2021.dta"
order year mun pan pri prd alianza morena votos
egen winner=rowmax(pan pri prd alianza morena)
foreach variable in pan pri prd alianza morena {
	replace `variable'=1 if `variable'==.
	replace `variable'=. if `variable'==winner
}
egen second=rowmax(pan pri prd alianza morena)
foreach variable in pan pri prd alianza morena {
		replace `variable'=winner if `variable'==.
		replace `variable'=. if `variable'==1
}
gen margin=abs(winner-second)/votos
gen close=margin<=0.05
gen federal_winner=0
if year<2012 {
	replace federal_winner=1 if pan==winner 
}
if year>=2012 & year<2018 {
	replace federal_winner=1 if pri==winner 
}
if year>=2018{
	replace federal_winner=1 if morena==winner 
}
gen state="Baja California", before(mun)
save "${temp}bc.dta", replace


use "${temp}clean/edomex_2000.dta", clear
append using "${temp}clean/edomex_2003.dta"
append using "${temp}clean/edomex_2006.dta"
append using "${temp}clean/edomex_2009.dta"
append using "${temp}clean/edomex_2012.dta"
append using "${temp}clean/edomex_2015.dta"
append using "${temp}clean/edomex_2018.dta"
append using "${temp}clean/edomex_2021.dta"
order year mun pan pri prd alianza morena votos

egen winner=rowmax(pan pri prd alianza morena)
foreach variable in pan pri prd alianza morena {
	replace `variable'=1 if `variable'==.
	replace `variable'=. if `variable'==winner
}
egen second=rowmax(pan pri prd alianza morena)
foreach variable in pan pri prd alianza morena {
		replace `variable'=winner if `variable'==.
		replace `variable'=. if `variable'==1
}
gen margin=abs(winner-second)/votos
gen close=margin<=0.05
gen federal_winner=0
if year<2012 {
	replace federal_winner=1 if pan==winner 
}
if year>=2012 & year<2018 {
	replace federal_winner=1 if pri==winner 
}
if year>=2018{
	replace federal_winner=1 if morena==winner 
}
gen state="México", before(mun)
save "${temp}edomex.dta", replace

use "${temp}bc.dta", clear
append using "${temp}cdmx.dta"
append using "${temp}edomex.dta"
keep if close==1
replace margin=-margin if federal_winner==0

*Gen a string with the format: "state - municipality" that will serve for merging.
gen muni = lower(ustrto(ustrnormalize(mun, "nfd"), "ascii", 2))
gen aux= state + " - " + muni
gen muns=lower(aux)
order year muns state mun
drop aux
save "${data}electoral.dta", replace
