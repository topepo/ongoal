test_that("rink plots", {
  skip_on_os("windows")
  skip_if_not_installed("dplyr")

  # ----------------------------------------------------------------------------

  save_png <- function(code, file_name = "plot.png",
                       width = 400, height = 400) {
    path <- file.path(tempdir(), file_name)
    png(path, width = width, height = height)
    on.exit(dev.off())
    code

    path
  }

  # ----------------------------------------------------------------------------

  expect_snapshot_file(
    save_png(print(nhl_rink_plot()), "basic-rink-plot.png"),
    name = "basic-rink-plot.png"
  )

  expect_snapshot_file(
    save_png(
      print(nhl_rink_plot("red", "green", "orange")),
      "alt-col-rink-plot.png"
    ),
    name = "alt-col-rink-plot.png"
  )

  # ----------------------------------------------------------------------------

  library(dplyr)
  set.seed(1)
  small_data <- on_goal %>% sample_n(500)

  expect_snapshot_file(
    save_png(
      small_data %>% plot_nhl_shots() %>% print(),
      "basic-data-plot.png"
    ),
    name = "basic-data-plot.png"
  )

  expect_snapshot_file(
    save_png(
      small_data %>% plot_nhl_shots(emphasis = shooter_type) %>% print(),
      "qual-data-plot.png"
    ),
    name = "qual-data-plot.png"
  )

  expect_snapshot_file(
    save_png(
      small_data %>% plot_nhl_shots(emphasis = coord_x) %>% print(),
      "quant-data-plot.png"
    ),
    name = "quant-data-plot.png"
  )

  expect_snapshot_file(
    save_png(
      small_data %>% plot_nhl_shots(cex = 5) %>% print(),
      "point-opt-data-plot.png"
    ),
    name = "point-opt-data-plot.png"
  )

  # ----------------------------------------------------------------------------

  expect_snapshot_error(small_data %>% plot_nhl_shots(emphasis = potato))

})
