#!/bin/bash
#SBATCH --job-name=meraculous1                # Job name
#SBATCH --partition=batch                # Partition (queue) name
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=300gb
#SBATCH --time=48:00:00		                            # Time limit hrs:min:sec
#SBATCH --output="/home/srb67793/G_maculatum_novogene/log.%j"			    # Location of standard output and error log files
#SBATCH --mail-user=srb67793@uga.edu                    # Where to send mail
#SBATCH --mail-type=END,FAIL                          # Mail events (BEGIN, END, FAIL, ALL)

##################################

#SUMMER BLANCO
#PHD STUDENT, PLANT BIOLOGY
#LEEBENS-MACK & CHANG LABS
#UNIVERSITY OF GEORGIA

#APPLIED GENOME ANALYSIS FALL 2022
#TERM PROJECT
#SAPELO2

##################################

#THIS SCRIPT:
#1) TRIMS G MACULATUM ILLUMINA SHORT READS -- DONE
#2) QC'S G MACULATUM ILLUMINA SHORT READS  -- DONE
#3) ASSEMBLES PLASTOME -- DONE
#4) ANALYZES K-MER DISTRIBUTION -- DONE
#5) ASSEMBLES NUCLEAR GENOME -- RUNNING MERACULOUS
#6) EVALUATES GENOME ASSEMBLY -- WAITING FOR GENOME ASSEMBLY, CODE WRITTEN

##################################
# SET UP
##################################

#set output directory variable
OUTDIR="/scratch/srb67793/G_maculatum"

#if output directory doesn't exist, create it

# if [ ! -d $OUTDIR ]
# then
#     mkdir -p $OUTDIR
# fi
#
# load modules
# module load FastQC/0.11.9-Java-11
# module load MultiQC/1.8-foss-2019b-Python-3.7.4
# module load ml Trimmomatic/0.39-Java-1.8.0_144
# module load GetOrganelle/1.7.5.2-foss-2020b
# module load NOVOPlasty/4.2-GCCcore-8.3.0
# module load BLAST+/2.9.0-gompi-2019b
# module load QUAST/5.0.2-foss-2019b-Python-3.7.4
# module load Jellyfish/2.3.0-GCC-8.3.0
# module load GenomeScope/2.0-foss-2020b-R-4.2.1
# ml Meraculous/2.2.6
# module load SRA-Toolkit/2.11.1-centos_linux64
module load seqkit/0.12.1
module load BWA/0.7.17-GCC-8.3.0
module load SAMtools/1.10-GCC-8.3.0
module load BCFtools/1.10.2-GCC-8.3.0
#
# #Raw reads are in jlm project directory
# #mkdir /scratch/G_maculatum/rawreads
# #On xfer node: scp -r /project/jlmlab/G_maculatum /scratch/G_maculatum/rawreads
#
# ####################################################################
# # 1) TRIMS G MACULATUM ILLUMINA SHORT READS
# ####################################################################
#
# #QC pre-trim with FASTQC & MultiQC (took ~1 hr)
# mkdir $OUTDIR/FastQC
# mkdir $OUTDIR/FastQC/pretrim
# fastqc -o $OUTDIR/FastQC/pretrim/ /home/srb67793/G_maculatum/*.gz
# multiqc $OUTDIR/FastQC/pretrim/*.zip -o $OUTDIR/FastQC/pretrim/
#
# trim reads with trimmomatic
# java -jar $EBROOTTRIMMOMATIC/trimmomatic-0.39.jar PE  -threads 4 \
# /home/srb67793/G_maculatum/OT1_CKDN220054653-1A_HF33VDSX5_L1_1.fq.gz \
# /home/srb67793/G_maculatum/OT1_CKDN220054653-1A_HF33VDSX5_L1_2.fq.gz \
# $OUTDIR/trimmomatic/OT1_CKDN220054653-1A_HF33VDSX5_L1_R1_paired.fq.gz \
# $OUTDIR/trimmomatic/OT1_CKDN220054653-1A_HF33VDSX5_L1_R1_unpaired.fq.gz \
# $OUTDIR/trimmomatic/OT1_CKDN220054653-1A_HF33VDSX5_L1_R2_paired.fq.gz \
# $OUTDIR/trimmomatic/OT1_CKDN220054653-1A_HF33VDSX5_L1_R2_unpaired.fq.gz \
# ILLUMINACLIP:$EBROOTTRIMMOMATIC/adapters/TruSeq3-PE-2.fa:2:30:10 \
# LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
#
# ####################################################################
# # 2) QC'S G MACULATUM ILLUMINA SHORT READS
# ####################################################################
#
# #QC post-trim with FASTQC & MultiQC
# mkdir $OUTDIR/FastQC/trimmed
# fastqc -o $OUTDIR/FastQC/trimmed/ $OUTDIR/trimmomatic/*paired.fq.gz
# multiqc $OUTDIR/FastQC/trimmed/*.zip
#
# ####################################################################
# # 3) ASSEMBLES PLASTOME
# ####################################################################
#
# assemble plastome
# get_organelle_from_reads.py -t 8 -w 99 -R 20 -s /home/srb67793/G_maculatum_novogene/plastome/G_incanum_plastomesequence.fasta -1 $OUTDIR/trimmomatic/OT1_CKDN220054653-1A_HF33VDSX5_L1_R1_paired.fq -2 $OUTDIR/trimmomatic/OT1_CKDN220054653-1A_HF33VDSX5_L1_R2_paired.fq -F embplant_pt -o $OUTDIR/plastome_GetOrganelle2
#
# mkdir $OUTDIR/novoplasty
# cd $OUTDIR/novoplasty #need to be in directory for some reason
# NOVOPlasty4.2.pl -c /home/srb67793/G_maculatum_novogene/scripts/config.txt
# cd /home/srb67793/G_maculatum_novogene
#
# module load Fast-Plast/1.2.8-foss-2019b-Perl-5.30.0
# # mkdir $OUTDIR/FastPlast
# fast-plast.pl -1 $OUTDIR/rawreads/G_maculatum/OT1_CKDN220054653-1A_HF33VDSX5_L1_1.fq.gz -2 $OUTDIR/rawreads/G_maculatum/OT1_CKDN220054653-1A_HF33VDSX5_L1_2.fq.gz –-threads 16 --bowtie_index Geraniales --coverage_analysis
#
# ####################################################################
# # 3) Maps trimmed reads to reference plastome
# ####################################################################
#
# mkdir $OUTDIR/mapping
#
# on local computer
# Geranium incanum plastid, complete genome KT760575.1
# wget -O Desktop/G_incanum.gff "https://www.ncbi.nlm.nih.gov/sviewer/viewer.cgi?db=nuccore&report=gff3&id=KT760575.1"
# #Constructs a BWA index for the reference plastome
# bwa index /home/srb67793/G_maculatum_novogene/plastome/G_incanum_plastomesequence.fasta
#
# #Maps the reads to the reference plastome
# #stores the mapped reads in sorted .bam format
# # bwa mem -t 6 /home/srb67793/G_maculatum_novogene/plastome/G_incanum_plastomesequence.fasta $OUTDIR/trimmomatic/OT1_CKDN220054653-1A_HF33VDSX5_L1_R1_paired.fq $OUTDIR/trimmomatic/OT1_CKDN220054653-1A_HF33VDSX5_L1_R2_paired.fq > $OUTDIR/mapping/G_maculatum.bam
#
# samtools sort $OUTDIR/mapping/G_maculatum.bam -o $OUTDIR/mapping/G_maculatum.sorted.bam
#
# samtools index -@ 6 $OUTDIR/mapping/G_maculatum.sorted.ba12m
#
# #Calls variants from (i) reads with mapping quality greater than 60, excludes variants that have a (ii) quality score of less than 40, and excludes variants that are (iii) supported by fewer than 10 reads for the E. coli C600 genome using `bcftools mpileup`, `bcftools call`, and `bcftools filter` (BCFtools/1.10.2-GCC-8.3.0):
#
# bcftools mpileup -Ou --threads 6 --min-MQ 60 -f /home/srb67793/G_maculatum_novogene/plastome/G_incanum_plastomesequence.fasta \
# $OUTDIR/mapping/G_maculatum.sorted.bam | bcftools call --threads 6 -mv -Ou \
# --ploidy 1 | bcftools filter -Oz -e 'QUAL<40 || DP<10' > \
# $OUTDIR/mapping/G_maculatum.sorted.mpileup.call.filter.onestep.vcf.gz
# bcftools view $OUTDIR/mapping/G_maculatum.sorted.mpileup.call.filter.onestep.vcf.gz
#
# samtools flagstat -@ 6 $OUTDIR/mapping/G_maculatum.sorted.bam > $OUTDIR/mapping/flagstat_G_maculatum.txt
# samtools stats -@ 6 $OUTDIR/mapping/G_maculatum.sorted.bam > $OUTDIR/mapping/stats_G_maculatum.txt
#
# ####################################################################
# # PLASTOME MUMMER PLOTS
# ####################################################################
#
# mkdir $OUTDIR/novomummer
# nucmer /home/srb67793/G_maculatum_novogene/plastome/G_incanum_plastomesequence.fasta $OUTDIR/novoplasty/Contigs_1_NovoTest.fasta -p $OUTDIR/novomummer/nucmer
# delta-filter -1 $OUTDIR/novomummer/nucmer.delta > $OUTDIR/novomummer/nucmer.1delta
# mummerplot --size large -layout --color -f --png $OUTDIR/novomummer/nucmer.1delta -p $OUTDIR/novomummer/nucmer
#
#
# mkdir $OUTDIR/GOmummer
# nucmer /home/srb67793/G_maculatum_novogene/plastome/G_incanum_plastomesequence.fasta $OUTDIR/plastome_GetOrganelle2/embplant_pt.K115.scaffolds.graph1.1.path_sequence.fasta -p $OUTDIR/GOmummer/nucmer
# delta-filter -1 $OUTDIR/GOmummer/nucmer.delta > $OUTDIR/GOmummer/nucmer.1delta
# mummerplot --size large -layout --color -f --png $OUTDIR/GOmummer/nucmer.1delta -p $OUTDIR/GOmummer/nucmer
# ####################################################################
# # 4) NEED TO ANNOTATE PLASTOME
# ####################################################################
#
# BLAST plastome results
# blastn -num_threads 2 -query $OUTDIR/plastome_GetOrganelle/embplant_pt.K115.scaffolds.graph1.1.path_sequence.fasta \
#        -db /db/ncbiblast/nt/06042020/nt \
#        -out $OUTDIR/plastome_GetOrganelle/embplant_pt.K115.fa.blastn.${SLURM_JOB_ID}.tsv \
#        -outfmt 6 \
#        -max_target_seqs 2
# ####################################################################
# # 4) smudgeplot test
# ####################################################################
#
# conda activate smudge_env
# # mkdir $OUTDIR/smudgeplot
# # for k in 19 21 23 25 27 29 31; do
# #   mkdir $OUTDIR/smudgeplot/k${k}
# #   L=$(smudgeplot.py cutoff $OUTDIR/jellyfish/k${k}test.histo L)
# #   U=$(smudgeplot.py cutoff $OUTDIR/jellyfish/k${k}test.histo U)
# #   jellyfish dump -c -L $L -U $U $OUTDIR/jellyfish/k${k}test.jf | smudgeplot.py hetkmers -o $OUTDIR/smudgeplot/k${k}
# for k in 19 ; do
#   # mkdir $OUTDIR/smudgeplot/k${k}
#   L=$(smudgeplot.py cutoff $OUTDIR/jellyfish/k${k}test.histo L)
#   U=$(smudgeplot.py cutoff $OUTDIR/jellyfish/k${k}test.histo U)
#   jellyfish dump -c -L $L -U $U $OUTDIR/jellyfish/k${k}test.jf > $OUTDIR/smudgeplot/k${k}/k${k}testdump.jf
#   smudgeplot.py hetkmers -o $OUTDIR/smudgeplot/k${k} $OUTDIR/smudgeplot/k${k}/k${k}testdump.jf
# done
#
# ####################################################################
# # 5) ANALYZES K-MER DISTRIBUTION
# ####################################################################
#
# # kmer analysis with Jellyfish for loop 19-31-mers
# mkdir $OUTDIR/jellyfish
# gunzip $OUTDIR/trimmomatic/*_paired.fq.gz
#
# for m in 19 21 23 25 27 29 31; do
#   jellyfish count -m $m -s 100M -t 10 -C -F 2 /$OUTDIR/trimmomatic/OT1_CKDN220054653-1A_HF33VDSX5_L1_R1_paired.fq /$OUTDIR/trimmomatic/OT1_CKDN220054653-1A_HF33VDSX5_L1_R2_paired.fq -o /$OUTDIR/jellyfish/k${m}test.jf
#   jellyfish histo -t 10 $OUTDIR/jellyfish/k${m}test.jf -o /$OUTDIR/jellyfish/k${m}test.histo
# done
#
# mkdir $OUTDIR/genomescope2
# for k in 19 21 23 25 27 29 31 33 35 37 39 41 43 45 47 49 51 53 55 57 59 61 63 65 67 69 71; do
#   mkdir $OUTDIR/genomescope2/k${k}
#   genomescope.R -i /scratch/srb67793/G_maculatum/jellyfish/k${k}test.histo -o /scratch/srb67793/G_maculatum/genomescope2/k${k} -k $k
# done
#
# ####################################################################
# # 6) ASSEMBLES NUCLEAR GENOME (testing spades & abyss)
# ####################################################################
#
# mkdir $OUTDIR/meraculous
# mkdir $OUTDIR/meraculous/diploid0test
# source activate ${EBROOTMERACULOUS}
# run_meraculous.sh -c  /home/srb67793/G_maculatum_novogene/scripts/G_maculatum.config -dir /scratch/srb67793/G_maculatum/meraculous/diploid1test -cleanup_level 1
#
# fasta_stats $OUTDIR/meraculous/diploid1test/run_2022-12-04_10h01m10s/meraculous_merblast/contigs.fa > $OUTDIR/meraculous/diploid0test/run_2022-12-04_10h01m10s/meraculous_merblast/fasta_stats.txt

####################################################################
# 8) Maps trimmed reads to meraculous contigs
####################################################################
#
# # first determine scaffold lengths
# seqkit fx2tab --length --name --header-line $OUTDIR/meraculous/diploid0test/run_2022-12-04_10h01m10s/meraculous_final_results/final.scaffolds.fa > scaffold_lengths.txt
#
# # view longest scaffolds
# tail $OUTDIR/meraculous/diploid0test/run_2022-12-04_10h01m10s/meraculous_final_results/scaffold_lengths_sorted.txt
#
# mkdir $OUTDIR/meraculous/diploid0test/mapping
#
# # extract the longest reads
# seqkit grep -p Scaffold51732 $OUTDIR/meraculous/diploid0test/run_2022-12-04_10h01m10s/meraculous_final_results/final.scaffolds.fa > $OUTDIR/meraculous/diploid0test/mapping/Scaffold51732.fasta
# seqkit grep -p Scaffold190046 final.scaffolds.fa > $OUTDIR/meraculous/diploid0test/mapping/Scaffold190046.fasta
# seqkit grep -p Scaffold605022 final.scaffolds.fa > $OUTDIR/meraculous/diploid0test/mapping/Scaffold605022.fasta

# # Constructs a BWA index for the scaffold
# bwa index $OUTDIR/meraculous/diploid0test/mapping/Scaffold51732.fasta
#
# #Maps the reads to the scaffold
# #stores the mapped reads in sorted .bam format
# bwa mem -t 6 $OUTDIR/meraculous/diploid0test/mapping/Scaffold51732.fasta $OUTDIR/trimmomatic/OT1_CKDN220054653-1A_HF33VDSX5_L1_R1_paired.fq $OUTDIR/trimmomatic/OT1_CKDN220054653-1A_HF33VDSX5_L1_R2_paired.fq > $OUTDIR/meraculous/diploid0test/mapping/Scaffold51732.bam
#
# samtools sort $OUTDIR/meraculous/diploid0test/mapping/Scaffold51732.bam -o $OUTDIR/meraculous/diploid0test/mapping/Scaffold51732.sorted.bam
#
# samtools index -@ 10 $OUTDIR/meraculous/diploid0test/mapping/Scaffold51732.sorted.bam
#
# #Calls variants from (i) reads with mapping quality greater than 60, excludes variants that have a (ii) quality score of less than 40, and excludes variants that are (iii) supported by fewer than 10 reads for the genome
#
# bcftools mpileup -Ou --threads 6 --min-MQ 10 -f $OUTDIR/meraculous/diploid0test/mapping/Scaffold51732.fasta $OUTDIR/meraculous/diploid0test/mapping/Scaffold51732.sorted.bam | bcftools call --threads 6 -mv -Ou \
# --ploidy 1 | bcftools filter -Oz -e 'QUAL<40 || DP<10' > $OUTDIR/meraculous/diploid0test/mapping/G_maculatum.sorted.mpileup.call.filter.onestep.vcf.gz
#
# bcftools view $OUTDIR/meraculous/diploid0test/mapping/G_maculatum.sorted.mpileup.call.filter.onestep.vcf.gz

# samtools flagstat -@ 10 $OUTDIR/meraculous/diploid0test/mapping/Scaffold51732.sorted.bam > $OUTDIR/mapping/flagstat_Scaffold51732.txt
# samtools stats -@ 10 $OUTDIR/meraculous/diploid0test/mapping/Scaffold51732.sorted.bam > $OUTDIR/mapping/stats_Scaffold51732.txt

####################################################################
# VISUSLIZE SNPS & COVERAGE
####################################################################


# make a text file in the format bedtools wants for -g (which is the chromosome name and its length)
# awk '{ print $1"\t"$2 }' $OUTDIR/meraculous/diploid0test/mapping/Scaffold51732.fasta.fai > $OUTDIR/meraculous/diploid0test/mapping/ref.lengths.txt
​
#load bedtools
# ml BEDTools/2.30.0-GCC-8.3.0
#
# # convert the genome to sliding windows (10kb) - you can play with the size of these windows to view more/less details (eg, try 1kb - 100kb windows)
# bedtools makewindows -g $OUTDIR/meraculous/diploid0test/mapping/ref.lengths.txt -w 10000 -s 9000 > $OUTDIR/meraculous/diploid0test/mapping/ref.10kb_windows.bed
#
# # calculate read mapping depth from a SORTED bam file, within each sliding window in the bed file
# bedtools coverage -a $OUTDIR/meraculous/diploid0test/mapping/ref.10kb_windows.bed -b $OUTDIR/meraculous/diploid0test/mapping/Scaffold51732.sorted.bam -mean > $OUTDIR/meraculous/diploid0test/mapping/query.10kb_windows.DEPTH.txt
#
# #plot in R
# source activate R
# R --no-save < /home/srb67793/G_maculatum_novogene/scripts/plot_read_DEPTH.R
# source deactivate R

####################################################################
# smudgeplot
####################################################################

mkdir tmp
ls /scratch/srb67793/G_maculatum/rawreads/G_maculatum/OT1_CKDN220054653-1A_HF33VDSX5_L1_1.fq /scratch/srb67793/G_maculatum/rawreads/G_maculatum/OT1_CKDN220054653-1A_HF33VDSX5_L1_2.fq > FILES
kmc -k21 -t16 -m64 -ci1 -cs10000 @FILES kmer_counts tmp
kmc_tools transform kmer_counts histogram kmer_k21.hist
Rscript genomescope.R -i kmer_k21.hist -k 21 -p 2 -o . -n Gmaculatum_genomescope 10000
smudgeplot.py cutoff kmer_k21.hist L #10
smudgeplot.py cutoff kmer_k21.hist U #2200
kmc_dump -ci10 -cx2200 kmer_counts kmer_k21.dump
smudgeplot.py hetkmers -o kmer_pairs < kmer_k21.dump
smudgeplot.py plot -o G_maculatum -t "Geranium maculatum" -q 0.99 kmer_pairs_coverages.tsv

####################################################################
# 7) EVALUATES GENOME ASSEMBLY
####################################################################

# QUAST Test script
# for file in $OUTDIR/abyss/k*/g_maculatum-scaffolds.fa; do
#   quast.py -o $OUTDIR/quast -t 10 $OUTDIR/abyss/k*/g_maculatum-scaffolds.fa
# done
