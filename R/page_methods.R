page_methods_ui <- function() {
  div(class = "page-methods",

    div(class = "methods-header",
      div(class = "methods-eyebrow", "Analytical framework"),
      h2(class = "methods-title", "Methods"),
      p(class = "methods-intro",
        "This atlas reanalyzes the metabolomics component of a landmark macaque aging study at the MS2-supported feature level. Following the differential analysis logic of the original study, we identified age-associated LC-MS/MS features in each tissue and used Spec2Function to infer their biological functions directly from MS2 spectra."
      )
    ),

    div(class = "methods-body",

      # Section 1
      div(class = "methods-section",
        div(class = "ms-number", "01"),
        div(class = "ms-content",
          h3(class = "ms-heading", "Study source"),
          tagList(
            p(class = "ms-text",
              "The underlying dataset originates from the multi-omics macaque aging resource reported by Li et al. in Nature Methods (2025). That study profiled 30 tissues from female rhesus macaques (Macaca mulatta) across multiple life stages, generating a comprehensive molecular view of mammalian aging across organ systems."
            ),
            p(class = "ms-text",
              "This atlas specifically extends the metabolomics component of that resource and focuses on features supported by MS2 spectra, enabling downstream functional interpretation from tandem mass spectrometry data."
            )
          )
        )
      ),

      div(class = "methods-divider"),

      # Section 2
      div(class = "methods-section",
        div(class = "ms-number", "02"),
        div(class = "ms-content",
          h3(class = "ms-heading", "Analytical adaptation"),
          tagList(
            p(class = "ms-text",
              "In the original study, metabolomics differences were interpreted primarily at the metabolite level. In this atlas, we adopted the same overall analytical framework but shifted the unit of analysis to the MS2-supported feature level."
            ),
            p(class = "ms-text",
              tags$strong("More specifically:")
            ),
            div(class = "adaptation-points",
              div(class = "ap-item",
                div(class = "ap-dot"),
                "only LC-MS/MS features with associated MS2 spectra were retained for downstream analysis;"
              ),
              div(class = "ap-item",
                div(class = "ap-dot"),
                "age-associated differential analysis was conducted in each tissue following the analytical strategy of the original study;"
              ),
              div(class = "ap-item",
                div(class = "ap-dot"),
                "instead of relying on definitive metabolite identification, differential MS2-supported features were interpreted using Spec2Function;"
              ),
              div(class = "ap-item",
                div(class = "ap-dot"),
                "inferred functions were then organized into tissue-level functional clusters for visualization and exploration."
              )
            ),
            br(),
            p(class = "ms-text",
              "This design preserves the comparative structure of the original aging analysis while extending it toward a more inclusive and function-oriented interpretation of untargeted metabolomics data."
            )
          )
        )
      ),

      div(class = "methods-divider"),

      # Section 3: Workflow
      div(class = "methods-section",
        div(class = "ms-number", "03"),
        div(class = "ms-content",
          h3(class = "ms-heading", "Workflow"),
          div(class = "workflow-steps",
            div(class = "ws-step",
              div(class = "ws-num", "1"),
              div(class = "ws-body",
                div(class = "ws-title", "Select LC-MS/MS features"),
                div(class = "ws-desc", "Select LC-MS/MS features with valid MS2 spectra")
              )
            ),
            div(class = "ws-connector"),
            div(class = "ws-step",
              div(class = "ws-num", "2"),
              div(class = "ws-body",
                div(class = "ws-title", "Tissue-wise differential analysis"),
                div(class = "ws-desc", "Perform tissue-wise differential analysis of age-associated features")
              )
            ),
            div(class = "ws-connector"),
            div(class = "ws-step",
              div(class = "ws-num", "3"),
              div(class = "ws-body",
                div(class = "ws-title", "Spec2Function inference"),
                div(class = "ws-desc", "Infer biological functions from MS2 spectra using Spec2Function")
              )
            ),
            div(class = "ws-connector"),
            div(class = "ws-step",
              div(class = "ws-num", "4"),
              div(class = "ws-body",
                div(class = "ws-title", "Cluster summarization"),
                div(class = "ws-desc", "Summarize related features into interpretable functional clusters")
              )
            )
          )
        )
      ),

      div(class = "methods-divider"),

      # Section 4: Definitions
      div(class = "methods-section",
        div(class = "ms-number", "04"),
        div(class = "ms-content",
          h3(class = "ms-heading", "Output definitions"),
          div(class = "definitions-grid",
            div(class = "def-item",
              div(class = "def-term", "Feature"),
              div(class = "def-desc", "An LC-MS/MS signal with m/z, retention time, and MS2 spectrum")
            ),
            div(class = "def-item",
              div(class = "def-term", "Functional cluster"),
              div(class = "def-desc", "A group of differential features sharing related inferred biological functions")
            ),
            div(class = "def-item",
              div(class = "def-term", "Representative terms"),
              div(class = "def-desc", "Summarized functional labels, not definitive metabolite identifications")
            ),
            div(class = "def-item",
              div(class = "def-term", "Directionality"),
              div(class = "def-desc", "A higher-level summary that synthesizes all functional clusters within a tissue")
            )
          ),
          div(class = "definition-note",
            div(class = "dn-icon", "ℹ"),
            div(class = "dn-text",
              "This atlas emphasizes functional interpretation rather than definitive chemical identification. Results should therefore be read as spectrum-based functional summaries of tissue aging."
            )
          )
        )
      ),

      div(class = "methods-divider"),

      # Section 5: Data availability
      div(class = "methods-section",
        div(class = "ms-number", "05"),
        div(class = "ms-content",
          h3(class = "ms-heading", "Data Availability"),
          div(class = "data-sources",
            div(class = "ds-item",
              div(class = "ds-icon", "📄"),
              div(class = "ds-body",
                div(class = "ds-title", "Paper 1 · Spec2Function"),
                div(class = "ds-desc", "Zhang et al. · Deciphering the Biological Function of Tandem Mass Spectra Using a Dual-Modal Metabolite Language Model"),
                tags$a(href = "#", class = "ds-link", "Manuscript pending →")
              )
            ),
            div(class = "ds-item",
              div(class = "ds-icon", "📦"),
              div(class = "ds-body",
                div(class = "ds-title", "Paper 2 · Macaque multi-omics study"),
                div(class = "ds-desc", "A multi-omics molecular landscape of 30 tissues in aging female rhesus macaques"),
                tags$a(href = "https://doi.org/10.1038/s41592-025-02912-y", target = "_blank", rel = "noopener noreferrer", class = "ds-link", "View DOI →")
              )
            ),
            div(class = "ds-item",
              div(class = "ds-icon", "⌨"),
              div(class = "ds-body",
                div(class = "ds-title", "Analysis website"),
                div(class = "ds-desc", "Spec2Function web resource and project repository"),
                tags$a(href = "https://github.com/jaspershen-lab/spec2function", target = "_blank", rel = "noopener noreferrer", class = "ds-link", "Open website →")
              )
            ),
            div(class = "ds-item",
              div(class = "ds-icon", "🗄"),
              div(class = "ds-body",
                div(class = "ds-title", "Raw data accession"),
                div(class = "ds-desc", "OMIX (accession no. OMIX001779)"),
                tags$a(href = "https://ngdc.cncb.ac.cn/omix", target = "_blank", rel = "noopener noreferrer", class = "ds-link", "Access OMIX →")
              )
            )
          )
        )
      )
    )
  )
}
