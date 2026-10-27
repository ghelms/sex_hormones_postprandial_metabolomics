# code/04_figures/make_global_model_figures.R

# =========================================================
#  GLOBAL INTERACTION MODEL FIGURES
# =========================================================
# M15: progesterone_log × timepoint
# M16: estrogen_log × timepoint
#
# These models test whether the hormone modifies the overall
# postprandial trajectory of each metabolite.
#
# Tile colour = FDR/significance category
# Text = ΔAIC = AIC_reduced - AIC_full
# Positive ΔAIC means the interaction model fits better.

## ---------------------------------------------------------------------------------------------------------------------------

# Read M15 and M16 results

global_files <- file.path(
  RESULT_DIR,
  "models",
  paste0(c("M15", "M16"), "_global_interaction_results.csv")
)

global_results <- purrr::map_dfr(
  global_files,
  readr::read_csv,
  show_col_types = FALSE
)

## ---------------------------------------------------------------------------------------------------------------------------

# Add metabolite group information
# Requires `data` from preprocessing to be loaded in the environment.

metab_info <- data %>%
  distinct(metabolite, group)

global_results <- global_results %>%
  left_join(metab_info, by = "metabolite")

## ---------------------------------------------------------------------------------------------------------------------------

# Prepare plotting variables

plot_df <- global_results %>%
  mutate(
    delta_AIC = AIC_reduced - AIC_full,
    
    # make global results compatible with old plotting functions
    estimate = delta_AIC,
    p.value = p_value,
    p.adjusted = p_adj_fdr
  )

plot_df <- prepare_plot_data(plot_df)
plot_df <- prepare_discrete_labels(plot_df)

## ---------------------------------------------------------------------------------------------------------------------------

# Clean hormone labels for plotting

plot_df <- plot_df %>%
  mutate(
    hormone = case_when(
      hormone == "progesterone_log" ~ "Progesterone",
      hormone == "estrogen_log" ~ "Estrogen",
      TRUE ~ hormone
    )
  )

## ---------------------------------------------------------------------------------------------------------------------------

# Plot

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
    values = SIG_COLORS
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
    ),
    
    legend.position = "bottom"
  ) +
  
  labs(
    title = "Global hormone × timepoint interaction",
    subtitle = "Likelihood ratio test per metabolite; tile colour = significance, text = ΔAIC",
    x = NULL,
    y = NULL,
    fill = "Significance",
    caption = paste0("FDR adjusted: ", USE_FDR)
  )

## ---------------------------------------------------------------------------------------------------------------------------

# Save plot

ggsave(
  file.path(
    FIGURE_DIR,
    paste0("M15_16_",
      "global_interaction_plot",
      ifelse(USE_FDR, "_FDR", "_noFDR"),
      ".png"
    )
  ),
  height = FIG_HEIGHT,
  width = FIG_WIDTH
)