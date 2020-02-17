# OpenTargets_drug_repositioning
The scripts in this repository perform the following tasks necessary for the drug repositioning steps using Open Targets performed in the manuscript "Drug repositioning for psychiatric and neurological disorders through a network medicine approach":

01 - search Open Targets for every gene associated to a list of diseases (here: PNDs - Psychiatric and Neurological Disorders);

02 - search Open Targets for every drug associated to a list of diseases (here: PNDs - Psychiatric and Neurological Disorders);

03 - detect genes that are exclusive to each diseases;

04 - search Open Targets for drugs that affect the disease-exclusive genes detected in 03;

05 - filter results from 04 to keep only drugs that:

a) affect genes that are coexpressed in the group of diseases (here: genes coexpressed in PNDs according to Gandal, 2018a);

b) are not present in network 02;

c) affect only one gene among all searched genes;

06 - produce a drug-gene-disease table to be used for drug prioritization for repositioning in PNDs.

Authors:
Thomaz Lüscher Dias, Helena Paula Brentani, Viviane Schuch, Patrícia Cristina Baleeiro Beltrão Braga, Daniel Martins-de-Souza, Glória Regina Franco, Helder Imoto Nakaya

Manuscript submitted to Translational Psychiatry. In review.
