### Main NarFFL ###

#Load Packages
install.packages("ffscrapr", repos = c("https://ffverse.r-universe.dev", getOption("repos")))
#remotes::install_github("RandalMorris/ffscrapr")

#Load Functions and Data
# source("functions.R")
load(file = paste0(getwd(), "/data/NarFFL_Data_Load.rdata"))

#Set Variables
#Fantasy_Year = 2022 #Set to Older year to test
#week = 1

#Get current season player score totals
player_list = ffscrapr::fleaflicker_players(
  ffscrapr::fleaflicker_connect(season = Fantasy_Year, league_id = "140956"), page_limit = 5)
player_scores = ffscrapr::ff_playerscores(
  ffscrapr::fleaflicker_connect(season = Fantasy_Year, league_id = "140956"), page_limit = 25)

#Get Fresh data
start_time <- Sys.time()
for (x in 1:nrow(NarFFL_leagues)){
  conn <- ffscrapr::fleaflicker_connect(season = Fantasy_Year, league_id = NarFFL_leagues$id[x])
  
  cat(paste0("Working League ", NarFFL_leagues$name[x]))
  cat("",sep = "\n")

  franchises_tmp = ffscrapr::ff_franchises(conn)
  rosters_tmp = ffscrapr::ff_rosters(conn, week = week)
  schedule_tmp = ffscrapr::ff_schedule(conn)
  standings_tmp = ffscrapr::ff_standings(conn)
  starters_tmp = ffscrapr:::ff_starters(conn, week = week)
  transactions_tmp = ffscrapr::ff_transactions(conn)
  
  franchises = rbind(franchises, franchises_tmp)
  rosters = rbind(rosters, rosters_tmp)
  schedule = rbind(schedule, schedule_tmp)
  standings = rbind(standings, standings_tmp)
  starters = rbind(starters, starters_tmp)
  transactions = rbind(transactions, transactions_tmp)
  
  rm(franchises_tmp, rosters_tmp,standings_tmp,  starters_tmp, transactions_tmp, i, conn)
}
end_time <- Sys.time()
Duration = paste0("Execution Time: ", round(end_time - start_time,2), " Hours")
rm(x, end_time, start_time)

save.image(file = paste0(getwd(), "/data/NarFFL_Data_",Fantasy_Year,".rdata"))

