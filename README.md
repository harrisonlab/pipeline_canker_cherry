## Epiphytes Canker Cherry Pipeline

The pipeline runs through fastq files to produce predicted effectors which will be used for further downstreaming functional and phylogenetic analysis.

The pipeline has two main phases
### Phase 1: Pre-prcessing, Assembly and Annotation with PROKKA
### Phase 2: T3 effector prediction, phage prediction, genomic island prediction, and orthologs finding.

In the first phase, the pipeline is expected to do the following:
- Pre-processing fastq files using fastp.sh script file running fastp (https://github.com/OpenGene/fastp) tool. The fastp final output will be stored in the same directory where the pipeline script runs.
- Performing genome assembly using SPAdes.sh script file running SPAdes (http://bioinf.spbau.ru/spades).
- Perform coverage analysis using genme_cov.sh which runs cuont.pl.
- Performing assembly quality analysis using quast.sh script running quast (http://quast.sourceforge.net/).
- Performing genome annotation using prokka_ps.sh script running prokka (https://github.com/tseemann/prokka).

The pipeline.sh script file should be in the same directory with other script files.
Before running the pipeline script open it using vim or any text editor and please change accordingly the following variables:-

READSDATADIR path where the sample reads are located.
Example `READSDATADIR=/home/bsalehe/canker_cherry/data/yang/`

QUASTOUTDIR path where the Quast output files are going to be stored.
Example `QUASTOUTDIR="/data/scratch/bsalehe/canker_cherry_pipeline_output/assembly_pre-processing/Tracy/1/"`

PROKKAOUTDIR path where the PROKKA output files are located.
Example `PROKKAOUTDIR="/data/scratch/bsalehe/prokka_out/Tracy/refgenomes/"`

DEEPREDEFFOUTDIR pathe where the Deepredeff output files are going to be stored.
Example `DEEPREDEFFOUTDIR="/data/scratch/bsalehe/canker_cherry_pipeline_output/analysis/Tracy/1/T3/deepredeff"`

Please run the pipeline in the slurm environment by typing the following command:
```
sbatch pipeline.sh
```

The prokka script should be conifgured accordingly:

1. Install ncbi-genome-download tool using conda. This is not needed at the moment
`#conda create -n ncbi_genome_download`
`#conda install -c bioconda ncbi-genome-download`

2. Activate the ncbi-genome-download
`#conda activate ncbi-genome-download`

3. Download ref genomes from ncbi
'#ncbi-genome-download -F genbank --genera "Pseudomonas syringae" bacteria -v --flat-output`

4. Move all gbff.gz to a single folder
`#mv *.gbff.gz refseq/`

5. Decompress files from .gbff.gz to .gbk
```
  #for file in refseq/*.gbff.gz; do
  #     zcat $file > refseq/$(basename $file .gbff.gz).gbk
  #done
```

6. Copy some few genomes to new folder for testing
```
   #mkdir refseq1
   #cp refseq/*.1_C*.gbk refseq1/
```

7. Merge all .gbk files into single gbk file using adapted merge_gbk.py script
```
   #mkdir refseq_merged
   #python merge_gbk.py refseq1/*.gbk > refseq_merged/ps.gbk
```
Step 1 and 2 may be skipped. Step 3 up to 7 may be repeated by uncommenting the prokka_script accordingly excluding step 6.

In the second phase the pipeline is expected to do the following:
- Taking the output from Prokka and use them to predict potential T3SS effectors. 
- Predicting prophage genomic islands, finding whether there are orthologoues and perform phylogenetic analysis. The aim is to identify genomic island regions and predicting availability of phages in the annotated sequences. Genomic islands identification is done by using islandPath DIMOB (https://github.com/brinkmanlab/islandpath) tool which is an integrated method of the islandviewer (https://www.pathogenomics.sfu.ca/islandviewer/browse/) tool. The prediction of prophage is done by using phispy tool (https://github.com/linsalrob/PhiSpy). To work with the tool properly the LOCUS part of the gbk annotation files from prokka was modified using script files 'modify_locus_genbank.sh' and 'modify_locus_genbank.py'. The script 'phage_analysis.sh' is used to predict prophages and it was integrated in the pipeline with its script files named 'pipeline_phase3_phage.sh' and 'pipeline_phase3_phage_ref_strains.sh'
The OrthoFinder 2.5.4 (https://github.com/davidemms/OrthoFinder/releases/tag/2.5.4) was used to perform the orthologous analysis.

## General location for pipeline Outputs
There paths for pipeline outputs are:

### Preprocessing and assembly 
- /data/scratch/bsalehe/canker_cherry_pipeline_output/assembly_pre-processing

### Annotation
- PROKKA : /data/scratch/bsalehe/prokka_out/

### Downstream analysis: Effectors, Genomic islands, Prophage & Orthologues
- /data/scratch/bsalehe/canker_cherry_pipeline_output/analysis

