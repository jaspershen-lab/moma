page_download_ui <- function(systems, tissue_table, tissue_clusters) {
  div(class = "page-download",

    div(class = "dl-header",
      div(class = "dl-eyebrow", "Data access"),
      h2(class = "dl-title", "Download"),
      p(class = "dl-intro",
        "All functional cluster results are freely available for download. Data can be accessed by selected tissue systems or selected tissues."
      )
    ),

    div(class = "dl-body",

      div(class = "dl-all-section",
        div(class = "dl-all-card",
          div(class = "dac-left",
            div(class = "dac-icon", "⊞"),
            div(class = "dac-body",
              div(class = "dac-title", "Complete dataset"),
              div(class = "dac-desc", "All tissues · All clusters · Tissue overview included · CSV format")
            )
          ),
          downloadButton("download_all", "Download all data", class = "btn-dl-all")
        )
      ),

      div(class = "dl-modes",

        div(class = "dl-mode",
          div(class = "dl-mode-header",
            div(class = "dlm-icon", "⬡"),
            div(class = "dlm-title", "Download by system"),
            div(class = "dlm-sub", "Export all tissues and clusters from one or more selected systems")
          ),
          div(class = "dl-selector-row",
            div(class = "dl-selector-input",
              selectizeInput(
                "dl_system_select",
                NULL,
                choices = setNames(systems, systems),
                selected = NULL,
                multiple = TRUE,
                width = "100%",
                options = list(
                  placeholder = "Select one or more systems...",
                  plugins = list("remove_button")
                )
              )
            ),
            downloadButton("download_system_clusters_csv", "Download CSV", class = "btn-dl-tissue")
          )
        ),

        div(class = "dl-mode",
          div(class = "dl-mode-header",
            div(class = "dlm-icon", "◎"),
            div(class = "dlm-title", "Download by tissue"),
            div(class = "dlm-sub", "Export cluster-level results for one or more selected tissues")
          ),
          div(class = "dl-selector-row",
            div(class = "dl-selector-input",
              selectizeInput(
                "dl_tissue_select",
                NULL,
                choices = setNames(tissue_table$tissue_id, tissue_table$tissue_name),
                selected = NULL,
                multiple = TRUE,
                width = "100%",
                options = list(
                  placeholder = "Select one or more tissues...",
                  plugins = list("remove_button")
                )
              )
            ),
            downloadButton("download_tissue_clusters_csv", "Download CSV", class = "btn-dl-tissue")
          ),
          uiOutput("dl_tissue_preview")
        )
      ),

      div(class = "dl-note",
        div(class = "dn-icon", "ℹ"),
        div(class = "dn-text",
          "All files are provided in comma-separated values (CSV) format. Each row represents one tissue-cluster result and includes the updated fields from the current release, including functional_name, report, feature_count, pmids, and tissue-level story/cluster_n when available."
        )
      )
    )
  )
}
