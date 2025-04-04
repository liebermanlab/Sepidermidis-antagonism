**Instructions for Use**

**Image Analysis** 
This code is designed for any 96-well format spot-on-lawn experiment.
1.	Copy the �Template for Image Analysis� folder, note that it contains some example data
2.	Open �auto_ZOI_analysis� in MATLAB
3.	Set imagedir (line 10) and params (lines 44-52) according to your imaging setup
4.	See comments in code for how to skip specific steps of the analysis by listing filenames (useful for pausing partway through analysis or rerunning specific steps)

**Interaction Analysis & Plotting** 
This code is designed to generate the plots in the manuscript. While some functions may be helpful for analyzing the results of the �Image Analysis� code for new experiments, it has a lot of manuscript specific datasets and dependencies that will not be relevant for your analysis. It is provided for users to explore the data in the manuscript
1.	Copy the �Interaction Analysis� folder
2.	Set parameters in lines 13-52
3.	Choose which plots to generate by setting a unique nonzero fignum for desired plots

**Bioinformatic Analysis**
These pipelines are designed to work on the MIT Engaging computing cluster (a SLURM system), they will need significant modifications before running on your system. Pre-computed results and links are available in the �local_pangenome_enrichment_analysis� folder. Pre-computed tables used for plotting can be found in the �Interaction Analysis/data_for_code� folder.
1.	Download raw isolate reads
2.	Run snakemake_assembly_annotation pipeline (see readme_pipeline_instructions.txt in folder)
3.	Run snakemake_gainloss_analysis pipeline (see readme_pipeline_instructions.txt in folder)
4.	Run snakemake_pangenome_and_BGC pipeline (see readme_pipeline_instructions.txt in folder)
5.	Download specified results to local_pangenome_enrichment_analysis
6.	Run extract_consensus_proteins.py
7.	Submit consensus_proteins.faa to reference database searches (e.g. VFDB)
8.	Run calculate_pangenome_enrichment.py
9.	Optional: run snakemake_breseq_lineage37
