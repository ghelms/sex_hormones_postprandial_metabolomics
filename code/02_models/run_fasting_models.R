# 02_models/run_fasting_models.R

models <- c("M5","M6")

to_run <- models[models %in% models_to_run]

## ---------------------------------------------------------------------------------------------------------------------------

# =========================================================
#  RUNNING FASTING MODEL
# =========================================================

for(model_name in to_run){
  model = eval(parse(text = paste0(model_name, "_MODEL_NAME")))
  
  cat(paste0("Running: ", model_name, "\n ", model))
  
  model_spec = strsplit(model, " ")[[1]]
  outcome_variable <- model_spec[1]
  hormone <- model_spec[5]
  
  results <- data %>%
    group_by(metabolite) %>%
    group_modify(~ {
      
      fit <- lm(
        as.formula(model),
        data = .x
      )
      broom.mixed::tidy(fit)
      }) %>% 
    mutate(
      outcome_variable = outcome_variable,
      hormone = hormone,
      model = model_name,
      model_category = "Fasting"
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