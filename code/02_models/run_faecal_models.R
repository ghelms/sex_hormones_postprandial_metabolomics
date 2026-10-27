# 02_models/run_faecal_models.R

models <-  c("M13","M14")

to_run <- models[models %in% models_to_run]

## ---------------------------------------------------------------------------------------------------------------------------

# Reshape AUCpos to one column per timepoint
auc_data <- data %>% 
  filter(!is.na(AUCpos)) %>% 
  pivot_wider(
    id_cols = c("COPSACID", "metabolite", "group","subgroup", "BMI", "estrogen_log", "progesterone_log", "cycle_phase"),
    names_from = timepoint, values_from = AUCpos, names_prefix = "AUCpos") 

# Add fasting data as AUCpos0
auc_data <-  auc_data %>% 
  left_join(
    data %>% select(COPSACID, metabolite, baseline) %>% 
      group_by(COPSACID, metabolite) %>% 
      slice(1) %>% 
      ungroup(),
    by = c("COPSACID", "metabolite")) %>% 
  rename(AUCpos0 = baseline)

faecal <- fecalwater_abs %>% 
  rename(COPSACID = sampleid) %>% 
  mutate(COPSACID = as.numeric(COPSACID)) %>% 
  filter(!is.na(COPSACID)) # Remove na

faecal_metabs <- names(faecal)[-1]
plasma_metabs <- unique(auc_data$metabolite)
timepoints <- c("0", as.character(unique(data$timepoint)))

model_data <- auc_data %>%
  left_join(faecal, by = "COPSACID")

# =========================================================
#  RUNNING FECAL MODELS
# =========================================================


all_results <- list()

for (model_name in to_run) {
  
  model_template <- get(paste0(model_name, "_MODEL_NAME"))
  
  # Run for each timepoint
  for (time in timepoints){
    
    # Get time in model
    formula_string <- gsub(
      "AUCpos",
      paste0("AUCpos", time),
      model_template
    )
  
    model_spec <- strsplit(formula_string, " ")[[1]]
    outcome_variable <- model_spec[1]
    hormone <- model_spec[5]
    
    cat("\nRunning", model_name, " for AUCpos", time, " with ", hormone,"\n")
    
    res <- purrr::map_dfr(plasma_metabs, function(plasma_metab) {
      
      dat_plasma <- model_data %>%
        filter(metabolite == plasma_metab)
      
      purrr::map_dfr(faecal_metabs, function(faecal_metab) {
        
        # Input faecal metab
        formula_string <- gsub(
          "faecal_metabolite",
          paste0("`", faecal_metab, "`"),
          formula_string
        )
        
        fit <- tryCatch(
          lm(
            as.formula(formula_string),
            data = dat_plasma
          ),
          error = function(e) NULL
        )
        
        if (is.null(fit)) {
          return(NULL)
        }
        
        broom::tidy(fit) %>%
          mutate(
            plasma_metabolite = plasma_metab,
            faecal_metabolite = faecal_metab
          )
        
      })
    }) %>%
      mutate(
        outcome_variable = outcome_variable,
        hormone = hormone,
        model = model_name,
        model_category = "Faecal"
      )
    
    write_csv(
      res,
      file.path(
        RESULT_DIR,
        "models",
        paste0(model_name, "_results_AUCpos", time,  ".csv")
      )
    )
  }
  all_results[[model_name]] <- res
}
