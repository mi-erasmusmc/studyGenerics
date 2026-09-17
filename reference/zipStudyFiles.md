# `zipStudyFiles()` compresses study results

`zipStudyFiles()` compresses study results

## Usage

``` r
zipStudyFiles(outputDir, resultsDirName, dbname)
```

## Arguments

- outputDir:

  Character string giving the path to the base output directory.

- resultsDirName:

  Character string giving the name or path of the results subfolder.

- dbname:

  Character string giving the database identifier.

## Value

Character string containing the file name of the generated zip archive.

## Examples

``` r
outputDir <- file.path(
   tempdir(),
   "examples"
   )
dbname <- "IPCI"
directories <- createResultsDir(
  outputDir,
  dbname = dbname
)
#> ℹ Creating locations to save results
zipStudyFiles(
  resultsDirName = directories$resultsDir,
  outputDir = directories$outputDir,
  dbname = dbname
)
#> ℹ Exporting results to zip format
#> ✔ Results exported to /tmp/Rtmph8oL25/examples/results_IPCI/results_IPCI_20260917.zip
#> results_IPCI_20260917.zip
unlink(outputDir, recursive = TRUE)
```
