page_atlas_ui <- function(systems, anatomy_svg) {
  div(class = "page-atlas",

    div(class = "atlas-header",
      h2(class = "atlas-page-title", "Functional Atlas"),
      p(class = "atlas-page-sub", "Select a tissue from the anatomy panel or dropdown from the upright panel to explore aging-associated functional clusters")
    ),

    div(class = "atlas-layout",
      div(class = "atlas-left",
        div(class = "anatomy-panel",
          div(class = "anatomy-panel-top",
            div(class = "anatomy-label", "Click a tissue region to explore"),
            div(class = "anatomy-zoom-controls",
              tags$button(type = "button", class = "anatomy-zoom-btn", id = "anatomy_zoom_out", "-"),
              tags$button(type = "button", class = "anatomy-zoom-btn", id = "anatomy_zoom_reset", "Reset"),
              tags$button(type = "button", class = "anatomy-zoom-btn", id = "anatomy_zoom_in", "+")
            )
          ),
          div(class = "anatomy-svg-wrapper",
            anatomy_svg
          )
        )
      ),

      div(class = "atlas-right",
        div(class = "atlas-selector-card",
          div(class = "cp-label", "TISSUE"),
          selectInput(
            "tissue_select",
            NULL,
            choices = c("Select a tissue..." = "", setNames(systems[["ids"]], systems[["names"]])),
            selected = "",
            selectize = FALSE,
            width = "100%"
          )
        ),
        div(class = "cluster-panel",
          div(class = "cluster-panel-header",
            div(class = "cph-title", "Cluster Details"),
            uiOutput("atlas_mode_tabs")
          ),
          div(class = "cluster-scroll",
            uiOutput("atlas_detail_body")
          )
        )
      )
    )
  )
}
