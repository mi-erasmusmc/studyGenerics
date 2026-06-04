test_that("Create logger files correctly", {
  outputDir <- file.path(
    tempdir()
  )

  # runLoggerTest <- function(outputDir) {
    directories <- createResultsDir(
      outputDir = outputDir,
      dbname = "LOGGER"
    )
    createLoggers(
      resultsDir = directories$resultsDir,
      loggerName = "OMOP STUDY",
      logFileName = "log.txt",
      errorFileName = "error.txt",
      eventLevel = "TRACE"
    )
    stop("Error test")
  # }

  runLoggerTest(outputDir)

  file.path(
    outputDir,
    "results_LOGGER",
    "log.txt"
  ) |>
    checkmate::checkFileExists() |>
    expect_true()

  file.path(
    outputDir,
    "results_LOGGER",
    "error.txt"
  ) |>
    checkmate::checkFileExists() |>
    expect_true()

  unlink(
    outputDir,
    recursive = TRUE
  )
})
