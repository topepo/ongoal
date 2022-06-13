
# original from https://raw.githubusercontent.com/mrbilltran/the-win-column/master/nhl_rink_plot.R
#' Plot a hockey rink and add data
#' @param a data frame of data (should include a column called `on_goal`).
#' @param group A factor column to color and shape the data points.
#' @param symbols A named vector of symbol numbers for the plot (or NULL).
#' @return A ggplot object
#' @export
plot_nhl_shots <- function(x, group = NULL, symbols = NULL, ...) {
  grp_chr <- as.character(match.call()$group)
  if (identical(grp_chr, character(0))) {
    grp_chr <- "on_goal"
    group <- rlang::sym("on_goal")
    if (is.null(symbols)) {
      symbols <- c(yes = 1, no = 4)
    }
  }
  if (!is.factor(x[[grp_chr]])) {
    rlang::abort("The grouping factor should be a factor")
  }
  if (!is.null(symbols)) {
    # check the names
    if (!identical(levels(x[[grp_chr]]), names(symbols))) {
      rlang::abort("The levels of the grouping function should be the names in `symbols`")
    }
  }

  p <- nhl_rink_plot() +
    ggplot2::geom_point(
      data = x,
      ggplot2::aes(x = coord_x, y = coord_y, col = {{group}}, pch = {{group}}),
      ...
    )
  if (!is.null(symbols)) {
    p <- p + ggplot2::scale_shape_manual(values = symbols)
  }
  p
}


nhl_rink_plot <- function (NHL_red = rgb(0, 0, 0, .2), NHL_blue = rgb(0, 0, 0, .2), NHL_light_blue = rgb(0, 0, 0, .2)) {

  # Plotting an NHL rink completely following the NHL rule book:
  # https://cms.nhl.bamgrid.com/images/assets/binary/308893668/binary-file/file.pdf
  # Line widths, lengths, colours, all followed as closely as possible

  ggplot2::ggplot() +

    # Faceoff circles
    ggforce::geom_circle(ggplot2::aes(x0 = 0, y0 = 0, r = 15), colour = NHL_blue, size = 2 / 12) + # Centre
    ggforce::geom_circle(ggplot2::aes(x0 = 69, y0 = 22, r = 15), colour = NHL_red, size = 2 / 12) + # Top-Right
    ggforce::geom_circle(ggplot2::aes(x0 = 69, y0 = -22, r = 15), colour = NHL_red, size = 2 / 12) + # Bottom-Right
    ggforce::geom_circle(ggplot2::aes(x0 = -69, y0 = 22, r = 15), colour = NHL_red, size = 2 / 12) + # Top-Left
    ggforce::geom_circle(ggplot2::aes(x0 = -69, y0 = -22, r = 15), colour = NHL_red, size = 2 / 12) + # Bottom-Left

  # Centre line
  ggplot2::geom_tile(ggplot2::aes(x = 0, y = 0, width = 1, height = 85), fill = NHL_red) + # Centre line

    # Faceoff dots - Plot AFTER centre lines for centre ice circle to show up above
    ggforce::geom_circle(ggplot2::aes(x0 = 0, y0 = 0, r = 6 / 12), colour = NHL_red, fill = NHL_red, size = 0) + # Centre dot with unique red
    ggforce::geom_circle(ggplot2::aes(x0 = 69, y0 = 22, r = 1), colour = NHL_red, fill = NHL_red, size = 0) + # Top-Right
    ggforce::geom_circle(ggplot2::aes(x0 = 69, y0 = -22, r = 1), colour = NHL_red, fill = NHL_red, size = 0) + # Bottom-Right
    ggforce::geom_circle(ggplot2::aes(x0 = -69, y0 = 22, r = 1), colour = NHL_red, fill = NHL_red, size = 0) + # Top-Left
    ggforce::geom_circle(ggplot2::aes(x0 = -69, y0 = -22, r = 1), colour = NHL_red, fill = NHL_red, size = 0) + # Bottom-Left

    ggforce::geom_circle(ggplot2::aes(x0 = 20.5, y0 = 22, r = 1), colour = NHL_red, fill = NHL_red, size = 0) + # Neutral Top-Right
    ggforce::geom_circle(ggplot2::aes(x0 = 20.5, y0 = -22, r = 1), colour = NHL_red, fill = NHL_red, size = 0) + # Neutral Bottom-Right
    ggforce::geom_circle(ggplot2::aes(x0 = -20.5, y0 = 22, r = 1), colour = NHL_red, fill = NHL_red, size = 0) + # Neutral Top-Left
    ggforce::geom_circle(ggplot2::aes(x0 = -20.5, y0 = -22, r = 1), colour = NHL_red, fill = NHL_red, size = 0) + # Neutral Bottom-Left

  # Left goalie crease
  ggplot2::geom_tile(ggplot2::aes(x = -86.75, y = 0, width = 4.5, height = 8), fill = NHL_light_blue) +
    ggforce::geom_arc_bar(ggplot2::aes(x0 = -89, y0 = 0, start = atan(4.5/4) - 0.01, end = pi - atan(4.5 / 4) + 0.01, r0 = 4, r = 6), fill = NHL_light_blue, colour = NHL_light_blue, size = 1 / 12) + # manually adjusted arc
    ggplot2::geom_tile(ggplot2::aes(x = -86.75, y = -4, width = 4.5, height = 2 / 12), fill = NHL_red) +
    ggplot2::geom_tile(ggplot2::aes(x = -86.75, y = 4, width = 4.5, height = 2 / 12), fill = NHL_red) +
    ggforce::geom_arc(ggplot2::aes(x0 = -89, y0 = 0, start = atan(4.5/4) - 0.01, end = pi - atan(4.5 / 4) + 0.01, r = 6), colour = NHL_red, size = 2 / 12) + # manually adjusted arc
    ggplot2::geom_tile(ggplot2::aes(x = -85, y = 3.75, width = 2 / 12, height = 0.42), fill = NHL_red) +
    ggplot2::geom_tile(ggplot2::aes(x = -85, y = -3.75, width = 2 / 12, height = 0.42), fill = NHL_red) +

    # Right goalie crease
    ggplot2::geom_tile(ggplot2::aes(x = 86.75, y = 0, width = 4.5, height = 8), fill = NHL_light_blue) +
    ggforce::geom_arc_bar(ggplot2::aes(x0 = 89, y0 = 0, start = -atan(4.5/4) + 0.01, end = -pi + atan(4.5 / 4) - 0.01, r0 = 4, r = 6), fill = NHL_light_blue, colour = NHL_light_blue, size = 1 / 12) + # manually adjusted arc
    ggplot2::geom_tile(ggplot2::aes(x = 86.75, y = -4, width = 4.5, height = 2 / 12), fill = NHL_red) +
    ggplot2::geom_tile(ggplot2::aes(x = 86.75, y = 4, width = 4.5, height = 2 / 12), fill = NHL_red) +
    ggforce::geom_arc(ggplot2::aes(x0 = 89, y0 = 0, start = -atan(4.5/4) + 0.01, end = -pi + atan(4.5 / 4) - 0.01, r = 6), colour = NHL_red, size = 2 / 12) + # manually adjusted arc
    ggplot2::geom_tile(ggplot2::aes(x = 85, y = 3.75, width = 2 / 12, height = 0.42), fill = NHL_red) +
    ggplot2::geom_tile(ggplot2::aes(x = 85, y = -3.75, width = 2 / 12, height = 0.42), fill = NHL_red) +

    # Goalie nets placed as rectangles
    ggplot2::geom_tile(ggplot2::aes(x = -90.67, y = 0, width = 3.33, height = 6), fill = "#E5E5E3") + # Left # with grey fills
    ggplot2::geom_tile(ggplot2::aes(x = 90.67, y = 0, width = 3.33, height = 6), fill = "#E5E5E3") + # Right

    # Trapezoids
    ggplot2::geom_polygon(ggplot2::aes(x = c(-100, -100, -89, -89), y = c(10.92, 11.08, 7.08, 6.92)), fill = NHL_red) + # Left
    ggplot2::geom_polygon(ggplot2::aes(x = c(-100, -100, -89, -89), y = c(-10.92, -11.08, -7.08, -6.92)), fill = NHL_red) + # Left
    ggplot2::geom_polygon(ggplot2::aes(x = c(100, 100, 89, 89), y = c(10.92, 11.08, 7.08, 6.92)), fill = NHL_red) + # Right
    ggplot2::geom_polygon(ggplot2::aes(x = c(100, 100, 89, 89), y = c(-10.92, -11.08, -7.08, -6.92)), fill = NHL_red) + # Right

    # Lines
    ggplot2::geom_tile(ggplot2::aes(x = -25.5, y = 0, width = 1, height = 85), fill = NHL_blue) + # Left Blue line
    ggplot2::geom_tile(ggplot2::aes(x = 25.5, y = 0, width = 1, height = 85),  fill = NHL_blue) + # Right Blue line
    ggplot2::geom_tile(ggplot2::aes(x = -89, y = 0, width = 2 / 12, height = 73.50), fill = NHL_red) + # Left goal line (73.5 value is rounded from finding intersect of goal line and board radius)
    ggplot2::geom_tile(ggplot2::aes(x = 89, y = 0, width = 2 / 12, height = 73.50), fill = NHL_red) + # Right goal line

    # Borders as line segments - plotted last to cover up line ends, etc.
    ggplot2::geom_line(ggplot2::aes(x = c(-72, 72), y = c(42.5, 42.5))) + # Top
    ggplot2::geom_line(ggplot2::aes(x = c(-72, 72), y = c(-42.5, -42.5))) + # Bottom
    ggplot2::geom_line(ggplot2::aes(x = c(-100, -100), y = c(-14.5, 14.5))) + # Left
    ggplot2::geom_line(ggplot2::aes(x = c(100, 100), y = c(-14.5, 14.5))) + # Right
    ggforce::geom_arc(ggplot2::aes(x0 = 72, y0 = 14.5, start = pi / 2, end = 0, r = 28)) + # Top-Right
    ggforce::geom_arc(ggplot2::aes(x0 = 72, y0 = -14.5, start = pi, end =  pi / 2, r = 28)) + # Bottom-Right
    ggforce::geom_arc(ggplot2::aes(x0 = -72, y0 = 14.5, start = - pi / 2, end = 0, r = 28)) + # Top-Left
    ggforce::geom_arc(ggplot2::aes(x0 = -72, y0 = -14.5, start = pi, end =  3 * pi / 2, r = 28)) + # Bottom-Left

    # Fixed scale for the coordinate system
    ggplot2::coord_fixed() +

    # Max's mods
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
}
