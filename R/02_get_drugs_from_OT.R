#this script searches Open Targets for all drugs related to a list of
#diseases using the OT python client API

#necessary packages
library(dplyr)
library(reticulate)
options(stringsAsFactors = F)

#set working directory
dir <- "~/Área de Trabalho/GitHub_projects/OpenTargets_drug_repositioning/"
setwd(dir)

#get Open Targets codes for each disease
disease_codes <- read.csv("data/19.11_disease_list.csv",col.names = c("code","disease","value"))
data("diseases")
disease_codes_selected <- disease_codes %>%
  filter(toupper(disease) %in% diseases)

#get all known drugs related to each disease in Open Targets
use_python("/usr/bin/python3.5",required=T)
source_python(file = "Py/search_known_drugs_open_targets_in_R.py")
for (i in 1:length(diseases)){
  dis <- diseases[i]
  code <- disease_codes_selected$code[i]
  result <- search_known_drugs(code) 
    mutate(Target=dis) %>%
    rename(Source=drug.molecule_name) %>%
    filter(!is.na(Source))
  result$Source <- as.character(result$Source)
  result <- result %>%
    filter(!duplicated(Source))
  if(i==1){
    drug_disease_OT_searches <- result
  }else{
    drug_disease_OT_searches <- as.data.frame(rbind(drug_disease_OT_searches,result))
  }
  print(i)
}    
  
save(drug_disease_OT_searches,file="data/02_drug-diseases.RData")

load("data/02_drug-diseases.RData")
write.csv(drug_disease_OT_searches,file="data/02_drug-diseases.csv",row.names = F)
