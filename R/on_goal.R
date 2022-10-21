#' Shots on goal data
#'
#' @description
#' These data are for Pittsburgh Penguins regular season games (seasons
#' 2015-2016, 2016-2017, and 2017-2018). Shots were determined to be on goal
#' (i.e., made it to the goaltender) or not (i.e., missed or blocked).
#'
#' `season_2015` contains data from a single season.
#'
#' @name on_goal
#' @aliases on_goal season_2015
#' @docType data
#' @return \item{on_goal,season_2015}{a tibble}
#' @details
#' The full set of columns are:
#'
#' - `season`: A factor with 3 levels: '20152016', '20162017', '20172018'.
#' - `game_id`, `event_idx`: Index columns for NHL database
#' - `date_time`: Data/time of event
#' - `event`: A factor with 4 levels: 'Blocked Shot', 'Goal', 'Missed Shot',
#'    'Shot'.
#' - `on_goal`: A factor with 2 levels: 'yes', 'no'. An on-goal shot is either
#'    a goal or a shot (from the `event` column).
#' - `period`: (integer) Which of the three regular season periods that the shot
#'    was taken.
#' - `game_seconds`: (double) Cumulative time for the shot.
#' - `strength`: A factor with 3 levels: 'even', 'power_play', 'shorthanded'.
#'    Even means that the teams have equal number of players (which may not be
#'    five). A power play is when the shooting team has more players and
#'    short-handed is when the defensive team (with fewer players).
#' - `strength_state`: A factor with 15 levels with format `#v#`. For example,
#'    "3v5" means the attacking team has three players on the ice and the
#'    defending team has five.
#' - `extra_attacker`: (double) How many more players are on-ice for the
#'    attacking team?
#' - `home_skaters`, `away_skaters`: (double) How many players and on-ice.
#' - `goaltender`: A factor with 78 levels. Name of the current goalie.
#' - `goal_difference`: (double) The difference between the current score of the
#'    attacking team minus the score of the defending team.
#' - `shooter`: A factor with 913 levels. Name of the attacking player.
#' - `shooter_team`: A factor with 31 levels. Attacking team.
#' - `shooter_nationality`: A factor with 19 levels.
#' - `shooter_position`: A factor with 5 levels: 'center', 'defenseman',
#'    'goalie', 'left_wing', or 'right_wing'.
#' - `coord_x`, `coord_y`: (double) Location of the event (shot or blocked
#'    shot). Center ice is a `(0, 0)` so negative x values are on the left and
#'    positive `y` values are on top. The data are configured so that the
#'    attacking team is always shooting at the right-hand goal. Note that
#'    there are not _shot_ locations for blocked shots; these are where the
#'    blocking player was located.
#' - `angle`: (double) The angle of the event (0 to 180 degrees) to the center
#'    of the goal. For blocked shots, this is the angle to the blocking player
#'    (which should approximate shot angle well).
#' - `distance`: (double) The minimum distance from the event to the right-hand
#'    goal (located at `(89, 0)`). We say _minimum_ because, for blocked shots,
#'    it is the distance from the blocking player to the center of the goal.
#' - `behind_goal_line`: (double) For the event, was `x > 89`?
#'
#' The `season_2015` version has fewer columns and different factor levels for
#' the player columns (it is used for teaching).
#' @keywords datasets
#' @examples
#' str(on_goal)
NULL
