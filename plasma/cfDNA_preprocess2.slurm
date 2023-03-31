#!/bin/bash

# This script is used for processing the standard sample for MRD project.
# The mapping part simply follows the common steps for NGS seq results

#SBATCH --mail-type=end
#SBATCH --mail-user=zly18810602991@163.com
#SBATCH --job-name=test
#SBATCH --partition=small
#SBATCH -N 1
#SBATCH -J Preprocess
#SBATCH --ntasks-per-node=4
#SBATCH --output=%j.o
#SBATCH --error=%j.e

# Initialize a variable with an intuitive name to store the name of the input fastq file
R1=$1
R2=$2
sample=$3
project_dir=$4
pl=ILLUMINA

# Data from Pfizer
#baseSuper=`basename ${sample} .fastq`
baseSuper=`basename ${sample}`
base=$(echo ${baseSuper} | cut -d'_' -f 2- | cut -d'-' -f 7-)  # get the filename with basename function
echo ${base}

# Directory with reference genome
#genome_19=/lustre/home/acct-medkwf/medkwf/database/GATK/hg19/ucsc.hg19.fasta
#genome_38=/lustre/home/acct-medkwf/medkwf4/reference/GATK/hg38_bundle/Homo_sapiens_assembly38.fasta
genome_38=/lustre/home/acct-medkwf/medkwf/reference/human/GRCh38_Gencode/GRCh38.primary_assembly.genome.fa

# Set working dir
#working_dir=/lustre/home/acct-medkwf/medkwf4/results/MRD/CC_data/${base}
working_dir=/lustre/home/acct-medkwf/medkwf4/results/MRD/standard_trai2_20220406/${base}
mkdir -p ${working_dir}

# Make dirs
mkdir -p ${working_dir}/FastQC/
mkdir -p ${working_dir}/bam_38/
mkdir -p ${working_dir}/interfiles/
mkdir -p ${working_dir}/trim_galore

# Set up output file names
fastqc_out=${working_dir}/FastQC
bam=${working_dir}/bam_38
inter=${working_dir}/interfiles
trim_galore_out=${working_dir}/trim_galore

# Set up file names
align_bam=${bam}/${base}.align.bam
tagfixed_bam=${bam}/${base}.tagfix.bam
align_rmdup=${bam}/${base}.dedup.bam
sort_bam=${bam}/${base}.sort.bam

# Set up the software environment
source activate dna

# specify the number of cores to use
cores=4

# Run FastQC
fastqc -t ${cores} \
${R1} \
-o ${fastqc_out}

fastqc -t ${cores} \
${R2} \
-o ${fastqc_out}

## Run trim_galore for paired end data #--fastqc \
#trim_galore --quality 20 --phred33 \
#--length 20 --stringency 1 --gzip \
#-o ${trim_galore_out} \
#--paired ${R1} ${R2} \
#2> ${trim_galore_out}/${base}.trimgalore.log
#
##-----------------------------------------------------------------------
## Alignment
## -k INT  Minimum seed length. Matches shorter than INT will be missed
## -M Mark shorter split hits as secondary (for Picard compatibility)
##-----------------------------------------------------------------------
#bwa mem -M -R "@RG\tID:${base}\tLB:${base}\tSM:${base}\tPL:$pl" -t ${cores} ${genome_38} ${trim_galore_out}/${base}_combined_R1_val_1.fq.gz ${trim_galore_out}/${base}_combined_R2_val_2.fq.gz | samtools view -hbS -q 0 -@ ${cores} - | samtools sort -o ${align_bam} -@ $cores
#
##-----------------------------------------------------------------------
## Remove duplicates. VALIDATION_STRINGENCY=LENIENT
##-----------------------------------------------------------------------
#picard MarkDuplicates \
#-Xmx20g \
#I=${align_bam} o=${align_rmdup} \
#M=${bam}/marked_dup_metrics.txt \
#REMOVE_DUPLICATES=true \
#VALIDATION_STRINGENCY=STRICT
#
## Index the bqsr.bam files
#samtools sort -o ${sort_bam} -@ $cores ${align_rmdup}
#samtools index ${sort_bam}

