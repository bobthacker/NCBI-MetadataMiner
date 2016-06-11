#!/bin/bash

EXECUTABLE=blastn
NUM_THREADS=12
DATABASE=/home/puri/blastdb/nt/nt
INPUT_FILE=./$1
RESULTS_FILE=/home/jacinta/04072014results.out.$$
PERCENT_IDENTITY=90

echo "Starting Program at: " `date`
time $EXECUTABLE -db $DATABASE -num_threads $NUM_THREADS -query $INPUT_FILE -out $RESULTS_FILE -perc_identity $PERCENT_IDENTITY -outfmt "10 qseqid sseqid pide
nt"
echo "Program Terminated Normally at: " `date`