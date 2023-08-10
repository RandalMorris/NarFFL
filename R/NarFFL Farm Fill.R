library(dplyr)

NarFFL_leagues = ffscrapr::fleaflicker_getendpoint("FetchUserLeagues",sport = "NFL", user_id = 606586) %>% 
  purrr::pluck("content","leagues") %>%
  tibble::tibble() %>% 
  tidyr::unnest_wider(1) %>%
  filter(!grepl("NarFFL Farm", name)) 

Waitlist = readxl::read_excel("2022 Waitlist.xlsx") %>%
  # filter(!grepl("NarFFL Farm", `League Level`)) %>%
  rename(user_name = Owner)
Waitlist_farm = readxl::read_excel("2022 Waitlist.xlsx", sheet = "Farm") %>% rename(user_name = Owner)


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
    mutate(name = NarFFL_leagues$name[x])
  
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

fill_count = Minor_Open + Major_Open



farm_filled =  left_join(Waitlist_farm, user_status, by = "user_name")
last_row <- farm_filled %>%
  filter(`Final Order` <= 150) %>%
  select(franchise_id)
last_row = as.numeric(max(ifelse(is.na(last_row), NA, row(last_row)), na.rm = TRUE))

farm_filled_last = farm_filled %>% filter(`Final Order` <= last_row & is.na(franchise_id) == TRUE) 
Count_not_filled = as.numeric(count(farm_filled_last, franchise_id))
Count_not_filled = Count_not_filled[2]

Total_Unfilled = fill_count - Count_not_filled
Need = 113 - last_row

source("NarFFL Farm Inactives.R")

Potential = Total_Unfilled + count_farm_not_active              

