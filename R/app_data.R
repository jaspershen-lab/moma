load_moma_data <- function() {
  extdata_dir <- system.file("extdata", package = package_name())
  if (!nzchar(extdata_dir)) {
    stop("Package data files are not available.", call. = FALSE)
  }

  tissue_table <- read_csv(
    file.path(extdata_dir, "tissue_table.csv"),
    show_col_types = FALSE
  )
  tissue_clusters <- read_csv(
    file.path(extdata_dir, "tissue_cluster.csv"),
    show_col_types = FALSE,
    col_types = cols(pmids = col_character())
  )
  tissue_sets <- read_csv(
    file.path(extdata_dir, "tissue_set.csv"),
    show_col_types = FALSE
  )

  names(tissue_table) <- trimws(names(tissue_table))
  names(tissue_clusters) <- trimws(names(tissue_clusters))
  names(tissue_sets) <- trimws(names(tissue_sets))

  tissue_table <- tissue_table %>% mutate(across(where(is.character), trimws))
  tissue_clusters <- tissue_clusters %>% mutate(across(where(is.character), trimws))
  tissue_sets <- tissue_sets %>% mutate(across(where(is.character), trimws))

  if ("tissue_category" %in% names(tissue_table) && !"system" %in% names(tissue_table)) {
    tissue_table <- tissue_table %>% rename(system = tissue_category)
  }

  if ("tissue" %in% names(tissue_clusters) && !"tissue_id" %in% names(tissue_clusters)) {
    tissue_clusters <- tissue_clusters %>% rename(tissue_id = tissue)
  }

  if ("functional_name" %in% names(tissue_clusters) && !"cluster_title" %in% names(tissue_clusters)) {
    tissue_clusters <- tissue_clusters %>% rename(cluster_title = functional_name)
  }

  if ("report" %in% names(tissue_clusters) && !"summary" %in% names(tissue_clusters)) {
    tissue_clusters <- tissue_clusters %>% rename(summary = report)
  }

  if ("tissue" %in% names(tissue_sets) && !"tissue_id" %in% names(tissue_sets)) {
    tissue_sets <- tissue_sets %>% rename(tissue_id = tissue)
  }

  for (col in c("cluster_title", "summary", "pmids")) {
    if (!col %in% names(tissue_clusters)) {
      tissue_clusters[[col]] <- NA_character_
    }
  }

  if (!"feature_count" %in% names(tissue_clusters)) {
    tissue_clusters$feature_count <- NA_real_
  }

  if (!"cluster_id" %in% names(tissue_clusters)) {
    tissue_clusters$cluster_id <- as.character(seq_len(nrow(tissue_clusters)))
  }

  if (!"story" %in% names(tissue_sets)) {
    tissue_sets$story <- NA_character_
  }

  if (!"cluster_n" %in% names(tissue_sets)) {
    tissue_sets$cluster_n <- NA_integer_
  }

  tissue_clusters <- tissue_clusters %>%
    mutate(
      tissue_id = str_trim(tissue_id),
      cluster_id = as.character(cluster_id),
      feature_count = suppressWarnings(as.numeric(feature_count))
    )

  tissue_sets <- tissue_sets %>%
    mutate(
      tissue_id = str_trim(tissue_id),
      cluster_n = suppressWarnings(as.integer(cluster_n))
    )

  tissue_cluster_summary <- tissue_clusters %>%
    group_by(tissue_id) %>%
    summarise(
      n_clusters = n(),
      n_features = sum(feature_count, na.rm = TRUE),
      .groups = "drop"
    )

  tissue_full <- tissue_table %>%
    left_join(tissue_sets %>% select(tissue_id, story, cluster_n), by = "tissue_id") %>%
    left_join(tissue_cluster_summary, by = "tissue_id") %>%
    mutate(cluster_n = coalesce(cluster_n, n_clusters))

  download_cluster_export <- tissue_clusters %>%
    transmute(
      tissue = tissue_id,
      cluster_id = cluster_id,
      functional_name = cluster_title,
      report = summary,
      feature_count = feature_count,
      pmids = pmids
    ) %>%
    left_join(
      tissue_table %>%
        transmute(tissue = tissue_id, tissue_name = tissue_name, tissue_category = system),
      by = "tissue"
    ) %>%
    left_join(
      tissue_sets %>% transmute(tissue = tissue_id, story = story, cluster_n = cluster_n),
      by = "tissue"
    ) %>%
    select(
      tissue,
      tissue_name,
      tissue_category,
      cluster_id,
      functional_name,
      feature_count,
      pmids,
      cluster_n,
      story,
      report
    )

  atlas_extra_tissues <- data.frame(
    tissue_id = c("lung", "stomach", "pituitary"),
    tissue_name = c("Lung", "Stomach", "Pituitary"),
    stringsAsFactors = FALSE
  )

  atlas_tissue_table <- atlas_extra_tissues %>%
    filter(!tissue_id %in% tissue_table$tissue_id) %>%
    {
      extra <- .
      for (col in setdiff(names(tissue_table), names(extra))) {
        extra[[col]] <- tissue_table[[col]][rep(NA_integer_, nrow(extra))]
      }
      extra[, names(tissue_table), drop = FALSE]
    } %>%
    bind_rows(tissue_table, .)

  systems <- unique(tissue_table$system) %>% sort()

  list(
    tissue_table = tissue_table,
    tissue_clusters = tissue_clusters,
    tissue_sets = tissue_sets,
    tissue_cluster_summary = tissue_cluster_summary,
    tissue_full = tissue_full,
    download_cluster_export = download_cluster_export,
    atlas_tissue_table = atlas_tissue_table,
    systems = systems
  )
}
