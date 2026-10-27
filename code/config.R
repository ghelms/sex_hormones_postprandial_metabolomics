# config.R

## ---------------------------------------------------------------------------------------------------------------------------
# =========================================================
# PATHS
# =========================================================

RESULT_DIR <- "./Results"
FIGURE_DIR <- "./Figures"

# Create output folders on a fresh clone
dir.create(file.path(RESULT_DIR, "models"), recursive = TRUE, showWarnings = FALSE)
dir.create(file.path(FIGURE_DIR, "faecal_plots"), recursive = TRUE, showWarnings = FALSE)

## ---------------------------------------------------------------------------------------------------------------------------
# =========================================================
# ANALYSIS SETTINGS
# =========================================================

# Significance settings
USE_FDR <- TRUE

FDR_METHOD <- "fdr"

FDR_cutoff_low <- 0.01
FDR_cutoff_medium <- 0.05
FDR_cutoff_high <- 0.10

spline_df <- 3

## ---------------------------------------------------------------------------------------------------------------------------
# =========================================================
# VARIABLES
# =========================================================



## ---------------------------------------------------------------------------------------------------------------------------
# =========================================================
# FIGURES SETTINGS
# =========================================================

PLOT_FDR_DISCRETE = TRUE
FIG_HEIGHT = 15
FIG_WIDTH = 9

FIG_HEIGHT_FAECAL = 15
FIG_WIDTH_FAECAL = 17

SIG_COLORS <- setNames(
  c("white", "#08519c", "#6baed6", "#c6dbef"),
  c(
    "NS",
    paste0("p < ", FDR_cutoff_low),
    paste0("p < ", FDR_cutoff_medium),
    paste0("p < ", FDR_cutoff_high)
  )
)


## ---------------------------------------------------------------------------------------------------------------------------
# =========================================================
# MODELS
# =========================================================
# Comment out models not to run
TIMEPOINT_MODELS = c("M1","M2","M3","M4")
# Fasting (M5-M6) and AUC (M7-M10) results are combined in one table
AUC_MODELS = c("M5","M6","M7","M8","M9","M10")
SPLINE_MODELS = c("M11","M12")
FAECAL_MODELS = c("M13","M14")
GLOBAL_INTERACTION_MODELS = c("M15","M16")

models_to_run <- c(
  "M1",
  "M2",
  "M3",
  "M4",
  "M5",
  "M6",
  "M7",
  "M8",
  "M9",
  "M10",
  "M11",
  "M12",
  "M13",
  "M14",
  "M15",
  "M16"
)

# - Timepoint model
M1_MODEL_NAME =  "rise ~ BMI + progesterone_log * timepoint + (1 | COPSACID)"
M2_MODEL_NAME =  "metabolite_raw ~ BMI + progesterone_log * timepoint + baseline + (1 | COPSACID)"
M3_MODEL_NAME =  "rise ~ BMI + estrogen_log * timepoint + (1 | COPSACID)"
M4_MODEL_NAME =  "metabolite_raw ~ BMI + estrogen_log * timepoint + baseline + (1 | COPSACID)"

# - AUC models
M5_MODEL_NAME = "baseline ~ BMI + progesterone_log"
M6_MODEL_NAME = "baseline ~ BMI + estrogen_log"
M7_MODEL_NAME = "AUCpos120 ~ BMI + progesterone_log"
M8_MODEL_NAME = "AUCpos240 ~ BMI + progesterone_log"
M9_MODEL_NAME = "AUCpos120 ~ BMI + estrogen_log"
M10_MODEL_NAME = "AUCpos240 ~ BMI + estrogen_log"

# - Spline model
M11_MODEL_NAME = sprintf("rise ~ BMI + progesterone_log * splines::ns(timepoint, df = %s) + (1 | COPSACID)", spline_df)
M12_MODEL_NAME = sprintf("rise ~ BMI + estrogen_log * splines::ns(timepoint, df = %s) + (1 | COPSACID)", spline_df)

# - Faecal model for all timepoints
M13_MODEL_NAME = "AUCpos ~ BMI + progesterone_log * faecal_metabolite" 
M14_MODEL_NAME = "AUCpos ~ BMI + estrogen_log * faecal_metabolite" 

# - Global interaction test per metabolite
# Tests whether hormone modifies the overall postprandial trajectory
# using a likelihood ratio test: anova(m0, m1)
# One test per metabolite per hormone

M15_MODEL_NAME <- "Global interaction test: progesterone_log × timepoint"
M15_MODEL_REDUCED <- "rise ~ BMI + progesterone_log + factor(timepoint) + (1 | COPSACID)"
M15_MODEL_FULL    <- "rise ~ BMI + progesterone_log * factor(timepoint) + (1 | COPSACID)"

M16_MODEL_NAME <- "Global interaction test: estrogen_log × timepoint"
M16_MODEL_REDUCED <- "rise ~ BMI + estrogen_log + factor(timepoint) + (1 | COPSACID)"
M16_MODEL_FULL    <- "rise ~ BMI + estrogen_log * factor(timepoint) + (1 | COPSACID)"


