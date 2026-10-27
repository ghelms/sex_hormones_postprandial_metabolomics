# code/04_figures/make_spline_model_figures.R

spline_results <- read_csv(
  file.path(
    RESULT_DIR,
    "spline_models_results.csv"
  ), 
  show_col_types = FALSE
)


plot_df <- prepare_plot_data(spline_results)
plot_df <- prepare_discrete_labels(plot_df)


ggplot(
  plot_df,
  aes(
    x = hormone,
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
  ) +
  
  labs(
    title = "Hormone × spline(time) interaction",
    subtitle = "Tile colour = significance, text = ΔAIC",
    caption = paste0("FDR ADJUSTED: ", USE_FDR)
  )

ggsave(
  file.path(
    FIGURE_DIR,
    paste0("spline_plot",
           ifelse(USE_FDR, "_FDR","_noFDR"),
           ".png")
  ), 
  height = FIG_HEIGHT,
  width = FIG_WIDTH)
