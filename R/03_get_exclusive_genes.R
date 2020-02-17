#this script uses gene-disease Open Targets association files to 
#get exclusive genes associated with each disease

#necessary packages
library(dplyr)
library(igraph)
library(tibble)
options(stringsAsFactors = F)

#set working directory where all necessary files are located
dir <- "~/Área de Trabalho/GitHub_projects/OpenTargets_drug_repositioning/"
setwd(dir)

#load manipulated gene-disease association files from data
data("01_gene-diseases")

OT_edges_filtered <- gene_disease_OT_searches %>%
  filter(score > 0.5)

#get the genes that are exclusive to each disease (not shared: degree = 1)
graph <- graph_from_data_frame(OT_edges_filtered,directed = F)
degree <- as.data.frame(degree(graph)) %>%
  rownames_to_column(var = "node")
colnames(degree) <- c("node","degree")
degree <- degree %>%
  filter(degree==1)

exclusive_genes <- degree$node[degree$degree==1]

exclusive_genes_edges <- OT_edges_filtered %>%
  filter(Source %in% exclusive_genes)

save(exclusive_genes_edges,file = "data/03_exclusive_gene-diseases.RData")

load("data/03_exclusive_gene-diseases.RData")
write.csv(exclusive_genes_edges,file="data/03_exclusive_gene-diseases.csv",row.names = F)

