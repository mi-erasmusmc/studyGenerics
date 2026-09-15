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

    for (pkg in pkg_names) {
      usethis::use_package(pkg)
    }

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
#' @return
#' No return value.
insertDocs <- function(path) {
  withr::with_dir(path, {
    usethis::use_news_md(open = FALSE)
    usethis::use_readme_rmd(open = FALSE)
    if ("LICENSE" %in% list.files(path)) {
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
    unlink(file.path(path, "R", "hello.R"))
  }
  usethis::use_r("createCohorts", open = FALSE)
  writeLines(createCohortsFun(), file.path(path, "R", "createCohorts.R"))
  usethis::use_r("runStudy", open = FALSE)
  usethis::use_r("runDiagnostics", open = FALSE)
  writeLines(runDiagnosticsFun(), file.path(path, "R", "runDiagnostics.R"))
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
    unlink(file.path(path, "man", "hello.Rd"))
  }
  # inst/
  dir.create(file.path(path, "inst"))
  dir.create(file.path(path, "inst", "cohorts"))
  dir.create(file.path(path, "inst", "concept_sets"))
  # extras/
  dir.create(file.path(path, "extras"))
  invisible(file.create(file.path(path, "extras", "CodeToRun.R")))
  invisible(file.create(file.path(path, "extras", "pullConceptSetsFromAtlas.R")))
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
#' It assumes an active R project has already been created and renv
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


#' Load default content for createCohorts.R
#'
#' @param path Character string identifying the path to the study project,
#' default `"."`.
#'
#' @return
#' No return value.
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


#' Load default content for runDiagnostics.R
#'
#' @param path Character string identifying the path to the study project,
#' default `"."`.
#'
#' @return
#' No return value.
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
    "#' results, logs, and the final zip archive will be written. If `NULL`, the",
    "#' current working directory is used.",
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
    "  outputDir = NULL,",
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
