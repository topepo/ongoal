library(tidymodels)
library(ongoal)
library(usethis)


retain <-
  c("on_goal", "period", "game_seconds", "strength", "home_skaters",
    "away_skaters", "goaltender", "goal_difference", "shooter", "shooter_type",
    "coord_x", "coord_y", "extra_attacker")

season_2015 <-
  on_goal %>%
  filter(season == "20152016") %>%
  select(all_of(retain)) %>%
  dplyr::mutate(
    shooter = factor(as.character(shooter)),
    goaltender = factor(as.character(goaltender))
  )

use_data(
  on_goal,
  version = 3,
  overwrite = TRUE,
  compress = TRUE
)

use_data(
  season_2015,
  version = 3,
  overwrite = TRUE,
  compress = TRUE
)


