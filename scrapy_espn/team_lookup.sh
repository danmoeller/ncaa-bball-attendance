#!/bin/bash
file="../data/team_list.csv"

if [ "$1" != "" ]; then
    
    {
		read
		while IFS=, read school name num conf
		do
			if [[ "$name" == *"$1"* ]]; then
            	echo "SCHOOL: $name ---- ID: $num"
    		fi
		done 
	} < "$file"


else
	printf "\nListing all teams and their espn identifiers:\n"
    {
		read
		while IFS=, read school name num conf
		do
        	echo "SCHOOL: $name ---- ID: $num"
		done 
	} < "$file"
	printf "\n"
fi



