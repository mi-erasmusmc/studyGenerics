# `arrangeCdmNames()` verifies whether data partners' acronyms are valid and returns a vector ordered alphabetically by country.

`arrangeCdmNames()` verifies whether data partners' acronyms are valid
and returns a vector ordered alphabetically by country.

## Usage

``` r
arrangeCdmNames(labels)
```

## Arguments

- labels:

  A character vector of data partners' acronyms

## Value

A character vector

## Examples

``` r
# Verifies acronyms are valid and sorts them in the correct order
labels <- c(
  "BCR",
  "IQVIA US - PMTX+",
  "IQVIA US - AmbEMR",
  "IQVIA LPD Belgium"
  )
arrangeCdmNames(labels = labels)
#> [1] "BCR"               "IQVIA LPD Belgium" "IQVIA US - AmbEMR"
#> [4] "IQVIA US - PMTX+" 
```
