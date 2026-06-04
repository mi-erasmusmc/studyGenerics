#' Create directory for analysis results
#'
#' @description
#' Creates a subdirectory for results based on the database name within a
#' specified output directory. If the output directory is not provided, the
#' current working directory is used.
#'
#' @param outputDir Character string. The path to the main output folder.
#'                  If NULL, defaults to the current working directory. Default NULL.
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
createResultsDir <- function(
    outputDir = NULL,
    dbname
    ) {
  # Set folder location for results ----
  cli::cli_alert_info(
    "Creating locations to save results"
    )
  if (is.null(outputDir)) {
    outputDir <- getwd()
    checkmate::assertDirectoryExists(
      outputDir
      )
  } else {
    if (!dir.exists(outputDir)) {
      dir.create(
        outputDir
        )
      checkmate::assertDirectoryExists(
        outputDir
        )
    } else {
      outputDir <- normalizePath(
        outputDir
        )
      checkmate::assertDirectoryExists(
        outputDir
        )
    }
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
  checkmate::assertDirectoryExists(
    resultsDir
    )
  return(
    list(
      outputDir = outputDir,
      resultsDir = resultsDir,
      resultsDirName = resultsDirName
    )
  )
}
