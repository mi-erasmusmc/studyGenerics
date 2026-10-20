#' Set up study structure
#'
#' Creates the standard structure required for a new OMOP study package.
#' It includes standard folders, R scripts, test and documentation files and it
#' installs a default list of DARWIN EU®/OHDSI packages.
#'
#' @param studyName Character string identifying the study, for example
#' `"P1-C1-001"`. Hyphens and spaces are removed to create the package name.
#' @param path Character string identifying an existing study folder in which
#' the package will be created.
#' @param n_obj Number of study objectives, default `n_obj = 3`.
#'
#' @return
#' No return value.
#'
#' @examples
#' \dontrun{
#'
#' # Create the package in an existing study folder
#' study_path <- file.path(tempdir(), "P1-C1-001")
#' dir.create(study_path)
#' studyGenerics::insertStructure(
#'   studyName = "P1-C1-001",
#'   path = study_path
#' )
#'
#' # - Initialize NAMESPACE
#' devtools::document()
#'
#' # - Check package is valid
#' devtools::check()
#' }
#'
#' @export
insertStructure <- function(
    studyName,
    path,
    n_obj = 3
  ) {
  checkmate::assertCharacter(studyName, len = 1, any.missing = FALSE)
  checkmate::assertDirectoryExists(path)
  package_name <- gsub("[-[:space:]/]", "", studyName)
  if (!grepl("^[A-Za-z][A-Za-z0-9.]*$", package_name)) {
    cli::cli_abort(
      message = c(
        "x" = "{.arg studyName} must produce a valid R package name.",
        "i" = "Use a study name beginning with a letter and containing only letters, numbers, periods, and hyphens."
      )
    )
  }
  if (!grepl("P[0-9]{1}C[0-9]{1}[0-9]{3}(C[0-9]{1}[0-9]{3})?", package_name)) {
    cli::cli_abort(
      message = c(
        "x" = "{.arg studyName} doesn't contain a valid study number.",
        "i" = "Please include in the name the study number in the format \"PX-CY-ZZZ.\""
      )
    )
  }
  if (file.exists(file.path(path, "DESCRIPTION"))) {
    cli::cli_abort("{.path {path}} already contains a package DESCRIPTION file.")
  }

  usethis::create_package(
    path = path,
    fields = list(Package = package_name),
    check_name = FALSE,
    open = FALSE
  )
  renv::init(project = path, bare = TRUE, load = FALSE, restart = FALSE)

  # Set up structure at specified project path
  studyNumber <- stringr::str_extract(
    studyName,
    "P[0-9]{1}-C[0-9]{1}-[0-9]{3}([/|-]C[0-9]{1}-[0-9]{3})?"
    )

  cli::cli_h1("Setting up study package structure")

  cli::cli_alert_info("Installing package bundle...")
  installPackageBundle(path)

  cli::cli_alert_info("Inserting documentation files...")
  insertDocs(package_name, path)

  cli::cli_alert_info("Inserting study files...")
  insertStudyFiles(package_name, path, n_obj)

  cli::cli_alert_info("Inserting test files...")
  insertTests(path)

  cli::cli_alert_success("Package structure created successfully.")
}

#' Install default package bundle
#'
#' Installs a predefined set of DARWIN EU®/OHDSI packages into the study project
#' and updates their dependencies. The standard package list includes the packages
#' omopgenerics, PhenotypeR, DrugExposureDiagnostics, CohortConstructor,
#' IncidencePrevalence, DrugUtilisation, CohortCharacteristics, CohortSurvival,
#' visOmopResults and DarwinShinyModules.
#'
#' @param path A valid path to the study project in character.
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

  # withr::with_dir(path, {
    # Install packages with renv
    renv::install(
      packages = complete_darwin$cran,
      project = path
    )
    renv::install(
      packages = complete_darwin$github,
      project = path
    )

    # Add dependencies (default type = "Imports")
    pkg_names <- c(
      complete_darwin$cran,
      basename(complete_darwin$github)
    )

    if (!requireNamespace("usethis", quietly = TRUE)) {
      cli::cli_inform(
        "Installing required package: 'usethis'"
      )
      renv::install(
        packages = "usethis",
        project = path
      )
    }

    withr::with_dir(path, {
      for (pkg in pkg_names) {
        usethis::use_package(pkg)
      }
    })

    # Update lockfile
    renv::snapshot(
      project = path
    )
  # })

  # Return invisible package list
  invisible(pkg_names)

}

#' Insert default documentation files
#'
#' Creates default `NEWS.md`, `README.Rmd` and `LICENSE.md` (Apache License 2.0) files.
#'
#' @param  studyNumber Character string identifying the study number, e.g. `"P1-C1-001"`.
#' @param path A valid path to the study project in character.
#'
#' @return
#' No return value.
insertDocs <- function(
    studyNumber,
    path
    ) {
  withr::with_dir(path, {
    existing_files <- list.files(path)
    # NEWS.md
    usethis::use_news_md(open = FALSE)
    # README.Rms
    usethis::use_readme_rmd(open = FALSE)
    writeLines(defaultContentREADME(studyNumber), file.path(path, "README.Rmd"))
    # instructions.md
    if (!"instructions.md" %in% existing_files) {
      cli::cli_alert_info("There is no\"instructions.md\" file.")
    } else {
      writeLines(defaultContentInstructions(studyNumber), file.path(path, "instructions.md"))
    }
    # LICENSE.md
    if ("LICENSE" %in% existing_files) {
      unlink(file.path(path, "LICENSE"))
    }
    usethis::use_apl2_license()
  })
}

#' Insert default study files
#'
#' Creates the `inst` and `extras` folders and populates the `R` folder with
#' ready files for standard study functions.
#'
#' @param studyNumber Character string identifying the study number, e.g. `"P1-C1-001"`.
#' @param path Character string identifying the path to the study project.
#' @param n_obj Number of study objectives, default `n_obj = 3`.
#'
#' @return
#' No return value.
insertStudyFiles <- function(
    studyNumber,
    path,
    n_obj = 3
    ) {
  withr::with_dir(path, {
    # R/
    if ("hello.R" %in% list.files(file.path(path, "R"))) {
      unlink(file.path(path, "R", "hello.R"))
    }
    usethis::use_r("createCohorts", open = FALSE)
    writeLines(createCohortsFun(), file.path(path, "R", "createCohorts.R"))
    usethis::use_r("runStudy", open = FALSE)
    writeLines(runStudyFun(n_obj), file.path(path, "R", "runStudy.R"))
    usethis::use_r("runDiagnostics", open = FALSE)
    writeLines(runDiagnosticsFun(), file.path(path, "R", "runDiagnostics.R"))
    usethis::use_r("utils", open = FALSE)
    usethis::use_r("globals", open = FALSE)
    usethis::use_r("merge", open = FALSE)
    for (i in 1:n_obj) {
      usethis::use_r(paste0("objective", i), open = FALSE)
    }
  })
  # man/
  if (!dir.exists(file.path(path, "man"))) {
    dir.create(file.path(path, "man"))
  }
  if ("hello.Rd" %in% list.files(file.path(path, "man"))) {
    unlink(file.path(path, "man", "hello.Rd"))
  }
  # inst/
  dir.create(file.path(path, "inst"))
  dir.create(file.path(path, "inst", "cohorts"))
  dir.create(file.path(path, "inst", "concept_sets"))
  # extras/
  dir.create(file.path(path, "extras"))
  invisible(file.create(file.path(path, "extras", "CodeToRun.R")))
  writeLines(defaultContentCodeToRun(studyNumber), file.path(path, "extras", "CodeToRun.R"))
  invisible(file.create(file.path(path, "extras", "pullConceptSetsFromAtlas.R")))
  # project file
  current_files <- list.files(path)
  if (length(current_files[stringr::str_detect(current_files, ".Rproj")]) > 1 && "StudyRepoTemplate.Rproj" %in% current_files) {
    unlink(file.path(path, "StudyRepoTemplate.Rproj"))
  }
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
    path
    ) {
  withr::with_dir(path, usethis::use_testthat())

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
      withr::with_dir(path, usethis::use_test(substr(script, 1, nchar(script) -2), open = FALSE))
    }
  }
}

#' Load default content for `createCohorts.R`
#'
#' @param path Character string identifying the path to the study project,
#' default `"."`.
#'
#' @return
#' A character vector containing the default contents of `createCohorts.R`.
createCohortsFun <- function(path = ".") {
    c("#' Creates a cohort set based on phenotype specifications",
      "#' @param cdm A cdm reference.",
      "#' @param path Folder where the concept sets to build the cohort are saved, in character.",
      "#' Default 'concept_sets'",
      "#' @param name Name of the new cohort set, in character.",
      "#' @param dbname Data source name in character. ",
      "#'",
      "#' @importFrom cli cli_alert_info",
      "#' @importFrom glue glue",
      "#' @importFrom checkmate assertDirectoryExists",
      "#' @importFrom desc desc_get",
      "#' @importFrom CohortConstructor conceptCohort",
      "#' @importFrom CodelistGenerator asCodelist",
      "#' @importFrom omopgenerics importConceptSetExpression settings",
      "#'",
      "#' @returns A cdm reference with the new created cohort ",
      "#' @export",
      "createCohorts <- function(",
      "   cdm,",
      "   path = 'concept_sets',",
      "   name,",
      "   dbname = 'TEST_DATA'",
      "  ) {",
      "  valid_dbnames <- studyGenerics::assertCdmNames(",
      "    labels = dbname,",
      "    expected = c(",
      "      \"BCR\", \"IQVIA LPD Belgium\", \"UZA\", \"NAJS\", \"DK-DHR\",",
      "      \"EBB\", \"HARMONY Platform\", \"HARMONY-ALL\", \"HARMONY-AML\",",
      "      \"HARMONY-CML\", \"HARMONY-MM\", \"FinOMOP-ACI Varha\", \"FinOMOP-HUS\",",
      "      \"FinOMOP-TaUH Pirha\", \"FinOMOP-THL\", \"APHM\", \"CDW Bordeaux\",",
      "      \"SNDS\", \"InGef RDB\", \"IQVIA DA Germany\", \"UMD\", \"PGH\", \"SUCD\",",
      "      \"Pedianet\", \"POLIMI\", \"LDH\", \"CRN\", \"NLHR\", \"NLHR@UiO:PERINATAL\",",
      "      \"EMDB-ULSEDV\", \"EMDB-ULSGE\", \"EMDB-ULSRA\", \"ULSM-RT\", \"BIFAP\",",
      "      \"H12O\", \"HUVM\", \"IMASIS\", \"PRISIB\", \"SIDIAP\", \"VID\", \"HI-SPEED\",",
      "      \"IPCI\", \"NCR\", \"CPRD AURUM\", \"CPRD Aurum Linked\", \"CPRD GOLD\",",
      "      \"UKBB\", \"IQVIA US - AmbEMR\", \"IQVIA US - PMTX+\"",
      "    )",
      "  )",
      "  pathToCohortJsonFiles <- system.file(",
      "    path,",
      "    package = desc::desc_get(\"Package\")",
      "    )",
      "  checkmate::assertDirectoryExists(pathToCohortJsonFiles)",
      "  cli::cli_alert_info(",
      "    glue::glue(",
      "      \"Creating codelist from {pathToCohortJsonFiles}\"",
      "      )",
      "    )",
      "  codelist <- omopgenerics::importConceptSetExpression(",
      "    path = pathToCohortJsonFiles,",
      "    type = \"json\"",
      "  )",
      " ",
      "  cdm[[name]] <- CohortConstructor::conceptCohort(",
      "    cdm,",
      "    conceptSet = codelist,",
      "    name = name,",
      "    exit = \"event_end_date\",",
      "    overlap = \"merge\",",
      "    table = NULL,",
      "    useRecordsBeforeObservation = FALSE,",
      "    useSourceFields = FALSE,",
      "    subsetCohort = NULL,",
      "    subsetCohortId = NULL",
      "    ) ",
      " ",
      "  return(cdm)",
      "}"
    )
}

#' Load default content for `runStudy.R`
#'
#' @param n_obj Number of study objectives to include in the workflow,
#' default `3`.
#'
#' @return
#' A character vector containing the default contents of `runStudy.R`.
runStudyFun <- function(n_obj = 3) {
  objective_calls <- unlist(lapply(seq_len(n_obj), function(i) {
    objective <- paste0("objective", i)
    c(
      "",
      paste0("  # --- Run ", objective, " ---"),
      paste0("  ", objective, "_results <- ", objective, "("),
      "    cdm = cdm,",
      "    resultsDir = resultsDir,",
      "    minCell = minCell",
      "  )"
    )
  }))

  c(
    "#' Runs the study workflow.",
    "#'",
    "#' Validates the database identifier, creates the result folders and log files,",
    "#' runs each study objective, and creates a zip archive with the results.",
    "#'",
    "#' @param cdm A cdm reference.",
    "#' @param dbname Character string giving the data source name.",
      "#' @param outputDir Character string giving the base output directory.",
    "#' @param test Logical indicating whether to run in test mode with a minimum",
    "#' cell count of `0` instead of `5`.",
    "#'",
    "#' @returns Invisibly returns `NULL`. The main side effects are writing study",
    "#' results to `outputDir` and creating a zip archive of the results.",
    "#'",
    "#' @importFrom ParallelLogger logInfo",
    "#' @importFrom studyGenerics assertCdmNames createResultsDir setLoggers zipStudyFiles",
    "#'",
    "#' @export",
    "",
    "runStudy <- function(",
    "  cdm,",
    "  dbname = 'TEST_DATA',",
      "  outputDir,",
    "  test = FALSE",
    ") {",
    "",
    "  # --- Validate database name ---",
    "  assertCdmNames(dbname)",
    "",
    "  # --- Create results folders ---",
    "  logInfo(\"Defining output directories\")",
    "  directories <- createResultsDir(outputDir, dbname)",
    "  outputDir <- directories$outputDir",
    "  resultsDir <- directories$resultsDir",
    "  resultsDirName <- directories$resultsDirName",
    "",
    "  # --- Create log files ---",
    "  setLoggers(resultsDir)",
    "",
    "  if (test) {",
    "    minCell <- 0",
    "  } else {",
    "    minCell <- 5",
    "  }",
    "",
    "  # Define each objective function in its corresponding objective<n>.R file.",
    objective_calls,
    "",
    "  # --- Export results ---",
    "  zipStudyFiles(outputDir, resultsDirName, dbname)",
    "  logInfo(\"-- Thank you for running the study!\")",
    "  invisible()",
    "}"
  )
}

#' Load default content for `runDiagnostics.R`
#'
#' @param path Character string identifying the path to the study project,
#' default `"."`.
#'
#' @return
#' A character vector containing the default contents of `runDiagnostics.R`.
runDiagnosticsFun <- function(path = ".") {
  c(
    "#' Runs the diagnostics workflow.",
    "#'",
    "#' Creates the study result folders, validates the database identifier, builds",
    "#' the cohorts, runs PhenotypeR diagnostics for the generated cohorts,",
    "#' and writes a zip archive with the results to `outputDir`.",
    "#'",
    "#' @param cdm A cdm reference.",
    "#' @param dbname Data source name in character.",
    "#' @param outputDir Character string with the base output directory where study",
    "#' results, logs, and the final zip archive will be written.",
    "#' @param test Logical indicating whether to run in test mode with a minimum",
    "#' cell count of `0` instead of `5`.",
    "#'",
    "#' @returns Invisibly returns `NULL`. The main side effects are writing",
    "#' diagnostics output to `outputDir` and creating a zip archive of the results.",
    "#'",
    "#' @importFrom checkmate assertDirectoryExists assertFileExists",
    "#' @importFrom glue glue",
    "#' @importFrom omopgenerics bind exportSummarisedResult",
    "#' @importFrom ParallelLogger addDefaultFileLogger logInfo",
    "#' @importFrom CohortCharacteristics summariseLargeScaleCharacteristics",
    "#' @importFrom PatientProfiles addSex addAge",
    "#' @importFrom zip zip",
    "#'",
    "#' @export",
    "",
    "runDiagnostics <- function(",
    "  cdm,",
    "  dbname = 'TEST_DATA',",
    "  outputDir,",
    "  test = FALSE",
    ") {",
    "",
    "  # --- Validate database name ---",
    "  valid_dbnames <- studyGenerics::assertCdmNames(",
    "    labels = dbname,",
    "    expected = c(",
    "      \"BCR\", \"IQVIA LPD Belgium\", \"UZA\", \"NAJS\", \"DK-DHR\",",
    "      \"EBB\", \"HARMONY Platform\", \"HARMONY-ALL\", \"HARMONY-AML\",",
    "      \"HARMONY-CML\", \"HARMONY-MM\", \"FinOMOP-ACI Varha\", \"FinOMOP-HUS\",",
    "      \"FinOMOP-TaUH Pirha\", \"FinOMOP-THL\", \"APHM\", \"CDW Bordeaux\",",
    "      \"SNDS\", \"InGef RDB\", \"IQVIA DA Germany\", \"UMD\", \"PGH\", \"SUCD\",",
    "      \"Pedianet\", \"POLIMI\", \"LDH\", \"CRN\", \"NLHR\", \"NLHR@UiO:PERINATAL\",",
    "      \"EMDB-ULSEDV\", \"EMDB-ULSGE\", \"EMDB-ULSRA\", \"ULSM-RT\", \"BIFAP\",",
    "      \"H12O\", \"HUVM\", \"IMASIS\", \"PRISIB\", \"SIDIAP\", \"VID\", \"HI-SPEED\",",
    "      \"IPCI\", \"NCR\", \"CPRD AURUM\", \"CPRD Aurum Linked\", \"CPRD GOLD\",",
    "      \"UKBB\", \"IQVIA US - AmbEMR\", \"IQVIA US - PMTX+\"",
    "    )",
    "  )",
    "",
    "  # --- Create results folders ---",
    "  ParallelLogger::logInfo(\"Defining output directories\")",
    "  directories <- studyGenerics::createResultsDir(",
    "    outputDir,",
    "    dbname",
    "  )",
    "  outputDir <- directories$outputDir",
    "  resultsDir <- directories$resultsDir",
    "  resultsDirName <- directories$resultsDirName",
    "  checkmate::assertDirectoryExists(resultsDir)",
    "  execution_date <- format(",
    "    Sys.Date(),",
    "    format='%Y%m%d'",
    "  )",
    "  if (test) {",
    "    minCell <- 0",
    "  } else {",
    "    minCell <- 5",
    "  }",
    "",
    "  # --- Create log file ---",
    "  ParallelLogger::logInfo(\"Creating log file\")",
    "  logFileName <- file.path(resultsDir, \"log.txt\")",
    "  ParallelLogger::addDefaultFileLogger(logFileName)",
    "",
    "  # --- Create cohorts ---",
    "  ParallelLogger::logInfo(\"Generating cohorts\")",
    "  cdm <- createCancerCohorts(",
    "    cdm,",
    "    path = \"cancer_cohorts\",",
    "    name = \"cancer_cohorts\"",
    "  )",
    "",
    "  # --- Run PhenotypeR diagnostics ---",
    "  if (!requireNamespace(\"PhenotypeR\", quietly = TRUE)) {",
    "    stop(",
    "      \"Package 'PhenotypeR' is required when 'diagnostics = TRUE'.\",",
    "      call. = FALSE",
    "    )",
    "  }",
    "  ",
    "  ParallelLogger::logInfo(\"Running Diagnostics\")",
    "  ",
    "  result_diagnostics <- cdm$cancer_cohorts |>",
    "    PhenotypeR::phenotypeDiagnostics(",
    "      databaseDiagnostics = list(",
    "        snapshot = TRUE,",
    "        personTableSummary = TRUE,",
    "        observationPeriodsSummary = TRUE",
    "      ),",
    "      codelistDiagnostics = list(",
    "        achillesCodeUse = TRUE,",
    "        orphanCodeUse = TRUE,",
    "        cohortCodeUse = TRUE,",
    "        drugDiagnostics = NULL,",
    "        drugDiagnosticsSample = NULL,",
    "        measurementDiagnostics = NULL,",
    "        measurementDiagnosticsSample = NULL",
    "      ),",
    "      cohortDiagnostics = list(",
    "        cohortCount = TRUE,",
    "        cohortCharacteristics = TRUE,",
    "        largeScaleCharacteristics = TRUE,",
    "        compareCohorts = TRUE,",
    "        cohortSurvival = NULL,",
    "        cohortSample = NULL,",
    "        matchedSample = NULL",
    "      ),",
    "      populationDiagnostics = list(",
    "        incidence = TRUE,",
    "        periodPrevalence = TRUE,",
    "        populationSample = NULL,",
    "        populationDateRange = as.Date(c(NA, NA))",
    "      ),",
    "      stagingDirectory = NULL",
    "    )",
    "",
    "  file_name_diagnostics <- paste(",
    "    \"diagnostics\",",
    "    \"{cdm_name}_{date}.csv\",",
    "    sep = \"_\"",
    "  )",
    "  ParallelLogger::logInfo(",
    "    glue::glue(",
    "      \"Exporting PhenotypeDiagnostics results for: {file_name_diagnostics}\"",
    "    )",
    "  )",
    "",
    "  omopgenerics::exportSummarisedResult(",
    "    result_diagnostics,",
    "    fileName = file_name_diagnostics,",
    "    path = resultsDir,",
    "    minCellCount = minCell",
    "  )",
    "  ParallelLogger::logInfo(",
    "    glue::glue(",
    "      \"PhenotypeDiagnostics completed; results in folder: {resultsDir}\"",
    "    )",
    "  )",
    "",
    "  ParallelLogger::logInfo(",
    "    \"Exporting results in zip format\"",
    "  )",
    "  zipFileName <- glue::glue(",
    "    \"{resultsDir}/results_diagnostics_{dbname}_{format(Sys.Date(), format='%Y%m%d')}.zip\"",
    "  )",
    "  zip::zip(",
    "    zipfile = zipFileName,",
    "    files = resultsDirName,",
    "    root = outputDir",
    "  )",
    "  checkmate::assertFileExists(zipFileName)",
    "  ParallelLogger::logInfo(\"-- Thank you for running the diagnostics!\")",
    "}"
  )
}

#' Load default content for `README.Rmd`
#'
#' @param studyNumber Character string identifying the study number, e.g. `"P1-C1-001"`.
#'
#' @return
#' A character vector containing the default contents of `README.Rmd`, to be
#' rendered into `README.md` through .
defaultContentREADME <- function(studyNumber) {
  c(
    "![](man/figures/darwin-eu_logo.png)",
    "",
    "[Study title]",
    "=============",
    "",
    paste0("**DARWIN EU ID:** ", studyNumber),
    "",
    "**HMA-EMA Study Catalogue:** **[EUPAS-](add link)**",
    "",
    "**Results Explorer:** **[Web Application](add link)**",
    "",
    "**Study Description:**",
    "",
    "(add text from HMA-EMA Study Catalogue here)",
    "",
    "**Instructions:**",
    "",
    "The instructions on how to run the study code are provided in the [instructions.md](instructions.md) file.",
    "",
    "**Disclaimer:**",
    "",
    "This study code is developed for execution on the selected data sources of the DARWIN EU Data Network as described in the study protocol.",
    "While the DARWIN EU Coordination Centre does not provide support to external users of this code, we welcome feedback via our email address (enquiries@darwin-eu.org).",
    "",
    "**License:**",
    "",
    "This software is distributed under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0) on an \"AS IS\" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.",
    "",
    "For more information about DARWIN EU<sup>\u00ae</sup> see [www.darwin-eu.org](https://www.darwin-eu.org).",
    "",
    "Copyright 2026 European Medicines Agency."
  )
}

#' Load default content for `instructions.md`
#'
#' @param studyNumber Character string identifying the study number, e.g. `"P1-C1-001"`.
#'
#' @return
#' A character vector containing the default contents of `instructions.md`.
defaultContentInstructions <- function(studyNumber) {
  c(
    "# Instructions",
    "",
    "The example execution code is also available in `extras/CodeToRun.R`.",
    "",
    "## 1. Install Dependencies",
    "",
    "Make sure `renv` is installed:",
    "",
    "```r",
    "install.packages(\"renv\")",
    "```",
    "",
    "Restore the project library from the lock file:",
    "",
    "```r",
    "renv::init()",
    "renv::restore()",
    "```",
    "",
    "## 2. Install the Package",
    "",
    "Install the package from the project source",
    "",
    "In RStudio, use `Build` -> `Install and Restart`, or install it from the project root with:",
    "",
    "```r",
    "devtools::install()",
    "```",
    "",
    "Then load the package:",
    "",
    "```r",
    paste0("library(", studyNumber, ")"),
    "```",
    "",
    "## 3. Configure the Database Connection",
    "",
    "Set the connection details for your environment:",
    "",
    "```r",
    "dbms <- Sys.getenv(\"dbms\")",
    "server <- Sys.getenv(\"host\")",
    "user <- Sys.getenv(\"user\")",
    "password <- Sys.getenv(\"password\")",
    "port <- Sys.getenv(\"port\")",
    "```",
    "",
    "Set the output location and CDM details:",
    "",
    "```r",
    "outputDir <- \"...\"",
    "cdmDatabaseSchema <- \"...\"",
    "cohortDatabaseSchema <- \"...\"",
    "cohortTable <- \"...\"",
    "dbname <- \"...\"",
    "```",
    "",
    "Create the database connection and CDM reference:",
    "",
    "```r",
    "conn <- DBI::dbConnect(",
      "dbms = dbms,",
      "server = server,",
      "user = user,",
      "password = password,",
      "port = port",
    ")",
    "",
    "cdm <- CDMConnector::cdmFromCon(",
      "con = conn,",
      "cdmSchema = cdmDatabaseSchema,",
      "writeSchema = cohortDatabaseSchema,",
      "cdmName = dbname",
    ")",
    "```",
    "",
    "## 4. Run the Study",
    "",
    "Execute the study with the required options:",
    "",
    "```r",
    paste0(studyNumber, "::runStudy("),
    "  ...",
    ")",
    "```",
    "",
    "## 5. Review the Results",
    "",
    "# If the study was successful, use the code below to review the results.",
    "",
    "```",
    "...",
    "```",
    "",
    "## 6. Return Results to the CC",
    "",
    paste0("After reviewing the outputs, please upload the ZIP file to the `", studyNumber, "` folder in the Data Transfer Zone (DTZ).")
  )
}

#' Load default content for `CodeToRun.R`
#'
#' @param studyNumber Character string identifying the study number, e.g. `"P1-C1-001"`.
#'
#' @return
#' A character vector containing the default contents of `extras/CodeToRun.R`.
defaultContentCodeToRun <- function(studyNumber) {
  c(
    "# *******************************************************",
    paste0("# ", studyNumber, ": Code to Run"),
    "# *******************************************************",
    "",
    "# This script mirrors the execution steps described in instructions.md.",
    "# Update the placeholder values before running the study.",
    "",
    "# *******************************************************",
    "# SECTION 1: Install dependencies",
    "# ******************************************************",
    "",
    "# Install renv if needed",
    "install.packages(\"renv\")",
    "",
    "# Build or restore the project library from the lock file",
    "renv::init()",
    "renv::restore()",
    "",
    "# *******************************************************",
    "# SECTION 2: Install and load the package",
    "# *******************************************************",
    "",
    "# In RStudio, use Build -> Install and Restart",
    "# Or install from the project root with:",
    "devtools::install()",
    "",
    "# Then load the package",
    paste0("library(", studyNumber, ")"),
    "",
    "# *******************************************************",
    "# SECTION 3: Configure the database connection",
    "# *******************************************************",
    "",
    "# The name/acronym for the database.",
    "# Choose yours between \"BCR\", \"IQVIA LPD Belgium\", \"UZA\", \"NAJS\", \"DK-DHR\",\"EBB\",",
    "# \"HARMONY Platform\", \"HARMONY-ALL\", \"HARMONY-AML\", \"HARMONY-CML\", \"HARMONY-MM\", ",
    "# \"FinOMOP-ACI Varha\", \"FinOMOP-HUS\", \"FinOMOP-TaUH Pirha\", \"FinOMOP-THL\",",
    "# \"APHM\", \"CDW Bordeaux\", \"SNDS\", \"InGef RDB\", \"IQVIA DA Germany\", \"UMD\", \"PGH\",",
    "# \"SUCD\", \"Pedianet\", \"POLIMI\", \"LDH\", \"CRN\", \"NLHR\", \"NLHR@UiO:PERINATAL\",",
    "# \"EMDB-ULSEDV\", \"EMDB-ULSGE\", \"EMDB-ULSRA\", \"ULSM-RT\", \"BIFAP\", \"H12O\",",
    "# \"HUVM\", \"IMASIS\", \"PRISIB\", \"SIDIAP\", \"VID\", \"HI-SPEED\", \"IPCI\",",
    "# \"NCR\", \"CPRD AURUM\", \"CPRD Aurum Linked\", \"CPRD GOLD\", \"UKBB\", \"IQVIA US - AmbEMR\",",
    "# \"IQVIA US - PMTX+\"",
    "",
    "dbname <- \"\"",
    "",
    "# Database connection details",
    "# In this study we also use the DBI package to connect to the database",
    "# set up the dbConnect details below",
    "# https://darwin-eu.github.io/CDMConnector/articles/DBI_connection_examples.html",
    "# for more details.",
    "# you may need to install another package for this",
    "# e.g. for postgres",
    "# db <- dbConnect(",
    "#   RPostgres::Postgres(),",
    "#   dbname = server_dbi,",
    "#   port = port,",
    "#   host = host,",
    "#   user = user,",
    "#   password = password",
    "# )",
    "db <- DBI::dbConnect()",
    "",
    "# The name of the schema that contains the OMOP CDM with patient-level data",
    "cdm_schema <- \"\"",
    "",
    "# A prefix for all permanent tables in the database",
    "write_prefix <- \"\"",
    "",
    "# The name of the schema where results tables will be created",
    "write_schema <- \"\"",
    "",
    "# The name of the schema where the achilles tables are",
    "achilles_schema <- \"\"",
    "",
    "# minimum counts that can be displayed according to data governance",
    "minCellCount <- 5",
    "",
    "# Create cdm object ----",
    "cdm <- CDMConnector::cdmFromCon(",
      "con = db,",
      "cdmSchema = cdm_schema,",
      "writeSchema = write_schema,",
      "writePrefix = write_prefix,",
      "cdmName = db_name,",
      "achillesSchema = achilles_schema",
    ")",
    "",
    "# *******************************************************",
    "# SECTION 4: Run the code",
    "# *******************************************************",
    "",
    "# Execute the diagnostics or the study code",
    paste0("# ", studyNumber, "::runStudy(...)"),
    "",
    "# *******************************************************",
    "# SECTION 5: Review the results",
    "# *******************************************************",
    "",
    "# Diagnostics results",
    "# ...",
    "#",
    "# Study results",
    "# ..."
  )
}
