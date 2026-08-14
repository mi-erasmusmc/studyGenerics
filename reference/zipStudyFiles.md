# \`zipStudyFiles()\` compress study results

\`zipStudyFiles()\` compress study results

## Usage

``` r
zipStudyFiles(resultsDirName, outputDir, dbname)
```

## Arguments

- resultsDirName:

  Location of the results. Character.

- outputDir:

  The directory where the results folder is located. Character

- dbname:

  The database name. Character

## Value

A message stating the location of the compressed results

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
#> ✔ Results exported to /tmp/RtmpV39vcn/examples/results_IPCI/results_IPCI_20260814.zip
unlink(outputDir, recursive = TRUE)
```
