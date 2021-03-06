#!/bin/bash

R1="$1"
R2="$2"
#OutDir="$3"
#OutDir1="$4"

OutDir=$(basename $R1 001.fastq.gz)trimmed.fastq.gz
OutDir1=$(basename $R2 001.fastq.gz)trimmed.fastq.gz

fsname=$(basename $OutDir _L001_R1_trimmed.fastq.gz)
mkdir ${fsname}_fastp_output

#tell bash where to find conda
export MYCONDAPATH=/home/bsalehe/miniconda3

#activate  fastp
source ${MYCONDAPATH}/bin/activate fastp

#run commands using your tools here
die(){
	local m="$1"
	local m1="$2"
	local err=$3
	echo "$m or $m1"
	exit $err
}

[ $# -eq 0 ] && die "Usage: fastp.sh <filename_R1.gz>" "Usage: fastp.sh <filename_R1.gz> <filename_R2.gz>" 1


echo "Start running fastp..."

#if [ $# -eq 2 ]; then ## For PE reads
	fastp -i "$R1" -I "$R2" --correction --trim_front1=10 --trim_front2=10 --trim_tail1=10 --trim_tail2=10 --cut_mean_quality=15 -5 -3 -r -o $OutDir -O $OutDir1 
#check if the file is one and single-end
#elif [ $# -eq 1 ]; then  ## For SE reads
#	fastp -i $R1 -o $OutDir
#else echo "fastp didn't run" 
#exit 1
#fi
cp *.html ${fsname}_fastp_output
cp *.json ${fsname}_fastp_output
rm *.html *.json

current_time=$(date "+%Y%m%d%H%M%S")
mkdir -p /data/scratch/bsalehe/canker_cherry_pipeline_output/assembly_pre-processing/$current_time

cp -r ${fsname}_fastp_output /data/scratch/bsalehe/canker_cherry_pipeline_output/assembly_pre-processing/$current_time
rm -rf ${fsname}_fastp_output
#
#deactivate fastp
conda deactivate
