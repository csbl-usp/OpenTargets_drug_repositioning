#this script searches Open Targets for all drugs related to the list of
#exclusive genes related to each disease using the OT python client API

#necessary packages
library(dplyr)
library(reticulate)
options(stringsAsFactors = F)

#set working directory
dir <- "~/Área de Trabalho/GitHub_projects/OpenTargets_drug_repositioning/"
setwd(dir)

#get list of exclusive genes related to each disease
data("03_exclusive_gene-diseases")

use_python("/usr/bin/python3.5",required=T)
source_python(file = "Py/search_new_drugs_open_targets_in_R.py")
for (i in 1:length(exclusive_genes_edges$Source)){
  gene <- exclusive_genes_edges$Source[i]
  result <- search_new_drugs(gene)
  drug_cols <- colnames(result)[grepl("drug",colnames(result))]  
  drugs <- c()
  
  for (j in 1:length(drug_cols)){
    drugs_j <- result %>% 
      select(drug_cols[j]) %>%
      pull(drug_cols[j]) %>%
      unlist()
    drugs <- c(drugs,drugs_j)
  }
  
  if(length(drugs)>0){
    drugs_df <- data.frame(drug=unique(c(drugs)),
                        gene=gene)
    drugs_df$name <- sub(drugs_df$drug,pattern = "-",replacement = "")
    drugs_df$name <- sub(drugs_df$name,pattern = " ",replacement = "")
    drugs_df$name <- toupper(drugs_df$name)
    drugs_df <- drugs_df %>%
      filter(!duplicated(name)) %>%
      select(drug,gene)
    if (i==1){
      exclusive_genes_drugs <- drugs_df
    }else{
      exclusive_genes_drugs <- as.data.frame(rbind(exclusive_genes_drugs,drugs_df))
    }
  }
  print(i)
}

save(exclusive_genes_drugs,file = "data/04_drug-exclusive_genes.RData")

load("data/04_drug-exclusive_genes.RData")
write.csv(exclusive_genes_drugs,file="data/04_drug-exclusive_genes.csv",row.names = F)
