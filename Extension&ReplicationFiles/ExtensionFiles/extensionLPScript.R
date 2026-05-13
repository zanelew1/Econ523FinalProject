# ============================================================
# Extension Analysis Script
# ============================================================

# Load data 
rm(list = ls())
require(install.load)
#set wd to the ExtensionFiles folder within the Extension&ReplicationFiles Folder
setwd("/Users/connorlewis_macbookpro/Desktop/Econ523FinalProject/Extension&ReplicationFiles/ExtensionFiles")
require(readxl)
library(seasonal)
require(dynlm)
require(car)
require(data.table)
require(xts)
require(vars)
require(forecast)
require(smooth)
require(Mcomp)
require(expm)
require(mFilter)
library(stringr)

# ============================================================
# Load main agency data
# ============================================================
all_data <- read_excel("all_agency.xlsx", sheet = "final")
all_data[,1] = NULL
varlist = names(all_data)

attach(all_data)
for (k in 2:length(varlist)){
  eval(parse(text = paste(as.name(varlist[k]),"= ts(",as.name(varlist[k]),",start=c(1980,1), frequency=4)")))
}
detach(all_data)

# ============================================================
# Load extension (Stata) data
# ============================================================
all_stata2 <- read_excel("extension_timeseries.xlsx")
all_stata2 = all_stata2[,-1]
varlist2 = names(all_stata2)

# Save each group varlist under a distinct name — do NOT overwrite
varlist2_educ = varlist2[str_detect(varlist2, "educ_")]   # education group variables
varlist2_race = varlist2[str_detect(varlist2, "race_")]   # race group variables
varlist2_size = varlist2[str_detect(varlist2, "size_")]   # family size group variables

# ============================================================
# Helper function: convert, seasonally adjust, and extract series
# ============================================================
seasonalize_group = function(varlist_seasonal, all_stata2, use_outlier = TRUE) {
  for (i in 1:length(varlist_seasonal)) {
    varname = varlist_seasonal[i]
    
    # Create time series
    x = ts(all_stata2[[varname]], start = c(1980, 1), frequency = 4)
    
    # Seasonally adjust
    if (use_outlier) {
      x_seas = seas(x, na.action = na.x13, estimate.maxiter = 10000)
    } else {
      x_seas = seas(x, na.action = na.x13, estimate.maxiter = 10000,
                    outlier = NULL, regression.aictest = NULL)
    }
    
    # Extract seasonally adjusted series and assign to global environment
    assign(varname, x_seas$data[, 3], envir = .GlobalEnv)
  }
}

# Seasonally adjust each group
seasonalize_group(varlist2_educ, all_stata2, use_outlier = TRUE)
seasonalize_group(varlist2_race, all_stata2, use_outlier = TRUE)
seasonalize_group(varlist2_size, all_stata2, use_outlier = FALSE)  # size needs outlier suppressed

# ============================================================
# First Stage Regression
# ============================================================
mtildeoverXt = policy / longruntrend / 100000
sumptoverXt  = rhsnpurch2 / longruntrend / 100000
npurchasetrend2 = netpurchase

lag = 4
lm.firststage = dynlm(sumptoverXt ~ mtildeoverXt +
                        L(reallogmortorigin, 1:lag) + L(loghousingstarts, 1:lag) + L(grmortdebt, 1:lag) + L(grhouseindex, 1:lag)
                      + L(grpriceindex, 1:lag) + L(threemonthtbill, 1:lag) + L(tenyeartreasury, 1:lag) + L(conventionalmortrate, 1:lag)
                      + L(baacorporatespread, 1:lag) + L(unemploymentrate, 1:lag) + L(grpi, 1:lag) + L(npurchasetrend2, 1:lag),
                      start = c(1980, 1), end = c(2006, 4))
summary(lm.firststage)
waldtest(lm.firststage, . ~ . - mtildeoverXt)

# Fitted values from first stage
firststagefitted = lm.firststage$fitted.values

# ============================================================
# Second Stage: Loop over ALL 9 group variables
# ============================================================
horizon2 = 9
lag = 4

mtildeoverXt = policy / longruntrend / 100000
sumptoverXt  = (((4 * 2) * rhsnpurch2) / longruntrend) / 100000

# Combine all 9 group variables into one list
all_groups = c(varlist2_educ, varlist2_race, varlist2_size)

for (kk in 1:length(all_groups)) {
  
  varname = all_groups[kk]
  x = get(varname)  # retrieve the seasonally adjusted series by name
  
  # Initialize results matrix for this variable
  secondstageresponse = matrix(0, nrow = horizon2, ncol = 7)
  secondstageresponse[, 1] = seq(1, horizon2, by = 1)
  
  for (i in 2:horizon2) {
    
    ythminusytoverXt = (lag(x, -(i - 1))) - (lag(x, 1))
    
    lm.secondstage = dynlm(ythminusytoverXt ~ sumptoverXt +
                             L(reallogmortorigin, 1:lag) + L(loghousingstarts, 1:lag) + L(100 * grmortdebt, 1:lag) + L(100 * grhouseindex, 1:lag)
                           + L(100 * grpriceindex, 1:lag) + L(100 * threemonthtbill, 1:lag) + L(100 * tenyeartreasury, 1:lag) + L(100 * conventionalmortrate, 1:lag)
                           + L(100 * baacorporatespread, 1:lag) + L(100 * unemploymentrate, 1:lag) + L(100 * grpi, 1:lag) + L(npurchasetrend, 1:lag) | mtildeoverXt +
                             L(reallogmortorigin, 1:lag) + L(loghousingstarts, 1:lag) + L(100 * grmortdebt, 1:lag) + L(100 * grhouseindex, 1:lag)
                           + L(100 * grpriceindex, 1:lag) + L(100 * threemonthtbill, 1:lag) + L(100 * tenyeartreasury, 1:lag) + L(100 * conventionalmortrate, 1:lag)
                           + L(100 * baacorporatespread, 1:lag) + L(100 * unemploymentrate, 1:lag) + L(100 * grpi, 1:lag) + L(npurchasetrend2, 1:lag),
                           start = c(1980, 1), end = c(2006, 4))
    
    coef = summary(lm.secondstage)[["coefficients"]][2, 1]
    se   = summary(lm.secondstage)[["coefficients"]][2, 2]
    
    secondstageresponse[i, 2] = coef
    secondstageresponse[i, 3] = coef - 1.96  * se
    secondstageresponse[i, 4] = coef - 1.645 * se
    secondstageresponse[i, 5] = coef + 1.645 * se
    secondstageresponse[i, 6] = coef + 1.96  * se
  }
  
  # Plot impulse response for this group
  matplot(secondstageresponse[, 2:6], type = "l", main = varname,
          ylab = "Response", xlab = "Horizon")
  lines(rep(0, horizon2))
  
  # Save results to CSV
  write.table(
    rbind(c("period", "ir", "ci5", "ci10", "ci90", "ci95", "zero"), secondstageresponse),
    paste("graphs/", varname, ".csv", sep = ""),
    sep = ",", col.names = FALSE, row.names = FALSE, quote = FALSE
  )
  
  message("Completed: ", varname, " (", kk, " of ", length(all_groups), ")")
}
