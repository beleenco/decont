# This script should index the genome file specified in the first argument ($1),
# creating the index in a directory specified by the second argument ($2).

# The STAR command is provided for you. You should replace the parts surrounded
# by "<>" and uncomment it.

output_dir=$2
genome=$1
 STAR --runThreadN 4 --runMode genomeGenerate --genomeDir ${output_dir} \
 --genomeFastaFiles ${genome} --genomeSAindexNbases 9
