test_that(
  "Output folders exist in working directory if outputDir is NULL", {

    # -- params
    path <- testthat::test_path(
      "data",
      "results_execution"
    )

    dbname <- "TEST-CDM"

    # -- FUN
    results_loc <- studyGenerics::createResultsDir(
      outputDir = NULL,
      dbname = "TEST-CDM"
    )

    # -- test
    expect_true({
      dir.exists(c(results_loc$resultsDir))
    })

    expect_equal(
      results_loc$resultsDirName,
      paste(
        "results",
        dbname,
        sep = "_"
        )
    )

    unlink(
      results_loc$resultsDir,
      recursive = TRUE
    )

  })

test_that(
  "Output folders exist in working directory if outputDir is another folder", {

    # -- params
    path <- testthat::test_path(
      "data",
      "results_execution"
    )
    outputDir <- file.path(
      tempdir(),
      "results"
    )

    # -- FUN
    results_loc <- createResultsDir(
      outputDir,
      dbname = "TEST-CDM"
    )

    # -- test
    expect_true({
      dir.exists(c(results_loc$resultsDir))
    })

    expect_equal(
      results_loc$resultsDirName,
      paste(
        "results",
        dbname,
        sep = "_"
      )
    )

    unlink(
      results_loc$outputDir,
      recursive = TRUE
    )

  })
