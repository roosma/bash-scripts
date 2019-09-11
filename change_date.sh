#!/bin/bash
# A simple script for changing the created and modified dates of files based on the kMDItemContentCreationDate date 

GREEN="\033[0;32m" # Green color
YELLOW="\033[1;33m" # Yellow color
BLUE="\033[0;35m" # Yellow color
NC="\033[0m" # No Color
OIFS="$IFS"
IFS=$"\n"

change_date () {
	file=$1
	if [[ $file == *.jpg ]] || [[ $file == *.png ]]
	then
		createdDate=$(mdls $file -name kMDItemFSCreationDate -raw)
		newDate=$(mdls $file -name kMDItemContentCreationDate -raw)

		if [[ $createdDate != $newDate ]]
		then
			createdDateShow=$(date -j -f "%Y-%m-%d %H:%M:%S %z" "$createdDate" +"%d/%m/%Y %H:%M:%S %z")
			newDateShow=$(date -j -f "%Y-%m-%d %H:%M:%S %z" "$newDate" +"%d/%m/%Y %H:%M:%S %z")

			printf "${file##*/}: ${YELLOW}${createdDateShow}${NC} -> ${GREEN}${newDateShow}${NC}\n"

			newDateFormated=$(date -j -f "%Y-%m-%d %H:%M:%S %z" "$newDate" +"%m/%d/%Y %H:%M:%S %z")
			SetFile -d "$newDateFormated" -m "$newDateFormated" $file

			changed=$((changed + 1))
		fi
	fi
}

loop_directory () {
	for file in $1/*
	do
		if [ -d $file ]
		then
			printf "${BLUE}ENTERING DIRECTORY:${NC} ${file}\n"
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
		changed=0
		loop_directory $1

		printf "\n${GREEN}${changed} FILES CHANGED${NC}\n\n"
	else
		change_date $1
	fi
fi

IFS="$OIFS"
