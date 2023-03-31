#!/bin/bash
# raw data has been instored at the following  ${project_dir} already
# USAGE : bash $0 <project directory> <working_directory>
# project_dir=/lustre/home/acct-medkwf/medkwf4/data/MRD/test_Pfizer
# cervical cancer dir: /lustre/home/acct-medkwf/medkwf/ncbi/public/sra/acclist/PRJNA305342_PE/raw
# working dir: /lustre/home/acct-medkwf/medkwf4/results/MRD/CC_data/SRR3862151

project_dir=$1
working_dir=$2

mkdir -p ${working_dir}

for sample in `ls -l ${project_dir} | awk '{print  $9}' | grep -E "_1.fastq.gz$" | uniq`
do
  R1=${project_dir}/${sample}
  R2=${project_dir}/${sample/_1/_2}
  echo -e "Sample is ${sample/_1.fastq.gz/}"
 if
  [[ $sample == *"SRR3862151"* ]]; then
    echo "running analysis on ${sample/_1.fastq.gz/}"
    sbatch /lustre/home/acct-medkwf/medkwf4/script/MRD/somatic_preprocess_new.slurm ${R1} ${R2} ${sample} ${project_dir} ${working_dir}
 fi
done

