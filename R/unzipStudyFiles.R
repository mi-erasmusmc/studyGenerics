#' Unzip study result files
#'
#' Finds zip files under `path` and extracts them to `outputDir`.
#'
#' @param path Character directory where zip files are searched.
#' @param recursive Logical indicating whether to search recursively for zip files.
#' @param pattern Optional regular expression used to filter zip file paths.
#' For instance, just unzip those files that do not belong to a 'DED' folder.
#' @param negate Logical passed to `stringr::str_detect()` to negate the optional pattern argument.
#' @param outputDir Character directory where files will be unzipped.
#'
#' @returns Invisible called for its side effects.
#'
#' @importFrom checkmate assertDirectoryExists assertLogical
#' @importFrom stringr str_detect
#' @importFrom zip unzip
#' @importFrom cli cli_alert_success cli_abort
#' @importFrom glue glue
#'
#' @export
#'
#' @examples
#'  \dontrun{
#' # It will unzip folders in temp file
#' path <- testthat::test_path(
#'    "data",
#'    "results_execution"
#' )
#' outputDir <- file.path(
#'   tempdir(),
#'   "examples"
#' )
#' unZipStudyFiles(
#'   path = path,
#'   outputDir = outputDir
#' )
#' unlink(outputDir, recursive = TRUE)
#' }
unZipStudyFiles <- function(
    path,
    recursive = FALSE,
    pattern,
    negate = TRUE,
    outputDir
    ) {
  checkmate::assertDirectoryExists(path)
  zip_files <- list.files(
    path = path,
    pattern = ".zip",
    full.names = TRUE,
    recursive = recursive
    )
  if (!missing(pattern) & !missing(recursive)) {
    checkmate::assertLogical(negate)
    checkmate::assertLogical(recursive)
    index_files <- stringr::str_detect(
      zip_files,
      pattern = pattern,
      negate = negate
    )
    zip_files <- zip_files[index_files]
  }
  if (!dir.exists(outputDir)) {
    dir.create(outputDir)
  }
  if (length(zip_files) > 0) {
    for (i in 1:length(zip_files)) {
      zip::unzip(
        zip_files[i],
        exdir = outputDir
        )
    } 
    cli::cli_alert_success(
      glue::glue(
        "Files successfully unzipped to: {outputDir}"
      )
    )
  } else {
    cli::cli_abort(
      glue::glue(
        "No zip files to uncompress"
      ), 
      class = "No files found"
   )
  }
  return(invisible())
}
