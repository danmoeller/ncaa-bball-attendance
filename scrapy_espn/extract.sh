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
				echo "Crawling: $school schedule for year $2"
    		fi
		done 
	} < "../data/team_list.csv"

	if [ "$FOUND" = 1 ]; then
		if [ "$2" != "" ]; then
			echo "scrapy crawl schedule -a team=$1 -a year=$2 -o ${NAME}_$2.csv -t csv"
			scrapy crawl schedule -a team="$1" -a year="$2" -o "${NAME}_$2_schedule".csv -t csv
	
			mv "${NAME}_$2_schedule".csv "../data/${NAME}/"
			echo "Look for your teams schedule at ../data/${NAME}_$2_schedule.csv"

			{
				read
				while IFS=, read game_id neutral
				do
					# Ensure game is not on neutral court
					if [ "$(echo ${neutral} | tr -d '\r' | tr -d '\n')" == "true" ]; then
						# TODO: should make this on option for future analysis
						echo "Skipping game: $game_id since on neutral court"
					else
						echo "crawling game: $game_id"
						scrapy crawl game -a game="$game_id" -o "${NAME}_$2_games.csv" -t csv
					fi
				done 
			} < "../data/${NAME}/${NAME}_$2_schedule.csv"

			# Delete temporary schedule file
			rm "../data/${NAME}/${NAME}_$2_schedule.csv"

			# Create directory for team if it does not exist
			mkdir -p "../data/${NAME}"
			
			# Remove duplicate data lines (mostly headers) and move to data folder
			cat -n "${NAME}_$2_games.csv" | sort -uk2 | sort -nk1 | cut -f2- > "../data/${NAME}/${NAME}_$2_games.csv"
			rm "${NAME}_$2_games.csv"
			


		else
			echo "Please provide a second argument containting the year you would like to crawl"
		fi
	else
		echo "Could not find a team that corresponds to team identifier: $1"
	fi
else
	echo "Please list a schools identifier and year of data you would like to crawl"
fi