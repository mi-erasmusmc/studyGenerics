# Unzip study result files

Finds zip files under `path` and extracts them to `outputDir`.

## Usage

``` r
unZipStudyFiles(path, recursive = FALSE, pattern, negate = TRUE, outputDir)
```

## Arguments

- path:

  Character string giving the directory where zip files are searched.

- recursive:

  Logical indicating whether to search recursively for zip files.

- pattern:

  Optional regular expression used to filter zip file paths. For
  example, use this to exclude files that belong to a 'DED' folder.

- negate:

  Logical passed to
  [`stringr::str_detect()`](https://stringr.tidyverse.org/reference/str_detect.html)
  to negate the optional pattern argument.

- outputDir:

  Character string giving the directory where files will be unzipped.

## Value

Invisible called for its side effects.

## Examples

``` r
 if (FALSE) { # \dontrun{
# Extracts files to a temporary directory
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
