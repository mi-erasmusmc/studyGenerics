# \`unZipStudyFiles()\` uncompress study results

\`unZipStudyFiles()\` uncompress study results

## Usage

``` r
unZipStudyFiles(path, pattern, negate = FALSE, recursive = TRUE, outputDir)
```

## Arguments

- path:

  The path to the directory where the .zip files are located. Character.

- pattern:

  A character string to filter the files from the location provided.
  Default is NULL.

- negate:

  If TRUE it will filter the opposite from 'pattern'. Default is FALSE.

- recursive:

  If TRUE it will search recursively for .zip files. Default is TRUE.

- outputDir:

  The path to the main output folder. Character.

## Value

A message stating the location of the uncompressed results

## Examples

``` r
 if (FALSE) { # \dontrun{
path <- testthat::test_path(
   "data",
   "results_execution"
)
outputDir <- file.path(
  tempdir(),
  "examples"
)
unZipStudyFiles(
  path = path,
  outputDir = outputDir
)
unlink(outputDir, recursive = TRUE)
} # }
```
