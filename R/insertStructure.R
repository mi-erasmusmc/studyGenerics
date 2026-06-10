#' Install default package bundle
#'
#' Installs a predefined set of DARWIN EU®/OHDSI packages into the study project
#' and updates their dependencies. The standard package list includes the packages
#' omopgenerics, PhenotypeR, DrugExposureDiagnostics, CohortConstructor,
#' IncidencePrevalence, DrugUtilisation, CohortCharacteristics, CohortSurvival,
#' visOmopResults and DarwinShinyModules.
#'
#' @return
#' An invisible list of the installed packages.
installPackageBundle <- function(path) {

  # Install default package bundle
  complete_darwin <- list(
    cran = c(
      "omopgenerics",
      "PhenotypeR",
      "DrugExposureDiagnostics",
      "CohortConstructor",
      "IncidencePrevalence",
      "DrugUtilisation",
      "CohortCharacteristics",
      "CohortSurvival",
      "visOmopResults"
    ),
    github = c(
      "darwin-eu/DarwinShinyModules"
    )
  )

  if (!dir.exists(file.path(path, "renv"))) {
    cli::cli_abort(
      message = c(
        "x" = "No renv detected in {.path {path}}.",
        "i" = "Need to initialize the environment with {.fn renv::init} first."
      )
    )
  }

  withr::with_dir(path, {
    # Install packages with renv
    renv::install(complete_darwin$cran)
    renv::install(complete_darwin$github)

    # Add dependencies (default type = "Imports")
    pkg_names <- c(
      complete_darwin$cran,
      basename(complete_darwin$github)
    )

    if (!requireNamespace("usethis", quietly = TRUE)) {
      cli::cli_inform(
        "Installing required package: 'usethis'"
      )
      install.packages("usethis")
    }

    for (pkg in pkg_names) {
      usethis::use_package(pkg)
    }

    # Update lockfile
    renv::snapshot()
  })

  # Return invisible package list
  invisible(pkg_names)

}


#' Insert default documentation files
#'
#' Creates default `NEWS.md`, `README.Rmd` and `LICENSE.md` (Apache License 2.0) files.
#'
#' @return
#' No return value.
insertDocs <- function(path) {
  withr::with_dir(path, {
    usethis::use_news_md(open = FALSE)
    usethis::use_readme_rmd(open = FALSE)
    usethis::use_apl2_license()
  })
}


#' Insert default study files
#'
#' Creates the `inst` and `extras` folders and populates the `R` folder with
#' ready files for standard study functions.
#'
#' @param path Character string identifying the path to the study project,
#' default `"."`.
#' @param n_obj Number of study objectives, default `n_obj = 3`.
#'
#' @return
#' No return value.
insertStudyFiles <- function(
    path = ".",
    n_obj = 3
    ) {
  # R/
  if ("hello.R" %in% list.files(file.path(path, "R"))) {
    unlink(file.path(path, "R/hello.R"))
  }
  usethis::use_r("createCohorts", open = FALSE)
  usethis::use_r("runStudy", open = FALSE)
  usethis::use_r("runDiagnostics", open = FALSE)
  usethis::use_r("pullFromAtlas", open = FALSE)
  usethis::use_r("utils", open = FALSE)
  usethis::use_r("globals", open = FALSE)
  usethis::use_r("merge", open = FALSE)
  for (i in 1:n_obj) {
    usethis::use_r(paste0("objective", i), open = FALSE)
  }
  # man/
  if (!dir.exists(file.path(path, "man"))) {
    dir.create(file.path(path, "man"))
  }
  if ("hello.Rd" %in% list.files(file.path(path, "man"))) {
    unlink(file.path(path, "man/hello.Rd"))
  }
  # inst/
  dir.create(file.path(path, "inst"))
  dir.create(file.path(path, "inst/cohorts"))
  dir.create(file.path(path, "inst/concept_sets"))
  # extras/
  dir.create(file.path(path, "extras"))
  invisible(file.create(file.path(path, "extras/CodeToRun.R")))
  invisible(file.create(file.path(path, "extras/pullCohortsFromAtlas.R")))
}


#' Insert default test files
#'
#' Creates the `tests` folder and populates the `tests/testthat` folder with
#' a default test file for each script found in the `R` folder.
#'
#' @param path Character string identifying the path to the study project,
#' default `"."`.
#'
#' @return
#' No return value.
insertTests <- function(
    path = "."
    ) {

  usethis::use_testthat()

  if (!dir.exists(file.path(path, "R")) | length(list.files(file.path(path, "R"))) == 0) {
    cli::cli_abort(
      message = c(
        "!" = "No .R files are found to generate tests",
        "x" = "The R folder in current project doesn't exist or is empty."
      )
    )
  }

  # Create test files for each script in R/ except globals.R
  for (script in list.files(file.path(path, "R"))) {
    if (script == "globals.R") {
      next
    } else{                                 # remove ".R"
      usethis::use_test(substr(script, 1, nchar(script) -2), open = FALSE)
    }
  }
}


#' Set up study structure
#'
#' Creates the standard structure required for a new OMOP study package.
#' It includes standard folders, R scripts, test and documentation files and it
#' installs a default list of DARWIN EU®/OHDSI packages.
#'
#' It assumes an active R project has already been created and the `renv`
#' initialized.
#'
#' @param path Character string identifying the path to the study project,
#' default `"."`.
#' @param n_obj Number of study objectives, default `n_obj = 3`.
#'
#' @return
#' No return value.
#'
#' @export
insertStructure <- function(
    path = ".",
    n_obj = 3
  ) {

  # Need an existing package to run the function
  if (!file.exists(file.path(path, "DESCRIPTION"))) {
    cli::cli_abort(
      message = c(
        "!" = "The path doesn't correspond to a package folder.",
        "x" = "A package must contain a DESCRIPTION file. No DESCRIPTION detected at {.path {path}}.",
        "i" = "Create a package first with {.fn usethis::create_package} or through the RStudio interface."
      )
    )
  }

  # Set up structure at specified project path
  cli::cli_h1("Setting up study package structure")

  cli::cli_alert_info("Installing package bundle...")
  installPackageBundle(path)

  cli::cli_alert_info("Inserting documentation files...")
  insertDocs(path)

  cli::cli_alert_info("Inserting study files...")
  insertStudyFiles(path, n_obj)

  cli::cli_alert_info("Inserting test files...")
  insertTests(path)

  cli::cli_alert_success("Package structure created successfully.")
}
