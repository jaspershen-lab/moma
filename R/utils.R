`%||%` <- function(x, y) {
  if (is.null(x) || length(x) == 0) {
    y
  } else {
    x
  }
}

package_name <- function() {
  "moma"
}

asset_href <- function(prefix, file) {
  paste0(prefix, "/", file)
}

asset_mtime <- function(asset_dir, file) {
  info <- file.info(file.path(asset_dir, file))
  if (nrow(info) == 0 || is.na(info$mtime[[1]])) {
    return(as.integer(Sys.time()))
  }
  as.integer(info$mtime[[1]])
}

register_moma_assets <- function(prefix = "moma-assets") {
  asset_dir <- system.file("app/www", package = package_name())
  if (!nzchar(asset_dir)) {
    stop("Package assets are not available.", call. = FALSE)
  }

  current_paths <- shiny::resourcePaths()
  if (!prefix %in% names(current_paths)) {
    shiny::addResourcePath(prefix, asset_dir)
  }

  list(prefix = prefix, dir = asset_dir)
}

arrange_cluster_rows <- function(df) {
  if (!"cluster_id" %in% names(df) || nrow(df) == 0) {
    return(df)
  }

  df %>%
    mutate(cluster_order = suppressWarnings(as.numeric(cluster_id))) %>%
    arrange(is.na(cluster_order), cluster_order, cluster_id) %>%
    select(-cluster_order)
}

parse_pmid_ids <- function(pmids) {
  pmid_text <- as.character(pmids %||% "")
  if (length(pmid_text) == 0 || is.na(pmid_text[[1]])) {
    return(character())
  }
  pmid_ids <- str_extract_all(pmid_text, "\\d+")[[1]]
  unique(pmid_ids[nzchar(pmid_ids)])
}

build_pmid_links_ui <- function(pmids) {
  pmid_ids <- parse_pmid_ids(pmids)

  if (length(pmid_ids) == 0) {
    return(div(class = "cluster-detail-empty", "No references available for this cluster."))
  }

  div(
    class = "pmid-link-list",
    lapply(pmid_ids, function(pmid) {
      tags$a(
        href = paste0("https://pubmed.ncbi.nlm.nih.gov/", pmid, "/"),
        target = "_blank",
        rel = "noopener noreferrer",
        class = "pmid-link",
        paste0("PMID ", pmid)
      )
    })
  )
}

build_anatomy_svg_ui <- function(svg_path, tissue_info) {
  if (!file.exists(svg_path)) {
    return(
      div(
        class = "anatomy-placeholder",
        div(
          class = "anatomy-placeholder-body",
          div(
            style = "text-align:center; color:#8C8278; font-size:13px; padding: 20px;",
            "Anatomy SVG not found.",
            tags$br(),
            "Place macaque_anatomy.svg in inst/app/www/"
          )
        ),
        div(
          class = "anatomy-placeholder-hint",
          "Replace with actual macaque anatomy SVG with tissue IDs matching tissue_table."
        )
      )
    )
  }

  normalize_svg_id <- function(x) {
    x %>%
      str_trim() %>%
      str_replace_all("[^A-Za-z0-9]+", "_") %>%
      str_replace_all("_+", "_") %>%
      str_replace_all("^_|_$", "") %>%
      str_to_lower()
  }

  svg_alias_to_tissue <- c(
    face_skin = "facial_skin",
    back_skin = "skin_of_back",
    thyroid = "thyroid_gland"
  )
  context_layer_ids <- c("body", "others", "brain_1", "brain_2")

  svg_doc <- read_xml(svg_path)
  svg_root <- xml_find_first(svg_doc, "/*[local-name()='svg']")
  root_class <- xml_attr(svg_root, "class")
  if (is.na(root_class)) {
    root_class <- ""
  }
  xml_set_attr(svg_root, "id", "macaque-svg")
  xml_set_attr(svg_root, "class", trimws(paste(root_class, "anatomy-svg-inline")))
  xml_set_attr(svg_root, "width", "100%")
  xml_set_attr(svg_root, "preserveAspectRatio", "xMidYMid meet")

  tissue_lookup <- tissue_info %>%
    mutate(norm_tissue_id = normalize_svg_id(tissue_id))

  svg_groups <- xml_find_all(svg_doc, "//*[local-name()='g' and @id]")
  svg_ids <- xml_attr(svg_groups, "id")
  norm_svg_ids <- normalize_svg_id(svg_ids)
  mapped_norm_ids <- ifelse(
    norm_svg_ids %in% names(svg_alias_to_tissue),
    unname(svg_alias_to_tissue[norm_svg_ids]),
    norm_svg_ids
  )

  for (i in seq_along(svg_groups)) {
    node <- svg_groups[[i]]
    node_id <- svg_ids[[i]]
    node_class <- xml_attr(node, "class")
    if (is.na(node_class)) {
      node_class <- ""
    }

    if (normalize_svg_id(node_id) %in% context_layer_ids) {
      xml_set_attr(node, "class", trimws(paste(node_class, "context-region")))
      next
    }

    tissue_match <- tissue_lookup %>%
      filter(norm_tissue_id == mapped_norm_ids[[i]]) %>%
      slice_head(n = 1)
    if (nrow(tissue_match) == 0) {
      next
    }

    xml_set_attr(node, "data-tissue", tissue_match$tissue_id[[1]])
    xml_set_attr(node, "data-tissue-name", tissue_match$tissue_name[[1]])
    xml_set_attr(node, "aria-label", tissue_match$tissue_name[[1]])
    xml_set_attr(node, "class", trimws(paste(node_class, "tissue-region")))
  }

  svg_markup <- as.character(svg_doc)
  svg_markup <- sub("^<\\?xml[^>]+>\\s*", "", svg_markup)
  HTML(svg_markup)
}
