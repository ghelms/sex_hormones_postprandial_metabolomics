# 00_preprocessing/preprocessing_plasma.R


## ---------------------------------------------------------------------------------------------------------------------------

# The following datasets have to be loaded: 

#postprandial
#- NGdata: raw nmr data for both fasting and postprandial response
#- AUC_all: AUC values for the metabolites (AUCpos)
#- iAUC_hor: AUC values for the five hormones. Need AUCpos (run AUCpos_hormones.R)

# Hormones
#- hormones1: Includes insuline and C-peptide (Important cols: {Insulin, C-peptid})
#- glp1_glucagon_gip: Includes GLP1, GIP and Glucagon


#Meta
#- meta: anthro metrics for participants. {bmi}
#- AllMetabolic: anthro metrics for participants (important cols: {"bmi})
#- biochem: hormones like prog and est (important cols: {ANALYSEKODE: {ESTRA, PROG}})
#- varINFO: Meta data on all the metabolites

## ----------------------------------------------------------------------------------------------------------------------------


# ============================================================
# PARTICIPANT SELECTION
# ============================================================
#n_distinct(AllMetabolic$COPSACNO)
# Start: 410 participants

participant_info <- meta %>%
  rename(Sex = Sex.x,
         COPSACNO = pid2) %>% 
  filter(
    Sex == "Female", 
    !COPSACNO %in% c("x1", "x2")   # Extreme acetate outliers (real IDs removed for data protection)
  ) %>%
  select(
    COPSACNO,
    bmi
    ) %>% 
  mutate(COPSACNO = as.numeric(COPSACNO))

#n_distinct(participant_info$COPSACNO)
# 207 females remain


## -----------------------------------------------------------------------------------------------------------------------------
# ============================================================
# SEX HORMONES (PROGESTERONE + ESTRADIOL)
# ============================================================

sex_hormones <- biochem %>%
  
  filter(ANALYSEKODE %in% c("ESTRA", "PROG")) %>%
  
  mutate(
    RESULTAT = gsub("<", "", RESULTAT),
    RESULTAT = gsub(",", ".", RESULTAT),
    RESULTAT = as.numeric(RESULTAT)
  ) %>%
  
  filter(!is.na(RESULTAT)) %>%
  
  pivot_wider(
    id_cols = COPSACNO,
    names_from = ANALYSEKODE,
    values_from = RESULTAT,
    values_fn = mean
  ) 

# Merge and keep complete hormone data
participant_info <- participant_info %>%
  left_join(sex_hormones, by = "COPSACNO") %>%
  filter(
    !is.na(PROG),
    !is.na(ESTRA)
  )

#n_distinct(participant_info$COPSACNO)
# 144 participants


## -----------------------------------------------------------------------------------------------------------------------------
# ============================================================
# INSULIN + C-PEPTIDE
# ============================================================

pp_hormones1 <- hormones1 %>%
  
  select(
    ID,
    Insulin,
    "C-peptid"
  ) %>%
  
  separate(
    ID,
    into = c("COPSACNO", "tmax"),
    sep = "_"
  ) %>%
  
  rename(
    C_peptid = "C-peptid"
  ) %>%
  
  mutate(
    COPSACNO      = as.numeric(COPSACNO),
    tmax      = as.numeric(tmax),
    Insulin   = as.numeric(Insulin),
    C_peptid = as.numeric(C_peptid)
  ) %>%
  
  filter(
    !is.na(Insulin),
    !is.na(C_peptid)
  )

# DO the same for the other hormones
pp_hormones2 <- glp1_glucagon_gip %>% 
  select(
    pid, 
    T_min, 
    'GIP [pM]',
    'GLP-1 [pM]',
    'Glucagon [pM]'
    ) %>% 
  rename(
    COPSACNO = pid,
    tmax = T_min,
    GIP = 'GIP [pM]',
    GLP_1 = 'GLP-1 [pM]',
    Glucagon = 'Glucagon [pM]'
  ) 

pp_hormones <- inner_join(pp_hormones1, pp_hormones2, by = c("COPSACNO", "tmax"))

hormone_metabolites <- c("Insulin", "C_peptid", "GIP", "GLP_1", "Glucagon")



## -----------------------------------------------------------------------------------------------------------------------------
# ============================================================
# METABOLITE ANNOTATIONS
# ============================================================

metabolite_info <- varINFO %>%
  
  filter(
    !group %in% c(
      "Lipoprotein subclasses",
      "Relative lipoprotein lipid concentrations"
    ),
    !is.na(group)
  ) %>%
  
  select(
    -Success,
    -class
  ) %>%
  
  rename(
    metabolite  = varname_short,
    description = varname
  )

metabolites <- metabolite_info$metabolite
# 82 Metabolites


## -----------------------------------------------------------------------------------------------------------------------------
# ============================================================
# ASSEMBLE METABOLOMICS DATASETS
# ============================================================

# Participants to keep
participant_ids <- participant_info$COPSACNO

nmr_long <- NGdata %>%
  
  rename(
    timepoint = T_min,
    COPSACNO = pid2
    ) %>%
  
  filter(
    cohort == "COPSAC2000",
    COPSACNO %in% participant_ids
  ) %>% # 122 PARTICIPANTS
  
  select(
    COPSACNO,
    timepoint,
    all_of(metabolites)
  ) %>%
  
  left_join(
    pp_hormones,
    by = c(
      "COPSACNO",
      "timepoint" = "tmax"
    )
  ) %>%
  
  pivot_longer(
    cols = -c(COPSACNO, timepoint),
    names_to = "metabolite",
    values_to = "metabolite_raw"
  ) %>% 
  
  filter(!is.na(metabolite_raw))

# NOW THERE IS 122 PARTICIPANTS



## -----------------------------------------------------------------------------------------------------------------------------
# EXTRACT bl values
baseline_values <- nmr_long %>%
  filter(timepoint == 0) %>%
  select(
    COPSACNO,
    metabolite,
    baseline = metabolite_raw
  )

# Now we can filter out bl and from the nmr data
nmr_long <- nmr_long %>% 
  filter(!timepoint == 0)


## -----------------------------------------------------------------------------------------------------------------------------
# ============================================================
# OUTLIER DETECTION AND REMOVAL
# ============================================================

# OUTLIERS are defined as any observation outside the given borders (Tukey's rule):
# lower = Q1 - 3*IQR
# upper = Q3 + 3*IQR

# First an outlier summary: 
outlier_summary <- nmr_long %>% 
  group_by(metabolite) %>%
  summarise(
    n = n(),
    n_outliers =
      sum(
        metabolite_raw <
          quantile(metabolite_raw,.25,na.rm=T) -
          3*IQR(metabolite_raw,na.rm=T) |
        metabolite_raw >
          quantile(metabolite_raw,.75,na.rm=T) +
          3*IQR(metabolite_raw,na.rm=T),
        na.rm = TRUE
      )
  ) %>%
  arrange(desc(n_outliers)) %>% 
  mutate(
    prop = round(n_outliers / n, 3)
  )

# EXPORTS OUTLIER_SUMMARY
write_csv(outlier_summary,
          file.path(RESULT_DIR, "outlier_summary.csv")
          )

# Now we remove the outliers
nmr_long_clean <- nmr_long %>%
  group_by(metabolite) %>%
  filter(
    metabolite_raw >= quantile(metabolite_raw, .25, na.rm=TRUE) -
                  3*IQR(metabolite_raw, na.rm=TRUE),
    metabolite_raw <= quantile(metabolite_raw, .75, na.rm=TRUE) +
                  3*IQR(metabolite_raw, na.rm=TRUE)
  )

# Before: 72491 obs
# After: 72211 obs
# REMOVED 280 obs



## -----------------------------------------------------------------------------------------------------------------------------
# ============================================================
# BASELINE CORRECTION
# ============================================================
#Prepare auc values 
auc <- AUC_all %>% 
  rbind(iAUC_hor) %>% 
  mutate(
    met = ifelse(met == "C-peptid", "C_peptid", met),
    met = ifelse(met == "GLP1", "GLP_1", met)
  )
  


# Add bl values
postprandial_long <- nmr_long_clean %>%
  
  left_join(
    baseline_values,
    by = c("COPSACNO", "metabolite")
  ) %>%
  
  mutate(
    rise = metabolite_raw - baseline
  ) %>%
  
  # ADD AUC data
  left_join(
    auc %>% select(pid2, met, AUCpos, tmax),
    by = c("COPSACNO" = "pid2", 
           "metabolite" = "met", 
           "timepoint" = "tmax")
  ) %>% 
  


  # Add info on metabolites
  left_join(
    metabolite_info,
    by = "metabolite"
  ) %>%
  
  mutate(
    group = if_else(
      metabolite %in% hormone_metabolites,
      "Hormone",
      group
    )
  )


## -----------------------------------------------------------------------------------------------------------------------------
# ============================================================
# ADD PARTICIPANT INFO
# ============================================================

data_long <- postprandial_long %>%
  
  left_join(
    participant_info,
    by = "COPSACNO"
  ) %>%
  
  mutate(
    cycle_phase = if_else(
      PROG > 0.7,
      "Luteal",
      "Follicular"
    ),
    
    timepoint = factor(timepoint)
  ) %>%
  
  rename(
    COPSACID     = COPSACNO,
    estrogen     = ESTRA,
    progesterone = PROG
  )


## -----------------------------------------------------------------------------------------------------------------------------
# ============================================================
# FINAL NA DIAGNOSTICS
# ============================================================

# REmove na in baseline and rise_value
data <- data_long %>% 
  filter(
    !is.na(baseline)
  ) %>% 
  rename(BMI = bmi)%>% 
  
  # LOG TRANSFORM progesterone
  mutate(
    progesterone_log = log(progesterone),
    estrogen_log = log(estrogen)
  )

model_data <- data

#colSums(is.na(data))

# ::: STATS :::
# PARTICIPANTS: 122
# METABOLITES: 86
# TOTAL OBS: 71789


# ============================================================
# TIDYING UP
# ============================================================

remove(sex_hormones, participant_info, pp_hormones1, pp_hormones2, pp_hormones, hormone_metabolites, metabolite_info, metabolites, participant_ids, baseline_values, nmr_long, outlier_summary, nmr_long_clean, postprandial_long, data_long)
