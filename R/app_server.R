app_server <- function(data) {
  function(input, output, session) {
    current_page <- reactiveVal("home")

    observe_nav <- function(btn_id, page_id) {
      observeEvent(input[[btn_id]], {
        current_page(page_id)
        session$sendCustomMessage("navigate", page_id)
      })
    }

    observe_nav("nav_home", "home")
    observe_nav("nav_atlas", "atlas")
    observe_nav("nav_methods", "methods")
    observe_nav("nav_download", "download")

    observeEvent(input$hero_explore_btn, {
      current_page("atlas")
      session$sendCustomMessage("navigate", "atlas")
    })

    observeEvent(input$hero_methods_btn, {
      current_page("methods")
      session$sendCustomMessage("navigate", "methods")
    })

    selected_tissue <- reactiveVal(NULL)
    atlas_detail_mode <- reactiveVal("cluster")

    observeEvent(input$svg_tissue_click, {
      tid <- input$svg_tissue_click
      if (!is.null(tid) && tid %in% data$atlas_tissue_table$tissue_id) {
        selected_tissue(tid)
      }
    })

    observeEvent(input$tissue_select, {
      if (!is.null(input$tissue_select) && input$tissue_select != "") {
        selected_tissue(input$tissue_select)
      } else {
        selected_tissue(NULL)
      }
    })

    observeEvent(
      selected_tissue(),
      {
        tid <- selected_tissue()
        updateSelectInput(session, "tissue_select", selected = if (is.null(tid)) "" else tid)

        if (!is.null(tid) && nzchar(tid)) {
          session$sendCustomMessage("highlightTissue", tid)
          tclusters <- data$tissue_clusters %>%
            filter(tissue_id == tid) %>%
            arrange_cluster_rows()

          choices <- if (nrow(tclusters) > 0) {
            setNames(
              tclusters$cluster_id,
              paste0("Cluster ", tclusters$cluster_id, " · ", tclusters$cluster_title)
            )
          } else {
            character(0)
          }
          updateSelectInput(
            session,
            "cluster_select",
            choices = c("Select a cluster..." = "", choices),
            selected = ""
          )
        } else {
          atlas_detail_mode("cluster")
          session$sendCustomMessage("highlightTissue", "")
          session$sendCustomMessage("resetAtlasSelection", list())
          updateSelectInput(
            session,
            "cluster_select",
            choices = c("Select a cluster..." = ""),
            selected = ""
          )
        }
      },
      ignoreNULL = FALSE
    )

    observeEvent(input$atlas_mode_overview, {
      atlas_detail_mode("overview")
    })

    observeEvent(input$atlas_mode_cluster, {
      atlas_detail_mode("cluster")
    })

    output$atlas_mode_tabs <- renderUI({
      mode <- atlas_detail_mode()

      div(
        class = "atlas-mode-tabs",
        actionButton(
          "atlas_mode_cluster",
          "Cluster",
          class = paste("atlas-mode-tab", if (identical(mode, "cluster")) "is-active" else "")
        ),
        actionButton(
          "atlas_mode_overview",
          "Overview",
          class = paste("atlas-mode-tab", if (identical(mode, "overview")) "is-active" else "")
        )
      )
    })

    output$atlas_detail_body <- renderUI({
      mode <- atlas_detail_mode()
      tid <- selected_tissue()
      tclusters <- if (!is.null(tid) && nzchar(tid)) {
        data$tissue_clusters %>% filter(tissue_id == tid) %>% arrange_cluster_rows()
      } else {
        data$tissue_clusters %>% slice(0)
      }

      if (identical(mode, "cluster")) {
        choices <- if (nrow(tclusters) > 0) {
          setNames(
            tclusters$cluster_id,
            paste0("Cluster ", tclusters$cluster_id, " · ", tclusters$cluster_title)
          )
        } else {
          character(0)
        }
        selected_id <- input$cluster_select %||% ""
        if (!selected_id %in% c("", tclusters$cluster_id)) {
          selected_id <- ""
        }

        return(
          div(
            class = "atlas-detail-shell",
            div(
              class = "cluster-selector-card",
              div(class = "cp-label", "CLUSTER"),
              selectInput(
                "cluster_select",
                NULL,
                choices = c("Select a cluster..." = "", choices),
                selected = selected_id,
                selectize = FALSE,
                width = "100%"
              )
            ),
            div(
              class = "atlas-detail-scrollbody",
              uiOutput("cluster_detail")
            )
          )
        )
      }

      div(
        class = "atlas-detail-shell",
        div(
          class = "atlas-detail-scrollbody",
          uiOutput("tissue_story")
        )
      )
    })

    output$tissue_story <- renderUI({
      tid <- selected_tissue()
      if (is.null(tid)) {
        return(
          div(
            class = "cluster-placeholder cluster-placeholder-compact",
            div(class = "cp-icon", "◌"),
            p(class = "cp-text", "Select a tissue to view its overview and cluster count.")
          )
        )
      }

      tset <- data$tissue_sets %>% filter(tissue_id == tid) %>% slice_head(n = 1)
      story_text <- if (nrow(tset) > 0 && !is.na(tset$story[[1]]) && nzchar(tset$story[[1]])) {
        tset$story[[1]]
      } else {
        "No tissue-level overview is available for this tissue yet."
      }

      div(
        class = "tissue-story-card",
        div(
          class = "cluster-detail-item overview-story-block",
          div(class = "cluster-detail-label", "Overview"),
          div(class = "cluster-detail-summary", story_text)
        )
      )
    })

    output$cluster_detail <- renderUI({
      tid <- selected_tissue()
      cid <- input$cluster_select

      if (is.null(tid)) {
        return(
          div(
            class = "cluster-placeholder",
            div(class = "cp-icon", "◈"),
            p(class = "cp-text", "Cluster details will appear here after tissue selection.")
          )
        )
      }

      tclusters <- data$tissue_clusters %>%
        filter(tissue_id == tid) %>%
        arrange_cluster_rows()
      if (nrow(tclusters) == 0) {
        return(
          div(
            class = "cluster-placeholder",
            p("Too few significant differential features were detected in this tissue to derive reliable cluster-level information.")
          )
        )
      }

      if (is.null(cid) || !cid %in% tclusters$cluster_id) {
        return(
          div(
            class = "cluster-placeholder cluster-placeholder-compact",
            div(class = "cp-icon", "◎"),
            p(class = "cp-text", "Select a cluster to read its functional report and linked references.")
          )
        )
      }

      cl <- tclusters %>% filter(cluster_id == cid) %>% slice_head(n = 1)
      tinfo <- data$atlas_tissue_table %>% filter(tissue_id == tid) %>% slice_head(n = 1)
      tset <- data$tissue_sets %>% filter(tissue_id == tid) %>% slice_head(n = 1)
      cluster_total <- if (nrow(tset) > 0 && !is.na(tset$cluster_n[[1]])) {
        tset$cluster_n[[1]]
      } else {
        nrow(tclusters)
      }
      category_label <- if (nrow(tinfo) > 0 && !is.na(tinfo$system[[1]]) && nzchar(tinfo$system[[1]])) {
        tinfo$system[[1]]
      } else {
        "Not annotated"
      }

      div(
        class = "cluster-detail-card",
        div(
          class = "cluster-detail-head",
          div(class = "cc-id", paste0("Cluster ", cl$cluster_id[[1]])),
          div(class = "cluster-detail-title", cl$cluster_title[[1]])
        ),
        div(
          class = "cluster-stat-row",
          div(
            class = "cluster-mini-card category",
            div(class = "cluster-mini-label", "Category"),
            div(class = "cluster-mini-value", category_label)
          ),
          div(
            class = "cluster-mini-card number",
            div(class = "cluster-mini-label", "Clusters"),
            div(class = "cluster-mini-value", cluster_total)
          ),
          div(
            class = "cluster-mini-card size",
            div(class = "cluster-mini-label", "Cluster size"),
            div(class = "cluster-mini-value", cl$feature_count[[1]])
          )
        ),
        div(
          class = "cluster-detail-grid",
          div(
            class = "cluster-detail-item",
            div(class = "cluster-detail-label", "Functional Report"),
            div(class = "cluster-detail-summary", cl$summary[[1]])
          ),
          div(
            class = "cluster-detail-item",
            div(class = "cluster-detail-label", "References"),
            build_pmid_links_ui(cl$pmids[[1]])
          )
        )
      )
    })

    outputOptions(output, "atlas_mode_tabs", suspendWhenHidden = FALSE)
    outputOptions(output, "atlas_detail_body", suspendWhenHidden = FALSE)
    outputOptions(output, "tissue_story", suspendWhenHidden = FALSE)
    outputOptions(output, "cluster_detail", suspendWhenHidden = FALSE)

    selected_download_tissues <- reactive({
      tids <- input$dl_tissue_select
      tids[!is.na(tids) & nzchar(tids)]
    })

    selected_download_systems <- reactive({
      systems_sel <- input$dl_system_select
      systems_sel[!is.na(systems_sel) & nzchar(systems_sel)]
    })

    output$dl_tissue_preview <- renderUI({
      tids <- selected_download_tissues()
      if (length(tids) == 0) {
        return(div(class = "dl-preview-note", "Select one or more tissues to prepare a download."))
      }

      n_clusters <- data$tissue_clusters %>% filter(tissue_id %in% tids) %>% nrow()
      div(
        class = "dl-preview-note",
        paste(length(tids), if (length(tids) == 1) "tissue selected" else "tissues selected"),
        " · ",
        n_clusters,
        if (n_clusters == 1) " cluster will be exported" else " clusters will be exported"
      )
    })

    output$download_all <- downloadHandler(
      filename = "macaque_aging_atlas_all.csv",
      content = function(file) {
        write_csv(data$download_cluster_export, file)
      }
    )

    output$download_tissue_clusters_csv <- downloadHandler(
      filename = function() {
        tids <- selected_download_tissues()
        label <- if (length(tids) == 1) tids[[1]] else paste0(length(tids), "_tissues")
        paste0("moma_", label, "_clusters.csv")
      },
      content = function(file) {
        tids <- selected_download_tissues()
        req(length(tids) > 0)
        write_csv(data$download_cluster_export %>% filter(tissue %in% tids), file)
      }
    )

    output$download_system_clusters_csv <- downloadHandler(
      filename = function() {
        selected_systems <- selected_download_systems()
        label <- if (length(selected_systems) == 1) {
          gsub("[^a-zA-Z0-9]", "_", selected_systems[[1]])
        } else {
          paste0(length(selected_systems), "_systems")
        }
        paste0("moma_", label, "_clusters.csv")
      },
      content = function(file) {
        selected_systems <- selected_download_systems()
        req(length(selected_systems) > 0)
        tids <- data$tissue_table %>%
          filter(system %in% selected_systems) %>%
          pull(tissue_id)
        write_csv(data$download_cluster_export %>% filter(tissue %in% tids), file)
      }
    )

    outputOptions(output, "dl_tissue_preview", suspendWhenHidden = FALSE)
    outputOptions(output, "download_all", suspendWhenHidden = FALSE)
    outputOptions(output, "download_tissue_clusters_csv", suspendWhenHidden = FALSE)
    outputOptions(output, "download_system_clusters_csv", suspendWhenHidden = FALSE)
  }
}
