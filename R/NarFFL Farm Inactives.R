source("flea_franchises.R")
NarFFL_leagues = ffscrapr::fleaflicker_getendpoint("FetchUserLeagues",sport = "NFL", user_id = 606586) %>% 
  purrr::pluck("content","leagues") %>%
  tibble::tibble() %>% 
  tidyr::unnest_wider(1) %>%
  filter(grepl("NarFFL Farm", name)) 

Waitlist_farm = readxl::read_excel("2022 Waitlist.xlsx", sheet = "Farm") %>% rename(user_name = Owner)


x=48
league_id = NarFFL_leagues$id[x]

conn <- ffscrapr::fleaflicker_connect(season = 2022, league_id = league_id)
test = ff_franchises_flea(conn = conn) %>%
  select(c(franchise_id, franchise_name, user_id, user_name, user_lastlogin))
test = test %>% mutate(name = NarFFL_leagues$name[x])


user_status = test[0,]


for (x in 1:nrow(NarFFL_leagues)){
  
  cat(paste0("Working League ", NarFFL_leagues$name[x]))
  cat("",sep = "\n")
  league_id = NarFFL_leagues$id[x]
  
  conn <- ffscrapr::fleaflicker_connect(season = 2022, league_id = league_id)
  tmp = ff_franchises_flea(conn = conn) %>%
    select(c(franchise_id, franchise_name, user_id, user_name, user_lastlogin)) %>%
    mutate(name = NarFFL_leagues$name[x])

  
  user_status = rbind(user_status, tmp)
  
}

rm(tmp, x, league_id, conn, test)
Users_Bad = user_status %>%
  filter(user_lastlogin <= "2023-07-01")

farm_inactive =  left_join(Waitlist_farm, Users_Bad, by = "user_name") %>%
  filter(`Final Order` <= 150 & is.na(franchise_id) == FALSE)

count_farm_not_active = as.numeric(nrow(farm_inactive))



                                                                                  