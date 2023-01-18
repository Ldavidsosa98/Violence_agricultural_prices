use "${data}products_prices.dta", clear
*Agricultural and livestock data
label variable superficie_sembrada "Ha"
label variable superficie_cosechada "Ha"
label variable superficie_siniestrada "Ha"
label variable produccion "Ton"
label variable rendimiento "Ton/Ha"
label variable precio_medio_rural "$/Ton"
label variable valor_produccion "Thousands of pesos"

label variable produccion "Ton or thousands of liters"
label variable produccion_pie "Ton"
label variable precio_promedio "$/Kg"
label variable precio_promedio_pie "$/Kg"
label variable valor_produccion "Thousands of pesos"
label variable valor_produccion_pie "Thousands of pesos"
label variable peso_promedio_canal "Kg"
label variable peso_promedio_pie "Kg"
label variable cabezas "Heads or tails"
save "${data}products_prices_labeled.dta", replace


use "${data}fish.dta", clear
label variable peso_vivo "Ton"
label variable peso_desembarcado "Ton"
label variable precio_pie_de_playa "$/Kg"
label variable valor_produccion "Thousands of pesos"
save "${data}fish_labeled.dta", replace