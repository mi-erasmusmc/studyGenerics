test_that("insertStructure works", {
  skip_on_cran()
  requireInstall("desc")
  testProject <- withr::local_tempdir()
  usethis::create_package(
    testProject,
    open = FALSE
  )
  renv::init(project = testProject, load = FALSE) # load = FALSE prevents changing the wd
  renv::install(
    c("usethis", "lattice", "Matrix", "survival"),
    project = testProject
  )

  usethis::with_project(testProject, {
    insertStructure(
      path = testProject,
      # path = ".",
      n_obj = 3)
  })

  # Expect installed packages
  expect_true(dir.exists(file.path(testProject, "renv")))
  expect_true(file.exists(file.path(testProject, "renv.lock")))
  installed_pkgs <- c(
    "omopgenerics",
    "PhenotypeR",
    "DrugExposureDiagnostics",
    "CohortConstructor",
    "IncidencePrevalence",
    "DrugUtilisation",
    "CohortCharacteristics",
    "CohortSurvival",
    "visOmopResults",
    "DarwinShinyModules"
  )
  desc <- desc::desc(file.path(testProject, "DESCRIPTION"))
  imported_pkgs <- desc$get("Imports")
  for (pkg in installed_pkgs) {
    expect_true(grepl(pkg, imported_pkgs))
  }

  # Expect inserted docs
  expect_true(file.exists(file.path(testProject, "NEWS.md")))
  expect_true(file.exists(file.path(testProject, "README.Rmd")))
  expect_true(file.exists(file.path(testProject, "LICENSE.md")))

  # Expect inserted study files
  expect_true(dir.exists(file.path(testProject, "R")))
  r_files <- length(list.files(file.path(testProject, "R")))
  expect_equal(r_files, 9)
  readLines(file.path(testProject, "R", "createCohorts.R")) |>
    expect_equal(createCohortsFun())
  readLines(file.path(testProject, "R", "runStudy.R")) |>
    expect_equal(runStudyFun(n_obj = 3))
  readLines(file.path(testProject, "R", "runDiagnostics.R")) |>
    expect_equal(runDiagnosticsFun())
  expect_false(file.exists(file.path(testProject, "R", "hello.R")))
  expect_false(file.exists(file.path(testProject, "man", "hello.Rd")))
  expect_true(dir.exists(file.path(testProject, "inst")))
  expect_true(dir.exists(file.path(testProject, "inst", "cohorts")))
  expect_true(dir.exists(file.path(testProject, "inst", "concept_sets")))
  expect_true(dir.exists(file.path(testProject, "extras")))
  expect_true(file.exists(file.path(testProject, "extras", "CodeToRun.R")))
  expect_true(file.exists(file.path(testProject, "extras", "pullConceptSetsFromAtlas.R")))

  # Expect inserted tests
  for (script in list.files(file.path(testProject, "R"))) {
    if (script == "globals.R") {
      next
    } else{
      expect_true(file.exists(file.path(testProject, paste0("tests/testthat/test-", script))))
    }
  }
})

test_that("createCohortsFun inserted into createCohorts.R", {
  skip_on_cran()
  testProject <- withr::local_tempdir()
  usethis::create_package(
    testProject,
    open = FALSE
  )
  renv::init(project = testProject, load = FALSE)
  renv::install(
    "usethis",
    project = testProject
  )
  usethis::with_project(testProject, {
    usethis::use_r("createCohorts", open = FALSE)
  })
  path <- file.path(
      testProject,
      "R",
      "createCohorts.R"
    )
  writeLines(createCohortsFun(), path)
  readLines(path) |>
    expect_equal(createCohortsFun())
})

test_that("runDiagnosticsFun inserted into runDiagnostics.R", {
  skip_on_cran()
  testProject <- withr::local_tempdir()
  usethis::create_package(
    testProject,
    open = FALSE
  )
  renv::init(project = testProject, load = FALSE)
  renv::install(
    "usethis",
    project = testProject
  )
  usethis::with_project(testProject, {
    usethis::use_r("runDiagnostics", open = FALSE)
  })
  path <- file.path(
    testProject,
    "R",
    "runDiagnosticsFun.R"
  )
  writeLines(runDiagnosticsFun(), path)
  readLines(path) |>
    expect_equal(runDiagnosticsFun())
})

test_that("runStudyFun creates a workflow for each objective", {
  workflow <- runStudyFun(n_obj = 2)

  expect_true("  objective1_results <- objective1(" %in% workflow)
  expect_true("  objective2_results <- objective2(" %in% workflow)
  expect_false(any(grepl("objective3", workflow)))
})
