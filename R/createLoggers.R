#' `createLoggers()` as a text file in a results directory
#'
#' @description
#' Sets `ohdsi/ParallelLogger` log and error report for a study
#'
#' @param resultsDir A valid folder where to save the results of a study.
#'    This function will work best with the folder structure formed by
#'    `createsResultsDir()`
#' @param loggerName A name in character. Default 'OMOP_STUDY_LOGGER'
#' @param logFileName A file name in character. Default 'log'
#' @param errorFileName A file name in character. Default 'error'
#' @param eventLevel TRACE is the default, captures all the output from
#'    the console
#' @returns Invisible
#' @export
#'
#' @examples
#' directories <- createResultsDir()
#' createLogger(
#'   resultsDir = directories$resultsDir
#'   )
#' @importFrom checkmate assertDirectoryExists
#' @importFrom checkmate assertCharacter
#' @importFrom fs path_ext_set
#' @importFrom ParallelLogger registerLogger
#' @importFrom ParallelLogger createLogger
#' @importFrom ParallelLogger createFileAppender
#' @importFrom ParallelLogger layoutParallel
#' @importFrom cli cli_alert_info
#' @importFrom glue glue
createLoggers <- function(
    resultsDir,
    loggerName = "OMOP_STUDY",
    logFileName = "log",
    errorFileName = "error",
    eventLevel = "TRACE"
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
      name = loggerName,
      threshold = eventLevel,
      appenders = list(
        ParallelLogger::createFileAppender(
          layout = ParallelLogger::layoutParallel,
          fileName = logFileLocation
        )
      )
    )
  )
  cli::cli_alert_info(
    glue::glue(
      "Logger file created at: {resultsDir}"
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
      name = "DEFAULT_ERROR_REPORT_LOGGER",
      threshold = "FATAL",
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
