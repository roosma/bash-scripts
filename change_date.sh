#!/bin/bash
# A simple script for changing the created and modified dates of files based on the kMDItemContentCreationDate date 

# PARAMETERS
GREEN="\033[0;32m" # Green color
YELLOW="\033[1;33m" # Yellow color
BLUE="\033[0;35m" # Yellow color
NC="\033[0m" # No Color

# Function for changing the actuall date of a file
change_date () {
	file="${1}"
	if [[ "${file}" == *.jpg ]] || [[ "${file}" == *.jpeg ]] || [[ "${file}" == *.png ]]# || [[ $file == *.mov ]]
	then
		# Get the creation date and the content creation date
		createdDate=$(mdls ${file} -name kMDItemFSCreationDate -raw)
		newDate=$(mdls ${file} -name kMDItemContentCreationDate -raw)

		# If the dates differ then change them to the content creation date
		if [[ $createdDate != $newDate ]]
		then
			# Formate the dates differently for showing them in the terminal
			createdDateShow=$(date -j -f "%Y-%m-%d %H:%M:%S %z" "$createdDate" +"%d/%m/%Y %H:%M:%S %z")
			newDateShow=$(date -j -f "%Y-%m-%d %H:%M:%S %z" "$newDate" +"%d/%m/%Y %H:%M:%S %z")

			printf "${file##*/}: ${YELLOW}${createdDateShow}${NC} -> ${GREEN}${newDateShow}${NC}\n"

			# Formate date before setting it to file
			newDateFormated=$(date -j -f "%Y-%m-%d %H:%M:%S %z" "$newDate" +"%m/%d/%Y %H:%M:%S %z")
			SetFile -d "$newDateFormated" -m "$newDateFormated" "${file}"

			# Increment counter
			changed=$((changed + 1))
		fi
	fi
}

# Loop content in a directory
loop_directory () {
	for file in "${1}"/*
	do
		# Check if directory or file
		if [ -d "${file}" ]
		then
			printf "${BLUE}ENTERING DIRECTORY:${NC} ${file}\n"
			loop_directory "${file}"
		else
			change_date "${file}"
		fi
	done
}

# Check if parameters given, otherwise show info
if [ $# -eq 0 ]
then
	echo "A bash script for changing the created and modified dates of files to the content created date"
	echo "Usage: ./change_date.sh FILE|FOLDER"
	echo "If a folder is given as input the script will go through it recursively"
else
	# Init counter (will only be shown if input is directory)
	changed=0

	if [ -d "${1}" ]
	then
		loop_directory "${1}"

		printf "\n${GREEN}${changed} FILES CHANGED${NC}\n\n"
	else
		change_date "${1}"
	fi
fi