#load(file = paste0(getwd(), "/data/NarFFL_Data_Load.rdata"))

Fantasy_Year = 2022

conn <- ffscrapr::fleaflicker_connect(season = Fantasy_Year, league_id = 140956)
#starters = ffscrapr:::ff_starters_detail.flea_conn(conn, week = 1)[0,]
#schedule = ffscrapr::ff_schedule(conn)[0, ]

rosters = ffscrapr::ff_rosters(conn)[0, ]

for (x in 1:nrow(NarFFL_leagues)){
  conn <- ffscrapr::fleaflicker_connect(season = Fantasy_Year, league_id = NarFFL_leagues$id[x])
  
  cat(paste0("Working League ", NarFFL_leagues$name[x]))
  cat("",sep = "\n")
  
  
  #schedule_tmp = ffscrapr::ff_schedule(conn)
  #starters_tmp = ffscrapr:::ff_starters_detail.flea_conn(conn)
  for (i in 1:17){
    rosters_tmp = ffscrapr::ff_rosters(conn)
    rosters = rbind(rosters, rosters_tmp)
  }
  
  
  
  #schedule = rbind(schedule, schedule_tmp)
  #starters = rbind(starters, starters_tmp)

  rm(rosters_tmp, conn)
}
