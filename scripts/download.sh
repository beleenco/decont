# This script should download the file specified in the first argument ($1),
# place it in the directory specified in the second argument ($2),
# and *optionally*:
# - uncompress the downloaded file with gunzip if the third
#   argument ($3) contains the word "yes"
# - filter the sequences based on a word contained in their header lines:
#   sequences containing the specified word in their header should be **excluded**
#
# Example of the desired filtering:
#
#   > this is my sequence
#   CACTATGGGAGGACATTATAC
#   > this is my second sequence
#   CACTATGGGAGGGAGAGGAGA
#   > this is another sequence
#   CCAGGATTTACAGACTTTAAA
#
#   If $4 == "another" only the **first two sequence** should be output

file=$1
dir=$2
myvar=$3


if [ "$#" -gt 1 ]
then 
    # Go to directory and download file
    wget -P ${dir} ${file}
    filename=$(basename ${file})

    # Uncompress file if 'yes' is specified
    if [ "$myvar" == "yes" ]
    then
        gunzip -k ${dir}/${filename}
    fi

    if [ -n "$4" ]; then
        gunzip -c ${dir}/${filename} | sed "/${4}/{N;d;}" > ${dir}/${filename}
    fi



else
    echo "Error: this script should be run with 2 or more arguments"
fi

