Replication files for Econ 523 Final Project: 
Replication and extension of Pidkuyko 2023 "Heterogeneous Spillovers of Housing Credit Policy"

14 May 2026
Prashant Bista and Connor Lewis

----------------------------------------------------------------------

This repository has five folders:

(1) Extension&ReplicationFiles -- Contains code and data for our basic replication and extension of the paper.

(2) GradingRubric -- Contains the grading rubric published for this assignment.

(3) OriginalPaper -- Contains a PDF of Pidkuyko 2023 and the appendix.

(4) ReplicationPresentation -- Contains the slide deck for our final presentation.

(5) ReplicationReport -- Contains the our final report for this assignment.

----------------------------------------------------------------------
The author uses three main sources of data: Consumer Expenditure Survey (available from th BLS and ICPSR), Survey of Consumer Finances (available from the Federal Reserve), and a set of macroeconomic variables (available from FRED and the author's calculations). Appendix A provides a description of individual sources and variable definitions. Additional data dictionaries can be found at source websites.  

The remainder of this read me will explain how to replicate our work.

NOTE: The Final_HHLevel.dta file is too large to store in this repository, so the user must extract it from the researcher's full replication package. One can access the researcher's full replication package at this link: https://ideas.repec.org/c/red/ccodes/21-100.html#:~:text=Programming%20Language-,STATA,-R . The researcher's full replication package is much larger than what we ultimately use. From their package, we keep only the files in their folder "R". They also have files for recreating their data, but some necessary scripts are missing. Additionally, we revise some of their R code so that the replication runs correctly. 

Extension&ReplicationFiles folder contains two folder:

  (a) ReplicationFiles
  
  (b) ExtensionFiles

----------------------------------------------------------------------
Basic Replication
----------------------------------------------------------------------
ReplicationFiles are the files we use to replicate the researcher's work. This folder contains the same files as the folder "R" in the original replication package, however we revised their code. 

-all_agency.xlsx is an excel workbook that contains all of the macro variables used for the IV-LP

-all_consumption.xlsx is an excel workbook that contains all consumption data used for the IV-LP and is the main thrust of the paper

-graphs is a folder that contains the output of the IRFs, allowing one to create the graphs in excel

-regression.R is a script that takes the data, estimates the IV_LP models, and produces IRF graphs in the R environment

Replication: Open regression.R. Update the working directory. Run the do file.

----------------------------------------------------------------------
Extension Replication
----------------------------------------------------------------------
ExtensionFiles are the files we use to extend the researcher's work. This folder contains a Stata Do file, an R script, output folders, and an initial dataset. 

!!! In order to replicate our extension, you must download the file Final_HHLevel.dta from the researcher's full replication package and add it to this folder!!!

-all_agency.xlsx is an excel workbook that contains all of the macro variables used for the IV-LP. It is the same as in the ReplicationFiles folder

-CreateExtensionDataSet.do is a Stata Do file. It use the consumer expenditure survey data compiled by the researcher to create a new time series for our analysis. This Do file creates new groups based on racial, family size, and education characteristics and collapse observations to create a wide time series of mean nondurable expenditure in each group. 

-extensionLPScript.R is an R Script that adjusts the researcher's orginal script to create IRF's from IV-LPs on our new groups. 

-graphs is a folder that stores output from the script. This output consists of Excel workbooks that contain the information to make IRF graphs. It is a vestigial folder, as R also produces the IRFs in its environment. 

-Temp is a folder that is necessary for creating temporary files as part of the Do file. 

-Additional files: the do file creates the new dataset used for the R script.

Extension Replication: 

Step 1: Download Final_HHLevel.dta from the original replication package linked above. The file path in the package is: HSOHCP-Final-Submission >> DATA >> CEX >> Final_HHLevel.dta

Step 2: Run CreateExtensionDataSet.do. Ensure the working directory is updated. This should take less than a minute to run. The files extension_timeseries.xlsx and extension_timeseries.dta are created in this step.

Step 3: Run extensionLPScript.R. Ensure the working directory is updated. This should take less than five minutes to run. 

:)
