# 03_results/add_fdr.R

results_files <- c(
  "timepoint_models_results.csv",
  "auc_models_results.csv",
  "spline_models_results.csv",
  "faecal_models_results.csv"
)

for(file in results_files){
  
  results <- read_csv(
    file.path(
      RESULT_DIR,
      file
    ),
    show_col_types = FALSE
  )
  
  # TIMEPOINT FDR: GROUP BY: Model and timepoint
  if("timepoint" %in% names(results)){
    
    results <- results %>%
      group_by(model, timepoint) %>%
      mutate(
        p.adjusted = p.adjust(
          p.value,
          method = FDR_METHOD
        )
      ) %>%
      ungroup()
    
  # FAECAL FDR: GROUP BY: Model and faecal_metabolite 
  } else if(str_detect(file, "faecal")){ 
    results <- results %>%
      group_by(indicator, faecal_metabolite) %>%
      mutate(
        p.adjusted = p.adjust(
          p.value,
          method = FDR_METHOD
        )
      ) %>%
      ungroup()
  
  # REST OF THE MODELS FDR: GROUP BY: Model 
  }else {
    
    results <- results %>%
      group_by(model) %>%
      mutate(
        p.adjusted = p.adjust(
          p.value,
          method = FDR_METHOD
        )
      ) %>%
      ungroup()
    
  }
  
  write_csv(
    results,
    file.path(
      RESULT_DIR,
      file
    )
  )
  
}
