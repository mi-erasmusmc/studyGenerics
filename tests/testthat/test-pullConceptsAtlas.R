test_that("pullConceptsAtlas downloads concept sets correctly", {

  skip_if(Sys.getenv("ATLAS_TOKEN") == "")

  require(ROhdsiWebApi)

  baseUrl <- "https://atlas.darwin-eu.org/WebAPI"
  token <- Sys.getenv("ATLAS_TOKEN")
  ROhdsiWebApi::setAuthHeader(baseUrl, authHeader = token)
  ROhdsiWebApi::getCdmSources(baseUrl)

  downloaded_concepts <- pullConceptsAtlas(
    conceptSetList = c(5305, 5293),
    conceptSetType = "cancer_cohorts",
    baseUrl,
    deletePrevious = TRUE,
    patternToRemove = c("p4-c4-002", "onconet", "hierarchy_based")
  )

  downloaded_concepts |>
    dplyr::filter(conceptSetId %in% c(5305, 5293)) |>
    nrow() |>
    expect_equal(2)

  downloaded_concepts |>
    dplyr::pull(fileName) |>
    stringr::str_detect("lung_cancer") |>
    expect_all_true()

  unlink(
    here::here(
    "inst/concept_sets",
    "cancer_cohorts"
    ),
    recursive = TRUE
  )

})
