# 02_models/run_global_models.R

models <- c("M15", "M16")

to_run <- models[models %in% models_to_run]

## ---------------------------------------------------------------------------------------------------------------------------

# =========================================================
#  GLOBAL INTERACTION TESTS
# =========================================================
# For each metabolite:
#   m0 = reduced model without hormone × timepoint interaction
#   m1 = full model with hormone × timepoint interaction
#
# The likelihood ratio test compares m0 and m1.
# Use REML = FALSE when comparing models with different fixed effects.

for (model_name in to_run) {
  
  model_reduced <- get(paste0(model_name, "_MODEL_REDUCED"))
  model_full    <- get(paste0(model_name, "_MODEL_FULL"))
  model_label   <- get(paste0(model_name, "_MODEL_NAME"))
  
  cat(
    paste0(
      "\nRunning: ", model_name, "\n",
      "Reduced: ", model_reduced, "\n",
      "Full:    ", model_full, "\n"
    )
  )
  
  hormone <- ifelse(
    grepl("progesterone", model_full),
    "progesterone_log",
    "estrogen_log"
  )
  
  results <- data %>%
    group_by(metabolite) %>%
    group_modify(~ {
      
      m0 <- lmer(
        as.formula(model_reduced),
        data = .x,
        REML = FALSE
      )
      
      m1 <- lmer(
        as.formula(model_full),
        data = .x,
        REML = FALSE
      )
      
      test <- anova(m0, m1)
      
      tibble::tibble(
        chisq = test$Chisq[2],
        df = test$`Chi Df`[2],
        p_value = test$`Pr(>Chisq)`[2],
        AIC_reduced = AIC(m0),
        AIC_full = AIC(m1),
        BIC_reduced = BIC(m0),
        BIC_full = BIC(m1),
        logLik_reduced = as.numeric(logLik(m0)),
        logLik_full = as.numeric(logLik(m1))
      )
      
    }) %>%
    ungroup() %>%
    mutate(
      p_adj_fdr = p.adjust(p_value, method = FDR_METHOD),
      outcome_variable = "rise",
      hormone = hormone,
      model = model_name,
      model_name = model_label,
      model_category = "global_interaction",
      reduced_formula = model_reduced,
      full_formula = model_full
    )
  
  write_csv(
    results,
    file.path(
      RESULT_DIR,
      "models",
      paste0(model_name, "_global_interaction_results.csv")
    )
  )
}

