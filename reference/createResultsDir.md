# Create directory for analysis results

Creates a subdirectory for results based on the database name within a
specified output directory.

## Usage

``` r
createResultsDir(outputDir, dbname)
```

## Arguments

- outputDir:

  Character string. The path to the main output folder. This must be
  supplied explicitly.

- dbname:

  Character string. The name of the database, used to suffix the results
  folder (e.g., "results_dbname").

## Value

A list containing three elements:

- `outputDir`: The path to the main output directory.

- `resultsDir`: The path to the specific results subdirectory created.

- `resultsDirName`: The name of the results subdirectory.

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
unlink(outputDir, recursive = TRUE)
```
