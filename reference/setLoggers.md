# Configure study loggers that write text files to the results directory

Configures the `ohdsi/ParallelLogger` logger and error report for a
study. The logger is registered as 'OMOP_STUDY_LOGGER' and the error
report as 'OMOP_STUDY_ERROR_REPORT'. Please note: avoid using it inside
[`tryCatch()`](https://rdrr.io/r/base/conditions.html) or similar
because events will not be observed or recorded by ParallelLogger.

## Usage

``` r
setLoggers(
  resultsDir,
  logFileName = "log",
  errorFileName = "error",
  eventLevel = "TRACE",
  errorLevel = "ERROR"
)
```

## Arguments

- resultsDir:

  A valid folder where to save the results of a study. This function
  will work best with the folder structure formed by
  [`createResultsDir()`](https://mi-erasmusmc.github.io/studyGenerics/reference/createResultsDir.md)

- logFileName:

  A character string specifying the file name. Default 'log'

- errorFileName:

  A character string specifying the file name. Default 'error'

- eventLevel:

  TRACE is the default, captures all the output from the console

- errorLevel:

  ERROR is the default, captures errors and fatal events

## Value

Invisible

## Examples

``` r
outputDir <- file.path(
   tempdir(),
   "examples"
)
directories <- createResultsDir(
   outputDir,
   dbname = "OMOP"
   )
#> ℹ Creating locations to save results
setLoggers(
  resultsDir = directories$resultsDir
  )
#> Currently in a tryCatch or withCallingHandlers block, so unable to add global calling handlers. ParallelLogger will not capture R messages, errors, and warnings, only explicit calls to ParallelLogger. (This message will not be shown again this R session)
#> Logger file will be created at: /tmp/Rtmp0pZY7y/examples/results_OMOP
ParallelLogger::clearLoggers()
unlink(outputDir, recursive = TRUE)
```
