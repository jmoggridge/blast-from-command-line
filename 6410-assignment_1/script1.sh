#!/bin/bash


## Set up paths to blast and blastdb (first-time only)

echo 'Setting up paths'
export PATH=$PATH:/Users/jasonmoggridge/ncbi-blast-2.10.1+/bin
mkdir $HOME/blastdb
export BLASTDB=$HOME/blastdb

# Make a reference database from reference.fasta sequences to blast LS and RB fast files against

echo 'Making blast db'
makeblastdb -in reference.fasta -dbtype nucl 


# Blast LS fasta seqs to create LS_match.txt

echo 'Blasting LS.fasta'
blastn -db reference.fasta -query LS.fasta -outfmt "6 qacc sseqid bitscore" -max_target_seqs 1 > LS_match.txt

# Blast RB fasta seqs to create RB_match.txt

echo 'Blasting RB.fasta'
blastn -db reference.fasta -query RB.fasta -outfmt "6 qacc sseqid bitscore" -max_target_seqs 1 > RB_match.txt


# create lists of genera in each sample for comparison

cut -f2 LS_match.txt | sort -u > LS_genera.txt
cut -f2 RB_match.txt | sort -u > RB_genera.txt


# create a list of genera shared between LS & RB samples

grep -f LS_genera.txt RB_genera.txt > LS_RB_common.txt


# create files with unique genera in each sample (get all lines not in LS_RB_common.txt)

grep -vf LS_RB_common.txt RB_genera.txt > RB_unique.txt
grep -vf LS_RB_common.txt LS_genera.txt > LS_unique.txt




## Output file for responses to questions:

echo "----------------------------" > responses.txt
echo "  Assignment 1 responses    " >> responses.txt
echo "Jason Moggridge 1159229    " >> responses.txt
echo "----------------------------" >> responses.txt

### Q1

STR=$'\n1. How many sequences are in the LS.fasta file and how many are in the RB.fasta file?'
echo "$STR" >> responses.txt

# Count number of ASV_* headers in each file, write to responses. (for q1)
echo 'LS:' >> responses.txt
grep -c '^>ASV_*' LS.fasta >> responses.txt
echo 'RB:' >> responses.txt
grep -c '^>ASV_*' RB.fasta >> responses.txt


### Q2

# Find genera for specific asv in LS

STR=$'\n2. For distal lumen bacteria (LS), what genera do ASV_0, ASV_202, and ASV_886 belong to?'
echo "$STR" >> responses.txt
grep -E 'ASV_(0|202|886)' LS_match.txt | cut -f1 -f2 >> responses.txt

# Find genera for specific asv in RB

STR=$'\nFor proximal mucosa bacteria, (RB) what genera do ASV_0, ASV_155, and ASV_558? Belong to?'
echo "$STR" >> responses.txt
grep -E 'ASV_(0|155|588)' RB_match.txt | cut -f1 -f2 >> responses.txt

### Q3

STR=$'\n3. How many genera are unique to the distal lumen, unique to proximal mucosa, and common between them?\n'
echo "$STR" >> responses.txt

# count number of lines in LS_unique.txt, RB_unique.txt, LS_RB_common.txt
echo 'Number of genera unique to LS:' >> responses.txt
grep -c '^' < LS_unique.txt >> responses.txt
echo 'Number of genera unique to RB:' >> responses.txt
grep -c '^'  < RB_unique.txt >> responses.txt
echo 'Number of genera in both LS & RB:' >> responses.txt
grep -c '^'  < LS_RB_common.txt >> responses.txt


### Q4 
STR=$'\n\n4. What could be some limitations of this experiment and analysis? Provide brief justification'
echo "$STR" >> responses.txt

ANS=$'\nPotential limitations of this study include the number of Blast hits considered for each sequence, the size of the reference database used for taxonomic classification, and the depth of sampling.\n\nOur analysis only considered the top result from BLAST (by bit score). There could be other hits with very similar scores that should also be considered. It could be worthwhile to examine several top hits for each sequence to see if there is any uncertainty in the classification from multiple hits with similarly high bit scores. The authors of BLAST recommend that at least 5 matches are considered.\n\nThe reference dataset for Blast was limited to 461 sequences whereas the full NCBI non-redundant sequence database contains many thousands, some of which may be better matches to ASVs from LS and RB. Broadening our reference data could potentially improve the accuracy of classification of bacteria in LS and RB. \n\nThe sequencing only produced 952 and 692 sequences of the 16S V4 region from LS and RB respectively. As such, our sampling effort may not have been sufficient to recover sequences from rare genera that are present in low abundances. This could be examined further with a rarefaction analysis to determine whether further sampling is appropriate or if the richness present in LS and RB are adequately represented in our sequences.'

echo "$ANS" >> responses.txt

### end of responses

# show responses output in terminal for checking
echo -e '\n\n\n'
cat responses.txt



# remove genera lists 

rm LS_genera.txt RB_genera.txt reference.fasta.*

# show output files
mkdir ./Results
mv LS_* RB_* ./Results/
echo -e '\n\n\nFiles after running "script1.sh":'
ls -l


