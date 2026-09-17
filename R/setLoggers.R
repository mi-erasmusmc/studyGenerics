#' Configure study loggers that write text files to the results directory
#'
#' @description
#' Configures the `ohdsi/ParallelLogger` logger and error report for a study. The logger
#' is registered as 'OMOP_STUDY_LOGGER' and the error report as 'OMOP_STUDY_ERROR_REPORT'.
#' Please note: avoid using it inside `tryCatch()` or similar because events
#' will not be observed or recorded by ParallelLogger.
#'
#' @param resultsDir A valid folder where to save the results of a study.
#'    This function will work best with the folder structure formed by
#'    `createResultsDir()`
#' @param logFileName A character string specifying the file name. Default 'log'
#' @param errorFileName A character string specifying the file name. Default 'error'
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
