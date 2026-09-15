test_that("insertStructure works", {
  test_pkg_path <- withr::local_tempdir()
  usethis::create_package(
    test_pkg_path,
    open = FALSE
  )
  renv::init(project = test_pkg_path, load = FALSE) # load = FALSE prevents changing the wd
  renv::install(
    "usethis",
    project = test_pkg_path
  )
  usethis::with_project(test_pkg_path, {
    insertStructure(
      path = test_pkg_path,
      # path = ".",
      n_obj = 3)
  })
  # Expect installed packages
  expect_true(dir.exists(file.path(test_pkg_path, "renv")))
  expect_true(file.exists(file.path(test_pkg_path, "renv.lock")))
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
  desc <- desc::desc(file.path(test_pkg_path, "DESCRIPTION"))
  imported_pkgs <- desc$get("Imports")
  for (pkg in installed_pkgs) {
    expect_true(grepl(pkg, imported_pkgs))
  }
  # Expect inserted docs
  expect_true(file.exists(file.path(test_pkg_path, "NEWS.md")))
  expect_true(file.exists(file.path(test_pkg_path, "README.Rmd")))
  expect_true(file.exists(file.path(test_pkg_path, "LICENSE.md")))
  # Expect inserted study files
  expect_true(dir.exists(file.path(test_pkg_path, "R")))
  r_files <- length(list.files(file.path(test_pkg_path, "R")))
  expect_equal(r_files, 9)
  readLines(file.path(test_pkg_path, "R", "createCohorts.R")) |> 
    expect_equal(createCohortsFun())
  expect_false(file.exists(file.path(test_pkg_path, "R", "hello.R")))
  expect_false(file.exists(file.path(test_pkg_path, "man", "hello.Rd")))
  expect_true(dir.exists(file.path(test_pkg_path, "inst", "cohorts")))
  expect_true(dir.exists(file.path(test_pkg_path, "inst")))
  expect_true(dir.exists(file.path(test_pkg_path, "inst", "concept_sets")))
  expect_true(dir.exists(file.path(test_pkg_path, "extras")))
  expect_true(file.exists(file.path(test_pkg_path, "extras", "CodeToRun.R")))
  expect_true(file.exists(file.path(test_pkg_path, "extras", "pullConceptSetsFromAtlas.R")))
  # Expect inserted tests
  for (script in list.files(file.path(test_pkg_path, "R"))) {
    if (script == "globals.R") {
      next
    } else{
      expect_true(file.exists(file.path(test_pkg_path, paste0("tests/testthat/test-", script))))
    }
  }
})

test_that("createCohortsFun inserted into createCohorts.R", {
  test_pkg_path <- withr::local_tempdir()
  usethis::create_package(
    test_pkg_path,
    open = FALSE
  )
  renv::init(project = test_pkg_path, load = FALSE)
  renv::install(
    "usethis",
    project = test_pkg_path
  )
  usethis::with_project(test_pkg_path, {
    usethis::use_r("createCohorts", open = FALSE)
  })
  path <- file.path(
      test_pkg_path,
      "R",
      "createCohorts.R"
    )
  writeLines(createCohortsFun(), path)
  readLines(path) |> 
    expect_equal(createCohortsFun())
})
