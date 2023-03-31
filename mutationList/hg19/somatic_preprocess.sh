#!/bin/bash
# raw data has been instored at the following  ${project_dir} already
# USAGE : bash $0 <project directory>
# project_dir=/lustre/home/acct-medkwf/medkwf4/data/MRD/test_Pfizer
# cervical cancer dir: /lustre/home/acct-medkwf/medkwf/ncbi/public/sra/acclist/PRJNA305342_PE/raw


project_dir=$1

for sample in `ls -l ${project_dir} | awk '{print  $9}' | grep -E "_R1.fastq.gz$" | uniq`
#for sample in `ls -l ${project_dir} | awk '{print  $9}' | grep -E "_1.fastq.gz$" | uniq`
do
  R1=${project_dir}/${sample}
  R2=${project_dir}/${sample/_R1/_R2}
  echo -e "Sample is ${sample/_R1.fastq.gz/}"
 if
  [[ $sample == *""* ]]; then
    echo "running analysis on ${sample/_1.fastq.gz/}"
    sbatch /dssg/home/acct-medkwf/medkwf4/script/MRD/mutationList/hg19/somatic_preprocess.slurm ${R1} ${R2} ${sample} ${project_dir}
 fi
done

