# Create directory for analysis results

Creates a subdirectory for results based on the database name within a
specified output directory. If the output directory is not provided, the
current working directory is used.

## Usage

``` r
createResultsDir(outputDir = NULL, dbname)
```

## Arguments

- outputDir:

  Character string. The path to the main output folder. If NULL,
  defaults to the current working directory. Default NULL.

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
