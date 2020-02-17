#this script integrates gene-disease, drug-disease and drug-gene results
#obtained from Open Targets to get a drug-gene-disease network with
#potentially novel drugs for PNDs to be curated

#necessary packages
library(dplyr)
library(reticulate)
library(igraph)
library(tibble)
library(stringr)
options(stringsAsFactors = F)

#set working directory
dir <- "~/Área de Trabalho/GitHub_projects/OpenTargets_drug_repositioning/"
setwd(dir)

data("01_gene-diseases")
data("02_drug-diseases")
known_drugs <- unique(drug_disease_OT_searches$Source)
data("03_exclusive_gene-diseases")
data("04_drug-exclusive_genes")
colnames(exclusive_genes_drugs) <- c("Source","Target")

#filter out genes that are not coexpressed in PNDs according to Gandal 2018
exclusive_genes <- exclusive_genes_edges$Source

gandal_2018a_kMEs <- read.csv("data/gandal_2018a_kMEs.csv",dec = ",")
coex_genes <- gandal_2018a_kMEs %>%
  filter(Module.name!="CD0") %>%
  pull(external_gene_id)

exclusive_genes_coex <- intersect(exclusive_genes,coex_genes)
save(exclusive_genes_coex,file = "data/05_exclusive_genes_coex.RData")
exclusive_genes_coex_edges <- exclusive_genes_edges %>%
  filter(Source %in% exclusive_genes_coex)

write.csv(exclusive_genes_coex_edges,file="data/05_exclusive_genes_coex.csv",row.names = F)

#get drugs that affect coexpressed exclusive genes
drug_genes_edges <- exclusive_genes_drugs %>%
  filter(Target %in% exclusive_genes_coex)

#count remaining drugs and genes
length(unique(drug_genes_edges$Source))
length(unique(drug_genes_edges$Target))

#prepare files to calculate degree and filter out drugs that affect more than
#one gene
drug_genes_nodes <- data.frame(Id=c(unique(c(drug_genes_edges$Source,drug_genes_edges$Target))),
                               Class=c(rep("DRUG",8796),rep("GENE",122)))

drug_genes_graph <- graph_from_data_frame(drug_genes_edges,
                                          directed = F,
                                          vertices = drug_genes_nodes)

drug_gene_degree <- as.data.frame(degree(drug_genes_graph)) %>%
  rownames_to_column("Id")

drug_gene_degree <- merge(drug_gene_degree,drug_genes_nodes,
                          by="Id")

#get the name of drugs that affect only one gene
exclusive_drugs <- drug_gene_degree %>%
  filter(Class=="DRUG" & `degree(drug_genes_graph)`==1) %>%
  pull(Id) %>%
  unique()

#make dataframe with only drugs that affect one gene
drug_genes_edges_exclusive <- drug_genes_edges %>%
  filter(Source %in% exclusive_drugs) %>%
  filter(!Source %in% known_drugs)

final_drugs <- unique(drug_genes_edges_exclusive$Source)
#save(final_drugs,file="data/06_final_drugs.RData")

#count how many drugs and genes remained
length(unique(drug_genes_edges_exclusive$Source))
length(unique(drug_genes_edges_exclusive$Target))

#make edges and nodes files to plot final drug-gene-disease networks in Gephi
final_genes_dis_edges <- exclusive_genes_coex_edges[,-3] %>%
  filter(Source %in% unique(drug_genes_edges_exclusive$Target))

drug_exclusive_genes_disease_edges <- as.data.frame(rbind(drug_genes_edges_exclusive,final_genes_dis_edges))

drug_exclusive_genes_disease_nodes <- data.frame(Id=unique(c(drug_exclusive_genes_disease_edges$Source,
                                                             drug_exclusive_genes_disease_edges$Target)),
                                                 Label=unique(c(drug_exclusive_genes_disease_edges$Source,
                                                                drug_exclusive_genes_disease_edges$Target)),
                                                 Class=c(rep("DRUG",4670),rep("GENE",69),rep("DISEASE",7))) 

write.csv(drug_exclusive_genes_disease_edges,file = "data/gephi/drug_exclusive_genes_disease_edges.csv",row.names = F)
write.csv(drug_exclusive_genes_disease_nodes,file = "data/gephi/drug_exclusive_genes_disease_nodes.csv",row.names = F)

#make files to be manually curated
drug_exclusive_genes_disease_curate <- merge(drug_genes_edges_exclusive,exclusive_genes_edges[,-3],
                                             by.x="Target",by.y="Source") %>%
  mutate(Drug=Source,Gene=Target,Disease=Target.y) %>%
  select(Drug,Gene,Disease)

save(drug_exclusive_genes_disease_curate,file="data/06_drug_exclusive_gene_disease_curate.RData")  
write.csv(drug_exclusive_genes_disease_curate,file="data/06_drug_exclusive_gene_disease_curate.csv",row.names = F)
