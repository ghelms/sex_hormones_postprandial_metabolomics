# 00_preprocessing/load_data.R
# Loads the raw COPSAC2000 data objects used by preprocessing_plasma.R.
# Requires access to the COPSAC data server; file paths are masked.

# Load Data -------------------------------

# Fasting values and extracted AUCs (AUC_all, use AUCpos).
# Note: these are AUC summaries, not the postprandial measurements themselves.
load(file = '.../features_all.RData')

# NGdata: raw NMR data for fasting and postprandial timepoints.
# Rows with cohort == "inhouse_diet_challenge" are excluded in preprocessing.
load(file = '.../NG_nmr_data_all.RData')
# Modelling notes:
# 1. Postprandial models adjust for the fasting level as a covariate (M2, M4)
#    instead of only subtracting it, which assumes a coefficient of one.
# 2. Time enters the timepoint models as a factor, since postprandial
#    profiles are not linear.

# Anthropometrics, sex and other participant metadata
meta <- rio::import(".../Metadata_v4_PE.RData")

# Clinical biochemistry, including progesterone and estradiol
biochem <- rio::import(".../20200923_CP_18yr_KBA_samlet.xlsx")

# Insulin and C-peptide
hormones1 <- rio::import(".../DietChallenge_insulin_cpeptide.xlsx")

# GLP-1, glucagon and GIP
load(file = ".../COPSAC2000_Glp1GlucagonGip.RData")

# Faecal metabolomics (fecalwater_abs: absolute concentrations, incl. SCFAs)
load(file = ".../COPSAC2000_fecalmetabolomics.RData")

# Precomputed AUCs for the hormones (iAUC_hor, see AUCpos_hormones.R)
load(file = '.../features_all_hor.RData')
