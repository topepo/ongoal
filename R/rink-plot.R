
#' Plot a hockey rink and add data
#' @param x data frame of data (should include a columns called `coord_x` and
#' `coord_y`).
#' @param emphasis A column in `x` to color (and shape if factor) the data points.
#' If this argument is used, it must be named and cannot use in-line functions
#' (e.g. `emphasis = log(distance)`).
#' @param ... Options to pass to [ggplot2::geom_point()]. If `emphasis` is a
#' string or factor, the `col` and `pch` aesthetics are already set and if
#' `emphasis` is numeric, only `col` is set.
#' @param upward A logical indicating whether the plot should be have center ice
#' at the bottom and the goal near the top. The default is center ice on the left
#' and the goal on the right.
#' @return A ggplot object.
#' @details
#' [nhl_rink_plot()] plots most elements of the rink. Code to plot all can be
#' found in the GitHub link in the References.
#'
#' [plot_nhl_shots()] overlays the rink plot with points in `x`. If `emphasis` is
#' given and is factor or character, the color and shape of the points are set.
#' Otherwise, only the color is set. This function also sets the rink colors to
#' grey.
#'
#' @references \url{https://raw.githubusercontent.com/mrbilltran/the-win-column/master/nhl_rink_plot.R}
#' @author Bill Tran (for `nhl_rink_plot()`)
#' @examples
#' nhl_rink_plot()
#'
#' if (rlang::is_installed("dplyr")) {
#'   library(dplyr)
#'   library(ggplot2)
#'
#'   set.seed(1)
#'   small_data <- on_goal %>% sample_n(500)
#'
#'   small_data %>% filter(distance < 20) %>% plot_nhl_shots()
#'
#'   small_data %>% filter(distance < 50) %>% plot_nhl_shots(alpha = 1/2)
#'
#'   small_data %>%
#'     plot_nhl_shots(emphasis = on_goal, cex = 2, alpha = 1/2) +
#'     scale_color_brewer(palette = "Dark2")
#' }
#'
#'
#' @export
plot_nhl_shots <- function(x, ..., emphasis = NULL, upward = FALSE) {
  if (!all(c("coord_x", "coord_y") %in% names(x))) {
    rlang::abort("data argument 'x' must have columns 'coord_x' and 'coord_y'.")
  }

  p <- nhl_rink_plot(
    NHL_red = grDevices::rgb(0, 0, 0, 0.2),
    NHL_blue = grDevices::rgb(0, 0, 0, 0.2),
    NHL_light_blue = grDevices::rgb(0, 0, 0, 0.2),
    upward = upward
  )

  if (is.null(match.call()$emphasis)) {
    p <- p + ggplot2::geom_point(
      data = x,
      ggplot2::aes(x = coord_x, y = coord_y),
      ...
    )
  } else {
    group_data <- x %>% dplyr::select({{emphasis}}) %>% purrr::pluck(1)
    is_cat <- is.factor(group_data) || is.character(group_data)
    if (is_cat) {
      p <- p + ggplot2::geom_point(
        data = x,
        ggplot2::aes(x = coord_x, y = coord_y, col = {{emphasis}}, pch = {{emphasis}}),
        ...
      )
    } else {
      p <- p + ggplot2::geom_point(
        data = x,
        ggplot2::aes(x = coord_x, y = coord_y, col = {{emphasis}}),
        ...
      )
    }
  }

  p
}

utils::globalVariables(c("coord_x", "coord_y"))

#' @export
#' @rdname plot_nhl_shots
#' @param NHL_red,NHL_blue,NHL_light_blue Suggested colors for various rink elements.
# original from https://raw.githubusercontent.com/mrbilltran/the-win-column/master/nhl_rink_plot.R
nhl_rink_plot <- function (NHL_red = "#FFCCD8", NHL_blue = "#CCE1FF", NHL_light_blue = "#CCF5FF", upward = FALSE) {

  # Plotting an NHL rink completely following the NHL rule book:
  # https://cms.nhl.bamgrid.com/images/assets/binary/308893668/binary-file/file.pdf
  # Line widths, lengths, colours, all followed as closely as possible

  p <-
    ggplot2::ggplot() +
    ggforce::geom_arc(ggplot2::aes(x0 = 0, y0 = 0, start = 0, end = pi, r = 15), col = NHL_blue, alpha = 1/2) +

    # Faceoff circles
    ggforce::geom_circle(ggplot2::aes(x0 = 69, y0 = 22, r = 15), colour = NHL_red, size = 2 / 12) + # Top-Right
    ggforce::geom_circle(ggplot2::aes(x0 = 69, y0 = -22, r = 15), colour = NHL_red, size = 2 / 12) + # Bottom-Right

    # Centre line
    ggplot2::geom_tile(ggplot2::aes(x = 0, y = 0, height = 85), width = 1 / 4, col = NHL_red) + # Centre line

    # Faceoff dots - Plot AFTER centre lines for centre ice circle to show up above
    ggforce::geom_circle(ggplot2::aes(x0 = 0, y0 = 0, r = 6 / 12), colour = NHL_red, fill = NHL_red, size = 0) + # Centre dot with unique red
    ggforce::geom_circle(ggplot2::aes(x0 = 69, y0 = 22, r = 1), colour = NHL_red, fill = NHL_red, size = 0) + # Top-Right
    ggforce::geom_circle(ggplot2::aes(x0 = 69, y0 = -22, r = 1), colour = NHL_red, fill = NHL_red, size = 0) + # Bottom-Right

    ggforce::geom_circle(ggplot2::aes(x0 = 20.5, y0 = 22, r = 1), colour = NHL_red, fill = NHL_red, size = 0) + # Neutral Top-Right
    ggforce::geom_circle(ggplot2::aes(x0 = 20.5, y0 = -22, r = 1), colour = NHL_red, fill = NHL_red, size = 0) + # Neutral Bottom-Right

    # Right goalie crease
    ggplot2::geom_tile(ggplot2::aes(x = 86.75, y = 0, width = 4.5, height = 8), fill = NHL_light_blue) +
    ggforce::geom_arc_bar(ggplot2::aes(x0 = 89, y0 = 0, start = -atan(4.5/4) + 0.01, end = -pi + atan(4.5 / 4) - 0.01, r0 = 4, r = 6), fill = NHL_light_blue, colour = NHL_light_blue, size = 1 / 12) + # manually adjusted arc
    ggplot2::geom_tile(ggplot2::aes(x = 86.75, y = -4, width = 4.5, height = 2 / 12), fill = NHL_red) +
    ggplot2::geom_tile(ggplot2::aes(x = 86.75, y = 4, width = 4.5, height = 2 / 12), fill = NHL_red) +
    ggforce::geom_arc(ggplot2::aes(x0 = 89, y0 = 0, start = -atan(4.5/4) + 0.01, end = -pi + atan(4.5 / 4) - 0.01, r = 6), colour = NHL_red, size = 2 / 12) + # manually adjusted arc
    ggplot2::geom_tile(ggplot2::aes(x = 85, y = 3.75, width = 2 / 12, height = 0.42), fill = NHL_red) +
    ggplot2::geom_tile(ggplot2::aes(x = 85, y = -3.75, width = 2 / 12, height = 0.42), fill = NHL_red) +

    # Goalie nets placed as rectangles
    ggplot2::geom_tile(ggplot2::aes(x = 90.67, y = 0, width = 3.33, height = 6), fill = "#E5E5E3") + # Right

    # Trapezoids
    ggplot2::geom_polygon(ggplot2::aes(x = c(100, 100, 89, 89), y = c(10.92, 11.08, 7.08, 6.92)), fill = NHL_red) + # Right
    ggplot2::geom_polygon(ggplot2::aes(x = c(100, 100, 89, 89), y = c(-10.92, -11.08, -7.08, -6.92)), fill = NHL_red) + # Right

    # Lines
    ggplot2::geom_tile(ggplot2::aes(x = 25.5, y = 0, width = 1, height = 85),  fill = NHL_blue) + # Right Blue line
    ggplot2::geom_tile(ggplot2::aes(x = 89, y = 0, width = 2 / 12, height = 73.50), fill = NHL_red) + # Right goal line

    # Borders as line segments - plotted last to cover up line ends, etc.
    ggplot2::geom_line(ggplot2::aes(x = c(0, 72), y = c(42.5, 42.5))) + # Top
    ggplot2::geom_line(ggplot2::aes(x = c(0, 72), y = c(-42.5, -42.5))) + # Bottom
    ggplot2::geom_line(ggplot2::aes(x = c(100, 100), y = c(-14.5, 14.5))) + # Right
    ggforce::geom_arc(ggplot2::aes(x0 = 72, y0 = 14.5, start = pi / 2, end = 0, r = 28)) + # Top-Right
    ggforce::geom_arc(ggplot2::aes(x0 = 72, y0 = -14.5, start = pi, end =  pi / 2, r = 28)) + # Bottom-Right

    ggplot2::theme_void() +
    ggplot2::theme(legend.position = "top") +
    ggplot2::theme(
      axis.title.x = ggplot2::element_blank(),
      axis.text.x  = ggplot2::element_blank(),
      axis.ticks.x = ggplot2::element_blank(),
      axis.title.y = ggplot2::element_blank(),
      axis.text.y  = ggplot2::element_blank(),
      axis.ticks.y = ggplot2::element_blank(),
      panel.grid.major = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      panel.border = ggplot2::element_blank()
    )

  if (upward) {
    p <- p + ggplot2::coord_flip()
  }
  p
}
