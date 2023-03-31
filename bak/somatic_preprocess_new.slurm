#!/bin/bash

# This script input raw paired fastq files and do the preprocess to get clean bams for variant call.

#SBATCH --mail-type=end
#SBATCH --mail-user=zly18810602991@163.com
#SBATCH --job-name=test
#SBATCH --partition=small
#SBATCH -N 1
#SBATCH -J preNEW
#SBATCH --ntasks-per-node=4
#SBATCH --output=%j.o
#SBATCH --error=%j.e

# Initialize a variable with an intuitive name to store the name of the input fastq file
R1=$1
R2=$2
sample=$3
project_dir=$4
working_dir=$5
pl=ILLUMINA

#baseSuper=`basename ${sample} .fastq`
baseSuper=`basename ${sample} .fastq.gz`
base=$(echo ${baseSuper} | cut -d'_' -f 1)  # get the filename with basename function
echo ${base}

# Directory with reference genome
genome_19=/lustre/home/acct-medkwf/medkwf/database/GATK/hg19/ucsc.hg19.fasta

# Make dirs
mkdir -p ${working_dir}/FastQC/
mkdir -p ${working_dir}/bam_19/
mkdir -p ${working_dir}/interfiles/
mkdir -p ${working_dir}/gatk/
mkdir -p ${working_dir}/trim_galore

# Set up output file names
fastqc_out=${working_dir}/FastQC
bam=${working_dir}/bam_19
inter=${working_dir}/interfiles
gatk=${working_dir}/gatk
trim_galore_out=${working_dir}/trim_galore

# Set up file names
aligned_bam=${bam}/${base}.align.bam
dupmarked_bam=${bam}/${base}.dedup.bam
metrics_txt=${inter}/${base}.dedup.txt
recalibration_tab=${gatk}/${base}.bqsr.tab
bqsr_bam=${bam}/${base}.bqsr.bam
bqsr_sorted=${bam}/${base}.sort.bam

# Set up the software environment
module load miniconda3
source activate dna
#export IMAGE_NAME=/lustre/home/acct-medkwf/medkwf4/software/gatk.v4.2.5.0.sif
module load picard
module load bwa
module load samtools

# specify the number of cores to use
cores=4

echo "Processing file ${R1} ${R2}"
## Run FastQC
#fastqc -t ${cores} \
#${R1} \
#-o ${fastqc_out}
#
#fastqc -t ${cores} \
#${R2} \
#-o ${fastqc_out}
#
## Run trim_galore for paired end data #--fastqc \
#trim_galore --quality 20 --phred33 \
#--length 20 --stringency 1 \
#-o ${trim_galore_out} \
#--paired ${R1} ${R2} \
#2> ${trim_galore_out}/${base}.trimgalore.log
#
## Use bwa for alignment
#bwa mem -K 100000000 -p -v 3 -t 16 -Y ${genome_19} ${trim_galore_out}/${base}_1_val_1.fq.gz ${trim_galore_out}/${base}_1_val_1.fq.gz | samtools view -1 - -o ${aligned_bam}
#
## Mark duplicates
#picard MarkDuplicates \
#INPUT=${aligned_bam} \
#OUTPUT=${dupmarked_bam} \
#METRICS_FILE=${metrics_txt} \
#VALIDATION_STRINGENCY=SILENT \
#OPTICAL_DUPLICATE_PIXEL_DISTANCE=2500 \
#ASSUME_SORT_ORDER="queryname" \
#CREATE_MD5_FILE=false
#
# Generate Base Quality Score Recalibration (BQSR) model
# dbSNP_vcf and known_indels_sites_VCFs? where to get
# -L ~{sep=" -L " sequence_group_interval}
#--use-original-qualities \
gatk --java-options "-Xmx128G" \
BaseRecalibrator \
-R ${genome_19} \
-I ${dupmarked_bam} \
-O ${recalibration_tab} \
--known-sites /lustre/home/acct-medkwf/medkwf/database/GATK/hg19/1000G_omni2.5.hg19.sites.vcf.gz \
--known-sites /lustre/home/acct-medkwf/medkwf/database/GATK/hg19/1000G_phase1.indels.hg19.sites.vcf.gz \
--known-sites /lustre/home/acct-medkwf/medkwf/database/GATK/hg19/dbsnp_138.hg19.excluding_sites_after_129.vcf.gz \
--known-sites /lustre/home/acct-medkwf/medkwf/database/GATK/hg19/1000G_phase1.snps.high_confidence.hg19.sites.vcf.gz \
--known-sites /lustre/home/acct-medkwf/medkwf/database/GATK/hg19/dbsnp_138.hg19.vcf.gz \
--known-sites /lustre/home/acct-medkwf/medkwf/database/GATK/hg19/hapmap_3.3.hg19.sites.vcf.gz \
--known-sites /lustre/home/acct-medkwf/medkwf/database/GATK/hg19/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf.gz

# Apply Base Quality Score Recalibration (BQSR) model
#-L ~{sep=" -L " sequence_group_interval} \
#singularity exec $IMAGE_NAME gatk --java-options "-Xmx128G" \
gatk --java-options "-Xmx128G" \
ApplyBQSR \
-R ${genome_19} \
-I ${dupmarked_bam} \
-O ${bqsr_bam} \
-bqsr ${recalibration_tab} \
--static-quantized-quals 10 --static-quantized-quals 20 --static-quantized-quals 30 \
--add-output-sam-program-record \
-OQ

# sort and index the bam
samtools index ${bqsr_bam}
samtools sort -o ${bqsr_sorted} -@ $cores ${bqsr_bam}
samtools index ${bqsr_sorted}
