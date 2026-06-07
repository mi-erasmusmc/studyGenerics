# Download zip-compressed Windows binaries from a renv.lock file

A function that locates and downloads Windows binaries (.zip) from CRAN
based on packages specified in a renv.lock file.

## Usage

``` r
getPkgZips(
  lockfile_path = NULL,
  supplement = NULL,
  override_lock = FALSE,
  r_rels_vect = c("4.0", "4.1", "4.2", "4.3", "4.4", "4.5", "4.6"),
  backupRrel = "4.4",
  outDir = NULL
)
```

## Arguments

- lockfile_path:

  Path to renv.lock file, if empty will search for renv.lock in project
  directory

- supplement:

  Nested list of packages to supplement or use in place of a renv.lock
  file

- override_lock:

  Logical. Default is FALSE. If set to TRUE and the same package is
  named in both the renv.lock and the supplement, the version called in
  the supplement will override the renv.lock

- r_rels_vect:

  A character vector of R minor releases

- backupRrel:

  A string of the R minor-release to use if preferred package version
  cannot be found under any of the minor releases specified in
  \`r_rels_vect\`

- outDir:

  Path to output directory for package zips. If left empty, an output
  directory will be created in project 'renv' directory

## Value

In addition to downloading the specified packages into the outDir,
returns a list of packages that were searched for as well as the URLs,
versions (if found), etc.

## Details

If the package version is not found under any of the R minor releases,
the package will be downloaded from the specified \`backupRrel\`
regardless of package version specified in renv.lock

## Examples

``` r
if (FALSE) { # \dontrun{
pkg_status_list <- getPkgZips()
# Format supp in this way:
devtools <- list(Package = "devtools", Version = "2.5.1")
duckdb <- list(Package = "duckdb", Version = "1.5.2")
supp <- list(Packages = list(devtools = devtools, duckdb = duckdb))
pkg_status_list <- getPkgZips(supplement = supp)
} # }
```
