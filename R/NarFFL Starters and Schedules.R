

.ff_starters.flea_conn <- function(conn, week = 1:17, ...) {
  starters <- ffscrapr::ff_schedule(conn, week) |>
    dplyr::filter(!is.na(.data$result)) |>
    dplyr::distinct(.data$week, .data$game_id) |>
    dplyr::mutate(starters = purrr::map2(.data$week, .data$game_id, .flea_starters, conn)) |>
    tidyr::unnest("starters") |>
    dplyr::arrange(.data$week, .data$franchise_id)
}

.flea_starters <- function(week, game_id, conn) {
  cols <- c(injurytypeAbbreviaition = NA, injurytypeFull = NA, injurydescription = NA, injuryseverity = NA)
  x <- ffscrapr::fleaflicker_getendpoint("FetchLeagueBoxscore",
                               sport = "NFL",
                               scoring_period = week,
                               fantasy_game_id = game_id,
                               league_id = conn$league_id
  ) |>
    purrr::pluck("content", "lineups") |>
    list() |>
    tibble::tibble() |>
    tidyr::unnest_longer(1) |>
    tidyr::unnest_wider(1) |>
    tidyr::unnest_longer("slots") |>
    tidyr::unnest_wider("slots") |>
    dplyr::mutate(
      position = purrr::map_chr(.data$position, purrr::pluck, "label"),
      positionColor = NULL
    ) |>
    tidyr::pivot_longer(c("home", "away"), names_to = "franchise", values_to = "player") |>
    tidyr::hoist("player", "proPlayer", "owner", "points" = "viewingActualPoints") |>
    tidyr::hoist("proPlayer",
                 "player_id" = "id",
                 "player_name" = "nameFull",
                 "pos" = "position",
                 "team" = "proTeamAbbreviation",
                 "injury" = "injury"
    ) |>
    # dplyr::filter(!is.na(.data$player_id)) |>
    tidyr::unnest_wider("injury", names_sep = "") |>
    tidyr::hoist("owner", "franchise_id" = "id", "franchise_name" = "name") |>
    tidyr::hoist("points", "player_score" = "value") |>
    dplyr::mutate(group = dplyr::case_when(is.na(group) == TRUE ~ "BENCH", .default = group))
  x = tibble::add_column(x, !!!cols[setdiff(names(cols), names(x))]) |>  
    dplyr::select(dplyr::any_of(c(
      "group",
      "franchise",
      "franchise_id",
      "franchise_name",
      "starter_status" = "position",
      "player_id",
      "player_name",
      "pos",
      "team",
      "injurytypeAbbreviaition",
      "injurytypeFull",
      "injurydescription",
      "injuryseverity",
      "player_score"
    )))
  
  
  return(x)
}

#Get All league information
NarFFL_leagues = ffscrapr::fleaflicker_getendpoint("FetchUserLeagues",sport = "NFL", user_id = 606586) |>
  purrr::pluck("content","leagues") |>
  tibble::tibble() |> 
  tidyr::unnest_wider(1) |>
  dplyr::select(id, name)

NarFFL_Premier = NarFFL_leagues |> dplyr::filter(grepl("NarFFL Premier", name))

Fantasy_Year = 2022
conn = ffscrapr::fleaflicker_connect(season = Fantasy_Year, league_id = "124681")

starters = .ff_starters.flea_conn(conn, week = 1)[0, ]
schedule = ffscrapr::ff_schedule(conn)[0, ]

for (x in 1:nrow(NarFFL_leagues)){
  conn <- ffscrapr::fleaflicker_connect(season = Fantasy_Year, league_id = NarFFL_leagues$id[12])
  
  cat(paste0("Working League ", NarFFL_leagues$name[x]))
  cat("",sep = "\n")
  
  
  starters_tmp = ff_starters.flea_conn(conn, week = 1) #remove week to run entire season
  schedule_tmp = ffscrapr::ff_schedule(conn)
  starters = rbind(starters, starters_tmp)
  schedule = rbind(schedule, schedule_tmp)
  
}


write.csv(starters, file = paste0(getwd(), "/data/NarFFL_Starters_Data.csv"))
write.csv(schedule, file = paste0(getwd(), "/data/NarFFL_Schedule_Data.csv"))
