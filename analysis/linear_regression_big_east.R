# dependencies
library(tidyr)
library(dplyr)

#read in datasets
games <- read.csv("/Users/DanMoeller/git/ncaa-bball-attendance/data/big_east/big_east_2014_2016.csv", header=TRUE, stringsAsFactors=FALSE)
attendance <- read.csv("/Users/DanMoeller/git/ncaa-bball-attendance/data/ncaa_attendance_2009-2016.csv", header=TRUE, stringsAsFactors=FALSE)
teams <- read.csv("/Users/DanMoeller/git/ncaa-bball-attendance/data/team_list.csv", header=TRUE, stringsAsFactors=FALSE)


# remove unneccessary columns
games$game_id <- NULL
games$home_score <- NULL
games$away_score <- NULL
games$home_wins <- NULL
games$home_losses <- NULL
games$away_wins <- NULL
games$away_losses <- NULL

# fix any errors
games$home_win_pct[games$home_win_pct > 1] <- 1
games$away_win_pct[games$away_win_pct > 1] <- 1

# time manipulation
games$time <- gsub(":",".",games$time)
games$time[games$time == "00.00"] <- NA

# days of the week to indicators
games$day[games$day=="monday"] <- "weekday"
games$day[games$day=="tuesday"] <- "weekday"
games$day[games$day=="wednesday"] <- "weekday"
games$day[games$day=="thursday"] <- "weekday"
games$day[games$day=="friday"] <- "weekday"
games$day[games$day=="saturday"] <- "weekend"
games$day[games$day=="sunday"] <- "weekend"

# tv network to indicators
games$tv_coverage[games$tv != ""] <- 1
games$tv_coverage[games$tv == ""] <- 0

# inverse rankings
games$away_rank[games$away_rank == 0] <- 26
games$away_rank <- (26 - games$away_rank)
games$home_rank[games$home_rank == 0] <- 26
games$home_rank <- (26 - games$home_rank)

library(tidyr)

# split out the date
games <- games %>%
  separate(date, into = c("month", "day_num", "year"), sep = "/")

# calculate previous season for merging
colnames(games)[10] <- "season"
games$season <- (paste("20", games$season, sep=""))
games$month <- as.numeric(games$month)
games$season <- as.numeric(games$season)
games$season[games$month > 9] <- (games$season + 1)
games <- games %>%
  mutate(prev_season = season - 1)

# merge in previous season attendance records
games <- merge(x=games,y=attendance, by.x=c("prev_season","home_id"), by.y=c("season","team_id"),all.x = TRUE)

#remove unneccessary columns
games$school <- NULL
games$url_name <- NULL
games$alt_school <- NULL
games$games_num <- NULL
games$attendance_total <- NULL

# Map home team
games <- merge(x=games,y=teams,by.x=c("home_id"),by.y=c("id"),all.x = TRUE)
games$url_name <- NULL
colnames(games)[20] <- "home_school"
colnames(games)[21] <- "home_conf"

# Map home team
games <- merge(x=games,y=teams,by.x=c("away_id"),by.y=c("id"),all.x = TRUE)
games$url_name <- NULL
games$school.y <- NULL
games$conf.y <- NULL
colnames(games)[22] <- "away_school"
colnames(games)[23] <- "away_conf"

# Determine if a conference game
games <- games %>%
  mutate(conf_game = 0)
games$conf_game[games$home_conf == games$away_conf] <- 1

#make sure there is nothing more than a sell out
games$attendance <- as.numeric(games$attendance)
games$capacity <- as.numeric(games$capacity)
games$attendance[games$capacity < games$attendance] <- games$capacity

# calculate pct full of capacity
games <- games %>%
  mutate(pct_full = attendance/capacity)
games$pct_full[games$pct_full > 1] <- 1

# put capacity & attendance in terms of thousands
games$capacity <- (games$capacity/1000)
games$attendance <- (games$attendance/1000)
games$attendance_avg <- (games$attendance_avg/1000)

# Start Regression
games.lm = lm(pct_full ~ capacity + home_win_pct + away_win_pct + home_rank + away_rank + factor(day) + line + scoring_line + attendance_avg + conf_game,data=games)
summary(games.lm)


