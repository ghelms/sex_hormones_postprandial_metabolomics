# main.R
RUN_PREPROC <- FALSE
RUN_MODELS  <- TRUE
COMBINE_RESULTS <- TRUE
RUN_FIGURES <- TRUE


# 0. Setup (run from the repository root)

source("code/01_functions/load_packages.R")
source("code/config.R")

# 1. Preprocessing
if(RUN_PREPROC){
  #source("code/00_preprocessing/load_data.R") # requires access to the COPSAC data server
  source("code/00_preprocessing/preprocessing_plasma.R") 
  #source("code/00_preprocessing/AUCpos_hormones.R")  # Only run if iAUC_hor is not loaded
}


# 2. Run models
if(RUN_MODELS){
  source("code/02_models/run_timepoint_models.R")
  source("code/02_models/run_fasting_models.R")
  source("code/02_models/run_auc_models.R")
  source("code/02_models/run_spline_models.R")
  source("code/02_models/run_faecal_models.R")
  source("code/02_models/run_global_models.R")
}

# 3. Combine results
if(COMBINE_RESULTS){
  source("code/03_results/combine_results.R")
  source("code/03_results/add_fdr.R")
}
# 4. Generate figures
if(RUN_FIGURES){
  source("code/04_figures/prepare_plot_data.R")
  source("code/04_figures/make_timepoint_model_figures.R")
  source("code/04_figures/make_auc_model_figures.R")
  source("code/04_figures/make_spline_model_figures.R")
  source("code/04_figures/make_faecal_model_figures.R")
  source("code/04_figures/make_global_model_figures.R")
  
}