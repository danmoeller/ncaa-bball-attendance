#!/bin/bash

FOUND=0
NAME=""

if [ "$1" != "" ]; then
	{
		read
		while IFS=, read school name num conf
		do
			if [[ "$num" == "$1" ]]; then
				# Found a school with an id that matches the first argument
				FOUND=1
				NAME="$school"
    		fi
		done 
	} < "../data/team_list.csv"


	if [ "$FOUND" = 1 ]; then
		if [[ "$2" != "" && "$3" != "" ]]; then
			YEAR=$2
			while [ $YEAR -le $3 ]
			do
				# Append years data to our combined file
				cat "../data/${NAME}/${NAME}_${YEAR}_games.csv" >> "${NAME}_games_$2-$3.csv"
				echo "Combined $YEAR to our file"
				(( YEAR++ ))
			done

			#Remove duplicate headers and move to data directory
			cat -n "${NAME}_games_$2-$3.csv" | sort -uk2 | sort -nk1 | cut -f2- > "../data/${NAME}/${NAME}_games_$2-$3.csv"
			rm "${NAME}_games_$2-$3.csv"

			echo "Look for your file at: ../data/${NAME}/${NAME}_games_$2-$3.csv"
		else
			echo "Please enter an ending year"
		fi
	else
		echo "Please enter a starting year"
	fi
else
	echo "Please enter a team identifier to combine"
fi


