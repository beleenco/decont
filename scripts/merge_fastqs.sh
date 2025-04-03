# This script should merge all files from a given sample (the sample id is
# provided in the third argument ($3)) into a single file, which should be
# stored in the output directory specified by the second argument ($2).
#
# The directory containing the samples is indicated by the first argument ($1).

sample_directory=$1
output_directory=$2
sid=$3

mkdir -p ${output_directory}
echo "Merging files for sample ${sid}..."
cat ${sample_directory}/${sid}-12.5dpp.1.1s_sRNA.fastq.gz ${sample_directory}/${sid}-12.5dpp.1.2s_sRNA.fastq.gz > ${output_directory}/${sid}_merged.fastq.gz

