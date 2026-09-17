# `packageCellar()` saves files from a renv.lock file into the 'cellar' folder in `renv`

`packageCellar()` saves files from a renv.lock file into the 'cellar'
folder in `renv`

## Usage

``` r
packageCellar(path, project, lockfile, type = "complete")
```

## Arguments

- path:

  Character string giving the cellar path. If omitted, defaults to
  `renv/cellar`.

- project:

  Character string giving the project path. If omitted, defaults to
  [`usethis::proj_get()`](https://usethis.r-lib.org/reference/proj_utils.html).

- lockfile:

  Character string giving the lockfile path. If omitted, defaults to
  `renv.lock` at the project base level provided by
  [`usethis::proj_get()`](https://usethis.r-lib.org/reference/proj_utils.html).

- type:

  Character string specifying whether to download all packages
  (`"complete"`) or only packages from GitHub (`"github"`).

## Value

Invisible

## Examples

``` r

if (FALSE) { # \dontrun{
# It will download the tar files for every package in the renv.lock
packageCellar()
} # }
```
