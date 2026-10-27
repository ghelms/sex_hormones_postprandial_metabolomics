# code/04_figures/make_timepoint_model_figures.R

# Create a figure for each model

tp_results <- read_csv(
  file.path(
    RESULT_DIR,
    "timepoint_models_results.csv"
  ),
  show_col_types = FALSE
)

for(model_label in unique(tp_results$model)){
  model_function = eval(parse(text = paste0(model_label, "_MODEL_NAME")))
  
  plot_df <- tp_results %>% filter(model == model_label)
  plot_df <- prepare_plot_data(plot_df)
  plot_df <- prepare_discrete_labels(plot_df)
  plot_df <- plot_df %>% mutate(timepoint = as.factor(timepoint))
  
  ggplot(
    plot_df,
    aes(
      x = timepoint,
      y = metabolite,
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
      values =  SIG_COLORS)+
    
    labs(
      x = "Postprandial timepoint (minutes)",
      y = "Metabolite",
      fill = "Significance"
    ) +
    
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
      )
    )+
    labs(
      title = paste0("Interaction between ", str_remove(plot_df$hormone[1], "_log"), " and time on pp metabolic response"),
      subtitle = paste("Model: ", model_function) ,
      caption = paste0("FDR adjusted = ", USE_FDR)
    )+
    theme(legend.position = "bottom")
  
  ggsave(
    file.path(
      FIGURE_DIR,
      paste0(model_label, "_plot",
      ifelse(USE_FDR, "_FDR","_noFDR"),
      ".png")
      ), 
    height = FIG_HEIGHT,
    width = FIG_WIDTH)
  
}

