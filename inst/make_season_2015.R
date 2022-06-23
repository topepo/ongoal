library(tidymodels)
library(ongoal)
library(usethis)

set.seed(1)
season_2015 <-
  on_goal %>%
  filter(season == "20152016") %>%
  select(-season, -date_time, -distance, -angle, -behind_goal_line) %>%
  mutate(
    player = as.character(player),
    player = as.factor(player)
  )

use_data(
  on_goal,
  version = 3,
  overwrite = TRUE
)

use_data(
  season_2015,
  version = 3,
  overwrite = TRUE
)


