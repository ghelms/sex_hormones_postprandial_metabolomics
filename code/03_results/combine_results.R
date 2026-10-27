# 03_results/combine_results.R

# Metabolite and group info
metab_info <- model_data %>% distinct(metabolite, group) # (NEED TO HAVE DATA LOADED IN ENVIROMENT)

## ---------------------------------------------------------------------------------------------------------------------------

# Time point models
tp_model_paths <- file.path(
  RESULT_DIR,
  "models",
  paste0(TIMEPOINT_MODELS, "_results.csv")
)

tp_results <- read_csv(tp_model_paths, show_col_types = FALSE) 

tp_results <- tp_results %>% 
  filter(str_detect(term, "(progesterone_log|estrogen_log):timepoint\\d+")) %>% 
  mutate(
    timepoint = str_remove(
      term,
      "(progesterone_log|estrogen_log):timepoint"
    )
  ) %>% 
  
  # Order timepoint
  mutate(
    timepoint = factor(
      timepoint,
      levels = c("30","60","90","120","150","240")
    )) %>% 
  select(!group) %>% 
  
  left_join(
    metab_info, 
    by = "metabolite"
  ) %>%
  
  arrange(group, metabolite) %>%
  
  mutate(
    metabolite = factor(
      metabolite,
      levels = rev(unique(metabolite))
    )
  )

write_csv(
  tp_results, 
  file.path(RESULT_DIR, "timepoint_models_results.csv")
  )
  
## ---------------------------------------------------------------------------------------------------------------------------

# AUC Models
auc_model_paths <- file.path(
  RESULT_DIR,
  "models",
  paste0(AUC_MODELS, "_results.csv")
)

auc_results <- read_csv(auc_model_paths, show_col_types = FALSE) 

auc_results <- auc_results %>%
  filter(term %in% c("progesterone_log", "estrogen_log")) %>% 
  
  left_join(
    metab_info, 
    by = "metabolite"
  ) %>%
  
  arrange(group, metabolite) %>%
  
  mutate(
    metabolite = factor(
      metabolite,
      levels = rev(unique(metabolite))
    )
  ) %>% 
  # Make indicator
  mutate(
    indicator = case_when(
      model == "M5" ~ "Fasting_prog",
      model == "M6" ~ "Fasting_estro",
      model == "M7" ~ "AUCpos120_prog",
      model == "M8" ~ "AUCpos240_prog",
      model == "M9" ~ "AUCpos120_estro",
      model == "M10" ~ "AUCpos240_estro"
    ),
    indicator = factor(
      indicator,
      levels = c(
        "Fasting_prog",
        "Fasting_estro",
        "AUCpos120_prog",
        "AUCpos240_prog",
        "AUCpos120_estro",
        "AUCpos240_estro"
      )
    )
  )

write_csv(
  auc_results, 
  file.path(RESULT_DIR, "auc_models_results.csv")
)

## ---------------------------------------------------------------------------------------------------------------------------

# Spline models
spline_model_paths <- file.path(
  RESULT_DIR,
  "models",
  paste0(SPLINE_MODELS, "_results.csv")
)

spline_results <- read_csv(spline_model_paths, show_col_types = FALSE) 

spline_results <- spline_results %>%
  
  left_join(
    metab_info, 
    by = "metabolite"
  ) %>%
  
  arrange(group, metabolite) %>%
  
  mutate(
    metabolite = factor(
      metabolite,
      levels = rev(unique(metabolite))
    ),
    estimate = delta_AIC
  )

write_csv(
  spline_results, 
  file.path(RESULT_DIR, "spline_models_results.csv")
)

## ---------------------------------------------------------------------------------------------------------------------------

faecal_models <- list.files(
  file.path(RESULT_DIR, "models"),  pattern = "AUC"
)
faecal_model_paths <- file.path(
  RESULT_DIR,
  "models",
  faecal_models
)

faecal_results <- read_csv(
  faecal_model_paths,
  show_col_types = FALSE
)

faecal_results <- faecal_results %>%
  
  # Keep interaction terms only
  filter(str_detect(term, ":")) %>%
  
  left_join(
    metab_info,
    by = c("plasma_metabolite" = "metabolite")
  ) %>%
  
  arrange(group, plasma_metabolite, faecal_metabolite) %>%
  
  mutate(
    plasma_metabolite = factor(
      plasma_metabolite,
      levels = rev(unique(plasma_metabolite))
    )
  ) %>%
  
  mutate(
    indicator = paste0(outcome_variable, "_", hormone),
    indicator = as.factor(indicator),
    timepoint = str_extract(outcome_variable, "\\d+"),
    timepoint = as.numeric(timepoint)
    )

write_csv(
  faecal_results,
  file.path(
    RESULT_DIR,
    "faecal_models_results.csv"
  )
)
