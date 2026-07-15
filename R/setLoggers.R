#' `setLoggers()` as text files in the results directory
#'
#' @description
#' Sets `ohdsi/ParallelLogger` log and error report for a study. Logger
#' registered as 'OMOP_STUDY_LOGGER' and error report as 'OMOP_STUDY_ERROR_REPORT'.
#' Please note: avoid using inside a tryCatch() or similar because events
#' will not be 'obsorbed' and not recorded by ParallelLogger.
#'
#' @param resultsDir A valid folder where to save the results of a study.
#'    This function will work best with the folder structure formed by
#'    `createsResultsDir()`
#' @param logFileName A file name in character. Default 'log'
#' @param errorFileName A file name in character. Default 'error'
#' @param eventLevel TRACE is the default, captures all the output from
#'    the console
#' @param errorLevel ERROR is the default, captures errors and fatal events
#'
#' @returns Invisible
#'
#' @importFrom checkmate assertDirectoryExists
#' @importFrom checkmate assertCharacter
#' @importFrom fs path_ext_set
#' @importFrom ParallelLogger registerLogger createLogger createFileAppender layoutParallel
#' @importFrom cli cli_alert_info
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
#' setLoggers(
#'   resultsDir = directories$resultsDir
#'   )
#' ParallelLogger::clearLoggers()
#' unlink(outputDir, recursive = TRUE)
setLoggers <- function(
    resultsDir,
    logFileName = "log",
    errorFileName = "error",
    eventLevel = "TRACE",
    errorLevel = "ERROR"
) {

  checkmate::assertDirectoryExists(resultsDir)
  checkmate::assertCharacter(logFileName)
  checkmate::assertCharacter(errorFileName)

  stopifnot(
    'eventLevel should be one of:
    "TRACE", "DEBUG", "INFO", "WARN",
    "ERROR", "FATAL"' = eventLevel %in% c(
      "TRACE", "DEBUG", "INFO", "WARN", "ERROR", "FATAL"
    )
  )

  # Logger ----
  logFileLocation <- file.path(
    resultsDir,
    fs::path_ext_set(
      logFileName,
      ".txt"
    )
  )
  ParallelLogger::registerLogger(
    logger <- ParallelLogger::createLogger(
      name =  "OMOP_STUDY_LOGGER",
      threshold = eventLevel,
      appenders = list(
        ParallelLogger::createFileAppender(
          layout = ParallelLogger::layoutParallel,
          fileName = logFileLocation
        )
      )
    )
  )
  ParallelLogger::logInfo(
    glue::glue(
      "Logger file will be created at: {resultsDir}"
    )
  )
  checkmate::assertFileExists(logFileLocation)

  # Error ---------------
  errorFileLocation <- file.path(
    resultsDir,
    fs::path_ext_set(
      errorFileName,
      ".txt"
    )
  )

  ParallelLogger::registerLogger(
    ParallelLogger::createLogger(
      name = "OMOP_STUDY_ERROR_REPORT",
      threshold = errorLevel,
      appenders = list(
        ParallelLogger::createFileAppender(
          layout = ParallelLogger::layoutErrorReport,
          fileName = errorFileLocation,
          overwrite = TRUE,
          expirationTime = 60
        )
      )
    )
  )

 return(invisible())
}
