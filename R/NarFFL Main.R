### Main NarFFL ###

#Load Packages
#remotes::install_github("ffverse/ffscrapr")
#remotes::install_github("RandalMorris/ffscrapr", ref = "Flea_Add")

#Load Functions and Data
# source("functions.R")
load(file = paste0(getwd(), "/data/NarFFL_Data_Load.rdata"))

#Set Variables
Fantasy_Year = 2021 #Set to Older year to test

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

  franchises_tmp = ffscrapr:::ff_franchises.flea_conn2(conn)
  rosters_tmp = ffscrapr::ff_rosters(conn)
  standings_tmp = ffscrapr::ff_standings(conn)
  starters_tmp = ffscrapr::ff_starters(conn)
  transactions_tmp = ffscrapr::ff_transactions(conn)
  
  franchises = rbind(franchises, franchises_tmp)
  rosters = rbind(rosters, rosters_tmp)
  standings = rbind(standings, standings_tmp)
  starters = rbind(starters, starters_tmp)
  transactions = rbind(transactions, transactions_tmp)
  
  rm(franchises_tmp, rosters_tmp,standings_tmp,  starters_tmp, transactions_tmp, conn)
}
end_time <- Sys.time()
Duration = paste0("Execution Time: ", round(end_time - start_time,2), " Hours")
rm(x, end_time, start_time)

save.image(file = paste0(getwd(), "/data/NarFFL_Data_",Fantasy_Year,".rdata"))

