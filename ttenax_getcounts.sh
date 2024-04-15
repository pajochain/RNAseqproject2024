# !/bin/bash

### Fastq to counts table pipeline for T.tenax samples
### GENE 5150 - Project
### Maintainer Paulo Joshua Tanicala
### ptanicala@kgi.edu

##REMINDER TO SELF:
#Comparative gene expression profiling analysis of RNA-seq data for Trichomonas tenax-treated NCI-H292 cells. 
#T. tenax is a neglected tropical disease that affects oral cavities of people around the world.

#ensure current directory is clean
#at 14:00
#bash bash.sh

#### Step 0. Download the necessary files for the project

# Downloads necessary toolkit for data download and give it read, write, and execute permissions
wget https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/3.1.0/sratoolkit.3.1.0-ubuntu64.tar.gz .
tar -vxzf sratoolkit.3.1.0-ubuntu64.tar.gz
chmod +777 sratoolkit.3.1.0-ubuntu64/bin/fastq-dump

#downloads the necessary files-5M limitation due to nature of the project
sratoolkit.3.1.0-ubuntu64/bin/fastq-dump  -X 5000000 SRR23972383 SRR23972384 SRR23972385 SRR23972386 SRR23972387 SRR23972388

#### Step 1. Data QC using FastQC
#Does fastqc on all fastq files downloaded
fastqc *.fastq

#Creates a new directory and transfers FastQC files in it
mkdir FastQC_results
mv *.html FastQC_results
mv *.zip FastQC_results

#Renames files to reflect experiment conditions
mv SRR23972383.fastq cocultured_Ttenax_01.fastq
mv SRR23972384.fastq cocultured_Ttenax_02.fastq
mv SRR23972385.fastq cocultured_Ttenax_03.fastq
mv SRR23972386.fastq untreated_01.fastq
mv SRR23972387.fastq untreated_02.fastq
mv SRR23972388.fastq untreated_03.fastq

#### Step 2. Trimming using cutadapt

#Cutadapt 200 bases. Number of bases determined from FastQC results and trial and error
cutadapt --cut 200 -q 28 -o trimmed_cocultured_Ttenax_01.fastq cocultured_Ttenax_01.fastq
cutadapt --cut 200 -q 28 -o trimmed_cocultured_Ttenax_02.fastq cocultured_Ttenax_02.fastq
cutadapt --cut 200 -q 28 -o trimmed_cocultured_Ttenax_03.fastq cocultured_Ttenax_03.fastq
cutadapt --cut 200 -q 28 -o trimmed_untreated_01.fastq untreated_01.fastq
cutadapt --cut 200 -q 28 -o trimmed_untreated_02.fastq untreated_02.fastq
cutadapt --cut 200 -q 28 -o trimmed_untreated_03.fastq untreated_03.fastq

#Creates a new folder and transfers trimmed files in the new folder
mkdir trimmed_files
mv trimmed*.fastq trimmed_files


# #Installs hisat2 and subread
# #hisat2 performs alignment against an indexed genome. Outputs sam files
# #subread- featureCounts creates a counts table (.txt) from the hisat2 sam files
# #Note: ensure conda environments are activated >>>conda activate
# conda install bioconda::hisat2
# conda install bioconda::subread

#Note: ensure correct file paths are used for each attempt
#### Step 3. Alignment using hisat2
#Downloads indexed genome and decompresses it
wget https://genome-idx.s3.amazonaws.com/hisat/grch38_genome.tar.gz
tar -xzf grch38_genome.tar.gz

##runs hisat using the previously downloaded reference and trimmed files 
hisat2 -x grch38/genome -U trimmed_files/trimmed_cocultured_Ttenax_01.fastq -S Aln_trimmed_cocultured_Ttenax_01.sam
hisat2 -x grch38/genome -U trimmed_files/trimmed_cocultured_Ttenax_02.fastq -S Aln_trimmed_cocultured_Ttenax_02.sam
hisat2 -x grch38/genome -U trimmed_files/trimmed_cocultured_Ttenax_03.fastq -S Aln_trimmed_cocultured_Ttenax_03.sam
hisat2 -x grch38/genome -U trimmed_files/trimmed_untreated_01.fastq -S Aln_trimmed_untreated_01.sam
hisat2 -x grch38/genome -U trimmed_files/trimmed_untreated_02.fastq -S Aln_trimmed_untreated_02.sam
hisat2 -x grch38/genome -U trimmed_files/trimmed_untreated_03.fastq -S Aln_trimmed_untreated_03.sam

#### Step 4. Creation of counts table
#Read counts and creates a counts table as a txt file
#Downloads a gtf file for identifying genomic features in maps read
wget https://ftp.ensembl.org/pub/release-102/gtf/homo_sapiens/Homo_sapiens.GRCh38.102.gtf.gz
gunzip Homo_sapiens.GRCh38.102.gtf.gz
featureCounts -a Homo_sapiens.GRCh38.102.gtf -o grch38_counts.txt *.sam

## Data analysis and visualization will be done using R. 
