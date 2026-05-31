#' `unZipStudyFiles()` uncompress study results
#'
#' @param path The path to the directory where the .zip files are located. Character.
#' @param pattern A character string to filter the files from the location provided. Default is NULL.
#' @param negate If TRUE it will filter the opposite from 'pattern'. Default is FALSE.
#' @param recursive If TRUE it will search recursively for .zip files. Default is TRUE.
#' @param outputDir The path to the main output folder. Character.
#'
#' @returns A message stating the location of the uncompressed results
#'
#' @importFrom checkmate assertDirectoryExists assertLogical
#' @importFrom stringr str_detect
#' @importFrom zip unzip
#' @importFrom cli cli_alert_success cli_abort
#' @importFrom glue glue
#'
#' @export
unZipStudyFiles <- function(
    path,
    pattern,
    negate = FALSE,
    recursive = TRUE,
    outputDir
) {
  path <- normalizePath(path)
  outputDir <- normalizePath(outputDir)
  checkmate::assertDirectoryExists(path)
  checkmate::assertLogical(recursive)

  zip_files <- list.files(
    path = path,
    pattern = ".zip",
    full.names = TRUE,
    recursive = recursive
  )

  if (!length(zip_files)) {
    cli::cli_abort(
      glue::glue(
        "Files with .zip extension couldn't be found in: {outputDir}"
        )
      )
    return(invisible(NULL))
  }

  if (!missing(pattern)) {

    checkmate::assertCharacter(pattern)
    checkmate::assertLogical(negate)

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

  for (i in 1:length(zip_files)) {
    zip::unzip(
      zip_files[i],
      exdir = outputDir
    )
  }

  cli::cli_alert_success(
    glue::glue(
      "Files unzipped to: {outputDir}"
    )
  )
  return(invisible(NULL))
}
