** model_2b_replication_do_file.do
* Description: Cuervo-Cazurra and Genc (2008) replication - model 2b
* Author: Andrew Kent Johnston
* Date: May 31, 2024

* Clear the workspace
clear all
set more off

* ----- Data Import -----
import delimited using "main_dataset.csv", clear

* ----- Data Cleaning and Filtering -----
* Dropping entities with incomplete observations for both years
egen row_missing = rowmiss(perc_emnes_excl_nat_res c1 c2 c3 c4 c5 c6 gni_per_capita roads_paved_pct phones_per_1000 geographic_proximity colonial_link)
bysort country: egen total_missing = total(row_missing)
drop if total_missing > 0

* Renaming variables
rename c1 voice_and_accountability
rename c2 pol_stab_abs_violence
rename c3 government_effectiveness
rename c4 regulatory_quality
rename c5 rule_of_law
rename c6 control_of_corruption


* Generating a numeric ID for countries
egen country_id = group(country)

* ----- Data Analysis -----
* Declaring the data as panel data using the new country ID
xtset country_id year

* Running a random effects panel Tobit model with bounds
xttobit perc_emnes_excl_nat_res voice_and_accountability pol_stab_abs_violence government_effectiveness regulatory_quality rule_of_law control_of_corruption gni_per_capita roads_paved_pct phones_per_1000 geographic_proximity colonial_link, ll(0) ul(100) re

* Store the results of the random effects model
estimates store re_model

* Estimating a pooled Tobit model
tobit perc_emnes_excl_nat_res voice_and_accountability pol_stab_abs_violence government_effectiveness regulatory_quality rule_of_law control_of_corruption gni_per_capita roads_paved_pct phones_per_1000 geographic_proximity colonial_link, ll(0) ul(100)

* Store the results of the pooled Tobit model for later comparison
estimates store pooled_model

* ----- Output Results Section -----
* Export random effects model results to a Word-compatible table with additional statistics
estimates restore re_model
local chi2_re = e(chi2)
local ll_re = e(ll)
outreg2 using "./results/model_2b_random_effects_results.doc", replace word addtext("Wald chi2", `chi2_re', "Log likelihood", `ll_re')

* Export pooled model results to a different Word-compatible table with additional statistics
estimates restore pooled_model
local chi2_pooled = e(chi2)
local ll_pooled = e(ll)
outreg2 using "./results/model_2b_pooled_tobit_results.doc", replace word addtext("LR chi2", `chi2_pooled', "Log likelihood", `ll_pooled')

* Summary Statistics
summarize

* Correlation Matrix
pwcorr, star(0.05)

* Save the output to a log file
log using model_2b_summary_stats_and_corr_matrix.log, replace
summarize
pwcorr, star(0.05)
log close

* Save the output to a text file
capture noisily {
    outsheet using model_2b_summary_stats_and_corr_matrix.txt, replace
}

* Save the output to a Word file
capture noisily {
    outreg2 using model_2b_summary_stats_and_corr_matrix.doc, replace word
}


* End of do-file
