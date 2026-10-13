test_that("createResultsDir requires an explicit output directory", {
  expect_error(createResultsDir(dbname = "TEST-CDM"))
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
    dbname <- "TEST-CDM"

    # -- FUN
    results_loc <- createResultsDir(
      outputDir,
      dbname = dbname
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
