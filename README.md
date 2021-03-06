
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ongoal

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/ongoal)](https://CRAN.R-project.org/package=ongoal)
<!-- badges: end -->

ongoal makes 35572 data points available for Pittsburgh Penguins games
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
#> Classes 'tbl_df', 'tbl' and 'data.frame':    35572 obs. of  22 variables:
#>  $ on_goal          : Factor w/ 2 levels "yes","no": 1 1 1 1 1 1 1 2 1 2 ...
#>  $ date_time        : POSIXct, format: "2018-04-11 23:08:36" "2018-04-11 23:08:48" ...
#>  $ season           : Factor w/ 3 levels "20152016","20162017",..: 3 3 3 3 3 3 3 3 3 3 ...
#>  $ period           : int  1 1 1 1 1 1 1 1 1 1 ...
#>  $ period_type      : Factor w/ 3 levels "overtime","regular",..: 2 2 2 2 2 2 2 2 2 2 ...
#>  $ coord_x          : num  63 -39 78 49 -58 50 54 70 -16 -76 ...
#>  $ coord_y          : num  16 -26 -31 -24 20 -20 14 -37 -23 8 ...
#>  $ game_time        : num  0.15 0.367 0.517 0.667 1.15 ...
#>  $ strength         : Factor w/ 4 levels "even","even_short_handed",..: 1 1 1 1 1 1 1 1 1 1 ...
#>  $ player           : Factor w/ 1468 levels "a_j_greer","aaron_ekblad",..: 579 549 229 251 1363 794 229 263 549 1102 ...
#>  $ player_diff      : num  0 0 0 0 0 0 0 0 0 0 ...
#>  $ offense_team     : Factor w/ 31 levels "ANA","ARI","BOS",..: 23 22 23 23 22 23 23 23 22 22 ...
#>  $ defense_team     : Factor w/ 31 levels "ANA","ARI","BOS",..: 22 23 22 22 23 22 22 22 23 23 ...
#>  $ offense_goal_diff: num  0 0 0 0 0 0 1 1 -1 -1 ...
#>  $ game_type        : Factor w/ 2 levels "regular","playoff": 2 2 2 2 2 2 2 2 2 2 ...
#>  $ position         : Factor w/ 5 levels "center","defenseman",..: 1 2 5 4 1 2 5 2 2 4 ...
#>  $ distance         : num  30.5 56.4 32.9 46.6 36.9 ...
#>  $ behind_goal_line : num  0 0 0 0 0 0 0 0 0 0 ...
#>  $ angle            : num  31.6 27.5 70.5 31 32.8 ...
#>  $ dow              : Factor w/ 7 levels "Sun","Mon","Tue",..: 4 4 4 4 4 4 4 4 4 4 ...
#>  $ month            : Factor w/ 12 levels "Jan","Feb","Mar",..: 4 4 4 4 4 4 4 4 4 4 ...
#>  $ year             : num  2018 2018 2018 2018 2018 ...
```

There’s also a visualization function (based on [Bill Tran’s
function](https://raw.githubusercontent.com/mrbilltran/the-win-column/master/nhl_rink_plot.R)):

``` r
suppressPackageStartupMessages(library(dplyr))
set.seed(1)
on_goal %>% 
  filter(abs(angle) < 20 & distance < 40) %>% 
  sample_n(500) %>% 
  plot_nhl_shots(emphasis = on_goal, alpha = 1 / 2)
```

<img src="man/figures/README-rink-1.png" width="100%" />

## Future plans

I might make a different version of the data and plotting function that
use the absolute x coordinate so that we only have to plot half the
rink.

## Code of Conduct

Please note that the ongoal project is released with a [Contributor Code
of
Conduct](https://contributor-covenant.org/version/2/0/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.
