# NCAA Basketball Attendance
Semester project for COSC/MATH 4931: Introduction to Data Science at Marquette University. It is designed around a deeper dive into what exactly determines/impacts tickets sold for NCAA Division 1 basketball games. It is currently designed to fit only the class project goals, but as time permits and after the semester the usage will become more generalizable.

## Installation
Currently using python 2.7.13 as well as the following tools:
	* Scrapy (1.3.0)
	* jupyter (1.0.0)
	* notebook (4.3.1)

## Usage
There are currently a few usable functions:
	* extract.sh {team-id} {year}  --> Pulls game data for {team-id} during the {year} season
	* team_lookup.sh {name-guess} --> Shows teams and their espn id that have {name-guess} in their name
	* combine_years.sh {team-id} {begin-year} {end-year} --> combines game data produced by extract.sh for a given team from {begin-year} to {end-year}

## Contributing
This repositiory currently serves as a class project, but will be open to forking and use at the end of the Spring 2017 semester.

