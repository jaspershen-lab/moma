#' Build the macaque atlas Shiny application
#'
#' @return A Shiny application object.
moma_app <- function() {
  data <- load_moma_data()
  assets <- register_moma_assets()
  anatomy_svg <- build_anatomy_svg_ui(
    file.path(assets$dir, "macaque_anatomy.svg"),
    data$atlas_tissue_table %>% select(tissue_id, tissue_name) %>% distinct()
  )

  shinyApp(
    ui = app_ui(data, anatomy_svg, assets),
    server = app_server(data)
  )
}

#' Launch the macaque atlas Shiny application
#'
#' @param launch.browser Whether to launch the app in a browser.
#' @param ... Additional arguments passed to [shiny::runApp()].
#'
#' @return Invisibly returns the running Shiny app.
moma <- function(launch.browser = interactive(), ...) {
  shiny::runApp(
    moma_app(),
    launch.browser = launch.browser,
    ...
  )
}
