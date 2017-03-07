#!/bin/bash
import sys

FOUND=0

if [ "$1" != "" ]; then
    {
		read
		while IFS=, read school name num conf
		do
			if [[ "$num" == "$1" ]]; then
				# Found a school with an id that matches the first argument
				FOUND=1
				printf "\nCrawling: $school schedule for year $2\n\n"
    		fi
		done 
	} < "../data/team_list.csv"

	if [ "$FOUND" == 1 ]; then
		echo "scrapy crawl schedule -a team=$1 -a year=$2 -o $1_$2.csv -t csv"
		scrapy crawl schedule -a team="$1" -a year="$2" -o "$1_$2_schedule".csv -t csv
	
		mv "$1_$2_schedule".csv ../data/
		printf "\n\nLook for your teams schedule at ../data/$1_$2_schedule.csv\n\n"

		{
			read
			while IFS=, read game_id neutral_court
			do
				if [ "$neutral_court" == 1]; then
					printf "\n\nSkipping game: $game_id since it is neutral court\n\n"
				else
					printf "\n\ncrawling game: $game_id\n\n"
					scrapy crawl game -a game="$game_id" -o "$1_$2_games.csv" -t csv
				fi
			done 
		} < "../data/$1_$2_schedule.csv"

		# Delete temporary schedule file
		rm "../data/$1_$2_schedule.csv"

		# Remove duplicate data lines (mostly headers)
		cat -n "$1_$2_games.csv" | sort -uk2 | sort -nk1 | cut -f2- > "../data/$1_$2_games.csv"
		rm "$1_$2_games.csv"

	else
		printf "\n\nCould not find a team that corresponds to team identifier: $1\n\n"
	fi
else
	printf "\n\nPlease list a schools identifier and year of data you would like to crawl\n\n"
fi