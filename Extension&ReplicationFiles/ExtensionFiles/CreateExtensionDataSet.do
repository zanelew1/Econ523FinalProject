***************
*Prashant Bista and Connor Lewis
*Econ 523 Final Project
*12 May 26
***************

/* This do file creates the dataset used for our extension. In the author's replication file, he stores Final_HHLevel.dta which is a dataset of the compiled aggregations of household expenditure. He created binary variables to indicate individuals' housing tenure status and age category and then collapses those into mean expenditure in each quarter for each group. 

Here we create new binary variables using existing data to investigate heterogeneous effects along other groups. We look at Black vs. White vs. other races, single households vs. 2-person vs. family (3+), and level of education: no hs degree vs. hs degree vs. college degree vs. advanced degree. 

First, we load their dataset and add new binary variables. Then we use our binaries to collapse observations in the same group into quarterly averages. Then we export this final dataset into an excel workbook so we can use it in R for linear projections. :)
*/
****
*Set up environment 
****

*clear environment
clear all
capture log close

*** set directories 
global route "/Users/connorlewis_macbookpro/Documents/Personal Filing System/Permanent/Education Connor/2025AUG-2026MAY_MA Economics_UTK/01_Coursework/2026_Spring/Econ_523_Applied_Macroeconomic_Theory/Assignments/FinalProj"
local ext "${route}/ExtensionCode"
local temp "`ext'/Temp/"

cd "`ext'"

*****
*Step 1: Load the data set
*****

use Final_HHLevel.dta, clear

*****
*Step 2: Generate new binary variables
*****

*generate indicators for racial groups
gen Black = (REF_RACE == 2) // generates indicator variable for race is Black 
gen White = (REF_RACE == 1) // generates indicator variable for race is white
gen OtherRace = (REF_RACE > 2) // generates indicator variable for race is not Black or white

*generate indicators for education groups
gen no_hs = inlist(EDUC_REF, 0, 1, 2, 7) //generates indicator variable for education that did not result in a high school degree
gen no_college = inlist(EDUC_REF, 3, 4) //generates indicator variable for education that achieved a hs degree but no college degree
gen college = inlist(EDUC_REF, 5, 6) //generates indicator variable for education that is a college degree or more

*generate indicators for  family size
gen single = (FAM_SIZE == 1) //generates indicator variable for a single person household
gen two = (FAM_SIZE == 2) //generates indicator variable for a two person household 
gen family = (FAM_SIZE > 2) //generates indicator variable for a family more than 2

*****
*Step 3: Create a time series of the mean nondurable expenditure of each group 
*****

*as a baseline collapse nondurable consumption for all individuals
preserve //temporarily store the orginal dataset and clear memory to create a new dataset
collapse (mean) ndconr_pc, by(quarter)
rename ndconr_pc ndcon_all //rename ndconr_pc to facilitate merging in step 4
save "`temp'baseline_all.dta", replace //save the new dataset to merge later
restore //restores the original data set so we can make more new time series sets

*collapse racial groups
preserve //temporarily store the orginal dataset and clear memory to create a new dataset
collapse (mean) ndconr_pc, by(quarter Black) //Race is Black
keep if (Black == 1)
drop Black
rename ndconr_pc race_ndcon_black //rename ndconr_pc to facilitate merging in step 4
save "`temp'black.dta", replace //save the new dataset to merge later
restore //restores the original data set so we can make more new time series sets

preserve //temporarily store the orginal dataset and clear memory to create a new dataset
collapse (mean) ndconr_pc, by(quarter White) //Race is White
keep if (White == 1)
drop White
rename ndconr_pc race_ndcon_white //rename ndconr_pc to facilitate merging in step 4
save "`temp'white.dta", replace //save the new dataset to merge later
restore //restores the original data set so we can make more new time series sets

preserve //temporarily store the orginal dataset and clear memory to create a new dataset
collapse (mean) ndconr_pc, by(quarter OtherRace) //Race is other
keep if (OtherRace == 1)
drop OtherRace
rename ndconr_pc race_ndcon_otherRace //rename ndconr_pc to facilitate merging in step 4
save "`temp'otherRace.dta", replace //save the new dataset to merge later
restore //restores the original data set so we can make more new time series sets



*collapse education groups
preserve //temporarily store the orginal dataset and clear memory to create a new dataset
collapse (mean) ndconr_pc, by(quarter no_hs) //no hs degree group
keep if (no_hs == 1)
drop no_hs
rename ndconr_pc educ_ndcon_noHS //rename ndconr_pc to facilitate merging in step 4
save "`temp'noHS.dta", replace //save the new dataset to merge later
restore //restores the original data set so we can make more new time series sets

preserve //temporarily store the orginal dataset and clear memory to create a new dataset
collapse (mean) ndconr_pc, by(quarter no_college) // hs degree but no college degree group
keep if (no_college == 1)
drop no_college
rename ndconr_pc educ_ndcon_HS //rename ndconr_pc to facilitate merging in step 4
save "`temp'HS.dta", replace //save the new dataset to merge later
restore //restores the original data set so we can make more new time series sets

preserve //temporarily store the orginal dataset and clear memory to create a new dataset
collapse (mean) ndconr_pc, by(quarter college) // college degree 
keep if (college == 1)
drop college
rename ndconr_pc educ_ndcon_college //rename ndconr_pc to facilitate merging in step 4
save "`temp'college.dta", replace //save the new dataset to merge later
restore //restores the original data set so we can make more new time series sets



*collapse family size groups
preserve //temporarily store the orginal dataset and clear memory to create a new dataset
collapse (mean) ndconr_pc, by(quarter single) //single person household group
keep if (single == 1)
drop single
rename ndconr_pc size_ndcon_single //rename ndconr_pc to facilitate merging in step 4
save "`temp'single.dta", replace //save the new dataset to merge later
restore //restores the original data set so we can make more new time series sets

preserve //temporarily store the orginal dataset and clear memory to create a new dataset
collapse (mean) ndconr_pc, by(quarter two) //two person family
keep if (two == 1)
drop two
rename ndconr_pc size_ndcon_two //rename ndconr_pc to facilitate merging in step 4
save "`temp'two.dta", replace //save the new dataset to merge later
restore //restores the original data set so we can make more new time series sets

preserve //temporarily store the orginal dataset and clear memory to create a new dataset
collapse (mean) ndconr_pc, by(quarter family) //family size greater than 2 group
keep if (family == 1)
drop family
rename ndconr_pc size_ndcon_fam //rename ndconr_pc to facilitate merging in step 4
save "`temp'fam.dta", replace //save the new dataset to merge later
restore //restores the original data set so we can make more new time series sets


*****
*Step 4: Merge the individual datasets into a single wide time series
*****

*now we load the baseline dataset. Then we will merge all of the other consumption means for each group based on the quarter, creating a single wide time series with each group
use "`temp'baseline_all.dta", clear

merge 1:1 quarter using "`temp'black.dta",  nogenerate keep(match)
merge 1:1 quarter using "`temp'white.dta",  nogenerate keep(match)
merge 1:1 quarter using "`temp'otherRace.dta",  nogenerate keep(match)
merge 1:1 quarter using "`temp'noHS.dta",  nogenerate keep(match)
merge 1:1 quarter using "`temp'HS.dta",  nogenerate keep(match)
merge 1:1 quarter using "`temp'college.dta",  nogenerate keep(match)
merge 1:1 quarter using "`temp'single.dta",  nogenerate keep(match)
merge 1:1 quarter using "`temp'two.dta",  nogenerate keep(match)
merge 1:1 quarter using "`temp'fam.dta",  nogenerate keep(match)

save extension_timeseries.dta, replace

*****
*Step 5: Export long time series as excel file so we can run LP in R
*****

use extension_timeseries.dta, clear
export excel using "extension_timeseries.xlsx", firstrow(variables) replace
