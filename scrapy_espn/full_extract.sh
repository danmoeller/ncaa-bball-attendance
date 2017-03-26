#!/bin/bash

FOUND=0

if [ "$1" != "" ]; then
    {
		read
		while IFS=, read school name num conf
		do
			if [[ "$num" == "$1" ]]; then
				# Found a school with an id that matches the first argument
				FOUND=1
    		fi
		done 
	} < "../data/team_list.csv"

	if [ "$FOUND" = 1 ]; then
		if [[ "$2" != "" && "$3" != "" ]]; then
			YEAR=$2

			while [ $YEAR -le $3 ]
			do
				echo "Extracting the $YEAR season"
				sh ./extract.sh "$1" "$YEAR"
				(( YEAR++ ))
			done

			echo "combining all of the seasons data"
			sh ./combine_years.sh "$1" "$2" "$3"


		else
			echo "Please provide a second & third argument containting the years you would like to crawl"
		fi
	else
		echo "Could not find a team that corresponds to team identifier: $1"
	fi
else
	echo "Please list a schools identifier and years of data you would like to crawl"
fi