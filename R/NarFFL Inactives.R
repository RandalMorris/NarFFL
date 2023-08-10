library(dplyr)

NarFFL_leagues = ffscrapr::fleaflicker_getendpoint("FetchUserLeagues",sport = "NFL", user_id = 606586) %>% 
  purrr::pluck("content","leagues") %>%
  tibble::tibble() %>% 
  tidyr::unnest_wider(1) %>%
  filter(!grepl("NarFFL Farm", name)) 

Waitlist = readxl::read_excel("2022 Waitlist.xlsx") %>%
  # filter(!grepl("NarFFL Farm", `League Level`)) %>%
  rename(user_name = Owner) %>%
  filter(!`Team ID` %in% c(1315042, 1252570, 882466))
Waitlist_farm = readxl::read_excel("2022 Waitlist.xlsx") %>%
  filter(grepl("NarFFL Farm", `League Level`))

x=73
league_id = NarFFL_leagues$id[x]

conn <- ffscrapr::fleaflicker_connect(season = 2023, league_id = league_id)
test = ffscrapr::ff_franchises(conn = conn) %>%
  select(c(franchise_id, franchise_name, user_id, user_name, user_lastlogin))
test = test %>% mutate(name = NarFFL_leagues$name[x])


user_status = test[0,]

Premier_Open = 0
Major_Open = 0
Minor_Open = 0


for (x in 1:nrow(NarFFL_leagues)){
  
  cat(paste0("Working League ", NarFFL_leagues$name[x]))
  cat("",sep = "\n")
  league_id = NarFFL_leagues$id[x]
  
  conn <- ffscrapr::fleaflicker_connect(season = 2023, league_id = league_id)
  tmp = ffscrapr::ff_franchises(conn = conn) %>%
    select(c(franchise_id, franchise_name, user_id, user_name, user_lastlogin)) %>%
    mutate(name = NarFFL_leagues$name[x]) %>%
    filter(!franchise_id %in% c(1315042, 1252570, 882466))
  
  if (grepl("NarFFL Premier", NarFFL_leagues$name[x]) == TRUE) {
    Premier_Open = Premier_Open + (12 - nrow(tmp))
  } 
  if (grepl("NarFFL Major", NarFFL_leagues$name[x]) == TRUE) {
    Major_Open = Major_Open + (12 - nrow(tmp))
  } 
  if (grepl("NarFFL Minor", NarFFL_leagues$name[x]) == TRUE) {
    Minor_Open = Minor_Open + (12 - nrow(tmp))
  } 
  
  user_status = rbind(user_status, tmp)

}

rm(tmp, x, league_id, conn, test)

user_status = user_status %>% 
  arrange(desc(user_lastlogin)) %>%
  mutate(user_lastlogin = as.Date(user_lastlogin))
# %>% filter(!grepl("NarFFL Farm", name))

fill_count = Minor_Open + Major_Open + Premier_Open

Fill_List = left_join(user_status, Waitlist, by = "user_name") %>%
  filter(is.na(`Team ID`) == FALSE) %>%
  filter(`Is Champion` == FALSE) %>%
  filter(!grepl("NarFFL Premier", name)) %>%
  mutate(wait_league_name = paste0(`League Level`," - ", `League Name`),
         equal = if_else(name == wait_league_name, 1, 0)) %>%
  filter(equal == 1) %>%
  arrange(factor(`League Level`, levels = c('NarFFL Majors', 'NarFFL Minors', 'NarFFL Farm')))


Users_Good = user_status %>%
  filter(user_lastlogin >= "2023-07-01")

Users_Bad = user_status %>%
  filter(user_lastlogin <= "2023-07-01")


Wait_Joined = inner_join(Fill_List, Users_Good, by = "franchise_id")

Count_by_Level = count(Wait_Joined, `League Level`, name = "Active_Count") %>%
  arrange(factor(`League Level`, levels = c('NarFFL Premier', 'NarFFL Majors', 'NarFFL Minors', 'NarFFL Farm')))

