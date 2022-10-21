
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ongoal

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/ongoal)](https://CRAN.R-project.org/package=ongoal)
<!-- badges: end -->

ongoal makes 27682 data points available for Pittsburgh Penguins games
where the it was determined whether a shot was on goal (i.e., made it to
the goaltender) or not (i.e., missed or blocked). Data are from seasons
2015-2016, 2016-2017, and 2017-2018.

Several other columns were recorded related to the game, player, and
shot. The data are not perfect; the determination of power play duration
were manually calculated and may not be completely accurate.

## Installation

You can install the development version of ongoal:

``` r
require(pak)
pak::pak("topepo/ongoal")
```

## Example

Here’s a look at the data:

``` r
library(ongoal)
str(on_goal)
#> Classes 'tbl_df', 'tbl' and 'data.frame':    27682 obs. of  24 variables:
#>  $ season             : Factor w/ 3 levels "20152016","20162017",..: 1 1 1 1 1 1 1 1 1 1 ...
#>  $ game_id            : int  2015020010 2015020010 2015020010 2015020010 2015020010 2015020010 2015020010 2015020010 2015020010 2015020010 ...
#>  $ event_idx          : Factor w/ 711 levels "0004","0005",..: 1 3 6 14 16 20 30 38 45 59 ...
#>  $ date_time          : Factor w/ 27832 levels "2015-10-09T00:44:51Z",..: 1 2 3 4 5 6 7 8 9 10 ...
#>  $ event              : Factor w/ 4 levels "Blocked Shot",..: 1 1 4 3 2 3 1 4 1 1 ...
#>  $ on_goal            : Factor w/ 2 levels "yes","no": 2 2 1 2 1 2 2 1 2 2 ...
#>  $ period             : int  1 1 1 1 1 1 1 1 1 1 ...
#>  $ game_seconds       : num  13 36 47 92 99 125 179 220 252 309 ...
#>  $ strength           : Factor w/ 3 levels "even","power_play",..: 1 1 1 1 1 1 1 1 1 1 ...
#>  $ strength_state     : Factor w/ 14 levels "3v3","3v4","3v5",..: 10 10 10 10 10 10 10 10 10 10 ...
#>  $ extra_attacker     : num  0 0 0 0 0 0 0 0 0 0 ...
#>  $ home_skaters       : num  5 5 5 5 5 5 5 5 5 5 ...
#>  $ away_skaters       : num  5 5 5 5 5 5 5 5 5 5 ...
#>  $ goaltender         : Factor w/ 78 levels "aaron_dell","al_montoya",..: 53 11 11 11 53 53 53 53 11 11 ...
#>  $ goal_difference    : num  0 0 0 0 1 1 1 1 -1 -1 ...
#>  $ shooter            : Factor w/ 915 levels "aaron_ekblad",..: 298 875 714 78 577 463 298 699 63 361 ...
#>  $ shooter_team       : Factor w/ 31 levels "ANA","ARI","BOS",..: 10 23 23 23 10 10 10 10 23 23 ...
#>  $ shooter_nationality: Factor w/ 19 levels "AUT","BLR","CAN",..: 15 15 19 19 18 8 15 3 9 3 ...
#>  $ shooter_type       : Factor w/ 5 levels "center","defenseman",..: 1 5 1 5 1 2 1 4 4 4 ...
#>  $ coord_x            : num  -66 -49 64 65 80 42 -55 62 -67 -58 ...
#>  $ coord_y            : num  -11 -21 -31 -21 13 31 -19 15 -9 -16 ...
#>  $ angle              : num  4.06 8.65 51.12 41.19 55.3 ...
#>  $ distance           : num  155.4 139.6 39.8 31.9 15.8 ...
#>  $ behind_goal_line   : num  0 0 0 0 0 0 0 0 0 0 ...
```

There’s also a visualization function (based on [Bill Tran’s
function](https://raw.githubusercontent.com/mrbilltran/the-win-column/master/nhl_rink_plot.R)):

``` r
suppressPackageStartupMessages(library(dplyr))
set.seed(12)
on_goal %>% 
    filter(abs(angle) < 10 & distance < 80) %>% 
    plot_nhl_shots(emphasis = on_goal, alpha = 1 / 2)
```

<img src="man/figures/README-rink-1.png" width="100%" />

## Code of Conduct

Please note that the ongoal project is released with a [Contributor Code
of
Conduct](https://contributor-covenant.org/version/2/0/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.
