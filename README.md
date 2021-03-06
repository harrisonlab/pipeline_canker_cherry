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

READSDATADIR path where the inputs  reads or assambled fasta are located.
Example `READSDATADIR=/home/bsalehe/canker_cherry/data/yang/`
If READSDATADIR contains already assembled files then comment out lines 42 - 65, and 74. Uncomment lines 72 and 73.

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

Please change `PROKKA_OUT` path variable in the prokka_ps.sh script accordingly. The path store the annotation files which are used for other downstream analysis. Basically, the PROKKA_OUT store the same path as PROKKAOUTDIR. Prokka requires that the directory for storing annotation files should not exist before. Also please make sure you change the fasta format extension in the psname variable accordingly.

In the second phase the pipeline is expected to do the following:
- Taking the output from Prokka and use them to predict potential T3SS effectors. 
- Predicting prophages, genomic islands, and orthologoues analysis. Genomic islands identification is done by using IslandViewer 4 (https://www.pathogenomics.sfu.ca/islandviewer/http_api/) integrated within genomicislands.sh script. The prediction of prophage is done by using PHASTER.
The OrthoFinder 2.5.4 (https://github.com/davidemms/OrthoFinder/releases/tag/2.5.4) was used to perform the orthologous analysis.

## General location for pipeline Outputs
The paths for pipeline outputs are:

### Preprocessing and assembly 
- `/data/scratch/bsalehe/canker_cherry_pipeline_output/assembly_pre-processing`

### Annotation
- `PROKKA : /data/scratch/bsalehe/prokka_out/`

### Downstream analysis: Effectors, Genomic islands, Prophage & Orthologues
- `/data/scratch/bsalehe/canker_cherry_pipeline_output/analysis`

You may also need to change the following output path directories in the following scripts:
- EFECTIVE_T3_OUTDIR : effective_t3.sh.
- MACSYF_OUT : macsyf.sh
- ORTHOFINDER_DIR : orthofinder.sh ## This directory should not exist before.
For instance, in `ORTHOFINDER_DIR="/dir/to/orthofinder/"`, the directory "orthofinder" should not exist before running Orthofinder program. Also, before running the pipeline,  please copy the annotation fasta files from PROKKAOUTDIR into another separate directory which will be used as input directory for orthofinder.

In running `genomicislands.sh`, please change the directory PROKKAOUTDIR accordingly. It is better to run it outside the pipeline by typing `bash ./genomicislands.sh`. This is because if it is run within pipeline script (pipeline.sh), it gives error "ModuleNotFoundError: No module named 'requests_toolbelt'", which requires a super user to sort this out as indicated in this link https://stackoverflow.com/a/56416843.

For phages identification the script "phaster.py" was adopted from https://github.com/boulund/phaster_scripts, which sends batch files under ths hood to PHASTER servers (http://phaster.ca/). The results are sent to the Web client for viewing and download. The "phaster.py" was integrated to the pipeline.

### General procedure for running blast after T3 effector prediction
We have used BLASTP for improving the T3 effectors prediction results. For instance, when runnin pipeline for T3 prediction using Deepredeff, the results are literally in CSV format. 
- The original CSV file from each Deepreff output is formatted first using this protocl (protocol_filtering_deepredeff_results.txt).
- Then the sequences are extracted using this command `for file in *_deepredeff_result_.csv ; do  name=$(basename $file .csv); awk -F, 'NR>1 {print ">"$2 "\n" $3}' $file > ${name}sequence.fasta; done`
- Then BLASTP is performed usin the script 'blastp.sh'.
- The potential hits with their sequences are retrieved using python script 'get_hits.py'.
- - E.g `python3 get_hits.py /data/outputs_of_blastp.txt /data/sequences_of_the_blastp_hits.txt /data/deepredeff_dir/retrieved_sequences_from_deepredeff.fasta`
- The file /data/sequences_of_the_blastp_hits.txt is the final outputs of the predicted T3 effectors sequences out of all sequences from the Deepredeff predictions. The files /data/outputs_of_blastp.txt and /data/sequences_of_the_blastp_hits.txt are the outputs from blastp, and sequences of the predicted effectors from the Dwepredeff after blastp respectively.
The blastp database that was used is from the supplimentary data of the T3 effectors, the largest todate which is available at the 'https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6460904/'.
