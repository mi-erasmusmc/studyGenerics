test_that("packageCellar saves single cran and github package to cellar", {
  # PREP ----------
  testLockfile <- testthat::test_path(
    "data",
    "renv.lock"
  )
  renv::lockfile_create(
    libpaths = .libPaths(),
    packages = c("DarwinShinyModules", "dplyr")
  ) |> 
    renv::lockfile_write(
      file = testthat::test_path(
        "data",
        "renv.lock"
      )
    )
  checkmate::assertFileExists(testLockfile)
  testCellarDir <- file.path(
    tempdir(),
    "test_cellar"
  )
  dir.create(testCellarDir)
  # EXECUTION -------
  packageCellar(
    lockfile = testLockfile,
    cellarDir = testCellarDir,
    type = "complete"
  )
  # TEST ------------
  list.files(
    testCellarDir
  ) |> 
    stringr::str_detect("DarwinShinyModules_260ebe58bc7d5e13fcdc8bc4254749abc85f0320.tar.gz") |> 
    any() |> 
    expect_true()
  # EXIT ------------
  unlink(
    testCellarDir,
    recursive = TRUE
  )
})

test_that("packageCellar saves multiple github packages to cellar", {
  # PREP ----------
  testLockfile <- testthat::test_path(
    "data",
    "renv.lock"
  )
  renv::lockfile_create(
    libpaths = .libPaths(),
    packages = c("DarwinShinyModules", "CohortDiagnostics", "dplyr")
  ) |> 
    renv::lockfile_write(
      file = testthat::test_path(
        "data",
        "renv.lock"
      )
    )
  checkmate::assertFileExists(testLockfile)
  testCellarDir <- file.path(
    tempdir(),
    "test_cellar"
  )
  dir.create(testCellarDir)
  # EXECUTION -------
  packageCellar(
    lockfile = testLockfile,
    cellarDir = testCellarDir,
    type = "github"
  )
  # TEST ------------
  list.files(
    testCellarDir
  ) |> 
    stringr::str_detect(
      "DarwinShinyModules"
    ) |> 
    any() |> 
    expect_true()
  # EXIT ------------
  unlink(
    testCellarDir,
    recursive = TRUE
  )
})

test_that("packageCellar saves single github package to cellar", {
  # PREP ----------
  testLockfile <- testthat::test_path(
    "data",
    "renv.lock"
  )
  renv::lockfile_create(
    libpaths = .libPaths(),
    packages = c("DarwinShinyModules", "dplyr")
  ) |> 
    renv::lockfile_write(
      file = testthat::test_path(
        "data",
        "renv.lock"
      )
    )
  checkmate::assertFileExists(testLockfile)
  testCellarDir <- file.path(
    tempdir(),
    "test_cellar"
  )
  dir.create(testCellarDir)
  # EXECUTION -------
  packageCellar(
    lockfile = testLockfile,
    cellarDir = testCellarDir,
    type = "github"
  )
  # TEST ------------
  list.files(
    testCellarDir
  ) |> 
    stringr::str_detect(
      "DarwinShinyModules"
    ) |> 
    any() |> 
    expect_true()
  # EXIT ------------
  unlink(
    testCellarDir,
    recursive = TRUE
  )
})

test_that("retrieveGithub packages to cellar", {
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
    cellarDir = testCellarDir
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
  renv::lockfile_create(
    libpaths = .libPaths(),
    packages = c("DarwinShinyModules", "dplyr")
  ) |> 
    renv::lockfile_write(
      file = testthat::test_path(
        "data",
        "renv.lock"
      )
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
    cellarDir = testCellarDir
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

test_that("installCellar try loop", {
  # PREP ----------
  unlink(
    renv::paths$root("cellar"),
    recursive = TRUE
  )
  testLockfile <- testthat::test_path(
    "data",
    "renv.lock"
  )
  renv::lockfile_create(
    libpaths = .libPaths(),
    packages = c("DarwinShinyModules", "dplyr")
  ) |> 
    renv::lockfile_write(
      file = testthat::test_path(
        "data",
        "renv.lock"
      )
    )
  checkmate::assertFileExists(testLockfile)
  testCellarDir <- file.path(
    tempdir(),
    "test_cellar"
  )
  dir.create(testCellarDir)
  # EXECUTION -------
  packageCellar(
    lockfile = testLockfile,
    cellarDir = testCellarDir,
    type = "complete"
  )
  # TEST ------------
  expect_no_error({
    installCellar(
      path = testCellarDir
    )
  })
  # EXIT ------------
  unlink(
    testCellarDir,
    recursive = TRUE
  )
})
