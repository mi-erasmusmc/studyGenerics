test_that(
  "results to correct output folder with default settings;
  simulate set of results from 3 data partners", {

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
    unZipStudyFiles(
      path = path,
      negate = TRUE,
      recursive = FALSE,
      outputDir = outputDir
      )

    # -- test
    list.files(
      path = outputDir
    ) |>
      expect_in(
        c("results_DP-A",
          "results_DP-B",
          "results_DP-C")
      )

    unlink(
      outputDir,
      recursive = TRUE
    )

  })

test_that(
  "Error if folder does't contain .zip files", {

    # -- params
    path <- testthat::test_path(
      "data",
      "results_all_data_partners"
    )
    outputDir <- file.path(
      tempdir(),
      "results"
    )

    # -- FUN
    # -- test
    expect_error({
      unZipStudyFiles(
        path = path,
        negate = FALSE,
        recursive = FALSE,
        outputDir = outputDir
      )
    })

    unlink(
      outputDir,
      recursive = TRUE
    )

    })

test_that(
  "Filtering only files that contain pattern 'DED'", {

    # -- params
    path <- testthat::test_path(
      "data",
      "results_all_data_partners"
    )
    outputDir <- file.path(
      tempdir(),
      "results"
    )

    # -- FUN
    # -- test
    expect_no_error({
      unZipStudyFiles(
        path = path,
        pattern = "DED",
        negate = FALSE,
        recursive = TRUE,
        outputDir = outputDir
      )
    })

    # -- test
    list.files(
      path = outputDir
    ) |>
      expect_in(
        c("DED_DP-A",
          "DED_DP-B",
          "DED_DP-C")
      )

    unlink(
      outputDir,
      recursive = TRUE
    )

  })

test_that(
  "Filtering DED result set with pattern", {

    # -- params
    path <- testthat::test_path(
      "data",
      "results_all_data_partners"
    )
    outputDir <- file.path(
      tempdir(),
      "results"
    )

    # -- FUN
    expect_no_error({
      unZipStudyFiles(
        path = path,
        pattern = "DED",
        negate = TRUE,
        recursive = TRUE,
        outputDir = outputDir
      )
    })

    # -- test
    list.files(
      path = outputDir
    ) |>
      expect_in(
        c("results_DP-A",
          "results_DP-B",
          "results_DP-C")
      )

    unlink(
      outputDir,
      recursive = TRUE
    )

  })
