# pak::pak(c("danmorse314/hockeyR"), ask = FALSE)

library(hockeyR)
library(nhlapi) # for player position
library(tidyverse)
library(tidylog, warn.conflicts = FALSE)
library(sessioninfo)
library(usethis)

# ------------------------------------------------------------------------------

play_by_play <- bind_rows(load_pbp('2015-16'), load_pbp('2016-17'), load_pbp('2017-18'))

# ------------------------------------------------------------------------------

clean_values <- function(x) {
  x <- gsub("([[:punct:]])|([[:space:]])", "_", tolower(x))
  x <- gsub("__", "_", x) # for names with dot them space
  x
}

# TODO off-shots (i.e. right wing player takes shot on left side)

# ------------------------------------------------------------------------------
# Basic filtering of events and teams along with some simple feature creation or
# engineering

shots <-
  play_by_play  %>%
  mutate(
    prev_event = clean_values(dplyr::lag(event)),
    prev_event_seconds = game_seconds - dplyr::lag(game_seconds, default = 0)
  ) %>%
  # Filter for shot-related events
  filter(event %in% c("Shot", "Blocked Shot", "Missed Shot", "Goal")) %>%
  # Remove 0v0 and 0v5 ¯\_(ツ)_/¯
  filter(!grepl("^0v", strength_state)) %>%
  # Remove pre-season games and overtime shots
  filter(period_type == "REGULAR" & season_type == "R") %>%
  mutate(
    # try to compute if the current shot is quickly after a blocked shot or save
    diff_game_seconds = game_seconds - dplyr::lag(game_seconds),
    was_shot = grepl("(saved by)|(Goalpost)", dplyr::lag(description)),
    was_blocked = grepl("blocked shot", dplyr::lag(description)),
    shot_rebound = ifelse(diff_game_seconds <= 2 & was_shot, "yes", "no"),
    blocked_rebound = ifelse(diff_game_seconds <= 2 & was_blocked, "yes", "no"),
  ) %>%
  select(
    event, event_team_type, event_team_abbr, period, game_seconds,
    home_score, away_score,
    # The event_player_* cols will be used to get info on the shooter
    starts_with("event_player_"), -ends_with("_link"),  -ends_with("_season_total"),
    strength, strength_state, extra_attacker, empty_net,
    x_fixed, y_fixed, home_skaters, away_skaters, ends_with("_goalie"),
    date_time, event_team_abbr, season, event_idx, game_id,
    shot_rebound, blocked_rebound, prev_event, prev_event_seconds
  ) %>%
  relocate(season, game_id, event_idx, date_time)

# Determine runs of shots for each team (= consecutive shots prior to current)
run_data <-
  shots %>%
  group_by(game_id, period) %>%
  mutate(run_number = vctrs::vec_identify_runs(event_team_type)) %>%
  ungroup() %>%
  group_by(game_id, period, event_team_type, run_number) %>%
  mutate(prev_consec_shots = row_number() - 1) %>%
  ungroup() %>%
  select(game_id, event_idx, prev_consec_shots)

shots <- inner_join(shots, run_data, by = c("game_id", "event_idx"))

# Filter data down via including games played by PIT
pit_playing <-
  shots %>%
  group_by(season, game_id) %>%
  summarize(has_pit = any(event_team_abbr == "PIT"), .groups = "drop") %>%
  filter(has_pit) %>%
  select(-has_pit)

team_info <-
  shots %>%
  # Next line to tie shooter to team; see notes on blocked shots below
  filter(event == "Shot") %>%
  group_by(season, game_id) %>%
  dplyr::distinct(event_team_type, event_team_abbr) %>%
  pivot_wider(
    id_cols = c(season, game_id),
    names_from = event_team_type,
    values_from = event_team_abbr
  ) %>%
  ungroup()

pit_playing <- inner_join(pit_playing, team_info, by = c("season", "game_id"))

pit_shots <-
  left_join(pit_playing, shots, by = c("season", "game_id")) %>%
  mutate(
    # 'event_team_abbr' is the defensive team for a blocked shot.
    # If that is the case, switch the team (as well as 'event_team_type')
    other_team = ifelse(event_team_abbr == away, home, away),
    event_team_abbr = ifelse(event == "Blocked Shot", other_team, event_team_abbr),
    other_type = ifelse(event_team_type == "away", "home", "away"),
    event_team_type = ifelse(event == "Blocked Shot", other_type, event_team_type),

    # Convert logical to binary indicator
    extra_attacker = ifelse(extra_attacker, 1, 0),

    # Assign no goaltender when an empty net
    empty_net = isTRUE(empty_net),
    away_goalie = ifelse(is.na(away_goalie) & empty_net, "none", away_goalie),
    home_goalie = ifelse(is.na(home_goalie) & empty_net, "none", home_goalie),

    # Determine goaltender from opposite team as event. There is a fair amount
    # of missing data here for some games. See the code below where we use the
    # 'event_player_*' columns to try to get the data when these two columns
    # are missing.
    goaltender = ifelse(event_team_type == "home", away_goalie, home_goalie),

    # Make a column for goal differential between offense and defense team
    goal_difference = ifelse(event_team_type == "away",
                             away_score - home_score,
                             home_score - away_score),

    # Binary outcome
    on_goal = ifelse(event %in% c("Shot", "Goal"), "yes", "no"),
    on_goal = factor(on_goal, levels = c("yes", "no"))

    # Now fold distance into the rebound data

  ) %>%
  # filter(event != "Blocked Shot") %>%
  rename(shooter_team = event_team_abbr, team_away = away, team_home = home) %>%
  select(-other_team, -other_type, -away_score, -home_score) %>%
  relocate(event, on_goal, .after = date_time)

# ------------------------------------------------------------------------------
# Get shooter name and position. Also get goaltender info to replace missing
# values of 'away_goalie' or 'home_goalie'

players <-
  pit_shots %>%
  select(event_idx, game_id, season, starts_with("event_player_")) %>%
  # have to convert integer player ID to character :-O
  mutate(across(c(starts_with("event_player_")), ~ as.character(.x))) %>%
  pivot_longer(
    c(starts_with("event_player_")),
    names_to = c("col"),
    values_to = "data"
  ) %>%
  mutate(
    event_index = gsub("([[:alpha:]])|([[:punct:]])", "", col),
    col = gsub("event_player_(.*)_", "", col)
  ) %>%
  pivot_wider(
    id_cols = c(season, game_id, event_idx, event_index),
    names_from = col,
    values_from = data
  ) %>%
  filter(!is.na(name))

shooter <-
  players %>%
  filter(type %in%  c("Shooter", "Scorer")) %>%
  mutate(
    name = clean_values(name),
    id = as.integer(id)
  ) %>%
  select(season, game_id, event_idx, shooter = name, shooter_id = id)

goalie <-
  players %>%
  filter(type == "Goalie") %>%
  select(season, game_id, event_idx, event_goalie = name)


# use nhlapi to get shooter position

shooter_ids <-
  shooter %>%
  dplyr::distinct(shooter_id) %>%
  pluck("shooter_id")

shooter_type <-
  nhl_players(playerIds = shooter_ids) %>%
  mutate(shooter_type = gsub(" ", "_", tolower(primaryPosition.name))) %>%
  select(shooter_id = id, shooter_nationality = nationality, shooter_type) %>%
  filter(!is.na(shooter_type))

shooter_with_position <-
  inner_join(shooter, shooter_type, by = "shooter_id") %>%
  select(-shooter_id)

with_shooter <-
  pit_shots %>%
  left_join(shooter_with_position, by = c("season", "game_id", "event_idx")) %>%
  select(-starts_with("event_player_")) %>%
  # There are a handful of rows without shooter info
  filter(!is.na(shooter)) %>%
  relocate(shooter_team, .after = shooter)

with_goalie <-
  with_shooter %>%
  left_join(goalie, by = c("season", "game_id", "event_idx")) %>%
  mutate(
    goaltender = ifelse(is.na(goaltender) & !is.na(event_goalie), event_goalie, goaltender),
    goaltender = clean_values(goaltender)
  )

# ------------------------------------------------------------------------------
# Make all shots on right-hand goal. From hockeyR docs: "x_fixed: Numeric
# transformed x-coordinate of event in feet, where the home team always shoots
# to the right, away team to the left."

left_to_right <-
  with_goalie %>%
  mutate(
    coord_x = ifelse(event_team_type == "away", -x_fixed, x_fixed),
    coord_y = ifelse(event_team_type == "away", -y_fixed, y_fixed)
  )

# ------------------------------------------------------------------------------

on_goal <-
  left_to_right %>%
  select(-x_fixed, -y_fixed, -event_team_type) %>%
  mutate(
    strength = clean_values(strength),
    shooter = clean_values(shooter),
    across(where(is.character), as.factor),
    angle = abs( atan2(abs(coord_y), (89 - coord_x) ) * (180 / pi)),
    distance = sqrt( (89 - coord_x) ^ 2 + coord_y ^ 2 ),
    behind_goal_line = ifelse(coord_x >= 89, 1, 0)
  ) %>%
  select(-team_home, -team_away, -empty_net, -home_goalie, -away_goalie,
         -event_goalie)


on_goal <- on_goal[complete.cases(on_goal), ]

# ------------------------------------------------------------------------------
# Smaller version used for teaching

retain <-
  c("on_goal", "period", "game_seconds", "strength", "home_skaters",
    "away_skaters", "goaltender", "goal_difference", "shooter", "shooter_type",
    "coord_x", "coord_y", "extra_attacker", "blocked_rebound", "shot_rebound",
    "prev_event", "prev_event_seconds", "prev_consec_shots")

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

# ------------------------------------------------------------------------------

if (!interactive()) {
  q("no")
}
