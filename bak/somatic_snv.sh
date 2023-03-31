#!/bin/bash
# run the variant call ready tumor and normal bqsr bam files
# USAGE : bash $0 <project directory>
# project_dir=/lustre/home/acct-medkwf/medkwf4/results/MRD/bam_19
# CC data dir=/lustre/home/acct-medkwf/medkwf4/results/MRD/CC_data/bam_19

project_dir=$1

for sample in `ls -l ${project_dir} | awk '{print  $9}' | grep -E '*SRR3862151.bqsr.bam$' | uniq`
do
  tumor=${project_dir}/${sample}
  normal=${project_dir}/SRR3862147.bqsr.bam
  echo -e "Sample is ${sample/.bqsr.bam/}"
 if
  [[ $sample == *"H009"* ]]; then
    echo "running analysis on ${sample/.bqsr.bam/}"
    sbatch /lustre/home/acct-medkwf/medkwf4/script/MRD/somatic_snv.slurm ${tumor} ${normal} ${project_dir}
 fi
done

