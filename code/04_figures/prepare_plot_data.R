# 04_figures/prepare_plot_data.R

prepare_plot_data <- function(results){
  
  results %>%
    
    mutate(
      
      significance_value = case_when(
        USE_FDR ~ p.adjusted,
        TRUE ~ p.value
      ),
      
      sig_cat = case_when(
        
        significance_value < FDR_cutoff_low ~
          paste0("p < ", FDR_cutoff_low),
        
        significance_value < FDR_cutoff_medium ~
          paste0("p < ", FDR_cutoff_medium),
        
        significance_value < FDR_cutoff_high ~
          paste0("p < ", FDR_cutoff_high),
        
        TRUE ~ "NS"
      ),
      
      neglog10_significance = case_when(
        significance_value == 0 ~
          -log10(.Machine$double.xmin),
        
        TRUE ~
          -log10(significance_value)
      )
      
    )
  
}

prepare_discrete_labels <- function(results){
  
  results %>%
    
    mutate(
      label = case_when(
        significance_value < FDR_cutoff_high ~
          sprintf("%.3f", estimate),
        
        TRUE ~ ""
      )
    )
  
}
