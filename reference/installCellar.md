# `installCellar()` install files already saved in a cellar

`installCellar()` install files already saved in a cellar

## Usage

``` r
installCellar(path, project, library, lockfile)
```

## Arguments

- path:

  Character string giving the cellar path. This must be supplied
  explicitly.

- project:

  Character string giving the project path. If omitted, defaults to
  [`usethis::proj_get()`](https://usethis.r-lib.org/reference/proj_utils.html).

- library:

  Character string giving the library path. This must be supplied
  explicitly.

- lockfile:

  Character string giving the lockfile path. If omitted, defaults to
  `renv.lock` at the project base level provided by
  [`usethis::proj_get()`](https://usethis.r-lib.org/reference/proj_utils.html).

## Value

Invisible

## Examples

``` r

if (FALSE) { # \dontrun{
# It will install all packages in the cellar
installCellar(
  path = file.path(tempdir(), "cellar"),
  library = file.path(tempdir(), "library")
)
} # }
```
