test_that("insertStructure works", {

  test_pkg_path <- testthat::test_path("testPackage") 
  dir.create(
    file.path(
      test_pkg_path,
      "renv"
    ),
     recursive = TRUE
  )

  insertStructure(path = test_pkg_path, n_obj = 3)

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
  expect_equal(r_files, 10)
  expect_false(file.exists(file.path(test_pkg_path, "R/hello.R")))
  expect_false(file.exists(file.path(test_pkg_path, "man/hello.Rd")))
  expect_true(dir.exists(file.path(test_pkg_path, "inst/cohorts")))
  expect_true(dir.exists(file.path(test_pkg_path, "inst")))
  expect_true(dir.exists(file.path(test_pkg_path, "inst/concept_sets")))
  expect_true(dir.exists(file.path(test_pkg_path, "extras")))
  expect_true(file.exists(file.path(test_pkg_path, "extras/CodeToRun.R")))
  expect_true(file.exists(file.path(test_pkg_path, "extras/pullCohortsFromAtlas.R")))

  # Expect inserted tests
  for (script in list.files(file.path(test_pkg_path, "R"))) {
    if (script == "globals.R") {
      next
    } else{
      expect_true(file.exists(file.path(test_pkg_path, paste0("tests/testthat/test-", script))))
    }
  }

  files <- list.files(
    test_pkg_path,
    full.names = TRUE,
    all.files = TRUE,
    no.. = TRUE
  )
  to_remove <- files[!basename(files) %in% c("renv.lock", "DESCRIPTION")]

  unlink(
    to_remove,
    recursive = TRUE
  )

})
