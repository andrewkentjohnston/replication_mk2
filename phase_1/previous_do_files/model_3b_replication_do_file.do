** model_2b_replication_do_file.do
* Description: Cuervo-Cazurra and Genc (2008) replication - model 2b
* Author: Andrew Kent Johnston
* Date: December 9, 2023

* Clear the workspace
clear all
set more off

* ----- Data Import -----
import delimited using "../main_dataset.csv", clear

* ----- Data Cleaning and Filtering -----
* Dropping entities with incomplete observations for both years
egen row_missing = rowmiss(perc_developing_excl_col_power c1 c2 c3 c4 c5 c6 gni_per_cap perc_roads_paved phones_per_1000 mne_from_bordering_country mne_from_former_col_power)
bysort country: egen total_missing = total(row_missing)
drop if total_missing > 0

* Renaming variables
rename c1 voice_accountability
rename c2 pol_stab_abs_violence
rename c3 gov_effectiveness
rename c4 reg_quality
rename c5 rule_of_law
rename c6 control_corruption
rename gni_per_cap gni_capita
rename perc_roads_paved roads_paved_pct
rename phones_per_1000 phones_capita
rename perc_developing_mnes prev_dev_country_MNEs
rename perc_developing_excl_nat_res prev_dev_MNEs_excl_nat_res
rename perc_developing_excl_col_power prev_dev_MNEs_excl_col_pow
rename mne_from_bordering_country geographic_proximity
rename mne_from_former_col_power colonial_link

* Generating a numeric ID for countries
egen country_id = group(country)

* ----- Data Analysis -----
* Declaring the data as panel data using the new country ID
xtset country_id year

* Running a random effects panel Tobit model with bounds
xttobit prev_dev_MNEs_excl_col_pow voice_accountability pol_stab_abs_violence gov_effectiveness reg_quality rule_of_law control_corruption gni_capita roads_paved_pct phones_capita geographic_proximity, ll(0) ul(100) re

* Store the results of the random effects model
estimates store re_model

* Estimating a pooled Tobit model
tobit prev_dev_MNEs_excl_col_pow voice_accountability pol_stab_abs_violence gov_effectiveness reg_quality rule_of_law control_corruption gni_capita roads_paved_pct phones_capita geographic_proximity, ll(0) ul(100)

* Store the results of the pooled Tobit model for later comparison
estimates store pooled_model

* ----- Output Results Section -----
* Export random effects model results to a Word-compatible table with additional statistics
estimates restore re_model
local chi2_re = e(chi2)
local ll_re = e(ll)
outreg2 using "../results/model_3b_random_effects_results.doc", replace word addtext("Wald chi2", `chi2_re', "Log likelihood", `ll_re')

* Export pooled model results to a different Word-compatible table with additional statistics
estimates restore pooled_model
local chi2_pooled = e(chi2)
local ll_pooled = e(ll)
outreg2 using "../results/model_3b_pooled_tobit_results.doc", replace word addtext("LR chi2", `chi2_pooled', "Log likelihood", `ll_pooled')

* End of do-file
