# 02_models/run_spline_models.R

models <- c("M11","M12")

to_run <- models[models %in% models_to_run]

## ---------------------------------------------------------------------------------------------------------------------------

# =========================================================
#  RUNNING SPLINE MODELS
# =========================================================

for(model_name in to_run){
  model = eval(parse(text = paste0(model_name, "_MODEL_NAME")))
  
  cat(paste0("Running: ", model_name, "\n ", model))
  
  model_spec = strsplit(model, " ")[[1]]
  outcome_variable <- model_spec[1]
  hormone <- model_spec[5]
  
  simple_model_name = str_replace(model, "\\*", "+") 
  
  results <- data %>%
    mutate(timepoint = as.numeric(timepoint)) %>% 
    group_by(metabolite) %>%
    
    group_modify(~{
      
      mod0 <- lmer(
        as.formula(simple_model_name),
        data = .x,
        REML = FALSE
      )
      
      mod1 <- lmer(
        as.formula(model),
        data = .x,
        REML = FALSE
      )
      
      lrt <- anova(mod0, mod1)
      
      tibble(
        p_value = lrt$`Pr(>Chisq)`[2],
        delta_AIC = AIC(mod0) - AIC(mod1)
      )
      
    }) %>%
    
    ungroup() %>%
    
    mutate(
      #FDR = p.adjust(p_value, method = "fdr"),
      p.value = p_value,
      outcome_variable = outcome_variable,
      hormone = hormone,
      model = model_name,
      model_category = "Spline"
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

