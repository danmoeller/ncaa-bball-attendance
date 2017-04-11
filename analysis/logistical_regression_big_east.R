# dependencies
library(aod)
library(ggplot2)
library(tidyr)
library(dplyr)

# datasets
games <- read.csv("/Users/DanMoeller/git/ncaa-bball-attendance/data/big_east/big_east_2014_2016.csv", header=TRUE, stringsAsFactors=FALSE)
attendance <- read.csv("/Users/DanMoeller/git/ncaa-bball-attendance/data/ncaa_attendance_2009-2016.csv", header=TRUE, stringsAsFactors=FALSE)
teams <- read.csv("/Users/DanMoeller/git/ncaa-bball-attendance/data/team_list.csv", header=TRUE, stringsAsFactors=FALSE)

# remove unneccessary columns
games$home_score <- NULL
games$away_score <- NULL
games$home_wins <- NULL
games$home_losses <- NULL
games$away_wins <- NULL
games$away_losses <- NULL

# fix any errors
games$home_win_pct[games$home_win_pct > 1] <- 1
games$away_win_pct[games$away_win_pct > 1] <- 1

# days of the week to indicators
games$day[games$day=="monday"] <- "weekday"
games$day[games$day=="tuesday"] <- "weekday"
games$day[games$day=="wednesday"] <- "weekday"
games$day[games$day=="thursday"] <- "weekday"
games$day[games$day=="friday"] <- "weekday"
games$day[games$day=="saturday"] <- "weekend"
games$day[games$day=="sunday"] <- "weekend"

# time manipulation
games$time <- gsub(":",".",games$time)
games$time[games$time == "00.00"] <- NA

# days of the week to indicators
colnames(games)[11] <- "day_of_week"

# tv network to indicators
games$tv_coverage[games$tv != ""] <- 1
games$tv_coverage[games$tv == ""] <- 0

# place rankings in buckets
games$home_rank[games$home_rank == 0] <- 0
games$home_rank[(games$home_rank >= 1) & (games$home_rank <= 5)] <- 5
games$home_rank[(games$home_rank >= 6) & (games$home_rank <= 10)] <- 10
games$home_rank[(games$home_rank >= 11) & (games$home_rank <= 15)] <- 15
games$home_rank[(games$home_rank >= 16) & (games$home_rank <= 20)] <- 20
games$home_rank[(games$home_rank >= 21) & (games$home_rank <= 25)] <- 25

games$away_rank[games$away_rank == 0] <- 0
games$away_rank[(games$away_rank >= 1) & (games$away_rank <= 5)] <- 5
games$away_rank[(games$away_rank >= 6) & (games$away_rank <= 10)] <- 10
games$away_rank[(games$away_rank >= 11) & (games$away_rank <= 15)] <- 15
games$away_rank[(games$away_rank >= 16) & (games$away_rank <= 20)] <- 20
games$away_rank[(games$away_rank >= 21) & (games$away_rank <= 25)] <- 25

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

# remove unneccessary columns
games$school <- NULL
games$url_name <- NULL
games$alt_school <- NULL
games$games_num <- NULL
games$attendance_total <- NULL

# map home team
games <- merge(x=games,y=teams,by.x=c("home_id"),by.y=c("id"),all.x = TRUE)
games$url_name <- NULL
colnames(games)[21] <- "home_school"
colnames(games)[22] <- "home_conf"

# map away team
games <- merge(x=games,y=teams,by.x=c("away_id"),by.y=c("id"),all.x = TRUE)
games$url_name <- NULL
games$school.y <- NULL
games$conf.y <- NULL
colnames(games)[23] <- "away_school"
colnames(games)[24] <- "away_conf"

# determine if a conference game
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

# determine if sellout
games <- games %>%
  mutate(sellout = 0)
games$sellout[games$pct_full >= 1] <- 1

# put capacity & attendance in terms of thousands
games$capacity <- (games$capacity/1000)
games$attendance <- (games$attendance/1000)
games$attendance_avg <- (games$attendance_avg/1000)

# begin data analysis
head(games)
summary(games)
xtabs(~sellout + day_of_week, data = games)
xtabs(~sellout + away_rank, data = games)
xtabs(~sellout + conf_game, data = games)

# logit regression
games.logit = glm(sellout ~ capacity + factor(away_rank) + factor(day_of_week) + line + attendance_avg + conf_game, data=games, family = "binomial")
summary(games.logit)

# confident interval
confint.default(games.logit)

# wald tests
wald.test(b = coef(games.logit), Sigma = vcov(games.logit), Terms = 3:7)
wald.test(b = coef(games.logit), Sigma = vcov(games.logit), Terms = 8)


# l <- cbind(0, 0, 0, 0, 0, 0, 0, 1, -1, 0, 0, 0, 0, 0, 0)
# wald.test(b = coef(games.logit), Sigma = vcov(games.logit), L = l)

# odds ratios and 95% CI
exp(coef(games.logit))
exp(cbind(OR = coef(games.logit), confint(games.logit)))

with(games.logit, null.deviance - deviance)
with(games.logit, df.null - df.residual)
with(games.logit, pchisq(null.deviance - deviance, df.null - df.residual, lower.tail = FALSE))
logLik(games.logit)

# get a visual for how capacity and away_rank impact probability of a sellout.
newdata1 <- with(games, data.frame(capacity = mean(capacity), away_rank = factor(seq(from=0, to=25, by=5)), day_of_week = "weekend", line = mean(line), attendance_avg = mean(attendance_avg), conf_game = 1))
newdata1$away_rankP <- predict(games.logit, newdata = newdata1, type = "response")
newdata2 <- with(games, data.frame(capacity = rep(seq(from = 4, to = 15, length.out = 100), 6), away_rank = factor(rep(seq(from=0, to=25, by=5), each = 100)), day_of_week = "weekend", line = mean(line), attendance_avg = mean(attendance_avg), conf_game = 1))
newdata3 <- cbind(newdata2, predict(games.logit, newdata = newdata2, type = "link", se = TRUE))
newdata3 <- within(newdata3, {
  PredictedProb <- plogis(fit)
  LL <- plogis(fit - (1.96 * se.fit))
  UL <- plogis(fit + (1.96 * se.fit))
})
ggplot(newdata3, aes(x = capacity, y = PredictedProb)) + geom_ribbon(aes(ymin = LL, ymax = UL, fill = away_rank), alpha = 0.2) + geom_line(aes(colour = away_rank),size = 1)

# get a visual for how previous years average attendance and away_rank impact probability of a sellout.
newdata4 <- with(games, data.frame(capacity = mean(capacity), away_rank = factor(rep(seq(from=0, to=25, by=5), each = 100)), day_of_week = "weekend", line = mean(line), attendance_avg = rep(seq(from = 4, to = 15, length.out = 100), 6), conf_game = 1))
newdata5 <- cbind(newdata4, predict(games.logit, newdata = newdata4, type = "link", se = TRUE))
newdata5 <- within(newdata5, {
  PredictedProb <- plogis(fit)
  LL <- plogis(fit - (1.96 * se.fit))
  UL <- plogis(fit + (1.96 * se.fit))
})
ggplot(newdata5, aes(x = attendance_avg, y = PredictedProb)) + geom_ribbon(aes(ymin = LL, ymax = UL, fill = away_rank), alpha = 0.2) + geom_line(aes(colour = away_rank),size = 1)

#plot them together
ggplot() + geom_line(data=newdata5, aes(color = away_rank, x = attendance_avg, y = PredictedProb), size = 1) + geom_line(data=newdata3, aes(color = away_rank, x = capacity, y = PredictedProb), size = 1) + labs(x="attendance | capacity",y="PredictedProb")



