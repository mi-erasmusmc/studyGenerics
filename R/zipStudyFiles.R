#' `zipStudyFiles()` compress study results
#'
#' @param resultsDirName Location of the results. Character.
#' @param outputDir The directory where the results folder is located. Character
#' @param dbname The database name. Character
#'
#' @returns A message stating the location of the compressed results
#'
#' @importFrom checkmate assertDirectoryExists assertFileExists
#' @importFrom zip zip
#' @importFrom cli cli_alert_info cli_alert_success
#' @importFrom glue glue
#'
#' @export
#' @examples
#' outputDir <- file.path(
#'    tempdir(),
#'    "examples"
#'    )
#' dbname <- "IPCI"
#' directories <- createResultsDir(
#'   outputDir,
#'   dbname = dbname
#' )
#' zipStudyFiles(
#'   resultsDirName = directories$resultsDir,
#'   outputDir = directories$outputDir,
#'   dbname = dbname
#' )
#' unlink(outputDir, recursive = TRUE)
zipStudyFiles <- function(
    resultsDirName,
    outputDir,
    dbname
) {
  resultsDirName <- normalizePath(resultsDirName)
  outputDir <- normalizePath(outputDir)
  checkmate::assertDirectoryExists(resultsDirName)
  checkmate::assertDirectoryExists(outputDir)
  assertCdmNames(dbname)
  cli::cli_alert_info(
    "Exporting results to zip format"
    )
  zipFileName <- glue::glue(
    "{resultsDirName}/results_{dbname}_{format(Sys.Date(), format='%Y%m%d')}.zip"
    )
  zip::zip(
    zipfile = zipFileName,
    files = basename(resultsDirName),
    root = outputDir
    )
  checkmate::assertFileExists(zipFileName)
  cli::cli_alert_success(
    glue::glue(
      "Results exported to {zipFileName}"
    )
  )
  return(invisible())
}
