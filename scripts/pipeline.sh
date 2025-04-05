#Download all the files specified in data/filenames
mkdir -p data
for url in $(list_of_urls) #TODO
do
    bash scripts/download.sh $url data
done

# Download the contaminants fasta file, uncompress it, and
# filter to remove all small nuclear RNAs
mkdir -p res
bash scripts/download.sh <contaminants_url> res yes #TODO

# Index the contaminants file
mkdir -p res/contaminants_idx
bash scripts/index.sh res/contaminants.fasta res/contaminants_idx

# I create a list with the sample ids. Belen 2025-04-02 23.39 Not sure if we had to do this here
for sample in data/*.gz; do
    id=$(basename ${sample})
    echo ${id%-12.5dpp*} 
done | uniq > list_of_sample_ids


# Merge all files from each sample
for sid in $(list_of_sample_ids) #TODO
do
    bash scripts/merge_fastqs.sh data out/merged $sid
done

# TODO: run cutadapt for all merged files
# cutadapt -m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed \
#     -o <trimmed_file> <input_file> > <log_file>  
echo "Running cutadapt..."
mkdir -p log/cutadapt
mkdir -p out/cutadapt
for sid in $(<list_of_sample_ids>)
do
    cutadapt \
        -m 18 \
        -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed \
        -o out/trimmed/${sid}_trimmed.fastq.gz \
        out/merged/${sid}_merged.fastq.gz > log/cutadapt/${sid}.log
done
echo

# TODO: run STAR for all trimmed files
for fname in out/trimmed/*.fastq.gz
do
    # you will need to obtain the sample ID from the filename
    sid=$(basename  ${fname} _trimmed.fastq.gz)
        mkdir -p out/star/$sid
        STAR --runThreadN 4 --genomeDir res/contaminants_idx \
            --outReadsUnmapped Fastx --readFilesIn out/trimmed/${sid}_trimmed.fastq.gz \
            --readFilesCommand gunzip -c --outFileNamePrefix out/star/${sid}/
done  

# TODO: create a log file containing information from cutadapt and star logs
# (this should be a single log file, and information should be *appended* to it on each run)
# - cutadapt: Reads with adapters and total basepairs
# - star: Percentages of uniquely mapped reads, reads mapped to multiple loci, and to too many loci
# tip: use grep to filter the lines you're interested in

echo -e "This is the log file of cutadapt and STAR for each run" > Log.out

for fname in out/trimmed/*.fastq.gz
do
    sid=$(basename ${fname} _trimmed.fastq.gz)
    echo $sid >> Log.out
    grep -E "Reads with adapters|Total basepairs processed" log/cutadapt/${sid}.log >> Log.out
    grep -E "Uniquely mapped reads %|% of reads mapped to multiple loci|% of reads mapped to too many loci" \
    out/star/${sid}/Log.final.out  >> Log.out
done
