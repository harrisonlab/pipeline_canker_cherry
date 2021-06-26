#!/usr/bin/bash
#
prokka_out_fasta="$1"
BEAN_PATH="/home/bsalehe/canker_cherry/software/BEAN-2.0/"
#
#
# Run BEAN2.0
#
perl ${BEAN_PATH}classify.pl $prokka_out_fasta
#
# Copy prediction result file into new file
cp ${BEAN_PATH}prediction_result.txt ${BEAN_PATH}pipeline_bean2.0_prediction_result_$(date +%Y%m%d%s).txt
#
# Copy prediction result new file into final output diectory
cp ${BEAN_PATH}pipeline_bean2.0_prediction_result_$(date +%Y%m%d%s).txt /data/scratch/bsalehe/canker_cherry_pipeline_output/
#
# Remove previous BEAN working output directory
rm -rf ${BEAN_PATH}OUT_work
#
# Copy previous prediction result file into new file
rm ${BEAN_PATH}prediction_result.txt
