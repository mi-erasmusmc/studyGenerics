# \`setLoggers()\` as text files in the results directory

Sets \`ohdsi/ParallelLogger\` log and error report for a study. Logger
registered as 'OMOP_STUDY_LOGGER' and error report as
'OMOP_STUDY_ERROR_REPORT'. Please note: avoid using inside a tryCatch()
or similar because events will not be 'obsorbed' and not recorded by
ParallelLogger.

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
  \`createsResultsDir()\`

- logFileName:

  A file name in character. Default 'log'

- errorFileName:

  A file name in character. Default 'error'

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
#> Logger file will be created at: /tmp/Rtmpejx70J/examples/results_OMOP
ParallelLogger::clearLoggers()
unlink(outputDir, recursive = TRUE)
```
