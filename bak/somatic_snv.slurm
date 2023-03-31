#!/bin/bash

#SBATCH --mail-type=end
#SBATCH --mail-user=zly18810602991@163.com
#SBATCH --job-name=test
#SBATCH --partition=small
#SBATCH -N 1
#SBATCH -J mpileup
#SBATCH --ntasks-per-node=8
#SBATCH --output=%j.o
#SBATCH --error=%j.e

# Initialize a variable with an intuitive name to store the name of the input fastq file

tumor=$1
normal=$2
project_dir=$3

# Data from Pfizer
baseSuper=`basename ${tumor} .tumor.1.bqsr.bam`
base=$(echo ${baseSuper} | cut -d'_' -f 1)  # get the filename with basename function
echo ${base}
echo ${tumor}
echo ${normal}

# Directory with reference genome
genome_19=/lustre/home/acct-medkwf/medkwf/database/GATK/hg19/ucsc.hg19.fasta

# Make dirs
mkdir -p ~/results/MRD/samtools/
mkdir -p ~/results/MRD/bam-readcount/
mkdir -p ~/results/MRD/Strelka/${base}/
mkdir -p ~/results/MRD/Mutect2/
mkdir -p ~/results/MRD/VarDict/
mkdir -p ~/results/MRD/bed/

# Set up output file names
bam=~/results/MRD/bam_19
varscan=~/results/MRD/varscan2
annovar=~/results/MRD/annovar
samtools=~/results/MRD/samtools
BRC=~/results/MRD/bam-readcount
Strelka=~/results/MRD/Strelka/${base}
Mutect2=~/results/MRD/Mutect2
VarDict=~/results/MRD/VarDict
VarDictPath=/lustre/home/acct-medkwf/medkwf4/software/vardict/share/vardict-2019.06.04-0
bed=~/results/MRD/bed

# Set up file names
tumor_mpileup=${varscan}/${base}.tumor.mpileup
normal_mpileup=${varscan}/${base}.normal.mpileup
out_snv=${varscan}/${base}.somatic.vcf
filter_snv=${varscan}/${base}.filtersnv.vcf.str10
normal_tumor_mpileup=${samtools}/${base}.normal-tumor.mpileup
tumor_sorted=${samtools}/${base}.sortedtumor.bam
normal_sorted=${samtools}/${base}.sortednormal.bam
filter_indel=${varscan}/${base}.filterindel.vcf
annovar_aviinput=${annovar}/${base}.snv
annovar_indel_aviinput=${annovar}/${base}.indel
annovar_merged_input=${annovar}/${base}.merge
annovar_annotated=${annovar}/${base}.csv
BRC_list=${BRC}/${base}.variants.sites
BRC_readcount=${BRC}/${base}.readcount
fpfilter=${varscan}/${base}.fpfilter
output_Mutect=${Mutect2}/${base}.mutect2.vcf.gz
normal_name=${Mutect2}/${base}.normalname.txt
tumor_name=${Mutect2}/${base}.tumorname.txt
filter_Mutect=${Mutect2}/${base}.filter.vcf.gz
output_Strelka=${Strelka}/results/variants/somatic.snv.2.vcf
annovar_aviinput_Strelka=${annovar}/${base}.2.strelka
annovar_annotated_Strelka=${annovar}/${base}.2.strelka.csv
output_Mutect2=${Mutect2}/${base}.mutect2.1.vcf
annovar_aviinput_Mutect2=${annovar}/${base}.mutect2
annovar_annotated_Mutect2=${annovar}/${base}.mutect2.csv
output_Varscan=${varscan}/P042.filtersnv.vcf.str10.1
annovar_aviinput_Varscan=${annovar}/${base}.Varscan
annovar_annotated_Varscan=${annovar}/${base}.Varscan.str10.csv
tumor_bed=${bed}/${base}.sorted.bed
VarDict_out=${VarDict}/${base}.VarDict.vcf
refbed=/lustre/home/acct-medkwf/medkwf4/reference/bed/nexterarapidcapture_exome_targetedregions.bed

# Set up the software environment
export IMAGE_NAME=/lustre/share/img/gatk-4.2.2.0.sif
module load picard
module load bwa
module load samtools
module load bedtools2
module load miniconda3/4.7.12.1-gcc-4.8.5
source activate R



# specify the number of cores to use
cores=4

# Sort and index the bam file for input
#samtools sort -o ${tumor_sorted} -@ $cores ${tumor}
#samtools sort -o ${normal_sorted} -@ $cores ${normal}
#samtools index -b ${tumor_sorted}
#samtools index -b ${normal_sorted}

# Use Varscan2
# pieup firstly (necessary for Varscan2)
# -q, --min-MQ INT Minimum mapping quality for an alignment to be used [0]
# -C, --adjust-MQ INT
#samtools mpileup -f ${genome_19} -B -C 50 -q 20 -Q 20 -x ${normal_sorted} ${tumor_sorted}> ${normal_tumor_mpileup}
#samtools mpileup -f ${genome_19} -A -Q 0 -x -l /lustre/home/acct-medkwf/medkwf4/reference/bed/nexterarapidcapture_exome_targetedregions_SMAD4.bed ${normal_sorted} ${tumor_sorted}  > ${normal_tumor_mpileup}.test3

#java -jar ~/VarScan.v2.3.9.jar somatic \
#${normal_tumor_mpileup} \
#${out_snv}.test.str10 \
#--mpileup 1 \
#--output-vcf 1 \
#--min-coverage-normal 10 \
#--min-var-freq 0.01 \
#--tumor-purity 0.5
#--validation 1 \
#--strand-filter 1

# Filter as recommended by official doc https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4278659/
# Region should be specified otherwise the output file is super large and cost much time
#singularity exec /lustre/home/acct-medkwf/medkwf4/software/bam-readcount.sif bam-readcount \
#-q 20 \
#-b 20 \
#-w 100 \
#-f ${genome_19} \
#-l /lustre/home/acct-medkwf/medkwf4/reference/bed/nexterarapidcapture_exome_targetedregions_4bamreadcount.txt \
#${tumor_sorted} > ${BRC_readcount}
#perl /lustre/home/acct-medkwf/medkwf4/software/fpfilter.pl ${BRC_readcount} --output-basename ${fpfilter}

# Filter manually and use somaticFilter 
# 2022/1/4 for mpileup -X results
# somaticFilter could be used after some manually filtering steps. Just give it a vcf file in the varscan2 ouput format
#awk '{split($8,a,/;/); if (a[2]=="SOMATIC") print $0}' P047.somatic.vcf.snp > P047.somatic.1.vcf
#awk '{split($8,a,/;/); if (a[2]=="SOMATIC") print $0}' P047.somatic.vcf.indel >> P047.somatic.1.vcf
#awk '{split($10,a,/:/); gsub("%", "", a[6]);} a[6]+0 <= 1{print $0;}' P047.somatic.1.vcf > P047.somatic.2.vcf
#grep "#" P047.somatic.vcf.snp > P047.somatic.3.vcf
#cat P047.somatic.2.vcf >> P047.somatic.3.vcf
#java -jar ~/VarScan.v2.3.9.jar somaticFilter ${varscan}/P042.somatic.str10.3.vcf \
#--min-var-freq  0.01 \
#--min-coverage 20 \
#--output-file ${filter_snv}
#grep "#" P042.filtersnv.vcf.str10 > P042.filtersnv.vcf.str10.1
#awk '{split($10,a,/:/); gsub("%", "", a[6]);} a[6]+0 <= 1{print $0;}' P042.filtersnv.vcf.str10 >>  P042.filtersnv.vcf.str10.1

# Use Mutect2
#singularity exec $IMAGE_NAME gatk --java-options "-Xmx128G" \
#GetSampleName \
#-R ${genome_19} \
#-I ${normal} \
#-O ${normal_name} \
#-encode

#singularity exec $IMAGE_NAME gatk --java-options "-Xmx128G" Mutect2 \
#-R ${genome_19} \
#-I ${tumor_sorted} \
#-I ${normal_sorted} \
#-normal `cat ${normal_name}` \
#-O ${output_Mutect}

#singularity exec $IMAGE_NAME gatk --java-options "-Xmx128G" \
#FilterMutectCalls \
#-R ${genome_19} \
#-V ${output_Mutect} \
#-O ${filter_Mutect} \
#--min-median-base-quality 20 \
#--min-median-mapping-quality 20 

# Filter the Mutect2 result (followed by Cambridge's paper)
# test
#zcat P042.filter.vcf.gz | grep -vE "^#" | awk '{n=split($8,a,/;/);split(a[n],b,/=/);}b[2]+0 > 5.3{print b[2]}' | wc -l


# Use Strelka
#/lustre/home/acct-medkwf/medkwf4/software/strelka-2.9.2.centos6_x86_64/bin/configureStrelkaSomaticWorkflow.py \
#--normalBam ${normal_sorted} \
#--tumorBam ${tumor_sorted} \
#--referenceFasta ${genome_19} \
#--runDir ${Strelka}

#${Strelka}/runWorkflow.py -m local -j 20

#------------------------------------------------------------------------
# For Strelka result
# Filter manually before doing the annotation
#------------------------------------------------------------------------
#zcat somatic.snvs.vcf.gz | grep -v "^#" | awk '$7=="PASS"' > somatic.snv.1.vcf
#zcat somatic.indels.vcf.gz | grep -v "^#" | awk '$7=="PASS"' >> somatic.snv.1.vcf
#awk '{split($10,a,/:/); split($11,b,/:/);}a[1]+0 >= 30 && b[1]+0 >= 30{print $0;}' somatic.snv.1.vcf > somatic.snv.2.vcf

# Use VarDict

#bedtools bamtobed -i ${tumor_sorted} > ${tumor_bed}
#AF_THR="0.01" # minimum allele frequency
#perl ${VarDictPath}/vardict -G ${genome_19} -f $AF_THR -b "${tumor_sorted}|${normal_sorted}" -c 1 -S 2 -E 3 -g 4 ${refbed} | Rscript ${VarDictPath}/testsomatic.R | perl ${VarDictPath}/var2vcf_paired.pl -N "${tumor_sorted}|${normal_sorted}" -f $AF_THR > ${VarDict_out}.test

#------------------------------------------------------------------------
# Annotation
#------------------------------------------------------------------------
/lustre/home/acct-medkwf/medkwf4/software/annovar/convert2annovar.pl --format vcf4old --includeinfo --withzyg ${output_Varscan} > ${annovar_aviinput_Varscan}
/lustre/home/acct-medkwf/medkwf4/software/annovar/table_annovar.pl ${annovar_aviinput_Varscan} /lustre/home/acct-medkwf/medkwf4/software/annovar/humandb -buildver hg19 -out ${annovar_annotated_Varscan} -polish -remove -protocol refGene,icgc28,gnomad_exome,EAS.sites.2014_10,avsnp144,EAS.sites.2015_08,cosmic70,nci60  -operation g,f,f,f,f,f,f,f --otherinfo -csvout

# Annotation
#/lustre/home/acct-medkwf/medkwf4/software/annovar/convert2annovar.pl --format vcf4 --includeinfo --withzyg ${filter_snv} > ${annovar_aviinput}
#/lustre/home/acct-medkwf/medkwf4/software/annovar/convert2annovar.pl --format vcf4 --includeinfo --withzyg ${filter_indel} > ${annovar_indel_aviinput}
#cat ${annovar_aviinput} ${annovar_indel_aviinput} > ${annovar_merged_input}
#/lustre/home/acct-medkwf/medkwf4/software/annovar/table_annovar.pl ${annovar_merged_input} /lustre/home/acct-medkwf/medkwf4/software/annovar/humandb -buildver hg19 -out ${annovar_annotated} -polish -remove -protocol refGene,icgc28,gnomad_exome,EAS.sites.2014_10,avsnp144,EAS.sites.2015_08,cosmic70,nci60  -operation g,f,f,f,f,f,f,f --otherinfo -csvout

