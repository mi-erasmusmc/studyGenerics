#' `zipStudyFiles()` compresses study results
#'
#' @param outputDir Character string giving the path to the base output directory.
#' @param resultsDirName Character string giving the name or path of the results subfolder.
#' @param dbname Character string giving the database identifier.
#' 
#' @returns Character string containing the file name of the generated zip archive.
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
    outputDir,
    resultsDirName,
    dbname
) {
  outputDir <- normalizePath(outputDir)
  checkmate::assertDirectoryExists(outputDir)
  resultsDirName <- basename(resultsDirName)
  assertCdmNames(dbname)
  cli::cli_alert_info(
    "Exporting results to zip format"
    )
  zipFileName <- glue::glue(
      "results_{dbname}_{format(Sys.Date(), format='%Y%m%d')}.zip"
    )
  zipFileNamePath <- file.path(
      resultsDirName,
      zipFileName
    )
  zip::zip(
    zipfile = zipFileNamePath,
    files = resultsDirName,
    root = outputDir
    )
  checkmate::assertFileExists(
    file.path(
      outputDir,
      zipFileNamePath
    )
  )
  cli::cli_alert_success(
    glue::glue(
      "Results exported to {file.path(outputDir, zipFileNamePath)}"
    )
  )
  return(zipFileName)
}
