app_ui <- function(data, anatomy_svg, assets) {
  fluidPage(
    tags$head(
      tags$title("MOMA"),
      tags$link(rel = "preconnect", href = "https://fonts.googleapis.com"),
      tags$link(rel = "preconnect", href = "https://fonts.gstatic.com", crossorigin = NA),
      tags$link(
        rel = "icon",
        type = "image/png",
        href = paste0(
          asset_href(assets$prefix, "shen_lab_logo.png"),
          "?v=",
          asset_mtime(assets$dir, "shen_lab_logo.png")
        )
      ),
      tags$link(
        href = "https://fonts.googleapis.com/css2?family=DM+Serif+Display:ital@0;1&family=DM+Sans:ital,opsz,wght@0,9..40,300;0,9..40,400;0,9..40,500;0,9..40,600;1,9..40,300&family=JetBrains+Mono:wght@400;500&display=swap",
        rel = "stylesheet"
      ),
      tags$link(
        rel = "stylesheet",
        href = paste0(
          asset_href(assets$prefix, "styles.css"),
          "?v=",
          asset_mtime(assets$dir, "styles.css")
        )
      ),
      tags$script(
        src = paste0(
          asset_href(assets$prefix, "interactions.js"),
          "?v=",
          asset_mtime(assets$dir, "interactions.js")
        )
      )
    ),
    div(
      class = "nav-bar",
      div(
        class = "nav-inner",
        div(
          class = "nav-logo",
          tags$img(
            src = asset_href(assets$prefix, "shen_lab.png"),
            alt = "Shen Lab",
            class = "nav-logo-image"
          )
        ),
        div(
          class = "nav-links",
          actionLink("nav_home", "Home", class = "nav-link active"),
          actionLink("nav_atlas", "Atlas", class = "nav-link"),
          actionLink("nav_methods", "Methods", class = "nav-link"),
          actionLink("nav_download", "Download", class = "nav-link")
        )
      )
    ),
    div(id = "page-home", class = "page active", page_home_ui(assets$prefix)),
    div(
      id = "page-atlas",
      class = "page",
      page_atlas_ui(
        systems = list(
          ids = data$atlas_tissue_table$tissue_id,
          names = data$atlas_tissue_table$tissue_name
        ),
        anatomy_svg = anatomy_svg
      )
    ),
    div(id = "page-methods", class = "page", page_methods_ui()),
    div(
      id = "page-download",
      class = "page",
      page_download_ui(
        systems = data$systems,
        tissue_table = data$tissue_table,
        tissue_clusters = data$tissue_clusters
      )
    )
  )
}
