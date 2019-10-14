#!/bin/bash

clear

echo "[1] iOS"
echo "[2] Android"

while true
do
	read -n 1 -s sim_type

	if [[ $sim_type == 1 ]]
	then
		sim_type="ios"
		break
	elif [[ $sim_type == 2 ]]
	then
		sim_type="android"
		break
	elif [[ ( $sim_type == "q" ) || ( $sim_type == "Q" ) ]]
	then
		exit 0
	fi
done

clear

IFS=$'\n'
counter=1
arr=()

if [[ $sim_type == "android" ]]
then
	read -n 1 -p "With DNS specified? (Y/n): " with_dns

	clear

	if [[ ( $with_dns == "q" ) || ( $with_dns == "Q" ) ]]
	then
		exit 0
	fi

	sim_list="$(emulator -list-avds)"

	for item in $sim_list
	do
		echo "[${counter}] ${item}"
		arr+=([${counter}]=${item})
		((counter++))
	done
fi

if [[ $sim_type == "ios" ]]
then
	sim_list="$(xcrun simctl list devices)"
	regexp=".*(iPhone[^\(]*) \(([^\)]*)\) (.*)"

	for item in $sim_list
	do
		if [[ $item =~ $regexp ]]
		then
			echo "[${counter}] ${BASH_REMATCH[1]} ${BASH_REMATCH[2]}"
			arr+=([${counter}]=${BASH_REMATCH[2]})
			((counter++))
		fi
	done
fi

while true
do
	read -n 1 -s sim_number

	for i in "${!arr[@]}"
	do
		if [[ $sim_number == $i ]]
		then
			clear
			if [[ $sim_type == "android" ]]
			then
				if [[ $with_dns == "n" ]]
				then
					emulator -avd ${arr[$i]}
				else
					emulator -avd ${arr[$i]} -dns-server 8.8.8.8
				fi
			else
				open -a Simulator --args -CurrentDeviceUDID ${arr[$i]}
			fi
			exit 0
		fi
	done

	if [[ ( $sim_number == "q" ) || ( $sim_number == "Q" ) ]]
	then
		exit 0
	fi
done
