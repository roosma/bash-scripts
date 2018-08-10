#!/bin/bash
# A simple script for changing the created and modified dates of files based on the kMDItemContentCreationDate date 

change_date () {
	file=$1
	if [[ $file == *.jpg ]] || [[ $file == *.png ]]
        then
		createdDate=$(mdls $file -name kMDItemFSCreationDate -raw)
		newDate=$(mdls $file -name kMDItemContentCreationDate -raw)

	        createdDateShow=$(date -j -f "%Y-%m-%d %H:%M:%S %z" "$createdDate" +"%d/%m/%Y %H:%M:%S %z")
        	newDateShow=$(date -j -f "%Y-%m-%d %H:%M:%S %z" "$newDate" +"%d/%m/%Y %H:%M:%S %z")

	        echo "$file: $createdDateShow -> $newDateShow"

        	newDateFormated=$(date -j -f "%Y-%m-%d %H:%M:%S %z" "$newDate" +"%m/%d/%Y %H:%M:%S %z")
	        SetFile -d "$newDateFormated" -m "$newDateFormated" $file
	fi
}

loop_directory () {
	for file in $1/*
        do
		if [ -d $file ]
		then
			loop_directory $file
		else
        		change_date $file
		fi
        done
}

if [ $# -eq 0 ]
then
	echo "A bash script for changing the created and modified dates of files to the content created date"
	echo "Usage: ./change_date.sh FILE|FOLDER"
	echo "If a folder is given as input the script will go through it recursively"
else
	if [ -d $1 ]
	then
		loop_directory $1
	else
		change_date $1
	fi
fi
