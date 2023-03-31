#!/bin/bash
# raw data has been instored at the following  ${project_dir} already
# USAGE : bash $0 <project directory>
# trail1: /lustre/home/acct-medkwf/medkwf/cgdata/DNA/cancer/MRD/preliminaryRD/50-R0254673-H-R22007580-202203071624-1
#         /lustre/home/acct-medkwf/medkwf/cgdata/DNA/cancer/MRD/preliminaryRD/50-R0254673-L-R22007579-202203101553-2
# trail2: /lustre/home/acct-medkwf/medkwf4/data/MRD/standards/25-R0254673-H-R22009118-202203191247-1
#         /lustre/home/acct-medkwf/medkwf4/data/MRD/standards/25-R0254673-L-R22009117-202203191247-1

project_dir=$1

for sample in `ls -l ${project_dir} | awk '{print  $9}' | grep ^Sample_ | uniq`
do
  R1=${project_dir}/${sample}/*_R1.fastq.gz
  R2=${project_dir}/${sample}/*_R2.fastq.gz
  echo -e "Sample is ${sample}"
 if
  [[ $sample == *"Sample_R22009118-25-R0254673-H-50-R0254673-H"* ]]; then
  #[[ $sample == *"Sample_R22009117-25-R0254673-L-50-R0254673-L"* ]]; then
    echo "running analysis on ${sample}"
    #sbatch /lustre/home/acct-medkwf/medkwf4/script/MRD/plasma/cfDNA_preprocess.slurm ${R1} ${R2} ${sample} ${project_dir}
    sbatch /lustre/home/acct-medkwf/medkwf4/script/MRD/plasma/cfDNA_preprocess2.slurm ${R1} ${R2} ${sample} ${project_dir}
 fi
done
