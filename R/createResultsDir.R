#' Create directory for analysis results
#'
#' @description
#' Creates a subdirectory for results based on the database name within a
#' specified output directory.
#'
#' @param outputDir Character string. The path to the main output folder.
#'                  This must be supplied explicitly.
#' @param dbname Character string. The name of the database, used to suffix
#'               the results folder (e.g., "results_dbname").
#'
#' @returns A list containing three elements:
#' \itemize{
#'   \item \code{outputDir}: The path to the main output directory.
#'   \item \code{resultsDir}: The path to the specific results subdirectory created.
#'   \item \code{resultsDirName}: The name of the results subdirectory.
#' }
#'
#' @importFrom cli cli_alert_info
#' @importFrom checkmate assertDirectoryExists
#' @importFrom glue glue
#'
#' @export
#'
#' @examples
#' outputDir <- file.path(
#'    tempdir(),
#'    "examples"
#' )
#' directories <- createResultsDir(
#'    outputDir,
#'    dbname = "OMOP"
#'    )
#' unlink(outputDir, recursive = TRUE)
createResultsDir <- function(
    outputDir,
    dbname
    ) {
  if (missing(outputDir)) {
    cli::cli_abort("{.arg outputDir} must be supplied explicitly.")
  }
  # Set folder location for results ----
  cli::cli_alert_info(
    "Creating locations to save results"
    )
  checkmate::assertCharacter(outputDir, len = 1, any.missing = FALSE)
  if (!dir.exists(outputDir)) {
    dir.create(outputDir, recursive = TRUE)
    checkmate::assertDirectoryExists(outputDir)
  } else {
    outputDir <- normalizePath(outputDir)
    checkmate::assertDirectoryExists(outputDir)
  }
resultsDirName <- glue::glue(
    "results_{dbname}"
    )
  resultsDir <- file.path(
    outputDir,
    resultsDirName
  )
  if (!dir.exists(resultsDir)) {
    dir.create(resultsDir)
  }
  checkmate::assertDirectoryExists(resultsDir)
  return(
    list(
      outputDir = outputDir,
      resultsDir = resultsDir,
      resultsDirName = resultsDirName
    )
  )
}
