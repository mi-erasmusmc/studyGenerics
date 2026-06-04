#' `createLoggers()` as a text file in a results directory
#'
#' @description
#' Sets `ohdsi/ParallelLogger` log and error report for a study
#'
#'
#' @param resultsDir A valid folder where to save the results of a study.
#'    This function will work best with the folder structure formed by
#'    `createsResultsDir()`
#' @param eventLevel TRACE is the default, captures all the output from
#'    the console
#'
#' @returns Invisible
#' @export
#'
#' @examples
#' directories <- createResultsDir()
#' createLogger(
#'   resultsDir = directories$resultsDir
#'   )
#' @importFrom checkmate assertDirectoryExists
#' @importFrom ParallelLogger function
createLoggers <- function(
    resultsDir,
    loggerName = "OMOP STUDY",
    logFileName = "log.txt",
    errorFileName = "error.txt",
    eventLevel = "TRACE"
    ) {

  checkmate::assertDirectoryExists(resultsDir)
  checkmate::assertCharacter(loggerName)

  stopifnot(
    "logFileName doesn't have a '.txt' extension" = fs::path_ext(
      logFileName
      ) == "txt"
  )
  stopifnot(
    "errorFileName doesn't have a '.txt' extension" = fs::path_ext(
      errorFileName
    ) == "txt"
  )
  stopifnot(
    'eventLevel should be one of:
    "TRACE", "DEBUG", "INFO", "WARN",
    "ERROR", "FATAL"' = eventLevel %in% c(
      "TRACE", "DEBUG", "INFO", "WARN", "ERROR", "FATAL"
      )
  )

  logFileLocation <- file.path(
    resultsDir,
    "log.txt"
    )
  checkmate::assertDirectoryExists(logFileLocation)

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
  registerLogger(
    logger
    )

  ParallelLogger::logInfo(
    glue::glue(
      "Logger instantiated at: {resultsDir}"
      )
  )

}
