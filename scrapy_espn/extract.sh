#!/bin/bash
import sys

file="../data/team_list.csv"
FOUND=0

if [ "$1" != "" ]; then
    
    {
		read
		while IFS=, read school name num conf
		do
			if [[ "$num" == "$1" ]]; then
				FOUND=1
				printf "\nCrawling: $school schedule for year $2\n\n"
    		fi
		done 
	} < "$file"

	if [ "$FOUND" == 1 ]; then
		echo "scrapy crawl schedule -a team=$1 -a year=$2 -o $1_$2.csv -t csv"
		scrapy crawl schedule -a team="$1" -a year="$2" -o "$1_$2_schedule".csv -t csv
	
		mv "$1_$2_schedule".csv ../data/
		printf "\n\nLook for your teams schedule at ../data/$1_$2_schedule.csv\n\n"

		{
			read
			while IFS=, read home_id record score result opp_id date_time game_id day
			do
				echo "crawling game: $game_id"
				scrapy crawl game -a game="$game_id" -o "$1_$2_games.csv" -t csv
			done 
		} < "../data/$1_$2_schedule.csv"

		sort "$1_$2_games.csv" | uniq -u > "../data/$1_$2_games.csv"
		rm "$1_$2_games.csv"




	else
		printf "\n\nCould not find a team that corresponds to team identifier: $1\n\n"
	fi
else
	printf "\n\nPlease list a schools identifier and year of data you would like to crawl\n\n"
fi