#!/bin/bash

# Use this script to do downstream analysis on plasma clean data

#SBATCH --mail-type=end
#SBATCH --mail-user=zly18810602991@163.com
#SBATCH --job-name=test
#SBATCH --partition=small
#SBATCH -N 1
#SBATCH -J cfDNApost
#SBATCH --ntasks-per-node=4
#SBATCH --output=%j.o
#SBATCH --error=%j.e

# Set input files
work_dir=/lustre/home/acct-medkwf/medkwf4/results/MRD/standard_3_8
#work_dir=/lustre/home/acct-medkwf/medkwf4/results/MRD/standard_3_11_new
bam1=${work_dir}/R22007580-50-R0254673-H-50-R0254673-H-1/bam_38/R22007580-50-R0254673-H-50-R0254673-H-1.sort.bam
bam2=${work_dir}/R22007580-50-R0254673-H-50-R0254673-H-2/bam_38/R22007580-50-R0254673-H-50-R0254673-H-2.sort.bam
bam3=${work_dir}/R22007580-50-R0254673-H-50-R0254673-H-3/bam_38/R22007580-50-R0254673-H-50-R0254673-H-3.sort.bam
bam4=${work_dir}/R22007580-50-R0254673-H-50-R0254673-H-4/bam_38/R22007580-50-R0254673-H-50-R0254673-H-4.sort.bam
#bam1=${work_dir}/R22007579-50-R0254673-L-50-R0254673-L-1/bam_38/R22007579-50-R0254673-L-50-R0254673-L-1.sort.bam
#bam2=${work_dir}/R22007579-50-R0254673-L-50-R0254673-L-2/bam_38/R22007579-50-R0254673-L-50-R0254673-L-2.sort.bam
#bam3=${work_dir}/R22007579-50-R0254673-L-50-R0254673-L-3/bam_38/R22007579-50-R0254673-L-50-R0254673-L-3.sort.bam
#bam4=${work_dir}/R22007579-50-R0254673-L-50-R0254673-L-4/bam_38/R22007579-50-R0254673-L-50-R0254673-L-4.sort.bam

# Set environment
source activate dna

# 50 sites positions
regionBed=/lustre/home/acct-medkwf/medkwf4/reference/bed/50SNVs/MRD0309.txt

# Reference
genome_38=/lustre/home/acct-medkwf/medkwf4/reference/GATK/hg38_bundle/Homo_sapiens_assembly38.fasta
#genome_38=/lustre/home/acct-medkwf/medkwf/reference/human/GRCh38_Gencode/GRCh38.primary_assembly.genome.fa

# Set output files
mkdir -p ${work_dir}/resultMerge
output=${work_dir}/resultMerge/R22007580-50-R0254673-H.mpileup
#output=${work_dir}/resultMerge/R22007579-50-R0254673-L.mpileup

## record site information
# The most lenient threshold (no threshold)
samtools mpileup -A -Q 0 -f ${genome_38} -l ${regionBed} -x ${bam1} ${bam2} ${bam3} ${bam4} > ${output}.lenient

# Same threshold for mutation list
samtools mpileup -f ${genome_38} -l ${regionBed} -q 20 -Q 20 -x ${bam1} ${bam2} ${bam3} ${bam4} > ${output}.strict

