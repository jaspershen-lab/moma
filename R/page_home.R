page_home_ui <- function(assets_prefix = NULL) {
  hero_image_src <- if (is.null(assets_prefix)) {
    "monkey_atlas.png"
  } else {
    asset_href(assets_prefix, "monkey_atlas.png")
  }

  div(class = "page-home",

    # Hero section
    div(class = "hero-section",
      div(class = "hero-content",
        div(class = "hero-eyebrow", "Rhesus Macaque · Multi-tissue · Spec2Function"),
        h1(class = "hero-title", tags$span(class = "hero-title-line", "Macaque Multi-Organ"), tags$span(class = "hero-title-line title-accent", "Metabolic Aging Atlas")),
        p(class = "hero-subtitle",
          "An interactive atlas revealing metabolic aging signatures across monkey tissues using MS/MS functional inference (Spec2Function)."
        ),
        div(class = "hero-actions",
          actionButton("hero_explore_btn", "Explore Atlas →", class = "btn-primary"),
          actionButton("hero_methods_btn", "View Methods", class = "btn-secondary")
        )
      ),
      div(class = "hero-visual",
        div(class = "hero-image-frame",
          tags$img(
            src = hero_image_src,
            alt = "Macaque atlas overview",
            class = "hero-image"
          )
        )
      )
    ),

    # Summary cards
    div(class = "summary-cards",
      div(class = "summary-card",
        div(class = "sc-icon", "◈"),
        div(class = "sc-body",
          div(class = "sc-val", "Spectra to Function"),
          div(class = "sc-sub", "Spec2Function interprets untargeted metabolomics data by directly inferring biological functions from MS/MS spectra.")
        )
      ),
      div(class = "summary-card",
        div(class = "sc-icon", "⬡"),
        div(class = "sc-body",
          div(class = "sc-val", "30 Tissues"),
          div(class = "sc-sub", "Comprehensive metabolomics profiling across 30 monkey tissues covering major physiological systems.")
        )
      ),
      div(class = "summary-card",
        div(class = "sc-icon", "◎"),
        div(class = "sc-body",
          div(class = "sc-val", "Interactive Atlas"),
          div(class = "sc-sub", "Explore tissue-specific metabolic functional clusters through an interactive monkey anatomy map.")
        )
      )
    ),

    # About section
    div(class = "about-section",
      div(class = "about-inner",
        div(class = "about-shell",
          div(class = "about-header",
            div(class = "about-tag", "About this resource"),
            h2(class = "about-heading", "Interactive atlas of metabolic aging across monkey tissues")
          ),
          div(class = "about-layout",
            div(class = "about-topic-grid",
              div(class = "about-topic-card",
                div(class = "about-badge", "Background"),
                p(class = "about-topic-text",
                  "This resource presents an interactive atlas of metabolic aging across monkey tissues. The atlas is based on the multi-organ metabolomics dataset reported in Nature Methods (2025) and focuses on MS/MS-resolved metabolomics features."
                )
              ),
              div(class = "about-topic-card",
                div(class = "about-badge", "Analysis framework"),
                p(class = "about-topic-text",
                  "Functional interpretation was performed using Spec2Function. By applying this framework to differential metabolomics analysis across tissues, we identified functional metabolic clusters associated with aging."
                )
              ),
              div(class = "about-topic-card",
                div(class = "about-badge", "Resource overview"),
                p(class = "about-topic-text",
                  "The resulting atlas allows users to explore tissue-specific metabolic functional modules through an interactive anatomical interface and provides downloadable results for further analysis."
                )
              )
            ),
            div(class = "contact-panel",
              div(class = "about-badge", "Contact Us"),
              h3(class = "contact-panel-title", "Reach Shen Lab"),
              p(class = "contact-panel-text", "For questions about the atlas, data access, or potential collaboration, feel free to reach out by email."),
              div(class = "contact-panel-email", "xiaotao.shen@ntu.edu.sg"),
              tags$a(
                href = "mailto:xiaotao.shen@ntu.edu.sg",
                class = "contact-panel-button",
                "Contact"
              )
            )
          )
        )
      )
    ),

    # Footer
    div(class = "home-footer",
      div(class = "footer-inner",
        div(class = "footer-citation",
          span(class = "footer-label", "Cite: "),
          span("Zhang et al. · Deciphering the Biological Function of Tandem Mass Spectra Using a Dual-Modal Metabolite Language Model · Unpublished manuscript")
        ),
        div(class = "footer-meta", "Version 2026")
      )
    )
  )
}
