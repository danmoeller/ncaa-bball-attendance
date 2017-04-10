#read in dataset
marquette <- read.csv("/Users/DanMoeller/git/ncaa-bball-attendance/data/big_east/big_east_2014_2016.csv", header=TRUE, stringsAsFactors=FALSE)

# remove unneccessary columns
marquette$game_id <- NULL
marquette$home_score <- NULL
marquette$away_score <- NULL

# remove away games
# marquette <- marquette[marquette$home_id == 269, ]

# time manipulation
marquette$time <- gsub(":",".",marquette$time)
marquette$time[marquette$time == "00.00"] <- NA

# days of the week to indicators
marquette$day[marquette$day=="sunday"] <- 1
marquette$day[marquette$day=="monday"] <- 0
marquette$day[marquette$day=="tuesday"] <- 0
marquette$day[marquette$day=="wednesday"] <- 0
marquette$day[marquette$day=="thursday"] <- 0
marquette$day[marquette$day=="friday"] <- 1
marquette$day[marquette$day=="saturday"] <- 1

# fix any errors
marquette$home_win_pct[marquette$home_win_pct > 1] <- 1
marquette$away_win_pct[marquette$away_win_pct > 1] <- 1
marquette$home_losses[marquette$home_losses < 0] <- 0
marquette$away_losses[marquette$away_losses < 0] <- 0
marquette$home_wins[marquette$home_losses < 0] <- 0
marquette$away_wins[marquette$home_losses < 0] <- 0

# tv network to indicators
marquette$tv_coverage[marquette$tv != ""] <- 1
marquette$tv_coverage[marquette$tv == ""] <- 0



# inverse rankings
marquette$away_rank[marquette$away_rank == 0] <- 26
marquette$away_rank <- (26 - marquette$away_rank)
marquette$home_rank[marquette$home_rank == 0] <- 26
marquette$home_rank <- (26 - marquette$home_rank)

library(tidyr)

# split out the date
marquette <- marquette %>%
  separate(date, into = c("month", "day_num", "year"), sep = "/")

# calculate how full the stadium was
marquette <- marquette %>%
  mutate(pct_full = attendance / capacity)


# Start Regression
marquette.lm = lm(attendance ~ capacity + home_win_pct + away_win_pct + home_rank + away_rank + scoring_line + home_opener + day + line,data=marquette)
summary(marquette.lm)


