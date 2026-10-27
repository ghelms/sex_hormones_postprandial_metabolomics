## Hormones -----------
#Insulin_Cpeptide <-import('.../DietChallenge_insulin_cpeptide.xlsx') %>% 
#  mutate(pid= copsacno, T_min=T_min.) %>%  mutate(across(c(Insulin:`C-peptid`), as.numeric)) %>% subset(select=c('pid', 'T_min', 'Insulin', 'C-peptid')) 

#GIP<-rio::import('.../COPSAC2000_18y_GIP.xlsx') %>% 
#  rename(., 'GIP'='GIP [pM]') %>% subset(select=c('pid', 'T_min', 'GIP'))

#GLP1<-rio::import('.../COPSAC2000_18y_GLP1.xlsx') %>% 
#  rename(., 'GLP1'='GLP-1 [pM]') %>% subset(select=c('pid', 'T_min', 'GLP1'))

#Glucagon<-rio::import('.../COPSAC2000_18y_Glucagon.xlsx') %>% 
#  rename(., 'Glucagon'='Glucagon [pM]') %>% subset(select=c('pid', 'T_min', 'Glucagon'))

#hormones <- Insulin_Cpeptide %>% left_join(GIP, by= c('pid', 'T_min')) %>% left_join(GLP1, by= c('pid', 'T_min')) %>% left_join(Glucagon, by= c('pid', 'T_min')) %>% 
#  pivot_longer(cols = Insulin:Glucagon, names_to = 'met', values_to = 'y') %>% rename(., 'pid2'='pid') %>% arrange(pid2)

# iAUC ---------------------------------------------

##############
# To compute AUCpos for hormones, this script have to be run.

# OBS Need to have loaded the hormones df

# Returns the iAUC_hor df
##############



# get AUC  
getAUC <- function(df,tmax, tol = 0.01){
  
  if (sum(!is.na(df$y))<5){auc <- data.frame(AUC = NA,AUCbl = NA, AUCpos = NA, tmax = NA)} else {
    
    p <- df %>% 
      ggplot(data = .,aes(T_min,y, group = factor(pid2))) + 
      geom_point() + 
      stat_smooth(aes(outfit=fit<<-..y..), se = F)+
      geom_line() 
    res <- ggplot_build(p)$data[[2]]
    
    auc <- res %>% 
      filter(x<=tmax) %>% 
      summarise(AUC = sum(y), 
                AUCbl = sum(y - y[1]),
                AUCpos = sum(pmax(y - y[1], 0))) # Added this line
    d <- res$y - res$y[1]
    d <- sign(d)
    id <- which((d[-1] - d[-length(d)])!=0)
    auc$tmax <- tmax
  }
  return(auc)
}

tm =c(15, 30, 60, 90, 120, 150, 240)
iAUC_hor <- data.frame()

for (i in 1:length(tm) ) {
  feat <- hormones %>% group_by(pid2, met) %>% 
    do(getAUC(df = ., tmax =tm[i]))
  iAUC_hor <- rbind(iAUC_hor, feat)
  remove(feat)
}



