#!/bin/bash
for i in $(find /scratch/huffman.r/ClusterRaw -mtime -0.00625 -name "*.raw")
do

pathfree=${i##*/}
extFree=${pathfree%.raw}
echo $extFree

outputDir="/scratch/huffman.r/"$extFree
echo $outputDir

mkdir /scratch/huffman.r/$extFree
cp $i /scratch/huffman.r/$extFree

shFileName=${extFree}.sh
xmlFileName=${extFree}.xml
echo $shFileName

plexEntry=$(awk -v ToMatch="$extFree" -F ',' '$1==ToMatch {print $4}' "MS_Runs_DB.csv")
echo $plexEntry
if [ -z "$plexEntry" ]
then
	mqparInput="mqpar_11plex_template.xml"
elif [ $plexEntry -eq 16 ]
then
	mqparInput="mqpar_16plex_template.xml"
elif [ $plexEntry -eq 11 ]
then
	mparInput="mqpar_11plex_template.xml"
elif [ $plexEntry -ne 11 ] && [ $plexEntry -ne 16 ]
then
	mqparInput="mqpar_11plex_template.xml"
fi
echo $mqparInput

templatePath=templates/$mqparInput
 
python3 gen_mqpar.py $templatePath $outputDir -mq 1_6_7_0 -o $xmlFileName -t 6

sbatch /home/huffman.r/scripts/$shFileName 


done
