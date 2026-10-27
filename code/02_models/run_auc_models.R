# 02_models/run_auc_models.R

models <-  c("M7","M8","M9","M10")

to_run <- models[models %in% models_to_run]

## ---------------------------------------------------------------------------------------------------------------------------

# Reshape AUCpos to one column per timepoint
auc_data <- data %>% 
  filter(!is.na(AUCpos)) %>% 
  pivot_wider(
    id_cols = c("COPSACID", "metabolite", "group","subgroup", "BMI", "estrogen_log", "progesterone_log", "cycle_phase"),
    names_from = timepoint, values_from = AUCpos, names_prefix = "AUCpos")


# =========================================================
#  RUNNING AUC MODELS
# =========================================================

for(model_name in to_run){
  model = eval(parse(text = paste0(model_name, "_MODEL_NAME")))
  
  cat(paste("Running: ", model_name, "\n ", model))
  
  model_spec = strsplit(model, " ")[[1]]
  outcome_variable <- model_spec[1]
  hormone <- model_spec[5]
  
  results <- auc_data %>%
    group_by(metabolite) %>%
    group_modify(~ {
      
      fit <- lm(
        as.formula(model),
        data = .x
      )
      broom.mixed::tidy(fit)}) %>% 
    mutate(
      outcome_variable = outcome_variable,
      hormone = hormone,
      model = model_name,
      model_category = "AUC"
    )
  
  
  write_csv(results, 
            file.path(
              RESULT_DIR, 
              "models",
              paste0(model_name, "_results.csv")
            )
  )
}

## ---------------------------------------------------------------------------------------------------------------------------