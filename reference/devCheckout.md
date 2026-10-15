# `devCheckout()` checks out the `develop` branch and pulls its latest changes.

Checks out the `develop` branch and pulls changes from its remote.

## Usage

``` r
devCheckout(verbose = FALSE)
```

## Arguments

- verbose:

  Logical. Whether to show Git pull progress. Defaults to `FALSE`; a
  concise completion message is always shown.

## Value

Invisibly, the result of pulling `develop`.

## Examples

``` r
if (FALSE) { # \dontrun{
# Requires access to the configured Git remote
devCheckout()
} # }
```
