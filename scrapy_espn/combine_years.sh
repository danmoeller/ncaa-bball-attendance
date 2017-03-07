#!/bin/bash


if [ "$1" != "" ]; then
	if [ "$2" != "" ]; then
		if [ "$3" != "" ]; then
			YEAR=$2
			while [ $YEAR -le $3 ]
			do
				# Append years data to our combined file
				cat "../data/$1_${YEAR}_games.csv" >> "$1_games_$2-$3.csv"
				echo "Combined $YEAR to our file"
				(( YEAR++ ))
			done

			#Remove duplicate headers and move to data directory
			cat -n "$1_games_$2-$3.csv" | sort -uk2 | sort -nk1 | cut -f2- > "../data/$1_games_$2-$3.csv"
			rm "$1_games_$2-$3.csv"

			echo "Look for your file at: ../data/$1_games_$2-$3.csv"
		else
			echo "Please enter an ending year"
		fi
	else
		echo "Please enter a starting year"
	fi
else
	echo "Please enter a team identifier to combine"
fi


