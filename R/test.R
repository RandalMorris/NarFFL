#remotes::install_github("RandalMorris/ffscrapr", ref = "Flea_Add")
#remotes::install_github("ffverse/ffscrapr")

library(ffscrapr)


#Build Base data that contains one time builds, and per year builds

#One time build for year
conn <- ffscrapr::fleaflicker_connect(season = 2022, league_id = 140956)
scoring_history = ffscrapr::ff_scoringhistory(conn)
schedule = ffscrapr::ff_schedule(conn)[0, ]
league = ffscrapr::ff_league(conn)[0, ]
franchises = ffscrapr:::ff_franchises.flea_conn2(conn)[0, ]
rosters = ffscrapr::ff_rosters(conn)[0, ]
standings = ffscrapr::ff_standings(conn)[0, ]
starters = ffscrapr:::ff_starters_detail.flea_conn(conn)[0,]
transactions = ffscrapr::ff_transactions(conn)[0, ]

for (x in 1:nrow(NarFFL_leagues)){
  conn <- ffscrapr::fleaflicker_connect(season = 2023, league_id = NarFFL_leagues$id[x])
  
  cat(paste0("Working League ", NarFFL_leagues$name[x]))
  cat("",sep = "\n")
  
  league_tmp = ffscrapr::ff_league(conn)
  league = rbind(league, league_tmp)
  rm(conn, league_tmp)
}
starter_positions = ffscrapr::ff_starter_positions(conn)
scoring = ffscrapr::ff_scoring(conn)

Fantasy_Year = as.numeric(format(Sys.Date(), "%Y"))

#Get All league information
NarFFL_leagues = ffscrapr::fleaflicker_getendpoint("FetchUserLeagues",sport = "NFL", user_id = 606586) |>
  purrr::pluck("content","leagues") |>
  tibble::tibble() |> 
  tidyr::unnest_wider(1) |>
  dplyr::select(id, name)

NarFFL_Farm = NarFFL_leagues |> dplyr::filter(grepl("NarFFL Farm", name))
NarFFL_Minors = NarFFL_leagues |> dplyr::filter(grepl("NarFFL Minors", name))
NarFFL_Majors = NarFFL_leagues |> dplyr::filter(grepl("NarFFL Majors", name))
NarFFL_Premier = NarFFL_leagues |> dplyr::filter(grepl("NarFFL Premier", name))



save(scoring_history, schedule, league, starter_positions, scoring, Fantasy_Year,
     NarFFL_leagues, NarFFL_Farm, NarFFL_Minors, NarFFL_Majors, NarFFL_Premier,
     franchises, rosters, standings, starters, transactions,
     file = paste0(getwd(), "/data/NarFFL_Data_Load.rdata"))
# load(file = paste0(getwd(), "/data/scoring_history.rdata"))




# draftboard = ffscrapr::ff_draft(conn) # Need fixed
draftpicks = ffscrapr::ff_draftpicks(conn)



