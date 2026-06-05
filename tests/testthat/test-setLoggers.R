test_that("Create logger files correctly", {
  outputDir <- file.path(
    tempdir()
  )

  dirs <- createResultsDir(
    outputDir = outputDir,
    dbname = "LOGGER"
  )

  studyGenerics::setLoggers(
    resultsDir = dirs$resultsDir
  )

  ParallelLogger::logError("Test error.txt")
  ParallelLogger::clearLoggers()

  file.path(
    outputDir,
    "results_LOGGER",
    "log.txt"
  ) |>
    file.exists() |>
    expect_true()

  file.path(
    outputDir,
    "results_LOGGER",
    "error.txt"
  ) |>
    file.exists() |>
    expect_true()

  unlink(
    outputDir,
    recursive = TRUE
  )
})
