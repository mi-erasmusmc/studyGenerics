test_that("zipStudyFiles works", {
  # -- params
  path <- testthat::test_path(
    "data",
    "results_execution"
  )
  outputDir <- file.path(
    tempdir(),
    "results"
  )
  dbname <- "IPCI"

  directories <- createResultsDir(
    outputDir,
    dbname = dbname
  )

  # -- Mock results CSV
  for (i in seq(3)) {
    filename <- paste(
      "objective",
      i,
      sep = "_"
    )
    file_path <- glue::glue(
      "{directories$resultsDir}/{filename}.csv"
      )
    file.create(file_path)
    checkmate::assertFileExists(file_path)
  }

  # -- Zip
  zipStudyFiles(
    resultsDirName = directories$resultsDir,
    outputDir = directories$outputDir,
    dbname = dbname
  )

  # -- Result filename
  zipFileName <- glue::glue(
    "{directories$resultsDir}/results_{dbname}_{format(Sys.Date(), format='%Y%m%d')}.zip"
  )

  # -- Test zip was created
  expect_true(
    file.exists(
      zipFileName
    )
  )

  # -- Test zip's contents
  outputDirUnzip <- file.path(
    tempdir(),
    "zip_contents"
  )

  unZipStudyFiles(
    path = directories$resultsDir,
    negate = TRUE,
    recursive = FALSE,
    outputDir = outputDirUnzip
  )

  list.files(
    path = outputDirUnzip,
    recursive = TRUE
  ) |>
    expect_in(
      c("results_IPCI/objective_1.csv",
        "results_IPCI/objective_2.csv",
        "results_IPCI/objective_3.csv")
    )

  # -- Clean up
  unlink(
    outputDir,
    recursive = TRUE
  )
  unlink(
    outputDirUnzip,
    recursive = TRUE
  )


})
