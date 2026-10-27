# code/04_figures/make_faecal_model_figures.R

faecal_results <- read_csv(
  file.path(
    RESULT_DIR,
    "faecal_models_results.csv"
  ), 
  show_col_types = FALSE
)


plot_df <- prepare_plot_data(faecal_results)
plot_df <- prepare_discrete_labels(plot_df)


# Plot each model separately
for (model_name in unique(plot_df$indicator)) {
  
  model_df <- plot_df %>%
    filter(indicator == model_name)
  
  # Dynamic labels
  hormone_label <- case_when(
    str_detect(model_df$indicator[1], "prog") ~ "Progesterone",
    str_detect(model_df$indicator[1], "estro") ~ "Estrogen",
    TRUE ~ "Hormone"
  )
  
  outcome_label <- paste0("AUCpos ", model_df$timepoint[1], " min")
  
  
  ggplot(
    model_df,
    aes(
      x = faecal_metabolite,
      y = plasma_metabolite,
      fill = sig_cat
    )
  ) +
    
    geom_tile(
      color = "grey85",
      linewidth = 0.3
    ) +
    
    geom_text(
      aes(label = label),
      size = 3
    ) +
    
    facet_grid(
      group ~ .,
      scales = "free_y",
      space = "free_y"
    ) +
    
    scale_fill_manual(
      values = SIG_COLORS) +
    
    theme_bw() +
    
    theme(
      strip.text.y = element_text(
        angle = 0,
        face = "bold"
      ),
      
      panel.grid = element_blank(),
      
      axis.text.y = element_text(
        size = 12
      ),
      
      axis.text.x = element_text(
        angle = 45,
        hjust = 1
      ),
      
      legend.position = "bottom"
    )+
    labs(
      title = paste0(
        hormone_label,
        " association with faecal metabolites"
      ),
      subtitle = paste0(
        "Plasma metabolite response: ",
        outcome_label
      ),
      x = "Faecal metabolite",
      y = "Plasma metabolite",
      fill = "Significance",
      caption = paste0(
        "Linear models adjusted for BMI | FDR correction applied: ",
        USE_FDR
      )
    )
  
  ggsave(
    file.path(
      FIGURE_DIR,
      "faecal_plots",
      paste0("Faecal_plot_",
             model_name,
             ifelse(USE_FDR, "_FDR","_noFDR"),
             ".png")
    ), 
    height = FIG_HEIGHT_FAECAL,
    width = FIG_WIDTH_FAECAL)
}