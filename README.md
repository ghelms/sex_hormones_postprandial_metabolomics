# Female Cycle Hormones and Postprandial Metabolic Responses in COPSAC2000

Do circulating progesterone and estradiol change how young women's metabolism responds to a meal? And do sex hormones modify the link between faecal and plasma metabolites?

This repository contains the R analysis pipeline I built during a two-month research internship at **DTU Health Tech** (May–June 2026), supervised by **Parvaneh Ebrahimi**, building on her earlier work in the cohort. It takes raw NMR metabolomics from a standardised meal challenge in the COPSAC2000 cohort and runs it through preprocessing, 16 per-metabolite models, multiple-testing correction and summary heatmaps.

> **Data are not included.** COPSAC2000 is a clinical birth cohort and the data cannot be shared publicly. The code is published to document the analysis, so it will not run without data access through COPSAC.

---

## Study design in brief

| | |
|---|---|
| **Cohort** | COPSAC2000, 18-year visit, meal challenge with blood sampling at fasting and up to 240 min after the meal |
| **Participants** | Women with both progesterone and estradiol measured (122 after filtering) |
| **Outcomes** | ~80 NMR plasma metabolites (lipoprotein subclasses excluded) plus insulin, C-peptide, GIP, GLP-1 and glucagon |
| **Exposures** | log-transformed progesterone and estradiol |
| **Covariates** | BMI; participant random intercept in repeated-measures models |
| **Faecal data** | Faecal water metabolites (absolute concentrations, e.g. short-chain fatty acids) |
| **Multiple testing** | Benjamini–Hochberg FDR, applied within each model (and within timepoint / faecal metabolite where relevant) |

---

## Models

All models are fitted separately for each plasma metabolite. Formulas are defined in one place, [`code/config.R`](code/config.R).

| Progesterone | Estradiol | Question | Outcome | Model |
|---|---|---|---|---|
| M1 | M3 | Does the hormone change the postprandial rise at each timepoint? | rise from fasting | LMM, hormone × timepoint (factor) |
| M2 | M4 | Same, adjusting for fasting level instead of subtracting it | raw concentration, fasting as covariate | LMM, hormone × timepoint |
| M5 | M6 | Is the hormone associated with fasting levels? | fasting concentration | linear model |
| M7, M8 | M9, M10 | Is the hormone associated with the total response? | positive incremental AUC at 120 / 240 min | linear model |
| M11 | M12 | Does the hormone change the *shape* of the trajectory? | rise from fasting | LMM with natural spline of time, likelihood ratio test |
| M13 | M14 | Does the hormone modify the faecal–plasma metabolite association? | AUCpos at each timepoint | linear model, hormone × faecal metabolite |
| M15 | M16 | Global test: any hormone × time interaction at all? | rise from fasting | LMM, likelihood ratio test of full vs. reduced model |

LMM = linear mixed model (`lme4` / `lmerTest`) with a random intercept per participant.

---

## Pipeline

```
code/
├── main.R                 # runs everything, switches at the top
├── config.R               # paths, FDR settings, figure settings, all model formulas
├── 00_preprocessing/      # load data, select participants, outlier removal, baseline correction, AUCs
├── 01_functions/          # package loading
├── 02_models/             # one script per model family, writes Results/models/*.csv
├── 03_results/            # combine model outputs and add FDR-adjusted p-values
└── 04_figures/            # significance heatmaps per model family
```

Preprocessing steps (`00_preprocessing/preprocessing_plasma.R`):

1. Keep female participants with both progesterone and estradiol measured
2. Join NMR metabolites with postprandial gut and pancreatic hormones
3. Remove extreme observations per metabolite (outside Q1 − 3·IQR / Q3 + 3·IQR); a summary is written to `Results/outlier_summary.csv`
4. Compute the rise from fasting and attach precomputed positive incremental AUCs
5. Log-transform hormones and define cycle phase (luteal if progesterone > 0.7)

---

## Running the analysis

Requires R and the packages `tidyverse`, `lme4`, `lmerTest`, `broom`, `broom.mixed`, `rio` and `pacman`.

From the repository root:

```r
source("code/main.R")
```

The switches at the top of `main.R` control which stages run:

```r
RUN_PREPROC     <- FALSE  # needs access to the COPSAC data
RUN_MODELS      <- TRUE
COMBINE_RESULTS <- TRUE
RUN_FIGURES     <- TRUE
```

Settings are changed in `code/config.R`, not inside the individual scripts:

- `USE_FDR`: colour figures by FDR-adjusted (`TRUE`) or raw p-values (`FALSE`)
- `FDR_cutoff_low / medium / high`: significance thresholds (0.01 / 0.05 / 0.10)
- `spline_df`: degrees of freedom for the spline models
- `models_to_run`: which of M1–M16 to fit

Outputs:

- `Results/models/`: one CSV per model with estimates, standard errors and p-values
- `Results/*_models_results.csv`: combined results with FDR-adjusted p-values
- `Figures/`: heatmaps (metabolites × timepoint / hormone), coloured by significance and labelled with the estimate

The scripts are sourced in sequence and share one R environment, so run them through `main.R` rather than one by one.

---

## Acknowledgements

Supervision and earlier analyses by Parvaneh Ebrahimi (DTU Health Tech). Data from the Copenhagen Prospective Studies on Asthma in Childhood (COPSAC).
