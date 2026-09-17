test_that("pullConceptsAtlas downloads concept sets and saves valid JSON files", {
  skip_on_cran()
  skip_if(
    !nzchar(Sys.getenv("ATLAS_TOKEN")),
    "ATLAS_TOKEN is not set; live test skipped"
  )
  for (package in c("httr", "RJSONIO", "lubridate", "rlang")) {
    skip_if_not_installed(package)
  }

  # Save the real ATLAS downloads in a temporary study folder.
  testProject <- withr::local_tempdir()
  local_mocked_bindings(
    here = function(...) file.path(testProject, ...),
    .package = "here"
  )

  downloaded_concepts <- pullConceptsAtlas(
    conceptSetList = c(5305, 5293),
    conceptSetType = "cancer_cohorts",
    baseUrl = "https://atlas.darwin-eu.org/WebAPI",
    deletePrevious = TRUE,
    patternToRemove = c("p4-c4-002", "onconet", "hierarchy_based")
  )

  # Expect both lung cancer concept sets and their saved definitions.
  expect_equal(downloaded_concepts$conceptSetId, c(5305, 5293))
  expect_true(all(grepl("lung_cancer", downloaded_concepts$fileName)))

  for (file_name in downloaded_concepts$fileName) {
    output <- file.path(
      testProject, "inst", "concept_sets", "cancer_cohorts", file_name
    )
    expect_true(file.exists(output))
    definition <- jsonlite::fromJSON(output, simplifyVector = FALSE)
    expect_true("items" %in% names(definition))
    expect_gt(length(definition$items), 0)
  }
})
