#this script searches Open Targets for all genes related to a list of
#diseases using the OT python client API

#necessary packages
library(dplyr)
library(reticulate)
options(stringsAsFactors = F)

#set working directory
dir <- "~/Área de Trabalho/GitHub_projects/OpenTargets_drug_repositioning//"
setwd(dir)

#diseases to be searched
diseases <- c("ALZHEIMER'S DISEASE",
              "PARKINSONS'S DISEASE",
              "HUNTINGTON DISEASE",
              "DEMENTIA",
              "UNIPOLAR DEPRESSION",
              "ANXIETY DISORDER",
              "BIPOLAR DISORDER",
              "SCHIZOPHRENIA",
              "AUTISM")

save(diseases,file = "data/diseases.RData")

#search Open Targets using python client within R
use_python("/usr/bin/python3.5",required=T)
source_python(file = "Py/search_disease_open_targets_in_R.py")
for (i in 1:length(diseases)){
  disease <- diseases[i]
  result <- search_disease(disease) %>%
    select(target.gene_info.symbol,association_score.overall) %>%
    mutate(Source=target.gene_info.symbol,Target=disease,score=association_score.overall) %>%
    select(Source,Target,score)
  file <- paste0("data/",disease,"_fromAPI_edges.csv")
  write.csv(result,file = file)
  if (i==1){
    gene_disease_OT_searches <- result
  }else{
    gene_disease_OT_searches <- as.data.frame(rbind(gene_disease_OT_searches,result))
  }
  print(i)
}

save(gene_disease_OT_searches,file = "data/01_gene-diseases.RData")

load("data/01_gene-diseases.RData")
write.csv(gene_disease_OT_searches,file = "data/01_gene-diseases.csv",row.names = F)
