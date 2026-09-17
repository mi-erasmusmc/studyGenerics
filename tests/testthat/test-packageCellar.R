test_that("packageCellar saves single cran and github package to cellar", {
  skip_on_cran()
  # PREP ----------
  # renv::lockfile_create(
  #   libpaths = .libPaths(),
  #   packages = c("DarwinShinyModules", "dplyr")
  # ) |> 
  #   renv::lockfile_write(
  #     file = testthat::test_path(
  #       "data",
  #       "renv.lock"
  #     )
  #   )
  testLockfile <- testthat::test_path(
    "data",
    "renv.lock"
  )
  checkmate::assertFileExists(testLockfile)
  testProject <- withr::local_tempdir()
  renv::init(
    project = testProject,
    load = FALSE
  ) 
  file.copy(
    from = testLockfile,
    to = testProject,
    overwrite = TRUE
  )
  # EXECUTION -------
  usethis::with_project(testProject, {
    cellar_path <- file.path(
      testProject,
      "renv",
      "cellar"
    )
    expect_no_error(
      packageCellar(
        path = cellar_path
      )
    )
    # TEST ------------
    list.files(
      cellar_path
    ) |> 
      stringr::str_detect("DarwinShinyModules_260ebe58bc7d5e13fcdc8bc4254749abc85f0320.tar.gz") |> 
      any() |> 
      expect_true()
    # EXIT ------------
  })
  unlink(
    testProject,
    recursive = TRUE
  )
  })

test_that("packageCellar saves single github package to cellar", {
  skip_on_cran()
  testLockfile <- testthat::test_path(
    "data",
    "renv.lock"
  )
  checkmate::assertFileExists(testLockfile)
  testProject <- withr::local_tempdir()
  renv::init(
    project = testProject,
    load = FALSE
  ) 
  file.copy(
    from = testLockfile,
    to = testProject,
    overwrite = TRUE
  )
  # EXECUTION -------
  usethis::with_project(testProject, {
    cellar_path <- file.path(
      testProject,
      "renv",
      "cellar"
    )
    packageCellar(
      path = cellar_path,
      type = "github"
    )
    # TEST ------------
    list.files(
      cellar_path
    ) |> 
      stringr::str_detect(
        "DarwinShinyModules"
      ) |> 
      any() |> 
      expect_true()
  })
  # EXIT ------------
  unlink(
    testProject,
    recursive = TRUE
  )
  })

test_that("retrieveGithub packages to cellar", {
  skip_on_cran()
  testLockfile <- testthat::test_path(
     "data",
     "renv.lock"
    )
  testCellarDir <- file.path(
    tempdir(),
    "test_cellar"
  )
  dir.create(testCellarDir)
  retrieveGithub(
    lockfile = testLockfile,
    path = testCellarDir
  )
  list.files(
    testCellarDir
  ) |> 
    stringr::str_detect(
      "DarwinShinyModules"
    ) |> 
    any() |> 
    expect_true()
  unlink(
    testCellarDir,
    recursive = TRUE
  )
})

test_that("packageList git repostitories", {
  testLockfile <- testthat::test_path(
     "data",
     "renv.lock"
    )
  packageList(
    lockfile = testLockfile,
    type = "github"
  ) |> 
    expect_equal(
      list(
        DarwinShinyModules = list(
          Version = "0.7.1",
          RemoteRepo = "DarwinShinyModules", 
          RemoteUsername = "darwin-eu", RemoteHost = "api.github.com", 
          Hash = "89f480bbf075d972b4d92a5db35265f0", Requirements = c("DT", 
          "R", "R6", "checkmate", "dplyr", "flextable", "ggplot2", 
          "gt", "mirai", "plotly", "promises", "purrr", "qs2", "reactable", 
          "rlang", "shiny", "shinyWidgets", "stringr", "visOmopResults"
        )
      )
    )
  )
})

test_that("extractGithubList", {
  testLockfile <- testthat::test_path(
    "data",
    "renv.lock"
  )
  lockfile_data <- renv::lockfile_read(
    file = testLockfile
  )
  extractGithubList(lockfile_data$Packages) |> 
    expect_equal(
      list(
        DarwinShinyModules = list(
          Version = "0.7.1",
          RemoteRepo = "DarwinShinyModules", 
          RemoteUsername = "darwin-eu", RemoteHost = "api.github.com", 
          Hash = "89f480bbf075d972b4d92a5db35265f0", Requirements = c("DT", 
          "R", "R6", "checkmate", "dplyr", "flextable", "ggplot2", 
          "gt", "mirai", "plotly", "promises", "purrr", "qs2", "reactable", 
          "rlang", "shiny", "shinyWidgets", "stringr", "visOmopResults"
        )
      )
    )
  )
})

test_that("downloadGithub package to cellar", {
  skip_on_cran()
  testLockfile <- testthat::test_path(
    "data",
    "renv.lock"
  )
  checkmate::assertFileExists(testLockfile)
  testCellarDir <- file.path(
    tempdir(),
    "test_cellar"
  )
  dir.create(testCellarDir)
  packageList(
    lockfile = testLockfile,
    type = "github"
  ) |> 
    downloadGithub(
    path = testCellarDir
  )
  list.files(
    testCellarDir
  ) |> 
    stringr::str_detect(
      "DarwinShinyModules"
    ) |> 
    any() |> 
    expect_true()

  unlink(
    testCellarDir,
    recursive = TRUE
  )
})

test_that("installCellar", {
  skip_on_cran()
  # PREP ----------
  testLockfile <- testthat::test_path(
    "data",
    "renv.lock"
  )
  unlink(
    renv::paths$root("cellar"),
    recursive = TRUE
  )
  testProject <- withr::local_tempdir()
  renv::init(
    project = testProject,
    load = FALSE
  ) 
  file.copy(
    from = testLockfile,
    to = testProject,
    overwrite = TRUE
  )
  # EXECUTION -------
  usethis::with_project(testProject, {
    packageCellar()
     # TEST ------------
    expect_no_error({
      installCellar()
    })
    testProject <- usethis::proj_path()
    testLibrary <- file.path(
      testProject,
      "renv",
      "library"
    )
    lockfileData <- renv::lockfile_read(
      file.path(testProject, "renv.lock")
    )
    expectedPackages <- names(lockfileData$Packages)
    installedPackages <- rownames(
      utils::installed.packages(
        lib.loc = testLibrary
      )
    )
    expect_true(
      all(expectedPackages %in% installedPackages)
    )
  })
  # EXIT ------------
  unlink(
    testProject,
    recursive = TRUE
  )
})
