# `installCellar()` install files already saved in a cellar

`installCellar()` install files already saved in a cellar

## Usage

``` r
installCellar(path, project, library, lockfile)
```

## Arguments

- path:

  Character string giving the cellar path. If omitted, defaults to
  `renv/cellar`.

- project:

  Character string giving the project path. If omitted, defaults to
  [`usethis::proj_get()`](https://usethis.r-lib.org/reference/proj_utils.html).

- library:

  Character string giving the library path. If omitted, defaults to
  `renv/library`.

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
installCellar()
} # }
```
